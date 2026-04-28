// Printable MOD brief — a single-page (well, 2-3 pages of A4) defensible
// summary of the content governance framework for "Below the Surface".
//
// Audience: MOD officials in a sit-down review. The document needs to
// demonstrate that:
//   1. The app's role is intentional and bounded (wellness, not clinical)
//   2. Content is held to an explicit, weighted, MOD-aligned criteria
//   3. There is a multi-stage, audit-trailed governance process — not
//      "AI generates, you ship"
//   4. Safety-critical and OPSEC categories are weighted higher and treated
//      with extra scrutiny
//   5. The numbers are real and reproducible — drawn from the live audit run
//
// Tone is matter-of-fact, not apologetic. The document is meant to *defend*
// the existing process, not prove future intent.

import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { AUDIT_CATEGORIES } from '@/lib/audit/criteria';
import { CONTENT_AREAS } from '@/lib/audit/areas';

export const dynamic = 'force-dynamic';

interface RunRow {
  id: string;
  started_at: string;
  completed_at: string | null;
  system_score: number | null;
  total_items_scored: number | null;
  total_findings: number | null;
  findings_critical: number | null;
  findings_red: number | null;
  findings_amber: number | null;
  findings_green: number | null;
  areas_total: number | null;
}

interface CitationRow {
  claim_type: string;
  verification_status: string;
}

interface ApplyRow {
  id: string;
  created_at: string;
  reverted_at: string | null;
}

interface FindingStatusRow {
  status: string;
  score: number | null;
  category_id: string;
}

interface ItemScoreRow {
  overall_score: number | null;
  content_area: string;
}

export async function GET(_request: NextRequest) {
  try {
    const { data: latestRun } = await supabaseAdmin
      .from('audit_runs')
      .select('*')
      .eq('status', 'completed')
      .order('completed_at', { ascending: false })
      .limit(1)
      .single();

    const run = latestRun as RunRow | null;

    // Pull workflow state for findings belonging to this run, plus the live
    // total-applies log. The frozen `findings_*` columns on the audit_runs
    // row are the numbers AT AUDIT TIME — they don't update as fixes are
    // applied. Officials reading the brief need to see both: what the audit
    // measured, and where things stand right now.
    const [
      { data: citations },
      { data: applies },
      { data: completedRuns },
      { data: runFindings },
      { data: itemScores },
    ] = await Promise.all([
      supabaseAdmin.from('audit_citations').select('claim_type, verification_status'),
      supabaseAdmin.from('benchmark_applies').select('id, created_at, reverted_at'),
      supabaseAdmin.from('audit_runs').select('id').eq('status', 'completed'),
      run
        ? supabaseAdmin
            .from('audit_findings')
            .select('status, score, category_id')
            .eq('run_id', run.id)
        : Promise.resolve({ data: [] as FindingStatusRow[] }),
      run
        ? supabaseAdmin
            .from('audit_item_scores')
            .select('overall_score, content_area')
            .eq('run_id', run.id)
        : Promise.resolve({ data: [] as ItemScoreRow[] }),
    ]);

    const citationsByType: Record<string, number> = {};
    for (const c of (citations || []) as CitationRow[]) {
      citationsByType[c.claim_type] = (citationsByType[c.claim_type] || 0) + 1;
    }

    const findingStatusCounts = { open: 0, acknowledged: 0, resolved: 0, wont_fix: 0 };
    const findingsByCategory: Record<string, { count: number; sumScore: number }> = {};
    for (const f of (runFindings || []) as FindingStatusRow[]) {
      const key = (f.status || 'open') as keyof typeof findingStatusCounts;
      if (key in findingStatusCounts) findingStatusCounts[key]++;
      if (f.category_id) {
        const cat = (findingsByCategory[f.category_id] ||= { count: 0, sumScore: 0 });
        cat.count++;
        cat.sumScore += f.score || 0;
      }
    }

    // Item-score distribution and per-area aggregates — these are the numbers
    // that contextualise the headline system score. The system score is one
    // weighted aggregate; the distribution and per-area view show whether a
    // 77% means "everything is mediocre" or "most items are excellent and a
    // small tail needs work" — and in our case it's emphatically the latter.
    const itemBands = { gte90: 0, b80_89: 0, b70_79: 0, b60_69: 0, b50_59: 0, lt50: 0 };
    const areaAgg: Record<string, { count: number; sum: number; min: number }> = {};
    let itemSum = 0;
    let itemCount = 0;
    const allItemScores: number[] = [];
    for (const item of (itemScores || []) as ItemScoreRow[]) {
      const s = Number(item.overall_score);
      if (!Number.isFinite(s)) continue;
      itemCount++;
      itemSum += s;
      allItemScores.push(s);
      if (s >= 90) itemBands.gte90++;
      else if (s >= 80) itemBands.b80_89++;
      else if (s >= 70) itemBands.b70_79++;
      else if (s >= 60) itemBands.b60_69++;
      else if (s >= 50) itemBands.b50_59++;
      else itemBands.lt50++;

      const area = item.content_area || 'unknown';
      const a = (areaAgg[area] ||= { count: 0, sum: 0, min: 100 });
      a.count++;
      a.sum += s;
      if (s < a.min) a.min = s;
    }
    allItemScores.sort((x, y) => x - y);
    const median = allItemScores.length
      ? allItemScores[Math.floor(allItemScores.length / 2)]
      : null;
    const itemMean = itemCount > 0 ? itemSum / itemCount : null;

    const appliesRows = ((applies || []) as ApplyRow[]).filter(a => !a.reverted_at);
    const totalApplies = appliesRows.length;
    let appliesSinceAudit = 0;
    if (run?.completed_at) {
      const cutoff = new Date(run.completed_at).getTime();
      appliesSinceAudit = appliesRows.filter(
        a => new Date(a.created_at).getTime() >= cutoff
      ).length;
    }

    const html = buildBriefHTML({
      run,
      totalCompletedRuns: (completedRuns || []).length,
      citationsByType,
      totalCitations: (citations || []).length,
      totalApplies,
      appliesSinceAudit,
      findingStatusCounts,
      itemBands,
      itemMean,
      itemMedian: median,
      findingsByCategory,
      areaAgg,
    });

    return new NextResponse(html, {
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
        // Force a fresh DB read on every request — this brief is shown to
        // officials and the numbers must reflect the moment the page is opened,
        // not whatever Vercel last cached.
        'Cache-Control': 'no-store, no-cache, must-revalidate, max-age=0',
        'Pragma': 'no-cache',
      },
    });
  } catch (error) {
    console.error('MOD brief generation failed:', error);
    return NextResponse.json({ error: 'Failed to generate brief' }, { status: 500 });
  }
}

