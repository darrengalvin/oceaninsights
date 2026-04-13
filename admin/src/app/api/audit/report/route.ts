import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { AUDIT_CATEGORIES, CATEGORY_MAP } from '@/lib/audit/criteria';
import { CONTENT_AREAS } from '@/lib/audit/areas';
import { scoreToTrafficLight } from '@/lib/audit/types';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const runId = searchParams.get('run_id');

    let targetRunId = runId;
    if (!targetRunId) {
      const { data: latest } = await supabaseAdmin
        .from('audit_runs')
        .select('id')
        .eq('status', 'completed')
        .order('completed_at', { ascending: false })
        .limit(1)
        .single();
      targetRunId = latest?.id;
    }

    if (!targetRunId) {
      return new NextResponse('No completed audit runs found', { status: 404 });
    }

    const [
      { data: run },
      { data: scores },
      { data: findings },
      { data: citations },
    ] = await Promise.all([
      supabaseAdmin.from('audit_runs').select('*').eq('id', targetRunId).single(),
      supabaseAdmin.from('audit_item_scores').select('*').eq('run_id', targetRunId).order('content_area'),
      supabaseAdmin.from('audit_findings').select('*').eq('run_id', targetRunId).order('score', { ascending: true }),
      supabaseAdmin.from('audit_citations').select('*').order('claim_type'),
    ]);

    if (!run) return new NextResponse('Audit run not found', { status: 404 });

    const html = buildReportHTML(run, scores || [], findings || [], citations || []);

    return new NextResponse(html, {
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
      },
    });
  } catch (error) {
    console.error('Report generation failed:', error);
    return NextResponse.json({ error: 'Failed to generate report' }, { status: 500 });
  }
}

function tl(score: number): { color: string; bg: string; label: string } {
  const light = scoreToTrafficLight(score);
  const map = {
    green: { color: '#16a34a', bg: '#f0fdf4', label: 'Meets Standard' },
    amber: { color: '#d97706', bg: '#fffbeb', label: 'Review Recommended' },
    red: { color: '#dc2626', bg: '#fef2f2', label: 'Action Required' },
    critical: { color: '#991b1b', bg: '#fef2f2', label: 'Immediate Action Required' },
  };
  return map[light];
}

