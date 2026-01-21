import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// GET all learn articles
export async function GET() {
  try {
    const { data, error } = await supabaseAdmin
      .from('learn_articles')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to fetch articles:', error)
    return NextResponse.json(
      { error: 'Failed to fetch articles' },
      { status: 500 }
    )
  }
}

// POST create new article
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    const {
      slug,
      title,
      summary,
      category,
      read_time_minutes,
      age_brackets,
      audience,
      sections,
      key_takeaways,
      is_published
    } = body

    // Insert article
    const { data: article, error: articleError } = await supabaseAdmin
      .from('learn_articles')
      .insert({
        slug,
        title,
        summary,
        category,
        read_time_minutes: read_time_minutes || 5,
        age_brackets: age_brackets || null,
        audience: audience || 'any',
        is_published: is_published || false
      })
      .select()
      .single()

    if (articleError) throw articleError

    // Insert content
    const { error: contentError } = await supabaseAdmin
      .from('learn_article_content')
      .insert({
        article_id: article.id,
        sections: sections || [],
        key_takeaways: key_takeaways || []
      })

    if (contentError) throw contentError

    return NextResponse.json(article)
  } catch (error: any) {
    console.error('Failed to create article:', error)
    return NextResponse.json(
      { error: error.message || 'Failed to create article' },
      { status: 500 }
    )
  }
}

