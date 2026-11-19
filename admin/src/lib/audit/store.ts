// Store one reviewed content area: item scores, findings and citations.
//
// Shared by the dashboard's per-area route (api/audit/run-area) and the
// server-side pipeline, so both score the same way. Besides the AI review,
// every item also gets the deterministic Evidence Checks, and items the model
// did not return are still stored with their evidence results, so no content
// silently drops out of a run.

import type { SupabaseClient } from '@supabase/supabase-js';
import { calculateWeightedScore } from './criteria';
import { AUDIT_MODEL_LABEL } from './claude';
import { scanItem, evidenceCategoryScore, hitSubCriterion, hitDescription, SEVERITY_SCORE } from './evidence';
import { scoreToTrafficLight } from './types';
import type { ClaudeAuditResponse, ClaudeCategoryScore, ClaudeItemResult, ExtractedContentArea } from './types';

export interface AreaStoreSummary {
  itemCount: number;
  findingCount: number;
  evidenceHitCount: number;
  critical: number;
  red: number;
  amber: number;
  green: number;
  avgScore: number | null;
}

type StoredCategory = { score: number; applicable: boolean; reasoning: string; sub_scores: unknown[] };

export async function storeAreaResults(
  supabase: SupabaseClient,
  runId: string,
  area: ExtractedContentArea,
  response: ClaudeAuditResponse
): Promise<AreaStoreSummary> {
  const areaId = area.id;
  const reviewed = new Map<string, ClaudeItemResult>(response.items.map(i => [String(i.item_id), i]));
  const summary: AreaStoreSummary = { itemCount: 0, findingCount: 0, evidenceHitCount: 0, critical: 0, red: 0, amber: 0, green: 0, avgScore: null };
  const itemScores: number[] = [];

  for (const extracted of area.items) {
    const aiItem = reviewed.get(String(extracted.id));
    const categoryScores: Record<string, StoredCategory> = {};

    for (const cs of aiItem?.category_scores ?? []) {
      categoryScores[cs.category_id] = {
        score: clampScore(cs.score),
        applicable: cs.applicable,
        reasoning: cs.reasoning,
        sub_scores: cs.sub_scores,
      };
    }

    const hits = scanItem(extracted);
    categoryScores.evidence_checks = evidenceCategoryScore(hits);
    summary.evidenceHitCount += hits.length;

    // Always computed from the category weights, never taken from the model,
    // so the arithmetic is reproducible.
    const overallScore = calculateWeightedScore(
      Object.fromEntries(Object.entries(categoryScores).map(([k, v]) => [k, { score: v.score, applicable: v.applicable }]))
    );
    itemScores.push(overallScore);
    const light = scoreToTrafficLight(overallScore);
    summary[light === 'critical' ? 'critical' : light === 'red' ? 'red' : light === 'amber' ? 'amber' : 'green']++;

    const { data: scoreRow } = await supabase
      .from('audit_item_scores')
      .insert({
        run_id: runId,
        content_area: areaId,
        item_id: String(extracted.id),
        item_label: aiItem?.item_label || extracted.label,
        source_table: extracted.source_table,
        overall_score: overallScore,
        category_scores: categoryScores,
      })
      .select('id')
      .single();
    const scoreId = scoreRow?.id ?? null;

    const findingRows: Record<string, unknown>[] = [];
    const base = {
      run_id: runId,
      item_score_id: scoreId,
      content_area: areaId,
      item_id: String(extracted.id),
      item_label: aiItem?.item_label || extracted.label,
      status: 'open',
    };

    for (const cs of aiItem?.category_scores ?? []) {
      for (const sub of cs.sub_scores) {
        if (sub.score < 90 && sub.finding) {
          findingRows.push({
            ...base,
            category_id: cs.category_id,
            sub_criterion: sub.sub_criterion,
            score: clampScore(sub.score),
            description: sub.finding,
            evidence: sub.evidence,
            suggested_action: sub.suggested_action,
          });
        }
      }
    }

    for (const hit of hits) {
      if (hit.severity === 'info') continue; // recorded in the item score, not raised as a finding
      findingRows.push({
        ...base,
        category_id: 'evidence_checks',
        sub_criterion: hitSubCriterion(hit),
        score: SEVERITY_SCORE[hit.severity],
        description: hitDescription(hit),
        evidence: hit.context,
        suggested_action: hit.fix,
      });
    }

    if (!aiItem && area.items.length > 0 && response.items.length > 0) {
      findingRows.push({
        ...base,
        category_id: 'completeness',
        sub_criterion: 'audit_coverage',
        score: 50,
        description: 'The AI review did not return a score for this item, so only the evidence checks were applied. Re-run this area.',
        evidence: extracted.label,
        suggested_action: 'Re-run the audit for this area.',
      });
    }

    if (findingRows.length) {
      await supabase.from('audit_findings').insert(findingRows);
      summary.findingCount += findingRows.length;
    }

    for (const cs of aiItem?.category_scores ?? []) {
      await upsertCitations(supabase, runId, areaId, extracted.source_table, String(extracted.id), cs);
    }
    summary.itemCount++;
  }

  summary.avgScore = itemScores.length
    ? Math.round((itemScores.reduce((a, b) => a + b, 0) / itemScores.length) * 100) / 100
    : null;
  return summary;
}

function clampScore(n: number): number {
  return Math.max(0, Math.min(100, Number(n) || 0));
}

const ALIGNMENT_TEXT: Record<string, string> = {
  matches: 'matches',
  differs: 'DIFFERS FROM',
  not_covered: 'is not covered by',
  no_trusted_source: 'has no trusted source',
};

async function upsertCitations(
  supabase: SupabaseClient,
  runId: string,
  contentArea: string,
  sourceTable: string,
  itemId: string,
  cs: ClaudeCategoryScore
): Promise<void> {
  for (const citation of cs.citations ?? []) {
    const alignment = citation.alignment ? ALIGNMENT_TEXT[citation.alignment] : null;
    const note = alignment
      ? `AI source check (${AUDIT_MODEL_LABEL}, ${new Date().toISOString().slice(0, 10)}): claim ${alignment}${citation.alignment === 'no_trusted_source' ? '' : ` ${citation.trusted_source_name ?? 'the trusted source'}`}. Needs human verification before it counts as verified.`
      : null;

    const { data: existing } = await supabase
      .from('audit_citations')
      .select('id, verification_status')
      .eq('claim_text', citation.claim_text)
      .eq('content_area', contentArea)
      .limit(1);

    if (existing && existing.length > 0) {
      const update: Record<string, unknown> = { last_seen_run_id: runId, updated_at: new Date().toISOString() };
      // Never overwrite a human verification; refresh the AI note otherwise.
      if (existing[0].verification_status === 'unverified' && note) {
        update.notes = note;
        if (citation.suggested_source) update.source_url = citation.suggested_source;
      }
      await supabase.from('audit_citations').update(update).eq('id', existing[0].id);
    } else {
      await supabase.from('audit_citations').insert({
        claim_text: citation.claim_text,
        claim_type: citation.claim_type,
        content_area: contentArea,
        source_table: sourceTable,
        source_field: null,
        source_row_id: itemId,
        verification_status: citation.alignment === 'differs' ? 'disputed' : 'unverified',
        source_url: citation.suggested_source,
        notes: note,
        first_detected_run_id: runId,
        last_seen_run_id: runId,
      });
    }
  }
}
