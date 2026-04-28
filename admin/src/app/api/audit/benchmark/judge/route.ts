// POST /api/audit/benchmark/judge
//
// For one finding in one benchmark run, has every judge model score all
// candidate fixes (anonymised, shuffled). Stores judgments rows.
//
// Body: { benchmark_run_id: string, finding_id: string }
// Returns: { judgments: BenchmarkJudgment[] }

import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { judgeFixes } from '@/lib/audit/benchmark';
import type { AuditFinding } from '@/lib/audit/types';

export const dynamic = 'force-dynamic';
export const maxDuration = 300;

interface JudgeModelEntry {
  id: string;
  label: string;
}

interface BenchmarkFixRow {
  id: string;
  model_id: string;
  anonymous_label: string;
  proposed_text: string;
  rationale: string | null;
  status: string;
}

export async function POST(request: NextRequest) {
  try {
    const { benchmark_run_id, finding_id } = await request.json();

    if (!benchmark_run_id || !finding_id) {
      return NextResponse.json(
        { error: 'benchmark_run_id and finding_id required' },
        { status: 400 }
      );
    }

    const { data: run, error: runErr } = await supabaseAdmin
      .from('benchmark_runs')
      .select('*')
      .eq('id', benchmark_run_id)
      .single();
    if (runErr || !run) {
      return NextResponse.json({ error: 'Benchmark run not found' }, { status: 404 });
    }

    const { data: finding, error: findingErr } = await supabaseAdmin
      .from('audit_findings')
      .select('*')
      .eq('id', finding_id)
      .single();
    if (findingErr || !finding) {
      return NextResponse.json({ error: 'Finding not found' }, { status: 404 });
    }

    const { data: fixes, error: fixesErr } = await supabaseAdmin
      .from('benchmark_fixes')
      .select('id, model_id, anonymous_label, proposed_text, rationale, status')
      .eq('benchmark_run_id', benchmark_run_id)
      .eq('finding_id', finding_id);
    if (fixesErr) throw fixesErr;
    const validFixes = (fixes || []).filter((f: BenchmarkFixRow) => f.status === 'completed' && f.proposed_text);
    if (validFixes.length < 2) {
      return NextResponse.json(
        { error: `Need at least 2 successful fixes to judge; got ${validFixes.length}` },
        { status: 400 }
      );
    }

    const judges = (run.judge_models || []) as JudgeModelEntry[];
    if (judges.length === 0) {
      return NextResponse.json({ error: 'Run has no judge models' }, { status: 400 });
    }

    // Mark the run as judging on first call.
    if (run.status === 'proposing') {
      await supabaseAdmin
        .from('benchmark_runs')
        .update({ status: 'judging' })
        .eq('id', benchmark_run_id);
    }

    const anonymisedForJudge = validFixes.map((f: BenchmarkFixRow) => ({
      label: f.anonymous_label,
      proposed_text: f.proposed_text,
      rationale: f.rationale || '',
    }));

    // Map anonymous label back to fix_id + model_id so we can persist the
    // judgment against the right fix without ever giving the judge that info.
    const labelToFix = new Map<string, BenchmarkFixRow>();
    for (const f of validFixes) labelToFix.set(f.anonymous_label, f);

    const results = await Promise.allSettled(
      judges.map(async (judge) => {
        try {
          const { response, call } = await judgeFixes(judge.id, finding as AuditFinding, anonymisedForJudge);
          return { ok: true as const, judge, response, call };
        } catch (err) {
          return {
            ok: false as const,
            judge,
            error: err instanceof Error ? err.message : 'Unknown error',
          };
        }
      })
    );

    const inserted: unknown[] = [];
    for (const r of results) {
      if (r.status !== 'fulfilled') continue;
      const v = r.value;

      if (!v.ok) {
        // One judgment row per (fix, judge) — all marked failed for this judge.
        for (const fix of validFixes) {
          await supabaseAdmin
            .from('benchmark_judgments')
            .upsert({
              benchmark_run_id,
              fix_id: fix.id,
              finding_id,
              judge_model_id: v.judge.id,
              judge_model_label: v.judge.label,
              is_self_vote: v.judge.id === fix.model_id,
              status: 'failed',
              error_message: v.error,
            }, { onConflict: 'fix_id,judge_model_id' });
        }
        continue;
      }

      // Spread one row per scored fix.
      for (const j of v.response.judgments) {
        const fix = labelToFix.get(j.fix_label);
        if (!fix) {
          // Judge hallucinated a label. Skip silently — we'll still have
          // the other judges' rows for this fix.
          continue;
        }
        const { data, error: insertErr } = await supabaseAdmin
          .from('benchmark_judgments')
          .upsert({
            benchmark_run_id,
            fix_id: fix.id,
            finding_id,
            judge_model_id: v.judge.id,
            judge_model_label: v.judge.label,
            is_self_vote: v.judge.id === fix.model_id,
            score_resolves: j.score_resolves,
            score_safety: j.score_safety,
            score_tone: j.score_tone,
            score_conciseness: j.score_conciseness,
            score_faithfulness: j.score_faithfulness,
            overall_score: j.overall,
            ranking: j.ranking,
            justification: j.justification,
            raw_response: v.response,
            status: 'completed',
            latency_ms: v.call.latencyMs,
            input_tokens: v.call.inputTokens,
            output_tokens: v.call.outputTokens,
            cost_usd: v.call.costUsd,
          }, { onConflict: 'fix_id,judge_model_id' })
          .select()
          .single();
        if (insertErr) {
          console.error('Insert judgment failed:', insertErr);
        } else if (data) {
          inserted.push(data);
        }
      }
    }

    return NextResponse.json({ judgments: inserted });
  } catch (error) {
    console.error('Benchmark judge failed:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
