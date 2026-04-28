import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { extractContentArea } from '@/lib/audit/extractor';
import { reviewContentArea } from '@/lib/audit/reviewer';
import { calculateWeightedScore } from '@/lib/audit/criteria';
import { scoreToTrafficLight } from '@/lib/audit/types';
import type { ClaudeItemResult, ClaudeCategoryScore } from '@/lib/audit/types';

export const dynamic = 'force-dynamic';
// 300s is the Vercel Pro max. Large content areas (navigate_content has 19
// items, scenarios_v2 has 27) routinely take longer than the previous 120s
// limit because the Anthropic auditor evaluates each item across 14
// categories and ~64 sub-criteria. Hitting the timeout means data is lost
// for the whole area, not just delayed.
export const maxDuration = 300;

export async function POST(request: NextRequest) {
  try {
    const { run_id, area_id, area_index, areas_total } = await request.json();

    if (!run_id || !area_id) {
      return NextResponse.json({ error: 'run_id and area_id are required' }, { status: 400 });
    }

    const anthropicApiKey = process.env.ANTHROPIC_API_KEY;
    if (!anthropicApiKey) {
      return NextResponse.json({ error: 'ANTHROPIC_API_KEY not configured' }, { status: 500 });
    }

    // Update run: extracting
    await supabaseAdmin.from('audit_runs').update({
      current_area: area_id,
      current_area_label: area_id.replace(/_/g, ' ').replace(/\b\w/g, (c: string) => c.toUpperCase()),
      current_phase: 'extracting',
      current_item_count: 0,
    }).eq('id', run_id);

    const area = await extractContentArea(supabaseAdmin, area_id);
    if (!area || area.items.length === 0) {
      await supabaseAdmin.from('audit_runs').update({
        areas_completed: (area_index || 0) + 1,
        current_phase: 'skipped',
      }).eq('id', run_id);

      return NextResponse.json({ status: 'skipped', items: 0, findings: 0, score: null });
    }

    // Update run: reviewing
    await supabaseAdmin.from('audit_runs').update({
      current_phase: 'reviewing',
      current_item_count: area.items.length,
    }).eq('id', run_id);

    const response = await reviewContentArea(area, anthropicApiKey);

    // Update run: storing
    await supabaseAdmin.from('audit_runs').update({
      current_phase: 'storing',
    }).eq('id', run_id);

    // Store results
    let findingCount = 0;
    let critical = 0, red = 0, amber = 0, green = 0;
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

      const { data: scoreRow } = await supabaseAdmin
        .from('audit_item_scores')
        .insert({
          run_id,
          content_area: response.content_area || area_id,
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
            await supabaseAdmin.from('audit_findings').insert({
              run_id,
              item_score_id: scoreId,
              content_area: response.content_area || area_id,
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

        await upsertCitations(run_id, response.content_area || area_id, item, cs);
      }
    }

    const avgScore = itemScores.length > 0
      ? Math.round(itemScores.reduce((a, b) => a + b, 0) / itemScores.length * 100) / 100
      : null;

    // Fetch current run totals and add to them
    const { data: currentRun } = await supabaseAdmin
      .from('audit_runs')
      .select('total_items_scored, total_findings, findings_critical, findings_red, findings_amber, findings_green')
      .eq('id', run_id)
      .single();

    await supabaseAdmin.from('audit_runs').update({
      areas_completed: (area_index || 0) + 1,
      total_items_scored: (currentRun?.total_items_scored || 0) + response.items.length,
      total_findings: (currentRun?.total_findings || 0) + findingCount,
      findings_critical: (currentRun?.findings_critical || 0) + critical,
      findings_red: (currentRun?.findings_red || 0) + red,
      findings_amber: (currentRun?.findings_amber || 0) + amber,
      findings_green: (currentRun?.findings_green || 0) + green,
      current_phase: 'complete',
    }).eq('id', run_id);

    return NextResponse.json({
      status: 'completed',
      items: response.items.length,
      findings: findingCount,
      score: avgScore,
      critical,
      red,
      amber,
      green,
    });
  } catch (error: unknown) {
    console.error('Area audit failed:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

async function upsertCitations(
  runId: string,
  contentArea: string,
  item: ClaudeItemResult,
  cs: ClaudeCategoryScore
): Promise<void> {
  for (const citation of cs.citations) {
    const { data: existing } = await supabaseAdmin
      .from('audit_citations')
      .select('id')
      .eq('claim_text', citation.claim_text)
      .eq('content_area', contentArea)
      .limit(1);

    if (existing && existing.length > 0) {
      await supabaseAdmin
        .from('audit_citations')
        .update({ last_seen_run_id: runId, updated_at: new Date().toISOString() })
        .eq('id', existing[0].id);
    } else {
      await supabaseAdmin.from('audit_citations').insert({
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
