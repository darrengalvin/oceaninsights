import { SupabaseClient } from '@supabase/supabase-js';
import { extractContentArea, CONTENT_AREAS } from './extractor';
import { reviewContentArea } from './reviewer';
import { calculateWeightedScore } from './criteria';
import {
  ClaudeAuditResponse,
  ClaudeItemResult,
  ClaudeCategoryScore,
  scoreToTrafficLight,
} from './types';

interface PipelineOptions {
  supabase: SupabaseClient;
  anthropicApiKey: string;
  areaIds?: string[];
  existingRunId?: string;
}

export async function runAuditPipeline(options: PipelineOptions): Promise<string> {
  const { supabase, anthropicApiKey, areaIds, existingRunId } = options;

  const areasToAudit = areaIds
    ? CONTENT_AREAS.filter(a => areaIds.includes(a.id))
    : CONTENT_AREAS;

  let runId: string;

  if (existingRunId) {
    runId = existingRunId;
  } else {
    const { data: run, error: runError } = await supabase
      .from('audit_runs')
      .insert({
        status: 'running',
        areas_total: areasToAudit.length,
        areas_completed: 0,
        triggered_by: 'manual',
      })
      .select()
      .single();

    if (runError || !run) {
      throw new Error(`Failed to create audit run: ${runError?.message}`);
    }
    runId = run.id;
  }

  let totalItems = 0;
  let totalFindings = 0;
  let findingsCritical = 0;
  let findingsRed = 0;
  let findingsAmber = 0;
  let findingsGreen = 0;
  const allAreaScores: number[] = [];

  for (let i = 0; i < areasToAudit.length; i++) {
    const areaDef = areasToAudit[i];

    try {
      // Signal: extracting content for this area
      await supabase.from('audit_runs').update({
        current_area: areaDef.id,
        current_area_label: areaDef.label,
        current_phase: 'extracting',
        current_item_count: 0,
      }).eq('id', runId);

      const area = await extractContentArea(supabase, areaDef.id);
      if (!area) continue;

      // Signal: sending to Claude for review
      await supabase.from('audit_runs').update({
        current_phase: 'reviewing',
        current_item_count: area.items.length,
      }).eq('id', runId);

      const response = await reviewContentArea(area, anthropicApiKey);

      // Signal: storing results
      await supabase.from('audit_runs').update({
        current_phase: 'storing',
      }).eq('id', runId);

      const areaScores = await storeResults(supabase, runId, response);
      totalItems += areaScores.itemCount;
      totalFindings += areaScores.findingCount;
      findingsCritical += areaScores.critical;
      findingsRed += areaScores.red;
      findingsAmber += areaScores.amber;
      findingsGreen += areaScores.green;
      if (areaScores.avgScore !== null) {
        allAreaScores.push(areaScores.avgScore);
      }

      await supabase.from('audit_runs').update({
        areas_completed: i + 1,
        total_items_scored: totalItems,
        total_findings: totalFindings,
        findings_critical: findingsCritical,
        findings_red: findingsRed,
        findings_amber: findingsAmber,
        findings_green: findingsGreen,
      }).eq('id', runId);
    } catch (err) {
      console.error(`Error auditing area ${areaDef.id}:`, err);
      await supabase.from('audit_runs').update({
        current_phase: 'error',
        error_message: `Failed on ${areaDef.label}: ${err instanceof Error ? err.message : 'Unknown error'}`,
        areas_completed: i + 1,
      }).eq('id', runId);
    }
  }

  const systemScore = allAreaScores.length > 0
    ? Math.round(allAreaScores.reduce((a, b) => a + b, 0) / allAreaScores.length * 100) / 100
    : null;

  await supabase
    .from('audit_runs')
    .update({
      status: 'completed',
      completed_at: new Date().toISOString(),
      areas_completed: areasToAudit.length,
      system_score: systemScore,
      total_items_scored: totalItems,
      total_findings: totalFindings,
      findings_critical: findingsCritical,
      findings_red: findingsRed,
      findings_amber: findingsAmber,
      findings_green: findingsGreen,
    })
    .eq('id', runId);

  return runId;
}

