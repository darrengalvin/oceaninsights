'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface LearningStyle {
  id: string;
  name: string;
  emoji: string;
  description: string;
  tips: string[];
  sort_order: number;
  is_active: boolean;
}

interface StudyStrategy {
  id: string;
  name: string;
  description: string;
  best_for: string[];
  sort_order: number;
  is_active: boolean;
}

export default function LearningContentPage() {
  const [styles, setStyles] = useState<LearningStyle[]>([]);
  const [strategies, setStrategies] = useState<StudyStrategy[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'styles' | 'strategies'>('styles');
  const [showAddForm, setShowAddForm] = useState(false);
  const [newStyle, setNewStyle] = useState({ name: '', emoji: '', description: '', tips: '' });
  const [newStrategy, setNewStrategy] = useState({ name: '', description: '', best_for: '' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [styleRes, stratRes] = await Promise.all([
      supabaseAdmin.from('learning_styles').select('*').order('sort_order'),
      supabaseAdmin.from('study_strategies').select('*').order('sort_order'),
    ]);

    if (styleRes.data) setStyles(styleRes.data);
    if (stratRes.data) setStrategies(stratRes.data);
    setLoading(false);
  }

  async function addStyle() {
    if (!newStyle.name.trim()) return;
    const maxOrder = styles.reduce((max, s) => Math.max(max, s.sort_order), 0);
    
    await supabaseAdmin.from('learning_styles').insert({
      name: newStyle.name,
      emoji: newStyle.emoji,
      description: newStyle.description,
      tips: newStyle.tips.split('\n').filter(Boolean),
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewStyle({ name: '', emoji: '', description: '', tips: '' });
    setShowAddForm(false);
  }

  async function addStrategy() {
    if (!newStrategy.name.trim()) return;
    const maxOrder = strategies.reduce((max, s) => Math.max(max, s.sort_order), 0);
    
    await supabaseAdmin.from('study_strategies').insert({
      name: newStrategy.name,
      description: newStrategy.description,
      best_for: newStrategy.best_for.split(',').map(s => s.trim()).filter(Boolean),
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewStrategy({ name: '', description: '', best_for: '' });
    setShowAddForm(false);
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

  if (loading) {
    return <div className="p-8"><div className="animate-pulse h-64 bg-gray-200 rounded"></div></div>;
  }

  return (
    <div className="p-8 max-w-5xl mx-auto">
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
          <h1 className="text-3xl font-bold text-gray-900">Learning & Study</h1>
          <p className="text-gray-600 mt-1">Learning styles and study strategies</p>
        </div>
        <button onClick={() => setShowAddForm(!showAddForm)} className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700">
          + Add {activeTab === 'styles' ? 'Style' : 'Strategy'}
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-white rounded-xl p-5 border border-gray-200">
          <div className="text-3xl font-bold text-gray-900">{styles.length}</div>
          <div className="text-gray-500">Learning Styles</div>
        </div>
        <div className="bg-white rounded-xl p-5 border border-gray-200">
          <div className="text-3xl font-bold text-gray-900">{strategies.length}</div>
          <div className="text-gray-500">Study Strategies</div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6">
        <button
          onClick={() => { setActiveTab('styles'); setShowAddForm(false); }}
          className={`px-4 py-2 rounded-lg font-medium transition ${activeTab === 'styles' ? 'bg-amber-600' : 'bg-gray-100 text-gray-600'}`}
        >
          📚 Learning Styles ({styles.length})
        </button>
        <button
          onClick={() => { setActiveTab('strategies'); setShowAddForm(false); }}
          className={`px-4 py-2 rounded-lg font-medium transition ${activeTab === 'strategies' ? 'bg-blue-600' : 'bg-gray-100 text-gray-600'}`}
        >
          🎯 Study Strategies ({strategies.length})
        </button>
      </div>

      {/* Add Form */}
      {showAddForm && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New {activeTab === 'styles' ? 'Learning Style' : 'Study Strategy'}</h2>
          
          {activeTab === 'styles' ? (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <input type="text" value={newStyle.name} onChange={(e) => setNewStyle({ ...newStyle, name: e.target.value })} placeholder="Style name (e.g., Visual)" className="px-4 py-2 border rounded-lg" />
              <input type="text" value={newStyle.emoji} onChange={(e) => setNewStyle({ ...newStyle, emoji: e.target.value })} placeholder="Emoji 👁️" className="px-4 py-2 border rounded-lg" />
              <input type="text" value={newStyle.description} onChange={(e) => setNewStyle({ ...newStyle, description: e.target.value })} placeholder="Description" className="px-4 py-2 border rounded-lg md:col-span-2" />
              <textarea value={newStyle.tips} onChange={(e) => setNewStyle({ ...newStyle, tips: e.target.value })} placeholder="Tips (one per line)" rows={3} className="px-4 py-2 border rounded-lg md:col-span-2" />
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <input type="text" value={newStrategy.name} onChange={(e) => setNewStrategy({ ...newStrategy, name: e.target.value })} placeholder="Strategy name" className="px-4 py-2 border rounded-lg" />
              <input type="text" value={newStrategy.best_for} onChange={(e) => setNewStrategy({ ...newStrategy, best_for: e.target.value })} placeholder="Best for (comma separated)" className="px-4 py-2 border rounded-lg" />
              <input type="text" value={newStrategy.description} onChange={(e) => setNewStrategy({ ...newStrategy, description: e.target.value })} placeholder="Description" className="px-4 py-2 border rounded-lg md:col-span-2" />
            </div>
          )}
          
          <div className="flex justify-end gap-3 mt-4">
            <button onClick={() => setShowAddForm(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={activeTab === 'styles' ? addStyle : addStrategy} className="px-4 py-2 bg-cyan-600 rounded-lg">Add</button>
          </div>
        </div>
      )}

      {/* Content */}
      {activeTab === 'styles' && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {styles.map((style) => (
            <div key={style.id} className={`bg-white rounded-xl shadow-sm border border-gray-200 p-5 ${!style.is_active ? 'opacity-50' : ''}`}>
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-3">
                  <span className="text-3xl">{style.emoji}</span>
                  <div>
                    <h3 className="font-semibold text-gray-900">{style.name}</h3>
                    <p className="text-sm text-gray-500">{style.description}</p>
                  </div>
                </div>
                <div className="flex gap-1">
                  <button onClick={() => toggleActive('learning_styles', style.id, style.is_active)} className={`text-xs px-2 py-1 rounded ${style.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100'}`}>
                    {style.is_active ? '✓' : '○'}
                  </button>
                  <button onClick={() => deleteItem('learning_styles', style.id)} className="text-xs px-2 py-1 text-red-600">×</button>
                </div>
              </div>
              <div className="border-t pt-3">
                <div className="text-xs text-gray-400 mb-2">Tips</div>
                <ul className="text-sm text-gray-600 space-y-1">
                  {style.tips?.map((tip, i) => (
                    <li key={i} className="flex items-start gap-2">
                      <span className="text-amber-500">•</span>
                      {tip}
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          ))}
        </div>
      )}

      {activeTab === 'strategies' && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 divide-y divide-gray-200">
          {strategies.map((strategy) => (
            <div key={strategy.id} className={`p-5 ${!strategy.is_active ? 'opacity-50' : ''}`}>
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <h3 className="font-semibold text-gray-900">{strategy.name}</h3>
                  <p className="text-sm text-gray-500 mt-1">{strategy.description}</p>
                  <div className="flex flex-wrap gap-1 mt-2">
                    {strategy.best_for?.map((style, i) => (
                      <span key={i} className="text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded">{style}</span>
                    ))}
                  </div>
                </div>
                <div className="flex gap-1 ml-4">
                  <button onClick={() => toggleActive('study_strategies', strategy.id, strategy.is_active)} className={`text-xs px-2 py-1 rounded ${strategy.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100'}`}>
                    {strategy.is_active ? '✓' : '○'}
                  </button>
                  <button onClick={() => deleteItem('study_strategies', strategy.id)} className="text-xs px-2 py-1 text-red-600">×</button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
