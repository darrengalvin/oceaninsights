// Benchmark CRUD endpoint.
//
//   POST /api/audit/benchmark   create a new benchmark run for a list of findings + models
//   GET  /api/audit/benchmark   list recent runs (most recent first)

import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { BENCHMARK_MODELS, MODEL_BY_ID } from '@/lib/audit/models';
import { anonymousLabels, shuffle } from '@/lib/audit/benchmark';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const limit = parseInt(searchParams.get('limit') || '20', 10);

  const { data: runs, error } = await supabaseAdmin
    .from('benchmark_runs')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(limit);

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({
    runs: runs || [],
    available_models: BENCHMARK_MODELS,
  });
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      finding_ids,
      candidate_model_ids,
      judge_model_ids,
      audit_run_id,
      notes,
    } = body as {
      finding_ids?: string[];
      candidate_model_ids?: string[];
      judge_model_ids?: string[];
      audit_run_id?: string;
      notes?: string;
    };

    if (!finding_ids || finding_ids.length === 0) {
      return NextResponse.json({ error: 'finding_ids required (at least 1)' }, { status: 400 });
    }
    if (!candidate_model_ids || candidate_model_ids.length < 2) {
      return NextResponse.json({ error: 'candidate_model_ids required (at least 2)' }, { status: 400 });
    }
    const judgeIds = judge_model_ids && judge_model_ids.length > 0 ? judge_model_ids : candidate_model_ids;

    const unknownCandidate = candidate_model_ids.find(id => !MODEL_BY_ID[id]);
    if (unknownCandidate) {
      return NextResponse.json({ error: `Unknown candidate model: ${unknownCandidate}` }, { status: 400 });
    }
    const unknownJudge = judgeIds.find(id => !MODEL_BY_ID[id]);
    if (unknownJudge) {
      return NextResponse.json({ error: `Unknown judge model: ${unknownJudge}` }, { status: 400 });
    }

    // Verify all findings exist and grab their content_areas — useful for the run summary.
    const { data: findings, error: findingsErr } = await supabaseAdmin
      .from('audit_findings')
      .select('id, content_area, item_id')
      .in('id', finding_ids);
    if (findingsErr) throw findingsErr;
    if (!findings || findings.length !== finding_ids.length) {
      return NextResponse.json({ error: 'One or more finding_ids not found' }, { status: 404 });
    }

    // Pre-compute the anonymous letter mapping per candidate model. Shuffling
    // here means the order we hand out anonymous labels is independent of the
    // order the user ticked the models in the UI.
    const shuffledModels = shuffle(candidate_model_ids);
    const labels = anonymousLabels(shuffledModels.length);
    const anonymousMap = Object.fromEntries(
      shuffledModels.map((id, i) => [id, labels[i]])
    );

    const candidateModels = candidate_model_ids.map(id => {
      const m = MODEL_BY_ID[id];
      return {
        id: m.id,
        label: m.label,
        provider: m.provider,
        thinking_mode: m.thinkingMode,
        anonymous_label: anonymousMap[id],
      };
    });

    const judgeModels = judgeIds.map(id => {
      const m = MODEL_BY_ID[id];
      return { id: m.id, label: m.label, provider: m.provider };
    });

    const { data: run, error: runErr } = await supabaseAdmin
      .from('benchmark_runs')
      .insert({
        audit_run_id: audit_run_id || null,
        status: 'created',
        finding_ids,
        candidate_models: candidateModels,
        judge_models: judgeModels,
        notes: notes || null,
      })
      .select()
      .single();
    if (runErr) throw runErr;

    return NextResponse.json({ run, anonymous_map: anonymousMap });
  } catch (error) {
    console.error('Failed to create benchmark run:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
