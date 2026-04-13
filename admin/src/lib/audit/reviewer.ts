import { buildCriteriaPromptText } from './criteria';
import { ClaudeAuditResponse, ExtractedContentArea } from './types';
import { serializeContentAreaForReview } from './extractor';

const ANTHROPIC_API_URL = 'https://api.anthropic.com/v1/messages';

const SYSTEM_PROMPT = `You are a MOD (Ministry of Defence) content compliance auditor. You are reviewing content from "Below the Surface", a mental health and wellbeing app designed for UK military personnel, veterans, their families, and young people aged 13+.

The app positions itself as:
- Privacy-first: no accounts, no personal data, no GPS, no camera/mic
- Non-clinical: wellness and educational tool, NOT a medical service
- OPSEC-safe: designed for use in classified and sensitive environments
- Offline-capable: works without internet after initial sync
- Growth-focused: content should be empowering, not deficit-framed

Your job is to score every content item against each applicable audit criterion. Use your extended thinking to carefully reason through each assessment before assigning scores.

SCORING SCALE (0-100):
- 100: Fully meets the criterion
- 75: Minor issue, low risk, should be improved
- 50: Significant issue, needs attention
- 25: Serious issue, must fix
- 0: Critical failure, safety/legal/reputational risk

Use any value 0-100, not just these anchors. Be calibrated: most good content should score 80-100. Reserve scores below 50 for genuine problems.

For each content item, score every applicable criterion. Mark criteria as not applicable (applicable: false) when the criterion genuinely does not apply to that type of content.

IMPORTANT: When you identify factual claims (statistics, medical claims, legal references, research citations, historical dates), log them as citations so they can be tracked in the citation registry.

Return your response as valid JSON matching the specified schema. Do not include any text outside the JSON.`;

export function buildReviewPrompt(area: ExtractedContentArea): string {
  const criteriaText = buildCriteriaPromptText();
  const contentText = serializeContentAreaForReview(area);

  return `Review the following content area and score each item against all applicable criteria.

## GRADING CRITERIA

${criteriaText}

## CONTENT TO REVIEW

${contentText}

## REQUIRED OUTPUT FORMAT

Return a JSON object with this exact structure:
{
  "content_area": "${area.id}",
  "items": [
    {
      "item_id": "the item's ID",
      "item_label": "the item's label",
      "source_table": "the source table name",
      "overall_score": 85,
      "category_scores": [
        {
          "category_id": "factual_accuracy",
          "applicable": true,
          "score": 90,
          "reasoning": "Brief explanation of the score",
          "sub_scores": [
            {
              "sub_criterion": "statistical_claims",
              "score": 85,
              "evidence": "The specific text being assessed",
              "finding": "Description of any issue, or null if score >= 90",
              "suggested_action": "What to do to fix it, or null"
            }
          ],
          "citations": [
            {
              "claim_text": "The exact factual claim text",
              "claim_type": "medical|legal|statistical|research|historical",
              "needs_verification": true,
              "suggested_source": "Where to verify this, or null"
            }
          ]
        }
      ]
    }
  ],
  "area_level_notes": [
    {
      "category_id": "distribution_balance",
      "observation": "Area-wide observation",
      "score": 80
    }
  ]
}

Score EVERY item. Return ONLY valid JSON, no other text.`;
}

export async function reviewContentArea(
  area: ExtractedContentArea,
  apiKey: string
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

  const userPrompt = buildReviewPrompt(area);

  const response = await fetch(ANTHROPIC_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 16000,
      thinking: {
        type: 'enabled',
        budget_tokens: 10000,
      },
      messages: [
        { role: 'user', content: userPrompt },
      ],
      system: SYSTEM_PROMPT,
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Claude API error ${response.status}: ${errorBody}`);
  }

  const result = await response.json();

  const textBlock = result.content?.find((b: { type: string }) => b.type === 'text');
  if (!textBlock?.text) {
    throw new Error('No text response from Claude');
  }

  let parsed: ClaudeAuditResponse;
  try {
    const jsonText = textBlock.text.trim();
    const jsonMatch = jsonText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error('No JSON found in response');
    parsed = JSON.parse(jsonMatch[0]);
  } catch (parseErr) {
    throw new Error(`Failed to parse Claude response as JSON: ${parseErr}`);
  }

  return parsed;
}
