'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';

interface Fact { id: string; emoji: string; title: string; detail: string; sort_order: number; is_active: boolean; }
interface Story { id: string; quote: string; branch: string; years_served: string; sort_order: number; is_active: boolean; }

export default function MilitaryPerksEditorPage() {
  const [tab, setTab] = useState<'facts' | 'stories'>('facts');
  const [facts, setFacts] = useState<Fact[]>([]);
  const [stories, setStories] = useState<Story[]>([]);
  const [loading, setLoading] = useState(true);
  const [editFact, setEditFact] = useState<Fact | null>(null);
  const [editStory, setEditStory] = useState<Story | null>(null);

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [f, s] = await Promise.all([
      supabaseAdmin.from('perks_facts').select('*').order('sort_order'),
      supabaseAdmin.from('perks_regret_stories').select('*').order('sort_order'),
    ]);
    setFacts(f.data || []);
    setStories(s.data || []);
    setLoading(false);
  }

  async function saveFact(item: Fact) {
    const payload = { emoji: item.emoji, title: item.title, detail: item.detail, sort_order: item.sort_order, is_active: item.is_active, updated_at: new Date().toISOString() };
    if (item.id) { await supabaseAdmin.from('perks_facts').update(payload).eq('id', item.id); }
    else { await supabaseAdmin.from('perks_facts').insert(payload); }
    setEditFact(null); fetchAll();
  }

  async function deleteFact(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('perks_facts').delete().eq('id', id); fetchAll(); }

  async function saveStory(item: Story) {
    const payload = { quote: item.quote, branch: item.branch, years_served: item.years_served, sort_order: item.sort_order, is_active: item.is_active, updated_at: new Date().toISOString() };
    if (item.id) { await supabaseAdmin.from('perks_regret_stories').update(payload).eq('id', item.id); }
    else { await supabaseAdmin.from('perks_regret_stories').insert(payload); }
    setEditStory(null); fetchAll();
  }

  async function deleteStory(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('perks_regret_stories').delete().eq('id', id); fetchAll(); }

  if (loading) return <div className="p-8"><div className="animate-pulse h-8 bg-gray-200 rounded w-1/4"></div></div>;

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <a href="/admin/content-manager" className="text-cyan-600 text-sm hover:underline">&larr; Content Manager</a>
        <h1 className="text-3xl font-bold text-gray-900 mt-2">Military Perks</h1>
        <p className="text-gray-500">Manage Did You Know facts and Regret Stories</p>
      </div>
      <div className="flex gap-2 mb-6">
        {(['facts', 'stories'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)} className={`px-4 py-2 rounded-lg text-sm font-medium transition ${tab === t ? 'bg-cyan-100 text-cyan-800' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
            {t === 'facts' ? `Did You Know (${facts.length})` : `Regret Stories (${stories.length})`}
          </button>
        ))}
      </div>

      {tab === 'facts' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Facts</h2>
            <button onClick={() => setEditFact({ id: '', emoji: '💡', title: '', detail: '', sort_order: facts.length + 1, is_active: true })} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">+ Add Fact</button>
          </div>
          {editFact && (
            <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
              <div className="grid grid-cols-4 gap-3">
                <div><label className="text-xs text-gray-600">Emoji</label><input value={editFact.emoji} onChange={e => setEditFact({...editFact, emoji: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-2xl text-center" /></div>
                <div className="col-span-2"><label className="text-xs text-gray-600">Title</label><input value={editFact.title} onChange={e => setEditFact({...editFact, title: e.target.value})} className="w-full border rounded-lg px-3 py-2" /></div>
                <div><label className="text-xs text-gray-600">Order</label><input type="number" value={editFact.sort_order} onChange={e => setEditFact({...editFact, sort_order: parseInt(e.target.value)||0})} className="w-full border rounded-lg px-3 py-2" /></div>
              </div>
              <div><label className="text-xs text-gray-600">Detail</label><textarea value={editFact.detail} onChange={e => setEditFact({...editFact, detail: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm" rows={3} /></div>
              <div className="flex gap-2 items-center">
                <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={editFact.is_active} onChange={e => setEditFact({...editFact, is_active: e.target.checked})} />Active</label>
                <div className="flex-1" />
                <button onClick={() => saveFact(editFact)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
                <button onClick={() => setEditFact(null)} className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm">Cancel</button>
              </div>
            </div>
          )}
          <div className="space-y-3">{facts.map(f => (
            <div key={f.id} className={`bg-white border rounded-xl p-4 ${!f.is_active ? 'opacity-50' : ''}`}>
              <div className="flex justify-between"><div className="flex-1"><div className="flex items-center gap-2 mb-1"><span className="text-xl">{f.emoji}</span><span className="font-semibold">{f.title}</span><span className="text-xs bg-gray-100 px-2 py-0.5 rounded">#{f.sort_order}</span></div><p className="text-sm text-gray-600">{f.detail}</p></div>
              <div className="flex gap-2 ml-4"><button onClick={() => setEditFact(f)} className="text-cyan-600 text-sm hover:underline">Edit</button><button onClick={() => deleteFact(f.id)} className="text-red-500 text-sm hover:underline">Delete</button></div></div>
            </div>
          ))}</div>
        </div>
      )}

      {tab === 'stories' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Regret Stories</h2>
            <button onClick={() => setEditStory({ id: '', quote: '', branch: 'Army', years_served: '10 years', sort_order: stories.length + 1, is_active: true })} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">+ Add Story</button>
          </div>
          {editStory && (
            <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
              <div className="grid grid-cols-3 gap-3">
                <div><label className="text-xs text-gray-600">Branch</label><select value={editStory.branch} onChange={e => setEditStory({...editStory, branch: e.target.value})} className="w-full border rounded-lg px-3 py-2">{['Army','Royal Navy','RAF','Royal Marines'].map(b => <option key={b} value={b}>{b}</option>)}</select></div>
                <div><label className="text-xs text-gray-600">Years Served</label><input value={editStory.years_served} onChange={e => setEditStory({...editStory, years_served: e.target.value})} className="w-full border rounded-lg px-3 py-2" /></div>
                <div><label className="text-xs text-gray-600">Order</label><input type="number" value={editStory.sort_order} onChange={e => setEditStory({...editStory, sort_order: parseInt(e.target.value)||0})} className="w-full border rounded-lg px-3 py-2" /></div>
              </div>
              <div><label className="text-xs text-gray-600">Quote</label><textarea value={editStory.quote} onChange={e => setEditStory({...editStory, quote: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm" rows={4} /></div>
              <div className="flex gap-2 items-center">
                <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={editStory.is_active} onChange={e => setEditStory({...editStory, is_active: e.target.checked})} />Active</label>
                <div className="flex-1" />
                <button onClick={() => saveStory(editStory)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
                <button onClick={() => setEditStory(null)} className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm">Cancel</button>
              </div>
            </div>
          )}
          <div className="space-y-3">{stories.map(s => (
            <div key={s.id} className={`bg-white border rounded-xl p-4 ${!s.is_active ? 'opacity-50' : ''}`}>
              <div className="flex justify-between"><div className="flex-1"><div className="flex items-center gap-2 mb-1"><span className="text-xs bg-cyan-100 text-cyan-800 px-2 py-0.5 rounded font-medium">{s.branch}</span><span className="text-xs text-gray-400">{s.years_served}</span><span className="text-xs bg-gray-100 px-2 py-0.5 rounded">#{s.sort_order}</span></div><p className="text-sm text-gray-700 italic">&ldquo;{s.quote.substring(0, 120)}...&rdquo;</p></div>
              <div className="flex gap-2 ml-4"><button onClick={() => setEditStory(s)} className="text-cyan-600 text-sm hover:underline">Edit</button><button onClick={() => deleteStory(s.id)} className="text-red-500 text-sm hover:underline">Delete</button></div></div>
            </div>
          ))}</div>
        </div>
      )}
    </div>
  );
}
