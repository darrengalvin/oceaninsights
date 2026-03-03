'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface ContraceptionMethod {
  id: string; name: string; emoji: string; category: string;
  how_it_works: string; effectiveness: string; duration: string;
  service_notes: string; side_effects: string[];
  sort_order: number; is_active: boolean;
}

interface PregnancyTopic {
  id: string; title: string; subtitle: string; content: string;
  icon: string; colour: string; sort_order: number; is_active: boolean;
}

type TabType = 'contraception' | 'pregnancy';

export default function HealthEducationPage() {
  const [activeTab, setActiveTab] = useState<TabType>('contraception');
  const [methods, setMethods] = useState<ContraceptionMethod[]>([]);
  const [pregnancy, setPregnancy] = useState<PregnancyTopic[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [editItem, setEditItem] = useState<any>(null);
  const [formData, setFormData] = useState<any>({});

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [mRes, pRes] = await Promise.all([
      supabaseAdmin.from('health_contraception_methods').select('*').order('sort_order'),
      supabaseAdmin.from('health_pregnancy_topics').select('*').order('sort_order'),
    ]);
    if (mRes.data) setMethods(mRes.data);
    if (pRes.data) setPregnancy(pRes.data);
    setLoading(false);
  }

  async function toggleActive(table: string, id: string, current: boolean) {
    await supabaseAdmin.from(table).update({ is_active: !current }).eq('id', id);
    fetchAll();
  }
  async function deleteItem(table: string, id: string, label: string) {
    if (!confirm(`Delete "${label}"?`)) return;
    await supabaseAdmin.from(table).delete().eq('id', id);
    fetchAll();
  }
  function resetForm() { setShowAdd(false); setEditItem(null); setFormData({}); }

  async function saveMethod() {
    const d = editItem || formData;
    if (!d.name?.trim()) return;
    const payload = {
      name: d.name, emoji: d.emoji || '💊', category: d.category || '',
      how_it_works: d.how_it_works || '', effectiveness: d.effectiveness || '',
      duration: d.duration || '', service_notes: d.service_notes || '',
      side_effects: (d.side_effects_text || '').split('\n').filter((s: string) => s.trim()),
      sort_order: editItem ? editItem.sort_order : methods.length,
      is_active: editItem ? editItem.is_active : true,
    };
    if (editItem?.id) {
      await supabaseAdmin.from('health_contraception_methods').update(payload).eq('id', editItem.id);
    } else {
      await supabaseAdmin.from('health_contraception_methods').insert(payload);
    }
    fetchAll(); resetForm();
  }

  async function savePregnancyTopic() {
    const d = editItem || formData;
    if (!d.title?.trim()) return;
    const payload = {
      title: d.title, subtitle: d.subtitle || '', content: d.content || '',
      icon: d.icon || 'info', colour: d.colour || '#F472B6',
      sort_order: editItem ? editItem.sort_order : pregnancy.length,
      is_active: editItem ? editItem.is_active : true,
    };
    if (editItem?.id) {
      await supabaseAdmin.from('health_pregnancy_topics').update(payload).eq('id', editItem.id);
    } else {
      await supabaseAdmin.from('health_pregnancy_topics').insert(payload);
    }
    fetchAll(); resetForm();
  }

  if (loading) return <div className="p-8"><div className="animate-pulse h-64 bg-gray-200 rounded"></div></div>;

  const tabs = [
    { id: 'contraception' as const, label: 'Contraception', count: methods.length, icon: '💊' },
    { id: 'pregnancy' as const, label: 'Pregnancy Guidance', count: pregnancy.length, icon: '🤰' },
  ];

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <Link href="/admin/content-manager" className="text-cyan-600 hover:text-cyan-800 text-sm">← Back to Content Manager</Link>
      </div>
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-2">
          <span className="text-3xl">🩺</span>
          <h1 className="text-3xl font-bold text-gray-900">Health Tracker Education</h1>
        </div>
        <p className="text-gray-600">Manage contraception methods and pregnancy guidance shown in the health tracker.</p>
      </div>

      <div className="flex gap-2 mb-6">
        {tabs.map(t => (
          <button key={t.id} onClick={() => { setActiveTab(t.id); resetForm(); }}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition ${activeTab === t.id ? 'bg-pink-600 text-white' : 'bg-white text-gray-600 border hover:bg-gray-50'}`}>
            {t.icon} {t.label} ({t.count})
          </button>
        ))}
      </div>

      {/* CONTRACEPTION */}
      {activeTab === 'contraception' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">💊 Contraception Methods ({methods.length})</h2>
            <button onClick={() => { setShowAdd(true); setEditItem(null); setFormData({ _type: 'method', name: '', emoji: '💊', category: '', how_it_works: '', effectiveness: '', duration: '', service_notes: '', side_effects_text: '' }); }}
              className="bg-pink-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add Method</button>
          </div>

          {(showAdd || (editItem && editItem._type === 'method')) && (
            <div className="bg-white border rounded-xl p-6 mb-4 space-y-4">
              <h3 className="font-semibold">{editItem ? 'Edit' : 'Add'} Contraception Method</h3>
              <div className="grid grid-cols-3 gap-3">
                <input placeholder="Name" value={(editItem || formData).name || ''} onChange={e => editItem ? setEditItem({...editItem, name: e.target.value}) : setFormData({...formData, name: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Emoji" value={(editItem || formData).emoji || ''} onChange={e => editItem ? setEditItem({...editItem, emoji: e.target.value}) : setFormData({...formData, emoji: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Category (e.g. LARC, Short-Acting)" value={(editItem || formData).category || ''} onChange={e => editItem ? setEditItem({...editItem, category: e.target.value}) : setFormData({...formData, category: e.target.value})} className="border rounded px-3 py-2 text-sm" />
              </div>
              <textarea placeholder="How it works" rows={2} value={(editItem || formData).how_it_works || ''} onChange={e => editItem ? setEditItem({...editItem, how_it_works: e.target.value}) : setFormData({...formData, how_it_works: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <div className="grid grid-cols-2 gap-3">
                <input placeholder="Effectiveness" value={(editItem || formData).effectiveness || ''} onChange={e => editItem ? setEditItem({...editItem, effectiveness: e.target.value}) : setFormData({...formData, effectiveness: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Duration" value={(editItem || formData).duration || ''} onChange={e => editItem ? setEditItem({...editItem, duration: e.target.value}) : setFormData({...formData, duration: e.target.value})} className="border rounded px-3 py-2 text-sm" />
              </div>
              <textarea placeholder="Service-specific notes" rows={2} value={(editItem || formData).service_notes || ''} onChange={e => editItem ? setEditItem({...editItem, service_notes: e.target.value}) : setFormData({...formData, service_notes: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <textarea placeholder="Side effects (one per line)" rows={3} value={(editItem || formData).side_effects_text ?? (editItem?.side_effects?.join('\n') || '')} onChange={e => editItem ? setEditItem({...editItem, side_effects_text: e.target.value}) : setFormData({...formData, side_effects_text: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <div className="flex gap-2">
                <button onClick={saveMethod} className="bg-pink-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            </div>
          )}

          <div className="space-y-3">
            {methods.map(m => (
              <div key={m.id} className={`bg-white border rounded-xl p-4 ${!m.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between items-start">
                  <div className="flex items-center gap-3">
                    <span className="text-2xl">{m.emoji}</span>
                    <div>
                      <h3 className="font-semibold">{m.name}</h3>
                      <p className="text-xs text-pink-600">{m.category}</p>
                      <p className="text-sm text-gray-500 mt-1">{m.effectiveness} · {m.duration}</p>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => { setEditItem({...m, _type: 'method', side_effects_text: m.side_effects.join('\n')}); setShowAdd(false); }} className="text-cyan-600 text-sm hover:underline">Edit</button>
                    <button onClick={() => toggleActive('health_contraception_methods', m.id, m.is_active)} className="text-xs text-gray-500 hover:underline">{m.is_active ? 'Disable' : 'Enable'}</button>
                    <button onClick={() => deleteItem('health_contraception_methods', m.id, m.name)} className="text-xs text-red-500 hover:underline">Delete</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* PREGNANCY */}
      {activeTab === 'pregnancy' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">🤰 Pregnancy Guidance ({pregnancy.length})</h2>
            <button onClick={() => { setShowAdd(true); setEditItem(null); setFormData({ _type: 'pregnancy', title: '', subtitle: '', content: '', icon: 'info', colour: '#F472B6' }); }}
              className="bg-pink-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add Topic</button>
          </div>

          {(showAdd || (editItem && editItem._type === 'pregnancy')) && (
            <div className="bg-white border rounded-xl p-6 mb-4 space-y-4">
              <h3 className="font-semibold">{editItem ? 'Edit' : 'Add'} Pregnancy Topic</h3>
              <div className="grid grid-cols-2 gap-3">
                <input placeholder="Title" value={(editItem || formData).title || ''} onChange={e => editItem ? setEditItem({...editItem, title: e.target.value}) : setFormData({...formData, title: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Subtitle" value={(editItem || formData).subtitle || ''} onChange={e => editItem ? setEditItem({...editItem, subtitle: e.target.value}) : setFormData({...formData, subtitle: e.target.value})} className="border rounded px-3 py-2 text-sm" />
              </div>
              <textarea placeholder="Content" rows={6} value={(editItem || formData).content || ''} onChange={e => editItem ? setEditItem({...editItem, content: e.target.value}) : setFormData({...formData, content: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <div className="grid grid-cols-2 gap-3">
                <input placeholder="Icon name" value={(editItem || formData).icon || ''} onChange={e => editItem ? setEditItem({...editItem, icon: e.target.value}) : setFormData({...formData, icon: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Colour (#hex)" value={(editItem || formData).colour || ''} onChange={e => editItem ? setEditItem({...editItem, colour: e.target.value}) : setFormData({...formData, colour: e.target.value})} className="border rounded px-3 py-2 text-sm" />
              </div>
              <div className="flex gap-2">
                <button onClick={savePregnancyTopic} className="bg-pink-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            </div>
          )}

          <div className="space-y-3">
            {pregnancy.map(p => (
              <div key={p.id} className={`bg-white border rounded-xl p-4 ${!p.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between items-start">
                  <div>
                    <h3 className="font-semibold">{p.title}</h3>
                    <p className="text-sm text-gray-500">{p.subtitle}</p>
                    <p className="text-sm text-gray-600 mt-1 line-clamp-2">{p.content}</p>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => { setEditItem({...p, _type: 'pregnancy'}); setShowAdd(false); }} className="text-cyan-600 text-sm hover:underline">Edit</button>
                    <button onClick={() => toggleActive('health_pregnancy_topics', p.id, p.is_active)} className="text-xs text-gray-500 hover:underline">{p.is_active ? 'Disable' : 'Enable'}</button>
                    <button onClick={() => deleteItem('health_pregnancy_topics', p.id, p.title)} className="text-xs text-red-500 hover:underline">Delete</button>
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
