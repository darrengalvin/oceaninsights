'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface CareerPath {
  id: string;
  title: string;
  emoji: string;
  tagline: string;
  description: string;
  skills_needed: string[];
  salary_range: string;
  sort_order: number;
  is_active: boolean;
}

export default function CareersContentPage() {
  const [careers, setCareers] = useState<CareerPath[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddForm, setShowAddForm] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [newCareer, setNewCareer] = useState({
    title: '',
    emoji: '',
    tagline: '',
    description: '',
    skills_needed: '',
    salary_range: '',
  });

  useEffect(() => {
    fetchCareers();
  }, []);

  async function fetchCareers() {
    setLoading(true);
    const { data } = await supabase
      .from('career_paths')
      .select('*')
      .order('sort_order');

    if (data) setCareers(data);
    setLoading(false);
  }

  async function addCareer() {
    if (!newCareer.title.trim()) return;

    const maxOrder = careers.reduce((max, c) => Math.max(max, c.sort_order), 0);

    const { error } = await supabaseAdmin.from('career_paths').insert({
      title: newCareer.title,
      emoji: newCareer.emoji || '💼',
      tagline: newCareer.tagline,
      description: newCareer.description,
      skills_needed: newCareer.skills_needed.split(',').map(s => s.trim()).filter(Boolean),
      salary_range: newCareer.salary_range,
      sort_order: maxOrder + 1,
      is_active: true,
    });

    if (!error) {
      fetchCareers();
      setNewCareer({ title: '', emoji: '', tagline: '', description: '', skills_needed: '', salary_range: '' });
      setShowAddForm(false);
    }
  }

  async function deleteCareer(id: string) {
    if (!confirm('Delete this career path?')) return;
    await supabaseAdmin.from('career_paths').delete().eq('id', id);
    fetchCareers();
  }

  async function toggleActive(id: string, current: boolean) {
    await supabaseAdmin.from('career_paths').update({ is_active: !current }).eq('id', id);
    fetchCareers();
  }

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
          <h1 className="text-3xl font-bold text-gray-900">Career Paths</h1>
          <p className="text-gray-600 mt-1">Career options for the Career Sampler feature</p>
        </div>
        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700 transition flex items-center gap-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add Career
        </button>
      </div>

      {/* Stats */}
      <div className="bg-white rounded-xl p-6 mb-6 border border-gray-200">
        <div className="text-4xl font-bold text-gray-900">{careers.length}</div>
        <div className="text-gray-500">Career paths available</div>
        <div className="text-sm text-gray-400 mt-2">
          {careers.filter(c => c.is_active).length} active • {careers.filter(c => !c.is_active).length} inactive
        </div>
      </div>

      {/* Add Form */}
      {showAddForm && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Career Path</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
              <input
                type="text"
                value={newCareer.title}
                onChange={(e) => setNewCareer({ ...newCareer, title: e.target.value })}
                placeholder="e.g., Software Developer"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Emoji</label>
              <input
                type="text"
                value={newCareer.emoji}
                onChange={(e) => setNewCareer({ ...newCareer, emoji: e.target.value })}
                placeholder="💻"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Tagline</label>
              <input
                type="text"
                value={newCareer.tagline}
                onChange={(e) => setNewCareer({ ...newCareer, tagline: e.target.value })}
                placeholder="Build the future with code"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
              <textarea
                value={newCareer.description}
                onChange={(e) => setNewCareer({ ...newCareer, description: e.target.value })}
                placeholder="What this career involves..."
                rows={3}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Skills (comma separated)</label>
              <input
                type="text"
                value={newCareer.skills_needed}
                onChange={(e) => setNewCareer({ ...newCareer, skills_needed: e.target.value })}
                placeholder="Problem solving, Logic, Creativity"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Salary Range</label>
              <input
                type="text"
                value={newCareer.salary_range}
                onChange={(e) => setNewCareer({ ...newCareer, salary_range: e.target.value })}
                placeholder="$70K-$150K"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
              />
            </div>
          </div>
          <div className="flex justify-end gap-3 mt-6">
            <button onClick={() => setShowAddForm(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button
              onClick={addCareer}
              disabled={!newCareer.title.trim()}
              className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700 disabled:opacity-50"
            >
              Add Career
            </button>
          </div>
        </div>
      )}

      {/* Careers Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {careers.map((career) => (
          <div
            key={career.id}
            className={`bg-white rounded-xl shadow-sm border border-gray-200 p-5 ${!career.is_active ? 'opacity-50' : ''}`}
          >
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-center gap-3">
                <span className="text-3xl">{career.emoji}</span>
                <div>
                  <h3 className="font-semibold text-gray-900">{career.title}</h3>
                  <p className="text-sm text-gray-500">{career.tagline}</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => toggleActive(career.id, career.is_active)}
                  className={`text-xs px-2 py-1 rounded ${career.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}`}
                >
                  {career.is_active ? 'Active' : 'Inactive'}
                </button>
              </div>
            </div>
            
            <p className="text-sm text-gray-600 mb-3 line-clamp-2">{career.description}</p>
            
            <div className="flex flex-wrap gap-1 mb-3">
              {career.skills_needed?.map((skill, i) => (
                <span key={i} className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded">
                  {skill}
                </span>
              ))}
            </div>
            
            <div className="flex items-center justify-between pt-3 border-t border-gray-100">
              <span className="text-sm font-medium text-green-600">{career.salary_range}</span>
              <button
                onClick={() => deleteCareer(career.id)}
                className="text-red-600 hover:text-red-800 text-sm"
              >
                Delete
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
