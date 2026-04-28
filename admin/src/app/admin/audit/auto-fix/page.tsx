'use client';

// Auto-fix page. Picks one trusted model, proposes a fix for every open
// finding, then shows the proposals in a review queue with side-by-side diff
// and per-fix apply. Bulk apply is available but every individual fix still
// requires an explicit click — the bake-off showed Opus can over-correct on
// regional findings, so silent auto-apply is too risky for compliance content.

import { useState, useEffect, useCallback } from 'react';
import { scoreToTrafficLight, trafficLightColor } from '@/lib/audit/types';
import type { AuditFinding } from '@/lib/audit/types';
import type { BenchmarkModel } from '@/lib/audit/models';

type View = 'setup' | 'running' | 'review';
type ApplyState = 'pending' | 'applying' | 'applied' | 'rejected' | 'failed';

interface AutoFixRun {
  id: string;
  status: 'created' | 'proposing' | 'judging' | 'completed' | 'failed';
  finding_ids: string[];
  candidate_models: { id: string; label: string }[];
  notes: string | null;
  created_at: string;
}

interface ProposedFix {
  id: string;
  finding_id: string;
  model_id: string;
  model_label: string;
  proposed_text: string;
  rationale: string | null;
  source_field: string | null;
  status: 'pending' | 'completed' | 'failed';
  error_message: string | null;
  latency_ms: number | null;
  cost_usd: number | null;
  original_text: string | null;
  finding?: AuditFinding | null;
}

interface RecentRun extends AutoFixRun {
  total_cost_usd: number | null;
}

