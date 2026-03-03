'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';

interface FlipCard {
  id: string;
  emoji: string;
  judgement: string;
  reality: string;
  sort_order: number;
  is_active: boolean;
}

interface ReactScenario {
  id: string;
  scenario: string;
  reveal: string;
  best_reaction_index: number;
  sort_order: number;
  is_active: boolean;
  options?: ReactOption[];
}

interface ReactOption {
  id: string;
  scenario_id: string;
  reaction_text: string;
  sort_order: number;
}

export default function KindnessEditorPage() {
  const [tab, setTab] = useState<'flip' | 'react'>('flip');
  const [flipCards, setFlipCards] = useState<FlipCard[]>([]);
  const [scenarios, setScenarios] = useState<ReactScenario[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingFlip, setEditingFlip] = useState<FlipCard | null>(null);
  const [editingScenario, setEditingScenario] = useState<ReactScenario | null>(null);

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [flipRes, scenRes, optRes] = await Promise.all([
      supabaseAdmin.from('kindness_flip_cards').select('*').order('sort_order'),
      supabaseAdmin.from('kindness_react_scenarios').select('*').order('sort_order'),
      supabaseAdmin.from('kindness_react_options').select('*').order('sort_order'),
    ]);

    setFlipCards(flipRes.data || []);

    const scenariosWithOpts = (scenRes.data || []).map((s: ReactScenario) => ({
      ...s,
      options: (optRes.data || []).filter((o: ReactOption) => o.scenario_id === s.id),
    }));
    setScenarios(scenariosWithOpts);
    setLoading(false);
  }

  // ── Flip Card CRUD ──

  async function saveFlipCard(card: FlipCard) {
    if (card.id) {
      await supabaseAdmin.from('kindness_flip_cards').update({
        emoji: card.emoji,
        judgement: card.judgement,
        reality: card.reality,
        sort_order: card.sort_order,
        is_active: card.is_active,
        updated_at: new Date().toISOString(),
      }).eq('id', card.id);
    } else {
      await supabaseAdmin.from('kindness_flip_cards').insert({
        emoji: card.emoji,
        judgement: card.judgement,
        reality: card.reality,
        sort_order: card.sort_order,
        is_active: card.is_active,
      });
    }
    setEditingFlip(null);
    fetchAll();
  }

  async function deleteFlipCard(id: string) {
    if (!confirm('Delete this flip card?')) return;
    await supabaseAdmin.from('kindness_flip_cards').delete().eq('id', id);
    fetchAll();
  }

  // ── Scenario CRUD ──

  async function saveScenario(scenario: ReactScenario) {
    if (scenario.id) {
      await supabaseAdmin.from('kindness_react_scenarios').update({
        scenario: scenario.scenario,
        reveal: scenario.reveal,
        best_reaction_index: scenario.best_reaction_index,
        sort_order: scenario.sort_order,
        is_active: scenario.is_active,
        updated_at: new Date().toISOString(),
      }).eq('id', scenario.id);

      // Update options
      if (scenario.options) {
        await supabaseAdmin.from('kindness_react_options').delete().eq('scenario_id', scenario.id);
        for (const opt of scenario.options) {
          await supabaseAdmin.from('kindness_react_options').insert({
            scenario_id: scenario.id,
            reaction_text: opt.reaction_text,
            sort_order: opt.sort_order,
          });
        }
      }
    } else {
      const { data } = await supabaseAdmin.from('kindness_react_scenarios').insert({
        scenario: scenario.scenario,
        reveal: scenario.reveal,
        best_reaction_index: scenario.best_reaction_index,
        sort_order: scenario.sort_order,
        is_active: scenario.is_active,
      }).select().single();

      if (data && scenario.options) {
        for (const opt of scenario.options) {
          await supabaseAdmin.from('kindness_react_options').insert({
            scenario_id: data.id,
            reaction_text: opt.reaction_text,
            sort_order: opt.sort_order,
          });
        }
      }
    }
    setEditingScenario(null);
    fetchAll();
  }

  async function deleteScenario(id: string) {
    if (!confirm('Delete this scenario and all its options?')) return;
    await supabaseAdmin.from('kindness_react_options').delete().eq('scenario_id', id);
    await supabaseAdmin.from('kindness_react_scenarios').delete().eq('id', id);
    fetchAll();
  }

  if (loading) {
    return <div className="p-8"><div className="animate-pulse h-8 bg-gray-200 rounded w-1/4"></div></div>;
  }

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <a href="/admin/content-manager" className="text-cyan-600 text-sm hover:underline">← Content Manager</a>
        <h1 className="text-3xl font-bold text-gray-900 mt-2">Learning to be Kind</h1>
        <p className="text-gray-500">Manage flip cards and react-or-reflect scenarios</p>
      </div>

      {/* Tab Bar */}
      <div className="flex gap-2 mb-6">
        {(['flip', 'react'] as const).map((t) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
              tab === t ? 'bg-cyan-100 text-cyan-800' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {t === 'flip' ? `Flip the Story (${flipCards.length})` : `React or Reflect (${scenarios.length})`}
          </button>
        ))}
      </div>

      {/* ── Flip Cards ── */}
      {tab === 'flip' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Flip Cards</h2>
            <button
              onClick={() => setEditingFlip({ id: '', emoji: '💭', judgement: '', reality: '', sort_order: flipCards.length + 1, is_active: true })}
              className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700"
            >
              + Add Card
            </button>
          </div>

          {editingFlip && (
            <FlipCardEditor card={editingFlip} onSave={saveFlipCard} onCancel={() => setEditingFlip(null)} />
          )}

          <div className="space-y-3">
            {flipCards.map((card) => (
              <div key={card.id} className={`bg-white border rounded-xl p-4 ${!card.is_active ? 'opacity-50' : ''}`}>
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-2xl">{card.emoji}</span>
                      <span className="text-xs bg-gray-100 px-2 py-0.5 rounded">#{card.sort_order}</span>
                      {!card.is_active && <span className="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded">Hidden</span>}
                    </div>
                    <p className="text-gray-900 font-medium text-sm">Judgement: &ldquo;{card.judgement}&rdquo;</p>
                    <p className="text-green-700 text-sm mt-1">Reality: {card.reality}</p>
                  </div>
                  <div className="flex gap-2 ml-4">
                    <button onClick={() => setEditingFlip(card)} className="text-cyan-600 text-sm hover:underline">Edit</button>
                    <button onClick={() => deleteFlipCard(card.id)} className="text-red-500 text-sm hover:underline">Delete</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── React or Reflect ── */}
      {tab === 'react' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Scenarios</h2>
            <button
              onClick={() => setEditingScenario({
                id: '', scenario: '', reveal: '', best_reaction_index: 0,
                sort_order: scenarios.length + 1, is_active: true,
                options: [
                  { id: '', scenario_id: '', reaction_text: '', sort_order: 0 },
                  { id: '', scenario_id: '', reaction_text: '', sort_order: 1 },
                  { id: '', scenario_id: '', reaction_text: '', sort_order: 2 },
                ],
              })}
              className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700"
            >
              + Add Scenario
            </button>
          </div>

          {editingScenario && (
            <ScenarioEditor scenario={editingScenario} onSave={saveScenario} onCancel={() => setEditingScenario(null)} />
          )}

          <div className="space-y-4">
            {scenarios.map((s) => (
              <div key={s.id} className={`bg-white border rounded-xl p-4 ${!s.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-xs bg-gray-100 px-2 py-0.5 rounded">#{s.sort_order}</span>
                      {!s.is_active && <span className="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded">Hidden</span>}
                    </div>
                    <p className="text-gray-900 font-medium text-sm">{s.scenario}</p>
                    <div className="mt-2 space-y-1">
                      {s.options?.map((o, i) => (
                        <p key={o.id || i} className={`text-xs ${i === s.best_reaction_index ? 'text-green-700 font-semibold' : 'text-gray-500'}`}>
                          {i === s.best_reaction_index ? '✓' : '○'} {o.reaction_text}
                        </p>
                      ))}
                    </div>
                    <p className="text-cyan-700 text-xs mt-2 italic">Reveal: {s.reveal}</p>
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

// ── Flip Card Editor ──

function FlipCardEditor({ card, onSave, onCancel }: { card: FlipCard; onSave: (c: FlipCard) => void; onCancel: () => void }) {
  const [form, setForm] = useState(card);

  return (
    <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
      <div className="grid grid-cols-6 gap-3">
        <div>
          <label className="text-xs text-gray-600">Emoji</label>
          <input value={form.emoji} onChange={(e) => setForm({ ...form, emoji: e.target.value })}
            className="w-full border rounded-lg px-3 py-2 text-2xl text-center" />
        </div>
        <div>
          <label className="text-xs text-gray-600">Order</label>
          <input type="number" value={form.sort_order} onChange={(e) => setForm({ ...form, sort_order: parseInt(e.target.value) || 0 })}
            className="w-full border rounded-lg px-3 py-2" />
        </div>
        <div className="col-span-4 flex items-end">
          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" checked={form.is_active} onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />
            Active
          </label>
        </div>
      </div>
      <div>
        <label className="text-xs text-gray-600">Snap Judgement</label>
        <textarea value={form.judgement} onChange={(e) => setForm({ ...form, judgement: e.target.value })}
          className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} />
      </div>
      <div>
        <label className="text-xs text-gray-600">The Reality</label>
        <textarea value={form.reality} onChange={(e) => setForm({ ...form, reality: e.target.value })}
          className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} />
      </div>
      <div className="flex gap-2">
        <button onClick={() => onSave(form)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">Save</button>
        <button onClick={onCancel} className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm hover:bg-gray-300">Cancel</button>
      </div>
    </div>
  );
}

// ── Scenario Editor ──

function ScenarioEditor({ scenario, onSave, onCancel }: { scenario: ReactScenario; onSave: (s: ReactScenario) => void; onCancel: () => void }) {
  const [form, setForm] = useState(scenario);

  function updateOption(index: number, text: string) {
    const opts = [...(form.options || [])];
    opts[index] = { ...opts[index], reaction_text: text };
    setForm({ ...form, options: opts });
  }

  function addOption() {
    setForm({
      ...form,
      options: [...(form.options || []), { id: '', scenario_id: '', reaction_text: '', sort_order: (form.options?.length || 0) }],
    });
  }

  function removeOption(index: number) {
    const opts = [...(form.options || [])];
    opts.splice(index, 1);
    setForm({ ...form, options: opts });
  }

  return (
    <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
      <div className="grid grid-cols-4 gap-3">
        <div>
          <label className="text-xs text-gray-600">Order</label>
          <input type="number" value={form.sort_order} onChange={(e) => setForm({ ...form, sort_order: parseInt(e.target.value) || 0 })}
            className="w-full border rounded-lg px-3 py-2" />
        </div>
        <div>
          <label className="text-xs text-gray-600">Best Answer Index (0-based)</label>
          <input type="number" value={form.best_reaction_index} onChange={(e) => setForm({ ...form, best_reaction_index: parseInt(e.target.value) || 0 })}
            className="w-full border rounded-lg px-3 py-2" />
        </div>
        <div className="col-span-2 flex items-end">
          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" checked={form.is_active} onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />
            Active
          </label>
        </div>
      </div>
      <div>
        <label className="text-xs text-gray-600">Scenario</label>
        <textarea value={form.scenario} onChange={(e) => setForm({ ...form, scenario: e.target.value })}
          className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} />
      </div>
      <div>
        <label className="text-xs text-gray-600">Reveal (the truth)</label>
        <textarea value={form.reveal} onChange={(e) => setForm({ ...form, reveal: e.target.value })}
          className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} />
      </div>
      <div>
        <label className="text-xs text-gray-600 mb-1 block">Reaction Options</label>
        {form.options?.map((opt, i) => (
          <div key={i} className="flex items-center gap-2 mb-2">
            <span className={`text-xs font-bold w-6 text-center ${i === form.best_reaction_index ? 'text-green-600' : 'text-gray-400'}`}>
              {i === form.best_reaction_index ? '✓' : i}
            </span>
            <input value={opt.reaction_text} onChange={(e) => updateOption(i, e.target.value)}
              className="flex-1 border rounded-lg px-3 py-2 text-sm" placeholder={`Reaction ${i + 1}`} />
            <button onClick={() => removeOption(i)} className="text-red-400 text-sm hover:text-red-600">✕</button>
          </div>
        ))}
        <button onClick={addOption} className="text-cyan-600 text-sm hover:underline">+ Add option</button>
      </div>
      <div className="flex gap-2">
        <button onClick={() => onSave(form)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">Save</button>
        <button onClick={onCancel} className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm hover:bg-gray-300">Cancel</button>
      </div>
    </div>
  );
}
