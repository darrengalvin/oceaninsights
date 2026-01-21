import { NextRequest, NextResponse } from 'next/server'

export const dynamic = 'force-dynamic'

const OPENAI_API_KEY = process.env.OPENAI_API_KEY || ''

const PROTOCOL_PROMPT = `You are GPT-5.2. Generate step-by-step communication protocols for military personnel, veterans, and their families.

## GOAL
Create clear, actionable protocols for:
- Difficult conversations
- Conflict de-escalation
- Boundary setting
- Giving/receiving feedback
- High-stakes communication

## OUTPUT FORMAT (STRICT JSON)
Return ONLY valid JSON (no markdown, no commentary):

{
  "protocols": [
    {
      "title": "Protocol Name",
      "category": "conflict | feedback | boundary | clarification | difficult_conversation",
      "description": "Brief description of when to use this",
      "when_to_use": "Use this when you need to...",
      "when_not_to_use": "Don't use this if...",
      "common_failures": ["Common mistake 1", "Common mistake 2"],
      "steps": [
        {
          "step_number": 1,
          "title": "Step Name",
          "instruction": "What to do",
          "example": "Example of what to say",
          "why_it_works": "Explanation of the psychology/benefit"
        }
      ]
    }
  ]
}

## PROTOCOL CATEGORIES
- **conflict**: De-escalation, resolution, mediation
- **feedback**: Giving/receiving criticism, praise, performance reviews
- **boundary**: Setting limits, saying no, protecting time/energy
- **clarification**: Asking questions, confirming understanding
- **difficult_conversation**: Sensitive topics, bad news, confrontation

## EXAMPLE PROTOCOL

{
  "protocols": [
    {
      "title": "The Clarification Protocol",
      "category": "clarification",
      "description": "A three-step approach to ensure you fully understand before responding",
      "when_to_use": "Use this when instructions are unclear, emotions are high, or stakes are significant",
      "when_not_to_use": "Don't use this in emergencies requiring immediate action, or when clarification would be seen as stalling",
      "common_failures": [
        "Assuming you understand and moving forward too quickly",
        "Asking for clarification in a way that sounds accusatory",
        "Over-clarifying obvious points and appearing difficult"
      ],
      "steps": [
        {
          "step_number": 1,
          "title": "Acknowledge What You Heard",
          "instruction": "Restate what you think you heard in your own words",
          "example": "Just to make sure I've got this right, you're saying that...",
          "why_it_works": "Shows you're listening and gives them a chance to correct misunderstandings early"
        },
        {
          "step_number": 2,
          "title": "Ask a Specific Question",
          "instruction": "Pinpoint exactly what you need clarified",
          "example": "Can you help me understand what you mean by 'as soon as possible'—are we talking hours or days?",
          "why_it_works": "Specific questions get specific answers; vague questions get vague answers"
        },
        {
          "step_number": 3,
          "title": "Confirm the Path Forward",
          "instruction": "State what you'll do next based on the clarification",
          "example": "Right, so I'll prioritise this and have it to you by end of day Thursday",
          "why_it_works": "Closes the loop and prevents future confusion about expectations"
        }
      ]
    }
  ]
}

## GUIDELINES
1. Keep steps clear and actionable (3-5 steps ideal)
2. Provide realistic examples of what to say
3. Explain WHY each step works (psychology/benefit)
4. Include common failure modes
5. Be practical, not academic
6. Use UK English
7. Generate 3-5 protocols per request

Generate protocols now.`

export async function POST(request: NextRequest) {
  try {
    const { count = 3 } = await request.json()
    const { getSupabaseAdmin } = await import('@/lib/supabase')

    if (!OPENAI_API_KEY) {
      return NextResponse.json(
        { error: 'OpenAI API key not configured' },
        { status: 500 }
      )
    }

    // Get existing protocol titles to avoid duplicates
    const supabaseAdmin = getSupabaseAdmin()
    const { data: existingProtocols } = await supabaseAdmin
      .from('protocols')
      .select('title')
    
    const existingTitles = new Set(existingProtocols?.map(p => p.title.toLowerCase()) || [])

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'gpt-4-turbo-preview',
        messages: [
          {
            role: 'system',
            content: 'You are a communication protocol designer for military and veteran support.'
          },
          {
            role: 'user',
            content: `${PROTOCOL_PROMPT}\n\nGenerate ${count} protocols.\n\nIMPORTANT: Avoid these existing titles:\n${Array.from(existingTitles).join(', ')}`
          }
        ],
        temperature: 0.8,
        max_tokens: 4000,
      }),
    })

    if (!response.ok) {
      throw new Error('OpenAI API request failed')
    }

    const data = await response.json()
    const content = data.choices[0].message.content

    // Parse JSON from response
    const jsonMatch = content.match(/\{[\s\S]*\}/)
    if (!jsonMatch) {
      throw new Error('No valid JSON found in response')
    }

    const result = JSON.parse(jsonMatch[0])

    // Filter out any duplicates that might still have been generated
    const newProtocols = result.protocols?.filter((p: any) => 
      !existingTitles.has(p.title.toLowerCase())
    ) || []

    // Insert protocols into database
    if (newProtocols.length > 0) {
      const { error } = await supabaseAdmin
        .from('protocols')
        .insert(newProtocols.map((p: any) => ({
          ...p,
          published: false, // Always save as draft
          created_at: new Date().toISOString()
        })))

      if (error) throw error
    }

    return NextResponse.json({ 
      protocols: newProtocols,
      duplicatesSkipped: (result.protocols?.length || 0) - newProtocols.length
    })
  } catch (error) {
    console.error('Failed to generate protocols:', error)
    return NextResponse.json(
      { error: 'Failed to generate protocols' },
      { status: 500 }
    )
  }
}

