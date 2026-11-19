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
  /** Older model kept only so historical runs resolve; hidden from new runs. */
  legacy?: boolean;
}

export const BENCHMARK_MODELS: BenchmarkModel[] = [
  {
    id: 'claude-opus-5-5-xhigh',
    label: 'Claude Opus 5.5 (xhigh effort)',
    provider: 'anthropic',
    apiModel: 'claude-opus-5-5',
    thinkingMode: 'adaptive_xhigh',
    description: 'Anthropic\'s current Opus model and the audit\'s reviewer. Adaptive thinking at xhigh effort.',
    inputCostPerMtok: 4,
    outputCostPerMtok: 20,
    maxOutputTokens: 32000,
  },
  {
    id: 'claude-sonnet-5-5-high',
    label: 'Claude Sonnet 5.5 (high effort)',
    provider: 'anthropic',
    apiModel: 'claude-sonnet-5-5',
    thinkingMode: 'adaptive_high',
    description: 'Anthropic\'s current Sonnet model. Faster and cheaper baseline against the flagships.',
    inputCostPerMtok: 2,
    outputCostPerMtok: 10,
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
  // Previous generation, kept so earlier benchmark runs still resolve their
  // model ids and costs. Not offered for new runs.
  {
    id: 'claude-opus-4-7-xhigh',
    label: 'Claude Opus 4.7 (xhigh thinking)',
    provider: 'anthropic',
    apiModel: 'claude-opus-4-7',
    thinkingMode: 'adaptive_xhigh',
    description: 'Previous Opus generation (used for runs before November 2026).',
    inputCostPerMtok: 5,
    outputCostPerMtok: 25,
    maxOutputTokens: 32000,
    legacy: true,
  },
  {
    id: 'claude-sonnet-4-6-adaptive',
    label: 'Claude Sonnet 4.6 (adaptive thinking)',
    provider: 'anthropic',
    apiModel: 'claude-sonnet-4-6',
    thinkingMode: 'adaptive_high',
    description: 'Previous Sonnet generation (used for runs before November 2026).',
    inputCostPerMtok: 3,
    outputCostPerMtok: 15,
    maxOutputTokens: 32000,
    legacy: true,
  },
];

/** Models offered for new benchmark and Auto-Fix runs. */
export const CURRENT_BENCHMARK_MODELS = BENCHMARK_MODELS.filter(m => !m.legacy);

/** Default model for Auto-Fix. */
export const DEFAULT_FIX_MODEL_ID = 'claude-opus-5-5-xhigh';

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
