// Registry of LLM models available for the audit fix benchmark.
//
// Each entry maps a stable internal id (used in DB rows + UI) to the
// provider-specific configuration needed to call it. Pricing is per 1M tokens
// and is used to estimate the cost of a benchmark run after the fact.

export type Provider = 'anthropic' | 'openai';

export interface BenchmarkModel {
  id: string;
  label: string;
  provider: Provider;
  apiModel: string;
  thinkingMode: 'adaptive_xhigh' | 'adaptive_high' | 'reasoning_xhigh' | 'reasoning_high' | 'pro_default' | 'off';
  description: string;
  inputCostPerMtok: number;
  outputCostPerMtok: number;
  maxOutputTokens: number;
}

export const BENCHMARK_MODELS: BenchmarkModel[] = [
  {
    id: 'claude-opus-4-7-xhigh',
    label: 'Claude Opus 4.7 (xhigh thinking)',
    provider: 'anthropic',
    apiModel: 'claude-opus-4-7',
    thinkingMode: 'adaptive_xhigh',
    description: 'Anthropic\'s flagship — adaptive thinking with maximum effort. Best agentic reasoning available.',
    inputCostPerMtok: 15,
    outputCostPerMtok: 75,
    maxOutputTokens: 32000,
  },
  {
    id: 'gpt-5-5-pro',
    label: 'GPT-5.5 Pro',
    provider: 'openai',
    apiModel: 'gpt-5.5-pro',
    thinkingMode: 'pro_default',
    description: 'OpenAI\'s highest-accuracy reasoning model. Slowest, most expensive, top quality.',
    inputCostPerMtok: 30,
    outputCostPerMtok: 180,
    maxOutputTokens: 32000,
  },
  {
    id: 'gpt-5-5-xhigh',
    label: 'GPT-5.5 (xhigh reasoning)',
    provider: 'openai',
    apiModel: 'gpt-5.5',
    thinkingMode: 'reasoning_xhigh',
    description: 'GPT-5.5 with reasoning effort dialled to maximum.',
    inputCostPerMtok: 5,
    outputCostPerMtok: 30,
    maxOutputTokens: 32000,
  },
  {
    id: 'claude-sonnet-4-6-adaptive',
    label: 'Claude Sonnet 4.6 (adaptive thinking)',
    provider: 'anthropic',
    apiModel: 'claude-sonnet-4-6',
    thinkingMode: 'adaptive_high',
    description: 'Fast smart tier — useful baseline against the flagships.',
    inputCostPerMtok: 3,
    outputCostPerMtok: 15,
    maxOutputTokens: 32000,
  },
];

export const MODEL_BY_ID = Object.fromEntries(
  BENCHMARK_MODELS.map(m => [m.id, m])
) as Record<string, BenchmarkModel>;

export function estimateCostUsd(
  model: BenchmarkModel,
  inputTokens: number,
  outputTokens: number
): number {
  const inputCost = (inputTokens / 1_000_000) * model.inputCostPerMtok;
  const outputCost = (outputTokens / 1_000_000) * model.outputCostPerMtok;
  return Math.round((inputCost + outputCost) * 10000) / 10000;
}