export default function AutoFixPage() {
  const [view, setView] = useState<View>('setup');
  const [models, setModels] = useState<BenchmarkModel[]>([]);
  const [openFindings, setOpenFindings] = useState<AuditFinding[]>([]);
  const [recentRuns, setRecentRuns] = useState<RecentRun[]>([]);
  const [chosenModelId, setChosenModelId] = useState<string>('claude-opus-4-7-xhigh');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const [progress, setProgress] = useState({ done: 0, total: 0, current: '' });
  const [activeRunId, setActiveRunId] = useState<string | null>(null);
  const [fixes, setFixes] = useState<ProposedFix[]>([]);
  const [applyStates, setApplyStates] = useState<Record<string, ApplyState>>({});

  const loadInitial = useCallback(async () => {
    setLoading(true);
    try {
      const [findingsRes, runsRes] = await Promise.all([
        fetch('/api/audit/findings?status=open&limit=500').then(r => r.json()),
        fetch('/api/audit/auto-fix').then(r => r.json()),
      ]);
      setOpenFindings(findingsRes.findings || []);
      setRecentRuns(runsRes.runs || []);
      setModels(runsRes.available_models || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load');
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    loadInitial();
  }, [loadInitial]);

  async function startAutoFix() {
    setError(null);
    if (openFindings.length === 0) {
      setError('No open findings to fix.');
      return;
    }
    setView('running');
    setFixes([]);
    setApplyStates({});

    try {
      const createRes = await fetch('/api/audit/auto-fix', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ model_id: chosenModelId }),
      });
      const createData = await createRes.json();
      if (!createRes.ok) throw new Error(createData.error || 'Failed to create auto-fix run');

      const runId: string = createData.run.id;
      const findingIds: string[] = createData.finding_ids;
      setActiveRunId(runId);
      setProgress({ done: 0, total: findingIds.length, current: '' });

      // Fan out in batches of 4. Each propose call hits one finding × one
      // model so latency is bounded by the slowest single call (~5-10s for
      // Opus xhigh), and 4 in parallel keeps us under typical rate limits.
      const BATCH = 4;
      let done = 0;
      const allFixes: ProposedFix[] = [];

      for (let i = 0; i < findingIds.length; i += BATCH) {
        const batch = findingIds.slice(i, i + BATCH);
        const findingLabels = openFindings
          .filter(f => batch.includes(f.id))
          .map(f => f.item_label || f.content_area)
          .join(', ');
        setProgress({ done, total: findingIds.length, current: findingLabels });

        const settled = await Promise.allSettled(
          batch.map(fid =>
            fetch('/api/audit/benchmark/propose', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ benchmark_run_id: runId, finding_id: fid }),
            }).then(r => r.json())
          )
        );

        for (const r of settled) {
          if (r.status === 'fulfilled' && r.value.fixes) {
            allFixes.push(...r.value.fixes);
            setFixes(prev => [...prev, ...r.value.fixes]);
          }
          done += 1;
        }
        setProgress({ done, total: findingIds.length, current: findingLabels });
      }

      // Mark run completed (so it shows up cleanly in history) and load the
      // joined view (fixes joined to findings) for the review queue.
      await fetch(`/api/audit/benchmark/${runId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'completed' }),
      });
      const joinedRes = await fetch(`/api/audit/auto-fix/${runId}`);
      const joinedData = await joinedRes.json();
      if (joinedData.fixes) setFixes(joinedData.fixes);

      setView('review');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Auto-fix failed');
      setView('setup');
    }
  }

  async function loadExistingRun(runId: string) {
    setError(null);
    setLoading(true);
    try {
      const res = await fetch(`/api/audit/auto-fix/${runId}`);
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to load run');
      setActiveRunId(runId);
      setFixes(data.fixes || []);
      const initialApply: Record<string, ApplyState> = {};
      for (const a of data.applies || []) {
        initialApply[a.fix_id] = 'applied';
      }
      setApplyStates(initialApply);
      setView('review');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load');
    }
    setLoading(false);
  }

  async function applyOne(fix: ProposedFix, sourceField: string): Promise<boolean> {
    setApplyStates(prev => ({ ...prev, [fix.id]: 'applying' }));
    try {
      const res = await fetch('/api/audit/benchmark/apply', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ fix_id: fix.id, source_field: sourceField }),
      });
      const data = await res.json();
      if (!res.ok) {
        setApplyStates(prev => ({ ...prev, [fix.id]: 'failed' }));
        setError(`Apply ${fix.id.slice(0, 6)}…: ${data.error}`);
        return false;
      }
      setApplyStates(prev => ({ ...prev, [fix.id]: 'applied' }));
      return true;
    } catch (err) {
      setApplyStates(prev => ({ ...prev, [fix.id]: 'failed' }));
      setError(err instanceof Error ? err.message : 'Apply failed');
      return false;
    }
  }

  if (loading && view === 'setup') {
    return (
      <div className="p-8 flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <div className="w-8 h-8 border-2 border-cyan-700 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
          <p className="text-gray-500 text-sm">Loading auto-fix...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto">
      <div className="mb-6 flex items-center gap-3 text-xs text-gray-500">
        <a href="/admin/audit" className="hover:text-gray-700">Audit</a>
        <span>/</span>
        <span className="text-gray-700">Auto-Fix</span>
      </div>

      {error && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm">{error}</div>
      )}

      {view === 'setup' && (
        <SetupView
          openFindings={openFindings}
          models={models}
          chosenModelId={chosenModelId}
          setChosenModelId={setChosenModelId}
          recentRuns={recentRuns}
          onStart={startAutoFix}
          onOpenRun={loadExistingRun}
        />
      )}

      {view === 'running' && (
        <RunningView progress={progress} fixes={fixes} />
      )}

      {view === 'review' && (
        <ReviewView
          fixes={fixes}
          applyStates={applyStates}
          onApply={applyOne}
          onReject={fixId => setApplyStates(prev => ({ ...prev, [fixId]: 'rejected' }))}
          onReset={() => {
            setView('setup');
            setActiveRunId(null);
            setFixes([]);
            setApplyStates({});
            loadInitial();
          }}
        />
      )}
    </div>
  );
}

// ============================================================
// SETUP
// ============================================================

function SetupView({
  openFindings, models, chosenModelId, setChosenModelId, recentRuns, onStart, onOpenRun,
}: {
  openFindings: AuditFinding[];
  models: BenchmarkModel[];
  chosenModelId: string;
  setChosenModelId: (id: string) => void;
  recentRuns: RecentRun[];
  onStart: () => void;
  onOpenRun: (id: string) => void;
}) {
  const chosenModel = models.find(m => m.id === chosenModelId);
  const severityCounts = openFindings.reduce(
    (acc, f) => {
      const light = scoreToTrafficLight(f.score);
      acc[light] = (acc[light] || 0) + 1;
      return acc;
    },
    {} as Record<string, number>
  );
  // Rough cost estimate: 1500 input + 600 output tokens per fix, single model.
  const estimatedCost = chosenModel
    ? openFindings.length *
      ((1500 / 1_000_000) * chosenModel.inputCostPerMtok +
        (600 / 1_000_000) * chosenModel.outputCostPerMtok)
    : 0;

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Auto-Fix open findings</h1>
        <p className="text-gray-600 max-w-3xl">
          Run a single trusted model across every open audit finding. Each proposal lands in a review queue with the original text, the proposed rewrite, and the model's rationale. <span className="font-semibold text-gray-900">Nothing gets applied without your explicit click</span> — the benchmark showed even frontier models can over-correct on regional findings.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Open findings</div>
          <div className="text-3xl font-bold text-gray-900">{openFindings.length}</div>
          <div className="flex gap-2 mt-2 text-[11px]">
            {(['critical', 'red', 'amber', 'green'] as const).map(l => (
              <span key={l} className="flex items-center gap-1">
                <span className="w-2 h-2 rounded-full" style={{ backgroundColor: trafficLightColor(l) }} />
                <span className="text-gray-500">{severityCounts[l] || 0}</span>
              </span>
            ))}
          </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Chosen model</div>
          <select
            value={chosenModelId}
            onChange={e => setChosenModelId(e.target.value)}
            className="text-base font-semibold text-gray-900 bg-transparent border-b border-gray-200 focus:border-cyan-700 outline-none w-full"
          >
            {models.map(m => (
              <option key={m.id} value={m.id}>{m.label}</option>
            ))}
          </select>
          {chosenModel && (
            <div className="text-xs text-gray-500 mt-1">{chosenModel.description}</div>
          )}
        </div>

        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Estimated cost</div>
          <div className="text-3xl font-bold text-gray-900">${estimatedCost.toFixed(2)}</div>
          <div className="text-xs text-gray-400 mt-1">
            ~upper bound for {openFindings.length} fixes
          </div>
        </div>
      </div>

      <div className="bg-white border border-gray-200 rounded-2xl p-5 mb-6">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-lg font-semibold text-gray-900">What will be fixed</h2>
          <span className="text-xs text-gray-400">all open findings on the latest audit run</span>
        </div>
        {openFindings.length === 0 ? (
          <div className="text-gray-500 text-sm text-center py-8">
            No open findings. Run an audit first.
          </div>
        ) : (
          <div className="max-h-72 overflow-y-auto space-y-1">
            {openFindings.slice(0, 100).map(f => {
              const light = scoreToTrafficLight(f.score);
              return (
                <div key={f.id} className="flex items-center gap-3 px-2 py-1.5 text-xs border-b border-gray-50">
                  <span className="font-bold tabular-nums w-10 text-right" style={{ color: trafficLightColor(light) }}>
                    {Math.round(f.score)}%
                  </span>
                  <span className="text-gray-400 w-32 truncate">{f.category_id}</span>
                  <span className="text-gray-700 flex-1 truncate font-medium">{f.item_label || '(unlabelled)'}</span>
                  <span className="text-gray-400 truncate max-w-[40%]">{f.description}</span>
                </div>
              );
            })}
            {openFindings.length > 100 && (
              <div className="text-xs text-gray-400 text-center py-2">
                ... and {openFindings.length - 100} more
              </div>
            )}
          </div>
        )}
      </div>

      <div className="flex items-center gap-3 mb-8">
        <button
          onClick={onStart}
          disabled={openFindings.length === 0}
          className="px-8 py-3 bg-cyan-700 text-white rounded-xl font-semibold hover:bg-cyan-800 transition text-sm disabled:bg-gray-300 disabled:cursor-not-allowed"
        >
          Run Auto-Fix on {openFindings.length} findings
        </button>
        <span className="text-xs text-gray-400">
          Using {chosenModel?.label || chosenModelId}
        </span>
      </div>

      {recentRuns.length > 0 && (
        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <h2 className="text-lg font-semibold text-gray-900 mb-3">Previous auto-fix runs</h2>
          <div className="space-y-2">
            {recentRuns.map(r => (
              <button
                key={r.id}
                onClick={() => onOpenRun(r.id)}
                className="w-full text-left bg-gray-50 hover:bg-gray-100 rounded-xl p-3 transition flex items-center justify-between"
              >
                <div>
                  <div className="text-sm font-medium text-gray-900">
                    {r.candidate_models[0]?.label || 'Unknown model'} · {r.finding_ids.length} findings
                  </div>
                  <div className="text-xs text-gray-500">
                    {new Date(r.created_at).toLocaleString('en-GB')}
                  </div>
                </div>
                <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                  r.status === 'completed' ? 'bg-green-50 text-green-700' :
                  r.status === 'failed' ? 'bg-red-50 text-red-700' :
                  'bg-amber-50 text-amber-700'
                }`}>
                  {r.status}
                </span>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

