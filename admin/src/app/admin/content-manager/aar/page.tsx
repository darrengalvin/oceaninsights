'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
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
  const [saving, setSaving] = useState(false);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newItem, setNewItem] = useState({ text: '', category: 'general' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [wwRes, impRes, takeRes] = await Promise.all([
      supabaseAdmin.from('aar_went_well_options').select('*').order('sort_order'),
      supabaseAdmin.from('aar_improve_options').select('*').order('sort_order'),
      supabaseAdmin.from('aar_takeaway_options').select('*').order('sort_order'),
    ]);

    // Log errors for debugging
    if (wwRes.error) console.error('Fetch went_well error:', wwRes.error);
    if (impRes.error) console.error('Fetch improve error:', impRes.error);
    if (takeRes.error) console.error('Fetch takeaway error:', takeRes.error);

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
    if (!newItem.text.trim() || saving) return;
    
    // Immediately update UI
    setSaving(true);
    
    const table = getTable();
    const items = getItems();
    const maxOrder = items.reduce((max, i) => Math.max(max, i.sort_order), 0);

    const { error } = await supabaseAdmin.from(table).insert({
      text: newItem.text,
      category: newItem.category,
      sort_order: maxOrder + 1,
      is_active: true,
    });

    setSaving(false);
    
    if (error) {
      console.error('Add error:', error);
      alert(`Error adding item: ${error.message}\n\nMake sure the database tables exist and SUPABASE_SERVICE_ROLE_KEY is set in Vercel.`);
    } else {
      fetchData();
      setNewItem({ text: '', category: 'general' });
      setShowAddForm(false);
    }
  }

  async function deleteItem(id: string) {
    if (!confirm('Delete this item?')) return;
    
    // Optimistic update - remove from UI immediately
    const updateState = (items: AAROption[]) => items.filter(i => i.id !== id);
    if (activeTab === 'went_well') setWentWell(updateState);
    else if (activeTab === 'improve') setImprove(updateState);
    else setTakeaway(updateState);
    
    // Then do the actual delete
    const { error } = await supabaseAdmin.from(getTable()).delete().eq('id', id);
    if (error) {
      alert(`Error deleting: ${error.message}`);
      fetchData(); // Restore on error
    }
  }

  async function toggleActive(id: string, current: boolean) {
    // Optimistic update - toggle in UI immediately
    const updateState = (items: AAROption[]) => 
      items.map(i => i.id === id ? { ...i, is_active: !current } : i);
    if (activeTab === 'went_well') setWentWell(updateState);
    else if (activeTab === 'improve') setImprove(updateState);
    else setTakeaway(updateState);
    
    // Then do the actual update
    const { error } = await supabaseAdmin.from(getTable()).update({ is_active: !current }).eq('id', id);
    if (error) {
      alert(`Error updating: ${error.message}`);
      fetchData(); // Restore on error
    }
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
          className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700 transition flex items-center gap-2"
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
                ? `bg-${tab.color}-600`
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
            <button onClick={() => setShowAddForm(false)} className="px-4 py-2 text-gray-600" disabled={saving}>Cancel</button>
            <button 
              onClick={addItem} 
              disabled={!newItem.text.trim() || saving} 
              className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700 disabled:opacity-50 min-w-[80px]"
            >
              {saving ? (
                <span className="flex items-center gap-2">
                  <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                  </svg>
                  Saving
                </span>
              ) : 'Add'}
            </button>
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
