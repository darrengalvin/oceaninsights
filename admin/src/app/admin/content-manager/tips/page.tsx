'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';

interface TipCategory {
  id: string;
  slug: string;
  title: string;
  subtitle: string;
  icon: string;
  accent_color: string;
  target_audience: string;
  sort_order: number;
  is_active: boolean;
}

interface Tip {
  id: string;
  category_id: string;
  title: string;
  content: string;
  icon: string;
  key_points: string[];
  sort_order: number;
  is_active: boolean;
}

export default function TipsContentPage() {
  const [categories, setCategories] = useState<TipCategory[]>([]);
  const [tips, setTips] = useState<Tip[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [showAddCategory, setShowAddCategory] = useState(false);
  const [showAddTip, setShowAddTip] = useState(false);
  const [newCategory, setNewCategory] = useState({ slug: '', title: '', subtitle: '', target_audience: 'all', accent_color: '#00D9C4' });
  const [newTip, setNewTip] = useState({ category_id: '', title: '', content: '', key_points: '' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [catRes, tipRes] = await Promise.all([
      supabase.from('tip_categories').select('*').order('sort_order'),
      supabase.from('tips').select('*').order('sort_order'),
    ]);

    if (catRes.data) setCategories(catRes.data);
    if (tipRes.data) setTips(tipRes.data);
    setLoading(false);
  }

  async function addCategory() {
    if (!newCategory.title.trim()) return;
    const maxOrder = categories.reduce((max, c) => Math.max(max, c.sort_order), 0);
    
    await supabase.from('tip_categories').insert({
      ...newCategory,
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewCategory({ slug: '', title: '', subtitle: '', target_audience: 'all', accent_color: '#00D9C4' });
    setShowAddCategory(false);
  }

  async function addTip() {
    if (!newTip.title.trim() || !newTip.category_id) return;
    const maxOrder = tips.filter(t => t.category_id === newTip.category_id).reduce((max, t) => Math.max(max, t.sort_order), 0);
    
    await supabase.from('tips').insert({
      category_id: newTip.category_id,
      title: newTip.title,
      content: newTip.content,
      key_points: newTip.key_points.split('\n').filter(Boolean),
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewTip({ category_id: '', title: '', content: '', key_points: '' });
    setShowAddTip(false);
  }

  async function deleteItem(table: string, id: string) {
    if (!confirm('Delete this item?')) return;
    await supabase.from(table).delete().eq('id', id);
    fetchData();
  }

  async function toggleActive(table: string, id: string, current: boolean) {
    await supabase.from(table).update({ is_active: !current }).eq('id', id);
    fetchData();
  }

  if (loading) {
    return <div className="p-8"><div className="animate-pulse h-64 bg-gray-200 rounded"></div></div>;
  }

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <Link href="/admin/content-manager" className="text-cyan-600 hover:text-cyan-800 text-sm flex items-center gap-1">
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          Back to Content Manager
        </Link>
      </div>

      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Tip Cards</h1>
          <p className="text-gray-600 mt-1">Swipeable tip cards for various topics</p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => setShowAddCategory(true)} className="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700">+ Category</button>
          <button onClick={() => setShowAddTip(true)} className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700">+ Tip</button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-gradient-to-r from-purple-500 to-indigo-500 rounded-xl p-5 text-white">
          <div className="text-3xl font-bold">{categories.length}</div>
          <div className="text-purple-100">Categories</div>
        </div>
        <div className="bg-gradient-to-r from-cyan-500 to-teal-500 rounded-xl p-5 text-white">
          <div className="text-3xl font-bold">{tips.length}</div>
          <div className="text-cyan-100">Tips</div>
        </div>
      </div>

      {/* Add Category Form */}
      {showAddCategory && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Category</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <input type="text" value={newCategory.slug} onChange={(e) => setNewCategory({ ...newCategory, slug: e.target.value })} placeholder="Slug" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newCategory.title} onChange={(e) => setNewCategory({ ...newCategory, title: e.target.value })} placeholder="Title" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newCategory.subtitle} onChange={(e) => setNewCategory({ ...newCategory, subtitle: e.target.value })} placeholder="Subtitle" className="px-4 py-2 border rounded-lg" />
            <select value={newCategory.target_audience} onChange={(e) => setNewCategory({ ...newCategory, target_audience: e.target.value })} className="px-4 py-2 border rounded-lg">
              <option value="all">All</option>
              <option value="youth">Youth</option>
              <option value="military">Military</option>
              <option value="veteran">Veteran</option>
            </select>
            <input type="color" value={newCategory.accent_color} onChange={(e) => setNewCategory({ ...newCategory, accent_color: e.target.value })} className="h-10 w-full rounded-lg" />
          </div>
          <div className="flex justify-end gap-3 mt-4">
            <button onClick={() => setShowAddCategory(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={addCategory} className="px-4 py-2 bg-purple-600 text-white rounded-lg">Add Category</button>
          </div>
        </div>
      )}

      {/* Add Tip Form */}
      {showAddTip && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Tip</h2>
          <div className="grid grid-cols-1 gap-4">
            <select value={newTip.category_id} onChange={(e) => setNewTip({ ...newTip, category_id: e.target.value })} className="px-4 py-2 border rounded-lg">
              <option value="">Select category...</option>
              {categories.map(c => <option key={c.id} value={c.id}>{c.title}</option>)}
            </select>
            <input type="text" value={newTip.title} onChange={(e) => setNewTip({ ...newTip, title: e.target.value })} placeholder="Tip title" className="px-4 py-2 border rounded-lg" />
            <textarea value={newTip.content} onChange={(e) => setNewTip({ ...newTip, content: e.target.value })} placeholder="Tip content" rows={3} className="px-4 py-2 border rounded-lg" />
            <textarea value={newTip.key_points} onChange={(e) => setNewTip({ ...newTip, key_points: e.target.value })} placeholder="Key points (one per line)" rows={3} className="px-4 py-2 border rounded-lg" />
          </div>
          <div className="flex justify-end gap-3 mt-4">
            <button onClick={() => setShowAddTip(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={addTip} className="px-4 py-2 bg-cyan-600 text-white rounded-lg">Add Tip</button>
          </div>
        </div>
      )}

      {/* Categories Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {categories.map((cat) => (
          <div key={cat.id} className={`bg-white rounded-xl shadow-sm border-l-4 p-5 ${!cat.is_active ? 'opacity-50' : ''}`} style={{ borderLeftColor: cat.accent_color }}>
            <div className="flex items-start justify-between mb-2">
              <div>
                <h3 className="font-semibold text-gray-900">{cat.title}</h3>
                <p className="text-sm text-gray-500">{cat.subtitle}</p>
              </div>
              <div className="flex gap-1">
                <button onClick={() => toggleActive('tip_categories', cat.id, cat.is_active)} className={`text-xs px-2 py-1 rounded ${cat.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100'}`}>
                  {cat.is_active ? '✓' : '○'}
                </button>
                <button onClick={() => deleteItem('tip_categories', cat.id)} className="text-xs px-2 py-1 text-red-600">×</button>
              </div>
            </div>
            <div className="flex gap-2 mb-3">
              <span className="text-xs bg-gray-100 px-2 py-1 rounded">{cat.slug}</span>
              <span className="text-xs bg-indigo-100 text-indigo-700 px-2 py-1 rounded">{cat.target_audience}</span>
            </div>
            <div className="border-t pt-3">
              <div className="text-xs text-gray-400 mb-2">Tips ({tips.filter(t => t.category_id === cat.id).length})</div>
              {tips.filter(t => t.category_id === cat.id).slice(0, 3).map(tip => (
                <div key={tip.id} className="flex items-center justify-between text-sm py-1">
                  <span className="truncate flex-1">{tip.title}</span>
                  <button onClick={() => deleteItem('tips', tip.id)} className="text-red-400 text-xs ml-2">×</button>
                </div>
              ))}
              {tips.filter(t => t.category_id === cat.id).length > 3 && (
                <div className="text-xs text-gray-400">+{tips.filter(t => t.category_id === cat.id).length - 3} more</div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
