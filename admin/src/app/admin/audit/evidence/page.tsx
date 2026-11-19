'use client';

// Evidence register: what the content audit checks against, where each
// reference comes from and when it was checked, and a live run of the
// deterministic evidence checks over the database and the app's built-in text.

import { useEffect, useMemo, useState } from 'react';

type Severity = 'critical' | 'red' | 'amber' | 'info';

interface Hit {
  rule_id: string; kind: string; category: string; severity: Severity; title: string;
  match: string; context: string; why: string; fix: string;
  source_name?: string; source_url?: string; review_ref?: string; checked_on?: string;
  source: 'app' | 'database'; area: string; location: string;
}
interface Helpline {
  numbers: string[]; service: string; status: string; hours?: string; crisis_line?: boolean; note?: string;
  source_name: string; source_url: string; checked_on: string;
}
interface TrustedSource { domain: string; name: string; tier: number }
interface Rule { id: string; kind: string; title: string; category: string; severity: Severity; why: string; fix: string; source_name?: string; source_url?: string; review_ref?: string }
interface RecallRow { id: string; summary: string; needs_judgement: boolean; status: string; locators: { label: string; found: boolean; where: string | null; detector: boolean; watchlist: boolean }[] }
interface EvidenceResponse {
  generated_at: string;
  reviewer_model: string;
  coverage: { app_snapshot: { generated_at: string; git_commit: string | null; file_count: number; string_count: number }; database_items: number; database_areas: number; database_errors: string[]; text_units_scanned: number };
  registers: { reviewed_on: string; trusted_sources: TrustedSource[]; tier_labels: Record<string, string>; helplines: Helpline[]; retired_services: { name: string; status: string; replacement: string; source_name: string; source_url: string; checked_on: string }[]; rules: Rule[] };
  summary: { total: number; bySeverity: Record<Severity, number> };
  recall: { rows: RecallRow[]; total: number; present: number; by_detectors: number; by_detectors_or_watchlist: number; missed: string[]; needs_judgement: string[] };
  hits: Hit[];
}

const SEV_STYLE: Record<Severity, string> = {
  critical: 'bg-red-700 text-white',
  red: 'bg-red-100 text-red-800',
  amber: 'bg-amber-100 text-amber-800',
  info: 'bg-gray-100 text-gray-600',
};
const SEV_RANK: Record<Severity, number> = { critical: 0, red: 1, amber: 2, info: 3 };

const STATUS_STYLE: Record<string, string> = {
  verified: 'bg-green-100 text-green-800',
  caution: 'bg-amber-100 text-amber-800',
  to_confirm: 'bg-amber-100 text-amber-800',
  closed: 'bg-red-700 text-white',
  non_uk: 'bg-red-700 text-white',
  client_rule: 'bg-red-100 text-red-800',
};
const STATUS_LABEL: Record<string, string> = {
  verified: 'Verified', caution: 'Verified, describe carefully', to_confirm: 'To confirm', closed: 'Closed', non_uk: 'Not a UK service', client_rule: 'Client rule',
};
const RECALL_LABEL: Record<string, [string, string]> = {
  detector: ['Caught by general checks', 'bg-green-100 text-green-800'],
  detector_and_watchlist: ['Caught (general checks + watchlist)', 'bg-green-100 text-green-800'],
  watchlist: ['Caught by reviewed-claims watchlist', 'bg-cyan-100 text-cyan-800'],
  missed: ['Left to the AI review', 'bg-amber-100 text-amber-800'],
  not_found: ['Not in the content scanned', 'bg-gray-100 text-gray-600'],
};

function formatNumber(n: string) {
  if (n.length === 11 && n.startsWith('0')) return n.startsWith('08') || n.startsWith('03') ? `${n.slice(0, 4)} ${n.slice(4, 7)} ${n.slice(7)}` : `${n.slice(0, 3)} ${n.slice(3, 7)} ${n.slice(7)}`;
  if (n === '116123') return '116 123';
  return n;
}

