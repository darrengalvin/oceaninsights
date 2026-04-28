// Auto-Fix runs: a benchmark_run with a single candidate model and no judges,
// used to bulk-propose fixes across many open findings using one trusted model.
//
// Why reuse benchmark_runs/_fixes/_applies tables instead of new tables?
//   * The "propose a fix per finding" flow is already implemented in
//     /api/audit/benchmark/propose — it iterates the run's candidate_models.
//     With a single candidate it just calls one model. Zero duplication.
//   * The "apply this fix to source" flow already exists at /benchmark/apply
//     and writes into benchmark_applies for revertability.
//   * Auto-fix runs are distinguishable in history by judge_models = [] and
//     a notes prefix of "auto-fix:".
//
//   POST /api/audit/auto-fix
//     Body: { model_id?: string, finding_ids?: string[], audit_run_id?: string, notes?: string }
//     Defaults: model_id = 'claude-opus-4-7-xhigh'; finding_ids = all open
//     findings on the latest completed audit run.
//     Returns: { run, finding_ids } — caller then iterates /benchmark/propose
//     per finding to fan out the work and stream progress to the UI.
//
//   GET /api/audit/auto-fix
//     Lists recent auto-fix runs (judge_models = []) for the history pane.

import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { MODEL_BY_ID, BENCHMARK_MODELS } from '@/lib/audit/models';
import { anonymousLabels } from '@/lib/audit/benchmark';

export const dynamic = 'force-dynamic';

const DEFAULT_MODEL_ID = 'claude-opus-4-7-xhigh';

export async function GET() {
  // Auto-fix runs are benchmark_runs where judge_models is empty.
  // Postgrest's `eq` on jsonb compares the whole value, so we use `.is` on
  // the JSONB equality with the literal `[]` via the `cs` (contained-by) trick:
  // any auto-fix run's judge_models array is exactly empty, so we filter
  // client-side after fetching the most recent.
  const { data: runs, error } = await supabaseAdmin
    .from('benchmark_runs')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(50);

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  const autoFixRuns = (runs || []).filter(
    (r: { judge_models: unknown[] }) =>
      Array.isArray(r.judge_models) && r.judge_models.length === 0
  );

  return NextResponse.json({
    runs: autoFixRuns.slice(0, 10),
    available_models: BENCHMARK_MODELS,
  });
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      model_id,
      finding_ids,
      audit_run_id,
      notes,
    } = body as {
      model_id?: string;
      finding_ids?: string[];
      audit_run_id?: string;
      notes?: string;
    };

    const chosenModelId = model_id || DEFAULT_MODEL_ID;
    const model = MODEL_BY_ID[chosenModelId];
    if (!model) {
      return NextResponse.json(
        { error: `Unknown model: ${chosenModelId}` },
        { status: 400 }
      );
    }

    // Resolve which findings to fix. If finding_ids was supplied, validate them.
    // Otherwise default to every open finding on the most recent completed run.
    let resolvedFindingIds: string[];
    if (finding_ids && finding_ids.length > 0) {
      const { data: existing, error: existingErr } = await supabaseAdmin
        .from('audit_findings')
        .select('id')
        .in('id', finding_ids);
      if (existingErr) throw existingErr;
      resolvedFindingIds = (existing || []).map((f: { id: string }) => f.id);
      if (resolvedFindingIds.length !== finding_ids.length) {
        return NextResponse.json(
          { error: 'One or more finding_ids not found' },
          { status: 404 }
        );
      }
    } else {
      let targetAuditRunId = audit_run_id;
      if (!targetAuditRunId) {
        const { data: latest } = await supabaseAdmin
          .from('audit_runs')
          .select('id')
          .eq('status', 'completed')
          .order('completed_at', { ascending: false })
          .limit(1)
          .single();
        targetAuditRunId = latest?.id;
      }
      if (!targetAuditRunId) {
        return NextResponse.json(
          { error: 'No completed audit runs found — run an audit first' },
          { status: 400 }
        );
      }

      const { data: findings, error: findingsErr } = await supabaseAdmin
        .from('audit_findings')
        .select('id, score')
        .eq('run_id', targetAuditRunId)
        .eq('status', 'open')
        .order('score', { ascending: true });
      if (findingsErr) throw findingsErr;
      resolvedFindingIds = (findings || []).map((f: { id: string }) => f.id);
    }

    if (resolvedFindingIds.length === 0) {
      return NextResponse.json(
        { error: 'No open findings to fix' },
        { status: 400 }
      );
    }

    // Single candidate — gets the only anonymous label. Anonymisation is
    // moot because there are no judges, but we keep the convention so the
    // existing apply/propose code paths work unchanged.
    const [label] = anonymousLabels(1);
    const candidateModels = [
      {
        id: model.id,
        label: model.label,
        provider: model.provider,
        thinking_mode: model.thinkingMode,
        anonymous_label: label,
      },
    ];

    const { data: run, error: runErr } = await supabaseAdmin
      .from('benchmark_runs')
      .insert({
        audit_run_id: audit_run_id || null,
        status: 'created',
        finding_ids: resolvedFindingIds,
        candidate_models: candidateModels,
        judge_models: [],
        notes: notes ? `auto-fix: ${notes}` : `auto-fix: ${model.label}`,
      })
      .select()
      .single();
    if (runErr) throw runErr;

    return NextResponse.json({
      run,
      finding_ids: resolvedFindingIds,
      model: { id: model.id, label: model.label },
    });
  } catch (error) {
    console.error('Failed to create auto-fix run:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
