// GET /api/audit/evidence
//
// The evidence register in one response: the trusted-source list, the
// verified helpline register, the check rules, and a live run of the
// deterministic evidence checks over the live database and the text built
// into the app. No AI is involved, so this is fast, free and repeatable.
//
//   ?format=csv   every flag as a CSV, for the evidence pack

import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { CONTENT_AREAS } from '@/lib/audit/areas';
import { isAppContentArea, APP_CONTENT_AREAS } from '@/lib/audit/app-areas';
import { appSnapshotFiles, appSnapshotInfo } from '@/lib/audit/app-content';
import { extractContentArea } from '@/lib/audit/extractor';
import { scanItem, itemText, type EvidenceHit } from '@/lib/audit/evidence';
import { scanText, summariseHits } from '@/lib/audit/evidence/scan.mjs';
import { HELPLINES, RETIRED_SERVICES, TRUSTED_SOURCES, TIER_LABELS, REGISTER_REVIEWED_ON } from '@/lib/audit/evidence/registry.mjs';
import { TEXT_RULES } from '@/lib/audit/evidence/rules.mjs';
import { computeRecall } from '@/lib/audit/evidence/recall-cases.mjs';
import { AUDIT_MODEL_LABEL } from '@/lib/audit/claude';

export const dynamic = 'force-dynamic';
export const maxDuration = 120;

interface LocatedHit extends EvidenceHit {
  source: 'app' | 'database';
  area: string;
  location: string;
}

export async function GET(request: NextRequest) {
  const format = request.nextUrl.searchParams.get('format');
  const units: { location: string; text: string; hits: EvidenceHit[] }[] = [];
  const hits: LocatedHit[] = [];

  // 1. Text built into the app (from the build-time snapshot).
  const groupToArea = new Map<string, string>();
  for (const a of APP_CONTENT_AREAS) for (const g of a.groups) groupToArea.set(g, a.label);
  for (const file of appSnapshotFiles()) {
    for (const s of file.strings) {
      const h = scanText(s.text) as EvidenceHit[];
      const location = `${file.path}:${s.line}`;
      units.push({ location, text: s.text, hits: h });
      for (const x of h) hits.push({ ...x, source: 'app', area: groupToArea.get(file.group) ?? 'App: other', location });
    }
  }

  // 2. The live database, area by area.
  const dbErrors: string[] = [];
  let dbItems = 0;
  for (const area of CONTENT_AREAS.filter(a => !isAppContentArea(a.id))) {
    try {
      const extracted = await extractContentArea(supabaseAdmin, area.id);
      for (const item of extracted?.items ?? []) {
        dbItems++;
        const h = scanItem(item);
        const location = `${item.source_table}:${item.id} (${item.label})`;
        units.push({ location, text: itemText(item), hits: h });
        for (const x of h) hits.push({ ...x, source: 'database', area: area.label, location });
      }
    } catch (err) {
      dbErrors.push(`${area.label}: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  const recall = computeRecall(units);
  const summary = summariseHits(hits);

  if (format === 'csv') {
    const header = ['severity', 'check', 'kind', 'source', 'area', 'location', 'text', 'why', 'fix', 'checked_against', 'checked_against_url', 'checked_on', 'source_pack_ref'];
    const rows = hits.map(h => [h.severity, h.title, h.kind, h.source, h.area, h.location, h.context, h.why, h.fix, h.source_name ?? '', h.source_url ?? '', h.checked_on ?? '', h.review_ref ?? '']);
    const csv = [header, ...rows].map(r => r.map(csvCell).join(',')).join('\n');
    return new NextResponse(csv, {
      headers: {
        'Content-Type': 'text/csv; charset=utf-8',
        'Content-Disposition': `attachment; filename="evidence-checks-${new Date().toISOString().slice(0, 10)}.csv"`,
      },
    });
  }

  return NextResponse.json({
    generated_at: new Date().toISOString(),
    reviewer_model: AUDIT_MODEL_LABEL,
    coverage: {
      app_snapshot: appSnapshotInfo(),
      database_items: dbItems,
      database_areas: CONTENT_AREAS.filter(a => !isAppContentArea(a.id)).length,
      database_errors: dbErrors,
      text_units_scanned: units.length,
    },
    registers: {
      reviewed_on: REGISTER_REVIEWED_ON,
      trusted_sources: TRUSTED_SOURCES,
      tier_labels: TIER_LABELS,
      helplines: HELPLINES,
      retired_services: RETIRED_SERVICES.map(({ pattern, ...rest }) => ({ name: pattern.split('|')[0].replace(/ \?/g, ' '), ...rest })),
      rules: TEXT_RULES.map(({ pattern, flags, unless, ...rest }) => rest),
    },
    summary,
    recall,
    hits,
  });
}

function csvCell(v: unknown): string {
  const s = String(v ?? '');
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}
