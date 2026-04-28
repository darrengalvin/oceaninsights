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
import type { SourceRowFields } from '@/lib/audit/benchmark';
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

// Columns to skip when surfacing "writable text fields" to the model. These are
// either internal bookkeeping (timestamps, ids), foreign keys, or display-only
// flags that can't reasonably be the offending content.
const SKIP_COLUMNS = new Set([
  'id', 'created_at', 'updated_at', 'sort_order', 'display_order',
  'is_active', 'is_published', 'is_featured', 'view_count',
  'icon', 'color', 'slug', 'audience', 'sensitivity', 'disclosure_level',
]);

function fieldLooksLikeFK(name: string): boolean {
  return name.endsWith('_id') || name.endsWith('_at') || name.endsWith('_by');
}

// Pull the source row for a finding and shape it as the model expects:
// only text-like columns, with a marker on whichever column currently holds
// the offending evidence string. Returns null if the row can't be located —
// the model then falls back to its best-guess behaviour.
async function fetchSourceRow(finding: AuditFinding): Promise<SourceRowFields | null> {
  if (!finding.item_id) return null;

  // We need the source_table — it lives on the audit_item_scores row that
  // produced this finding, not on the finding itself.
  let sourceTable: string | null = null;
  if (finding.item_score_id) {
    const { data: itemScore } = await supabaseAdmin
      .from('audit_item_scores')
      .select('source_table')
      .eq('id', finding.item_score_id)
      .single();
    sourceTable = (itemScore as { source_table?: string } | null)?.source_table || null;
  }
  if (!sourceTable) return null;

  const { data: row, error } = await supabaseAdmin
    .from(sourceTable)
    .select('*')
    .eq('id', finding.item_id)
    .single();
  if (error || !row) return null;

  const evidence = (finding.evidence || '').trim();
  const fields: SourceRowFields['fields'] = [];

  for (const [name, value] of Object.entries(row as Record<string, unknown>)) {
    if (SKIP_COLUMNS.has(name)) continue;
    if (fieldLooksLikeFK(name)) continue;
    if (value === null || value === undefined) continue;
    if (typeof value !== 'string') continue;
    if (value.length === 0) continue;

    const stringValue = value;
    fields.push({
      name,
      value: stringValue,
      matches_evidence: evidence.length > 0 && stringValue.includes(evidence),
    });
  }

  return { source_table: sourceTable, fields };
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

    // Fetch the source row once per finding (not per-model) so the model
    // sees the actual writable columns instead of guessing field names like
    // "description" that may not exist on tables like user_type_items.
    const sourceRow = await fetchSourceRow(finding as AuditFinding);

    // Fan out: every candidate model proposes for this finding in parallel.
    // We swallow per-model errors into per-row error_message so a single bad
    // model doesn't fail the whole finding.
    const results = await Promise.allSettled(
      candidates.map(async (candidate) => {
        const startedAt = Date.now();
        try {
          const { proposal, call } = await proposeFix(candidate.id, finding as AuditFinding, sourceRow);
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
