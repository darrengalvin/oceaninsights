// Deterministic evidence checks.
//
// Runs the evidence registers (registry.mjs) and text rules (rules.mjs) over
// any text: rows from the database, the snapshot of text built into the app,
// or seed files. No AI is involved, so the same content always gives the same
// result, and every hit carries the rule, the reason and the trusted source it
// was checked against.
//
// Plain JavaScript (ESM) so both the Next.js admin and the Node CLI scripts
// can import it.

import { HELPLINES, RETIRED_SERVICES, TRUSTED_SOURCES, TIER_LABELS } from './registry.mjs';
import { TEXT_RULES } from './rules.mjs';

/**
 * @typedef {{
 *   rule_id: string, kind: 'detector'|'watchlist'|'helpline'|'link',
 *   category: string, severity: 'critical'|'red'|'amber'|'info',
 *   title: string, match: string, context: string,
 *   why: string, fix: string,
 *   source_name?: string, source_url?: string, review_ref?: string,
 *   checked_on?: string
 * }} EvidenceHit
 */

/** Score used when a hit is stored as an audit finding (matches the traffic lights). */
export const SEVERITY_SCORE = { critical: 20, red: 45, amber: 70, info: 85 };

const COMPILED_RULES = TEXT_RULES.map(r => ({
  rule: r,
  re: new RegExp(r.pattern, 'g' + (r.flags ?? 'i')),
  unless: r.unless ? new RegExp(r.unless) : null, // case-sensitive: "NHS", "Mind"
}));

const RETIRED = RETIRED_SERVICES.map(s => ({ ...s, re: new RegExp(s.pattern, 'gi') }));

/** Digits only, with +44 / 0044 turned into a leading 0. */
export function normalisePhone(raw) {
  let d = String(raw).replace(/[^\d+]/g, '');
  if (d.startsWith('+44')) d = '0' + d.slice(3);
  else if (d.startsWith('0044')) d = '0' + d.slice(4);
  d = d.replace(/\+/g, '');
  if (d.startsWith('1800') && d.length === 11) d = '1' + d.slice(1); // 1-800-273-8255
  return d;
}

const HELPLINE_BY_NUMBER = new Map();
for (const h of HELPLINES) for (const n of h.numbers) HELPLINE_BY_NUMBER.set(n, h);

/** Look up a number in the helpline register. */
export function lookupHelpline(raw) {
  return HELPLINE_BY_NUMBER.get(normalisePhone(raw)) ?? null;
}

// UK geographic/freephone/non-geographic numbers, +44 forms, US 1-800 numbers,
// and the short codes the register knows about.
const PHONE_RE = /(?<![\d£$€.,])(?:(?:\+44\s?\(?0?\)?\s?|0044\s?|0)\d(?:[\s-]?\d){8,9}|1-800-\d{3}-\d{4}|116\s?123|116\s?117|\b(?:999|111|911|988|85258)\b)(?![\d%])/g;

/** @returns {{ raw: string, index: number }[]} */
export function findPhoneNumbers(text) {
  const out = [];
  for (const m of String(text).matchAll(PHONE_RE)) out.push({ raw: m[0].trim(), index: m.index ?? 0 });
  return out;
}

