import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { CONTENT_AREAS } from '@/lib/audit/areas';

export const dynamic = 'force-dynamic';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json().catch(() => ({}));
    const areaIds: string[] | undefined = body.area_ids;

    if (!process.env.ANTHROPIC_API_KEY) {
      return NextResponse.json(
        { error: 'ANTHROPIC_API_KEY not configured. Add it to your Vercel environment variables.' },
        { status: 500 }
      );
    }

    const areasToAudit = areaIds
      ? CONTENT_AREAS.filter(a => areaIds.includes(a.id))
      : CONTENT_AREAS;

    const { data: run, error: runError } = await supabaseAdmin
      .from('audit_runs')
      .insert({
        status: 'running',
        areas_total: areasToAudit.length,
        areas_completed: 0,
        triggered_by: 'manual',
        current_phase: 'starting',
      })
      .select()
      .single();

    if (runError || !run) {
      return NextResponse.json({ error: `Failed to create audit run: ${runError?.message}` }, { status: 500 });
    }

    return NextResponse.json({
      run_id: run.id,
      areas: areasToAudit.map(a => a.id),
      areas_total: areasToAudit.length,
    });
  } catch (error: unknown) {
    console.error('Audit run creation failed:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const { run_id, status, system_score } = await request.json();
    if (!run_id) return NextResponse.json({ error: 'run_id required' }, { status: 400 });

    const update: Record<string, unknown> = {};
    if (status) update.status = status;
    if (system_score !== undefined) update.system_score = system_score;
    if (status === 'completed' || status === 'failed') {
      update.completed_at = new Date().toISOString();
      update.current_phase = status;
      update.current_area = null;
      update.current_area_label = null;
    }

    await supabaseAdmin.from('audit_runs').update(update).eq('id', run_id);
    return NextResponse.json({ ok: true });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to update run' }, { status: 500 });
  }
}

export async function GET() {
  try {
    const { data: runs, error } = await supabaseAdmin
      .from('audit_runs')
      .select('*')
      .order('started_at', { ascending: false })
      .limit(20);

    if (error) throw error;
    return NextResponse.json({ runs: runs || [], available_areas: CONTENT_AREAS });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch audit runs' }, { status: 500 });
  }
}
