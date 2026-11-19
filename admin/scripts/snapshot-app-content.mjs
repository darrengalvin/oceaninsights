#!/usr/bin/env node
// Snapshot the user-facing text that is hard-coded in the Flutter app (lib/),
// so the content audit can review the app as shipped, not only the database.
//
// Writes admin/src/lib/audit/evidence/app-content-snapshot.json, which the
// admin imports at build time (the Vercel deployment cannot read lib/).
// Re-run whenever app content changes:  npm run audit:snapshot

import { readFileSync, writeFileSync, readdirSync, statSync } from 'node:fs';
import { join, relative, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';
import { extractDartStrings, groupForFeature } from '../src/lib/audit/evidence/dart-strings.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(here, '..', '..');
const libDir = join(repoRoot, 'lib');
const outPath = join(here, '..', 'src', 'lib', 'audit', 'evidence', 'app-content-snapshot.json');

// Folders with no user-facing health or support content.
const SKIP = [/\/games\//, /\/theme\//, /\/providers\//, /\.g\.dart$/, /\/music\//];

function walk(dir) {
  const out = [];
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) out.push(...walk(p));
    else if (p.endsWith('.dart')) out.push(p);
  }
  return out;
}

let commit = null;
try {
  commit = execSync('git rev-parse --short HEAD', { cwd: repoRoot }).toString().trim();
} catch { /* not a git checkout */ }

const files = [];
let totalStrings = 0;
for (const abs of walk(libDir).sort()) {
  const path = relative(repoRoot, abs).split('\\').join('/');
  if (SKIP.some(r => r.test('/' + path))) continue;
  const strings = extractDartStrings(readFileSync(abs, 'utf8'));
  if (strings.length === 0) continue;
  totalStrings += strings.length;
  files.push({ path, group: groupForFeature(path), strings });
}

const snapshot = {
  generated_at: new Date().toISOString(),
  git_commit: commit,
  file_count: files.length,
  string_count: totalStrings,
  files,
};
writeFileSync(outPath, JSON.stringify(snapshot, null, 1) + '\n');
console.log(`Snapshot: ${files.length} files, ${totalStrings} strings -> ${relative(repoRoot, outPath)}`);
