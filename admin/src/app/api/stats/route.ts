import { NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

export async function GET() {
  try {
    // Get total content count
    const { count: totalContent } = await supabaseAdmin
      .from('content_items')
      .select('*', { count: 'exact', head: true })

    // Get published content count
    const { count: publishedContent } = await supabaseAdmin
      .from('content_items')
      .select('*', { count: 'exact', head: true })
      .eq('is_published', true)

    // Get domains count
    const { count: domains } = await supabaseAdmin
      .from('domains')
      .select('*', { count: 'exact', head: true })
      .eq('is_active', true)

    // Get journeys count
    const { count: journeys } = await supabaseAdmin
      .from('journeys')
      .select('*', { count: 'exact', head: true })

    return NextResponse.json({
      totalContent: totalContent ?? 0,
      publishedContent: publishedContent ?? 0,
      draftContent: (totalContent ?? 0) - (publishedContent ?? 0),
      domains: domains ?? 0,
      journeys: journeys ?? 0,
    })
  } catch (error) {
    console.error('Failed to fetch stats:', error)
    return NextResponse.json(
      { error: 'Failed to fetch stats' },
      { status: 500 }
    )
  }
}

