import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// POST bulk import content (for GPT-generated content)
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { items } = body

    if (!items || !Array.isArray(items)) {
      return NextResponse.json(
        { error: 'Invalid format. Expected { items: [...] }' },
        { status: 400 }
      )
    }

    // Get domain mapping
    const { data: domains } = await supabaseAdmin
      .from('domains')
      .select('id, slug')

    const domainMap = new Map(domains?.map(d => [d.slug, d.id]) ?? [])

    // Map domain slugs to IDs
    const domainNameToSlug: Record<string, string> = {
      'Relationships & Connection': 'relationships',
      'Family, Parenting & Home Life': 'family',
      'Identity, Belonging & Inclusion': 'identity',
      'Grief, Change & Life Events': 'grief',
      'Calm, Confidence & Emotional Skills': 'calm',
      'Sleep, Energy & Recovery': 'sleep',
      'Health, Injury & Physical Wellbeing': 'health',
      'Money, Housing & Practical Life': 'money',
      'Work, Purpose & Service Culture': 'work',
      'Leadership, Boundaries & Communication': 'leadership',
      'Transition, Resettlement & Civilian Life': 'transition',
    }

    const results = {
      success: 0,
      failed: 0,
      skipped: 0,
      errors: [] as string[],
    }

    for (const item of items) {
      try {
        // Map domain name to ID
        const domainSlug = domainNameToSlug[item.domain] || item.domain.toLowerCase().replace(/[^a-z]+/g, '-')
        const domainId = domainMap.get(domainSlug)

        if (!domainId) {
          results.failed++
          results.errors.push(`Unknown domain: ${item.domain}`)
          continue
        }

        // Check if item already exists (by label + domain)
        const { data: existing } = await supabaseAdmin
          .from('content_items')
          .select('id, slug, is_published')
          .eq('domain_id', domainId)
          .eq('label', item.label)
          .maybeSingle()

        if (existing) {
          results.skipped++
          results.errors.push(`Skipped (exists): ${item.label}`)
          continue
        }

        // Create slug from ID or generate one
        const slug = item.id || `${domainSlug}.${item.pillar.toLowerCase()}.${item.label.toLowerCase().replace(/[^a-z0-9]+/g, '-').slice(0, 50)}`

        // Insert content item
        const { data: contentItem, error: itemError } = await supabaseAdmin
          .from('content_items')
          .insert({
            slug,
            domain_id: domainId,
            pillar: item.pillar.toLowerCase(),
            label: item.label,
            microcopy: item.microcopy,
            audience: item.audience?.replace('_', '-') || 'any',
            sensitivity: item.sensitivity || 'normal',
            disclosure_level: item.disclosure_level || 1,
            keywords: item.keywords || [],
            is_published: false, // Import as draft
          })
          .select()
          .single()

        if (itemError) {
          // Skip duplicates
          if (itemError.code === '23505') {
            results.skipped++
            results.errors.push(`Duplicate slug: ${item.label}`)
            continue
          }
          throw itemError
        }

        // Insert content details
        await supabaseAdmin
          .from('content_details')
          .insert({
            content_item_id: contentItem.id,
            understand_title: item.understand_title || null,
            understand_body: item.understand_body || null,
            understand_examples: item.understand_examples || null,
            understand_insights: item.understand_insights || [],
            reflect_prompts: item.reflect_prompts || [],
            grow_title: item.grow_title || null,
            grow_steps: item.grow_steps || [],
            grow_obstacles: item.grow_obstacles || null,
            support_intro: item.support_intro || null,
            support_resources: item.support_resources || [],
            when_to_seek_help: item.when_to_seek_help || null,
            affirmation: item.affirmation || item.microcopy,
          })

        results.success++
      } catch (error) {
        results.failed++
        results.errors.push(`Error: ${item.label} - ${error}`)
      }
    }

    return NextResponse.json({
      message: `Import complete. ${results.success} imported, ${results.skipped} skipped, ${results.failed} failed.`,
      ...results,
    })
  } catch (error) {
    console.error('Import failed:', error)
    return NextResponse.json(
      { error: 'Import failed' },
      { status: 500 }
    )
  }
}

