// Shared Claude client for the content audit.
//
// One place for the model choice and request shape, so the reviewer, Auto-Fix
// and the benchmark stay on the same, current model.

import Anthropic from '@anthropic-ai/sdk';

/** The model that scores content. */
export const AUDIT_MODEL = 'claude-opus-5-5';
/** Human-readable name, used in reports. */
export const AUDIT_MODEL_LABEL = 'Claude Opus 5.5';

export type Effort = 'low' | 'medium' | 'high' | 'xhigh' | 'max';

export interface ClaudeJsonRequest {
  model?: string;
  system: string;
  user: string;
  schema?: Record<string, unknown>;
  effort?: Effort;
  maxTokens?: number;
  apiKey?: string;
}

export interface ClaudeJsonResult {
  text: string;
  model: string;
  stopReason: string | null;
  inputTokens: number;
  outputTokens: number;
  cacheReadTokens: number;
  latencyMs: number;
}

let cachedClient: Anthropic | null = null;
function client(apiKey?: string): Anthropic {
  if (apiKey) return new Anthropic({ apiKey });
  cachedClient ??= new Anthropic();
  return cachedClient;
}

/**
 * Call Claude and return its text, streaming so long reviews do not hit
 * HTTP timeouts. With a schema, the response is constrained to that JSON
 * schema (structured outputs), so it always parses.
 *
 * Server-side fallbacks are on: if a safety classifier declines the request
 * (possible with suicide or self-harm content), the API retries it on a
 * fallback model in the same call instead of failing the area.
 */
export async function callClaude(req: ClaudeJsonRequest): Promise<ClaudeJsonResult> {
  const started = Date.now();
  const model = req.model ?? AUDIT_MODEL;
  // Server-side fallbacks are available on the current model generation only.
  const fallback = /^claude-(opus-5|sonnet-5-5|fable-5)/.test(model)
    ? { betas: ['server-side-fallback-2026-07-01'], fallbacks: 'default' as const }
    : {};
  const stream = client(req.apiKey).beta.messages.stream({
    model,
    max_tokens: req.maxTokens ?? 64000,
    ...fallback,
    thinking: { type: 'adaptive' },
    output_config: {
      effort: req.effort ?? 'high',
      ...(req.schema ? { format: { type: 'json_schema' as const, schema: req.schema } } : {}),
    },
    // The system prompt (instructions + rubric) is identical for every call,
    // so it is cached and only the content is billed at the full rate.
    system: [{ type: 'text', text: req.system, cache_control: { type: 'ephemeral' } }],
    messages: [{ role: 'user', content: req.user }],
  });
  const message = await stream.finalMessage();

  if (message.stop_reason === 'refusal') {
    throw new Error(`Claude declined to review this content (${message.stop_details?.category ?? 'no category'}).`);
  }
  if (message.stop_reason === 'max_tokens') {
    throw new Error('Claude ran out of output space before finishing; split the area into smaller batches.');
  }

  const text = message.content
    .filter((b): b is Extract<typeof b, { type: 'text' }> => b.type === 'text')
    .map(b => b.text)
    .join('');

  return {
    text,
    model: message.model,
    stopReason: message.stop_reason,
    inputTokens: message.usage.input_tokens,
    outputTokens: message.usage.output_tokens,
    cacheReadTokens: message.usage.cache_read_input_tokens ?? 0,
    latencyMs: Date.now() - started,
  };
}
