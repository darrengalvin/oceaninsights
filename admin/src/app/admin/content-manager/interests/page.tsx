'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface InterestCategory {
  id: string;
  name: string;
  emoji: string;
  color: string;
  description: string;
  sort_order: number;
  is_active: boolean;
}

interface InterestActivity {
  id: string;
  category_id: string;
  title: string;
  description: string;
  difficulty: string;
  duration: string;
  sort_order: number;
  is_active: boolean;
}

export default function InterestsContentPage() {
  const [categories, setCategories] = useState<InterestCategory[]>([]);
  const [activities, setActivities] = useState<InterestActivity[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddCategory, setShowAddCategory] = useState(false);
  const [showAddActivity, setShowAddActivity] = useState(false);
  const [newCategory, setNewCategory] = useState({ name: '', emoji: '', color: '#00D9C4', description: '' });
  const [newActivity, setNewActivity] = useState({ category_id: '', title: '', description: '', difficulty: 'easy', duration: '10 min' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [catRes, actRes] = await Promise.all([
      supabaseAdmin.from('interest_categories').select('*').order('sort_order'),
      supabaseAdmin.from('interest_activities').select('*').order('sort_order'),
    ]);

    if (catRes.data) setCategories(catRes.data);
    if (actRes.data) setActivities(actRes.data);
    setLoading(false);
  }

  async function addCategory() {
    if (!newCategory.name.trim()) return;
    const maxOrder = categories.reduce((max, c) => Math.max(max, c.sort_order), 0);
    
    await supabaseAdmin.from('interest_categories').insert({
      ...newCategory,
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewCategory({ name: '', emoji: '', color: '#00D9C4', description: '' });
    setShowAddCategory(false);
  }

  async function addActivity() {
    if (!newActivity.title.trim() || !newActivity.category_id) return;
    const maxOrder = activities.filter(a => a.category_id === newActivity.category_id).reduce((max, a) => Math.max(max, a.sort_order), 0);
    
    await supabaseAdmin.from('interest_activities').insert({
      ...newActivity,
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewActivity({ category_id: '', title: '', description: '', difficulty: 'easy', duration: '10 min' });
    setShowAddActivity(false);
  }

  async function deleteItem(table: string, id: string) {
    if (!confirm('Delete this item?')) return;
    await supabaseAdmin.from(table).delete().eq('id', id);
    fetchData();
  }

  async function toggleActive(table: string, id: string, current: boolean) {
    await supabaseAdmin.from(table).update({ is_active: !current }).eq('id', id);
    fetchData();
  }

  const difficultyColors = {
    easy: 'bg-green-100 text-green-700',
    medium: 'bg-yellow-100 text-yellow-700',
    hard: 'bg-red-100 text-red-700',
  };

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
          <h1 className="text-3xl font-bold text-gray-900">Interest Explorer</h1>
          <p className="text-gray-600 mt-1">Interest categories and activities for youth</p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => setShowAddCategory(true)} className="px-4 py-2 bg-teal-600 rounded-lg hover:bg-teal-700">+ Category</button>
          <button onClick={() => setShowAddActivity(true)} className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700">+ Activity</button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-white rounded-xl p-5 border border-gray-200">
          <div className="text-3xl font-bold text-gray-900">{categories.length}</div>
          <div className="text-gray-500">Interest Categories</div>
        </div>
        <div className="bg-white rounded-xl p-5 border border-gray-200">
          <div className="text-3xl font-bold text-gray-900">{activities.length}</div>
          <div className="text-gray-500">Activities</div>
        </div>
      </div>

      {/* Add Category Form */}
      {showAddCategory && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Interest Category</h2>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <input type="text" value={newCategory.name} onChange={(e) => setNewCategory({ ...newCategory, name: e.target.value })} placeholder="Category name" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newCategory.emoji} onChange={(e) => setNewCategory({ ...newCategory, emoji: e.target.value })} placeholder="Emoji 🎨" className="px-4 py-2 border rounded-lg" />
            <input type="color" value={newCategory.color} onChange={(e) => setNewCategory({ ...newCategory, color: e.target.value })} className="h-10 w-full rounded-lg" />
            <input type="text" value={newCategory.description} onChange={(e) => setNewCategory({ ...newCategory, description: e.target.value })} placeholder="Description" className="px-4 py-2 border rounded-lg" />
          </div>
          <div className="flex justify-end gap-3 mt-4">
            <button onClick={() => setShowAddCategory(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={addCategory} className="px-4 py-2 bg-teal-600 rounded-lg">Add Category</button>
          </div>
        </div>
      )}

      {/* Add Activity Form */}
      {showAddActivity && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Activity</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <select value={newActivity.category_id} onChange={(e) => setNewActivity({ ...newActivity, category_id: e.target.value })} className="px-4 py-2 border rounded-lg">
              <option value="">Select category...</option>
              {categories.map(c => <option key={c.id} value={c.id}>{c.emoji} {c.name}</option>)}
            </select>
            <input type="text" value={newActivity.title} onChange={(e) => setNewActivity({ ...newActivity, title: e.target.value })} placeholder="Activity title" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newActivity.description} onChange={(e) => setNewActivity({ ...newActivity, description: e.target.value })} placeholder="Description" className="px-4 py-2 border rounded-lg md:col-span-2" />
            <select value={newActivity.difficulty} onChange={(e) => setNewActivity({ ...newActivity, difficulty: e.target.value })} className="px-4 py-2 border rounded-lg">
              <option value="easy">Easy</option>
              <option value="medium">Medium</option>
              <option value="hard">Hard</option>
            </select>
            <input type="text" value={newActivity.duration} onChange={(e) => setNewActivity({ ...newActivity, duration: e.target.value })} placeholder="Duration (e.g., 10 min)" className="px-4 py-2 border rounded-lg" />
          </div>
          <div className="flex justify-end gap-3 mt-4">
            <button onClick={() => setShowAddActivity(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={addActivity} className="px-4 py-2 bg-cyan-600 rounded-lg">Add Activity</button>
          </div>
        </div>
      )}

      {/* Categories Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {categories.map((cat) => (
          <div key={cat.id} className={`bg-white rounded-xl shadow-sm border-2 p-5 ${!cat.is_active ? 'opacity-50' : ''}`} style={{ borderColor: cat.color }}>
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-center gap-2">
                <span className="text-2xl">{cat.emoji}</span>
                <div>
                  <span className="font-semibold text-gray-900">{cat.name}</span>
                  {cat.description && <p className="text-xs text-gray-500">{cat.description}</p>}
                </div>
              </div>
              <div className="flex gap-1">
                <button onClick={() => toggleActive('interest_categories', cat.id, cat.is_active)} className={`text-xs px-2 py-1 rounded ${cat.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100'}`}>
                  {cat.is_active ? '✓' : '○'}
                </button>
                <button onClick={() => deleteItem('interest_categories', cat.id)} className="text-xs px-2 py-1 text-red-600">×</button>
              </div>
            </div>
            
            <div className="border-t pt-3">
              <div className="text-xs text-gray-400 mb-2">Activities ({activities.filter(a => a.category_id === cat.id).length})</div>
              {activities.filter(a => a.category_id === cat.id).map(activity => (
                <div key={activity.id} className="flex items-center justify-between text-sm py-1">
                  <div className="flex items-center gap-2 flex-1">
                    <span className={`text-xs px-1.5 py-0.5 rounded ${difficultyColors[activity.difficulty as keyof typeof difficultyColors] || difficultyColors.easy}`}>
                      {activity.difficulty}
                    </span>
                    <span className="truncate">{activity.title}</span>
                  </div>
                  <button onClick={() => deleteItem('interest_activities', activity.id)} className="text-red-400 text-xs ml-2">×</button>
                </div>
              ))}
              {activities.filter(a => a.category_id === cat.id).length === 0 && (
                <div className="text-xs text-gray-400">No activities yet</div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
