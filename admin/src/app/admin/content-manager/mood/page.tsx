'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';

interface MoodReason {
  id: string;
  mood_type: 'positive' | 'neutral' | 'negative';
  text: string;
  icon: string;
  sort_order: number;
  is_active: boolean;
}

export default function MoodContentPage() {
  const [reasons, setReasons] = useState<MoodReason[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'positive' | 'neutral' | 'negative'>('all');
  const [showAddForm, setShowAddForm] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [newReason, setNewReason] = useState({
    text: '',
    mood_type: 'positive' as const,
    icon: 'circle',
  });

  useEffect(() => {
    fetchReasons();
  }, []);

  async function fetchReasons() {
    setLoading(true);
    const { data, error } = await supabase
      .from('mood_reasons')
      .select('*')
      .order('mood_type')
      .order('sort_order');

    if (data) setReasons(data);
    setLoading(false);
  }

  async function addReason() {
    if (!newReason.text.trim()) return;

    const maxOrder = reasons
      .filter(r => r.mood_type === newReason.mood_type)
      .reduce((max, r) => Math.max(max, r.sort_order), 0);

    const { error } = await supabase.from('mood_reasons').insert({
      ...newReason,
      sort_order: maxOrder + 1,
      is_active: true,
    });

    if (!error) {
      fetchReasons();
      setNewReason({ text: '', mood_type: 'positive', icon: 'circle' });
      setShowAddForm(false);
    }
  }

  async function updateReason(id: string, updates: Partial<MoodReason>) {
    const { error } = await supabase
      .from('mood_reasons')
      .update(updates)
      .eq('id', id);

    if (!error) {
      fetchReasons();
      setEditingId(null);
    }
  }

  async function deleteReason(id: string) {
    if (!confirm('Delete this mood reason?')) return;
    await supabase.from('mood_reasons').delete().eq('id', id);
    fetchReasons();
  }

  const filteredReasons = filter === 'all'
    ? reasons
    : reasons.filter(r => r.mood_type === filter);

  const moodColors = {
    positive: { bg: 'bg-green-50', border: 'border-green-200', badge: 'bg-green-500' },
    neutral: { bg: 'bg-gray-50', border: 'border-gray-200', badge: 'bg-gray-500' },
    negative: { bg: 'bg-red-50', border: 'border-red-200', badge: 'bg-red-500' },
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
          <h1 className="text-3xl font-bold text-gray-900">Mood Reasons</h1>
          <p className="text-gray-600 mt-1">
            Why users feel the way they do
          </p>
        </div>
        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 transition flex items-center gap-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add Reason
        </button>
      </div>

      {/* Add Form */}
      {showAddForm && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Mood Reason</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Reason Text</label>
              <input
                type="text"
                value={newReason.text}
                onChange={(e) => setNewReason({ ...newReason, text: e.target.value })}
                placeholder="e.g., Good sleep"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Mood Type</label>
              <select
                value={newReason.mood_type}
                onChange={(e) => setNewReason({ ...newReason, mood_type: e.target.value as any })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              >
                <option value="positive">Positive 😊</option>
                <option value="neutral">Neutral 😐</option>
                <option value="negative">Negative 😔</option>
              </select>
            </div>
          </div>
          <div className="flex justify-end gap-3 mt-6">
            <button onClick={() => setShowAddForm(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button
              onClick={addReason}
              disabled={!newReason.text.trim()}
              className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 disabled:opacity-50"
            >
              Add Reason
            </button>
          </div>
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-900">{reasons.length}</div>
          <div className="text-sm text-gray-500">Total</div>
        </div>
        <div className="bg-green-50 rounded-xl p-4 border border-green-200">
          <div className="text-2xl font-bold text-green-700">
            {reasons.filter(r => r.mood_type === 'positive').length}
          </div>
          <div className="text-sm text-green-600">Positive</div>
        </div>
        <div className="bg-gray-50 rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-700">
            {reasons.filter(r => r.mood_type === 'neutral').length}
          </div>
          <div className="text-sm text-gray-600">Neutral</div>
        </div>
        <div className="bg-red-50 rounded-xl p-4 border border-red-200">
          <div className="text-2xl font-bold text-red-700">
            {reasons.filter(r => r.mood_type === 'negative').length}
          </div>
          <div className="text-sm text-red-600">Negative</div>
        </div>
      </div>

      {/* Filter tabs */}
      <div className="flex gap-2 mb-6">
        {(['all', 'positive', 'neutral', 'negative'] as const).map((type) => (
          <button
            key={type}
            onClick={() => setFilter(type)}
            className={`px-4 py-2 rounded-lg font-medium transition ${
              filter === type
                ? 'bg-cyan-600 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {type.charAt(0).toUpperCase() + type.slice(1)}
          </button>
        ))}
      </div>

      {/* Reasons list */}
      <div className="space-y-3">
        {filteredReasons.map((reason) => (
          <div
            key={reason.id}
            className={`${moodColors[reason.mood_type].bg} ${moodColors[reason.mood_type].border} border rounded-xl p-4 ${!reason.is_active ? 'opacity-50' : ''}`}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <span className={`${moodColors[reason.mood_type].badge} text-white text-xs px-2 py-1 rounded-full`}>
                  {reason.mood_type}
                </span>
                {editingId === reason.id ? (
                  <input
                    type="text"
                    defaultValue={reason.text}
                    onBlur={(e) => updateReason(reason.id, { text: e.target.value })}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') updateReason(reason.id, { text: (e.target as HTMLInputElement).value });
                      if (e.key === 'Escape') setEditingId(null);
                    }}
                    className="px-2 py-1 border rounded focus:ring-2 focus:ring-cyan-500"
                    autoFocus
                  />
                ) : (
                  <span className="font-medium text-gray-900">{reason.text}</span>
                )}
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => updateReason(reason.id, { is_active: !reason.is_active })}
                  className={`text-sm px-2 py-1 rounded ${reason.is_active ? 'text-green-600' : 'text-gray-400'}`}
                >
                  {reason.is_active ? 'Active' : 'Inactive'}
                </button>
                <button
                  onClick={() => setEditingId(reason.id)}
                  className="text-cyan-600 hover:text-cyan-800 text-sm"
                >
                  Edit
                </button>
                <button
                  onClick={() => deleteReason(reason.id)}
                  className="text-red-600 hover:text-red-800 text-sm"
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
