'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface Affirmation {
  id: string;
  text: string;
  category: string;
  target_audience: string;
  sort_order: number;
  is_active: boolean;
}

interface ConfidenceChallenge {
  id: string;
  text: string;
  category: string;
  sort_order: number;
  is_active: boolean;
}

interface ConfidenceAction {
  id: string;
  text: string;
  difficulty: 'easy' | 'medium' | 'hard';
  sort_order: number;
  is_active: boolean;
}

type TabType = 'affirmations' | 'challenges' | 'actions';

export default function AffirmationsContentPage() {
  const [activeTab, setActiveTab] = useState<TabType>('affirmations');
  const [affirmations, setAffirmations] = useState<Affirmation[]>([]);
  const [challenges, setChallenges] = useState<ConfidenceChallenge[]>([]);
  const [actions, setActions] = useState<ConfidenceAction[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newItem, setNewItem] = useState({ 
    text: '', 
    category: 'general', 
    target_audience: 'all',
    difficulty: 'easy' as const 
  });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [affRes, chalRes, actRes] = await Promise.all([
      supabaseAdmin.from('affirmations').select('*').order('sort_order'),
      supabaseAdmin.from('confidence_challenges').select('*').order('sort_order'),
      supabaseAdmin.from('confidence_actions').select('*').order('sort_order'),
    ]);

    if (affRes.data) setAffirmations(affRes.data);
    if (chalRes.data) setChallenges(chalRes.data);
    if (actRes.data) setActions(actRes.data);
    setLoading(false);
  }

  async function addItem() {
    const table = activeTab === 'affirmations' 
      ? 'affirmations' 
      : activeTab === 'challenges' 
        ? 'confidence_challenges' 
        : 'confidence_actions';

    const items = activeTab === 'affirmations' ? affirmations : activeTab === 'challenges' ? challenges : actions;
    const maxOrder = items.reduce((max, i) => Math.max(max, i.sort_order), 0);

    let insertData: any = { text: newItem.text, sort_order: maxOrder + 1, is_active: true };
    
    if (activeTab === 'affirmations') {
      insertData.category = newItem.category;
      insertData.target_audience = newItem.target_audience;
    } else if (activeTab === 'challenges') {
      insertData.category = newItem.category;
    } else {
      insertData.difficulty = newItem.difficulty;
    }

    const { error } = await supabaseAdmin.from(table).insert(insertData);

    if (!error) {
      fetchData();
      setNewItem({ text: '', category: 'general', target_audience: 'all', difficulty: 'easy' });
      setShowAddForm(false);
    }
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

  const tabs = [
    { id: 'affirmations', label: 'Affirmations', count: affirmations.length, icon: '✨' },
    { id: 'challenges', label: 'Confidence Challenges', count: challenges.length, icon: '💪' },
    { id: 'actions', label: 'Daily Actions', count: actions.length, icon: '🎯' },
  ] as const;

  const difficultyColors = {
    easy: 'bg-green-100 text-green-700',
    medium: 'bg-yellow-100 text-yellow-700',
    hard: 'bg-red-100 text-red-700',
  };

  if (loading) {
    return (
      <div className="p-8">
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="h-64 bg-gray-200 rounded"></div>
        </div>
      </div>
    );
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
          <h1 className="text-3xl font-bold text-gray-900">Affirmations & Confidence</h1>
          <p className="text-gray-600 mt-1">Positive messages and confidence-building content</p>
        </div>
        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700 transition flex items-center gap-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add Item
        </button>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6 flex-wrap">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => { setActiveTab(tab.id); setShowAddForm(false); }}
            className={`px-4 py-2 rounded-lg font-medium transition flex items-center gap-2 ${
              activeTab === tab.id
                ? 'bg-cyan-600'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            <span>{tab.icon}</span>
            {tab.label}
            <span className={`text-xs px-2 py-0.5 rounded-full ${
              activeTab === tab.id ? 'bg-cyan-500' : 'bg-gray-200'
            }`}>
              {tab.count}
            </span>
          </button>
        ))}
      </div>

      {/* Add Form */}
      {showAddForm && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Item</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Text</label>
              <input
                type="text"
                value={newItem.text}
                onChange={(e) => setNewItem({ ...newItem, text: e.target.value })}
                placeholder="Enter text..."
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              />
            </div>
            {activeTab === 'affirmations' && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Audience</label>
                <select
                  value={newItem.target_audience}
                  onChange={(e) => setNewItem({ ...newItem, target_audience: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                >
                  <option value="all">All</option>
                  <option value="youth">Youth</option>
                  <option value="military">Military</option>
                  <option value="veteran">Veteran</option>
                </select>
              </div>
            )}
            {activeTab === 'actions' && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Difficulty</label>
                <select
                  value={newItem.difficulty}
                  onChange={(e) => setNewItem({ ...newItem, difficulty: e.target.value as any })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                >
                  <option value="easy">Easy</option>
                  <option value="medium">Medium</option>
                  <option value="hard">Hard</option>
                </select>
              </div>
            )}
          </div>
          <div className="flex justify-end gap-3 mt-6">
            <button onClick={() => setShowAddForm(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button
              onClick={addItem}
              disabled={!newItem.text.trim()}
              className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700 disabled:opacity-50"
            >
              Add Item
            </button>
          </div>
        </div>
      )}

      {/* Content */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        {activeTab === 'affirmations' && (
          <div className="divide-y divide-gray-200">
            {affirmations.map((aff) => (
              <div key={aff.id} className={`p-4 flex items-center justify-between ${!aff.is_active ? 'opacity-50' : ''}`}>
                <div className="flex items-center gap-4">
                  <span className="text-xl">✨</span>
                  <div>
                    <div className="text-gray-900">"{aff.text}"</div>
                    <div className="text-xs text-gray-500 mt-1">
                      Audience: {aff.target_audience}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => toggleActive('affirmations', aff.id, aff.is_active)}
                    className={`text-sm px-2 py-1 rounded ${aff.is_active ? 'text-green-600' : 'text-gray-400'}`}
                  >
                    {aff.is_active ? 'Active' : 'Inactive'}
                  </button>
                  <button
                    onClick={() => deleteItem('affirmations', aff.id)}
                    className="text-red-600 hover:text-red-800 text-sm"
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {activeTab === 'challenges' && (
          <div className="divide-y divide-gray-200">
            {challenges.map((chal) => (
              <div key={chal.id} className={`p-4 flex items-center justify-between ${!chal.is_active ? 'opacity-50' : ''}`}>
                <div className="flex items-center gap-4">
                  <span className="text-xl">💪</span>
                  <span className="text-gray-900">{chal.text}</span>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => toggleActive('confidence_challenges', chal.id, chal.is_active)}
                    className={`text-sm px-2 py-1 rounded ${chal.is_active ? 'text-green-600' : 'text-gray-400'}`}
                  >
                    {chal.is_active ? 'Active' : 'Inactive'}
                  </button>
                  <button
                    onClick={() => deleteItem('confidence_challenges', chal.id)}
                    className="text-red-600 hover:text-red-800 text-sm"
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {activeTab === 'actions' && (
          <div className="divide-y divide-gray-200">
            {actions.map((act) => (
              <div key={act.id} className={`p-4 flex items-center justify-between ${!act.is_active ? 'opacity-50' : ''}`}>
                <div className="flex items-center gap-4">
                  <span className={`text-xs px-2 py-1 rounded-full ${difficultyColors[act.difficulty]}`}>
                    {act.difficulty}
                  </span>
                  <span className="text-gray-900">{act.text}</span>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => toggleActive('confidence_actions', act.id, act.is_active)}
                    className={`text-sm px-2 py-1 rounded ${act.is_active ? 'text-green-600' : 'text-gray-400'}`}
                  >
                    {act.is_active ? 'Active' : 'Inactive'}
                  </button>
                  <button
                    onClick={() => deleteItem('confidence_actions', act.id)}
                    className="text-red-600 hover:text-red-800 text-sm"
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
