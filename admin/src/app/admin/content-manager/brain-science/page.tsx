'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';

interface Myth { id: string; statement: string; is_true: boolean; explanation: string; sort_order: number; is_active: boolean; }
interface Bias { id: string; scenario: string; correct_option_index: number; explanation: string; sort_order: number; is_active: boolean; options?: BiasOption[]; }
interface BiasOption { id: string; bias_id: string; option_text: string; sort_order: number; }
interface Experiment { id: string; title: string; year: string; researcher: string; sort_order: number; is_active: boolean; }

export default function BrainScienceEditorPage() {
  const [tab, setTab] = useState<'myths' | 'biases' | 'experiments'>('myths');
  const [myths, setMyths] = useState<Myth[]>([]);
  const [biases, setBiases] = useState<Bias[]>([]);
  const [experiments, setExperiments] = useState<Experiment[]>([]);
  const [loading, setLoading] = useState(true);
  const [editMyth, setEditMyth] = useState<Myth | null>(null);
  const [editBias, setEditBias] = useState<Bias | null>(null);
  const [editExp, setEditExp] = useState<Experiment | null>(null);

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [m, b, o, e] = await Promise.all([
      supabaseAdmin.from('brain_myths').select('*').order('sort_order'),
      supabaseAdmin.from('brain_biases').select('*').order('sort_order'),
      supabaseAdmin.from('brain_bias_options').select('*').order('sort_order'),
      supabaseAdmin.from('brain_experiments').select('*').order('sort_order'),
    ]);
    setMyths(m.data || []);
    const biasesWithOpts = (b.data || []).map((bias: Bias) => ({
      ...bias,
      options: (o.data || []).filter((opt: BiasOption) => opt.bias_id === bias.id),
    }));
    setBiases(biasesWithOpts);
    setExperiments(e.data || []);
    setLoading(false);
  }

  async function saveMyth(item: Myth) {
    const payload = { statement: item.statement, is_true: item.is_true, explanation: item.explanation, sort_order: item.sort_order, is_active: item.is_active, updated_at: new Date().toISOString() };
    if (item.id) { await supabaseAdmin.from('brain_myths').update(payload).eq('id', item.id); }
    else { await supabaseAdmin.from('brain_myths').insert(payload); }
    setEditMyth(null); fetchAll();
  }
  async function deleteMyth(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('brain_myths').delete().eq('id', id); fetchAll(); }

  async function saveBias(item: Bias) {
    const payload = { scenario: item.scenario, correct_option_index: item.correct_option_index, explanation: item.explanation, sort_order: item.sort_order, is_active: item.is_active, updated_at: new Date().toISOString() };
    let biasId = item.id;
    if (item.id) {
      await supabaseAdmin.from('brain_biases').update(payload).eq('id', item.id);
      await supabaseAdmin.from('brain_bias_options').delete().eq('bias_id', item.id);
    } else {
      const { data } = await supabaseAdmin.from('brain_biases').insert(payload).select().single();
      biasId = data?.id;
    }
    if (biasId && item.options) {
      for (const opt of item.options) {
        await supabaseAdmin.from('brain_bias_options').insert({ bias_id: biasId, option_text: opt.option_text, sort_order: opt.sort_order });
      }
    }
    setEditBias(null); fetchAll();
  }
  async function deleteBias(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('brain_bias_options').delete().eq('bias_id', id); await supabaseAdmin.from('brain_biases').delete().eq('id', id); fetchAll(); }

  async function saveExp(item: Experiment) {
    const payload = { title: item.title, year: item.year, researcher: item.researcher, sort_order: item.sort_order, is_active: item.is_active, updated_at: new Date().toISOString() };
    if (item.id) { await supabaseAdmin.from('brain_experiments').update(payload).eq('id', item.id); }
    else { await supabaseAdmin.from('brain_experiments').insert(payload); }
    setEditExp(null); fetchAll();
  }
  async function deleteExp(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('brain_experiment_steps').delete().eq('experiment_id', id); await supabaseAdmin.from('brain_experiments').delete().eq('id', id); fetchAll(); }

  if (loading) return <div className="p-8"><div className="animate-pulse h-8 bg-gray-200 rounded w-1/4"></div></div>;

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <a href="/admin/content-manager" className="text-cyan-600 text-sm hover:underline">&larr; Content Manager</a>
        <h1 className="text-3xl font-bold text-gray-900 mt-2">Brain Science & Psychology</h1>
        <p className="text-gray-500">Manage myths, biases, and famous experiments</p>
      </div>
      <div className="flex gap-2 mb-6">
        {(['myths', 'biases', 'experiments'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)} className={`px-4 py-2 rounded-lg text-sm font-medium transition ${tab === t ? 'bg-cyan-100 text-cyan-800' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
            {t === 'myths' ? `Myths (${myths.length})` : t === 'biases' ? `Biases (${biases.length})` : `Experiments (${experiments.length})`}
          </button>
        ))}
      </div>

      {tab === 'myths' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Myth Buster</h2>
            <button onClick={() => setEditMyth({ id: '', statement: '', is_true: false, explanation: '', sort_order: myths.length + 1, is_active: true })} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">+ Add Myth</button>
          </div>
          {editMyth && (
            <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
              <div><label className="text-xs text-gray-600">Statement</label><textarea value={editMyth.statement} onChange={e => setEditMyth({...editMyth, statement: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} /></div>
              <div className="grid grid-cols-3 gap-3">
                <div><label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={editMyth.is_true} onChange={e => setEditMyth({...editMyth, is_true: e.target.checked})} />Answer is TRUE</label></div>
                <div><label className="text-xs text-gray-600">Order</label><input type="number" value={editMyth.sort_order} onChange={e => setEditMyth({...editMyth, sort_order: parseInt(e.target.value)||0})} className="w-full border rounded-lg px-3 py-2" /></div>
                <div><label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={editMyth.is_active} onChange={e => setEditMyth({...editMyth, is_active: e.target.checked})} />Active</label></div>
              </div>
              <div><label className="text-xs text-gray-600">Explanation</label><textarea value={editMyth.explanation} onChange={e => setEditMyth({...editMyth, explanation: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} /></div>
              <div className="flex gap-2"><button onClick={() => saveMyth(editMyth)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button><button onClick={() => setEditMyth(null)} className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm">Cancel</button></div>
            </div>
          )}
          <div className="space-y-3">{myths.map(m => (
            <div key={m.id} className={`bg-white border rounded-xl p-4 ${!m.is_active ? 'opacity-50' : ''}`}>
              <div className="flex justify-between"><div className="flex-1"><div className="flex items-center gap-2 mb-1"><span className={`text-xs px-2 py-0.5 rounded font-medium ${m.is_true ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>{m.is_true ? 'TRUE' : 'FALSE'}</span><span className="text-xs bg-gray-100 px-2 py-0.5 rounded">#{m.sort_order}</span></div><p className="text-sm text-gray-900 font-medium">&ldquo;{m.statement}&rdquo;</p><p className="text-xs text-gray-500 mt-1">{m.explanation}</p></div>
              <div className="flex gap-2 ml-4"><button onClick={() => setEditMyth(m)} className="text-cyan-600 text-sm hover:underline">Edit</button><button onClick={() => deleteMyth(m.id)} className="text-red-500 text-sm hover:underline">Delete</button></div></div>
            </div>
          ))}</div>
        </div>
      )}

      {tab === 'biases' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Bias Spotter</h2>
            <button onClick={() => setEditBias({ id: '', scenario: '', correct_option_index: 0, explanation: '', sort_order: biases.length + 1, is_active: true, options: [{id:'',bias_id:'',option_text:'',sort_order:0},{id:'',bias_id:'',option_text:'',sort_order:1},{id:'',bias_id:'',option_text:'',sort_order:2},{id:'',bias_id:'',option_text:'',sort_order:3}] })} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">+ Add Bias</button>
          </div>
          {editBias && (
            <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
              <div><label className="text-xs text-gray-600">Scenario</label><textarea value={editBias.scenario} onChange={e => setEditBias({...editBias, scenario: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} /></div>
              <div className="grid grid-cols-3 gap-3">
                <div><label className="text-xs text-gray-600">Correct Index (0-based)</label><input type="number" value={editBias.correct_option_index} onChange={e => setEditBias({...editBias, correct_option_index: parseInt(e.target.value)||0})} className="w-full border rounded-lg px-3 py-2" /></div>
                <div><label className="text-xs text-gray-600">Order</label><input type="number" value={editBias.sort_order} onChange={e => setEditBias({...editBias, sort_order: parseInt(e.target.value)||0})} className="w-full border rounded-lg px-3 py-2" /></div>
                <div><label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={editBias.is_active} onChange={e => setEditBias({...editBias, is_active: e.target.checked})} />Active</label></div>
              </div>
              <div><label className="text-xs text-gray-600">Options</label>
                {editBias.options?.map((o, i) => (
                  <div key={i} className="flex items-center gap-2 mb-2"><span className={`text-xs font-bold w-6 text-center ${i === editBias.correct_option_index ? 'text-green-600' : 'text-gray-400'}`}>{i === editBias.correct_option_index ? '✓' : i}</span><input value={o.option_text} onChange={e => { const opts = [...(editBias.options||[])]; opts[i] = {...opts[i], option_text: e.target.value}; setEditBias({...editBias, options: opts}); }} className="flex-1 border rounded-lg px-3 py-2 text-sm" /></div>
                ))}
              </div>
              <div><label className="text-xs text-gray-600">Explanation</label><textarea value={editBias.explanation} onChange={e => setEditBias({...editBias, explanation: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm" rows={2} /></div>
              <div className="flex gap-2"><button onClick={() => saveBias(editBias)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button><button onClick={() => setEditBias(null)} className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm">Cancel</button></div>
            </div>
          )}
          <div className="space-y-3">{biases.map(b => (
            <div key={b.id} className={`bg-white border rounded-xl p-4 ${!b.is_active ? 'opacity-50' : ''}`}>
              <div className="flex justify-between"><div className="flex-1"><p className="text-sm text-gray-900 font-medium">{b.scenario}</p><div className="mt-1 space-y-0.5">{b.options?.map((o,i) => <p key={i} className={`text-xs ${i === b.correct_option_index ? 'text-green-700 font-semibold' : 'text-gray-400'}`}>{i === b.correct_option_index ? '✓' : '○'} {o.option_text}</p>)}</div></div>
              <div className="flex gap-2 ml-4"><button onClick={() => setEditBias(b)} className="text-cyan-600 text-sm hover:underline">Edit</button><button onClick={() => deleteBias(b.id)} className="text-red-500 text-sm hover:underline">Delete</button></div></div>
            </div>
          ))}</div>
        </div>
      )}

      {tab === 'experiments' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Famous Experiments</h2>
            <button onClick={() => setEditExp({ id: '', title: '', year: '', researcher: '', sort_order: experiments.length + 1, is_active: true })} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">+ Add Experiment</button>
          </div>
          {editExp && (
            <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
              <div className="grid grid-cols-4 gap-3">
                <div><label className="text-xs text-gray-600">Title</label><input value={editExp.title} onChange={e => setEditExp({...editExp, title: e.target.value})} className="w-full border rounded-lg px-3 py-2" /></div>
                <div><label className="text-xs text-gray-600">Year</label><input value={editExp.year} onChange={e => setEditExp({...editExp, year: e.target.value})} className="w-full border rounded-lg px-3 py-2" /></div>
                <div><label className="text-xs text-gray-600">Researcher</label><input value={editExp.researcher} onChange={e => setEditExp({...editExp, researcher: e.target.value})} className="w-full border rounded-lg px-3 py-2" /></div>
                <div><label className="text-xs text-gray-600">Order</label><input type="number" value={editExp.sort_order} onChange={e => setEditExp({...editExp, sort_order: parseInt(e.target.value)||0})} className="w-full border rounded-lg px-3 py-2" /></div>
              </div>
              <div className="flex gap-2"><button onClick={() => saveExp(editExp)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button><button onClick={() => setEditExp(null)} className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm">Cancel</button></div>
            </div>
          )}
          <div className="space-y-3">{experiments.map(e => (
            <div key={e.id} className={`bg-white border rounded-xl p-4 ${!e.is_active ? 'opacity-50' : ''}`}>
              <div className="flex justify-between"><div><span className="font-semibold text-gray-900">{e.title}</span><span className="text-gray-400 ml-2 text-sm">{e.researcher}, {e.year}</span></div>
              <div className="flex gap-2"><button onClick={() => setEditExp(e)} className="text-cyan-600 text-sm hover:underline">Edit</button><button onClick={() => deleteExp(e.id)} className="text-red-500 text-sm hover:underline">Delete</button></div></div>
            </div>
          ))}</div>
          <p className="text-xs text-gray-400 mt-4">Experiment steps are managed via the step_type system in the database. Contact your developer to modify step sequences.</p>
        </div>
      )}
    </div>
  );
}
