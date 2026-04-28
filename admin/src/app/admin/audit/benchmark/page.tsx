'use client';

import { useState, useEffect, useCallback } from 'react';
import { scoreToTrafficLight, trafficLightColor } from '@/lib/audit/types';
import type { AuditFinding } from '@/lib/audit/types';
import type { BenchmarkModel } from '@/lib/audit/models';

type View = 'setup' | 'running' | 'results';

interface BenchmarkRun {
  id: string;
  status: 'created' | 'proposing' | 'judging' | 'completed' | 'failed';
  finding_ids: string[];
  candidate_models: { id: string; label: string; thinking_mode: string; anonymous_label: string }[];
  judge_models: { id: string; label: string }[];
  total_cost_usd: number | null;
  total_latency_ms: number | null;
  winner_model_id: string | null;
  notes: string | null;
  created_at: string;
  completed_at: string | null;
}

interface BenchmarkFix {
  id: string;
  finding_id: string;
  model_id: string;
  model_label: string;
  anonymous_label: string;
  proposed_text: string;
  rationale: string | null;
  source_field: string | null;
  status: 'pending' | 'completed' | 'failed';
  error_message: string | null;
  latency_ms: number | null;
  cost_usd: number | null;
  input_tokens: number | null;
  output_tokens: number | null;
  reasoning_tokens: number | null;
  original_text: string | null;
}

interface FixAggregate extends BenchmarkFix {
  mean_overall_excl_self: number;
  mean_resolves: number;
  mean_safety: number;
  mean_tone: number;
  mean_conciseness: number;
  mean_faithfulness: number;
  judgments_received: number;
  self_vote_overall: number | null;
}

interface ModelLeaderboard {
  model_id: string;
  model_label: string;
  mean_overall_excl_self: number;
  mean_resolves: number;
  mean_safety: number;
  mean_tone: number;
  mean_conciseness: number;
  mean_faithfulness: number;
  judgments_received: number;
  fixes_produced: number;
  fixes_failed: number;
  avg_latency_ms: number;
  total_cost_usd: number;
  self_vote_overall: number | null;
  wins: number;
}

interface RunResults {
  run: BenchmarkRun;
  findings: AuditFinding[];
  fixes: BenchmarkFix[];
  leaderboard: {
    models: ModelLeaderboard[];
    fixes: FixAggregate[];
    finding_winners: { finding_id: string; winner_fix_id: string; winner_model_id: string; winner_score: number }[];
  };
}

