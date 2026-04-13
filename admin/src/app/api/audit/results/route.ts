import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const runId = searchParams.get('run_id');
    const area = searchParams.get('area');
    const itemId = searchParams.get('item_id');

    if (!runId) {
      const { data: latestRun } = await supabaseAdmin
        .from('audit_runs')
        .select('id')
        .eq('status', 'completed')
        .order('completed_at', { ascending: false })
        .limit(1)
        .single();

      if (!latestRun) {
        return NextResponse.json({ scores: [], run: null, summary: null });
      }

      return await getRunResults(latestRun.id, area, itemId);
    }

    return await getRunResults(runId, area, itemId);
  } catch (error) {
    console.error('Failed to fetch audit results:', error);
    return NextResponse.json(
      { error: 'Failed to fetch audit results' },
      { status: 500 }
    );
  }
}

async function getRunResults(runId: string, area: string | null, itemId: string | null) {
  const { data: run } = await supabaseAdmin
    .from('audit_runs')
    .select('*')
    .eq('id', runId)
    .single();

  let query = supabaseAdmin
    .from('audit_item_scores')
    .select('*')
    .eq('run_id', runId)
    .order('overall_score', { ascending: true });

  if (area) {
    query = query.eq('content_area', area);
  }

  if (itemId) {
    query = query.eq('item_id', itemId);
  }

  const { data: scores, error } = await query;
  if (error) throw error;

  const areaSummary: Record<string, { label: string; avg_score: number; item_count: number; findings: number }> = {};
  for (const score of (scores || [])) {
    if (!areaSummary[score.content_area]) {
      areaSummary[score.content_area] = {
        label: score.content_area,
        avg_score: 0,
        item_count: 0,
        findings: 0,
      };
    }
    areaSummary[score.content_area].item_count++;
    areaSummary[score.content_area].avg_score += score.overall_score;
  }

  for (const key of Object.keys(areaSummary)) {
    areaSummary[key].avg_score = Math.round(
      areaSummary[key].avg_score / areaSummary[key].item_count * 100
    ) / 100;
  }

  const { data: findingCounts } = await supabaseAdmin
    .from('audit_findings')
    .select('content_area')
    .eq('run_id', runId)
    .eq('status', 'open');

  if (findingCounts) {
    for (const f of findingCounts) {
      if (areaSummary[f.content_area]) {
        areaSummary[f.content_area].findings++;
      }
    }
  }

  let previousScore: number | null = null;
  if (run) {
    const { data: prevRun } = await supabaseAdmin
      .from('audit_runs')
      .select('system_score')
      .eq('status', 'completed')
      .lt('completed_at', run.started_at)
      .order('completed_at', { ascending: false })
      .limit(1)
      .single();

    if (prevRun) {
      previousScore = prevRun.system_score;
    }
  }

  return NextResponse.json({
    run,
    scores: scores || [],
    area_summary: areaSummary,
    previous_score: previousScore,
  });
}
