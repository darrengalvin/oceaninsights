// POST /api/audit/benchmark/propose
//
// Runs every candidate model in parallel against ONE finding, stores the
// proposals as benchmark_fixes rows. The UI calls this once per finding so
// it can show progress per finding, and so a single slow model doesn't block
// the entire run.
//
// Body: { benchmark_run_id: string, finding_id: string }
// Returns: { fixes: BenchmarkFix[] }

import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { proposeFix } from '@/lib/audit/benchmark';
import type { AuditFinding } from '@/lib/audit/types';

export const dynamic = 'force-dynamic';
// Generous because GPT-5.5 Pro can take several minutes on hard prompts.
export const maxDuration = 300;

interface CandidateModelEntry {
  id: string;
  label: string;
  thinking_mode: string;
  anonymous_label: string;
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

    const candidates = (run.candidate_models || []) as CandidateModelEntry[];
    if (candidates.length === 0) {
      return NextResponse.json({ error: 'Run has no candidate models' }, { status: 400 });
    }

    // Mark the run as proposing on first call (idempotent).
    if (run.status === 'created') {
      await supabaseAdmin
        .from('benchmark_runs')
        .update({ status: 'proposing' })
        .eq('id', benchmark_run_id);
    }

    // Fan out: every candidate model proposes for this finding in parallel.
    // We swallow per-model errors into per-row error_message so a single bad
    // model doesn't fail the whole finding.
    const results = await Promise.allSettled(
      candidates.map(async (candidate) => {
        const startedAt = Date.now();
        try {
          const { proposal, call } = await proposeFix(candidate.id, finding as AuditFinding);
          return {
            ok: true as const,
            candidate,
            proposal,
            call,
          };
        } catch (err) {
          return {
            ok: false as const,
            candidate,
            error: err instanceof Error ? err.message : 'Unknown error',
            elapsed: Date.now() - startedAt,
          };
        }
      })
    );

    const inserted: unknown[] = [];

    for (const r of results) {
      if (r.status !== 'fulfilled') continue;
      const v = r.value;

      if (v.ok) {
        const { data, error: insertErr } = await supabaseAdmin
          .from('benchmark_fixes')
          .upsert({
            benchmark_run_id,
            finding_id,
            model_id: v.candidate.id,
            model_label: v.candidate.label,
            thinking_mode: v.candidate.thinking_mode,
            anonymous_label: v.candidate.anonymous_label,
            original_text: finding.evidence,
            proposed_text: v.proposal.proposed_text,
            rationale: v.proposal.rationale,
            source_field: v.proposal.source_field,
            raw_response: v.call.raw,
            status: 'completed',
            latency_ms: v.call.latencyMs,
            input_tokens: v.call.inputTokens,
            output_tokens: v.call.outputTokens,
            reasoning_tokens: v.call.reasoningTokens,
            cost_usd: v.call.costUsd,
          }, { onConflict: 'benchmark_run_id,finding_id,model_id' })
          .select()
          .single();
        if (insertErr) {
          console.error('Insert benchmark_fix failed:', insertErr);
        } else if (data) {
          inserted.push(data);
        }
      } else {
        const { data, error: insertErr } = await supabaseAdmin
          .from('benchmark_fixes')
          .upsert({
            benchmark_run_id,
            finding_id,
            model_id: v.candidate.id,
            model_label: v.candidate.label,
            thinking_mode: v.candidate.thinking_mode,
            anonymous_label: v.candidate.anonymous_label,
            original_text: finding.evidence,
            proposed_text: '',
            rationale: '',
            source_field: '',
            status: 'failed',
            error_message: v.error,
            latency_ms: v.elapsed,
          }, { onConflict: 'benchmark_run_id,finding_id,model_id' })
          .select()
          .single();
        if (insertErr) {
          console.error('Insert failed benchmark_fix failed:', insertErr);
        } else if (data) {
          inserted.push(data);
        }
      }
    }

    return NextResponse.json({ fixes: inserted });
  } catch (error) {
    console.error('Benchmark propose failed:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
