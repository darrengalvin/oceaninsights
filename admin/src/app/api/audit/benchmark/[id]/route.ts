// GET /api/audit/benchmark/:id
//
// Returns the run, every fix, every judgment, the original findings, and a
// pre-computed leaderboard so the UI can render results in one fetch.
//
// PATCH /api/audit/benchmark/:id
// Marks a run completed and stores aggregated totals + winner.

import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

export const dynamic = 'force-dynamic';

interface JudgmentRow {
  id: string;
  fix_id: string;
  finding_id: string;
  judge_model_id: string;
  is_self_vote: boolean;
  overall_score: number | null;
  score_resolves: number | null;
  score_safety: number | null;
  score_tone: number | null;
  score_conciseness: number | null;
  score_faithfulness: number | null;
  ranking: number | null;
  justification: string | null;
  status: string;
}

interface FixRow {
  id: string;
  finding_id: string;
  model_id: string;
  model_label: string;
  anonymous_label: string;
  proposed_text: string;
  rationale: string | null;
  source_field: string | null;
  status: string;
  error_message: string | null;
  latency_ms: number | null;
  input_tokens: number | null;
  output_tokens: number | null;
  reasoning_tokens: number | null;
  cost_usd: number | null;
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
      return NextResponse.json({ error: 'Benchmark run not found' }, { status: 404 });
    }

    const { data: fixes, error: fixesErr } = await supabaseAdmin
      .from('benchmark_fixes')
      .select('*')
      .eq('benchmark_run_id', runId);
    if (fixesErr) throw fixesErr;

    const { data: judgments, error: judgmentsErr } = await supabaseAdmin
      .from('benchmark_judgments')
      .select('*')
      .eq('benchmark_run_id', runId);
    if (judgmentsErr) throw judgmentsErr;

    const { data: findings, error: findingsErr } = await supabaseAdmin
      .from('audit_findings')
      .select('*')
      .in('id', run.finding_ids || []);
    if (findingsErr) throw findingsErr;

    const { data: applies, error: appliesErr } = await supabaseAdmin
      .from('benchmark_applies')
      .select('*')
      .eq('benchmark_run_id', runId);
    if (appliesErr) throw appliesErr;

    const leaderboard = computeLeaderboard(fixes || [], judgments || []);

    return NextResponse.json({
      run,
      findings: findings || [],
      fixes: fixes || [],
      judgments: judgments || [],
      applies: applies || [],
      leaderboard,
    });
  } catch (error) {
    console.error('Failed to fetch benchmark run:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const runId = params.id;
    const body = await request.json();

    const update: Record<string, unknown> = {};
    if (body.status) update.status = body.status;
    if (body.notes !== undefined) update.notes = body.notes;

    if (body.status === 'completed') {
      update.completed_at = new Date().toISOString();

      // Compute totals + winner from current data.
      const { data: fixes } = await supabaseAdmin
        .from('benchmark_fixes')
        .select('cost_usd, latency_ms')
        .eq('benchmark_run_id', runId);
      const { data: judgmentsForTotals } = await supabaseAdmin
        .from('benchmark_judgments')
        .select('cost_usd, latency_ms')
        .eq('benchmark_run_id', runId);
      const { data: allFixes } = await supabaseAdmin
        .from('benchmark_fixes')
        .select('*')
        .eq('benchmark_run_id', runId);
      const { data: allJudgments } = await supabaseAdmin
        .from('benchmark_judgments')
        .select('*')
        .eq('benchmark_run_id', runId);

      const totalCost = [
        ...(fixes || []),
        ...(judgmentsForTotals || []),
      ].reduce((s, r: { cost_usd: number | null }) => s + (r.cost_usd || 0), 0);
      const totalLatency = [
        ...(fixes || []),
        ...(judgmentsForTotals || []),
      ].reduce((s, r: { latency_ms: number | null }) => s + (r.latency_ms || 0), 0);

      const leaderboard = computeLeaderboard(allFixes || [], allJudgments || []);
      const winner = leaderboard.models[0]?.model_id || null;

      update.total_cost_usd = Math.round(totalCost * 10000) / 10000;
      update.total_latency_ms = totalLatency;
      update.winner_model_id = winner;
    }

    const { data, error } = await supabaseAdmin
      .from('benchmark_runs')
      .update(update)
      .eq('id', runId)
      .select()
      .single();
    if (error) throw error;

    return NextResponse.json({ run: data });
  } catch (error) {
    console.error('Failed to update benchmark run:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

// =============================================================
// Leaderboard computation
// =============================================================
//
// We aggregate twice:
//   * per (finding × model) — winning model on each individual finding;
//   * per model — overall, averaged across all findings.
// Self-votes are tracked but excluded from the headline overall scores.

interface ModelLeaderboardEntry {
  model_id: string;
  model_label: string;
  mean_overall_excl_self: number;
  mean_resolves: number;
  mean_safety: number;
  mean_tone: number;
  mean_conciseness: number;
  mean_faithfulness: number;
  judgments_received: number;
  fixes_produced: number;
  fixes_failed: number;
  avg_latency_ms: number;
  total_cost_usd: number;
  self_vote_overall: number | null;
  wins: number;
}

function mean(nums: number[]): number {
  if (nums.length === 0) return 0;
  return Math.round((nums.reduce((s, n) => s + n, 0) / nums.length) * 100) / 100;
}

function computeLeaderboard(fixes: FixRow[], judgments: JudgmentRow[]) {
  // Group judgments by fix_id for per-fix aggregates.
  const judgmentsByFix = new Map<string, JudgmentRow[]>();
  for (const j of judgments) {
    if (j.status !== 'completed') continue;
    const arr = judgmentsByFix.get(j.fix_id) || [];
    arr.push(j);
    judgmentsByFix.set(j.fix_id, arr);
  }

  // Per-fix aggregate (excluding self-votes).
  const fixAggregates = fixes.map(f => {
    const all = judgmentsByFix.get(f.id) || [];
    const peer = all.filter(j => !j.is_self_vote);
    const selfVote = all.find(j => j.is_self_vote);
    return {
      fix_id: f.id,
      finding_id: f.finding_id,
      model_id: f.model_id,
      model_label: f.model_label,
      anonymous_label: f.anonymous_label,
      proposed_text: f.proposed_text,
      rationale: f.rationale,
      source_field: f.source_field,
      status: f.status,
      error_message: f.error_message,
      latency_ms: f.latency_ms,
      cost_usd: f.cost_usd,
      input_tokens: f.input_tokens,
      output_tokens: f.output_tokens,
      reasoning_tokens: f.reasoning_tokens,
      original_text: f.original_text,
      mean_overall_excl_self: mean(peer.map(j => j.overall_score || 0)),
      mean_resolves: mean(peer.map(j => j.score_resolves || 0)),
      mean_safety: mean(peer.map(j => j.score_safety || 0)),
      mean_tone: mean(peer.map(j => j.score_tone || 0)),
      mean_conciseness: mean(peer.map(j => j.score_conciseness || 0)),
      mean_faithfulness: mean(peer.map(j => j.score_faithfulness || 0)),
      judgments_received: peer.length,
      self_vote_overall: selfVote?.overall_score ?? null,
    };
  });

  // Per-finding winner: which fix had the highest mean_overall_excl_self for
  // that finding. Used to count "wins" per model.
  const fixesByFinding = new Map<string, typeof fixAggregates>();
  for (const fa of fixAggregates) {
    const arr = fixesByFinding.get(fa.finding_id) || [];
    arr.push(fa);
    fixesByFinding.set(fa.finding_id, arr);
  }
  const winsPerModel = new Map<string, number>();
  const findingWinners: { finding_id: string; winner_fix_id: string; winner_model_id: string; winner_score: number }[] = [];
  for (const [findingId, group] of Array.from(fixesByFinding.entries())) {
    const ranked = [...group].sort((a, b) => b.mean_overall_excl_self - a.mean_overall_excl_self);
    const top = ranked[0];
    if (!top || top.judgments_received === 0) continue;
    winsPerModel.set(top.model_id, (winsPerModel.get(top.model_id) || 0) + 1);
    findingWinners.push({
      finding_id: findingId,
      winner_fix_id: top.fix_id,
      winner_model_id: top.model_id,
      winner_score: top.mean_overall_excl_self,
    });
  }

  // Per-model overall.
  const fixesByModel = new Map<string, typeof fixAggregates>();
  for (const fa of fixAggregates) {
    const arr = fixesByModel.get(fa.model_id) || [];
    arr.push(fa);
    fixesByModel.set(fa.model_id, arr);
  }

  const models: ModelLeaderboardEntry[] = [];
  for (const [modelId, modelFixes] of Array.from(fixesByModel.entries())) {
    const successful = modelFixes.filter(f => f.status === 'completed');
    const failed = modelFixes.filter(f => f.status === 'failed');
    const allPeerJudgments = successful.flatMap(f => {
      const all = judgmentsByFix.get(f.fix_id) || [];
      return all.filter(j => !j.is_self_vote);
    });
    const selfJudgments = successful.flatMap(f => {
      const all = judgmentsByFix.get(f.fix_id) || [];
      return all.filter(j => j.is_self_vote);
    });

    models.push({
      model_id: modelId,
      model_label: modelFixes[0]?.model_label || modelId,
      mean_overall_excl_self: mean(allPeerJudgments.map(j => j.overall_score || 0)),
      mean_resolves: mean(allPeerJudgments.map(j => j.score_resolves || 0)),
      mean_safety: mean(allPeerJudgments.map(j => j.score_safety || 0)),
      mean_tone: mean(allPeerJudgments.map(j => j.score_tone || 0)),
      mean_conciseness: mean(allPeerJudgments.map(j => j.score_conciseness || 0)),
      mean_faithfulness: mean(allPeerJudgments.map(j => j.score_faithfulness || 0)),
      judgments_received: allPeerJudgments.length,
      fixes_produced: successful.length,
      fixes_failed: failed.length,
      avg_latency_ms: Math.round(
        successful.reduce((s, f) => s + (f.latency_ms || 0), 0) / Math.max(successful.length, 1)
      ),
      total_cost_usd: Math.round(
        successful.reduce((s, f) => s + (f.cost_usd || 0), 0) * 10000
      ) / 10000,
      self_vote_overall: selfJudgments.length > 0
        ? mean(selfJudgments.map(j => j.overall_score || 0))
        : null,
      wins: winsPerModel.get(modelId) || 0,
    });
  }

  models.sort((a, b) => b.mean_overall_excl_self - a.mean_overall_excl_self);

  return {
    models,
    fixes: fixAggregates,
    finding_winners: findingWinners,
  };
}
