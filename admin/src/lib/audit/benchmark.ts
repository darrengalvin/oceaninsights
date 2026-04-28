// Benchmark orchestration: turns audit findings into proposed fixes from N
// candidate models, then has every judge model score every anonymised fix on
// the same rubric. The two stages are kept as pure functions over
// AuditFinding rows + a list of model ids, so the API routes can call them
// without owning prompt-engineering details.

import { AuditFinding } from './types';
import { BenchmarkModel, MODEL_BY_ID } from './models';
import { callModel, extractJson, LlmCallResult } from './llm';
import { CATEGORY_MAP } from './criteria';

export const RUBRIC_AXES = ['resolves', 'safety', 'tone', 'conciseness', 'faithfulness'] as const;
export type RubricAxis = typeof RUBRIC_AXES[number];

const RUBRIC_DESCRIPTIONS: Record<RubricAxis, string> = {
  resolves: 'Does the fix actually resolve the cited finding?',
  safety: 'Does it preserve safety, clinical, safeguarding and OPSEC compliance?',
  tone: 'Does it match the "Below the Surface" voice — growth-focused, normalising, hopeful, UK English?',
  conciseness: 'Is it as short as it needs to be — no padding, no preamble, no needless caveats?',
  faithfulness: 'Does it avoid inventing new factual claims it cannot back up?',
};

// Sequential-letter anonymous labels: fix_a, fix_b, ... up to fix_z. Each
// benchmark run shuffles the candidate ordering so a given model never has
// the same letter twice in a row, and judges never see the model name.
export function anonymousLabels(n: number): string[] {
  const letters = 'abcdefghijklmnopqrstuvwxyz';
  if (n > letters.length) throw new Error('Too many models for anonymous labelling');
  return Array.from({ length: n }, (_, i) => `fix_${letters[i]}`);
}

export function shuffle<T>(array: T[]): T[] {
  const copy = [...array];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

// =============================================================
// FIX GENERATION
// =============================================================

const FIX_SYSTEM_PROMPT = `You are a senior content editor for "Below the Surface", a UK MOD-aligned mental health and wellbeing app for military personnel, veterans, families and young people aged 13+.

The app's voice is:
- Growth-focused, normalising, hopeful (never deficit-framed)
- Privacy-first and OPSEC-safe
- Non-clinical wellness and education only — never clinical advice
- UK English throughout

Your job is to take a single piece of content that has failed an audit criterion and propose the smallest correct rewrite that resolves the finding. Do not rewrite text that does not need to change. Preserve the original intent. Never introduce new factual claims you cannot back up. Never make safety advice less safe. Never add diagnostic or treatment language.

CRITICAL RULES — these prevent over-correction failures:

1. REGIONAL APPROPRIATENESS findings (e.g. "US content presented as universal", "missing jurisdiction label"): the fix is always to ADD A LABEL or QUALIFIER, never to substitute the underlying content. If the original says "VA & DoD Benefits", the fix is "US VA & DoD Benefits" — NOT "MOD & Veterans UK Benefits". Do not invent UK equivalents for US-specific facts. Do not strip the original concept.

2. EMERGENCY NUMBER / CRISIS RESOURCE findings: when a US-only support number is shown without a UK equivalent in a UK app, ADD a UK option alongside it (e.g. Samaritans 116 123 for general support). Do not remove the original — extend it. The user may need either depending on context.

3. FACTUAL ACCURACY findings (claims about events, dates, statistics, policy): reframe the certainty rather than removing the claim. Use "reports indicate", "may", "could", "is reported to" — keep the topic, soften the certainty. Do not delete the claim entirely if the topic itself is relevant; just stop presenting an uncertain or future event as established history.

4. LENGTH: stay within +/- 30% of the original character count. A finding asking for a label addition should not balloon into a paragraph.

5. SAFETY-CRITICAL categories (Safety, Clinical Boundaries, Safeguarding, OPSEC): when in doubt, the fix should ADD scaffolding (signposting to professional help, "if you're in immediate danger call 999", consent reminders) rather than remove text. Never reduce safety information.

Return strict JSON only — no commentary, no markdown.`;

export interface FixProposal {
  proposed_text: string;
  rationale: string;
  source_field: string;
  changed: boolean;
}

function describeFinding(finding: AuditFinding): string {
  const cat = CATEGORY_MAP[finding.category_id];
  const catLabel = cat?.label || finding.category_id;
  const subLabel = cat?.sub_criteria.find(s => s.id === finding.sub_criterion)?.label || finding.sub_criterion;
  return [
    `Content area: ${finding.content_area}`,
    `Item label: ${finding.item_label || '(unknown)'}`,
    `Audit category: ${catLabel}`,
    `Sub-criterion: ${subLabel}`,
    `Score: ${Math.round(finding.score)}/100`,
    `Finding: ${finding.description}`,
    finding.evidence ? `Offending text (verbatim): "${finding.evidence}"` : '',
    finding.suggested_action ? `Auditor's suggested action: ${finding.suggested_action}` : '',
  ].filter(Boolean).join('\n');
}

function buildFixUserPrompt(finding: AuditFinding): string {
  return `# Audit finding to fix

${describeFinding(finding)}

# Task

Propose a corrected version of the offending text. The fix must:
1. Resolve the specific sub-criterion that failed.
2. Be minimal — change only what needs to change.
3. Stay in the same length range as the original (within +/- 30%).
4. Use UK English.
5. Preserve any specific facts that are correct (do not strip safe information).

# Required JSON output

{
  "proposed_text": "the rewritten text, ready to drop into the source field",
  "rationale": "1-3 sentences explaining what you changed and why it resolves the finding",
  "source_field": "best guess at which field this text belongs to (e.g. 'description', 'body', 'microcopy')",
  "changed": true
}

If you genuinely believe the original text already meets the criterion and no change is needed, return:
{
  "proposed_text": "<the original text unchanged>",
  "rationale": "Explain why you believe no change is required.",
  "source_field": "<best guess>",
  "changed": false
}

Return ONLY valid JSON — no other text.`;
}

const FIX_RESPONSE_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['proposed_text', 'rationale', 'source_field', 'changed'],
  properties: {
    proposed_text: { type: 'string' },
    rationale: { type: 'string' },
    source_field: { type: 'string' },
    changed: { type: 'boolean' },
  },
};

