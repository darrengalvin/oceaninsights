import { NextRequest, NextResponse } from 'next/server'
import { getSupabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// GET all ritual topics with category info
export async function GET(request: NextRequest) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    const { searchParams } = new URL(request.url)
    const categorySlug = searchParams.get('category')
    
    let query = supabaseAdmin
      .from('ritual_topics')
      .select(`
        *,
        category:ritual_categories(id, slug, name, icon, color),
        ritual_items(count),
        ritual_affirmations(count)
      `)
      .order('display_order', { ascending: true })
    
    if (categorySlug) {
      const { data: category } = await supabaseAdmin
        .from('ritual_categories')
        .select('id')
        .eq('slug', categorySlug)
        .single()
      
      if (category) {
        query = query.eq('category_id', category.id)
      }
    }

    const { data, error } = await query

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to fetch ritual topics:', error)
    return NextResponse.json(
      { error: 'Failed to fetch ritual topics' },
      { status: 500 }
    )
  }
}

// POST create new topic
export async function POST(request: NextRequest) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    const body = await request.json()
    
    // Generate slug from name if not provided
    if (!body.slug && body.name) {
      body.slug = body.name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-|-$/g, '')
    }
    
    const { data, error } = await supabaseAdmin
      .from('ritual_topics')
      .insert(body)
      .select(`
        *,
        category:ritual_categories(id, slug, name, icon, color)
      `)
      .single()

    if (error) throw error

    return NextResponse.json(data, { status: 201 })
  } catch (error) {
    console.error('Failed to create ritual topic:', error)
    return NextResponse.json(
      { error: 'Failed to create ritual topic' },
      { status: 500 }
    )
  }
}
