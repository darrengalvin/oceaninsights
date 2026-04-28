'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import { scoreToTrafficLight, trafficLightColor, trafficLightLabel } from '@/lib/audit/types';
import type { AuditRun, AuditFinding, AuditCitation } from '@/lib/audit/types';
import { AUDIT_CATEGORIES } from '@/lib/audit/criteria';
import { CONTENT_AREAS } from '@/lib/audit/areas';

interface AreaSummary {
  label: string;
  avg_score: number;
  item_count: number;
  findings: number;
}

type ViewState = 'landing' | 'running' | 'results';

export default function AuditDashboardPage() {
  const [view, setView] = useState<ViewState>('landing');
  const [run, setRun] = useState<AuditRun | null>(null);
  const [areaSummary, setAreaSummary] = useState<Record<string, AreaSummary>>({});
  const [previousScore, setPreviousScore] = useState<number | null>(null);
  const [findings, setFindings] = useState<AuditFinding[]>([]);
  const [citations, setCitations] = useState<AuditCitation[]>([]);
  const [runs, setRuns] = useState<AuditRun[]>([]);
  const [loading, setLoading] = useState(true);
  const [runId, setRunId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [completedAreas, setCompletedAreas] = useState<string[]>([]);
  const [currentArea, setCurrentArea] = useState<string | null>(null);
  const [currentPhase, setCurrentPhase] = useState<string>('');
  const [currentItemCount, setCurrentItemCount] = useState(0);
  const [areaScores, setAreaScores] = useState<Record<string, number>>({});
  const [liveStats, setLiveStats] = useState({ items: 0, findings: 0, critical: 0, citations: 0 });
  const [areaError, setAreaError] = useState<string | null>(null);
  const [phaseStartTime, setPhaseStartTime] = useState<number>(Date.now());
  const [elapsedSeconds, setElapsedSeconds] = useState(0);

  const fetchAll = useCallback(async (targetRunId?: string) => {
    const params = targetRunId ? `?run_id=${targetRunId}` : '';
    const [resResult] = await Promise.all([
      fetch(`/api/audit/results${params}`).then(r => r.json()).catch(() => ({})),
      fetch(`/api/audit/findings?limit=500${targetRunId ? `&run_id=${targetRunId}` : ''}`).then(r => r.json()).then(d => setFindings(d.findings || [])).catch(() => {}),
      fetch('/api/audit/citations?limit=500').then(r => r.json()).then(d => setCitations(d.citations || [])).catch(() => {}),
      fetch('/api/audit/run').then(r => r.json()).then(d => setRuns(d.runs || [])).catch(() => {}),
    ]);
    if (resResult.run) setRun(resResult.run);
    if (resResult.area_summary) setAreaSummary(resResult.area_summary);
    if (resResult.previous_score !== undefined) setPreviousScore(resResult.previous_score);
  }, []);

  // Timer for elapsed seconds during running
  useEffect(() => {
    if (view !== 'running') return;
    const timer = setInterval(() => {
      setElapsedSeconds(Math.floor((Date.now() - phaseStartTime) / 1000));
    }, 1000);
    return () => clearInterval(timer);
  }, [view, phaseStartTime]);

  useEffect(() => {
    async function init() {
      setLoading(true);
      try {
        const res = await fetch('/api/audit/results');
        const data = await res.json();
        if (data.run) {
          setRun(data.run);
          if (data.area_summary) setAreaSummary(data.area_summary);
          if (data.previous_score !== undefined) setPreviousScore(data.previous_score);
          await fetchAll();
          setView('results');
        }
      } catch { /* no results yet */ }
      setLoading(false);
    }
    init();
  }, [fetchAll]);

  async function startAudit() {
    setError(null);
    setCompletedAreas([]);
    setFindings([]);
    setCitations([]);
    setAreaScores({});
    setLiveStats({ items: 0, findings: 0, critical: 0, citations: 0 });
    setView('running');

    try {
      // Step 1: Create the run
      const createRes = await fetch('/api/audit/run', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: '{}',
      });
      const createData = await createRes.json();
      if (!createRes.ok) throw new Error(createData.error || 'Failed to start audit');

      const activeRunId = createData.run_id;
      const areas: string[] = createData.areas;
      setRunId(activeRunId);
      setRun(prev => prev ? { ...prev, areas_total: areas.length, status: 'running' as const } : null);

      let totalItems = 0;
      let totalFindings = 0;
      let totalCritical = 0;
      const scores: Record<string, number> = {};

      // Step 2: Process each area sequentially
      for (let i = 0; i < areas.length; i++) {
        const areaId = areas[i];
        const areaLabel = CONTENT_AREAS.find(a => a.id === areaId)?.label || areaId;

        setCurrentArea(areaId);
        setAreaError(null);
        setPhaseStartTime(Date.now());
        setCurrentPhase(`Analysing ${areaLabel}...`);
        setCurrentItemCount(0);

        try {
          const controller = new AbortController();
          const timeout = setTimeout(() => controller.abort(), 110000);

          const areaRes = await fetch('/api/audit/run-area', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              run_id: activeRunId,
              area_id: areaId,
              area_index: i,
              areas_total: areas.length,
            }),
            signal: controller.signal,
          });
          clearTimeout(timeout);

          const areaData = await areaRes.json();

          if (!areaRes.ok) {
            setAreaError(`${areaLabel}: ${areaData.error || 'Failed'}`);
          } else if (areaData.status === 'skipped') {
            setAreaError(null);
          } else {
            totalItems += areaData.items || 0;
            totalFindings += areaData.findings || 0;
            totalCritical += areaData.critical || 0;
            if (areaData.score !== null) scores[areaId] = areaData.score;
            setAreaError(null);
          }

          setCompletedAreas(prev => [...prev, areaId]);
          setAreaScores({ ...scores });
          setLiveStats({ items: totalItems, findings: totalFindings, critical: totalCritical, citations: 0 });

          const findingsRes = await fetch(`/api/audit/findings?run_id=${activeRunId}&limit=50`);
          const findingsData = await findingsRes.json();
          if (findingsData.findings) setFindings(findingsData.findings);

          const citRes = await fetch('/api/audit/citations?limit=100');
          const citData = await citRes.json();
          if (citData.citations) {
            setCitations(citData.citations);
            setLiveStats(prev => ({ ...prev, citations: citData.citations.length }));
          }

          setPhaseStartTime(Date.now());
          setCurrentPhase(`${areaLabel} complete`);
        } catch (err) {
          const msg = err instanceof Error ? err.message : 'Unknown error';
          setAreaError(`${areaLabel}: ${msg.includes('abort') ? 'Timed out (>110s)' : msg}`);
          setCompletedAreas(prev => [...prev, areaId]);
        }
      }

      // Step 3: Finalise the run
      const allScores = Object.values(scores);
      const systemScore = allScores.length > 0
        ? Math.round(allScores.reduce((a, b) => a + b, 0) / allScores.length * 100) / 100
        : null;

      await fetch('/api/audit/run', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ run_id: activeRunId, status: 'completed', system_score: systemScore }),
      });

      setCurrentPhase('Audit complete');
      setCurrentArea(null);
      await fetchAll(activeRunId);
      setView('results');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Audit failed');
      setView('landing');
    }
  }

  async function updateFindingStatus(id: string, status: string) {
    await fetch('/api/audit/findings', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id, status }),
    });
    const res = await fetch('/api/audit/findings?limit=500');
    const data = await res.json();
    if (data.findings) setFindings(data.findings);
  }

  async function updateCitation(id: string, verification_status: string) {
    await fetch('/api/audit/citations', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id, verification_status, verified_by: 'admin' }),
    });
    const res = await fetch('/api/audit/citations?limit=500');
    const data = await res.json();
    if (data.citations) setCitations(data.citations);
  }

  if (loading) {
    return (
      <div className="p-8 flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <div className="w-8 h-8 border-2 border-cyan-700 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
          <p className="text-gray-500 text-sm">Loading audit system...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto">
      {error && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm">{error}</div>
      )}

      {view === 'landing' && <LandingView onStartAudit={startAudit} hasHistory={runs.length > 0} onViewResults={() => setView('results')} />}
      {view === 'running' && <RunningView run={run} completedAreas={completedAreas} currentArea={currentArea} currentPhase={currentPhase} currentItemCount={currentItemCount} findings={findings} liveStats={liveStats} areaScores={areaScores} areaError={areaError} elapsedSeconds={elapsedSeconds} />}
      {view === 'results' && <ResultsView run={run} areaSummary={areaSummary} previousScore={previousScore} findings={findings} citations={citations} runs={runs} onNewAudit={startAudit} onUpdateFinding={updateFindingStatus} onUpdateCitation={updateCitation} />}
    </div>
  );
}

