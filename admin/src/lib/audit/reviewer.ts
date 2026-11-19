import { buildCriteriaPromptText, AI_CATEGORIES } from './criteria';
import { ClaudeAuditResponse, ExtractedContentArea } from './types';
import { serializeContentAreaForReview } from './extractor';
import { callClaude, AUDIT_MODEL } from './claude';
import { TRUSTED_SOURCES } from './evidence/registry.mjs';

const TRUSTED_LIST = [1, 2, 3]
  .map(tier => {
    const names = TRUSTED_SOURCES.filter(s => s.tier === tier).map(s => `${s.name} (${s.domain})`).join('; ');
    const heading = tier === 1 ? 'Tier 1, named by the client' : tier === 2 ? 'Tier 2, official UK government and NHS bodies' : 'Tier 3, UK charities the NHS signposts to (acceptable for signposting; for health claims prefer Tier 1)';
    return `- ${heading}: ${names}`;
  })
  .join('\n');

const SYSTEM_PROMPT = `You are a content compliance auditor reviewing "Below the Surface", a mental health and wellbeing app for UK military personnel, veterans, their families, and young people aged 13+.

The app positions itself as:
- Privacy-first: no accounts, no personal data, no GPS, no camera or microphone
- Non-clinical: a wellness and educational tool, not a medical service
- OPSEC-safe: designed for use in sensitive environments
- Offline-capable: works without internet after the initial sync
- Growth-focused: content should be empowering, not deficit-framed

Client rules that apply to every item:
1. All health and wellbeing information must reflect the NHS or trusted sources. Score each claim against what the relevant trusted page actually says, not against general knowledge. Popular psychology, self-help books and "research shows" without a source do not count as trusted sources.
2. The audience is in the UK. Content describing another country's systems (for example the US VA, GI Bill, TSP, 911 or 988) as if it applied to UK users is a failure, not a labelling issue.
3. Do not name the Royal Navy or imply its endorsement. Flag any mention.

Trusted sources:
${TRUSTED_LIST}

Separate, deterministic checks already cover phone numbers against a verified helpline register, links, and known wording rules. You do not need to re-check phone numbers digit by digit; concentrate on whether the content is accurate, safe, within scope and traceable to a trusted source.

SCORING SCALE (0-100):
- 100: fully meets the criterion
- 75: minor issue, low risk, should be improved
- 50: significant issue, needs attention
- 25: serious issue, must fix
- 0: critical failure: safety, legal or reputational risk

Use any value 0-100. Be calibrated: most good content should score 80-100; reserve scores below 50 for genuine problems. Mark a category not applicable only when it genuinely does not apply.

For each item and applicable category, give the category score and a one-sentence reason. List in sub_scores ONLY the sub-criteria that score below 90, each with the exact text assessed as evidence (quote it, including any [L123] line marker), the issue, and what to change. Sub-criteria scoring 90 or above are omitted.

For every factual claim (statistics, medical claims, legal references, research, dates, named services), add a citation: the claim, its type, the trusted page you checked it against (name and URL, or null if none covers it), and whether the content matches, differs from, or is not covered by that source.

GRADING CRITERIA

${buildCriteriaPromptText()}`;

const AI_CATEGORY_IDS = AI_CATEGORIES.map(c => c.id);
const nullableString = { anyOf: [{ type: 'string' }, { type: 'null' }] };

