import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { scoreToTrafficLight, trafficLightLabel } from '@/lib/audit/types';
import { CATEGORY_MAP } from '@/lib/audit/criteria';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const runId = searchParams.get('run_id');
    const format = searchParams.get('format') || 'json';

    let targetRunId = runId;
    if (!targetRunId) {
      const { data: latestRun } = await supabaseAdmin
        .from('audit_runs')
        .select('id')
        .eq('status', 'completed')
        .order('completed_at', { ascending: false })
        .limit(1)
        .single();
      targetRunId = latestRun?.id;
    }

    if (!targetRunId) {
      return NextResponse.json({ error: 'No completed audit runs found' }, { status: 404 });
    }

    const { data: run } = await supabaseAdmin
      .from('audit_runs')
      .select('*')
      .eq('id', targetRunId)
      .single();

    const { data: scores } = await supabaseAdmin
      .from('audit_item_scores')
      .select('*')
      .eq('run_id', targetRunId)
      .order('content_area', { ascending: true });

    const { data: findings } = await supabaseAdmin
      .from('audit_findings')
      .select('*')
      .eq('run_id', targetRunId)
      .order('score', { ascending: true });

    const { data: citations } = await supabaseAdmin
      .from('audit_citations')
      .select('*')
      .order('claim_type', { ascending: true });

    if (format === 'csv') {
      return exportCSV(run, scores || [], findings || []);
    }

    if (format === 'summary') {
      return exportSummary(run, scores || [], findings || [], citations || []);
    }

    return NextResponse.json({
      run,
      scores: scores || [],
      findings: findings || [],
      citations: citations || [],
    });
  } catch (error) {
    console.error('Failed to export audit:', error);
    return NextResponse.json(
      { error: 'Failed to export audit' },
      { status: 500 }
    );
  }
}

function exportCSV(
  run: Record<string, unknown> | null,
  scores: Record<string, unknown>[],
  findings: Record<string, unknown>[]
) {
  const headers = ['Content Area', 'Item', 'Source Table', 'Overall Score', 'Traffic Light', 'Finding Count'];
  const rows = scores.map(s => {
    const findingCount = findings.filter(f => f.item_id === s.item_id).length;
    const light = scoreToTrafficLight(Number(s.overall_score));
    return [
      s.content_area,
      s.item_label,
      s.source_table,
      s.overall_score,
      trafficLightLabel(light),
      findingCount,
    ].join(',');
  });

  const csv = [headers.join(','), ...rows].join('\n');

  return new NextResponse(csv, {
    headers: {
      'Content-Type': 'text/csv',
      'Content-Disposition': `attachment; filename="audit-${run?.id || 'export'}.csv"`,
    },
  });
}

function exportSummary(
  run: Record<string, unknown> | null,
  scores: Record<string, unknown>[],
  findings: Record<string, unknown>[],
  citations: Record<string, unknown>[]
) {
  const systemScore = run?.system_score ?? 'N/A';
  const light = typeof systemScore === 'number' ? scoreToTrafficLight(systemScore) : 'red';

  const areaTotals: Record<string, { total: number; count: number }> = {};
  for (const s of scores) {
    const area = String(s.content_area);
    if (!areaTotals[area]) areaTotals[area] = { total: 0, count: 0 };
    areaTotals[area].total += Number(s.overall_score);
    areaTotals[area].count++;
  }

  const areaLines = Object.entries(areaTotals)
    .map(([area, t]) => {
      const avg = Math.round(t.total / t.count);
      const aLight = scoreToTrafficLight(avg);
      return `  - ${area}: ${avg}% (${trafficLightLabel(aLight)}) — ${t.count} items`;
    })
    .join('\n');

  const criticalFindings = findings.filter(f => Number(f.score) < 50);
  const criticalLines = criticalFindings.slice(0, 10).map(f =>
    `  - [${f.category_id}] ${f.item_label}: ${f.description}`
  ).join('\n');

  const unverifiedCitations = citations.filter(c => c.verification_status === 'unverified');

  const summary = `# Below the Surface — Content Audit Report

## Executive Summary

**Audit Date:** ${run?.completed_at || 'N/A'}
**Overall Score:** ${systemScore}% — ${trafficLightLabel(light)}
**Items Scored:** ${run?.total_items_scored || 0}
**Total Findings:** ${run?.total_findings || 0}
**Critical Issues:** ${run?.findings_critical || 0}
**Action Required:** ${run?.findings_red || 0}
**Review Recommended:** ${run?.findings_amber || 0}

## Content Area Scores

${areaLines}

## Critical Findings (Top 10)

${criticalLines || '  No critical findings.'}

## Citation Registry

**Total Claims Tracked:** ${citations.length}
**Verified:** ${citations.filter(c => c.verification_status === 'verified').length}
**Unverified:** ${unverifiedCitations.length}
**Disputed:** ${citations.filter(c => c.verification_status === 'disputed').length}

## Audit Criteria

This audit assessed content against 14 categories:
${Object.values(CATEGORY_MAP).map(c => `  ${c.label} (${c.weight}x weight)`).join('\n')}

---
*Generated by Below the Surface Content Audit System*
`;

  return new NextResponse(summary, {
    headers: {
      'Content-Type': 'text/markdown',
      'Content-Disposition': `attachment; filename="audit-summary-${run?.id || 'export'}.md"`,
    },
  });
}