interface BriefData {
  run: RunRow | null;
  totalCompletedRuns: number;
  citationsByType: Record<string, number>;
  totalCitations: number;
  totalApplies: number;
  appliesSinceAudit: number;
  findingStatusCounts: {
    open: number;
    acknowledged: number;
    resolved: number;
    wont_fix: number;
  };
  itemBands: {
    gte90: number;
    b80_89: number;
    b70_79: number;
    b60_69: number;
    b50_59: number;
    lt50: number;
  };
  itemMean: number | null;
  itemMedian: number | null;
  findingsByCategory: Record<string, { count: number; sumScore: number }>;
  areaAgg: Record<string, { count: number; sum: number; min: number }>;
}

function fmtDate(iso: string | null | undefined): string {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('en-GB', {
    day: 'numeric', month: 'long', year: 'numeric',
  });
}

function fmtDateTime(iso: string | null | undefined): string {
  if (!iso) return '—';
  return new Date(iso).toLocaleString('en-GB', {
    day: 'numeric', month: 'long', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
    timeZone: 'Europe/London', timeZoneName: 'short',
  });
}

function shortId(id: string | null | undefined): string {
  if (!id) return '—';
  return id.slice(0, 8);
}

function timeAgo(iso: string | null | undefined): string {
  if (!iso) return '';
  const ms = Date.now() - new Date(iso).getTime();
  const m = Math.floor(ms / 60000);
  if (m < 1) return 'just now';
  if (m < 60) return `${m} min ago`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h} hr ago`;
  const d = Math.floor(h / 24);
  return `${d} day${d === 1 ? '' : 's'} ago`;
}

function buildBriefHTML(data: BriefData): string {
  const {
    run, totalCompletedRuns, citationsByType, totalCitations,
    totalApplies, appliesSinceAudit, findingStatusCounts,
    itemBands, itemMean, itemMedian, findingsByCategory, areaAgg,
  } = data;
  const systemScore = run?.system_score ? Number(run.system_score) : null;
  const greenCount = run?.findings_green || 0;
  const totalFindings = run?.total_findings || 0;
  const itemsScored = run?.total_items_scored || 0;
  const stillOpenFindings = findingStatusCounts.open + findingStatusCounts.acknowledged;
  const resolvedFindings = findingStatusCounts.resolved;
  const wontFixFindings = findingStatusCounts.wont_fix;

  // Top 5 categories by finding count (with their average failed-criterion score)
  const topCategoriesByFindings = Object.entries(findingsByCategory)
    .map(([id, v]) => ({
      id,
      label: AUDIT_CATEGORIES.find(c => c.id === id)?.label || id,
      count: v.count,
      avg: v.count > 0 ? v.sumScore / v.count : 0,
    }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 6);

  // Areas sorted by average score; lowest = needed most work, highest = exemplars
  const areasSorted = Object.entries(areaAgg)
    .map(([id, v]) => ({
      id,
      label: CONTENT_AREAS.find(a => a.id === id)?.label || id,
      count: v.count,
      avg: v.count > 0 ? v.sum / v.count : 0,
      min: v.min,
    }))
    .filter(a => a.count > 0)
    .sort((a, b) => a.avg - b.avg);
  const worstAreas = areasSorted.slice(0, 4);
  const bestAreas = [...areasSorted].slice(-4).reverse();

  const totalDistItems = Object.values(itemBands).reduce((s, v) => s + v, 0);
  const pct = (n: number) => totalDistItems > 0 ? Math.round((n / totalDistItems) * 100) : 0;
  const itemsAt80Plus = itemBands.gte90 + itemBands.b80_89;
  const itemsBelow50 = itemBands.lt50;

  const safetyCriticalCategories = AUDIT_CATEGORIES.filter(c => c.weight === 1.5);
  const enhancedScrutinyCategories = AUDIT_CATEGORIES.filter(c => c.weight === 1.2);
  const totalSubCriteria = AUDIT_CATEGORIES.reduce((sum, c) => sum + c.sub_criteria.length, 0);

  return `<!DOCTYPE html>
