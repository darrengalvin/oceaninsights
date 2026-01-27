import { NextRequest, NextResponse } from 'next/server'
import { getSupabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// GET single topic with all related data
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    
    // Get topic
    const { data: topic, error: topicError } = await supabaseAdmin
      .from('ritual_topics')
      .select(`
        *,
        category:ritual_categories(id, slug, name, icon, color)
      `)
      .eq('id', params.id)
      .single()

    if (topicError) throw topicError

    // Get ritual items
    const { data: items, error: itemsError } = await supabaseAdmin
      .from('ritual_items')
      .select('*')
      .eq('topic_id', params.id)
      .order('display_order', { ascending: true })

    if (itemsError) throw itemsError

    // Get affirmations
    const { data: affirmations, error: affirmationsError } = await supabaseAdmin
      .from('ritual_affirmations')
      .select('*')
      .eq('topic_id', params.id)
      .order('display_order', { ascending: true })

    if (affirmationsError) throw affirmationsError

    // Get milestones
    const { data: milestones, error: milestonesError } = await supabaseAdmin
      .from('ritual_milestones')
      .select('*')
      .eq('topic_id', params.id)
      .order('day_threshold', { ascending: true })

    if (milestonesError) throw milestonesError

    // Get tips
    const { data: tips, error: tipsError } = await supabaseAdmin
      .from('ritual_tips')
      .select('*')
      .eq('topic_id', params.id)
      .order('day_to_show', { ascending: true })

    if (tipsError) throw tipsError

    return NextResponse.json({
      ...topic,
      items,
      affirmations,
      milestones,
      tips
    })
  } catch (error) {
    console.error('Failed to fetch ritual topic:', error)
    return NextResponse.json(
      { error: 'Failed to fetch ritual topic' },
      { status: 500 }
    )
  }
}

// PATCH update topic
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    const body = await request.json()
    
    // Handle items, affirmations, milestones, tips separately
    const { items, affirmations, milestones, tips, ...topicData } = body
    
    // Update topic
    const { data: topic, error: topicError } = await supabaseAdmin
      .from('ritual_topics')
      .update(topicData)
      .eq('id', params.id)
      .select()
      .single()

    if (topicError) throw topicError

    // Update items if provided
    if (items) {
      // Delete removed items
      const itemIds = items.filter((i: any) => i.id).map((i: any) => i.id)
      if (itemIds.length > 0) {
        await supabaseAdmin
          .from('ritual_items')
          .delete()
          .eq('topic_id', params.id)
          .not('id', 'in', `(${itemIds.join(',')})`)
      } else {
        await supabaseAdmin
          .from('ritual_items')
          .delete()
          .eq('topic_id', params.id)
      }

      // Upsert items
      for (const item of items) {
        if (item.id) {
          await supabaseAdmin
            .from('ritual_items')
            .update(item)
            .eq('id', item.id)
        } else {
          await supabaseAdmin
            .from('ritual_items')
            .insert({ ...item, topic_id: params.id })
        }
      }
    }

    // Update affirmations if provided
    if (affirmations) {
      await supabaseAdmin
        .from('ritual_affirmations')
        .delete()
        .eq('topic_id', params.id)

      if (affirmations.length > 0) {
        await supabaseAdmin
          .from('ritual_affirmations')
          .insert(affirmations.map((a: any, i: number) => ({
            topic_id: params.id,
            text: a.text,
            attribution: a.attribution,
            display_order: i,
            is_active: true
          })))
      }
    }

    // Update milestones if provided
    if (milestones) {
      await supabaseAdmin
        .from('ritual_milestones')
        .delete()
        .eq('topic_id', params.id)

      if (milestones.length > 0) {
        await supabaseAdmin
          .from('ritual_milestones')
          .insert(milestones.map((m: any, i: number) => ({
            topic_id: params.id,
            title: m.title,
            description: m.description,
            day_threshold: m.day_threshold,
            icon: m.icon || 'emoji_events',
            celebration_message: m.celebration_message,
            display_order: i
          })))
      }
    }

    // Update tips if provided
    if (tips) {
      await supabaseAdmin
        .from('ritual_tips')
        .delete()
        .eq('topic_id', params.id)

      if (tips.length > 0) {
        await supabaseAdmin
          .from('ritual_tips')
          .insert(tips.map((t: any) => ({
            topic_id: params.id,
            title: t.title,
            content: t.content,
            day_to_show: t.day_to_show,
            icon: t.icon || 'lightbulb_outline',
            is_active: true
          })))
      }
    }

    return NextResponse.json(topic)
  } catch (error) {
    console.error('Failed to update ritual topic:', error)
    return NextResponse.json(
      { error: 'Failed to update ritual topic' },
      { status: 500 }
    )
  }
}

// DELETE topic
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    
    const { error } = await supabaseAdmin
      .from('ritual_topics')
      .delete()
      .eq('id', params.id)

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Failed to delete ritual topic:', error)
    return NextResponse.json(
      { error: 'Failed to delete ritual topic' },
      { status: 500 }
    )
  }
}
