import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

// GET single content item with details
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { data, error } = await supabaseAdmin
      .from('content_items')
      .select(`
        *,
        domains (slug, name, icon),
        content_details (*)
      `)
      .eq('id', params.id)
      .single()

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

// PUT update content item
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const body = await request.json()
    
    const {
      domain_id,
      pillar,
      label,
      microcopy,
      audience,
      sensitivity,
      disclosure_level,
      keywords,
      is_published,
      // Deep content
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
    } = body

    // Update content item
    const { data: contentItem, error: itemError } = await supabaseAdmin
      .from('content_items')
      .update({
        domain_id,
        pillar,
        label,
        microcopy,
        audience,
        sensitivity,
        disclosure_level,
        keywords,
        is_published,
        updated_at: new Date().toISOString(),
      })
      .eq('id', params.id)
      .select()
      .single()

    if (itemError) throw itemError

    // Update content details
    const { error: detailsError } = await supabaseAdmin
      .from('content_details')
      .upsert({
        content_item_id: params.id,
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
        updated_at: new Date().toISOString(),
      })

    if (detailsError) throw detailsError

    return NextResponse.json(contentItem)
  } catch (error) {
    console.error('Failed to update content:', error)
    return NextResponse.json(
      { error: 'Failed to update content' },
      { status: 500 }
    )
  }
}

// DELETE content item
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { error } = await supabaseAdmin
      .from('content_items')
      .delete()
      .eq('id', params.id)

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Failed to delete content:', error)
    return NextResponse.json(
      { error: 'Failed to delete content' },
      { status: 500 }
    )
  }
}

// PATCH for quick actions (publish/unpublish)
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const body = await request.json()
    
    const { data, error } = await supabaseAdmin
      .from('content_items')
      .update({
        ...body,
        updated_at: new Date().toISOString(),
      })
      .eq('id', params.id)
      .select()
      .single()

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to update content:', error)
    return NextResponse.json(
      { error: 'Failed to update content' },
      { status: 500 }
    )
  }
}

