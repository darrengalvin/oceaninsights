import { NextRequest, NextResponse } from 'next/server'
import OpenAI from 'openai'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

export async function POST(request: NextRequest) {
  try {
    const { count = 3 } = await request.json()
    
    const apiKey = process.env.OPENAI_API_KEY
    console.log('[Journeys Generate] API Key present:', !!apiKey)
    
    if (!apiKey) {
      return NextResponse.json(
        { error: 'OpenAI API key not configured' },
        { status: 500 }
      )
    }

    const openai = new OpenAI({ apiKey })

    // First, check existing journeys to avoid duplicates
    const { data: existingJourneys } = await supabaseAdmin
      .from('journeys')
      .select('title, slug')

    const existingTitles = new Set(
      existingJourneys?.map((j: any) => j.title.toLowerCase()) || []
    )
    const existingSlugs = new Set(
      existingJourneys?.map((j: any) => j.slug) || []
    )

    console.log(`[Journeys Generate] Existing journeys: ${existingTitles.size}`)

    const completion = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: `You are a mental health content designer for military personnel, veterans, and their families. 
Generate curated content journey ideas that provide structured pathways through mental health topics.

Each journey should be:
- Practical and actionable
- Military/veteran-appropriate (no therapy language)
- Focused on a specific outcome
- 7-14 days in length typically

Example journeys:
- "7-Day Sleep Recovery" for service_member
- "Managing Transition Stress" for veteran
- "Building Trust in Relationships" for any
- "Processing Deployment Experiences" for veteran
- "Supporting Your Partner" for partner_family

Respond with valid JSON only. No markdown, no code blocks.`
        },
        {
          role: 'user',
          content: `Generate ${count} unique content journey ideas. Format as a JSON array:
[
  {
    "title": "7-Day Sleep Recovery",
    "slug": "7-day-sleep-recovery",
    "description": "A structured pathway to rebuild healthy sleep patterns...",
    "audience": "service_member"
  }
]

Audience must be one of: any, service_member, veteran, partner_family
Ensure slugs are URL-safe (lowercase, hyphens, no spaces).`
        }
      ],
      temperature: 0.9,
      max_tokens: 2000
    })

    const content = completion.choices[0]?.message?.content?.trim()
    console.log('[Journeys Generate] GPT Response:', content?.substring(0, 200))

    if (!content) {
      throw new Error('No content received from OpenAI')
    }

    let journeys
    try {
      journeys = JSON.parse(content)
    } catch (parseError) {
      console.error('[Journeys Generate] JSON parse error:', parseError)
      throw new Error('Invalid JSON response from GPT')
    }

    if (!Array.isArray(journeys)) {
      throw new Error('Response is not an array')
    }

    // Filter out duplicates
    const newJourneys = journeys.filter((journey: any) => {
      const titleExists = existingTitles.has(journey.title.toLowerCase())
      const slugExists = existingSlugs.has(journey.slug)
      return !titleExists && !slugExists
    })

    console.log(`[Journeys Generate] New journeys after deduplication: ${newJourneys.length}/${journeys.length}`)

    if (newJourneys.length === 0) {
      return NextResponse.json({
        message: 'All generated journeys already exist. Try again for different results.',
        inserted: 0
      })
    }

    // Insert into database
    const journeysToInsert = newJourneys.map((journey: any) => ({
      title: journey.title,
      slug: journey.slug,
      description: journey.description || null,
      audience: journey.audience || 'any',
      item_sequence: [], // Empty initially
      is_published: false
    }))

    const { data: inserted, error: insertError } = await supabaseAdmin
      .from('journeys')
      .insert(journeysToInsert)
      .select()

    if (insertError) {
      console.error('[Journeys Generate] Insert error:', insertError)
      throw insertError
    }

    console.log(`[Journeys Generate] Successfully inserted ${inserted?.length || 0} journeys`)

    return NextResponse.json({
      message: `Generated ${inserted?.length || 0} new journeys`,
      inserted: inserted?.length || 0,
      journeys: inserted
    })

  } catch (error: any) {
    console.error('[Journeys Generate] Error:', error)
    return NextResponse.json(
      { error: `Failed to generate journeys: ${error.message}` },
      { status: 500 }
    )
  }
}

