// Thin unified LLM client for the audit benchmark.
//
// Claude is called through the Anthropic SDK (see claude.ts). OpenAI is
// called via raw fetch to its Responses API. Latency and token bookkeeping
// stay in one place.
//
// The caller specifies the model by its internal id; this module looks up
// the provider config and dispatches accordingly. The return shape is
// identical across providers so the benchmark code is provider-agnostic.

import { BenchmarkModel, MODEL_BY_ID, estimateCostUsd } from './models';
import { callClaude } from './claude';

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
  // Through the official SDK (lib/audit/claude.ts): streaming, adaptive
  // thinking with the model's effort level, structured output when a schema
  // is given, and server-side refusal fallbacks on current models.
  const result = await callClaude({
    model: model.apiModel,
    system: options.systemPrompt,
    user: options.userPrompt,
    schema: options.responseSchema as Record<string, unknown> | undefined,
    effort: model.thinkingMode === 'adaptive_xhigh' ? 'xhigh' : 'high',
    maxTokens: options.maxOutputTokens ?? model.maxOutputTokens,
  });

  return {
    text: result.text,
    inputTokens: result.inputTokens,
    outputTokens: result.outputTokens,
    // Anthropic bills thinking as output tokens and does not break it out here.
    reasoningTokens: 0,
    latencyMs: result.latencyMs,
    costUsd: estimateCostUsd(model, result.inputTokens, result.outputTokens),
    raw: { model: result.model, stop_reason: result.stopReason, cache_read_input_tokens: result.cacheReadTokens },
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