// ============================================================
// LANDING VIEW - Explains what the audit does before you run it
// ============================================================

function LandingView({ onStartAudit, hasHistory, onViewResults }: { onStartAudit: () => void; hasHistory: boolean; onViewResults: () => void }) {
  const [showAllCriteria, setShowAllCriteria] = useState(false);

  return (
    <div>
      {/* Hero */}
      <div className="mb-10">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Content Audit</h1>
        <p className="text-gray-600 max-w-2xl">
          This system reviews every piece of content in the app against 14 compliance categories using AI-powered analysis. Each content item is scored 0-100% and graded with a traffic light system.
        </p>
      </div>

      {/* What will be audited */}
      <div className="bg-white border border-gray-200 rounded-2xl p-6 mb-8">
        <h2 className="text-lg font-semibold text-gray-900 mb-1">What gets audited</h2>
        <p className="text-sm text-gray-500 mb-4">{CONTENT_AREAS.length} content areas covering every piece of user-facing content in the app</p>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
          {CONTENT_AREAS.map(area => (
            <div key={area.id} className="flex items-center gap-2 px-3 py-2 bg-gray-50 rounded-lg text-sm text-gray-700">
              <div className="w-1.5 h-1.5 rounded-full bg-cyan-500 flex-shrink-0" />
              {area.label}
            </div>
          ))}
        </div>
      </div>

      {/* The 14 criteria */}
      <div className="bg-white border border-gray-200 rounded-2xl p-6 mb-8">
        <h2 className="text-lg font-semibold text-gray-900 mb-1">14 Grading Criteria</h2>
        <p className="text-sm text-gray-500 mb-4">Every content item is scored against each applicable criterion</p>

        <div className="space-y-3">
          {(showAllCriteria ? AUDIT_CATEGORIES : AUDIT_CATEGORIES.slice(0, 5)).map((cat, i) => (
            <div key={cat.id} className="border border-gray-100 rounded-xl p-4">
              <div className="flex items-start justify-between">
                <div className="flex items-start gap-3">
                  <span className="text-xs font-bold text-cyan-700 bg-cyan-50 rounded-full w-6 h-6 flex items-center justify-center flex-shrink-0 mt-0.5">{i + 1}</span>
                  <div>
                    <h3 className="font-semibold text-gray-900 text-sm">{cat.label}</h3>
                    <p className="text-xs text-gray-500 mt-0.5">{cat.description}</p>
                    <div className="flex flex-wrap gap-1.5 mt-2">
                      {cat.sub_criteria.map(sc => (
                        <span key={sc.id} className="text-[10px] px-2 py-0.5 bg-gray-50 text-gray-500 rounded-full">{sc.label}</span>
                      ))}
                    </div>
                  </div>
                </div>
                <span className={`text-[10px] px-2 py-0.5 rounded-full font-medium flex-shrink-0 ${cat.weight >= 1.5 ? 'bg-red-50 text-red-600' : cat.weight >= 1.2 ? 'bg-amber-50 text-amber-600' : 'bg-gray-50 text-gray-500'}`}>
                  {cat.weight}x weight
                </span>
              </div>
            </div>
          ))}
        </div>

        {!showAllCriteria && (
          <button onClick={() => setShowAllCriteria(true)} className="mt-3 text-sm text-cyan-700 hover:text-cyan-800 font-medium">
            Show all {AUDIT_CATEGORIES.length} criteria →
          </button>
        )}
      </div>

      {/* Scoring explanation */}
      <div className="bg-white border border-gray-200 rounded-2xl p-6 mb-8">
        <h2 className="text-lg font-semibold text-gray-900 mb-3">Scoring System</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {[
            { range: '90-100%', light: 'green' as const, label: 'Meets Standard', desc: 'No action required' },
            { range: '70-89%', light: 'amber' as const, label: 'Review Recommended', desc: 'Minor issues to address' },
            { range: '50-69%', light: 'red' as const, label: 'Action Required', desc: 'Must be fixed' },
            { range: '0-49%', light: 'critical' as const, label: 'Immediate Action', desc: 'Safety or legal risk' },
          ].map(tier => (
            <div key={tier.range} className="border border-gray-100 rounded-xl p-4 text-center">
              <div className="w-4 h-4 rounded-full mx-auto mb-2" style={{ backgroundColor: trafficLightColor(tier.light) }} />
              <div className="text-sm font-bold text-gray-900">{tier.range}</div>
              <div className="text-xs text-gray-600 mt-0.5">{tier.label}</div>
              <div className="text-[10px] text-gray-400 mt-0.5">{tier.desc}</div>
            </div>
          ))}
        </div>
        <p className="text-xs text-gray-400 mt-3">
          Safety-critical categories (Safety, Clinical Boundaries, Safeguarding, OPSEC) are weighted at 1.5x. Factual Accuracy, Regional, and Currency at 1.2x.
        </p>
      </div>

      {/* Action buttons */}
      <div className="flex items-center gap-4">
        <button onClick={onStartAudit} className="px-8 py-3 bg-cyan-700 text-white rounded-xl font-semibold hover:bg-cyan-800 transition text-sm">
          Run Full Audit
        </button>
        {hasHistory && (
          <button onClick={onViewResults} className="px-6 py-3 border border-gray-300 text-gray-700 rounded-xl font-medium hover:bg-gray-50 transition text-sm">
            View Previous Results
          </button>
        )}
      </div>
    </div>
  );
}

