import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const url = new URL(req.url)
    const limit = Math.min(parseInt(url.searchParams.get('limit') || '200', 10), 1000)

    const { data, error } = await supabaseAdmin
      .from('redemption_events')
      .select('*')
      .eq('organization_id', params.id)
      .order('occurred_at', { ascending: false })
      .limit(limit)

    if (error) throw error

    const successful = (data ?? []).filter((e) => e.succeeded)
    const failed = (data ?? []).filter((e) => !e.succeeded)

    const burstAlerts = detectBursts(successful)

    return NextResponse.json({
      events: data ?? [],
      stats: {
        total: data?.length ?? 0,
        successful: successful.length,
        failed: failed.length,
      },
      alerts: burstAlerts,
    })
  } catch (error) {
    console.error('Failed to fetch redemption events:', error)
    return NextResponse.json({ error: 'Failed to fetch redemption events' }, { status: 500 })
  }
}

interface EventRow {
  occurred_at: string
}

function detectBursts(events: EventRow[]): { window_start: string; window_end: string; count: number }[] {
  if (events.length < 10) return []
  const sorted = [...events].sort(
    (a, b) => new Date(a.occurred_at).getTime() - new Date(b.occurred_at).getTime()
  )
  const alerts: { window_start: string; window_end: string; count: number }[] = []
  for (let i = 0; i < sorted.length; i++) {
    const start = new Date(sorted[i].occurred_at).getTime()
    let count = 1
    let lastIdx = i
    for (let j = i + 1; j < sorted.length; j++) {
      const t = new Date(sorted[j].occurred_at).getTime()
      if (t - start <= 60_000) {
        count++
        lastIdx = j
      } else break
    }
    if (count >= 10) {
      alerts.push({
        window_start: sorted[i].occurred_at,
        window_end: sorted[lastIdx].occurred_at,
        count,
      })
      i = lastIdx
    }
  }
  return alerts
}
