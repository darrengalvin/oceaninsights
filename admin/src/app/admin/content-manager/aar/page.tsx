'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';

interface AAROption {
  id: string;
  text: string;
  category: string;
  sort_order: number;
  is_active: boolean;
}

type TabType = 'went_well' | 'improve' | 'takeaway';

export default function AARContentPage() {
  const [activeTab, setActiveTab] = useState<TabType>('went_well');
  const [wentWell, setWentWell] = useState<AAROption[]>([]);
  const [improve, setImprove] = useState<AAROption[]>([]);
  const [takeaway, setTakeaway] = useState<AAROption[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newItem, setNewItem] = useState({ text: '', category: 'general' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [wwRes, impRes, takeRes] = await Promise.all([
      supabase.from('aar_went_well_options').select('*').order('sort_order'),
      supabase.from('aar_improve_options').select('*').order('sort_order'),
      supabase.from('aar_takeaway_options').select('*').order('sort_order'),
    ]);

    if (wwRes.data) setWentWell(wwRes.data);
    if (impRes.data) setImprove(impRes.data);
    if (takeRes.data) setTakeaway(takeRes.data);
    setLoading(false);
  }

  const getTable = () => {
    switch (activeTab) {
      case 'went_well': return 'aar_went_well_options';
      case 'improve': return 'aar_improve_options';
      case 'takeaway': return 'aar_takeaway_options';
    }
  };

  const getItems = () => {
    switch (activeTab) {
      case 'went_well': return wentWell;
      case 'improve': return improve;
      case 'takeaway': return takeaway;
    }
  };

  async function addItem() {
    if (!newItem.text.trim()) return;
    const table = getTable();
    const items = getItems();
    const maxOrder = items.reduce((max, i) => Math.max(max, i.sort_order), 0);

    const { error } = await supabase.from(table).insert({
      text: newItem.text,
      category: newItem.category,
      sort_order: maxOrder + 1,
      is_active: true,
    });

    if (!error) {
      fetchData();
      setNewItem({ text: '', category: 'general' });
      setShowAddForm(false);
    }
  }

  async function deleteItem(id: string) {
    if (!confirm('Delete this item?')) return;
    await supabase.from(getTable()).delete().eq('id', id);
    fetchData();
  }

  async function toggleActive(id: string, current: boolean) {
    await supabase.from(getTable()).update({ is_active: !current }).eq('id', id);
    fetchData();
  }

  const tabs = [
    { id: 'went_well', label: 'What Went Well', count: wentWell.length, icon: '✅', color: 'green' },
    { id: 'improve', label: 'To Improve', count: improve.length, icon: '📈', color: 'orange' },
    { id: 'takeaway', label: 'Key Takeaways', count: takeaway.length, icon: '💡', color: 'blue' },
  ] as const;

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
          <h1 className="text-3xl font-bold text-gray-900">After Action Review</h1>
          <p className="text-gray-600 mt-1">Evening reflection options</p>
        </div>
        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 transition flex items-center gap-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add Option
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
                ? `bg-${tab.color}-600 text-white`
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
            style={activeTab === tab.id ? { backgroundColor: tab.color === 'green' ? '#16a34a' : tab.color === 'orange' ? '#ea580c' : '#2563eb' } : {}}
          >
            <span>{tab.icon}</span>
            {tab.label}
            <span className="text-xs px-2 py-0.5 rounded-full bg-white/20">{tab.count}</span>
          </button>
        ))}
      </div>

      {showAddForm && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Option</h2>
          <div className="flex gap-4">
            <input
              type="text"
              value={newItem.text}
              onChange={(e) => setNewItem({ ...newItem, text: e.target.value })}
              placeholder="Enter option text..."
              className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
            />
            <button onClick={() => setShowAddForm(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={addItem} disabled={!newItem.text.trim()} className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 disabled:opacity-50">Add</button>
          </div>
        </div>
      )}

      <div className="bg-white rounded-xl shadow-sm border border-gray-200 divide-y divide-gray-200">
        {getItems().map((item) => (
          <div key={item.id} className={`p-4 flex items-center justify-between ${!item.is_active ? 'opacity-50' : ''}`}>
            <span className="text-gray-900">{item.text}</span>
            <div className="flex items-center gap-2">
              <button onClick={() => toggleActive(item.id, item.is_active)} className={`text-sm px-2 py-1 rounded ${item.is_active ? 'text-green-600' : 'text-gray-400'}`}>
                {item.is_active ? 'Active' : 'Inactive'}
              </button>
              <button onClick={() => deleteItem(item.id)} className="text-red-600 hover:text-red-800 text-sm">Delete</button>
            </div>
          </div>
        ))}
        {getItems().length === 0 && <div className="p-8 text-center text-gray-500">No items yet</div>}
      </div>
    </div>
  );
}
