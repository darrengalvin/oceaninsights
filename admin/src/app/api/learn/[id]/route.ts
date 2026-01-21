import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// GET single article
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { data: article, error: articleError } = await supabaseAdmin
      .from('learn_articles')
      .select('*')
      .eq('id', params.id)
      .single()

    if (articleError) throw articleError

    const { data: content, error: contentError } = await supabaseAdmin
      .from('learn_article_content')
      .select('*')
      .eq('article_id', params.id)
      .single()

    if (contentError && contentError.code !== 'PGRST116') throw contentError

    return NextResponse.json({
      ...article,
      content: content || { sections: [], key_takeaways: [] }
    })
  } catch (error) {
    console.error('Failed to fetch article:', error)
    return NextResponse.json(
      { error: 'Failed to fetch article' },
      { status: 500 }
    )
  }
}

// PATCH update article
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
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

    // Update article
    const articleUpdate: any = {}
    if (slug !== undefined) articleUpdate.slug = slug
    if (title !== undefined) articleUpdate.title = title
    if (summary !== undefined) articleUpdate.summary = summary
    if (category !== undefined) articleUpdate.category = category
    if (read_time_minutes !== undefined) articleUpdate.read_time_minutes = read_time_minutes
    if (age_brackets !== undefined) articleUpdate.age_brackets = age_brackets
    if (audience !== undefined) articleUpdate.audience = audience
    if (is_published !== undefined) articleUpdate.is_published = is_published

    if (Object.keys(articleUpdate).length > 0) {
      articleUpdate.updated_at = new Date().toISOString()
      
      const { error: articleError } = await supabaseAdmin
        .from('learn_articles')
        .update(articleUpdate)
        .eq('id', params.id)

      if (articleError) throw articleError
    }

    // Update content if provided
    if (sections !== undefined || key_takeaways !== undefined) {
      const contentUpdate: any = {}
      if (sections !== undefined) contentUpdate.sections = sections
      if (key_takeaways !== undefined) contentUpdate.key_takeaways = key_takeaways

      // Check if content exists
      const { data: existing } = await supabaseAdmin
        .from('learn_article_content')
        .select('article_id')
        .eq('article_id', params.id)
        .single()

      if (existing) {
        // Update existing
        const { error: contentError } = await supabaseAdmin
          .from('learn_article_content')
          .update(contentUpdate)
          .eq('article_id', params.id)

        if (contentError) throw contentError
      } else {
        // Insert new
        const { error: contentError } = await supabaseAdmin
          .from('learn_article_content')
          .insert({
            article_id: params.id,
            ...contentUpdate
          })

        if (contentError) throw contentError
      }
    }

    return NextResponse.json({ success: true })
  } catch (error: any) {
    console.error('Failed to update article:', error)
    return NextResponse.json(
      { error: error.message || 'Failed to update article' },
      { status: 500 }
    )
  }
}

// DELETE article
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    // Delete content first (foreign key constraint)
    await supabaseAdmin
      .from('learn_article_content')
      .delete()
      .eq('article_id', params.id)

    // Delete article
    const { error } = await supabaseAdmin
      .from('learn_articles')
      .delete()
      .eq('id', params.id)

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Failed to delete article:', error)
    return NextResponse.json(
      { error: 'Failed to delete article' },
      { status: 500 }
    )
  }
}

