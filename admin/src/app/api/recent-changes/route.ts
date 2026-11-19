import { NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'
import { ALL_TABLES, findTable } from '@/lib/content-sections'
import { TABLE_COLUMNS } from '@/lib/content-schema'

export const dynamic = 'force-dynamic'

// The most recently added or changed items across every editable list, plus
// the latest content audit, for the dashboard.
export async function GET() {
  const perTable = await Promise.all(
    ALL_TABLES.map(async (t) => {
      const cols = TABLE_COLUMNS[t.table] || []
      const stamp = cols.some((c) => c.name === 'updated_at') ? 'updated_at' : cols.some((c) => c.name === 'created_at') ? 'created_at' : null
      if (!stamp) return []
      const { data, error } = await supabaseAdmin
        .from(t.table)
        .select(`id, ${t.titleField}, ${stamp}`)
        .order(stamp, { ascending: false })
        .limit(3)
      if (error || !data) return []
      return data.map((r: any) => ({
        table: t.table,
        id: r.id,
        title: String(r[t.titleField] ?? '').slice(0, 120),
        at: r[stamp] as string,
        section: findTable(t.table)?.section.label ?? '',
        list: t.label,
      }))
    })
  )

  const recent = perTable
    .flat()
    .filter((r) => r.at)
    .sort((a, b) => (a.at < b.at ? 1 : -1))
    .slice(0, 8)

  const { data: audit } = await supabaseAdmin
    .from('audit_runs')
    .select('id, completed_at, system_score, findings_critical, findings_red')
    .eq('status', 'completed')
    .order('completed_at', { ascending: false })
    .limit(1)
    .maybeSingle()

  return NextResponse.json({ recent, lastAudit: audit ?? null })
}
