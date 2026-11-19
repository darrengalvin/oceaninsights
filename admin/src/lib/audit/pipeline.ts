import { SupabaseClient } from '@supabase/supabase-js';
import { extractContentArea, CONTENT_AREAS } from './extractor';
import { reviewContentArea } from './reviewer';
import { storeAreaResults } from './store';

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

      const areaScores = await storeAreaResults(supabase, runId, area, response);
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
