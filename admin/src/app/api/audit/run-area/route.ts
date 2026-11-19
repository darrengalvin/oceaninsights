import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { extractContentArea } from '@/lib/audit/extractor';
import { reviewContentArea } from '@/lib/audit/reviewer';
import { storeAreaResults } from '@/lib/audit/store';
import { CONTENT_AREAS } from '@/lib/audit/areas';

export const dynamic = 'force-dynamic';
// 300s is the Vercel Pro max. The reviewer splits large areas into batches
// reviewed in parallel so a single area stays inside this limit.
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
      current_area_label: CONTENT_AREAS.find(a => a.id === area_id)?.label
        ?? area_id.replace(/_/g, ' ').replace(/\b\w/g, (c: string) => c.toUpperCase()),
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

    const stored = await storeAreaResults(supabaseAdmin, run_id, area, response);
    const { findingCount, critical, red, amber, green, avgScore } = stored;

    // Fetch current run totals and add to them
    const { data: currentRun } = await supabaseAdmin
      .from('audit_runs')
      .select('total_items_scored, total_findings, findings_critical, findings_red, findings_amber, findings_green')
      .eq('id', run_id)
      .single();

    await supabaseAdmin.from('audit_runs').update({
      areas_completed: (area_index || 0) + 1,
      total_items_scored: (currentRun?.total_items_scored || 0) + stored.itemCount,
      total_findings: (currentRun?.total_findings || 0) + findingCount,
      findings_critical: (currentRun?.findings_critical || 0) + critical,
      findings_red: (currentRun?.findings_red || 0) + red,
      findings_amber: (currentRun?.findings_amber || 0) + amber,
      findings_green: (currentRun?.findings_green || 0) + green,
      current_phase: 'complete',
    }).eq('id', run_id);

    return NextResponse.json({
      status: 'completed',
      items: stored.itemCount,
      findings: findingCount,
      evidence_hits: stored.evidenceHitCount,
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
