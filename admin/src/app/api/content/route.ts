import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// GET all content items
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const domain = searchParams.get('domain')
    const pillar = searchParams.get('pillar')
    const published = searchParams.get('published')
    const search = searchParams.get('search')

    let query = supabaseAdmin
      .from('content_items')
      .select(`
        *,
        domains (slug, name, icon)
      `)
      .order('created_at', { ascending: false })

    if (domain) {
      query = query.eq('domain_id', domain)
    }

    if (pillar) {
      query = query.eq('pillar', pillar)
    }

    if (published === 'true') {
      query = query.eq('is_published', true)
    } else if (published === 'false') {
      query = query.eq('is_published', false)
    }

    if (search) {
      query = query.or(`label.ilike.%${search}%,microcopy.ilike.%${search}%`)
    }

    const { data, error } = await query

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to fetch content:', error)
    return NextResponse.json(
      { error: 'Failed to fetch content' },
      { status: 500 }
    )
  }
}

// POST create new content item
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    const {
      domain_id,
      pillar,
      label,
      microcopy,
      audience = 'any',
      sensitivity = 'normal',
      disclosure_level = 1,
      keywords = [],
      is_published = false,
      // Deep content
      understand_title,
      understand_body,
      understand_examples,
      understand_insights = [],
      reflect_prompts = [],
      grow_title,
      grow_steps = [],
      grow_obstacles,
      support_intro,
      support_resources = [],
      when_to_seek_help,
      affirmation,
    } = body

    // Generate slug from label
    const slug = `${pillar}.${label.toLowerCase().replace(/[^a-z0-9]+/g, '-').slice(0, 50)}`

    // Insert content item
    const { data: contentItem, error: itemError } = await supabaseAdmin
      .from('content_items')
      .insert({
        slug,
        domain_id,
        pillar,
        label,
        microcopy,
        audience,
        sensitivity,
        disclosure_level,
        keywords,
        is_published,
      })
      .select()
      .single()

    if (itemError) throw itemError

    // Insert content details
    const { error: detailsError } = await supabaseAdmin
      .from('content_details')
      .insert({
        content_item_id: contentItem.id,
        understand_title,
        understand_body,
        understand_examples,
        understand_insights,
        reflect_prompts,
        grow_title,
        grow_steps,
        grow_obstacles,
        support_intro,
        support_resources,
        when_to_seek_help,
        affirmation,
      })

    if (detailsError) throw detailsError

    return NextResponse.json(contentItem, { status: 201 })
  } catch (error) {
    console.error('Failed to create content:', error)
    return NextResponse.json(
      { error: 'Failed to create content' },
      { status: 500 }
    )
  }
}