function esc(text: string | null | undefined): string {
  if (!text) return '';
  return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function buildReportHTML(
  run: Record<string, unknown>,
  scores: Record<string, unknown>[],
  findings: Record<string, unknown>[],
  citations: Record<string, unknown>[]
): string {
  const systemScore = Number(run.system_score) || 0;
  const sys = tl(systemScore);
  const auditDate = run.completed_at ? new Date(String(run.completed_at)).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' }) : 'N/A';

  // Area summaries
  const areaMap: Record<string, { scores: number[]; findings: number; label: string }> = {};
  for (const s of scores) {
    const area = String(s.content_area);
    if (!areaMap[area]) {
      const areaInfo = CONTENT_AREAS.find(a => a.id === area);
      areaMap[area] = { scores: [], findings: 0, label: areaInfo?.label || area };
    }
    areaMap[area].scores.push(Number(s.overall_score));
  }
  for (const f of findings) {
    const area = String(f.content_area);
    if (areaMap[area]) areaMap[area].findings++;
  }

  const sortedAreas = Object.entries(areaMap).sort((a, b) => {
    const avgA = a[1].scores.reduce((x, y) => x + y, 0) / a[1].scores.length;
    const avgB = b[1].scores.reduce((x, y) => x + y, 0) / b[1].scores.length;
    return avgA - avgB;
  });

  // Category summaries across all findings
  const catFindings: Record<string, number> = {};
  for (const f of findings) {
    const cat = String(f.category_id);
    catFindings[cat] = (catFindings[cat] || 0) + 1;
  }

  // Citation stats
  const citByType: Record<string, number> = {};
  const citByStatus: Record<string, number> = {};
  for (const c of citations) {
    const t = String(c.claim_type);
    const s = String(c.verification_status);
    citByType[t] = (citByType[t] || 0) + 1;
    citByStatus[s] = (citByStatus[s] || 0) + 1;
  }

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Content Audit Report — Below the Surface</title>
<style>
  @media print { body { font-size: 11pt; } .no-print { display: none; } .page-break { page-break-before: always; } }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; color: #1a1a1a; line-height: 1.6; max-width: 900px; margin: 0 auto; padding: 40px 20px; }
  h1 { font-size: 28px; font-weight: 700; margin-bottom: 4px; }
  h2 { font-size: 20px; font-weight: 700; margin: 32px 0 12px; padding-bottom: 8px; border-bottom: 2px solid #e5e7eb; }
  h3 { font-size: 16px; font-weight: 600; margin: 20px 0 8px; }
  h4 { font-size: 13px; font-weight: 600; margin: 12px 0 4px; color: #374151; }
  p { margin: 6px 0; color: #374151; font-size: 14px; }
  .subtitle { color: #6b7280; font-size: 14px; }
  .score-hero { display: flex; align-items: center; gap: 16px; padding: 24px; border-radius: 12px; margin: 20px 0; }
  .score-hero .number { font-size: 48px; font-weight: 800; }
  .score-hero .detail { font-size: 14px; }
  .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin: 16px 0; }
  .stat-card { background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px; padding: 12px; text-align: center; }
  .stat-card .num { font-size: 24px; font-weight: 700; }
  .stat-card .lbl { font-size: 11px; color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px; }
  .area-row { display: flex; align-items: center; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f3f4f6; }
  .area-row .name { font-size: 14px; font-weight: 500; }
  .area-row .score { font-size: 14px; font-weight: 700; }
  .area-row .meta { font-size: 12px; color: #9ca3af; }
  .bar { height: 6px; border-radius: 3px; background: #f3f4f6; margin-top: 4px; }
  .bar .fill { height: 6px; border-radius: 3px; }
  .finding-card { background: #f9fafb; border-left: 3px solid; border-radius: 0 8px 8px 0; padding: 12px 16px; margin: 8px 0; }
  .finding-card .header { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
  .finding-card .cat { font-size: 11px; font-weight: 600; color: #6b7280; text-transform: uppercase; }
  .finding-card .item-name { font-size: 13px; font-weight: 600; color: #111827; }
  .finding-card .desc { font-size: 13px; color: #374151; margin: 4px 0; }
  .finding-card .evidence { font-size: 12px; color: #6b7280; font-style: italic; margin: 4px 0; }
  .finding-card .action { font-size: 12px; color: #0e7490; margin-top: 4px; }
  .crit-table { width: 100%; border-collapse: collapse; margin: 12px 0; font-size: 13px; }
  .crit-table th { text-align: left; padding: 8px; background: #f9fafb; border-bottom: 2px solid #e5e7eb; font-size: 12px; text-transform: uppercase; color: #6b7280; }
  .crit-table td { padding: 8px; border-bottom: 1px solid #f3f4f6; vertical-align: top; }
  .badge { display: inline-block; padding: 2px 8px; border-radius: 9999px; font-size: 11px; font-weight: 600; }
  .methodology { background: #f0f9ff; border: 1px solid #bae6fd; border-radius: 12px; padding: 20px; margin: 16px 0; }
  .methodology p { color: #0c4a6e; }
  .print-btn { position: fixed; bottom: 20px; right: 20px; background: #0e7490; color: white; border: none; padding: 12px 24px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
  .print-btn:hover { background: #0891b2; }
  .citation-row { display: flex; align-items: flex-start; gap: 8px; padding: 8px 0; border-bottom: 1px solid #f3f4f6; font-size: 13px; }
  .citation-row .type { font-size: 11px; font-weight: 600; padding: 1px 6px; border-radius: 4px; background: #f3f4f6; color: #6b7280; white-space: nowrap; }
</style>
</head>
<body>

<button class="print-btn no-print" onclick="window.print()">Print / Save PDF</button>

<div style="margin-bottom: 32px;">
  <h1>Content Audit Report</h1>
  <p class="subtitle">Below the Surface — Mental Wellness Application</p>
  <p class="subtitle">Audit Date: ${auditDate}</p>
</div>

<!-- Executive Summary -->
<h2>1. Executive Summary</h2>

<div class="score-hero" style="background: ${sys.bg}; border: 1px solid ${sys.color}20;">
  <div class="number" style="color: ${sys.color};">${Math.round(systemScore)}%</div>
  <div>
    <div class="detail" style="color: ${sys.color}; font-weight: 700;">${sys.label}</div>
    <div class="detail">${scores.length} content items scored across ${Object.keys(areaMap).length} content areas</div>
    <div class="detail">${findings.length} findings identified · ${citations.length} factual claims catalogued</div>
  </div>
</div>

<div class="stats-grid">
  <div class="stat-card"><div class="num" style="color: #dc2626;">${run.findings_critical || 0}</div><div class="lbl">Critical</div></div>
  <div class="stat-card"><div class="num" style="color: #ef4444;">${run.findings_red || 0}</div><div class="lbl">Action Required</div></div>
  <div class="stat-card"><div class="num" style="color: #d97706;">${run.findings_amber || 0}</div><div class="lbl">Review</div></div>
  <div class="stat-card"><div class="num" style="color: #16a34a;">${run.findings_green || 0}</div><div class="lbl">Passing</div></div>
</div>

<p>This report presents the results of an automated content compliance audit conducted on all user-facing content within the Below the Surface application. The audit was performed using AI-powered analysis (Claude) against 14 compliance categories covering factual accuracy, safety, OPSEC, clinical boundaries, safeguarding, bias, regional appropriateness, and more.</p>
<p>Each content item was scored 0–100% per applicable criterion, with weighted averages producing overall scores. Categories with safety or legal implications carry higher weight (1.5x for Safety, Clinical Boundaries, Safeguarding, OPSEC; 1.2x for Factual Accuracy, Regional, Currency).</p>

<!-- Methodology -->
<h2>2. Audit Methodology</h2>

<div class="methodology">
  <p><strong>What was audited:</strong> Every piece of user-facing content across ${Object.keys(areaMap).length} content areas — including navigate content, learn articles, crisis pathways, harassment guidance, LGBTQ+ support, brain science, military perks, service family resources, and more.</p>
  <p><strong>How it was audited:</strong> Each content area was extracted from the database with all related child content, serialised into a structured format, and submitted to Claude (Anthropic AI) with the full 14-category grading rubric. Claude used extended thinking to reason through each assessment before assigning scores.</p>
  <p><strong>Scoring:</strong> Each content item received a score of 0–100% per applicable criterion, producing an overall weighted score. Traffic light grades provide at-a-glance readability: Green (90–100%), Amber (70–89%), Red (50–69%), Critical (0–49%).</p>
</div>

<h3>The 14 Grading Criteria</h3>
<table class="crit-table">
  <thead><tr><th>#</th><th>Category</th><th>Weight</th><th>What it checks</th><th>Findings</th></tr></thead>
  <tbody>
${AUDIT_CATEGORIES.map((cat, i) => `    <tr>
      <td>${i + 1}</td>
      <td><strong>${esc(cat.label)}</strong></td>
      <td>${cat.weight}x</td>
      <td>${esc(cat.description)}</td>
      <td>${catFindings[cat.id] || 0}</td>
    </tr>`).join('\n')}
  </tbody>
</table>

<!-- Content Area Scores -->
<div class="page-break"></div>
<h2>3. Content Area Scores</h2>

<p>The following table shows the average score for each content area, sorted from lowest (most issues) to highest. Areas scoring below 70% require priority attention.</p>

${sortedAreas.map(([id, area]) => {
  const avg = Math.round(area.scores.reduce((a, b) => a + b, 0) / area.scores.length);
  const t = tl(avg);
  return `<div class="area-row">
    <div style="flex: 1;">
      <div class="name">${esc(area.label)}</div>
      <div class="meta">${area.scores.length} items · ${area.findings} findings</div>
      <div class="bar"><div class="fill" style="width: ${Math.min(avg, 100)}%; background: ${t.color};"></div></div>
    </div>
    <div class="score" style="color: ${t.color}; min-width: 60px; text-align: right;">${avg}%</div>
  </div>`;
}).join('\n')}

<!-- Findings -->
<div class="page-break"></div>
<h2>4. Findings</h2>

<p>${findings.length} findings were identified across all content areas. Findings are issues where content scored below 90% on a specific criterion. They are listed below in order of severity (lowest score first).</p>

${findings.length === 0 ? '<p><em>No findings — all content meets standards.</em></p>' : ''}

${AUDIT_CATEGORIES.filter(cat => catFindings[cat.id]).map(cat => {
  const catFindingsList = findings.filter(f => f.category_id === cat.id);
  if (catFindingsList.length === 0) return '';
  return `
<h3>${esc(cat.label)} (${catFindingsList.length} findings)</h3>
<p style="font-size: 12px; color: #6b7280; margin-bottom: 8px;">${esc(cat.description)}</p>
${catFindingsList.map(f => {
  const score = Number(f.score);
  const t = tl(score);
  return `<div class="finding-card" style="border-color: ${t.color};">
  <div class="header">
    <span class="badge" style="background: ${t.bg}; color: ${t.color};">${Math.round(score)}%</span>
    <span class="cat">${esc(String(f.sub_criterion))}</span>
  </div>
  <div class="item-name">${esc(String(f.item_label))} <span style="font-weight: 400; color: #9ca3af; font-size: 12px;">· ${esc(String(f.content_area))}</span></div>
  <div class="desc">${esc(String(f.description))}</div>
  ${f.evidence ? `<div class="evidence">"${esc(String(f.evidence))}"</div>` : ''}
  ${f.suggested_action ? `<div class="action">→ ${esc(String(f.suggested_action))}</div>` : ''}
</div>`;
}).join('\n')}`;
}).join('\n')}

<!-- Citations -->
<div class="page-break"></div>
<h2>5. Citation Registry</h2>

<p>The audit identified ${citations.length} factual claims across all content that should be tracked and verified. These include medical claims, legal references, statistics, research citations, and historical facts. Each claim is logged for ongoing verification.</p>

<div class="stats-grid" style="grid-template-columns: repeat(5, 1fr);">
  ${['medical', 'legal', 'statistical', 'research', 'historical'].map(t => 
    `<div class="stat-card"><div class="num">${citByType[t] || 0}</div><div class="lbl">${t}</div></div>`
  ).join('\n  ')}
</div>

<div class="stats-grid" style="grid-template-columns: repeat(4, 1fr); margin-bottom: 16px;">
  ${['unverified', 'verified', 'disputed', 'stale'].map(s => {
    const colors: Record<string, string> = { unverified: '#6b7280', verified: '#16a34a', disputed: '#dc2626', stale: '#d97706' };
    return `<div class="stat-card"><div class="num" style="color: ${colors[s]}">${citByStatus[s] || 0}</div><div class="lbl">${s}</div></div>`;
  }).join('\n  ')}
</div>

${citations.slice(0, 50).map(c => `<div class="citation-row">
  <span class="type">${esc(String(c.claim_type))}</span>
  <div style="flex: 1;">
    <div>"${esc(String(c.claim_text))}"</div>
    <div style="font-size: 11px; color: #9ca3af;">${esc(String(c.content_area))} · ${esc(String(c.source_table))}</div>
  </div>
  <span class="badge" style="background: ${c.verification_status === 'verified' ? '#f0fdf4' : c.verification_status === 'disputed' ? '#fef2f2' : '#f9fafb'}; color: ${c.verification_status === 'verified' ? '#16a34a' : c.verification_status === 'disputed' ? '#dc2626' : '#6b7280'};">${esc(String(c.verification_status))}</span>
</div>`).join('\n')}
${citations.length > 50 ? `<p style="color: #9ca3af; font-style: italic;">Showing 50 of ${citations.length} citations. Full list available in the admin panel.</p>` : ''}

<!-- Footer -->
<div class="page-break"></div>
<h2>6. Recommendations</h2>

<p>Based on this audit, the following priority actions are recommended:</p>

<h4>Immediate (Critical & Red findings)</h4>
<p>${Number(run.findings_critical || 0) + Number(run.findings_red || 0) > 0 ? `${Number(run.findings_critical || 0) + Number(run.findings_red || 0)} items require immediate attention. These involve safety, clinical, or legal concerns that could impact users or fail external review.` : 'No critical or red findings — all content meets minimum safety standards.'}</p>

<h4>Short-term (Amber findings)</h4>
<p>${Number(run.findings_amber || 0) > 0 ? `${run.findings_amber} items should be reviewed and improved. These are issues that reduce content quality but do not pose immediate risk.` : 'No amber findings.'}</p>

<h4>Ongoing</h4>
<ul style="padding-left: 20px; font-size: 14px; color: #374151;">
  <li>Verify all ${citByStatus['unverified'] || 0} unverified citations with authoritative sources</li>
  <li>Re-run the audit after making corrections to track improvement</li>
  <li>Establish a regular audit cadence (recommended: before each release)</li>
</ul>

<div style="margin-top: 48px; padding-top: 16px; border-top: 1px solid #e5e7eb; font-size: 12px; color: #9ca3af;">
  <p>Generated by Below the Surface Content Audit System</p>
  <p>Audit ID: ${esc(String(run.id))} · ${auditDate}</p>
</div>

</body>
</html>`;
}
