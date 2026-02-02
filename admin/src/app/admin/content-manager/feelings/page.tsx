'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';

interface Feeling {
  id: string;
  name: string;
  emoji: string;
  color: string;
  description: string;
  sort_order: number;
  is_active: boolean;
}

interface CopingTool {
  id: string;
  feeling_id: string;
  title: string;
  description: string;
  duration: string;
  icon: string;
  sort_order: number;
  is_active: boolean;
}

export default function FeelingsContentPage() {
  const [feelings, setFeelings] = useState<Feeling[]>([]);
  const [tools, setTools] = useState<CopingTool[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddFeeling, setShowAddFeeling] = useState(false);
  const [showAddTool, setShowAddTool] = useState(false);
  const [selectedFeeling, setSelectedFeeling] = useState<string | null>(null);
  const [newFeeling, setNewFeeling] = useState({ name: '', emoji: '', color: '#00D9C4', description: '' });
  const [newTool, setNewTool] = useState({ feeling_id: '', title: '', description: '', duration: '5 min' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [feelRes, toolRes] = await Promise.all([
      supabase.from('feelings').select('*').order('sort_order'),
      supabase.from('coping_tools').select('*').order('sort_order'),
    ]);

    if (feelRes.data) setFeelings(feelRes.data);
    if (toolRes.data) setTools(toolRes.data);
    setLoading(false);
  }

  async function addFeeling() {
    if (!newFeeling.name.trim()) return;
    const maxOrder = feelings.reduce((max, f) => Math.max(max, f.sort_order), 0);
    
    await supabase.from('feelings').insert({
      ...newFeeling,
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewFeeling({ name: '', emoji: '', color: '#00D9C4', description: '' });
    setShowAddFeeling(false);
  }

  async function addTool() {
    if (!newTool.title.trim() || !newTool.feeling_id) return;
    const maxOrder = tools.filter(t => t.feeling_id === newTool.feeling_id).reduce((max, t) => Math.max(max, t.sort_order), 0);
    
    await supabase.from('coping_tools').insert({
      ...newTool,
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewTool({ feeling_id: '', title: '', description: '', duration: '5 min' });
    setShowAddTool(false);
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
          <h1 className="text-3xl font-bold text-gray-900">Big Feelings Toolkit</h1>
          <p className="text-gray-600 mt-1">Feelings and coping tools for youth</p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => setShowAddFeeling(true)} className="px-4 py-2 bg-pink-600 text-white rounded-lg hover:bg-pink-700">
            + Add Feeling
          </button>
          <button onClick={() => setShowAddTool(true)} className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700">
            + Add Coping Tool
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-gradient-to-r from-pink-500 to-rose-500 rounded-xl p-5 text-white">
          <div className="text-3xl font-bold">{feelings.length}</div>
          <div className="text-pink-100">Feelings</div>
        </div>
        <div className="bg-gradient-to-r from-cyan-500 to-teal-500 rounded-xl p-5 text-white">
          <div className="text-3xl font-bold">{tools.length}</div>
          <div className="text-cyan-100">Coping Tools</div>
        </div>
      </div>

      {/* Add Feeling Form */}
      {showAddFeeling && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Feeling</h2>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <input type="text" value={newFeeling.name} onChange={(e) => setNewFeeling({ ...newFeeling, name: e.target.value })} placeholder="Feeling name" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newFeeling.emoji} onChange={(e) => setNewFeeling({ ...newFeeling, emoji: e.target.value })} placeholder="Emoji 😰" className="px-4 py-2 border rounded-lg" />
            <input type="color" value={newFeeling.color} onChange={(e) => setNewFeeling({ ...newFeeling, color: e.target.value })} className="h-10 w-full rounded-lg" />
            <input type="text" value={newFeeling.description} onChange={(e) => setNewFeeling({ ...newFeeling, description: e.target.value })} placeholder="Description" className="px-4 py-2 border rounded-lg" />
          </div>
          <div className="flex justify-end gap-3 mt-4">
            <button onClick={() => setShowAddFeeling(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={addFeeling} className="px-4 py-2 bg-pink-600 text-white rounded-lg">Add Feeling</button>
          </div>
        </div>
      )}

      {/* Add Tool Form */}
      {showAddTool && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Coping Tool</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <select value={newTool.feeling_id} onChange={(e) => setNewTool({ ...newTool, feeling_id: e.target.value })} className="px-4 py-2 border rounded-lg">
              <option value="">Select feeling...</option>
              {feelings.map(f => <option key={f.id} value={f.id}>{f.emoji} {f.name}</option>)}
            </select>
            <input type="text" value={newTool.title} onChange={(e) => setNewTool({ ...newTool, title: e.target.value })} placeholder="Tool title" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newTool.description} onChange={(e) => setNewTool({ ...newTool, description: e.target.value })} placeholder="Description" className="px-4 py-2 border rounded-lg md:col-span-2" />
            <input type="text" value={newTool.duration} onChange={(e) => setNewTool({ ...newTool, duration: e.target.value })} placeholder="Duration (e.g., 5 min)" className="px-4 py-2 border rounded-lg" />
          </div>
          <div className="flex justify-end gap-3 mt-4">
            <button onClick={() => setShowAddTool(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={addTool} className="px-4 py-2 bg-cyan-600 text-white rounded-lg">Add Tool</button>
          </div>
        </div>
      )}

      {/* Feelings Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {feelings.map((feeling) => (
          <div key={feeling.id} className={`bg-white rounded-xl shadow-sm border-2 p-5 ${!feeling.is_active ? 'opacity-50' : ''}`} style={{ borderColor: feeling.color }}>
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <span className="text-2xl">{feeling.emoji}</span>
                <span className="font-semibold text-gray-900">{feeling.name}</span>
              </div>
              <div className="flex gap-1">
                <button onClick={() => toggleActive('feelings', feeling.id, feeling.is_active)} className={`text-xs px-2 py-1 rounded ${feeling.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100'}`}>
                  {feeling.is_active ? '✓' : '○'}
                </button>
                <button onClick={() => deleteItem('feelings', feeling.id)} className="text-xs px-2 py-1 text-red-600">×</button>
              </div>
            </div>
            
            <div className="text-sm text-gray-500 mb-3">{feeling.description}</div>
            
            <div className="border-t pt-3">
              <div className="text-xs text-gray-400 mb-2">Coping Tools ({tools.filter(t => t.feeling_id === feeling.id).length})</div>
              {tools.filter(t => t.feeling_id === feeling.id).map(tool => (
                <div key={tool.id} className="flex items-center justify-between text-sm py-1">
                  <span>{tool.title}</span>
                  <button onClick={() => deleteItem('coping_tools', tool.id)} className="text-red-400 text-xs">×</button>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
