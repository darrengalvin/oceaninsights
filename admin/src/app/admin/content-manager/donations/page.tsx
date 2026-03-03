'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';

interface Impact { id: string; amount: number; emoji: string; impact_text: string; sort_order: number; is_active: boolean; }
interface Setting { id: string; key: string; value: string; }

export default function DonationsEditorPage() {
  const [impacts, setImpacts] = useState<Impact[]>([]);
  const [settings, setSettings] = useState<Setting[]>([]);
  const [loading, setLoading] = useState(true);
  const [editImpact, setEditImpact] = useState<Impact | null>(null);

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [i, s] = await Promise.all([
      supabaseAdmin.from('donation_impacts').select('*').order('sort_order'),
      supabaseAdmin.from('donation_settings').select('*'),
    ]);
    setImpacts(i.data || []);
    setSettings(s.data || []);
    setLoading(false);
  }

  async function saveImpact(item: Impact) {
    const payload = { amount: item.amount, emoji: item.emoji, impact_text: item.impact_text, sort_order: item.sort_order, is_active: item.is_active, updated_at: new Date().toISOString() };
    if (item.id) { await supabaseAdmin.from('donation_impacts').update(payload).eq('id', item.id); }
    else { await supabaseAdmin.from('donation_impacts').insert(payload); }
    setEditImpact(null); fetchAll();
  }

  async function deleteImpact(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('donation_impacts').delete().eq('id', id); fetchAll(); }

  async function updateSetting(key: string, value: string) {
    await supabaseAdmin.from('donation_settings').update({ value, updated_at: new Date().toISOString() }).eq('key', key);
    fetchAll();
  }

  if (loading) return <div className="p-8"><div className="animate-pulse h-8 bg-gray-200 rounded w-1/4"></div></div>;

  const donateUrl = settings.find(s => s.key === 'donate_url')?.value || '';
  const thankMsg = settings.find(s => s.key === 'thank_you_message')?.value || '';

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <a href="/admin/content-manager" className="text-cyan-600 text-sm hover:underline">&larr; Content Manager</a>
        <h1 className="text-3xl font-bold text-gray-900 mt-2">Donations</h1>
        <p className="text-gray-500">Manage donation impacts, URL, and messaging</p>
      </div>

      {/* Settings */}
      <div className="bg-white border rounded-xl p-5 mb-6 space-y-4">
        <h2 className="text-lg font-semibold">Settings</h2>
        <div>
          <label className="text-xs text-gray-600">Donate URL</label>
          <input defaultValue={donateUrl} onBlur={e => updateSetting('donate_url', e.target.value)} className="w-full border rounded-lg px-3 py-2 text-sm" />
        </div>
        <div>
          <label className="text-xs text-gray-600">Thank You Message</label>
          <textarea defaultValue={thankMsg} onBlur={e => updateSetting('thank_you_message', e.target.value)} className="w-full border rounded-lg px-3 py-2 text-sm" rows={3} />
        </div>
      </div>

      {/* Impact tiers */}
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-semibold">Impact Tiers</h2>
        <button onClick={() => setEditImpact({ id: '', amount: 10, emoji: '💛', impact_text: '', sort_order: impacts.length + 1, is_active: true })} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">+ Add Tier</button>
      </div>

      {editImpact && (
        <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
          <div className="grid grid-cols-4 gap-3">
            <div><label className="text-xs text-gray-600">Amount (£)</label><input type="number" value={editImpact.amount} onChange={e => setEditImpact({...editImpact, amount: parseInt(e.target.value)||0})} className="w-full border rounded-lg px-3 py-2" /></div>
            <div><label className="text-xs text-gray-600">Emoji</label><input value={editImpact.emoji} onChange={e => setEditImpact({...editImpact, emoji: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-2xl text-center" /></div>
            <div><label className="text-xs text-gray-600">Order</label><input type="number" value={editImpact.sort_order} onChange={e => setEditImpact({...editImpact, sort_order: parseInt(e.target.value)||0})} className="w-full border rounded-lg px-3 py-2" /></div>
            <div className="flex items-end"><label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={editImpact.is_active} onChange={e => setEditImpact({...editImpact, is_active: e.target.checked})} />Active</label></div>
          </div>
          <div><label className="text-xs text-gray-600">Impact Text</label><input value={editImpact.impact_text} onChange={e => setEditImpact({...editImpact, impact_text: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm" /></div>
          <div className="flex gap-2"><button onClick={() => saveImpact(editImpact)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button><button onClick={() => setEditImpact(null)} className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm">Cancel</button></div>
        </div>
      )}

      <div className="space-y-3">{impacts.map(i => (
        <div key={i.id} className={`bg-white border rounded-xl p-4 ${!i.is_active ? 'opacity-50' : ''}`}>
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-3"><span className="text-2xl">{i.emoji}</span><div><span className="font-semibold text-gray-900">£{i.amount}</span><p className="text-sm text-gray-600">{i.impact_text}</p></div></div>
            <div className="flex gap-2"><button onClick={() => setEditImpact(i)} className="text-cyan-600 text-sm hover:underline">Edit</button><button onClick={() => deleteImpact(i.id)} className="text-red-500 text-sm hover:underline">Delete</button></div>
          </div>
        </div>
      ))}</div>
    </div>
  );
}
