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

    const [{ data: citations }, { data: applies }, { data: completedRuns }] =
      await Promise.all([
        supabaseAdmin.from('audit_citations').select('claim_type, verification_status'),
        supabaseAdmin.from('benchmark_applies').select('id'),
        supabaseAdmin.from('audit_runs').select('id').eq('status', 'completed'),
      ]);

    const citationsByType: Record<string, number> = {};
    for (const c of (citations || []) as CitationRow[]) {
      citationsByType[c.claim_type] = (citationsByType[c.claim_type] || 0) + 1;
    }

    const html = buildBriefHTML({
      run,
      totalCompletedRuns: (completedRuns || []).length,
      citationsByType,
      totalCitations: (citations || []).length,
      totalApplies: ((applies || []) as ApplyRow[]).length,
    });

    return new NextResponse(html, {
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
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
}

function fmtDate(iso: string | null | undefined): string {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('en-GB', {
    day: 'numeric', month: 'long', year: 'numeric',
  });
}

function buildBriefHTML(data: BriefData): string {
  const { run, totalCompletedRuns, citationsByType, totalCitations, totalApplies } = data;
  const systemScore = run?.system_score ? Number(run.system_score) : null;
  const greenCount = run?.findings_green || 0;
  const totalFindings = run?.total_findings || 0;
  const itemsScored = run?.total_items_scored || 0;

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
  <p class="meta">Prepared ${fmtDate(new Date().toISOString())} · Live extract from the content audit system</p>
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

<div class="callout">
  <strong>Safety-critical at 1.5×:</strong> ${safetyCriticalCategories.map(c => c.label).join(', ')}.
  These four categories together cover ${safetyCriticalCategories.reduce((s, c) => s + c.sub_criteria.length, 0)} sub-criteria including help-seeking pathways, diagnostic-language detection, vulnerable-user safety, crisis escalation, operational details, location references, personnel identification and pattern disclosure.
</div>

<h2>3 · Scope — every content area is audited, nothing exempt</h2>
<p>The audit covers ${CONTENT_AREAS.length} discrete content areas spanning every user-facing surface in the app:</p>
<ul class="areas-grid">
  ${CONTENT_AREAS.map(a => `<li>${a.label}</li>`).join('')}
</ul>

<div class="page-break"></div>

<h2>4 · Live snapshot — current compliance position</h2>
${
  run
    ? `
<p>Latest completed audit: <strong>${fmtDate(run.completed_at || run.started_at)}</strong>. Numbers below are drawn live from the audit database.</p>
<div class="stat-row">
  <div class="stat">
    <div class="stat-num">${systemScore !== null ? Math.round(systemScore) + '%' : '—'}</div>
    <div class="stat-label">Overall system score</div>
  </div>
  <div class="stat">
    <div class="stat-num">${itemsScored}</div>
    <div class="stat-label">Items scored</div>
  </div>
  <div class="stat">
    <div class="stat-num">${greenCount}</div>
    <div class="stat-label">Items meeting standard (90%+)</div>
  </div>
  <div class="stat">
    <div class="stat-num">${totalFindings}</div>
    <div class="stat-label">Open findings being worked</div>
  </div>
</div>

<p style="font-size:9.5pt; color:#4b5563;">
  Of ${totalFindings} findings, <strong style="color:#991b1b">${run.findings_critical || 0}</strong> are critical (under 50%, immediate action), <strong style="color:#dc2626">${run.findings_red || 0}</strong> require action (50&ndash;69%), and <strong style="color:#d97706">${run.findings_amber || 0}</strong> are recommended for review (70&ndash;89%). Each finding has a documented evidence string, an auditor-suggested action, and a workflow status (open / acknowledged / resolved / won't fix). Nothing is closed silently.
</p>
`
    : `<p style="color:#9ca3af; font-style:italic;">No completed audit run on file. The framework is in place; an audit is scheduled.</p>`
}

<h2>5 · The governance pipeline — from generation to applied fix</h2>
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

<h2>6 · MOD-specific considerations baked into the criteria</h2>
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

<h2>7 · Cadence &amp; what happens next</h2>
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
