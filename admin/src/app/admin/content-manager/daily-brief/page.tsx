'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';

interface EnergyLevel {
  id: string;
  label: string;
  emoji: string;
  description: string;
  sort_order: number;
  is_active: boolean;
}

interface BriefOption {
  id: string;
  text: string;
  category: string;
  sort_order: number;
  is_active: boolean;
}

type TabType = 'energy' | 'objectives' | 'challenges';

export default function DailyBriefContentPage() {
  const [activeTab, setActiveTab] = useState<TabType>('energy');
  const [energyLevels, setEnergyLevels] = useState<EnergyLevel[]>([]);
  const [objectives, setObjectives] = useState<BriefOption[]>([]);
  const [challenges, setChallenges] = useState<BriefOption[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newItem, setNewItem] = useState({ text: '', category: 'general', emoji: '', label: '', description: '' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [energyRes, objRes, chalRes] = await Promise.all([
      supabase.from('daily_brief_energy_levels').select('*').order('sort_order'),
      supabase.from('daily_brief_objectives').select('*').order('sort_order'),
      supabase.from('daily_brief_challenges').select('*').order('sort_order'),
    ]);

    if (energyRes.data) setEnergyLevels(energyRes.data);
    if (objRes.data) setObjectives(objRes.data);
    if (chalRes.data) setChallenges(chalRes.data);
    setLoading(false);
  }

  async function addItem() {
    const table = activeTab === 'energy' 
      ? 'daily_brief_energy_levels' 
      : activeTab === 'objectives' 
        ? 'daily_brief_objectives' 
        : 'daily_brief_challenges';

    const items = activeTab === 'energy' ? energyLevels : activeTab === 'objectives' ? objectives : challenges;
    const maxOrder = items.reduce((max, i) => Math.max(max, i.sort_order), 0);

    const insertData = activeTab === 'energy'
      ? { label: newItem.label, emoji: newItem.emoji, description: newItem.description, sort_order: maxOrder + 1 }
      : { text: newItem.text, category: newItem.category, sort_order: maxOrder + 1 };

    const { error } = await supabase.from(table).insert(insertData);

    if (!error) {
      fetchData();
      setNewItem({ text: '', category: 'general', emoji: '', label: '', description: '' });
      setShowAddForm(false);
    }
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

  const tabs = [
    { id: 'energy', label: 'Energy Levels', count: energyLevels.length, icon: '⚡' },
    { id: 'objectives', label: 'Objectives', count: objectives.length, icon: '🎯' },
    { id: 'challenges', label: 'Challenges', count: challenges.length, icon: '⚠️' },
  ] as const;

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
      {/* Breadcrumb */}
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
          <h1 className="text-3xl font-bold text-gray-900">Daily Brief Content</h1>
          <p className="text-gray-600 mt-1">Energy levels, objectives, and challenges</p>
        </div>
        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 transition flex items-center gap-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add {activeTab === 'energy' ? 'Energy Level' : activeTab === 'objectives' ? 'Objective' : 'Challenge'}
        </button>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => { setActiveTab(tab.id); setShowAddForm(false); }}
            className={`px-4 py-2 rounded-lg font-medium transition flex items-center gap-2 ${
              activeTab === tab.id
                ? 'bg-cyan-600 text-white'
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
          <h2 className="text-lg font-semibold mb-4">
            Add New {activeTab === 'energy' ? 'Energy Level' : activeTab === 'objectives' ? 'Objective' : 'Challenge'}
          </h2>
          
          {activeTab === 'energy' ? (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Label</label>
                <input
                  type="text"
                  value={newItem.label}
                  onChange={(e) => setNewItem({ ...newItem, label: e.target.value })}
                  placeholder="e.g., Fully Charged"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Emoji</label>
                <input
                  type="text"
                  value={newItem.emoji}
                  onChange={(e) => setNewItem({ ...newItem, emoji: e.target.value })}
                  placeholder="⚡"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <input
                  type="text"
                  value={newItem.description}
                  onChange={(e) => setNewItem({ ...newItem, description: e.target.value })}
                  placeholder="Ready to take on anything"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Text</label>
                <input
                  type="text"
                  value={newItem.text}
                  onChange={(e) => setNewItem({ ...newItem, text: e.target.value })}
                  placeholder={activeTab === 'objectives' ? 'Stay focused on one priority' : 'Distractions and interruptions'}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
                <input
                  type="text"
                  value={newItem.category}
                  onChange={(e) => setNewItem({ ...newItem, category: e.target.value })}
                  placeholder="Focus, Health, Work..."
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
            </div>
          )}
          
          <div className="flex justify-end gap-3 mt-6">
            <button onClick={() => setShowAddForm(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button
              onClick={addItem}
              className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700"
            >
              Add Item
            </button>
          </div>
        </div>
      )}

      {/* Content based on active tab */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        {activeTab === 'energy' && (
          <div className="divide-y divide-gray-200">
            {energyLevels.map((level) => (
              <div key={level.id} className={`p-4 flex items-center justify-between ${!level.is_active ? 'opacity-50' : ''}`}>
                <div className="flex items-center gap-4">
                  <span className="text-2xl">{level.emoji}</span>
                  <div>
                    <div className="font-medium text-gray-900">{level.label}</div>
                    <div className="text-sm text-gray-500">{level.description}</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => toggleActive('daily_brief_energy_levels', level.id, level.is_active)}
                    className={`text-sm px-2 py-1 rounded ${level.is_active ? 'text-green-600' : 'text-gray-400'}`}
                  >
                    {level.is_active ? 'Active' : 'Inactive'}
                  </button>
                  <button
                    onClick={() => deleteItem('daily_brief_energy_levels', level.id)}
                    className="text-red-600 hover:text-red-800 text-sm"
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {activeTab === 'objectives' && (
          <div className="divide-y divide-gray-200">
            {objectives.map((obj) => (
              <div key={obj.id} className={`p-4 flex items-center justify-between ${!obj.is_active ? 'opacity-50' : ''}`}>
                <div className="flex items-center gap-4">
                  <span className="text-xs px-2 py-1 rounded-full bg-cyan-100 text-cyan-700">{obj.category}</span>
                  <span className="text-gray-900">{obj.text}</span>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => toggleActive('daily_brief_objectives', obj.id, obj.is_active)}
                    className={`text-sm px-2 py-1 rounded ${obj.is_active ? 'text-green-600' : 'text-gray-400'}`}
                  >
                    {obj.is_active ? 'Active' : 'Inactive'}
                  </button>
                  <button
                    onClick={() => deleteItem('daily_brief_objectives', obj.id)}
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
                  <span className="text-xs px-2 py-1 rounded-full bg-orange-100 text-orange-700">{chal.category}</span>
                  <span className="text-gray-900">{chal.text}</span>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => toggleActive('daily_brief_challenges', chal.id, chal.is_active)}
                    className={`text-sm px-2 py-1 rounded ${chal.is_active ? 'text-green-600' : 'text-gray-400'}`}
                  >
                    {chal.is_active ? 'Active' : 'Inactive'}
                  </button>
                  <button
                    onClick={() => deleteItem('daily_brief_challenges', chal.id)}
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
