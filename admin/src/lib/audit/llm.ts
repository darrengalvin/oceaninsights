// Thin unified LLM client for the audit benchmark.
//
// Both providers are called via raw fetch (not their SDKs) so we can:
//   * support brand-new model parameters (Opus 4.7 adaptive thinking,
//     GPT-5.5 reasoning effort) without waiting for SDK bumps;
//   * keep latency/token bookkeeping in one place.
//
// The caller specifies the model by its internal id; this module looks up
// the provider config and dispatches accordingly. The return shape is
// identical across providers so the benchmark code is provider-agnostic.

import { BenchmarkModel, MODEL_BY_ID, estimateCostUsd } from './models';

export interface LlmCallResult {
  text: string;
  inputTokens: number;
  outputTokens: number;
  reasoningTokens: number;
  latencyMs: number;
  costUsd: number;
  raw: unknown;
}

export interface LlmCallOptions {
  systemPrompt: string;
  userPrompt: string;
  responseSchema?: object;
  maxOutputTokens?: number;
}

const ANTHROPIC_URL = 'https://api.anthropic.com/v1/messages';
const OPENAI_URL = 'https://api.openai.com/v1/responses';

// Strip leading/trailing fences and pull the first JSON object out of a string.
// Some providers occasionally wrap valid JSON in markdown fences or prepend
// reasoning preamble; we don't want to fail a benchmark over that.
export function extractJson<T = unknown>(text: string): T {
  const trimmed = text.trim();
  // Try parse direct first — fast path for well-behaved models.
  try {
    return JSON.parse(trimmed) as T;
  } catch {
    // Fall through to extraction.
  }
  const fenceMatch = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/);
  const candidate = fenceMatch ? fenceMatch[1] : trimmed;
  const objectMatch = candidate.match(/\{[\s\S]*\}/);
  if (!objectMatch) {
    throw new Error(`No JSON object found in response. First 200 chars: ${trimmed.slice(0, 200)}`);
  }
  return JSON.parse(objectMatch[0]) as T;
}

export async function callModel(
  modelId: string,
  options: LlmCallOptions
): Promise<LlmCallResult> {
  const model = MODEL_BY_ID[modelId];
  if (!model) throw new Error(`Unknown benchmark model: ${modelId}`);

  if (model.provider === 'anthropic') return callAnthropic(model, options);
  if (model.provider === 'openai') return callOpenAI(model, options);
  throw new Error(`Unsupported provider for ${modelId}`);
}

async function callAnthropic(
  model: BenchmarkModel,
  options: LlmCallOptions
): Promise<LlmCallResult> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) throw new Error('ANTHROPIC_API_KEY not configured');

  // Adaptive thinking is the only thinking-on mode for Opus 4.7. Sonnet 4.6
  // also supports adaptive (recommended) and we use it across the board so
  // both flagships are evaluated under their best-known setting.
  const body: Record<string, unknown> = {
    model: model.apiModel,
    max_tokens: options.maxOutputTokens ?? model.maxOutputTokens,
    messages: [{ role: 'user', content: options.userPrompt }],
    system: options.systemPrompt,
  };

  if (model.thinkingMode === 'adaptive_xhigh') {
    body.thinking = { type: 'adaptive', display: 'omitted' };
    body.output_config = { effort: 'xhigh' };
  } else if (model.thinkingMode === 'adaptive_high') {
    body.thinking = { type: 'adaptive', display: 'omitted' };
    body.output_config = { effort: 'high' };
  }

  const startedAt = Date.now();
  const response = await fetch(ANTHROPIC_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify(body),
  });
  const latencyMs = Date.now() - startedAt;

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Anthropic ${model.apiModel} ${response.status}: ${errorBody}`);
  }

  const result = await response.json();
  const textBlock = result.content?.find((b: { type: string }) => b.type === 'text');
  const text = textBlock?.text ?? '';

  const inputTokens = result.usage?.input_tokens ?? 0;
  const outputTokens = result.usage?.output_tokens ?? 0;
  // Anthropic charges thinking tokens as output tokens, but exposes the
  // breakdown in usage when available so we surface it for transparency.
  const reasoningTokens = result.usage?.cache_creation_input_tokens ?? 0;

  return {
    text,
    inputTokens,
    outputTokens,
    reasoningTokens,
    latencyMs,
    costUsd: estimateCostUsd(model, inputTokens, outputTokens),
    raw: result,
  };
}

async function callOpenAI(
  model: BenchmarkModel,
  options: LlmCallOptions
): Promise<LlmCallResult> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) throw new Error('OPENAI_API_KEY not configured');

  // We use the Responses API rather than Chat Completions because reasoning
  // models (gpt-5.5, gpt-5.5-pro) are first-class there and reasoning effort
  // is passed via the `reasoning` field. `instructions` plays the role of a
  // system prompt for this endpoint.
  const body: Record<string, unknown> = {
    model: model.apiModel,
    instructions: options.systemPrompt,
    input: options.userPrompt,
    max_output_tokens: options.maxOutputTokens ?? model.maxOutputTokens,
  };

  if (model.thinkingMode === 'reasoning_xhigh') {
    body.reasoning = { effort: 'xhigh' };
  } else if (model.thinkingMode === 'reasoning_high') {
    body.reasoning = { effort: 'high' };
  }
  // gpt-5.5-pro always reasons; no effort field needed.

  if (options.responseSchema) {
    // Force JSON output via structured outputs when a schema is provided.
    body.text = {
      format: {
        type: 'json_schema',
        name: 'response',
        schema: options.responseSchema,
        strict: true,
      },
    };
  }

  const startedAt = Date.now();
  const response = await fetch(OPENAI_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
  });
  const latencyMs = Date.now() - startedAt;

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`OpenAI ${model.apiModel} ${response.status}: ${errorBody}`);
  }

  const result = await response.json();

  // Responses API returns either a top-level `output_text` convenience field,
  // or an `output` array of message objects we have to splice. Try both.
  let text: string = result.output_text ?? '';
  if (!text && Array.isArray(result.output)) {
    for (const block of result.output) {
      if (block.type === 'message' && Array.isArray(block.content)) {
        for (const part of block.content) {
          if (part.type === 'output_text' && typeof part.text === 'string') {
            text += part.text;
          }
        }
      }
    }
  }

  const inputTokens = result.usage?.input_tokens ?? 0;
  const outputTokens = result.usage?.output_tokens ?? 0;
  const reasoningTokens = result.usage?.output_tokens_details?.reasoning_tokens ?? 0;

  return {
    text,
    inputTokens,
    outputTokens,
    reasoningTokens,
    latencyMs,
    costUsd: estimateCostUsd(model, inputTokens, outputTokens),
    raw: result,
  };
}