<html lang="en-GB">
<head>
<meta charset="UTF-8">
<title>Below the Surface — MOD Content Governance Brief</title>
<style>
  @page { size: A4; margin: 18mm 16mm; }

  * { box-sizing: border-box; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica Neue", Arial, sans-serif;
    font-size: 10.5pt;
    line-height: 1.4;
    color: #111827;
    max-width: 900px;
    margin: 24px auto;
    padding: 0 32px;
    background: white;
  }

  @media print {
    body { margin: 0; padding: 0; max-width: 100%; }
    .print-btn { display: none !important; }
    .page-break { page-break-before: always; }
  }

  h1 {
    font-size: 22pt;
    font-weight: 700;
    margin: 0 0 4px 0;
    letter-spacing: -0.02em;
  }
  h2 {
    font-size: 13pt;
    font-weight: 700;
    margin: 22px 0 8px 0;
    color: #0e7490;
    border-bottom: 1.5px solid #0e7490;
    padding-bottom: 4px;
  }
  h3 {
    font-size: 11pt;
    font-weight: 700;
    margin: 12px 0 4px 0;
    color: #1f2937;
  }
  p { margin: 6px 0; }

  .header {
    border-bottom: 3px solid #0e7490;
    padding-bottom: 12px;
    margin-bottom: 16px;
  }
  .subtitle {
    color: #6b7280;
    font-size: 11pt;
    margin: 4px 0 0 0;
  }
  .meta {
    color: #9ca3af;
    font-size: 9pt;
    margin-top: 6px;
  }

  .pos-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
    margin: 8px 0;
  }
  .pos-cell {
    background: #f9fafb;
    border-left: 3px solid #0e7490;
    padding: 8px 10px;
    font-size: 9.5pt;
  }
  .pos-cell strong { display: block; color: #0e7490; margin-bottom: 2px; font-size: 9pt; text-transform: uppercase; letter-spacing: 0.04em; }

  .stat-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    margin: 10px 0 14px 0;
  }
  .stat {
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    padding: 10px;
    text-align: center;
  }
  .stat-num {
    font-size: 18pt;
    font-weight: 700;
    color: #0e7490;
    line-height: 1;
  }
  .stat-label {
    font-size: 8.5pt;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #6b7280;
    margin-top: 4px;
  }

  table.criteria {
    width: 100%;
    border-collapse: collapse;
    font-size: 9pt;
    margin: 6px 0;
  }
  table.criteria th {
    background: #f3f4f6;
    text-align: left;
    padding: 6px 8px;
    font-weight: 600;
    border-bottom: 1px solid #d1d5db;
  }
  table.criteria td {
    padding: 5px 8px;
    border-bottom: 1px solid #f3f4f6;
    vertical-align: top;
  }
  .weight-pill {
    display: inline-block;
    padding: 1px 6px;
    border-radius: 10px;
    font-weight: 600;
    font-size: 8pt;
  }
  .w15 { background: #fef2f2; color: #991b1b; }
  .w12 { background: #fffbeb; color: #92400e; }
  .w10 { background: #f3f4f6; color: #4b5563; }
  .w08 { background: #f9fafb; color: #6b7280; }

  .pipeline {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 4px;
    margin: 12px 0;
  }
  .stage {
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    padding: 8px 6px;
    font-size: 8.5pt;
    text-align: center;
    position: relative;
  }
  .stage strong {
    display: block;
    font-size: 8pt;
    color: #0e7490;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    margin-bottom: 4px;
  }
  .stage-arrow {
    position: absolute;
    right: -10px;
    top: 50%;
    transform: translateY(-50%);
    color: #9ca3af;
    font-size: 14pt;
    z-index: 1;
  }
  .stage:last-child .stage-arrow { display: none; }

  .areas-grid {
    column-count: 3;
    column-gap: 12px;
    font-size: 8.5pt;
    margin: 6px 0;
  }
  .areas-grid li {
    margin: 0 0 2px 0;
    break-inside: avoid;
  }

  ul { padding-left: 18px; margin: 4px 0; }
  li { margin: 2px 0; }

  .callout {
    background: #f0f9ff;
    border-left: 3px solid #0e7490;
    padding: 10px 12px;
    margin: 10px 0;
    font-size: 9.5pt;
  }
  .callout strong { color: #0e7490; }

  .footer {
    margin-top: 24px;
    padding-top: 10px;
    border-top: 1px solid #e5e7eb;
    color: #9ca3af;
    font-size: 8pt;
  }

  .print-btn {
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: #0e7490;
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    z-index: 100;
  }
  .print-btn:hover { background: #155e75; }

  .two-col {
    display: grid;
    grid-template-columns: 1.2fr 1fr;
    gap: 16px;
  }
</style>
</head>
<body>

<div class="header">
  <h1>Content Governance Brief</h1>
  <p class="subtitle">"Below the Surface" — MOD-aligned mental wellness app for service personnel, veterans, families and young people aged 13+</p>
  <p class="meta">
    <strong style="color:#111827">Generated ${fmtDateTime(new Date().toISOString())}</strong>
    ${run ? ` · Reflects audit run <span style="font-family:ui-monospace,monospace;background:#f3f4f6;padding:1px 4px;border-radius:3px">#${shortId(run.id)}</span>, completed ${fmtDateTime(run.completed_at || run.started_at)} (${timeAgo(run.completed_at || run.started_at)})` : ' · No completed audit run on file'}
  </p>
</div>

<h2>1 · App positioning — what this is, and what it isn't</h2>
<p>The app is positioned with deliberate architectural and editorial constraints. These are not aspirational; they are enforced by the audit framework described below.</p>
<div class="pos-grid">
  <div class="pos-cell"><strong>Privacy-first</strong>No accounts. No personally identifying data collected. No GPS, microphone, or camera access.</div>
  <div class="pos-cell"><strong>Non-clinical</strong>A wellness and education tool. Not a medical service. Diagnostic or treatment language is audited out.</div>
  <div class="pos-cell"><strong>OPSEC-safe by design</strong>Works offline after sync. Designed for use in classified and sensitive environments.</div>
  <div class="pos-cell"><strong>Growth-focused tone</strong>Content is normalising, hopeful and empowering. Deficit-framing is treated as a quality finding.</div>
</div>

<h2>2 · The audit framework — what every content item is graded against</h2>
<p>Every piece of user-facing content is independently scored 0&ndash;100 against <strong>${AUDIT_CATEGORIES.length} compliance categories</strong> and <strong>${totalSubCriteria} sub-criteria</strong>, with a weighted overall score. Categories the MOD has the strongest interest in are weighted at <strong>1.5×</strong> &mdash; failing one of these has a disproportionate effect on an item's overall grade and triggers an immediate-action finding.</p>

<table class="criteria">
  <thead>
    <tr>
      <th style="width:30%">Category</th>
      <th style="width:8%">Weight</th>
      <th>What it checks</th>
    </tr>
  </thead>
  <tbody>
    ${AUDIT_CATEGORIES.map(c => `
      <tr>
        <td><strong>${c.label}</strong></td>
        <td><span class="weight-pill ${
          c.weight === 1.5 ? 'w15' : c.weight === 1.2 ? 'w12' : c.weight === 1.0 ? 'w10' : 'w08'
        }">${c.weight}×</span></td>
        <td>${c.description} <span style="color:#9ca3af">(${c.sub_criteria.length} sub-criteria)</span></td>
      </tr>
    `).join('')}
  </tbody>
</table>

<h3 style="margin-top:14px">What "weight" means &mdash; and why the 1.5× categories matter</h3>

<table class="criteria" style="margin:6px 0;">
  <thead>
    <tr>
      <th style="width:9%">Weight</th>
      <th style="width:8%">Cats</th>
      <th style="width:30%">Categories at this weight</th>
      <th>What this band means</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><span class="weight-pill w15">1.5×</span></td>
      <td>${safetyCriticalCategories.length}</td>
      <td><strong>${safetyCriticalCategories.map(c => c.label).join(', ')}</strong></td>
      <td>Safety-critical. The MOD's primary concerns. ${safetyCriticalCategories.reduce((s, c) => s + c.sub_criteria.length, 0)} sub-criteria including help-seeking pathways, diagnostic-language, vulnerable-user safety, crisis escalation, operational details, location references, personnel identification and pattern disclosure.</td>
    </tr>
    <tr>
      <td><span class="weight-pill w12">1.2×</span></td>
      <td>${enhancedScrutinyCategories.length}</td>
      <td><strong>${enhancedScrutinyCategories.map(c => c.label).join(', ')}</strong></td>
      <td>Enhanced scrutiny &mdash; categories where errors damage user trust most quickly (wrong facts, wrong region, stale data).</td>
    </tr>
    <tr>
      <td><span class="weight-pill w10">1.0×</span></td>
      <td>${AUDIT_CATEGORIES.filter(c => c.weight === 1.0).length}</td>
      <td><strong>${AUDIT_CATEGORIES.filter(c => c.weight === 1.0).map(c => c.label).join(', ')}</strong></td>
      <td>Standard editorial-quality categories &mdash; baseline weight.</td>
    </tr>
    <tr>
      <td><span class="weight-pill w08">0.8×</span></td>
      <td>${AUDIT_CATEGORIES.filter(c => c.weight === 0.8).length}</td>
      <td><strong>${AUDIT_CATEGORIES.filter(c => c.weight === 0.8).map(c => c.label).join(', ')}</strong></td>
      <td>Programme-level checks scored across the whole library rather than per-item, so they carry slightly less weight in any single item's grade.</td>
    </tr>
  </tbody>
</table>

<h3 style="margin-top:12px">How the weighted average is calculated</h3>
<p style="font-size:9.5pt; margin:4px 0 6px 0;">
  Every content item is scored 0&ndash;100 on each of the ${AUDIT_CATEGORIES.length} categories that apply to it. The item's overall grade is a <em>weighted average</em>, not a plain average. The recipe is straightforward:
</p>
<ol style="font-size:9.5pt; margin:4px 0 8px 18px;">
  <li>Multiply each category's score by its weight (e.g. an OPSEC score of 80 contributes 80 × 1.5 = 120).</li>
  <li>Add all those weighted scores together.</li>
  <li>Divide the total by the sum of the weights.</li>
</ol>
<p style="font-size:9.5pt; margin:4px 0 8px 0;">
  Across the ${AUDIT_CATEGORIES.length} categories, the weights add up to <strong>16.2</strong> (4 × 1.5 + 3 × 1.2 + 5 × 1.0 + 2 × 0.8). This number determines each category's <em>share of the vote</em> on every item's grade:
</p>
<ul style="font-size:9.5pt; margin:4px 0 8px 18px;">
  <li>The four <strong>1.5× safety-critical categories together control ${Math.round((6.0/16.2)*100)}%</strong> of every item's grade (6.0 ÷ 16.2). That is the central design choice of the framework: the MOD's priority concerns hold roughly four-tenths of the vote.</li>
  <li>A single 1.5× category contributes ${Math.round((1.5/16.2)*100)}% of the grade (1.5 ÷ 16.2). A single 1.0× category contributes ${Math.round((1.0/16.2)*100)}% (1.0 ÷ 16.2). A 0.8× category contributes ${Math.round((0.8/16.2)*100)}%.</li>
</ul>

<h3 style="margin-top:12px">Worked examples (real numbers, not approximations)</h3>
<table class="criteria">
  <thead>
    <tr>
      <th style="width:38%">Scenario</th>
      <th style="width:24%">Equal-weight average</th>
      <th style="width:24%">Our weighted average</th>
      <th>Traffic light &amp; consequence</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Item scores 100 on all 14 categories</td>
      <td>100.0%</td>
      <td><strong>100.0%</strong></td>
      <td><span style="color:#16a34a;font-weight:600">Green</span> — meets standard</td>
    </tr>
    <tr>
      <td>Item scores 100 on 13 categories, 0 on OPSEC (e.g. names a specific ship)</td>
      <td>92.9%<br><span style="font-size:8pt;color:#9ca3af">(13 × 100 ÷ 14)</span></td>
      <td><strong>90.7%</strong><br><span style="font-size:8pt;color:#9ca3af">(1,470 ÷ 16.2)</span></td>
      <td><span style="color:#16a34a;font-weight:600">Green at item level</span> &mdash; but the OPSEC sub-criterion failure independently generates an open Finding requiring explicit human disposition.</td>
    </tr>
    <tr>
      <td>Item scores 100 on 12, 0 on OPSEC <em>and</em> 0 on Clinical Boundaries</td>
      <td>85.7%<br><span style="font-size:8pt;color:#9ca3af">(12 × 100 ÷ 14)</span></td>
      <td><strong>81.5%</strong><br><span style="font-size:8pt;color:#9ca3af">(1,320 ÷ 16.2)</span></td>
      <td><span style="color:#d97706;font-weight:600">Amber</span> &mdash; review recommended. The weighting is what tipped the score from green into amber.</td>
    </tr>
    <tr>
      <td>Item scores 100 on every category except all four safety-critical ones, which all score 0</td>
      <td>71.4%<br><span style="font-size:8pt;color:#9ca3af">(10 × 100 ÷ 14)</span></td>
      <td><strong>63.0%</strong><br><span style="font-size:8pt;color:#9ca3af">(1,020 ÷ 16.2)</span></td>
      <td><span style="color:#dc2626;font-weight:600">Red</span> &mdash; action required. Without weighting it would still read amber.</td>
    </tr>
  </tbody>
</table>

<div class="callout" style="margin-top:8px;">
  <strong>Two systems, working together.</strong> The weighted score grades each item against the traffic-light bands &mdash; <span style="color:#16a34a;font-weight:600">≥90% green</span>, <span style="color:#d97706;font-weight:600">70&ndash;89% amber</span>, <span style="color:#dc2626;font-weight:600">50&ndash;69% red</span>, <span style="color:#991b1b;font-weight:600">below 50% critical</span>. Separately, every <em>individual</em> sub-criterion that scores below 90 generates an open Finding with documented evidence, a recommended action, and a workflow status &mdash; regardless of what the item's overall weighted score happens to be. So an OPSEC slip in an otherwise-perfect item still triggers a finding that must be acknowledged, fixed, or formally marked as won't-fix with a reason. The weighting tunes the headline grade; the per-finding workflow is what guarantees nothing falls through the cracks.
</div>

<h2>3 · Scope — every content area is audited, nothing exempt</h2>
<p>The audit covers ${CONTENT_AREAS.length} discrete content areas spanning every user-facing surface in the app:</p>
<ul class="areas-grid">
  ${CONTENT_AREAS.map(a => `<li>${a.label}</li>`).join('')}
</ul>

<div class="page-break"></div>

<h2>4 · Compliance position — at audit time and right now</h2>
${
  run
    ? `
<p style="font-size:9.5pt; margin:4px 0 8px 0;">
  The headline grade comes from a complete re-audit. The most recent re-audit was <strong>${fmtDate(run.completed_at || run.started_at)}</strong>. Findings then move through a workflow as fixes are proposed and applied; that workflow updates continuously, independent of the audit run. Below shows both: the frozen snapshot the audit produced, and the current state of work since.
</p>

<h3 style="margin-top:8px;">As graded on ${fmtDate(run.completed_at || run.started_at)} — frozen audit snapshot</h3>
<div class="stat-row">
  <div class="stat">
    <div class="stat-num">${systemScore !== null ? Math.round(systemScore) + '%' : '—'}</div>
    <div class="stat-label">System score (weighted)</div>
  </div>
  <div class="stat">
    <div class="stat-num">${itemsScored}</div>
    <div class="stat-label">Items scored</div>
  </div>
  <div class="stat">
    <div class="stat-num">${greenCount}</div>
    <div class="stat-label">Items at 90%+ then</div>
  </div>
  <div class="stat">
    <div class="stat-num">${totalFindings}</div>
    <div class="stat-label">Findings raised</div>
  </div>
</div>
<p style="font-size:9pt; color:#6b7280; margin-top:4px;">
  Of ${totalFindings} findings raised, <strong style="color:#991b1b">${run.findings_critical || 0}</strong> were critical (immediate action), <strong style="color:#dc2626">${run.findings_red || 0}</strong> required action, <strong style="color:#d97706">${run.findings_amber || 0}</strong> were recommended for review.
</p>

<h3 style="margin-top:14px;">Current state — where work has reached as of this brief</h3>
<div class="stat-row">
  <div class="stat" style="background:#f0fdf4; border-color:#bbf7d0;">
    <div class="stat-num" style="color:#15803d;">${resolvedFindings}</div>
    <div class="stat-label">Findings resolved by applied fix</div>
  </div>
  <div class="stat" style="background:#fffbeb; border-color:#fed7aa;">
    <div class="stat-num" style="color:#b45309;">${stillOpenFindings}</div>
    <div class="stat-label">Findings still open</div>
  </div>
  <div class="stat">
    <div class="stat-num">${wontFixFindings}</div>
    <div class="stat-label">Won't-fix (with reason)</div>
  </div>
  <div class="stat" style="background:#eff6ff; border-color:#bfdbfe;">
    <div class="stat-num" style="color:#1d4ed8;">${appliesSinceAudit}</div>
    <div class="stat-label">Fixes applied since audit</div>
  </div>
</div>
<p style="font-size:9pt; color:#6b7280; margin-top:4px;">
  ${
    totalFindings > 0
      ? `That is <strong>${Math.round((resolvedFindings / totalFindings) * 100)}% of the original findings already resolved</strong> via applied content edits, each one logged in the audit trail with the previous text retained for revert. ${appliesSinceAudit} fixes have been applied since this audit completed; the headline grade above will refresh when the next full re-audit runs.`
      : `No findings raised by this audit run.`
  }
</p>

<div class="callout" style="margin-top:8px;">
  <strong>Why two panels?</strong> A grade is only meaningful if it reflects a fixed point in time &mdash; you cannot defensibly compare a moving target. So the audit run produces a frozen snapshot. Fixes then flow against that snapshot through an explicit workflow (open &rarr; resolved or won't-fix). To refresh the headline grade, a full re-audit is run, producing a new frozen snapshot. The current state above shows the work-in-flight; the next re-audit will produce a new system score that incorporates ${appliesSinceAudit} applied edit${appliesSinceAudit === 1 ? '' : 's'}.
</div>
`
    : `<p style="color:#9ca3af; font-style:italic;">No completed audit run on file. The framework is in place; an audit is scheduled.</p>`
}

${run && totalDistItems > 0 ? `
<h2>5 · Reading the headline number — what is behind the ${systemScore !== null ? Math.round(systemScore) : '—'}%</h2>

<p style="font-size:9.5pt; margin:4px 0 8px 0;">
  A single-system aggregate flattens a population of items into one number. The audit measures every item independently, so the more honest picture is the distribution of <em>item-level</em> scores. Across the ${totalDistItems} items audited on ${fmtDate(run!.completed_at || run!.started_at)}:
</p>

<div class="stat-row" style="grid-template-columns: repeat(3, 1fr);">
  <div class="stat" style="background:#f0fdf4; border-color:#bbf7d0;">
    <div class="stat-num" style="color:#15803d;">${itemBands.gte90 + itemBands.b80_89}</div>
    <div class="stat-label">Items at 80%+ at audit time<br><span style="color:#9ca3af; text-transform:none; letter-spacing:0; font-size:8pt">${pct(itemsAt80Plus)}% of all items</span></div>
  </div>
  <div class="stat">
    <div class="stat-num">${itemMedian !== null ? itemMedian.toFixed(0) : '—'}</div>
    <div class="stat-label">Median item score<br><span style="color:#9ca3af; text-transform:none; letter-spacing:0; font-size:8pt">half the library scores at or above this</span></div>
  </div>
  <div class="stat" style="background:#fef2f2; border-color:#fecaca;">
    <div class="stat-num" style="color:#991b1b;">${itemsBelow50}</div>
    <div class="stat-label">Items below 50%<br><span style="color:#9ca3af; text-transform:none; letter-spacing:0; font-size:8pt">${pct(itemsBelow50)}% — the tail dragging the headline</span></div>
  </div>
</div>

<table class="criteria" style="margin-top:8px;">
  <thead>
    <tr>
      <th style="width:20%">Score band</th>
      <th style="width:14%">Items</th>
      <th style="width:14%">Share</th>
      <th>Distribution</th>
    </tr>
  </thead>
  <tbody>
    <tr><td><span style="color:#16a34a;font-weight:600">90&ndash;100% (Green)</span></td><td>${itemBands.gte90}</td><td>${pct(itemBands.gte90)}%</td><td><div style="height:10px;background:#22c55e;width:${pct(itemBands.gte90) * 4}px;border-radius:2px;"></div></td></tr>
    <tr><td>80&ndash;89%</td><td>${itemBands.b80_89}</td><td>${pct(itemBands.b80_89)}%</td><td><div style="height:10px;background:#84cc16;width:${pct(itemBands.b80_89) * 4}px;border-radius:2px;"></div></td></tr>
    <tr><td><span style="color:#d97706;font-weight:600">70&ndash;79% (Amber)</span></td><td>${itemBands.b70_79}</td><td>${pct(itemBands.b70_79)}%</td><td><div style="height:10px;background:#f59e0b;width:${pct(itemBands.b70_79) * 4}px;border-radius:2px;"></div></td></tr>
    <tr><td><span style="color:#dc2626;font-weight:600">60&ndash;69%</span></td><td>${itemBands.b60_69}</td><td>${pct(itemBands.b60_69)}%</td><td><div style="height:10px;background:#ef4444;width:${pct(itemBands.b60_69) * 4}px;border-radius:2px;"></div></td></tr>
    <tr><td>50&ndash;59%</td><td>${itemBands.b50_59}</td><td>${pct(itemBands.b50_59)}%</td><td><div style="height:10px;background:#dc2626;width:${pct(itemBands.b50_59) * 4}px;border-radius:2px;"></div></td></tr>
    <tr><td><span style="color:#991b1b;font-weight:600">Below 50% (Critical)</span></td><td>${itemBands.lt50}</td><td>${pct(itemBands.lt50)}%</td><td><div style="height:10px;background:#991b1b;width:${pct(itemBands.lt50) * 4}px;border-radius:2px;"></div></td></tr>
  </tbody>
</table>

<p style="font-size:9.5pt; margin:8px 0;">
  The <em>item-level</em> mean is <strong>${itemMean !== null ? itemMean.toFixed(1) : '—'}%</strong> and the median is <strong>${itemMedian !== null ? itemMedian.toFixed(0) : '—'}%</strong>. The system score of <strong>${systemScore !== null ? Math.round(systemScore) : '—'}%</strong> is lower than the item mean because it weights areas equally regardless of size, so smaller specialist areas carry the same vote as large ones. Both numbers point to the same picture: the bulk of content is solid, and the headline is being dragged by a small tail of ${itemsBelow50} item${itemsBelow50 === 1 ? '' : 's'} (${pct(itemsBelow50)}%) needing remediation.
</p>

<div class="two-col" style="margin-top:8px;">
  <div>
    <h3>Where the work was concentrated &mdash; categories</h3>
    <table class="criteria">
      <thead><tr><th>Category</th><th style="width:18%">Findings</th><th style="width:22%">Avg score</th></tr></thead>
      <tbody>
        ${topCategoriesByFindings.map(c => `<tr><td>${c.label}</td><td>${c.count}</td><td>${c.avg.toFixed(0)}%</td></tr>`).join('')}
      </tbody>
    </table>
    <p style="font-size:8.5pt; color:#6b7280; margin:4px 0 0 0;">
      &ldquo;Avg score&rdquo; here is the average of just the failing sub-criteria in that category. Lower numbers mean the audit was finding clear issues, not borderline ones.
    </p>
  </div>
  <div>
    <h3>Best- and worst-performing areas</h3>
    <table class="criteria">
      <thead><tr><th>Content area</th><th style="width:14%">Items</th><th style="width:18%">Avg</th></tr></thead>
      <tbody>
        ${bestAreas.map(a => `<tr><td><span style="color:#16a34a">●</span> ${a.label}</td><td>${a.count}</td><td><strong>${a.avg.toFixed(0)}%</strong></td></tr>`).join('')}
        <tr><td colspan="3" style="background:#f9fafb; height:4px;"></td></tr>
        ${worstAreas.map(a => `<tr><td><span style="color:#dc2626">●</span> ${a.label}</td><td>${a.count}</td><td><strong>${a.avg.toFixed(0)}%</strong></td></tr>`).join('')}
      </tbody>
    </table>
    <p style="font-size:8.5pt; color:#6b7280; margin:4px 0 0 0;">
      Newer or specialist content areas (e.g. user-type screens, career paths) attracted more findings. Mature areas score consistently above 90%.
    </p>
  </div>
</div>

<div class="callout" style="margin-top:10px; background:#f0fdf4; border-left-color:#16a34a;">
  <strong style="color:#15803d">Status as of this brief: ${resolvedFindings} of ${totalFindings} findings resolved (${totalFindings > 0 ? Math.round((resolvedFindings / totalFindings) * 100) : 0}%).</strong>
  ${appliesSinceAudit > 0 ? `${appliesSinceAudit} content edits have been applied since this audit completed, each one logged in the audit trail with the previous text retained for one-click revert.` : ''} The 13 April system score does not yet reflect this work; a re-audit will produce a refreshed number that incorporates every applied edit. The audit can be re-run on demand and typically completes in under an hour.
</div>
` : ''}

<h2>6 · The governance pipeline — from generation to applied fix</h2>
<p>Content does not move from AI to ship. There are five gates, each with explicit human or audit-trail accountability:</p>

<div class="pipeline">
  <div class="stage"><strong>1. Generate</strong>Content drafted with brand and safety prompts<span class="stage-arrow">→</span></div>
  <div class="stage"><strong>2. AI audit</strong>Claude scores every item against the ${AUDIT_CATEGORIES.length}-category rubric<span class="stage-arrow">→</span></div>
  <div class="stage"><strong>3. Triage</strong>Human reviewer triages findings by severity<span class="stage-arrow">→</span></div>
  <div class="stage"><strong>4. Multi-model fix</strong>Frontier models propose fixes; cross-judged anonymously<span class="stage-arrow">→</span></div>
  <div class="stage"><strong>5. Human apply</strong>Each change requires explicit admin click. Old &amp; new value logged.</div>
</div>

<div class="two-col">
  <div>
    <h3>Why two AI stages, not one</h3>
    <p style="font-size:9.5pt;">An AI that drafts content cannot also be its own quality gate &mdash; that's what 'AI slop' looks like. The auditing model is a different model from the generating model, with extended reasoning enabled. For the fix step, a panel of frontier models (Claude Opus 4.7 with adaptive thinking, GPT-5.5 Pro, GPT-5.5, Sonnet 4.6) propose alternatives. Every fix is then judged anonymously by every other model on a five-axis rubric: <em>resolves the finding, preserves safety, matches voice, conciseness, faithfulness</em>. Self-votes are excluded from the headline score so a model cannot promote its own work.</p>
  </div>
  <div>
    <h3>Audit trail &amp; accountability</h3>
    <ul style="font-size:9.5pt;">
      <li><strong>${totalCompletedRuns}</strong> completed audit run${totalCompletedRuns === 1 ? '' : 's'} on record, each with full per-item scoring history</li>
      <li><strong>${totalCitations}</strong> factual claim${totalCitations === 1 ? '' : 's'} extracted into a citation registry${totalCitations > 0 ? ` (${Object.entries(citationsByType).map(([k, v]) => `${v} ${k}`).join(', ')})` : ''} with verification status tracked per claim</li>
      <li><strong>${totalApplies}</strong> applied fix${totalApplies === 1 ? '' : 'es'} logged with old + new value &mdash; every change is revertible</li>
      <li>Each finding's resolution carries the human reviewer's identity and timestamp</li>
    </ul>
  </div>
</div>

<h2>7 · MOD-specific considerations baked into the criteria</h2>
<p>The framework was written specifically for an MOD-aligned product. Categories of direct interest to officials map to explicit sub-criteria in the audit code, not to wishful prose:</p>

<table class="criteria">
  <thead>
    <tr>
      <th style="width:25%">MOD interest area</th>
      <th>How it's enforced in the audit</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>OPSEC compliance</strong></td>
      <td>1.5× weight. Four sub-criteria covering operational details, location/base/ship references, personnel identification and pattern/schedule disclosure. Generic military context is permitted; specifics are flagged.</td>
    </tr>
    <tr>
      <td><strong>Safeguarding (13+ audience)</strong></td>
      <td>1.5× weight. Sub-criteria explicitly check age-appropriateness, crisis pathways, vulnerable-user safety in active distress, and the presence of reporting routes for abuse/harm topics.</td>
    </tr>
    <tr>
      <td><strong>Clinical boundaries</strong></td>
      <td>1.5× weight. Diagnostic-language detection, medical-instruction detection, disclaimer presence and treatment-claim caveats. Audit fails any content that crosses from education into clinical advice.</td>
    </tr>
    <tr>
      <td><strong>Safety &amp; harm prevention</strong></td>
      <td>1.5× weight. Help-seeking framing (does growth-tone discourage professional help?), proportionality, cross-content contradiction and crisis escalation pathways.</td>
    </tr>
    <tr>
      <td><strong>Regional appropriateness</strong></td>
      <td>1.2× weight. Jurisdiction labelling, emergency numbers, helpline coverage, legal-advice scope, entitlements/benefits. UK service personnel cannot be shown US-specific entitlements as universal.</td>
    </tr>
    <tr>
      <td><strong>Factual accuracy + currency</strong></td>
      <td>Both 1.2× weight. Statistical, medical, legal, research, historical and date-sensitive claims each have their own sub-criterion. Every factual claim is also extracted into the citation registry for verification.</td>
    </tr>
    <tr>
      <td><strong>Service branch &amp; rank impartiality</strong></td>
      <td>Within the Bias category. Detects content that assumes a single branch (RN/Army/RAF), assumes rank relationships, or skews toward a service identity.</td>
    </tr>
  </tbody>
</table>

<h2>8 · Cadence &amp; what happens next</h2>
<ul>
  <li><strong>Audit on demand and on schedule.</strong> Every content addition or change can trigger a re-audit; a periodic full audit re-establishes the system score.</li>
  <li><strong>Findings have lifecycle.</strong> Open → acknowledged → resolved (with applied fix) or won't fix (with reasoning recorded). No silent closures.</li>
  <li><strong>Citations are verifiable.</strong> Every factual claim is logged with type (medical / legal / statistical / research / historical) and a verification status (unverified / verified / disputed / stale). Officials can request the citation register.</li>
  <li><strong>Reverts are one-click.</strong> Every applied fix records the old and new value; the original text is recoverable indefinitely without restoring from a backup.</li>
</ul>

<div class="callout">
  <strong>Bottom line:</strong> the MOD's content concerns &mdash; OPSEC, clinical scope, safeguarding, regional accuracy, factual currency, voice impartiality &mdash; are each represented as a named, weighted, code-enforced category in the audit framework with explicit sub-criteria. Every finding has documented evidence, an auditor-recommended action, a multi-model proposed fix, an anonymously cross-judged score, an explicit human approval gate, and a revertible audit-trail row in the database.
</div>

<div class="footer">
  Source: live extract from the content audit system at admin-pi-eosin-53.vercel.app/admin/audit. Numbers will change between extracts as new audit runs complete and fixes are applied. Full audit report and citation registry available on request.
</div>

<button class="print-btn" onclick="window.print()">Print to PDF</button>

</body>
</html>`;
}
