'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';

interface CultureValue {
  id: string;
  name: string;
  emoji: string;
  description: string;
  daily_challenge: string;
  sort_order: number;
  is_active: boolean;
}

interface CultureScenario {
  id: string;
  scenario: string;
  correct_value: string;
  explanation: string;
  sort_order: number;
  is_active: boolean;
}

export default function ServiceCultureEditorPage() {
  const [tab, setTab] = useState<'values' | 'scenarios'>('values');
  const [values, setValues] = useState<CultureValue[]>([]);
  const [scenarios, setScenarios] = useState<CultureScenario[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingValue, setEditingValue] = useState<CultureValue | null>(null);
  const [editingScenario, setEditingScenario] = useState<CultureScenario | null>(null);

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [valRes, scenRes] = await Promise.all([
      supabaseAdmin.from('culture_values').select('*').order('sort_order'),
      supabaseAdmin.from('culture_scenarios').select('*').order('sort_order'),
    ]);
    setValues(valRes.data || []);
    setScenarios(scenRes.data || []);
    setLoading(false);
  }

  async function saveValue(v: CultureValue) {
    const payload = {
      name: v.name, emoji: v.emoji, description: v.description,
      daily_challenge: v.daily_challenge, sort_order: v.sort_order,
      is_active: v.is_active, updated_at: new Date().toISOString(),
    };
    if (v.id) {
      await supabaseAdmin.from('culture_values').update(payload).eq('id', v.id);
    } else {
      await supabaseAdmin.from('culture_values').insert(payload);
    }
    setEditingValue(null);
    fetchAll();
  }

  async function deleteValue(id: string) {
    if (!confirm('Delete this value?')) return;
    await supabaseAdmin.from('culture_values').delete().eq('id', id);
    fetchAll();
  }

  async function saveScenario(s: CultureScenario) {
    const payload = {
      scenario: s.scenario, correct_value: s.correct_value,
      explanation: s.explanation, sort_order: s.sort_order,
      is_active: s.is_active, updated_at: new Date().toISOString(),
    };
    if (s.id) {
      await supabaseAdmin.from('culture_scenarios').update(payload).eq('id', s.id);
    } else {
      await supabaseAdmin.from('culture_scenarios').insert(payload);
    }
    setEditingScenario(null);
    fetchAll();
  }

  async function deleteScenario(id: string) {
    if (!confirm('Delete this scenario?')) return;
    await supabaseAdmin.from('culture_scenarios').delete().eq('id', id);
    fetchAll();
  }

  if (loading) {
    return <div className="p-8"><div className="animate-pulse h-8 bg-gray-200 rounded w-1/4"></div></div>;
  }

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <a href="/admin/content-manager" className="text-cyan-600 text-sm hover:underline">&larr; Content Manager</a>
        <h1 className="text-3xl font-bold text-gray-900 mt-2">Service Culture (C2 Drill)</h1>
        <p className="text-gray-500">Manage values, scenarios, and daily challenges</p>
      </div>

      <div className="flex gap-2 mb-6">
        {(['values', 'scenarios'] as const).map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
              tab === t ? 'bg-cyan-100 text-cyan-800' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}>
            {t === 'values' ? `Values (${values.length})` : `Scenarios (${scenarios.length})`}
          </button>
        ))}
      </div>

      {/* Values Tab */}
      {tab === 'values' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Core Values</h2>
            <button onClick={() => setEditingValue({ id: '', name: '', emoji: '⭐', description: '', daily_challenge: '', sort_order: values.length + 1, is_active: true })}
              className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">+ Add Value</button>
          </div>

          {editingValue && (
            <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
              <div className="grid grid-cols-4 gap-3">
                <div>
                  <label className="text-xs text-gray-600">Name</label>
                  <input value={editingValue.name} onChange={(e) => setEditingValue({ ...editingValue, name: e.target.value })}
                    className="w-full border rounded-lg px-3 py-2" />
                </div>
                <div>
                  <label className="text-xs text-gray-600">Emoji</label>
                  <input value={editingValue.emoji} onChange={(e) => setEditingValue({ ...editingValue, emoji: e.target.value })}
                    className="w-full border rounded-lg px-3 py-2 text-2xl text-center" />
                </div>
                <div>
                  <label className="text-xs text-gray-600">Order</label>
                  <input type="number" value={editingValue.sort_order} onChange={(e) => setEditingValue({ ...editingValue, sort_order: parseInt(e.target.value) || 0 })}
                    className="w-full border rounded-lg px-3 py-2" />
                </div>
                <div className="flex items-end">
                  <label className="flex items-center gap-2 text-sm">
                    <input type="checkbox" checked={editingValue.is_active} onChange={(e) => setEditingValue({ ...editingValue, is_active: e.target.checked })} />
                    Active
                  </label>
                </div>
              </div>
              <div>
                <label className="text-xs text-gray-600">Description</label>
                <textarea value={editingValue.description} onChange={(e) => setEditingValue({ ...editingValue, description: e.target.value })}
                  className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} />
              </div>
              <div>
                <label className="text-xs text-gray-600">Daily Challenge</label>
                <textarea value={editingValue.daily_challenge} onChange={(e) => setEditingValue({ ...editingValue, daily_challenge: e.target.value })}
                  className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} />
              </div>
              <div className="flex gap-2">
                <button onClick={() => saveValue(editingValue)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
                <button onClick={() => setEditingValue(null)} className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm">Cancel</button>
              </div>
            </div>
          )}

          <div className="space-y-3">
            {values.map((v) => (
              <div key={v.id} className={`bg-white border rounded-xl p-4 ${!v.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-2xl">{v.emoji}</span>
                      <span className="font-semibold text-gray-900">{v.name}</span>
                      <span className="text-xs bg-gray-100 px-2 py-0.5 rounded">#{v.sort_order}</span>
                    </div>
                    <p className="text-sm text-gray-600">{v.description}</p>
                    <p className="text-xs text-amber-700 mt-1">Challenge: {v.daily_challenge}</p>
                  </div>
                  <div className="flex gap-2 ml-4">
                    <button onClick={() => setEditingValue(v)} className="text-cyan-600 text-sm hover:underline">Edit</button>
                    <button onClick={() => deleteValue(v.id)} className="text-red-500 text-sm hover:underline">Delete</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Scenarios Tab */}
      {tab === 'scenarios' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Scenario Challenges</h2>
            <button onClick={() => setEditingScenario({ id: '', scenario: '', correct_value: 'Courage', explanation: '', sort_order: scenarios.length + 1, is_active: true })}
              className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">+ Add Scenario</button>
          </div>

          {editingScenario && (
            <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
              <div className="grid grid-cols-4 gap-3">
                <div>
                  <label className="text-xs text-gray-600">Correct Value</label>
                  <select value={editingScenario.correct_value} onChange={(e) => setEditingScenario({ ...editingScenario, correct_value: e.target.value })}
                    className="w-full border rounded-lg px-3 py-2">
                    {['Courage', 'Commitment', 'Respect', 'Discipline', 'Integrity', 'Loyalty'].map((v) => (
                      <option key={v} value={v}>{v}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="text-xs text-gray-600">Order</label>
                  <input type="number" value={editingScenario.sort_order} onChange={(e) => setEditingScenario({ ...editingScenario, sort_order: parseInt(e.target.value) || 0 })}
                    className="w-full border rounded-lg px-3 py-2" />
                </div>
                <div className="col-span-2 flex items-end">
                  <label className="flex items-center gap-2 text-sm">
                    <input type="checkbox" checked={editingScenario.is_active} onChange={(e) => setEditingScenario({ ...editingScenario, is_active: e.target.checked })} />
                    Active
                  </label>
                </div>
              </div>
              <div>
                <label className="text-xs text-gray-600">Scenario</label>
                <textarea value={editingScenario.scenario} onChange={(e) => setEditingScenario({ ...editingScenario, scenario: e.target.value })}
                  className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} />
              </div>
              <div>
                <label className="text-xs text-gray-600">Explanation</label>
                <textarea value={editingScenario.explanation} onChange={(e) => setEditingScenario({ ...editingScenario, explanation: e.target.value })}
                  className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} />
              </div>
              <div className="flex gap-2">
                <button onClick={() => saveScenario(editingScenario)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
                <button onClick={() => setEditingScenario(null)} className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm">Cancel</button>
              </div>
            </div>
          )}

          <div className="space-y-3">
            {scenarios.map((s) => (
              <div key={s.id} className={`bg-white border rounded-xl p-4 ${!s.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-xs bg-cyan-100 text-cyan-800 px-2 py-0.5 rounded font-medium">{s.correct_value}</span>
                      <span className="text-xs bg-gray-100 px-2 py-0.5 rounded">#{s.sort_order}</span>
                    </div>
                    <p className="text-sm text-gray-900 font-medium">{s.scenario}</p>
                    <p className="text-xs text-gray-500 mt-1 italic">{s.explanation}</p>
                  </div>
                  <div className="flex gap-2 ml-4">
                    <button onClick={() => setEditingScenario(s)} className="text-cyan-600 text-sm hover:underline">Edit</button>
                    <button onClick={() => deleteScenario(s.id)} className="text-red-500 text-sm hover:underline">Delete</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
