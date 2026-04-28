// GET /api/audit/auto-fix/:id
//
// Returns the auto-fix run plus every proposed fix joined with its underlying
// audit_finding. The UI polls this while proposals are streaming in and then
// renders the review queue from the same payload when the run is finished.

import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

export const dynamic = 'force-dynamic';

interface FixRow {
  id: string;
  finding_id: string;
  model_id: string;
  model_label: string;
  proposed_text: string;
  rationale: string | null;
  source_field: string | null;
  status: string;
  error_message: string | null;
  latency_ms: number | null;
  cost_usd: number | null;
  input_tokens: number | null;
  output_tokens: number | null;
  reasoning_tokens: number | null;
  original_text: string | null;
}

export async function GET(
  _request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const runId = params.id;

    const { data: run, error: runErr } = await supabaseAdmin
      .from('benchmark_runs')
      .select('*')
      .eq('id', runId)
      .single();
    if (runErr || !run) {
      return NextResponse.json({ error: 'Run not found' }, { status: 404 });
    }

    const [{ data: fixes }, { data: findings }, { data: applies }] =
      await Promise.all([
        supabaseAdmin
          .from('benchmark_fixes')
          .select('*')
          .eq('benchmark_run_id', runId),
        supabaseAdmin
          .from('audit_findings')
          .select('*')
          .in('id', run.finding_ids || []),
        supabaseAdmin
          .from('benchmark_applies')
          .select('*')
          .eq('benchmark_run_id', runId),
      ]);

    // Join fixes to their findings for easy rendering.
    const findingMap = new Map(
      (findings || []).map((f: { id: string }) => [f.id, f])
    );

    const enriched = (fixes || []).map((f: FixRow) => ({
      ...f,
      finding: findingMap.get(f.finding_id) || null,
    }));

    return NextResponse.json({
      run,
      fixes: enriched,
      applies: applies || [],
    });
  } catch (error) {
    console.error('Failed to fetch auto-fix run:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