const URL_RE = /\b(?:https?:\/\/)?(?:www\.)?((?:[a-z0-9-]+\.)+(?:org\.uk|nhs\.uk|gov\.uk|ac\.uk|co\.uk|mod\.uk|uk|org|com|net|lgbt|scot|wales))(\/[^\s'")\]]*)?/gi;

/** Classify a hostname against the trusted-source list. */
export function classifyDomain(host) {
  const h = host.toLowerCase().replace(/^www\./, '');
  let best = null;
  for (const s of TRUSTED_SOURCES) {
    if (h === s.domain || h.endsWith('.' + s.domain)) {
      if (!best || s.domain.length > best.domain.length) best = s;
    }
  }
  return best ? { tier: best.tier, name: best.name, label: TIER_LABELS[best.tier] }
              : { tier: 0, name: null, label: TIER_LABELS[0] };
}

/** @returns {{ url: string, host: string, tier: number, name: string|null, label: string }[]} */
export function findLinks(text) {
  const out = [];
  for (const m of String(text).matchAll(URL_RE)) {
    const host = m[1];
    // Skip things that only look like domains (file names), email addresses,
    // and service endpoints the app calls in code rather than shows to users.
    if (/\.(dart|png|jpg|svg|json)$/i.test(host)) continue;
    if (text[(m.index ?? 0) - 1] === '@') continue;
    if (/^(?:api|platform)\.|(?:^|\.)(?:openai\.com|supabase\.co|googleapis\.com|revenuecat\.com)$/i.test(host)) continue;
    out.push({ url: m[0], host, ...classifyDomain(host) });
  }
  return out;
}

function contextAround(text, index, length, pad = 70) {
  const start = Math.max(0, index - pad);
  const end = Math.min(text.length, index + length + pad);
  return (start > 0 ? '…' : '') + text.slice(start, end).replace(/\s+/g, ' ').trim() + (end < text.length ? '…' : '');
}

function sentenceAround(text, index) {
  const before = text.lastIndexOf('.', index);
  const after = text.indexOf('.', index);
  return text.slice(before + 1, after === -1 ? text.length : after + 1);
}

/**
 * Run every evidence check over one piece of text.
 * @param {string} text
 * @returns {EvidenceHit[]}
 */
export function scanText(text) {
  const t = String(text ?? '');
  if (!t.trim()) return [];
  /** @type {EvidenceHit[]} */
  const hits = [];

  // 1. Phone numbers against the helpline register.
  for (const { raw, index } of findPhoneNumbers(t)) {
    const entry = lookupHelpline(raw);
    const context = contextAround(t, index, raw.length);
    if (!entry) {
      // A bare short code with no register entry (e.g. 116 117) is still a number to check.
      hits.push({
        rule_id: 'helpline-unregistered', kind: 'helpline', category: 'currency', severity: 'amber',
        title: 'Phone number not in the helpline register', match: raw, context,
        why: 'Every number shown to users should be checked against the organisation\'s own page and recorded with the date checked.',
        fix: 'Check the number on the organisation\'s website and add it to the helpline register, or remove it.',
      });
      continue;
    }
    if (entry.status === 'verified') {
      // Verified number: still check any 24/7 claim against the register's hours.
      const near = t.slice(Math.max(0, index - 80), index + raw.length + 80);
      if (/24\s?\/\s?7|24 hours/i.test(near) && entry.hours && !/24\/7/.test(entry.hours)) {
        hits.push({
          rule_id: 'helpline-hours', kind: 'helpline', category: 'currency', severity: 'red',
          title: `${entry.service}: hours shown as 24/7`, match: raw, context,
          why: `The register records the hours as ${entry.hours}.`,
          fix: `Show the hours as ${entry.hours}.`,
          source_name: entry.source_name, source_url: entry.source_url, checked_on: entry.checked_on,
        });
      }
      continue;
    }
    const sev = { closed: 'critical', non_uk: 'critical', client_rule: 'red', to_confirm: 'amber', caution: 'info' }[entry.status];
    const title = {
      closed: `Closed service: ${entry.service}`,
      non_uk: `Non-UK number: ${entry.service}`,
      client_rule: `Breaks a client wording rule: ${entry.service}`,
      to_confirm: `Number awaiting confirmation: ${entry.service}`,
      caution: `Check how this service is described: ${entry.service}`,
    }[entry.status];
    hits.push({
      rule_id: `helpline-${entry.status.replace('_', '-')}`, kind: 'helpline', category: entry.status === 'client_rule' ? 'client_rule' : entry.status === 'non_uk' ? 'uk_applicability' : 'currency',
      severity: /** @type {any} */ (sev), title, match: raw, context,
      why: entry.note ?? `Register status: ${entry.status}.`,
      fix: entry.status === 'caution' ? 'Make sure the surrounding text describes the service as the register notes.' : 'Replace or remove, following the register note.',
      source_name: entry.source_name, source_url: entry.source_url || undefined, checked_on: entry.checked_on,
    });
  }

  // 2. Services named in text that have closed or been renamed.
  for (const s of RETIRED) {
    s.re.lastIndex = 0;
    for (const m of t.matchAll(s.re)) {
      hits.push({
        rule_id: `service-${s.status.replace(/_/g, '-')}`, kind: 'helpline', category: 'currency',
        severity: s.status === 'closed' ? 'critical' : 'red',
        title: `${s.status === 'renamed' ? 'Renamed' : s.status === 'closed' ? 'Closed' : 'Unrecognised'} service: ${m[0]}`,
        match: m[0], context: contextAround(t, m.index ?? 0, m[0].length),
        why: s.note ?? `This service has ${s.status === 'renamed' ? 'been renamed' : 'closed'}.`,
        fix: `Use ${s.replacement}.`,
        source_name: s.source_name, source_url: s.source_url, checked_on: s.checked_on,
      });
    }
  }

  // 3. Links classified by trusted-source tier.
  for (const link of findLinks(t)) {
    if (link.tier === 1 || link.tier === 2) continue;
    hits.push({
      rule_id: link.tier === 3 ? 'link-tier3' : 'link-untrusted', kind: 'link', category: 'trusted_source',
      severity: link.tier === 3 ? 'info' : 'amber',
      title: link.tier === 3 ? `Links to a UK charity: ${link.name}` : `Link not on the trusted-source list: ${link.host}`,
      match: link.url, context: contextAround(t, t.indexOf(link.url), link.url.length),
      why: link.tier === 3
        ? 'An established UK charity the NHS signposts to. The client decides whether these count as trusted.'
        : 'Client rule: information must come from the NHS or trusted sources.',
      fix: link.tier === 3 ? 'No change needed unless the client rules charities out.' : 'Replace with an NHS, RCPsych, Mind, Mental Health Foundation or GOV.UK page, or add the site to the trusted list with the client\'s agreement.',
    });
  }

  // 4. Text rules.
  for (const { rule, re, unless } of COMPILED_RULES) {
    re.lastIndex = 0;
    for (const m of t.matchAll(re)) {
      const idx = m.index ?? 0;
      if (unless && unless.test(sentenceAround(t, idx))) continue;
      hits.push({
        rule_id: rule.id, kind: rule.kind, category: rule.category, severity: rule.severity,
        title: rule.title, match: m[0], context: contextAround(t, idx, m[0].length),
        why: rule.why, fix: rule.fix,
        source_name: rule.source_name, source_url: rule.source_url, review_ref: rule.review_ref,
      });
      break; // one hit per rule per text is enough to flag it
    }
  }

  return hits;
}

/**
 * Flatten a structured record (a database row, nested JSON) into readable text.
 * Keys that are clearly not user-facing (ids, timestamps, colours) are skipped.
 */
export function recordToText(value) {
  const parts = [];
  const SKIP_KEY = /(^id$|_id$|_at$|^icon|colou?r|^slug$|^order|sort|position|^is_|^has_|image|asset|uuid)/i;
  (function walk(v, key) {
    if (v == null) return;
    if (key && SKIP_KEY.test(key)) return;
    if (typeof v === 'string') { if (v.trim()) parts.push(v); return; }
    if (typeof v === 'number' || typeof v === 'boolean') return;
    if (Array.isArray(v)) { v.forEach(x => walk(x, '')); return; }
    if (typeof v === 'object') for (const [k, x] of Object.entries(v)) walk(x, k);
  })(value, '');
  return parts.join('\n');
}

/**
 * Summarise hits for reports: counts by severity and by rule.
 * @param {EvidenceHit[]} hits
 */
export function summariseHits(hits) {
  const bySeverity = { critical: 0, red: 0, amber: 0, info: 0 };
  /** @type {Record<string, { title: string, kind: string, severity: string, count: number }>} */
  const byRule = {};
  for (const h of hits) {
    bySeverity[h.severity]++;
    byRule[h.rule_id] ??= { title: h.title, kind: h.kind, severity: h.severity, count: 0 };
    byRule[h.rule_id].count++;
  }
  return { total: hits.length, bySeverity, byRule };
}
