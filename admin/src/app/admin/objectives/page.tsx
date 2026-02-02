'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';

interface Objective {
  id: string;
  text: string;
  category: string;
  objective_type: 'primary' | 'secondary' | 'contingency';
  sort_order: number;
  is_active: boolean;
  user_types: string[];
  created_at: string;
  updated_at: string;
}

interface Category {
  id: string;
  name: string;
  color: string;
}

export default function ObjectivesPage() {
  const [objectives, setObjectives] = useState<Objective[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'primary' | 'secondary' | 'contingency'>('all');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [newObjective, setNewObjective] = useState({
    text: '',
    category: '',
    objective_type: 'primary' as const,
    user_types: ['all'],
  });
  const [showAddForm, setShowAddForm] = useState(false);

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    try {
      const [objRes, catRes] = await Promise.all([
        supabase.from('mission_objectives').select('*').order('objective_type').order('sort_order'),
        supabase.from('objective_categories').select('*').order('sort_order'),
      ]);

      if (objRes.data) setObjectives(objRes.data);
      if (catRes.data) setCategories(catRes.data);
    } catch (error) {
      console.error('Error fetching data:', error);
    }
    setLoading(false);
  }

  async function addObjective() {
    if (!newObjective.text.trim() || !newObjective.category) return;

    const maxOrder = objectives
      .filter(o => o.objective_type === newObjective.objective_type)
      .reduce((max, o) => Math.max(max, o.sort_order), 0);

    const { error } = await supabase.from('mission_objectives').insert({
      ...newObjective,
      sort_order: maxOrder + 1,
      is_active: true,
    });

    if (!error) {
      fetchData();
      setNewObjective({ text: '', category: '', objective_type: 'primary', user_types: ['all'] });
      setShowAddForm(false);
    }
  }

  async function updateObjective(id: string, updates: Partial<Objective>) {
    const { error } = await supabase
      .from('mission_objectives')
      .update(updates)
      .eq('id', id);

    if (!error) {
      fetchData();
      setEditingId(null);
    }
  }

  async function deleteObjective(id: string) {
    if (!confirm('Are you sure you want to delete this objective?')) return;

    const { error } = await supabase
      .from('mission_objectives')
      .delete()
      .eq('id', id);

    if (!error) fetchData();
  }

  async function toggleActive(id: string, currentState: boolean) {
    await updateObjective(id, { is_active: !currentState });
  }

  const filteredObjectives = filter === 'all'
    ? objectives
    : objectives.filter(o => o.objective_type === filter);

  const typeColors = {
    primary: 'bg-green-500',
    secondary: 'bg-orange-500',
    contingency: 'bg-blue-500',
  };

  const typeBgColors = {
    primary: 'bg-green-50 border-green-200',
    secondary: 'bg-orange-50 border-orange-200',
    contingency: 'bg-blue-50 border-blue-200',
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
    <div className="p-8 max-w-6xl mx-auto">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Mission Objectives</h1>
          <p className="text-gray-600 mt-1">
            Manage objectives for the Mission Planner feature
          </p>
        </div>
        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 transition flex items-center gap-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add Objective
        </button>
      </div>

      {/* Add Form */}
      {showAddForm && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Objective</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Objective Text
              </label>
              <input
                type="text"
                value={newObjective.text}
                onChange={(e) => setNewObjective({ ...newObjective, text: e.target.value })}
                placeholder="e.g., Complete my main work task"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Type
              </label>
              <select
                value={newObjective.objective_type}
                onChange={(e) => setNewObjective({ ...newObjective, objective_type: e.target.value as any })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              >
                <option value="primary">Primary</option>
                <option value="secondary">Secondary</option>
                <option value="contingency">Contingency</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Category
              </label>
              <select
                value={newObjective.category}
                onChange={(e) => setNewObjective({ ...newObjective, category: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              >
                <option value="">Select category...</option>
                {categories.map((cat) => (
                  <option key={cat.id} value={cat.name}>{cat.name}</option>
                ))}
              </select>
            </div>
          </div>
          <div className="flex justify-end gap-3 mt-6">
            <button
              onClick={() => setShowAddForm(false)}
              className="px-4 py-2 text-gray-600 hover:text-gray-800"
            >
              Cancel
            </button>
            <button
              onClick={addObjective}
              disabled={!newObjective.text.trim() || !newObjective.category}
              className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Add Objective
            </button>
          </div>
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-900">{objectives.length}</div>
          <div className="text-sm text-gray-500">Total Objectives</div>
        </div>
        <div className="bg-green-50 rounded-xl p-4 border border-green-200">
          <div className="text-2xl font-bold text-green-700">
            {objectives.filter(o => o.objective_type === 'primary').length}
          </div>
          <div className="text-sm text-green-600">Primary</div>
        </div>
        <div className="bg-orange-50 rounded-xl p-4 border border-orange-200">
          <div className="text-2xl font-bold text-orange-700">
            {objectives.filter(o => o.objective_type === 'secondary').length}
          </div>
          <div className="text-sm text-orange-600">Secondary</div>
        </div>
        <div className="bg-blue-50 rounded-xl p-4 border border-blue-200">
          <div className="text-2xl font-bold text-blue-700">
            {objectives.filter(o => o.objective_type === 'contingency').length}
          </div>
          <div className="text-sm text-blue-600">Contingency</div>
        </div>
      </div>

      {/* Filter tabs */}
      <div className="flex gap-2 mb-6">
        {(['all', 'primary', 'secondary', 'contingency'] as const).map((type) => (
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

      {/* Objectives list */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                Type
              </th>
              <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                Objective
              </th>
              <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                Category
              </th>
              <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-6 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {filteredObjectives.map((objective) => (
              <tr key={objective.id} className={`hover:bg-gray-50 ${!objective.is_active ? 'opacity-50' : ''}`}>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium text-white ${typeColors[objective.objective_type]}`}>
                    {objective.objective_type}
                  </span>
                </td>
                <td className="px-6 py-4">
                  {editingId === objective.id ? (
                    <input
                      type="text"
                      defaultValue={objective.text}
                      onBlur={(e) => updateObjective(objective.id, { text: e.target.value })}
                      onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                          updateObjective(objective.id, { text: (e.target as HTMLInputElement).value });
                        }
                        if (e.key === 'Escape') setEditingId(null);
                      }}
                      className="w-full px-2 py-1 border border-gray-300 rounded focus:ring-2 focus:ring-cyan-500"
                      autoFocus
                    />
                  ) : (
                    <span className="text-gray-900">{objective.text}</span>
                  )}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className="text-gray-600">{objective.category}</span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <button
                    onClick={() => toggleActive(objective.id, objective.is_active)}
                    className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      objective.is_active
                        ? 'bg-green-100 text-green-800'
                        : 'bg-gray-100 text-gray-600'
                    }`}
                  >
                    {objective.is_active ? 'Active' : 'Inactive'}
                  </button>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <button
                    onClick={() => setEditingId(objective.id)}
                    className="text-cyan-600 hover:text-cyan-800 mr-4"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => deleteObjective(objective.id)}
                    className="text-red-600 hover:text-red-800"
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        
        {filteredObjectives.length === 0 && (
          <div className="text-center py-12 text-gray-500">
            No objectives found
          </div>
        )}
      </div>

      {/* Categories section */}
      <div className="mt-12">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Categories</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {categories.map((cat) => (
            <div
              key={cat.id}
              className="bg-white rounded-xl p-4 border border-gray-200 flex items-center gap-3"
            >
              <div
                className="w-4 h-4 rounded-full"
                style={{ backgroundColor: cat.color }}
              />
              <span className="font-medium text-gray-700">{cat.name}</span>
              <span className="ml-auto text-sm text-gray-400">
                {objectives.filter(o => o.category === cat.name).length}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