export default function EvidencePage() {
  const [data, setData] = useState<EvidenceResponse | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState<'flags' | 'helplines' | 'sources' | 'rules'>('flags');
  const [sourceFilter, setSourceFilter] = useState<'all' | 'app' | 'database'>('all');
  const [showInfo, setShowInfo] = useState(false);
  const [open, setOpen] = useState<string | null>(null);

  useEffect(() => {
    fetch('/api/audit/evidence')
      .then(r => (r.ok ? r.json() : r.json().then(j => Promise.reject(new Error(j.error || r.statusText)))))
      .then(setData)
      .catch(e => setError(e instanceof Error ? e.message : String(e)));
  }, []);

  const grouped = useMemo(() => {
    if (!data) return [];
    const g = new Map<string, { title: string; severity: Severity; kind: string; why: string; fix: string; source_name?: string; source_url?: string; review_ref?: string; hits: Hit[] }>();
    for (const h of data.hits) {
      if (sourceFilter !== 'all' && h.source !== sourceFilter) continue;
      if (!showInfo && h.severity === 'info') continue;
      const key = `${h.rule_id}|${h.title}`;
      if (!g.has(key)) g.set(key, { title: h.title, severity: h.severity, kind: h.kind, why: h.why, fix: h.fix, source_name: h.source_name, source_url: h.source_url, review_ref: h.review_ref, hits: [] });
      g.get(key)!.hits.push(h);
    }
    return Array.from(g.entries()).sort((a, b) => SEV_RANK[a[1].severity] - SEV_RANK[b[1].severity] || b[1].hits.length - a[1].hits.length);
  }, [data, sourceFilter, showInfo]);

  if (error) return <div className="p-6 bg-red-50 border border-red-200 rounded-2xl text-red-800">Could not load the evidence register: {error}</div>;
  if (!data) return <div className="p-6 text-gray-500">Running the evidence checks over the app and the database…</div>;

  const snap = data.coverage.app_snapshot;
  const r = data.recall;

  return (
    <div>
      <div className="flex flex-wrap items-start justify-between gap-4 mb-6">
        <div>
          <a href="/admin/audit" className="text-sm text-cyan-700 hover:underline">← Content Audit</a>
          <h1 className="text-3xl font-bold text-gray-900 mt-1">Evidence Register</h1>
          <p className="text-gray-500 text-sm mt-1 max-w-3xl">
            What the audit checks the app against, where each reference comes from and when it was checked. The checks on this page are fixed rules, not AI, so the same content always gives the same result. The AI review ({data.reviewer_model}) runs separately when you run an audit.
          </p>
        </div>
        <div className="flex gap-2">
          <a href="/api/audit/evidence?format=csv" className="px-4 py-2 bg-gray-900 text-white rounded-xl text-sm font-semibold hover:bg-gray-800 transition">Download CSV</a>
          <button onClick={() => window.print()} className="px-4 py-2 border border-gray-300 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-50 transition">Print</button>
        </div>
      </div>

      {/* Coverage */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Tile label="Text built into the app" value={`${snap.string_count.toLocaleString()} strings`} sub={`${snap.file_count} files · snapshot ${snap.git_commit ?? ''} · ${new Date(snap.generated_at).toLocaleDateString('en-GB')}`} />
        <Tile label="Database content" value={`${data.coverage.database_items.toLocaleString()} items`} sub={data.coverage.database_errors.length ? `${data.coverage.database_errors.length} areas could not be read` : `${data.coverage.database_areas} areas, read live`} />
        <Tile label="Helpline register" value={`${data.registers.helplines.length} services`} sub={`Reviewed ${new Date(data.registers.reviewed_on).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' })}`} />
        <Tile label="Flags now" value={`${data.summary.bySeverity.critical} critical · ${data.summary.bySeverity.red} red`} sub={`${data.summary.bySeverity.amber} amber · ${data.summary.bySeverity.info} for information`} />
      </div>

      {/* Detection rate */}
      <div className="bg-white border border-gray-200 rounded-2xl p-6 mb-6">
        <h2 className="text-lg font-bold text-gray-900">How well the checks catch known issues</h2>
        <p className="text-sm text-gray-600 mt-1 max-w-3xl">
          The manual content source pack review (19 November 2026) found {r.total} issues. Of those still in the app, the fixed checks catch <strong>{r.by_detectors_or_watchlist} of {r.present}</strong>: {r.by_detectors} entirely through general checks that would also catch new cases (a US healthcare term, an unsourced statistic, a closed helpline), and the rest through the reviewed-claims watchlist, which stops a corrected claim from coming back. {r.missed.length ? `${r.missed.join(', ')} need${r.missed.length === 1 ? 's' : ''} judgement and ${r.missed.length === 1 ? 'is' : 'are'} left to the AI review.` : ''}
        </p>
        <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-x-6">
          {r.rows.map(row => (
            <div key={row.id} className="flex items-center gap-3 py-1.5 border-b border-gray-100 text-sm">
              <span className="w-10 font-mono text-gray-500">{row.id}</span>
              <span className="flex-1 text-gray-800">{row.summary}</span>
              <span className={`px-2 py-0.5 rounded-full text-xs font-medium whitespace-nowrap ${RECALL_LABEL[row.status][1]}`}>{RECALL_LABEL[row.status][0]}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 mb-4 border-b border-gray-200">
        {([['flags', 'Current flags'], ['helplines', 'Helpline register'], ['sources', 'Trusted sources'], ['rules', 'Check rules']] as const).map(([id, label]) => (
          <button key={id} onClick={() => setTab(id)} className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px ${tab === id ? 'border-cyan-700 text-cyan-800' : 'border-transparent text-gray-500 hover:text-gray-800'}`}>{label}</button>
        ))}
      </div>

      {tab === 'flags' && (
        <div>
          <div className="flex flex-wrap items-center gap-3 mb-3 text-sm">
            {(['all', 'app', 'database'] as const).map(f => (
              <button key={f} onClick={() => setSourceFilter(f)} className={`px-3 py-1 rounded-full border ${sourceFilter === f ? 'bg-gray-900 text-white border-gray-900' : 'border-gray-300 text-gray-700'}`}>
                {f === 'all' ? 'App and database' : f === 'app' ? 'Built into the app' : 'Database'}
              </button>
            ))}
            <label className="flex items-center gap-2 text-gray-600 ml-2"><input type="checkbox" checked={showInfo} onChange={e => setShowInfo(e.target.checked)} /> Show information-only flags</label>
          </div>
          <div className="space-y-2">
            {grouped.map(([key, g]) => (
              <div key={key} className="bg-white border border-gray-200 rounded-xl">
                <button onClick={() => setOpen(open === key ? null : key)} className="w-full flex items-center gap-3 px-4 py-3 text-left">
                  <span className={`px-2 py-0.5 rounded-full text-xs font-semibold uppercase ${SEV_STYLE[g.severity]}`}>{g.severity}</span>
                  <span className="flex-1 font-medium text-gray-900">{g.title}</span>
                  {g.review_ref && <span className="text-xs text-gray-400">{g.review_ref}</span>}
                  <span className="text-sm text-gray-500">{g.hits.length} place{g.hits.length === 1 ? '' : 's'}</span>
                </button>
                {open === key && (
                  <div className="px-4 pb-4 text-sm">
                    <p className="text-gray-700"><strong>Why:</strong> {g.why}</p>
                    <p className="text-gray-700 mt-1"><strong>Fix:</strong> {g.fix}</p>
                    {g.source_name && <p className="text-gray-700 mt-1"><strong>Checked against:</strong> {g.source_url ? <a className="text-cyan-700 hover:underline" href={g.source_url} target="_blank" rel="noreferrer">{g.source_name}</a> : g.source_name}</p>}
                    <table className="w-full mt-3 text-xs">
                      <thead><tr className="text-left text-gray-500"><th className="py-1 pr-3">Where</th><th className="py-1">Text</th></tr></thead>
                      <tbody>
                        {g.hits.map((h, i) => (
                          <tr key={i} className="border-t border-gray-100 align-top">
                            <td className="py-1.5 pr-3 text-gray-500 w-1/3"><span className="block text-gray-800">{h.area}</span><span className="font-mono break-all">{h.location}</span></td>
                            <td className="py-1.5 text-gray-800">{h.context}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            ))}
            {grouped.length === 0 && <p className="text-gray-500 text-sm">No flags.</p>}
          </div>
        </div>
      )}

      {tab === 'helplines' && (
        <div className="bg-white border border-gray-200 rounded-2xl overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 text-left text-gray-600">
              <tr><th className="px-4 py-2">Service</th><th className="px-4 py-2">Number</th><th className="px-4 py-2">Status</th><th className="px-4 py-2">Hours</th><th className="px-4 py-2">Checked against</th><th className="px-4 py-2">Checked</th></tr>
            </thead>
            <tbody>
              {data.registers.helplines.map(h => (
                <tr key={h.numbers.join()} className="border-t border-gray-100 align-top">
                  <td className="px-4 py-2 text-gray-900">{h.service}{h.crisis_line === false && <span className="block text-xs text-gray-500">Not a crisis line</span>}{h.note && <span className="block text-xs text-gray-500 mt-0.5">{h.note}</span>}</td>
                  <td className="px-4 py-2 font-mono whitespace-nowrap">{h.numbers.map(formatNumber).join(', ')}</td>
                  <td className="px-4 py-2"><span className={`px-2 py-0.5 rounded-full text-xs font-medium whitespace-nowrap ${STATUS_STYLE[h.status] ?? ''}`}>{STATUS_LABEL[h.status] ?? h.status}</span></td>
                  <td className="px-4 py-2 text-gray-600">{h.hours ?? ''}</td>
                  <td className="px-4 py-2">{h.source_url ? <a className="text-cyan-700 hover:underline" href={h.source_url} target="_blank" rel="noreferrer">{h.source_name}</a> : h.source_name}</td>
                  <td className="px-4 py-2 text-gray-600 whitespace-nowrap">{new Date(h.checked_on).toLocaleDateString('en-GB')}</td>
                </tr>
              ))}
              {data.registers.retired_services.map(s => (
                <tr key={s.name} className="border-t border-gray-100 align-top">
                  <td className="px-4 py-2 text-gray-900">{s.name}<span className="block text-xs text-gray-500">Use instead: {s.replacement}</span></td>
                  <td className="px-4 py-2 text-gray-400">named in text</td>
                  <td className="px-4 py-2"><span className="px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">{s.status === 'renamed' ? 'Renamed' : s.status === 'closed' ? 'Closed' : 'Not a recognised service'}</span></td>
                  <td className="px-4 py-2"></td>
                  <td className="px-4 py-2"><a className="text-cyan-700 hover:underline" href={s.source_url} target="_blank" rel="noreferrer">{s.source_name}</a></td>
                  <td className="px-4 py-2 text-gray-600 whitespace-nowrap">{new Date(s.checked_on).toLocaleDateString('en-GB')}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <p className="px-4 py-3 text-xs text-gray-500 border-t border-gray-100">Any phone number in the app that is not on this register is flagged as unregistered. To change an entry, edit <code>admin/src/lib/audit/evidence/registry.mjs</code> and record the date you checked it.</p>
        </div>
      )}

      {tab === 'sources' && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {[1, 2, 3].map(tier => (
            <div key={tier} className="bg-white border border-gray-200 rounded-2xl p-4">
              <h3 className="font-semibold text-gray-900">Tier {tier}</h3>
              <p className="text-xs text-gray-500 mb-2">{data.registers.tier_labels[String(tier)]}</p>
              <ul className="text-sm space-y-1">
                {data.registers.trusted_sources.filter(s => s.tier === tier).map(s => (
                  <li key={s.domain} className="flex justify-between gap-2"><span className="text-gray-800">{s.name}</span><span className="text-gray-400 font-mono text-xs">{s.domain}</span></li>
                ))}
              </ul>
            </div>
          ))}
          <p className="md:col-span-3 text-xs text-gray-500">Tier 1 is the client&apos;s named list. Links to any site not listed here are flagged. Whether Tier 3 charities count as trusted for health claims is the client&apos;s decision; the AI review is told to prefer Tier 1 for health claims.</p>
        </div>
      )}

      {tab === 'rules' && (
        <div className="bg-white border border-gray-200 rounded-2xl overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 text-left text-gray-600">
              <tr><th className="px-4 py-2">Check</th><th className="px-4 py-2">Type</th><th className="px-4 py-2">Severity</th><th className="px-4 py-2">Why it matters</th><th className="px-4 py-2">Reference</th></tr>
            </thead>
            <tbody>
              {data.registers.rules.map(rule => (
                <tr key={rule.id} className="border-t border-gray-100 align-top">
                  <td className="px-4 py-2 text-gray-900">{rule.title}</td>
                  <td className="px-4 py-2 text-gray-600 whitespace-nowrap">{rule.kind === 'detector' ? 'General check' : 'Reviewed claim'}</td>
                  <td className="px-4 py-2"><span className={`px-2 py-0.5 rounded-full text-xs font-semibold uppercase ${SEV_STYLE[rule.severity]}`}>{rule.severity}</span></td>
                  <td className="px-4 py-2 text-gray-700">{rule.why}</td>
                  <td className="px-4 py-2 whitespace-nowrap">{rule.source_url ? <a className="text-cyan-700 hover:underline" href={rule.source_url} target="_blank" rel="noreferrer">{rule.source_name}</a> : rule.source_name ?? ''}{rule.review_ref ? <span className="block text-xs text-gray-400">Source pack {rule.review_ref}</span> : null}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <p className="text-xs text-gray-400 mt-6">Generated {new Date(data.generated_at).toLocaleString('en-GB')}. {data.coverage.text_units_scanned.toLocaleString()} pieces of text scanned.</p>
    </div>
  );
}

function Tile({ label, value, sub }: { label: string; value: string; sub: string }) {
  return (
    <div className="bg-white border border-gray-200 rounded-2xl p-4">
      <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">{label}</p>
      <p className="text-xl font-bold text-gray-900 mt-1">{value}</p>
      <p className="text-xs text-gray-500 mt-1">{sub}</p>
    </div>
  );
}