export async function proposeFix(
  modelId: string,
  finding: AuditFinding
): Promise<{ proposal: FixProposal; call: LlmCallResult }> {
  const call = await callModel(modelId, {
    systemPrompt: FIX_SYSTEM_PROMPT,
    userPrompt: buildFixUserPrompt(finding),
    responseSchema: FIX_RESPONSE_SCHEMA,
    maxOutputTokens: 4000,
  });

  const proposal = extractJson<FixProposal>(call.text);
  return { proposal, call };
}

// =============================================================
// JUDGING
// =============================================================

const JUDGE_SYSTEM_PROMPT = `You are an expert content reviewer judging a blind bake-off of proposed rewrites.

You will be given:
- An audit finding (what's wrong with the original content)
- The original offending text
- A set of anonymised proposed fixes labelled "fix_a", "fix_b", etc. — you do NOT know which model wrote which.

Score every fix on five axes from 0 to 100:
- resolves: does it actually fix the cited finding?
- safety: does it preserve safety, clinical, safeguarding and OPSEC compliance?
- tone: does it match the "Below the Surface" voice — growth-focused, normalising, UK English?
- conciseness: is it as short as it needs to be?
- faithfulness: does it avoid inventing new claims it cannot back up?

Be calibrated. A fix that fully resolves the finding without trade-offs deserves 90+. Reserve scores below 50 for genuine problems. Do not anchor all scores at the same value — differentiate.

Then rank the fixes from best (rank 1) to worst, and write a one-paragraph justification per fix explaining the score.

Return strict JSON only — no commentary outside the JSON.`;

export interface JudgeFixScore {
  fix_label: string;
  score_resolves: number;
  score_safety: number;
  score_tone: number;
  score_conciseness: number;
  score_faithfulness: number;
  overall: number;
  ranking: number;
  justification: string;
}

export interface JudgeResponse {
  judgments: JudgeFixScore[];
  panel_note: string;
}

function buildJudgeUserPrompt(
  finding: AuditFinding,
  anonymisedFixes: { label: string; proposed_text: string; rationale: string }[]
): string {
  const fixBlocks = anonymisedFixes
    .map(f => `### ${f.label}\nProposed text:\n"""\n${f.proposed_text}\n"""\nAuthor's rationale: ${f.rationale}`)
    .join('\n\n');

  return `# Audit finding

${describeFinding(finding)}

# Proposed fixes (anonymised)

${fixBlocks}

# Task

Score every fix above on the five-axis rubric. Use the full 0-100 range — do NOT give every fix the same score. The "overall" field should be a weighted average reflecting your overall judgement (you choose the weights).

Then rank them: 1 = best, 2 = next best, etc. Ties are not allowed.

Finally, in panel_note, write 1-2 sentences calling out the most interesting differences between the fixes.

# Required JSON output

{
  "judgments": [
    {
      "fix_label": "fix_a",
      "score_resolves": 92,
      "score_safety": 95,
      "score_tone": 88,
      "score_conciseness": 80,
      "score_faithfulness": 95,
      "overall": 90,
      "ranking": 1,
      "justification": "1-3 sentences explaining the score."
    }
  ],
  "panel_note": "1-2 sentences."
}

You MUST score every fix in the input — same number of judgments as fixes. Return ONLY valid JSON.`;
}

const JUDGE_RESPONSE_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['judgments', 'panel_note'],
  properties: {
    judgments: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: [
          'fix_label', 'score_resolves', 'score_safety', 'score_tone',
          'score_conciseness', 'score_faithfulness', 'overall', 'ranking', 'justification',
        ],
        properties: {
          fix_label: { type: 'string' },
          score_resolves: { type: 'number' },
          score_safety: { type: 'number' },
          score_tone: { type: 'number' },
          score_conciseness: { type: 'number' },
          score_faithfulness: { type: 'number' },
          overall: { type: 'number' },
          ranking: { type: 'integer' },
          justification: { type: 'string' },
        },
      },
    },
    panel_note: { type: 'string' },
  },
};

export async function judgeFixes(
  judgeModelId: string,
  finding: AuditFinding,
  anonymisedFixes: { label: string; proposed_text: string; rationale: string }[]
): Promise<{ response: JudgeResponse; call: LlmCallResult }> {
  // Shuffle the order shown to the judge so position bias is averaged out.
  const shuffled = shuffle(anonymisedFixes);
  const call = await callModel(judgeModelId, {
    systemPrompt: JUDGE_SYSTEM_PROMPT,
    userPrompt: buildJudgeUserPrompt(finding, shuffled),
    responseSchema: JUDGE_RESPONSE_SCHEMA,
    maxOutputTokens: 4000,
  });

  const response = extractJson<JudgeResponse>(call.text);
  return { response, call };
}

// =============================================================
// HELPERS for the API layer
// =============================================================

export function modelsFromIds(ids: string[]): BenchmarkModel[] {
  const out: BenchmarkModel[] = [];
  for (const id of ids) {
    const m = MODEL_BY_ID[id];
    if (m) out.push(m);
  }
  return out;
}

export { RUBRIC_DESCRIPTIONS };