interface AreaScoreSummary {
  itemCount: number;
  findingCount: number;
  critical: number;
  red: number;
  amber: number;
  green: number;
  avgScore: number | null;
}

async function storeResults(
  supabase: SupabaseClient,
  runId: string,
  response: ClaudeAuditResponse
): Promise<AreaScoreSummary> {
  let findingCount = 0;
  let critical = 0;
  let red = 0;
  let amber = 0;
  let green = 0;
  const itemScores: number[] = [];

  for (const item of response.items) {
    const categoryScoresMap: Record<string, { score: number; applicable: boolean; reasoning: string; sub_scores: unknown[] }> = {};

    for (const cs of item.category_scores) {
      categoryScoresMap[cs.category_id] = {
        score: cs.score,
        applicable: cs.applicable,
        reasoning: cs.reasoning,
        sub_scores: cs.sub_scores,
      };
    }

    const overallScore = item.overall_score ?? calculateWeightedScore(
      Object.fromEntries(
        Object.entries(categoryScoresMap).map(([k, v]) => [k, { score: v.score, applicable: v.applicable }])
      )
    );

    itemScores.push(overallScore);

    const light = scoreToTrafficLight(overallScore);
    if (light === 'critical') critical++;
    else if (light === 'red') red++;
    else if (light === 'amber') amber++;
    else green++;

    const { data: scoreRow } = await supabase
      .from('audit_item_scores')
      .insert({
        run_id: runId,
        content_area: response.content_area,
        item_id: item.item_id,
        item_label: item.item_label,
        source_table: item.source_table,
        overall_score: overallScore,
        category_scores: categoryScoresMap,
      })
      .select('id')
      .single();

    const scoreId = scoreRow?.id;

    for (const cs of item.category_scores) {
      for (const sub of cs.sub_scores) {
        if (sub.score < 90 && sub.finding) {
          findingCount++;
          await supabase.from('audit_findings').insert({
            run_id: runId,
            item_score_id: scoreId,
            content_area: response.content_area,
            item_id: item.item_id,
            item_label: item.item_label,
            category_id: cs.category_id,
            sub_criterion: sub.sub_criterion,
            score: sub.score,
            description: sub.finding,
            evidence: sub.evidence,
            suggested_action: sub.suggested_action,
            status: 'open',
          });
        }
      }

      await upsertCitations(supabase, runId, response.content_area, item, cs);
    }
  }

  return {
    itemCount: response.items.length,
    findingCount,
    critical,
    red,
    amber,
    green,
    avgScore: itemScores.length > 0
      ? Math.round(itemScores.reduce((a, b) => a + b, 0) / itemScores.length * 100) / 100
      : null,
  };
}

async function upsertCitations(
  supabase: SupabaseClient,
  runId: string,
  contentArea: string,
  item: ClaudeItemResult,
  cs: ClaudeCategoryScore
): Promise<void> {
  for (const citation of cs.citations) {
    const { data: existing } = await supabase
      .from('audit_citations')
      .select('id')
      .eq('claim_text', citation.claim_text)
      .eq('content_area', contentArea)
      .limit(1);

    if (existing && existing.length > 0) {
      await supabase
        .from('audit_citations')
        .update({ last_seen_run_id: runId, updated_at: new Date().toISOString() })
        .eq('id', existing[0].id);
    } else {
      await supabase.from('audit_citations').insert({
        claim_text: citation.claim_text,
        claim_type: citation.claim_type,
        content_area: contentArea,
        source_table: item.source_table,
        source_field: null,
        source_row_id: item.item_id,
        verification_status: 'unverified',
        source_url: citation.suggested_source,
        first_detected_run_id: runId,
        last_seen_run_id: runId,
      });
    }
  }
}
