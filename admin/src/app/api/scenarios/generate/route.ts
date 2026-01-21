import { NextRequest, NextResponse } from 'next/server'

export const dynamic = 'force-dynamic'

const SCENARIO_PROMPT = `You are GPT-5.2. Generate realistic workplace decision-training scenarios for military personnel, veterans, and their families.

## GOAL
Create scenarios that:
- Present realistic workplace/military communication challenges
- Offer 3-4 response options with different approaches
- Provide immediate feedback and long-term outcomes
- Show perspective shifts (how others might perceive actions)
- Are OPSEC-safe (no sensitive mission details)

## OUTPUT FORMAT (STRICT JSON)
Return ONLY valid JSON (no markdown, no commentary):

{
  "scenarios": [
    {
      "title": "Scenario Title",
      "situation": "Describe the situation in 2-3 sentences",
      "context": "military_workplace | civilian_workplace | family | social",
      "difficulty": 2,
      "tags": ["communication", "conflict", "leadership"],
      "options": [
        {
          "text": "What you might say or do",
          "tags": ["direct", "assertive"],
          "immediate_outcome": "What happens immediately",
          "longterm_outcome": "What happens over time",
          "risk_level": "low | medium | high",
          "perspective_shifts": [
            {
              "perspective": "Your supervisor",
              "interpretation": "How they might see it"
            }
          ]
        }
      ]
    }
  ]
}

## SCENARIO CONTEXTS
- **military_workplace**: On base, during operations, briefings, chain of command
- **civilian_workplace**: Post-service employment, civilian team dynamics
- **family**: Home life, partner communication, parenting
- **social**: Community events, veteran groups, public interactions

## RISK LEVELS
- **low**: Safe, constructive, builds relationships
- **medium**: Some risk, depends on execution
- **high**: Potential for damage, escalation, or regret

## TAGS FOR OPTIONS
- **direct, indirect, delay, escalate, de-escalate**
- **assertive, passive, aggressive, passive-aggressive**
- **clarify, avoid, confront, compromise**

## EXAMPLE SCENARIO

{
  "scenarios": [
    {
      "title": "Dismissed Concern During Briefing",
      "situation": "You've raised a safety concern during a team briefing, but your superior dismissed it quickly without discussion. The meeting continues, but you're certain the issue needs addressing.",
      "context": "military_workplace",
      "difficulty": 2,
      "tags": ["hierarchy", "safety", "communication"],
      "options": [
        {
          "text": "Raise it again immediately, more firmly",
          "tags": ["direct", "assertive", "escalate"],
          "immediate_outcome": "Your superior pauses, visibly annoyed, but allows you to elaborate briefly",
          "longterm_outcome": "Issue gets flagged, but you're seen as challenging authority in public settings",
          "risk_level": "medium",
          "perspective_shifts": [
            {
              "perspective": "Your superior",
              "interpretation": "Feels undermined in front of the team, may perceive you as insubordinate"
            },
            {
              "perspective": "Your peers",
              "interpretation": "Respect your courage but worry about the fallout"
            }
          ]
        },
        {
          "text": "Let it go and bring it up privately after",
          "tags": ["delay", "indirect", "de-escalate"],
          "immediate_outcome": "Meeting proceeds smoothly, no immediate conflict",
          "longterm_outcome": "You have a constructive 1-on-1 discussion, issue gets resolved without tension",
          "risk_level": "low",
          "perspective_shifts": [
            {
              "perspective": "Your superior",
              "interpretation": "Appreciates you respecting the chain of command and choosing the right time"
            }
          ]
        },
        {
          "text": "Send an email to the next level up",
          "tags": ["escalate", "direct"],
          "immediate_outcome": "Email is read, but you've bypassed your immediate superior",
          "longterm_outcome": "Safety issue addressed, but relationship with superior is damaged",
          "risk_level": "high",
          "perspective_shifts": [
            {
              "perspective": "Your superior",
              "interpretation": "Feels betrayed, sees you as someone who doesn't respect hierarchy"
            }
          ]
        }
      ]
    }
  ]
}

## GUIDELINES
1. Keep situations realistic and relatable
2. Make all options plausible (no obviously wrong answers)
3. Show trade-offs in every choice
4. Avoid stereotypes about military culture
5. Use UK English
6. NO classified or sensitive content
7. Generate 3-5 scenarios per request

Generate scenarios now.`

export async function POST(request: NextRequest) {
  try {
    const { count = 3 } = await request.json()
    const { getSupabaseAdmin } = await import('@/lib/supabase')
    
    const OPENAI_API_KEY = process.env.OPENAI_API_KEY

    if (!OPENAI_API_KEY) {
      return NextResponse.json(
        { error: 'OpenAI API key not configured' },
        { status: 500 }
      )
    }

    // Get existing scenario titles to avoid duplicates
    const supabaseAdmin = getSupabaseAdmin()
    const { data: existingScenarios } = await supabaseAdmin
      .from('scenarios')
      .select('title')
    
    const existingTitles = new Set(existingScenarios?.map(s => s.title.toLowerCase()) || [])

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
            content: 'You are a scenario designer for military communication training.'
          },
          {
            role: 'user',
            content: `${SCENARIO_PROMPT}\n\nGenerate ${count} scenarios.\n\nIMPORTANT: Avoid these existing titles:\n${Array.from(existingTitles).join(', ')}`
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
    const newScenarios = result.scenarios?.filter((s: any) => 
      !existingTitles.has(s.title.toLowerCase())
    ) || []

    // Insert scenarios and their options into database
    if (newScenarios.length > 0) {
      for (const scenario of newScenarios) {
        const { options, ...scenarioData } = scenario
        
        // Insert scenario
        const { data: insertedScenario, error: scenarioError } = await supabaseAdmin
          .from('scenarios')
          .insert({
            ...scenarioData,
            published: false, // Always save as draft
            created_at: new Date().toISOString()
          })
          .select()
          .single()

        if (scenarioError) throw scenarioError

        // Insert options
        if (options && options.length > 0 && insertedScenario) {
          const optionsToInsert = options.map((opt: any) => ({
            ...opt,
            scenario_id: insertedScenario.id
          }))

          const { error: optionsError } = await supabaseAdmin
            .from('scenario_options')
            .insert(optionsToInsert)

          if (optionsError) throw optionsError
        }
      }
    }

    return NextResponse.json({ 
      scenarios: newScenarios,
      duplicatesSkipped: (result.scenarios?.length || 0) - newScenarios.length
    })
  } catch (error) {
    console.error('Failed to generate scenarios:', error)
    return NextResponse.json(
      { error: 'Failed to generate scenarios' },
      { status: 500 }
    )
  }
}

