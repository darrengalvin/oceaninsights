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

    if (!domain_id || !pillar || !label?.trim()) {
      return NextResponse.json(
        { error: 'Domain, pillar and label are required' },
        { status: 400 }
      )
    }

    // Generate slug from label. Slugs are UNIQUE, so if another item already
    // uses this one (e.g. the same label in another domain) add a suffix
    // rather than failing the save.
    const baseSlug = `${pillar}.${label.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '').slice(0, 50)}`
    const { data: taken, error: slugError } = await supabaseAdmin
      .from('content_items')
      .select('slug')
      .like('slug', `${baseSlug}%`)
    if (slugError) throw slugError
    const takenSlugs = new Set((taken || []).map((r: { slug: string }) => r.slug))
    let slug = baseSlug
    for (let n = 2; takenSlugs.has(slug); n++) slug = `${baseSlug}-${n}`

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

    if (detailsError) {
      // Don't leave a half-created item behind: it would hold the slug and
      // make the next attempt fail too.
      await supabaseAdmin.from('content_items').delete().eq('id', contentItem.id)
      throw detailsError
    }

    return NextResponse.json(contentItem, { status: 201 })
  } catch (error: any) {
    console.error('Failed to create content:', error)
    return NextResponse.json(
      { error: error?.message || 'Failed to create content' },
      { status: 500 }
    )
  }
}