/** JSON schema the reviewer's response must follow (structured outputs). */
export const REVIEW_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['content_area', 'items', 'area_level_notes'],
  properties: {
    content_area: { type: 'string' },
    items: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['item_id', 'item_label', 'source_table', 'category_scores'],
        properties: {
          item_id: { type: 'string' },
          item_label: { type: 'string' },
          source_table: { type: 'string' },
          category_scores: {
            type: 'array',
            items: {
              type: 'object',
              additionalProperties: false,
              required: ['category_id', 'applicable', 'score', 'reasoning', 'sub_scores', 'citations'],
              properties: {
                category_id: { type: 'string', enum: AI_CATEGORY_IDS },
                applicable: { type: 'boolean' },
                score: { type: 'number' },
                reasoning: { type: 'string' },
                sub_scores: {
                  type: 'array',
                  items: {
                    type: 'object',
                    additionalProperties: false,
                    required: ['sub_criterion', 'score', 'evidence', 'finding', 'suggested_action'],
                    properties: {
                      sub_criterion: { type: 'string' },
                      score: { type: 'number' },
                      evidence: { type: 'string' },
                      finding: nullableString,
                      suggested_action: nullableString,
                    },
                  },
                },
                citations: {
                  type: 'array',
                  items: {
                    type: 'object',
                    additionalProperties: false,
                    required: ['claim_text', 'claim_type', 'needs_verification', 'suggested_source', 'trusted_source_name', 'alignment'],
                    properties: {
                      claim_text: { type: 'string' },
                      claim_type: { type: 'string', enum: ['medical', 'legal', 'statistical', 'research', 'historical'] },
                      needs_verification: { type: 'boolean' },
                      suggested_source: nullableString,
                      trusted_source_name: nullableString,
                      alignment: { type: 'string', enum: ['matches', 'differs', 'not_covered', 'no_trusted_source'] },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    area_level_notes: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['category_id', 'observation', 'score'],
        properties: {
          category_id: { type: 'string' },
          observation: { type: 'string' },
          score: { type: 'number' },
        },
      },
    },
  },
} as const;

export function buildReviewPrompt(area: ExtractedContentArea): string {
  return `Review the following content and score each item against all applicable criteria. Content area id: "${area.id}". Score every item.

${serializeContentAreaForReview(area)}`;
}

// Large areas are split into batches reviewed in parallel, so no single call
// runs long enough to hit the 300s serverless limit.
const MAX_ITEMS_PER_BATCH = 5;
const MAX_CHARS_PER_BATCH = 36000;
const MAX_PARALLEL = 4;

function batchArea(area: ExtractedContentArea): ExtractedContentArea[] {
  const batches: ExtractedContentArea[] = [];
  let current: ExtractedContentArea = { ...area, items: [] };
  let chars = 0;
  for (const item of area.items) {
    const size = JSON.stringify(item.data).length;
    if (current.items.length > 0 && (current.items.length >= MAX_ITEMS_PER_BATCH || chars + size > MAX_CHARS_PER_BATCH)) {
      batches.push(current);
      current = { ...area, items: [] };
      chars = 0;
    }
    current.items.push(item);
    chars += size;
  }
  if (current.items.length) batches.push(current);
  return batches;
}

async function reviewBatch(batch: ExtractedContentArea, apiKey?: string): Promise<ClaudeAuditResponse> {
  const result = await callClaude({
    model: AUDIT_MODEL,
    system: SYSTEM_PROMPT,
    user: buildReviewPrompt(batch),
    schema: REVIEW_SCHEMA as unknown as Record<string, unknown>,
    effort: 'high',
    maxTokens: 64000,
    apiKey,
  });
  try {
    return JSON.parse(result.text) as ClaudeAuditResponse;
  } catch (err) {
    throw new Error(`Failed to parse Claude response as JSON: ${err}`);
  }
}

export async function reviewContentArea(
  area: ExtractedContentArea,
  apiKey?: string
): Promise<ClaudeAuditResponse> {
  if (area.items.length === 0) {
    return {
      content_area: area.id,
      items: [],
      area_level_notes: [{
        category_id: 'completeness',
        observation: 'No content items found in this area. The area appears to be empty.',
        score: 0,
      }],
    };
  }

  const batches = batchArea(area);
  const responses: ClaudeAuditResponse[] = [];
  for (let i = 0; i < batches.length; i += MAX_PARALLEL) {
    responses.push(...await Promise.all(batches.slice(i, i + MAX_PARALLEL).map(b => reviewBatch(b, apiKey))));
  }

  return {
    content_area: area.id,
    items: responses.flatMap(r => r.items),
    area_level_notes: responses.flatMap(r => r.area_level_notes),
  };
}
