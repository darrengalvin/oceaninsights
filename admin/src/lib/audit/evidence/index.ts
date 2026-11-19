// Typed entry point to the deterministic evidence checks for the admin.
//
// The checks themselves live in plain JavaScript (scan.mjs, rules.mjs,
// registry.mjs) so the Node CLI scripts can run them too.

import { scanText, recordToText, SEVERITY_SCORE } from './scan.mjs';
import type { ExtractedContentItem } from '../types';
import { APP_SNAPSHOT_TABLE } from '../app-areas';

export interface EvidenceHit {
  rule_id: string;
  kind: 'detector' | 'watchlist' | 'helpline' | 'link';
  category: string;
  severity: 'critical' | 'red' | 'amber' | 'info';
  title: string;
  match: string;
  context: string;
  why: string;
  fix: string;
  source_name?: string;
  source_url?: string;
  review_ref?: string;
  checked_on?: string;
}

export interface EvidenceCategoryScore {
  score: number;
  applicable: boolean;
  reasoning: string;
  sub_scores: {
    sub_criterion: string;
    score: number;
    evidence: string;
    finding: string | null;
    suggested_action: string | null;
  }[];
}

/** The text of an item, as the evidence checks see it. */
export function itemText(item: ExtractedContentItem): string {
  if (item.source_table === APP_SNAPSHOT_TABLE) return String(item.data.text ?? '');
  return recordToText(item.data);
}

/** Which Evidence Checks sub-criterion a hit belongs to. */
export function hitSubCriterion(hit: EvidenceHit): string {
  if (hit.kind === 'helpline') return 'helpline_register';
  if (hit.kind === 'link') return 'trusted_links';
  if (hit.kind === 'watchlist') return 'reviewed_claims';
  if (hit.category === 'uk_applicability') return 'uk_applicability';
  if (hit.category === 'client_rule') return 'client_rules';
  return 'flagged_claims';
}

export function scanItem(item: ExtractedContentItem): EvidenceHit[] {
  const hits = scanText(itemText(item)) as EvidenceHit[];
  // One hit per rule and matched text is enough.
  const seen = new Set<string>();
  return hits.filter(h => {
    const key = `${h.rule_id}|${h.match.toLowerCase()}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

/** Describe a hit as a finding: what is wrong, and what it was checked against. */
export function hitDescription(hit: EvidenceHit): string {
  const src = hit.source_name ? ` Checked against: ${hit.source_name}${hit.checked_on ? ` (${hit.checked_on})` : ''}${hit.source_url ? ` ${hit.source_url}` : ''}.` : '';
  const ref = hit.review_ref ? ` Source pack ref ${hit.review_ref}.` : '';
  return `[Evidence check: ${hit.title}] ${hit.why}${src}${ref}`;
}

/**
 * Score an item's Evidence Checks category from its hits. Each sub-criterion
 * takes the score of its most severe hit; the category takes the lowest
 * sub-criterion score, so one closed helpline cannot be averaged away.
 */
export function evidenceCategoryScore(hits: EvidenceHit[]): EvidenceCategoryScore {
  const bySub = new Map<string, EvidenceHit[]>();
  for (const h of hits) {
    const sub = hitSubCriterion(h);
    if (!bySub.has(sub)) bySub.set(sub, []);
    bySub.get(sub)!.push(h);
  }
  const sub_scores = Array.from(bySub.entries()).map(([sub, hs]) => {
    const worst = hs.reduce((a, b) => (SEVERITY_SCORE[a.severity] <= SEVERITY_SCORE[b.severity] ? a : b));
    return {
      sub_criterion: sub,
      score: SEVERITY_SCORE[worst.severity],
      evidence: hs.map(h => h.context).join(' | ').slice(0, 1000),
      finding: hs.map(h => hitDescription(h)).join(' '),
      suggested_action: Array.from(new Set(hs.map(h => h.fix))).join(' '),
    };
  });
  const score = sub_scores.length ? Math.min(...sub_scores.map(s => s.score)) : 100;
  return {
    score,
    applicable: true,
    reasoning: hits.length === 0
      ? 'No evidence-check flags: phone numbers, links, UK applicability and client wording rules all pass.'
      : `${hits.length} evidence-check flag(s): ${Array.from(new Set(hits.map(h => h.title))).join('; ')}.`,
    sub_scores,
  };
}

export { SEVERITY_SCORE };
