'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface Release {
  id: string;
  version: string;
  title: string;
  subtitle: string | null;
  release_date: string;
  is_active: boolean;
  items?: Item[];
}

interface Item {
  id: string;
  release_id: string;
  emoji: string;
  title: string;
  description: string;
  sort_order: number;
  is_active: boolean;
}

export default function WhatsNewPage() {
  const [releases, setReleases] = useState<Release[]>([]);
  const [selectedRelease, setSelectedRelease] = useState<Release | null>(null);
  const [items, setItems] = useState<Item[]>([]);
  const [loading, setLoading] = useState(true);

  // Add forms
  const [showAddRelease, setShowAddRelease] = useState(false);
  const [showAddItem, setShowAddItem] = useState(false);

  const [newRelease, setNewRelease] = useState({ version: '', title: "What's New", subtitle: '', release_date: new Date().toISOString().split('T')[0] });
  const [newItem, setNewItem] = useState({ emoji: '✨', title: '', description: '' });

  useEffect(() => { fetchReleases(); }, []);

  async function fetchReleases() {
    setLoading(true);
    const { data } = await supabaseAdmin
      .from('whats_new_releases')
      .select('*')
      .order('release_date', { ascending: false });
    if (data) {
      setReleases(data);
      if (data.length > 0 && !selectedRelease) {
        selectRelease(data[0]);
      }
    }
    setLoading(false);
  }

  async function selectRelease(release: Release) {
    setSelectedRelease(release);
    const { data } = await supabaseAdmin
      .from('whats_new_items')
      .select('*')
      .eq('release_id', release.id)
      .order('sort_order');
    if (data) setItems(data);
  }

  async function addRelease() {
    if (!newRelease.version) return;
    await supabaseAdmin.from('whats_new_releases').insert({
      version: newRelease.version,
      title: newRelease.title,
      subtitle: newRelease.subtitle || null,
      release_date: newRelease.release_date,
    });
    setNewRelease({ version: '', title: "What's New", subtitle: '', release_date: new Date().toISOString().split('T')[0] });
    setShowAddRelease(false);
    await fetchReleases();
  }

  async function addItem() {
    if (!selectedRelease || !newItem.title) return;
    await supabaseAdmin.from('whats_new_items').insert({
      release_id: selectedRelease.id,
      emoji: newItem.emoji,
      title: newItem.title,
      description: newItem.description,
      sort_order: items.length,
    });
    setNewItem({ emoji: '✨', title: '', description: '' });
    setShowAddItem(false);
    await selectRelease(selectedRelease);
  }

  async function deleteRelease(id: string) {
    await supabaseAdmin.from('whats_new_releases').delete().eq('id', id);
    if (selectedRelease?.id === id) {
      setSelectedRelease(null);
      setItems([]);
    }
    await fetchReleases();
  }

  async function deleteItem(id: string) {
    await supabaseAdmin.from('whats_new_items').delete().eq('id', id);
    if (selectedRelease) await selectRelease(selectedRelease);
  }

  async function toggleReleaseActive(id: string, current: boolean) {
    await supabaseAdmin.from('whats_new_releases').update({ is_active: !current }).eq('id', id);
    await fetchReleases();
  }

  async function toggleItemActive(id: string, current: boolean) {
    await supabaseAdmin.from('whats_new_items').update({ is_active: !current }).eq('id', id);
    if (selectedRelease) await selectRelease(selectedRelease);
  }

  if (loading) return (
    <div className="p-8">
      <div className="animate-pulse space-y-4">
        <div className="h-8 bg-gray-200 rounded w-1/4"></div>
        <div className="grid grid-cols-1 gap-4">
          {[...Array(4)].map((_, i) => <div key={i} className="h-16 bg-gray-200 rounded-xl"></div>)}
        </div>
      </div>
    </div>
  );

  return (
    <div className="p-8 max-w-6xl mx-auto">
      {/* Header */}
      <div className="mb-6 flex items-center gap-4">
        <Link href="/admin/content-manager" className="text-gray-400 hover:text-gray-600 transition">← Back</Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">🆕 What&apos;s New</h1>
          <p className="text-gray-500 text-sm">Manage release notes shown to users after app updates</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left: Releases list */}
        <div className="lg:col-span-1">
          <div className="flex justify-between items-center mb-3">
            <h2 className="font-semibold text-gray-700">Releases</h2>
            <button onClick={() => setShowAddRelease(!showAddRelease)}
              className="bg-cyan-600 text-white px-3 py-1.5 rounded-lg text-sm hover:bg-cyan-700 transition">
              {showAddRelease ? 'Cancel' : '+ New Version'}
            </button>
          </div>

          {showAddRelease && (
            <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-3 space-y-2">
              <input className="w-full border rounded-lg p-2 text-sm" placeholder="Version (e.g. 1.1.0)"
                value={newRelease.version} onChange={e => setNewRelease({ ...newRelease, version: e.target.value })} />
              <input className="w-full border rounded-lg p-2 text-sm" placeholder="Title"
                value={newRelease.title} onChange={e => setNewRelease({ ...newRelease, title: e.target.value })} />
              <input className="w-full border rounded-lg p-2 text-sm" placeholder="Subtitle (optional)"
                value={newRelease.subtitle} onChange={e => setNewRelease({ ...newRelease, subtitle: e.target.value })} />
              <input className="w-full border rounded-lg p-2 text-sm" type="date"
                value={newRelease.release_date} onChange={e => setNewRelease({ ...newRelease, release_date: e.target.value })} />
              <button onClick={addRelease} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm w-full">Create Release</button>
            </div>
          )}

          <div className="space-y-2">
            {releases.map(r => (
              <div key={r.id}
                className={`border rounded-xl p-3 cursor-pointer transition ${selectedRelease?.id === r.id ? 'border-cyan-500 bg-cyan-50' : 'border-gray-200 bg-white hover:border-gray-300'} ${!r.is_active ? 'opacity-50' : ''}`}
                onClick={() => selectRelease(r)}>
                <div className="flex items-center justify-between">
                  <div>
                    <span className="font-mono font-semibold text-sm text-gray-900">v{r.version}</span>
                    <p className="text-xs text-gray-500">{r.title}</p>
                    <p className="text-xs text-gray-400">{r.release_date}</p>
                  </div>
                  <div className="flex gap-1">
                    <button onClick={(e) => { e.stopPropagation(); toggleReleaseActive(r.id, r.is_active); }}
                      className={`px-2 py-1 rounded text-xs ${r.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-200 text-gray-500'}`}>
                      {r.is_active ? 'Live' : 'Draft'}
                    </button>
                    <button onClick={(e) => { e.stopPropagation(); if (confirm('Delete this release and all its items?')) deleteRelease(r.id); }}
                      className="px-2 py-1 rounded text-xs bg-red-50 text-red-600 hover:bg-red-100">
                      ✕
                    </button>
                  </div>
                </div>
              </div>
            ))}
            {releases.length === 0 && (
              <p className="text-gray-400 text-sm text-center py-8">No releases yet. Create one to get started.</p>
            )}
          </div>
        </div>

        {/* Right: Items for selected release */}
        <div className="lg:col-span-2">
          {selectedRelease ? (
            <>
              <div className="flex justify-between items-center mb-3">
                <div>
                  <h2 className="font-semibold text-gray-700">
                    v{selectedRelease.version} — {selectedRelease.title}
                  </h2>
                  {selectedRelease.subtitle && <p className="text-sm text-gray-500">{selectedRelease.subtitle}</p>}
                </div>
                <button onClick={() => setShowAddItem(!showAddItem)}
                  className="bg-cyan-600 text-white px-3 py-1.5 rounded-lg text-sm hover:bg-cyan-700 transition">
                  {showAddItem ? 'Cancel' : '+ Add Item'}
                </button>
              </div>

              {showAddItem && (
                <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-3 space-y-2">
                  <div className="flex gap-2">
                    <input className="w-20 border rounded-lg p-2 text-sm text-center" placeholder="Emoji"
                      value={newItem.emoji} onChange={e => setNewItem({ ...newItem, emoji: e.target.value })} />
                    <input className="flex-1 border rounded-lg p-2 text-sm" placeholder="Title (e.g. New Health Tracker)"
                      value={newItem.title} onChange={e => setNewItem({ ...newItem, title: e.target.value })} />
                  </div>
                  <textarea className="w-full border rounded-lg p-2 text-sm" rows={2} placeholder="Description"
                    value={newItem.description} onChange={e => setNewItem({ ...newItem, description: e.target.value })} />
                  <button onClick={addItem} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm w-full">Add Item</button>
                </div>
              )}

              {/* Preview card */}
              <div className="bg-gray-900 rounded-2xl p-6 mb-4">
                <p className="text-gray-400 text-xs uppercase tracking-wider mb-1">Preview</p>
                <h3 className="text-white text-lg font-bold mb-1">{selectedRelease.title}</h3>
                {selectedRelease.subtitle && <p className="text-gray-400 text-sm mb-4">{selectedRelease.subtitle}</p>}
                <div className="space-y-3">
                  {items.filter(i => i.is_active).map(item => (
                    <div key={item.id} className="flex items-start gap-3">
                      <span className="text-xl">{item.emoji}</span>
                      <div>
                        <p className="text-white font-medium text-sm">{item.title}</p>
                        <p className="text-gray-400 text-xs">{item.description}</p>
                      </div>
                    </div>
                  ))}
                  {items.filter(i => i.is_active).length === 0 && (
                    <p className="text-gray-500 text-sm">No items yet — add some highlights!</p>
                  )}
                </div>
              </div>

              {/* Items list */}
              <div className="space-y-2">
                {items.map(item => (
                  <div key={item.id} className={`border rounded-xl p-3 flex items-start justify-between ${item.is_active ? 'bg-white border-gray-200' : 'bg-gray-50 border-gray-100 opacity-60'}`}>
                    <div className="flex items-start gap-3 min-w-0">
                      <span className="text-xl">{item.emoji}</span>
                      <div className="min-w-0">
                        <p className="font-medium text-sm text-gray-900">{item.title}</p>
                        <p className="text-xs text-gray-500 truncate">{item.description}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 ml-3 flex-shrink-0">
                      <button onClick={() => toggleItemActive(item.id, item.is_active)}
                        className={`px-2 py-1 rounded text-xs ${item.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-200 text-gray-500'}`}>
                        {item.is_active ? 'Active' : 'Hidden'}
                      </button>
                      <button onClick={() => { if (confirm('Delete this item?')) deleteItem(item.id); }}
                        className="px-2 py-1 rounded text-xs bg-red-50 text-red-600 hover:bg-red-100">
                        Delete
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </>
          ) : (
            <div className="flex items-center justify-center h-64 text-gray-400">
              Select a release or create a new one
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