// ============================================================
// RUNNING
// ============================================================

function RunningView({
  progress, fixes,
}: {
  progress: { done: number; total: number; current: string };
  fixes: ProposedFix[];
}) {
  const pct = progress.total > 0 ? Math.round((progress.done / progress.total) * 100) : 0;

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Generating fixes...</h1>
        <p className="text-gray-600">{progress.current ? `Currently: ${progress.current}` : 'Starting...'}</p>
      </div>

      <div className="bg-white border border-gray-200 rounded-2xl p-6 mb-6">
        <div className="flex items-center justify-between mb-3">
          <span className="text-sm font-medium text-gray-900">{progress.done} of {progress.total} fixed</span>
          <span className="text-2xl font-bold text-cyan-700">{pct}%</span>
        </div>
        <div className="w-full bg-gray-100 rounded-full h-3">
          <div className="h-3 rounded-full bg-cyan-600 transition-all duration-500" style={{ width: `${pct}%` }} />
        </div>
      </div>

      <div className="bg-white border border-gray-200 rounded-2xl p-5">
        <h3 className="font-semibold text-gray-900 text-sm mb-3">Live fix feed</h3>
        {fixes.length === 0 ? (
          <p className="text-xs text-gray-400 italic">Waiting for first proposals...</p>
        ) : (
          <div className="space-y-2 max-h-[400px] overflow-y-auto">
            {fixes.slice(-30).reverse().map(f => (
              <div key={f.id} className="border border-gray-100 rounded-lg p-3 text-xs">
                <div className="flex items-center justify-between mb-1">
                  <span className="font-semibold text-gray-700">{f.original_text || '(no original)'}</span>
                  <span className={`px-2 py-0.5 rounded-full ${f.status === 'completed' ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'}`}>
                    {f.status} {f.latency_ms ? `· ${(f.latency_ms / 1000).toFixed(1)}s` : ''}
                  </span>
                </div>
                {f.status === 'completed' ? (
                  <p className="text-gray-600 line-clamp-2">→ {f.proposed_text}</p>
                ) : (
                  <p className="text-red-600">{f.error_message}</p>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ============================================================
// REVIEW
// ============================================================

function ReviewView({
  fixes, applyStates, onApply, onReject, onReset,
}: {
  fixes: ProposedFix[];
  applyStates: Record<string, ApplyState>;
  onApply: (fix: ProposedFix, sourceField: string) => Promise<boolean>;
  onReject: (fixId: string) => void;
  onReset: () => void;
}) {
  const [filter, setFilter] = useState<'all' | 'pending' | 'applied' | 'failed' | 'flagged'>('pending');
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());

  const completed = fixes.filter(f => f.status === 'completed');
  const failed = fixes.filter(f => f.status === 'failed');

  // A fix is "flagged" for extra scrutiny if its length differs significantly
  // from the original (>40% delta) — that's the heuristic for over-correction
  // we saw in the benchmark (Opus replacing US facts with UK equivalents
  // produced a substantially different-length string).
  function isFlagged(f: ProposedFix): boolean {
    if (!f.original_text || !f.proposed_text) return false;
    const orig = f.original_text.length;
    const prop = f.proposed_text.length;
    if (orig === 0) return prop > 60;
    const ratio = prop / orig;
    return ratio < 0.6 || ratio > 1.6;
  }

  const filtered = (() => {
    if (filter === 'failed') return failed;
    if (filter === 'flagged') return completed.filter(isFlagged);
    if (filter === 'applied') return completed.filter(f => applyStates[f.id] === 'applied');
    if (filter === 'pending') {
      return completed.filter(f => {
        const state = applyStates[f.id];
        return !state || state === 'pending';
      });
    }
    return [...completed, ...failed];
  })();

  const allSelected = filtered.length > 0 && filtered.every(f => selectedIds.has(f.id));
  const appliedCount = Object.values(applyStates).filter(s => s === 'applied').length;
  const flaggedCount = completed.filter(isFlagged).length;

  function toggleAll() {
    if (allSelected) {
      setSelectedIds(new Set());
    } else {
      setSelectedIds(new Set(filtered.map(f => f.id)));
    }
  }

  function toggleOne(id: string) {
    setSelectedIds(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id); else next.add(id);
      return next;
    });
  }

  async function applySelected() {
    const targets = filtered.filter(f => selectedIds.has(f.id) && applyStates[f.id] !== 'applied');
    for (const fix of targets) {
      const sourceField = fix.source_field || 'description';
      await onApply(fix, sourceField);
    }
    setSelectedIds(new Set());
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Review proposed fixes</h1>
          <p className="text-gray-500 text-sm mt-1">
            {completed.length} fixes ready · {failed.length} failed · {flaggedCount} flagged for review · {appliedCount} applied
          </p>
        </div>
        <button onClick={onReset} className="px-4 py-2 bg-cyan-700 text-white rounded-xl text-sm font-semibold hover:bg-cyan-800 transition">
          New auto-fix
        </button>
      </div>

      <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 mb-4 text-xs text-amber-800">
        <span className="font-semibold">Heads-up:</span> review every fix before applying. The benchmark showed even frontier models can over-correct (e.g. replacing US-specific facts with UK equivalents instead of just adding a label). Look at flagged fixes first — those have unusual length deltas.
      </div>

      <div className="flex items-center gap-2 mb-4 flex-wrap">
        {(['pending', 'flagged', 'failed', 'applied', 'all'] as const).map(f => (
          <button
            key={f}
            onClick={() => { setFilter(f); setSelectedIds(new Set()); }}
            className={`px-3 py-1 text-xs rounded-full font-medium transition ${filter === f ? 'bg-cyan-700 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)} ({
              f === 'pending' ? completed.filter(c => !applyStates[c.id] || applyStates[c.id] === 'pending').length :
              f === 'flagged' ? flaggedCount :
              f === 'failed' ? failed.length :
              f === 'applied' ? appliedCount :
              fixes.length
            })
          </button>
        ))}

        {filtered.length > 0 && (
          <div className="ml-auto flex items-center gap-2">
            <button
              onClick={toggleAll}
              className="text-xs text-gray-600 hover:text-gray-900"
            >
              {allSelected ? 'Deselect all' : 'Select all'}
            </button>
            <button
              onClick={applySelected}
              disabled={selectedIds.size === 0}
              className="text-xs px-3 py-1.5 bg-cyan-700 text-white rounded-lg font-semibold hover:bg-cyan-800 disabled:bg-gray-300 disabled:cursor-not-allowed"
            >
              Apply selected ({selectedIds.size})
            </button>
          </div>
        )}
      </div>

      {filtered.length === 0 ? (
        <div className="bg-white border border-gray-200 rounded-2xl p-12 text-center text-gray-500">
          {filter === 'pending' ? 'No pending fixes — everything in this filter has been processed.' :
           filter === 'flagged' ? 'Nothing flagged for unusual length deltas. Good sign.' :
           'No fixes match this filter.'}
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map(fix => (
            <FixCard
              key={fix.id}
              fix={fix}
              flagged={isFlagged(fix)}
              applyState={applyStates[fix.id] || 'pending'}
              selected={selectedIds.has(fix.id)}
              onToggleSelect={() => toggleOne(fix.id)}
              onApply={field => onApply(fix, field)}
              onReject={() => onReject(fix.id)}
            />
          ))}
        </div>
      )}
    </div>
  );
}

function FixCard({
  fix, flagged, applyState, selected, onToggleSelect, onApply, onReject,
}: {
  fix: ProposedFix;
  flagged: boolean;
  applyState: ApplyState;
  selected: boolean;
  onToggleSelect: () => void;
  onApply: (field: string) => Promise<boolean>;
  onReject: () => void;
}) {
  const [sourceField, setSourceField] = useState(fix.source_field || 'description');
  const [expanded, setExpanded] = useState(false);
  const finding = fix.finding;

  const cardBorder =
    applyState === 'applied' ? 'border-green-300 bg-green-50/40' :
    applyState === 'rejected' ? 'border-gray-200 opacity-60' :
    flagged ? 'border-amber-300 bg-amber-50/30' :
    'border-gray-200';

  if (fix.status === 'failed') {
    return (
      <div className={`bg-white border rounded-2xl p-4 ${cardBorder}`}>
        <div className="text-sm font-semibold text-gray-900">{finding?.item_label || fix.finding_id}</div>
        <div className="text-xs text-red-600 bg-red-50 rounded p-2 mt-2">{fix.error_message || 'Failed'}</div>
      </div>
    );
  }

  return (
    <div className={`bg-white border rounded-2xl p-5 transition ${cardBorder}`}>
      <div className="flex items-start gap-3">
        {applyState !== 'applied' && applyState !== 'rejected' && (
          <input
            type="checkbox"
            checked={selected}
            onChange={onToggleSelect}
            className="mt-1 accent-cyan-600 cursor-pointer"
          />
        )}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1 flex-wrap">
            {finding && (
              <span className="text-xs font-bold" style={{ color: trafficLightColor(scoreToTrafficLight(finding.score)) }}>
                {Math.round(finding.score)}%
              </span>
            )}
            {finding && (
              <>
                <span className="text-xs text-gray-500">{finding.category_id}</span>
                <span className="text-xs text-gray-300">·</span>
                <span className="text-xs text-gray-500">{finding.sub_criterion}</span>
                <span className="text-xs text-gray-300">·</span>
                <span className="text-xs text-gray-500">{finding.content_area}</span>
              </>
            )}
            {flagged && (
              <span className="text-[10px] px-2 py-0.5 bg-amber-100 text-amber-800 rounded-full font-semibold">
                FLAGGED · unusual length
              </span>
            )}
            {applyState === 'applied' && (
              <span className="text-[10px] px-2 py-0.5 bg-green-100 text-green-800 rounded-full font-semibold">APPLIED</span>
            )}
            {applyState === 'rejected' && (
              <span className="text-[10px] px-2 py-0.5 bg-gray-100 text-gray-600 rounded-full font-semibold">REJECTED</span>
            )}
            {applyState === 'failed' && (
              <span className="text-[10px] px-2 py-0.5 bg-red-100 text-red-700 rounded-full font-semibold">FAILED</span>
            )}
          </div>

          <div className="text-base font-semibold text-gray-900">{finding?.item_label || '(unlabelled)'}</div>
          {finding?.description && (
            <div className="text-sm text-gray-600 mt-0.5">{finding.description}</div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mt-3">
            <div>
              <div className="text-[10px] uppercase tracking-wider text-gray-400 font-semibold mb-1">Original</div>
              <div className="text-sm text-gray-800 bg-gray-50 rounded-lg p-3 whitespace-pre-wrap">
                {fix.original_text || finding?.evidence || <span className="italic text-gray-400">(no original captured)</span>}
              </div>
            </div>
            <div>
              <div className="text-[10px] uppercase tracking-wider text-cyan-700 font-semibold mb-1">Proposed</div>
              <div className="text-sm text-gray-900 bg-cyan-50/60 border border-cyan-100 rounded-lg p-3 whitespace-pre-wrap">
                {fix.proposed_text}
              </div>
            </div>
          </div>

          {fix.rationale && (
            <button
              onClick={() => setExpanded(!expanded)}
              className="text-[11px] text-gray-500 hover:text-gray-800 mt-2 italic"
            >
              {expanded ? '▾' : '▸'} model rationale
            </button>
          )}
          {expanded && fix.rationale && (
            <div className="text-xs text-gray-600 italic mt-1">{fix.rationale}</div>
          )}

          <div className="flex items-center gap-3 mt-3">
            <label className="text-xs text-gray-500 flex items-center gap-1">
              Field:
              <input
                type="text"
                value={sourceField}
                onChange={e => setSourceField(e.target.value)}
                disabled={applyState === 'applied'}
                className="px-2 py-1 border border-gray-200 rounded text-xs font-mono w-32 disabled:bg-gray-50"
              />
            </label>

            <div className="ml-auto flex items-center gap-2">
              {applyState !== 'applied' && applyState !== 'rejected' && (
                <button
                  onClick={onReject}
                  className="text-xs px-3 py-1.5 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200"
                >
                  Reject
                </button>
              )}
              {applyState === 'applied' ? (
                <span className="text-xs px-3 py-1.5 bg-green-100 text-green-800 rounded-lg font-semibold">
                  Applied ✓
                </span>
              ) : applyState === 'applying' ? (
                <span className="text-xs px-3 py-1.5 bg-cyan-100 text-cyan-800 rounded-lg font-semibold">
                  Applying...
                </span>
              ) : (
                <button
                  onClick={() => onApply(sourceField)}
                  disabled={!sourceField}
                  className="text-xs px-4 py-1.5 bg-cyan-700 text-white rounded-lg font-semibold hover:bg-cyan-800 disabled:bg-gray-300"
                >
                  Apply this fix
                </button>
              )}
            </div>
          </div>

          <div className="flex items-center gap-3 mt-2 text-[10px] text-gray-400">
            <span>{fix.model_label}</span>
            {fix.latency_ms ? <span>· {(fix.latency_ms / 1000).toFixed(1)}s</span> : null}
            {fix.cost_usd !== null ? <span>· ${fix.cost_usd?.toFixed(4)}</span> : null}
            {fix.original_text && fix.proposed_text ? (
              <span>· length {fix.original_text.length} → {fix.proposed_text.length} ({Math.round((fix.proposed_text.length / fix.original_text.length - 1) * 100)}%)</span>
            ) : null}
          </div>
        </div>
      </div>
    </div>
  );
}