export default function BenchmarkPage() {
  const [view, setView] = useState<View>('setup');
  const [models, setModels] = useState<BenchmarkModel[]>([]);
  const [findings, setFindings] = useState<AuditFinding[]>([]);
  const [selectedFindings, setSelectedFindings] = useState<Set<string>>(new Set());
  const [selectedCandidates, setSelectedCandidates] = useState<Set<string>>(new Set());
  const [selectedJudges, setSelectedJudges] = useState<Set<string>>(new Set());
  const [recentRuns, setRecentRuns] = useState<BenchmarkRun[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Running state
  const [activeRunId, setActiveRunId] = useState<string | null>(null);
  const [progress, setProgress] = useState({ phase: '', findingIndex: 0, total: 0 });
  const [liveFixes, setLiveFixes] = useState<BenchmarkFix[]>([]);

  // Results state
  const [results, setResults] = useState<RunResults | null>(null);

  const loadInitial = useCallback(async () => {
    setLoading(true);
    try {
      const [findingsRes, runsRes] = await Promise.all([
        fetch('/api/audit/findings?status=open&limit=50').then(r => r.json()),
        fetch('/api/audit/benchmark?limit=10').then(r => r.json()),
      ]);
      setFindings(findingsRes.findings || []);
      setRecentRuns(runsRes.runs || []);
      setModels(runsRes.available_models || []);

      // Default selections: all candidates ticked, all judges ticked.
      if (runsRes.available_models?.length) {
        const allModelIds = new Set<string>(
          (runsRes.available_models as BenchmarkModel[]).map(m => m.id)
        );
        setSelectedCandidates(allModelIds);
        setSelectedJudges(allModelIds);
      }

      // Pre-select via query param if arriving from the "Fix it →" CTA on a
      // specific finding; otherwise default to the 3 lowest-scoring findings.
      const url = new URL(window.location.href);
      const findingFromUrl = url.searchParams.get('finding');
      if (findingFromUrl) {
        setSelectedFindings(new Set([findingFromUrl]));
      } else if (findingsRes.findings?.length) {
        const sorted = [...findingsRes.findings].sort(
          (a: AuditFinding, b: AuditFinding) => a.score - b.score
        );
        setSelectedFindings(new Set(sorted.slice(0, 3).map((f: AuditFinding) => f.id)));
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load');
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    loadInitial();
  }, [loadInitial]);

  async function startBenchmark() {
    setError(null);
    if (selectedFindings.size === 0) {
      setError('Pick at least one finding to test');
      return;
    }
    if (selectedCandidates.size < 2) {
      setError('Pick at least two candidate models — there is nothing to compare otherwise');
      return;
    }
    if (selectedJudges.size === 0) {
      setError('Pick at least one judge model');
      return;
    }

    setView('running');
    setLiveFixes([]);
    setProgress({ phase: 'Creating benchmark run', findingIndex: 0, total: selectedFindings.size });

    try {
      const createRes = await fetch('/api/audit/benchmark', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          finding_ids: Array.from(selectedFindings),
          candidate_model_ids: Array.from(selectedCandidates),
          judge_model_ids: Array.from(selectedJudges),
        }),
      });
      const createData = await createRes.json();
      if (!createRes.ok) throw new Error(createData.error || 'Failed to create run');

      const runId: string = createData.run.id;
      setActiveRunId(runId);

      const findingIds = Array.from(selectedFindings);

      // Stage A: propose fixes per finding (sequential per finding so the UI
      // can show progress, but parallel across models within each finding).
      for (let i = 0; i < findingIds.length; i++) {
        setProgress({
          phase: `Proposing fixes (${i + 1}/${findingIds.length})`,
          findingIndex: i,
          total: findingIds.length,
        });
        const res = await fetch('/api/audit/benchmark/propose', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ benchmark_run_id: runId, finding_id: findingIds[i] }),
        });
        const data = await res.json();
        if (data.fixes) setLiveFixes(prev => [...prev, ...data.fixes]);
      }

      // Stage B: judging — same sequential-by-finding pattern.
      for (let i = 0; i < findingIds.length; i++) {
        setProgress({
          phase: `Judging fixes (${i + 1}/${findingIds.length})`,
          findingIndex: i,
          total: findingIds.length,
        });
        await fetch('/api/audit/benchmark/judge', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ benchmark_run_id: runId, finding_id: findingIds[i] }),
        });
      }

      // Stage C: finalise.
      setProgress({ phase: 'Aggregating results', findingIndex: findingIds.length, total: findingIds.length });
      await fetch(`/api/audit/benchmark/${runId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'completed' }),
      });

      const resultsRes = await fetch(`/api/audit/benchmark/${runId}`);
      const resultsData = await resultsRes.json();
      setResults(resultsData);
      setView('results');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Benchmark failed');
      setView('setup');
    }
  }

  async function loadExistingRun(runId: string) {
    setError(null);
    setLoading(true);
    try {
      const res = await fetch(`/api/audit/benchmark/${runId}`);
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to load run');
      setResults(data);
      setActiveRunId(runId);
      setView('results');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load');
    }
    setLoading(false);
  }

  if (loading && view === 'setup') {
    return (
      <div className="p-8 flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <div className="w-8 h-8 border-2 border-cyan-700 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
          <p className="text-gray-500 text-sm">Loading benchmark system...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto">
      <div className="mb-6 flex items-center gap-3 text-xs text-gray-500">
        <a href="/admin/audit" className="hover:text-gray-700">Audit</a>
        <span>/</span>
        <span className="text-gray-700">Model Benchmark</span>
      </div>

      {error && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm">{error}</div>
      )}

      {view === 'setup' && (
        <SetupView
          models={models}
          findings={findings}
          selectedFindings={selectedFindings}
          setSelectedFindings={setSelectedFindings}
          selectedCandidates={selectedCandidates}
          setSelectedCandidates={setSelectedCandidates}
          selectedJudges={selectedJudges}
          setSelectedJudges={setSelectedJudges}
          recentRuns={recentRuns}
          onStart={startBenchmark}
          onOpenRun={loadExistingRun}
        />
      )}

      {view === 'running' && (
        <RunningView progress={progress} liveFixes={liveFixes} candidates={Array.from(selectedCandidates)} models={models} />
      )}

      {view === 'results' && results && (
        <ResultsView
          results={results}
          onReset={() => {
            setView('setup');
            setResults(null);
            setActiveRunId(null);
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
  models, findings, selectedFindings, setSelectedFindings,
  selectedCandidates, setSelectedCandidates, selectedJudges, setSelectedJudges,
  recentRuns, onStart, onOpenRun,
}: {
  models: BenchmarkModel[];
  findings: AuditFinding[];
  selectedFindings: Set<string>;
  setSelectedFindings: (s: Set<string>) => void;
  selectedCandidates: Set<string>;
  setSelectedCandidates: (s: Set<string>) => void;
  selectedJudges: Set<string>;
  setSelectedJudges: (s: Set<string>) => void;
  recentRuns: BenchmarkRun[];
  onStart: () => void;
  onOpenRun: (id: string) => void;
}) {
  const [groupBy, setGroupBy] = useState<'severity' | 'category'>('severity');

  const sortedFindings = [...findings].sort((a, b) => a.score - b.score);
  const groups = new Map<string, AuditFinding[]>();
  for (const f of sortedFindings) {
    const key = groupBy === 'severity'
      ? scoreToTrafficLight(f.score)
      : f.category_id;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key)!.push(f);
  }

  function toggle<T>(set: Set<T>, item: T): Set<T> {
    const next = new Set(set);
    if (next.has(item)) next.delete(item); else next.add(item);
    return next;
  }

  const estimatedCost = estimateRunCost(
    models.filter(m => selectedCandidates.has(m.id)),
    models.filter(m => selectedJudges.has(m.id)),
    selectedFindings.size
  );

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Model Benchmark</h1>
        <p className="text-gray-600 max-w-3xl">
          Pick a sample of findings and a set of models. Every candidate proposes a fix for each finding. Then every judge model scores all the fixes — anonymised, shuffled — on a 5-axis rubric. The winner is the model with the highest average score across peers (self-votes excluded).
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Findings selected</div>
          <div className="text-3xl font-bold text-gray-900">{selectedFindings.size}</div>
          <div className="text-xs text-gray-400 mt-1">{findings.length} open findings available</div>
        </div>
        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Models in run</div>
          <div className="text-3xl font-bold text-gray-900">
            {selectedCandidates.size}<span className="text-base font-normal text-gray-400"> candidates · {selectedJudges.size} judges</span>
          </div>
        </div>
        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Estimated cost</div>
          <div className="text-3xl font-bold text-gray-900">${estimatedCost.toFixed(2)}</div>
          <div className="text-xs text-gray-400 mt-1">~rough upper bound, all-in</div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg font-semibold text-gray-900">Candidate models</h2>
            <span className="text-xs text-gray-400">these will propose fixes</span>
          </div>
          <div className="space-y-2">
            {models.map(m => (
              <ModelToggle
                key={m.id}
                model={m}
                checked={selectedCandidates.has(m.id)}
                onChange={() => setSelectedCandidates(toggle(selectedCandidates, m.id))}
              />
            ))}
          </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg font-semibold text-gray-900">Judge models</h2>
            <span className="text-xs text-gray-400">these will score the fixes (anonymised)</span>
          </div>
          <div className="space-y-2">
            {models.map(m => (
              <ModelToggle
                key={m.id}
                model={m}
                checked={selectedJudges.has(m.id)}
                onChange={() => setSelectedJudges(toggle(selectedJudges, m.id))}
              />
            ))}
          </div>
        </div>
      </div>

      <div className="bg-white border border-gray-200 rounded-2xl p-5 mb-6">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-lg font-semibold text-gray-900">Pick findings to test</h2>
          <div className="flex gap-1 text-xs">
            <span className="text-gray-400 mr-1">Group:</span>
            {(['severity', 'category'] as const).map(g => (
              <button
                key={g}
                onClick={() => setGroupBy(g)}
                className={`px-2 py-1 rounded font-medium transition ${groupBy === g ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
              >
                {g.charAt(0).toUpperCase() + g.slice(1)}
              </button>
            ))}
          </div>
        </div>

        {findings.length === 0 ? (
          <div className="text-gray-500 text-sm text-center py-8">
            No open findings. Run an audit first or change the status filter.
          </div>
        ) : (
          <div className="space-y-4 max-h-[500px] overflow-y-auto">
            {Array.from(groups.entries()).map(([key, items]) => (
              <div key={key}>
                <div className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 sticky top-0 bg-white py-1">
                  {key} ({items.length})
                </div>
                <div className="space-y-1">
                  {items.map(f => {
                    const light = scoreToTrafficLight(f.score);
                    const checked = selectedFindings.has(f.id);
                    return (
                      <label
                        key={f.id}
                        className={`flex items-start gap-3 p-3 rounded-lg cursor-pointer transition ${checked ? 'bg-cyan-50 border border-cyan-200' : 'border border-gray-100 hover:bg-gray-50'}`}
                      >
                        <input
                          type="checkbox"
                          checked={checked}
                          onChange={() => setSelectedFindings(toggle(selectedFindings, f.id))}
                          className="mt-1 accent-cyan-600 cursor-pointer"
                        />
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-0.5">
                            <span className="text-xs font-bold" style={{ color: trafficLightColor(light) }}>{Math.round(f.score)}%</span>
                            <span className="text-xs text-gray-400">{f.category_id}</span>
                            <span className="text-xs text-gray-300">·</span>
                            <span className="text-xs text-gray-400">{f.content_area}</span>
                          </div>
                          <div className="text-sm text-gray-900 font-medium truncate">{f.item_label || '(unlabelled)'}</div>
                          <div className="text-xs text-gray-500 line-clamp-2">{f.description}</div>
                        </div>
                      </label>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="flex items-center gap-3 mb-8">
        <button
          onClick={onStart}
          disabled={selectedFindings.size === 0 || selectedCandidates.size < 2 || selectedJudges.size === 0}
          className="px-8 py-3 bg-cyan-700 text-white rounded-xl font-semibold hover:bg-cyan-800 transition text-sm disabled:bg-gray-300 disabled:cursor-not-allowed"
        >
          Run benchmark
        </button>
        <span className="text-xs text-gray-400">
          {selectedCandidates.size} candidates × {selectedFindings.size} findings × {selectedJudges.size} judges
        </span>
      </div>

      {recentRuns.length > 0 && (
        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <h2 className="text-lg font-semibold text-gray-900 mb-3">Recent runs</h2>
          <div className="space-y-2">
            {recentRuns.map(r => (
              <button
                key={r.id}
                onClick={() => onOpenRun(r.id)}
                className="w-full text-left bg-gray-50 hover:bg-gray-100 rounded-xl p-3 transition flex items-center justify-between"
              >
                <div>
                  <div className="text-sm font-medium text-gray-900">
                    {r.candidate_models.length} models · {r.finding_ids.length} findings
                  </div>
                  <div className="text-xs text-gray-500">
                    {new Date(r.created_at).toLocaleString('en-GB')}
                    {r.winner_model_id ? ` · winner: ${r.candidate_models.find(m => m.id === r.winner_model_id)?.label || r.winner_model_id}` : ''}
                  </div>
                </div>
                <div className="text-right">
                  <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                    r.status === 'completed' ? 'bg-green-50 text-green-700' :
                    r.status === 'failed' ? 'bg-red-50 text-red-700' :
                    'bg-amber-50 text-amber-700'
                  }`}>
                    {r.status}
                  </span>
                  {r.total_cost_usd !== null && (
                    <div className="text-xs text-gray-400 mt-0.5">${r.total_cost_usd?.toFixed(2)}</div>
                  )}
                </div>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

function ModelToggle({ model, checked, onChange }: { model: BenchmarkModel; checked: boolean; onChange: () => void }) {
  return (
    <label className={`flex items-start gap-3 p-3 rounded-xl cursor-pointer transition ${checked ? 'bg-cyan-50 border border-cyan-200' : 'border border-gray-100 hover:bg-gray-50'}`}>
      <input type="checkbox" checked={checked} onChange={onChange} className="mt-0.5 accent-cyan-600 cursor-pointer" />
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 flex-wrap">
          <span className="text-sm font-semibold text-gray-900">{model.label}</span>
          <span className="text-[10px] uppercase tracking-wider text-gray-500 bg-gray-100 px-1.5 py-0.5 rounded">{model.provider}</span>
        </div>
        <div className="text-xs text-gray-500 mt-0.5">{model.description}</div>
        <div className="text-[11px] text-gray-400 mt-1">
          ${model.inputCostPerMtok}/in · ${model.outputCostPerMtok}/out per MTok
        </div>
      </div>
    </label>
  );
}

function estimateRunCost(candidates: BenchmarkModel[], judges: BenchmarkModel[], findingCount: number): number {
  // Rough order-of-magnitude estimate. Assume ~1500 input tokens per fix
  // prompt and ~600 output tokens per fix; ~2500 in / ~700 out per judge call
  // (multiplied by candidate count because the judge sees all fixes).
  const fixCost = candidates.reduce((s, m) => {
    const inCost = (1500 / 1_000_000) * m.inputCostPerMtok;
    const outCost = (600 / 1_000_000) * m.outputCostPerMtok;
    return s + (inCost + outCost) * findingCount;
  }, 0);
  const judgeCost = judges.reduce((s, m) => {
    const inTokens = 1500 + 800 * candidates.length;
    const outTokens = 200 * candidates.length;
    const inCost = (inTokens / 1_000_000) * m.inputCostPerMtok;
    const outCost = (outTokens / 1_000_000) * m.outputCostPerMtok;
    return s + (inCost + outCost) * findingCount;
  }, 0);
  return fixCost + judgeCost;
}

// ============================================================
// RUNNING
// ============================================================

function RunningView({
  progress, liveFixes, candidates, models,
}: {
  progress: { phase: string; findingIndex: number; total: number };
  liveFixes: BenchmarkFix[];
  candidates: string[];
  models: BenchmarkModel[];
}) {
  const pct = progress.total > 0 ? Math.round((progress.findingIndex / progress.total) * 100) : 0;
  const candidateModels = models.filter(m => candidates.includes(m.id));

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Benchmark running</h1>
        <p className="text-gray-600">{progress.phase}</p>
      </div>

      <div className="bg-white border border-gray-200 rounded-2xl p-6 mb-6">
        <div className="flex items-center justify-between mb-3">
          <span className="text-sm font-medium text-gray-900">{progress.findingIndex} of {progress.total} findings</span>
          <span className="text-2xl font-bold text-cyan-700">{pct}%</span>
        </div>
        <div className="w-full bg-gray-100 rounded-full h-3">
          <div className="h-3 rounded-full bg-cyan-600 transition-all duration-500" style={{ width: `${pct}%` }} />
        </div>
        <div className="flex items-center gap-2 mt-3 text-xs text-gray-500">
          <div className="w-2 h-2 rounded-full bg-cyan-500 animate-pulse" />
          {progress.phase}
        </div>
      </div>

      <div className="bg-white border border-gray-200 rounded-2xl p-5">
        <h3 className="font-semibold text-gray-900 text-sm mb-3">Live fix feed ({liveFixes.length})</h3>
        {liveFixes.length === 0 ? (
          <p className="text-xs text-gray-400 italic">Waiting for first proposals...</p>
        ) : (
          <div className="space-y-2 max-h-[400px] overflow-y-auto">
            {liveFixes.slice(-30).reverse().map(f => (
              <div key={f.id} className="border border-gray-100 rounded-lg p-3 text-xs">
                <div className="flex items-center justify-between mb-1">
                  <span className="font-semibold text-gray-700">{f.model_label}</span>
                  <span className={`px-2 py-0.5 rounded-full ${f.status === 'completed' ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'}`}>
                    {f.status} {f.latency_ms ? `· ${(f.latency_ms / 1000).toFixed(1)}s` : ''}
                  </span>
                </div>
                {f.status === 'completed' ? (
                  <p className="text-gray-600 line-clamp-2">{f.proposed_text}</p>
                ) : (
                  <p className="text-red-600">{f.error_message}</p>
                )}
              </div>
            ))}
          </div>
        )}
        <div className="mt-3 text-xs text-gray-400">
          Models in this run: {candidateModels.map(m => m.label).join(', ')}
        </div>
      </div>
    </div>
  );
}

// ============================================================
// RESULTS
// ============================================================

function ResultsView({ results, onReset }: { results: RunResults; onReset: () => void }) {
  const [tab, setTab] = useState<'leaderboard' | 'findings'>('leaderboard');
  const [appliedFixIds, setAppliedFixIds] = useState<Set<string>>(new Set());
  const { run, findings, leaderboard } = results;

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Benchmark results</h1>
          <p className="text-gray-500 text-sm mt-1">
            {new Date(run.created_at).toLocaleString('en-GB')} ·
            {' '}{run.candidate_models.length} candidates · {run.finding_ids.length} findings · {run.judge_models.length} judges
            {run.total_cost_usd !== null ? ` · $${run.total_cost_usd?.toFixed(4)}` : ''}
          </p>
        </div>
        <button onClick={onReset} className="px-4 py-2 bg-cyan-700 text-white rounded-xl text-sm font-semibold hover:bg-cyan-800 transition">
          New benchmark
        </button>
      </div>

      <div className="border-b border-gray-200 mb-6">
        <nav className="flex gap-6">
          {([
            ['leaderboard', `Leaderboard (${leaderboard.models.length} models)`],
            ['findings', `Findings (${findings.length})`],
          ] as [typeof tab, string][]).map(([id, label]) => (
            <button
              key={id}
              onClick={() => setTab(id)}
              className={`pb-3 text-sm font-medium border-b-2 transition ${tab === id ? 'border-cyan-700 text-cyan-700' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
            >
              {label}
            </button>
          ))}
        </nav>
      </div>

      {tab === 'leaderboard' && <Leaderboard leaderboard={leaderboard} />}
      {tab === 'findings' && (
        <FindingsBreakdown
          findings={findings}
          leaderboard={leaderboard}
          appliedFixIds={appliedFixIds}
          onApply={async (fixId, sourceField) => {
            const res = await fetch('/api/audit/benchmark/apply', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ fix_id: fixId, source_field: sourceField }),
            });
            const data = await res.json();
            if (!res.ok) {
              alert(`Apply failed: ${data.error}`);
              return false;
            }
            setAppliedFixIds(prev => new Set([...Array.from(prev), fixId]));
            return true;
          }}
        />
      )}
    </div>
  );
}

function Leaderboard({ leaderboard }: { leaderboard: RunResults['leaderboard'] }) {
  const winner = leaderboard.models[0];
  return (
    <div>
      {winner && (
        <div className="bg-gradient-to-br from-cyan-50 to-cyan-100 border border-cyan-200 rounded-2xl p-6 mb-6">
          <div className="text-xs text-cyan-700 uppercase tracking-wider mb-1 font-semibold">Winner</div>
          <div className="flex items-end gap-4">
            <div>
              <div className="text-2xl font-bold text-gray-900">{winner.model_label}</div>
              <div className="text-sm text-gray-600 mt-1">
                {winner.wins} of {leaderboard.finding_winners.length} findings · {winner.judgments_received} peer judgments
              </div>
            </div>
            <div className="ml-auto text-right">
              <div className="text-4xl font-bold text-cyan-700">{winner.mean_overall_excl_self}</div>
              <div className="text-xs text-cyan-700">peer-rated overall</div>
            </div>
          </div>
        </div>
      )}

      <div className="bg-white border border-gray-200 rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 text-xs text-gray-500 uppercase tracking-wider">
            <tr>
              <th className="text-left px-4 py-3">Model</th>
              <th className="text-right px-3 py-3">Overall</th>
              <th className="text-right px-3 py-3">Resolves</th>
              <th className="text-right px-3 py-3">Safety</th>
              <th className="text-right px-3 py-3">Tone</th>
              <th className="text-right px-3 py-3">Concise</th>
              <th className="text-right px-3 py-3">Faithful</th>
              <th className="text-right px-3 py-3">Wins</th>
              <th className="text-right px-3 py-3">Self-vote</th>
              <th className="text-right px-3 py-3">Avg Latency</th>
              <th className="text-right px-4 py-3">Cost</th>
            </tr>
          </thead>
          <tbody>
            {leaderboard.models.map((m, i) => {
              const winner = i === 0;
              return (
                <tr key={m.model_id} className={`border-t border-gray-100 ${winner ? 'bg-cyan-50/40' : ''}`}>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-bold text-gray-400 w-5">{i + 1}</span>
                      <div>
                        <div className="font-semibold text-gray-900">{m.model_label}</div>
                        {m.fixes_failed > 0 && (
                          <div className="text-[10px] text-red-600">{m.fixes_failed} failed</div>
                        )}
                      </div>
                    </div>
                  </td>
                  <td className="text-right px-3 py-3 font-bold text-gray-900">{m.mean_overall_excl_self}</td>
                  <td className="text-right px-3 py-3 text-gray-700">{m.mean_resolves}</td>
                  <td className="text-right px-3 py-3 text-gray-700">{m.mean_safety}</td>
                  <td className="text-right px-3 py-3 text-gray-700">{m.mean_tone}</td>
                  <td className="text-right px-3 py-3 text-gray-700">{m.mean_conciseness}</td>
                  <td className="text-right px-3 py-3 text-gray-700">{m.mean_faithfulness}</td>
                  <td className="text-right px-3 py-3 font-semibold text-gray-900">{m.wins}</td>
                  <td className="text-right px-3 py-3 text-gray-400">
                    {m.self_vote_overall !== null ? (
                      <span className={m.self_vote_overall - m.mean_overall_excl_self > 5 ? 'text-amber-600' : ''}>
                        {m.self_vote_overall.toFixed(0)}
                      </span>
                    ) : '—'}
                  </td>
                  <td className="text-right px-3 py-3 text-gray-500 tabular-nums">{(m.avg_latency_ms / 1000).toFixed(1)}s</td>
                  <td className="text-right px-4 py-3 text-gray-500 tabular-nums">${m.total_cost_usd.toFixed(4)}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <div className="text-xs text-gray-400 mt-3 leading-relaxed">
        Overall scores are means of peer judgments only — self-votes are excluded from the headline number but surfaced in the "Self-vote" column. A self-vote noticeably above the peer-rated overall (highlighted amber) suggests self-bias.
      </div>
    </div>
  );
}

function FindingsBreakdown({
  findings, leaderboard, appliedFixIds, onApply,
}: {
  findings: AuditFinding[];
  leaderboard: RunResults['leaderboard'];
  appliedFixIds: Set<string>;
  onApply: (fixId: string, sourceField: string) => Promise<boolean>;
}) {
  return (
    <div className="space-y-6">
      {findings.map(f => {
        const fixesForFinding = leaderboard.fixes
          .filter(fa => fa.finding_id === f.id)
          .sort((a, b) => b.mean_overall_excl_self - a.mean_overall_excl_self);
        const winner = leaderboard.finding_winners.find(w => w.finding_id === f.id);
        return (
          <div key={f.id} className="bg-white border border-gray-200 rounded-2xl p-5">
            <div className="mb-4">
              <div className="flex items-center gap-2 mb-1">
                <span className="text-xs font-bold" style={{ color: trafficLightColor(scoreToTrafficLight(f.score)) }}>
                  {Math.round(f.score)}%
                </span>
                <span className="text-xs text-gray-500">{f.category_id} · {f.sub_criterion}</span>
                <span className="text-xs text-gray-300">·</span>
                <span className="text-xs text-gray-500">{f.content_area}</span>
              </div>
              <div className="text-base font-semibold text-gray-900">{f.item_label}</div>
              <div className="text-sm text-gray-600 mt-1">{f.description}</div>
              {f.evidence && (
                <div className="mt-2 text-sm text-gray-700 bg-gray-50 rounded-lg px-3 py-2 italic">
                  &ldquo;{f.evidence}&rdquo;
                </div>
              )}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {fixesForFinding.map(fix => {
                const isWinner = winner?.winner_fix_id === fix.id;
                const applied = appliedFixIds.has(fix.id);
                return (
                  <div
                    key={fix.id}
                    className={`border rounded-xl p-4 ${isWinner ? 'border-cyan-300 bg-cyan-50/40' : 'border-gray-100'}`}
                  >
                    <div className="flex items-center justify-between mb-2">
                      <div>
                        <div className="text-xs font-semibold text-gray-900">{fix.model_label}</div>
                        <div className="text-[10px] text-gray-400">{fix.judgments_received} peer judges</div>
                      </div>
                      <div className="text-right">
                        <div className="text-xl font-bold" style={{ color: isWinner ? '#0e7490' : '#111827' }}>
                          {fix.mean_overall_excl_self}
                        </div>
                        {isWinner && <div className="text-[10px] text-cyan-700 font-semibold">winner</div>}
                      </div>
                    </div>

                    {fix.status === 'failed' ? (
                      <div className="text-xs text-red-600 bg-red-50 rounded p-2">{fix.error_message || 'Failed'}</div>
                    ) : (
                      <>
                        <div className="text-sm text-gray-800 mb-2 whitespace-pre-wrap">{fix.proposed_text}</div>
                        {fix.rationale && (
                          <div className="text-[11px] text-gray-500 italic mb-2">{fix.rationale}</div>
                        )}
                        <div className="grid grid-cols-5 gap-1 mb-3">
                          {[
                            ['R', fix.mean_resolves],
                            ['S', fix.mean_safety],
                            ['T', fix.mean_tone],
                            ['C', fix.mean_conciseness],
                            ['F', fix.mean_faithfulness],
                          ].map(([letter, score]) => (
                            <div key={letter as string} className="text-center">
                              <div className="text-[9px] text-gray-400 uppercase">{letter}</div>
                              <div className="text-xs font-semibold text-gray-700">{score}</div>
                            </div>
                          ))}
                        </div>
                        <div className="flex items-center justify-between text-[10px] text-gray-400 mb-2">
                          <span>{fix.latency_ms ? `${(fix.latency_ms / 1000).toFixed(1)}s` : ''}</span>
                          <span>{fix.cost_usd !== null ? `$${fix.cost_usd?.toFixed(4)}` : ''}</span>
                        </div>
                        <button
                          disabled={applied || !fix.source_field}
                          onClick={async () => {
                            if (applied) return;
                            const field = prompt(
                              'Apply this fix to which source field?',
                              fix.source_field || ''
                            );
                            if (!field) return;
                            await onApply(fix.id, field);
                          }}
                          className={`w-full text-xs px-3 py-1.5 rounded-lg font-medium transition ${
                            applied
                              ? 'bg-green-100 text-green-800 cursor-not-allowed'
                              : isWinner
                                ? 'bg-cyan-700 text-white hover:bg-cyan-800'
                                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                          }`}
                        >
                          {applied ? 'Applied ✓' : 'Apply this fix'}
                        </button>
                      </>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        );
      })}
    </div>
  );
}