// ============================================================
// RUNNING VIEW - Live progress as the audit executes
// ============================================================

function RunningView({ run, completedAreas, currentArea, currentPhase, currentItemCount, findings, liveStats, areaScores, areaError, elapsedSeconds }: {
  run: AuditRun | null;
  completedAreas: string[];
  currentArea: string | null;
  currentPhase: string;
  currentItemCount: number;
  findings: AuditFinding[];
  liveStats: { items: number; findings: number; critical: number; citations: number };
  areaScores: Record<string, number>;
  areaError: string | null;
  elapsedSeconds: number;
}) {
  const total = run?.areas_total || CONTENT_AREAS.length;
  const completed = completedAreas.length;
  const progress = total > 0 ? (completed / total) * 100 : 0;
  const currentAreaLabel = CONTENT_AREAS.find(a => a.id === currentArea)?.label || currentArea;

  const completedSet = new Set(completedAreas);

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Audit in Progress</h1>
        <p className="text-gray-600">Reviewing {total} content areas against 14 compliance criteria</p>
      </div>

      {/* Main progress */}
      <div className="bg-white border border-gray-200 rounded-2xl p-6 mb-6">
        <div className="flex items-center justify-between mb-3">
          <div>
            <div className="text-sm font-medium text-gray-900">
              {completed} of {total} areas completed
            </div>
            {currentAreaLabel && (
              <div className="text-sm text-cyan-700 mt-0.5">
                Currently reviewing: <span className="font-semibold">{currentAreaLabel}</span>
                {currentItemCount ? ` (${currentItemCount} items)` : ''}
              </div>
            )}
          </div>
          <span className="text-2xl font-bold text-cyan-700">{Math.round(progress)}%</span>
        </div>

        {/* Progress bar */}
        <div className="w-full bg-gray-100 rounded-full h-3 mb-3">
          <div className="h-3 rounded-full bg-cyan-600 transition-all duration-500" style={{ width: `${progress}%` }} />
        </div>

        {/* Phase indicator */}
        {currentPhase && (
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 text-xs text-gray-500">
              <div className="w-2 h-2 rounded-full bg-cyan-500 animate-pulse" />
              {currentPhase}
            </div>
            <span className="text-xs text-gray-400 tabular-nums">{elapsedSeconds}s</span>
          </div>
        )}
        {areaError && (
          <div className="mt-2 text-xs text-amber-600 bg-amber-50 rounded-lg px-3 py-2">
            {areaError} — skipping to next area
          </div>
        )}
      </div>

      {/* Two-column: area checklist + live findings */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Content area checklist */}
        <div className="bg-white border border-gray-200 rounded-2xl p-5">
          <h3 className="font-semibold text-gray-900 text-sm mb-3">Content Areas</h3>
          <div className="space-y-1 max-h-[400px] overflow-y-auto">
            {CONTENT_AREAS.map(area => {
              const isDone = completedSet.has(area.id);
              const isCurrent = currentArea === area.id;
              return (
                <div key={area.id} className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs ${isCurrent ? 'bg-cyan-50 text-cyan-800 font-medium' : isDone ? 'text-gray-500' : 'text-gray-400'}`}>
                  {isDone ? (
                    <svg className="w-4 h-4 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" /></svg>
                  ) : isCurrent ? (
                    <div className="w-4 h-4 flex items-center justify-center flex-shrink-0">
                      <div className="w-2 h-2 rounded-full bg-cyan-500 animate-pulse" />
                    </div>
                  ) : (
                    <div className="w-4 h-4 flex items-center justify-center flex-shrink-0">
                      <div className="w-1.5 h-1.5 rounded-full bg-gray-300" />
                    </div>
                  )}
                  <span className="flex-1">{area.label}</span>
                  {isDone && areaScores[area.id] !== undefined && (
                    <span className="text-xs font-bold" style={{ color: trafficLightColor(scoreToTrafficLight(areaScores[area.id])) }}>
                      {Math.round(areaScores[area.id])}%
                    </span>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Live stats + recent findings */}
        <div className="space-y-4">
          {/* Live counters */}
          <div className="bg-white border border-gray-200 rounded-2xl p-5">
            <h3 className="font-semibold text-gray-900 text-sm mb-3">Live Statistics</h3>
            <div className="grid grid-cols-2 gap-3">
              <Stat label="Items Scored" value={liveStats.items} />
              <Stat label="Findings" value={liveStats.findings} />
              <Stat label="Citations Found" value={liveStats.citations} color="#6366f1" />
              <Stat label="Critical Issues" value={liveStats.critical} color={liveStats.critical ? '#dc2626' : '#22c55e'} />
            </div>
          </div>

          {/* Recent findings feed */}
          <div className="bg-white border border-gray-200 rounded-2xl p-5">
            <h3 className="font-semibold text-gray-900 text-sm mb-3">
              Live Findings Feed
              {findings.length > 0 && <span className="text-xs text-gray-400 font-normal ml-2">({findings.length} total)</span>}
            </h3>
            <div className="space-y-2 max-h-[250px] overflow-y-auto">
              {findings.length === 0 ? (
                <p className="text-xs text-gray-400 italic">Findings will appear here as content is reviewed...</p>
              ) : (
                findings.slice(0, 20).map(f => {
                  const light = scoreToTrafficLight(f.score);
                  return (
                    <div key={f.id} className="flex items-start gap-2 text-xs border-b border-gray-50 pb-2">
                      <div className="w-2 h-2 rounded-full mt-1 flex-shrink-0" style={{ backgroundColor: trafficLightColor(light) }} />
                      <div>
                        <span className="font-medium text-gray-700">{f.item_label}</span>
                        <span className="text-gray-400 mx-1">·</span>
                        <span className="text-gray-500">{f.description}</span>
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function Stat({ label, value, color }: { label: string; value: number; color?: string }) {
  return (
    <div className="bg-gray-50 rounded-xl p-3">
      <div className="text-lg font-bold" style={{ color: color || '#111827' }}>{value}</div>
      <div className="text-[10px] text-gray-500 uppercase tracking-wider">{label}</div>
    </div>
  );
}

// ============================================================
// RESULTS VIEW - After audit completes
// ============================================================

function ResultsView({ run, areaSummary, previousScore, findings, citations, runs, onNewAudit, onUpdateFinding, onUpdateCitation }: {
  run: AuditRun | null;
  areaSummary: Record<string, AreaSummary>;
  previousScore: number | null;
  findings: AuditFinding[];
  citations: AuditCitation[];
  runs: AuditRun[];
  onNewAudit: () => void;
  onUpdateFinding: (id: string, status: string) => void;
  onUpdateCitation: (id: string, status: string) => void;
}) {
  const [tab, setTab] = useState<'areas' | 'findings' | 'citations' | 'history'>('areas');

  const systemScore = run?.system_score ?? null;
  const systemLight = systemScore !== null ? scoreToTrafficLight(systemScore) : null;
  const scoreDelta = systemScore !== null && previousScore !== null ? systemScore - previousScore : null;

  return (
    <div>
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Audit Results</h1>
          <p className="text-gray-500 text-sm mt-1">
            {run ? new Date(run.completed_at || run.started_at).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : ''}
            {run ? ` · ${run.total_items_scored} items scored across ${run.areas_total} content areas` : ''}
          </p>
        </div>
        <div className="flex gap-2">
          <a href="/admin/audit/benchmark" className="px-4 py-2 bg-purple-700 text-white rounded-xl text-sm font-semibold hover:bg-purple-800 transition">
            Fix Benchmark
          </a>
          <a href="/api/audit/report" target="_blank" className="px-4 py-2 bg-gray-900 text-white rounded-xl text-sm font-semibold hover:bg-gray-800 transition">
            Full Report
          </a>
          <a href="/api/audit/export?format=csv" target="_blank" className="px-4 py-2 border border-gray-300 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-50 transition">
            CSV Export
          </a>
          <button onClick={onNewAudit} className="px-4 py-2 bg-cyan-700 text-white rounded-xl text-sm font-semibold hover:bg-cyan-800 transition">
            Run New Audit
          </button>
        </div>
      </div>

      {/* Score banner */}
      <div className="bg-white border border-gray-200 rounded-2xl p-6 mb-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-6">
            <div>
              <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Overall Content Health</div>
              <div className="flex items-center gap-3">
                <span className="text-4xl font-bold" style={{ color: systemLight ? trafficLightColor(systemLight) : '#6b7280' }}>
                  {systemScore !== null ? `${Math.round(systemScore)}%` : '—'}
                </span>
                {systemLight && <div className="w-4 h-4 rounded-full" style={{ backgroundColor: trafficLightColor(systemLight) }} />}
                {scoreDelta !== null && (
                  <span className={`text-sm font-semibold ${scoreDelta >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                    {scoreDelta >= 0 ? '↑' : '↓'} {Math.abs(Math.round(scoreDelta))}% from last audit
                  </span>
                )}
              </div>
              {systemLight && <div className="text-xs mt-1" style={{ color: trafficLightColor(systemLight) }}>{trafficLightLabel(systemLight)}</div>}
            </div>
          </div>
          <div className="grid grid-cols-4 gap-4 text-center">
            <MiniStat label="Critical" value={run?.findings_critical || 0} color="#dc2626" />
            <MiniStat label="Action Required" value={run?.findings_red || 0} color="#ef4444" />
            <MiniStat label="Review" value={run?.findings_amber || 0} color="#f59e0b" />
            <MiniStat label="Passing" value={run?.findings_green || 0} color="#22c55e" />
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200 mb-6">
        <nav className="flex gap-6">
          {([
            ['areas', `Content Areas (${Object.keys(areaSummary).length})`],
            ['findings', `Findings (${findings.filter(f => f.status === 'open').length} open)`],
            ['citations', `Citations (${citations.length})`],
            ['history', `History (${runs.filter(r => r.status === 'completed').length} runs)`],
          ] as [typeof tab, string][]).map(([id, label]) => (
            <button key={id} onClick={() => setTab(id)} className={`pb-3 text-sm font-medium border-b-2 transition ${tab === id ? 'border-cyan-700 text-cyan-700' : 'border-transparent text-gray-500 hover:text-gray-700'}`}>
              {label}
            </button>
          ))}
        </nav>
      </div>

      {tab === 'areas' && <AreasGrid areaSummary={areaSummary} />}
      {tab === 'findings' && <FindingsList findings={findings} onUpdate={onUpdateFinding} />}
      {tab === 'citations' && <CitationsList citations={citations} onUpdate={onUpdateCitation} />}
      {tab === 'history' && <HistoryList runs={runs} />}
    </div>
  );
}

function MiniStat({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <div>
      <div className="text-xl font-bold" style={{ color }}>{value}</div>
      <div className="text-[10px] text-gray-400">{label}</div>
    </div>
  );
}

function AreasGrid({ areaSummary }: { areaSummary: Record<string, AreaSummary> }) {
  const areas = Object.entries(areaSummary).sort((a, b) => a[1].avg_score - b[1].avg_score);

  if (areas.length === 0) return <div className="text-gray-500 text-center py-12">No results yet.</div>;

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {areas.map(([id, area]) => {
        const light = scoreToTrafficLight(area.avg_score);
        return (
          <div key={id} className="bg-white border border-gray-200 rounded-xl p-5 hover:shadow-md transition">
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-semibold text-gray-900 text-sm">{area.label.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase())}</h3>
              <div className="w-3 h-3 rounded-full" style={{ backgroundColor: trafficLightColor(light) }} title={trafficLightLabel(light)} />
            </div>
            <div className="flex items-end justify-between">
              <div>
                <span className="text-2xl font-bold" style={{ color: trafficLightColor(light) }}>{Math.round(area.avg_score)}%</span>
                <span className="text-xs text-gray-400 ml-2">{area.item_count} items</span>
              </div>
              {area.findings > 0 && (
                <span className="text-xs bg-red-50 text-red-600 px-2 py-1 rounded-full font-medium">{area.findings} findings</span>
              )}
            </div>
            <div className="mt-3 w-full bg-gray-100 rounded-full h-2">
              <div className="h-2 rounded-full transition-all" style={{ width: `${Math.min(area.avg_score, 100)}%`, backgroundColor: trafficLightColor(light) }} />
            </div>
          </div>
        );
      })}
    </div>
  );
}

function FindingsList({ findings, onUpdate }: { findings: AuditFinding[]; onUpdate: (id: string, status: string) => void }) {
  const [statusFilter, setStatusFilter] = useState('open');
  const [groupBy, setGroupBy] = useState<'category' | 'area' | 'severity'>('category');

  const filtered = statusFilter === 'all' ? findings : findings.filter(f => f.status === statusFilter);

  const grouped: Record<string, AuditFinding[]> = {};
  for (const f of filtered) {
    let key: string;
    if (groupBy === 'category') key = f.category_id;
    else if (groupBy === 'area') key = f.content_area;
    else {
      const light = scoreToTrafficLight(f.score);
      key = light === 'critical' ? '0-critical' : light === 'red' ? '1-red' : light === 'amber' ? '2-amber' : '3-green';
    }
    if (!grouped[key]) grouped[key] = [];
    grouped[key].push(f);
  }

  const sortedGroups = Object.entries(grouped).sort((a, b) => {
    if (groupBy === 'severity') return a[0].localeCompare(b[0]);
    const avgA = a[1].reduce((s, f) => s + f.score, 0) / a[1].length;
    const avgB = b[1].reduce((s, f) => s + f.score, 0) / b[1].length;
    return avgA - avgB;
  });

  function groupLabel(key: string): { title: string; desc: string } {
    if (groupBy === 'category') {
      const cat = AUDIT_CATEGORIES.find(c => c.id === key);
      return { title: cat?.label || key, desc: cat?.description || '' };
    }
    if (groupBy === 'area') {
      const area = CONTENT_AREAS.find(a => a.id === key);
      return { title: area?.label || key, desc: '' };
    }
    const labels: Record<string, { title: string; desc: string }> = {
      '0-critical': { title: 'Immediate Action Required (0-49%)', desc: 'These findings pose a safety, legal, or reputational risk.' },
      '1-red': { title: 'Action Required (50-69%)', desc: 'These findings must be fixed before external review.' },
      '2-amber': { title: 'Review Recommended (70-89%)', desc: 'Minor issues that should be improved.' },
      '3-green': { title: 'Minor Notes (90%+)', desc: 'Low-priority observations.' },
    };
    return labels[key] || { title: key, desc: '' };
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <div className="flex gap-2">
          {['open', 'all', 'acknowledged', 'resolved', 'wont_fix'].map(s => (
            <button key={s} onClick={() => setStatusFilter(s)} className={`px-3 py-1 text-xs rounded-full font-medium transition ${statusFilter === s ? 'bg-cyan-700 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
              {s === 'wont_fix' ? "Won't Fix" : s.charAt(0).toUpperCase() + s.slice(1)} ({s === 'all' ? findings.length : findings.filter(f => f.status === s).length})
            </button>
          ))}
        </div>
        <div className="flex gap-1 text-xs">
          <span className="text-gray-400 mr-1">Group:</span>
          {(['category', 'area', 'severity'] as const).map(g => (
            <button key={g} onClick={() => setGroupBy(g)} className={`px-2 py-1 rounded font-medium transition ${groupBy === g ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
              {g.charAt(0).toUpperCase() + g.slice(1)}
            </button>
          ))}
        </div>
      </div>

      {filtered.length === 0 ? (
        <div className="text-gray-500 text-center py-12">No findings match this filter.</div>
      ) : (
        <div className="space-y-6">
          {sortedGroups.map(([key, items]) => {
            const { title, desc } = groupLabel(key);
            return (
              <div key={key}>
                <div className="mb-2">
                  <h3 className="text-sm font-semibold text-gray-900">{title} <span className="text-gray-400 font-normal">({items.length})</span></h3>
                  {desc && <p className="text-xs text-gray-500">{desc}</p>}
                </div>
                <div className="space-y-2">
                  {items.sort((a, b) => a.score - b.score).map(f => {
                    const light = scoreToTrafficLight(f.score);
                    return (
                      <div key={f.id} className="bg-white border border-gray-200 rounded-xl p-4">
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="flex items-center gap-2 mb-1">
                              <div className="w-2.5 h-2.5 rounded-full flex-shrink-0" style={{ backgroundColor: trafficLightColor(light) }} />
                              <span className="text-xs font-bold" style={{ color: trafficLightColor(light) }}>{Math.round(f.score)}%</span>
                              <span className="text-xs text-gray-400">{f.sub_criterion}</span>
                              {groupBy !== 'area' && <span className="text-xs text-gray-300">· {f.content_area}</span>}
                            </div>
                            <p className="text-sm text-gray-900 font-medium">{f.item_label}</p>
                            <p className="text-sm text-gray-600 mt-0.5">{f.description}</p>
                            {f.evidence && <p className="text-xs text-gray-400 mt-1 italic">"{f.evidence}"</p>}
                            {f.suggested_action && (
                              <div className="mt-2 text-xs text-cyan-800 bg-cyan-50 rounded-lg px-3 py-2 flex items-start justify-between gap-3">
                                <div><span className="font-semibold">Suggested action:</span> {f.suggested_action}</div>
                                <a
                                  href={`/admin/audit/benchmark?finding=${f.id}`}
                                  className="text-[11px] px-2 py-1 bg-purple-700 text-white rounded font-semibold hover:bg-purple-800 whitespace-nowrap"
                                >
                                  Fix it →
                                </a>
                              </div>
                            )}
                          </div>
                          <div className="flex gap-1 ml-4 flex-shrink-0">
                            {f.status === 'open' && (
                              <>
                                <button onClick={() => onUpdate(f.id, 'acknowledged')} className="text-xs px-2 py-1 bg-amber-50 text-amber-700 rounded hover:bg-amber-100">Ack</button>
                                <button onClick={() => onUpdate(f.id, 'resolved')} className="text-xs px-2 py-1 bg-green-50 text-green-700 rounded hover:bg-green-100">Resolve</button>
                              </>
                            )}
                            {f.status === 'acknowledged' && (
                              <button onClick={() => onUpdate(f.id, 'resolved')} className="text-xs px-2 py-1 bg-green-50 text-green-700 rounded hover:bg-green-100">Resolve</button>
                            )}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function CitationsList({ citations, onUpdate }: { citations: AuditCitation[]; onUpdate: (id: string, status: string) => void }) {
  const [typeFilter, setTypeFilter] = useState('all');
  const filtered = typeFilter === 'all' ? citations : citations.filter(c => c.claim_type === typeFilter);
  const statusColor: Record<string, string> = { unverified: '#6b7280', verified: '#22c55e', disputed: '#ef4444', stale: '#f59e0b' };

  return (
    <div>
      <div className="flex gap-2 mb-4">
        {['all', 'medical', 'legal', 'statistical', 'research', 'historical'].map(t => (
          <button key={t} onClick={() => setTypeFilter(t)} className={`px-3 py-1 text-xs rounded-full font-medium transition ${typeFilter === t ? 'bg-cyan-700 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
            {t === 'all' ? 'All' : t.charAt(0).toUpperCase() + t.slice(1)}
          </button>
        ))}
      </div>

      {filtered.length === 0 ? (
        <div className="text-gray-500 text-center py-12">No citations found.</div>
      ) : (
        <div className="space-y-2">
          {filtered.map(c => (
            <div key={c.id} className="bg-white border border-gray-200 rounded-xl p-4">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-xs font-medium px-2 py-0.5 rounded-full" style={{ backgroundColor: `${statusColor[c.verification_status]}15`, color: statusColor[c.verification_status] }}>
                      {c.verification_status}
                    </span>
                    <span className="text-xs text-gray-400 bg-gray-50 px-2 py-0.5 rounded-full">{c.claim_type}</span>
                  </div>
                  <p className="text-sm text-gray-900">"{c.claim_text}"</p>
                  <p className="text-xs text-gray-400 mt-0.5">{c.content_area} · {c.source_table}</p>
                </div>
                <div className="flex gap-1 ml-4 flex-shrink-0">
                  {c.verification_status === 'unverified' && (
                    <>
                      <button onClick={() => onUpdate(c.id, 'verified')} className="text-xs px-2 py-1 bg-green-50 text-green-700 rounded hover:bg-green-100">Verify</button>
                      <button onClick={() => onUpdate(c.id, 'disputed')} className="text-xs px-2 py-1 bg-red-50 text-red-700 rounded hover:bg-red-100">Dispute</button>
                    </>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function HistoryList({ runs }: { runs: AuditRun[] }) {
  const completed = runs.filter(r => r.status === 'completed' && r.system_score !== null);
  if (completed.length === 0) return <div className="text-gray-500 text-center py-12">No completed runs yet.</div>;

  return (
    <div>
      {/* Trend chart */}
      {completed.length >= 2 && (
        <div className="bg-white border border-gray-200 rounded-2xl p-6 mb-6">
          <h3 className="font-semibold text-gray-900 text-sm mb-4">Score Trend</h3>
          <div className="flex items-end gap-2 h-28">
            {completed.slice().reverse().slice(-12).map(r => {
              const score = r.system_score || 0;
              const light = scoreToTrafficLight(score);
              return (
                <div key={r.id} className="flex-1 flex flex-col items-center gap-1">
                  <span className="text-[10px] font-bold" style={{ color: trafficLightColor(light) }}>{Math.round(score)}%</span>
                  <div className="w-full bg-gray-100 rounded-t flex-1 relative min-h-[4px]">
                    <div className="absolute bottom-0 w-full rounded-t" style={{ height: `${score}%`, backgroundColor: trafficLightColor(light) }} />
                  </div>
                  <span className="text-[9px] text-gray-400">
                    {new Date(r.completed_at || r.started_at).toLocaleDateString('en-GB', { day: '2-digit', month: 'short' })}
                  </span>
                </div>
              );
            })}
          </div>
        </div>
      )}

      <div className="space-y-2">
        {completed.map(r => {
          const light = scoreToTrafficLight(r.system_score || 0);
          return (
            <div key={r.id} className="bg-white border border-gray-200 rounded-xl p-4 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-3 h-3 rounded-full" style={{ backgroundColor: trafficLightColor(light) }} />
                <span className="text-sm font-semibold" style={{ color: trafficLightColor(light) }}>{Math.round(r.system_score || 0)}%</span>
                <span className="text-xs text-gray-500">
                  {new Date(r.completed_at || r.started_at).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
                </span>
              </div>
              <div className="flex gap-4 text-xs text-gray-500">
                <span>{r.total_items_scored} items</span>
                <span>{r.total_findings} findings</span>
                {(r.findings_critical || 0) > 0 && <span className="text-red-600 font-medium">{r.findings_critical} critical</span>}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
