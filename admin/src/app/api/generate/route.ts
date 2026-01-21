import { NextRequest, NextResponse } from 'next/server'

export const dynamic = 'force-dynamic'

const OPENAI_API_KEY = process.env.OPENAI_API_KEY || ''

const SYSTEM_PROMPT = `You are a content architect for a growth-focused "wellness library" designed for military personnel, veterans, and partner/family members.

Generate COMPLETE content items that are positive, educational, and empowering — NOT like a symptom checker. Avoid planting negative ideas. Use UK English.

DOMAIN LIST (MUST USE EXACT NAMES):
1. "Relationships & Connection"
2. "Family, Parenting & Home Life"
3. "Identity, Belonging & Inclusion"
4. "Grief, Change & Life Events"
5. "Calm, Confidence & Emotional Skills"
6. "Sleep, Energy & Recovery"
7. "Health, Injury & Physical Wellbeing"
8. "Money, Housing & Practical Life"
9. "Work, Purpose & Service Culture"
10. "Leadership, Boundaries & Communication"
11. "Transition, Resettlement & Civilian Life"

PILLARS:
- Understand (35%) - Educational, "how it works"
- Grow (35%) - Practical skills
- Reflect (20%) - Self-discovery questions  
- Support (10%) - Crisis resources

AUDIENCE:
- any (55%) - Everyone
- service_member (20%) - Currently serving
- veteran (10%) - Former military
- partner_family (15%) - Partners/family

THE REFRAME:
✅ GOOD: "Building confidence", "Finding calm", "Understanding healthy relationships"
❌ BAD: "I'm anxious", "My partner doesn't listen", "I feel like a failure"

Write as LEARNING INTENTIONS and GROWTH AREAS, not problems.

Return ONLY valid JSON with this structure:
{
  "items": [
    {
      "id": "domain-slug.pillar.short-slug",
      "domain": "Exact domain name from list",
      "pillar": "Understand|Reflect|Grow|Support",
      "label": "4-9 words, positive, growth-focused",
      "microcopy": "1-2 sentences, normalising and hopeful, max 240 chars",
      "audience": "any|service_member|veteran|partner_family",
      "disclosure_level": 1|2|3,
      "sensitivity": "normal|sensitive|urgent",
      "keywords": ["8-16 lowercase keywords"],
      
      "understand_title": "Clear educational title",
      "understand_body": "2-3 paragraphs explaining the concept. Educational and normalising. 150-300 words.",
      "understand_examples": "1-2 concrete real-world examples. Military context when appropriate. 50-100 words.",
      "understand_insights": ["Key insight 1", "Key insight 2", "Key insight 3"],
      
      "reflect_prompts": ["Gentle question 1?", "Gentle question 2?", "Gentle question 3?"],
      
      "grow_title": "Practical section title",
      "grow_steps": [
        {"action": "Specific actionable step", "detail": "How and why to do it"},
        {"action": "Another step", "detail": "Explanation"}
      ],
      "grow_obstacles": "Common challenges people face when trying these steps. Normalising and compassionate. 50-100 words.",
      
      "when_to_seek_help": "When appropriate, guidance on when professional help is needed. Only for sensitive items. Empty string if not needed.",
      
      "affirmation": "Short positive closing statement"
    }
  ]
}

IMPORTANT:
- Understand section: Always include for Understand and Grow pillars. Can be brief for Reflect and Support.
- Reflect section: Always include 2-3 prompts for Reflect pillar. Optional for others.
- Grow section: Always include for Grow pillar. 3-5 steps minimum. Optional for others.
- Examples: Make them specific and relatable. Use military scenarios when audience is service_member/veteran.
- Obstacles: Be honest about challenges but always frame hopefully.
- When to seek help: Only include for sensitive/urgent items or Support pillar. Otherwise empty string.
- All text should be compassionate, normalising, and hopeful.`

export async function POST(request: NextRequest) {
  try {
    if (!OPENAI_API_KEY) {
      return NextResponse.json(
        { error: 'OpenAI API key not configured' },
        { status: 500 }
      )
    }

    const body = await request.json()
    const {
      batchSize = 20,
      focusDomain = '',
      excludeIds = [],
      excludeLabels = [],
    } = body

    const userPrompt = `Generate exactly ${batchSize} content items${focusDomain ? ` focused on the "${focusDomain}" domain` : ' across various domains'}.

${excludeIds.length > 0 ? `Do NOT use these IDs: ${excludeIds.slice(0, 10).join(', ')}` : ''}
${excludeLabels.length > 0 ? `Do NOT use these labels: ${excludeLabels.slice(0, 10).join(', ')}` : ''}

Return ONLY the JSON object with the items array. No markdown, no explanation.`

    console.log('Calling OpenAI API...')
    
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'gpt-4-turbo-preview', // Use latest available model
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          { role: 'user', content: userPrompt },
        ],
        temperature: 0.8,
        max_tokens: 4000,
      }),
    })

    if (!response.ok) {
      const error = await response.text()
      console.error('OpenAI API error:', error)
      return NextResponse.json(
        { error: 'Failed to generate content' },
        { status: response.status }
      )
    }

    const data = await response.json()
    const content = data.choices[0].message.content

    // Try to parse JSON from the response
    let parsed
    try {
      // Remove markdown code blocks if present
      const cleaned = content.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim()
      parsed = JSON.parse(cleaned)
    } catch (e) {
      console.error('Failed to parse OpenAI response:', content)
      return NextResponse.json(
        { error: 'Failed to parse generated content', raw: content },
        { status: 500 }
      )
    }

    return NextResponse.json(parsed)
  } catch (error: any) {
    console.error('Generation failed:', error)
    return NextResponse.json(
      { error: error.message || 'Generation failed' },
      { status: 500 }
    )
  }
}

