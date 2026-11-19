#!/usr/bin/env node
// Run the deterministic evidence checks over the app's built-in text and the
// Supabase seed files, without the database or an API key.
//
//   npm run audit:evidence            summary of findings
//   npm run audit:evidence -- --md out.md --json out.json
//   npm run audit:recall              detection rate against the source pack's known issues
//
// The live audit (admin > Content Audit) runs the same checks over the live
// database as well; this script is for checking a branch before it ships.

import { readFileSync, writeFileSync, readdirSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { scanText, summariseHits } from '../src/lib/audit/evidence/scan.mjs';
import { computeRecall } from '../src/lib/audit/evidence/recall-cases.mjs';
import { REGISTER_REVIEWED_ON, HELPLINES } from '../src/lib/audit/evidence/registry.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(here, '..', '..');
const args = process.argv.slice(2);
const argVal = (flag) => { const i = args.indexOf(flag); return i >= 0 ? args[i + 1] : null; };
const recallMode = args.includes('--recall');
const includeSeeds = !args.includes('--app-only');

/** @type {{ source: string, location: string, text: string }[]} */
const units = [];

const snapshot = JSON.parse(readFileSync(join(here, '..', 'src', 'lib', 'audit', 'evidence', 'app-content-snapshot.json'), 'utf8'));
for (const f of snapshot.files) {
  for (const s of f.strings) units.push({ source: 'app', location: `${f.path}:${s.line}`, text: s.text });
}

if (includeSeeds) {
  const seedDir = join(repoRoot, 'supabase');
  for (const name of readdirSync(seedDir).filter(n => n.endsWith('.sql')).sort()) {
    const lines = readFileSync(join(seedDir, name), 'utf8').split('\n');
    lines.forEach((line, i) => {
      if (/^\s*(--|create|alter|drop|grant|comment)/i.test(line)) return;
      if (!/[A-Za-z]{3,} [A-Za-z]{3,}/.test(line)) return;
      units.push({ source: 'seed', location: `supabase/${name}:${i + 1}`, text: line });
    });
  }
}

const results = units.map(u => ({ ...u, hits: scanText(u.text) }));
const allHits = results.flatMap(r => r.hits.map(h => ({ ...h, location: r.location, source: r.source })));
const summary = summariseHits(allHits);

if (recallMode) {
  printRecall();
} else {
  printSummary();
}

const mdPath = argVal('--md');
const jsonPath = argVal('--json');
if (jsonPath) {
  writeFileSync(jsonPath, JSON.stringify({ generated_at: new Date().toISOString(), snapshot_commit: snapshot.git_commit, summary, hits: allHits }, null, 1));
  console.log(`\nWrote ${jsonPath}`);
}
if (mdPath) {
  writeFileSync(mdPath, renderMarkdown());
  console.log(`Wrote ${mdPath}`);
}

function printSummary() {
  console.log(`Evidence checks: ${units.length} text units (${snapshot.string_count} from the app snapshot of ${snapshot.git_commit ?? 'unknown commit'})`);
  console.log(`Helpline register: ${HELPLINES.length} services, reviewed ${REGISTER_REVIEWED_ON}`);
  console.log(`Hits: ${summary.total}  critical ${summary.bySeverity.critical}  red ${summary.bySeverity.red}  amber ${summary.bySeverity.amber}  info ${summary.bySeverity.info}\n`);
  const rows = Object.entries(summary.byRule).sort((a, b) => sevRank(a[1].severity) - sevRank(b[1].severity) || b[1].count - a[1].count);
  for (const [id, r] of rows) console.log(`${r.severity.padEnd(8)} ${String(r.count).padStart(4)}  ${r.kind.padEnd(9)} ${id}  ${r.title}`);
}

function sevRank(s) { return { critical: 0, red: 1, amber: 2, info: 3 }[s] ?? 4; }

function printRecall() {
  const r = computeRecall(results);
  const label = { detector: 'detector', detector_and_watchlist: 'detector + watchlist', watchlist: 'watchlist only', missed: 'MISSED', not_found: 'not in scanned text' };
  console.log('Detection rate against the content source pack (R1 to R23)\n');
  for (const row of r.rows) {
    console.log(`${row.id.padEnd(4)} ${label[row.status].padEnd(22)} ${row.summary}`);
    for (const l of row.locators) {
      const m = !l.found ? '  -  ' : l.detector ? ' det ' : l.watchlist ? ' wl  ' : ' MISS';
      console.log(`      [${m}] ${l.label}${l.where ? `  (${l.where})` : ''}`);
    }
  }
  console.log(`\nIssues present in the scanned text: ${r.present} of ${r.total}`);
  console.log(`Caught entirely by general detectors: ${r.by_detectors} of ${r.present}`);
  console.log(`Caught by detectors or the reviewed-claims watchlist: ${r.by_detectors_or_watchlist} of ${r.present}`);
  console.log(`Missed by the text checks: ${r.missed.join(', ') || 'none'} (left to the AI review; needs judgement: ${r.needs_judgement.join(', ')})`);
}

function renderMarkdown() {
  const lines = [];
  lines.push('# Evidence checks report', '');
  lines.push(`Generated ${new Date().toISOString().slice(0, 10)} from app snapshot ${snapshot.git_commit ?? ''} (${snapshot.string_count} strings) and Supabase seed files. Helpline register reviewed ${REGISTER_REVIEWED_ON}.`, '');
  lines.push(`Total hits ${summary.total}: critical ${summary.bySeverity.critical}, red ${summary.bySeverity.red}, amber ${summary.bySeverity.amber}, info ${summary.bySeverity.info}.`, '');
  lines.push('| Severity | Rule | Where | Text | Why | Checked against |', '|---|---|---|---|---|---|');
  for (const h of [...allHits].sort((a, b) => sevRank(a.severity) - sevRank(b.severity))) {
    if (h.severity === 'info') continue;
    const src = h.source_url ? `[${h.source_name}](${h.source_url})` : (h.source_name ?? '');
    lines.push(`| ${h.severity} | ${h.title} | ${relative('.', h.location)} | ${esc(h.context)} | ${esc(h.why)} | ${src} |`);
  }
  if (recallMode) {
    const r = computeRecall(results);
    lines.push('', '## Detection rate against the source pack', '', `${r.by_detectors_or_watchlist} of ${r.present} caught (${r.by_detectors} entirely by general detectors).`, '');
    for (const row of r.rows) lines.push(`- ${row.id} (${row.status.replace(/_/g, ' ')}): ${row.summary}`);
  }
  return lines.join('\n') + '\n';
}

function esc(s) { return String(s ?? '').replace(/\|/g, '\\|').replace(/\n/g, ' '); }
