'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';

interface ContentStats {
  table: string;
  label: string;
  count: number;
  icon: string;
  href: string;
  color: string;
}

export default function ContentManagerPage() {
  const [stats, setStats] = useState<ContentStats[]>([]);
  const [loading, setLoading] = useState(true);

  const contentTypes: Omit<ContentStats, 'count'>[] = [
    { table: 'mission_objectives', label: 'Mission Objectives', icon: '🎯', href: '/admin/objectives', color: 'bg-green-50 border-green-200' },
    { table: 'mood_reasons', label: 'Mood Reasons', icon: '😊', href: '/admin/content-manager/mood', color: 'bg-blue-50 border-blue-200' },
    { table: 'daily_brief_objectives', label: 'Daily Brief Options', icon: '📋', href: '/admin/content-manager/daily-brief', color: 'bg-yellow-50 border-yellow-200' },
    { table: 'aar_went_well_options', label: 'After Action Review', icon: '📝', href: '/admin/content-manager/aar', color: 'bg-purple-50 border-purple-200' },
    { table: 'military_roles', label: 'Skills Translator', icon: '🎖️', href: '/admin/content-manager/skills', color: 'bg-red-50 border-red-200' },
    { table: 'feelings', label: 'Big Feelings Toolkit', icon: '💭', href: '/admin/content-manager/feelings', color: 'bg-pink-50 border-pink-200' },
    { table: 'quizzes', label: 'Quizzes', icon: '❓', href: '/admin/content-manager/quizzes', color: 'bg-indigo-50 border-indigo-200' },
    { table: 'career_paths', label: 'Career Paths', icon: '🚀', href: '/admin/content-manager/careers', color: 'bg-orange-50 border-orange-200' },
    { table: 'tip_categories', label: 'Tip Cards', icon: '💡', href: '/admin/content-manager/tips', color: 'bg-cyan-50 border-cyan-200' },
    { table: 'checklist_templates', label: 'Checklists', icon: '✅', href: '/admin/content-manager/checklists', color: 'bg-emerald-50 border-emerald-200' },
    { table: 'resource_categories', label: 'Resources', icon: '📚', href: '/admin/content-manager/resources', color: 'bg-violet-50 border-violet-200' },
    { table: 'learning_styles', label: 'Learning & Study', icon: '📖', href: '/admin/content-manager/learning', color: 'bg-amber-50 border-amber-200' },
    { table: 'affirmations', label: 'Affirmations', icon: '✨', href: '/admin/content-manager/affirmations', color: 'bg-rose-50 border-rose-200' },
    { table: 'interest_categories', label: 'Interest Explorer', icon: '🎨', href: '/admin/content-manager/interests', color: 'bg-teal-50 border-teal-200' },
  ];

  useEffect(() => {
    fetchStats();
  }, []);

  async function fetchStats() {
    setLoading(true);
    
    const statsPromises = contentTypes.map(async (type) => {
      const { count } = await supabase
        .from(type.table)
        .select('*', { count: 'exact', head: true });
      
      return {
        ...type,
        count: count || 0,
      };
    });

    const results = await Promise.all(statsPromises);
    setStats(results);
    setLoading(false);
  }

  const totalItems = stats.reduce((sum, s) => sum + s.count, 0);

  if (loading) {
    return (
      <div className="p-8">
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {[...Array(12)].map((_, i) => (
              <div key={i} className="h-24 bg-gray-200 rounded-xl"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Content Manager</h1>
        <p className="text-gray-600 mt-1">
          Manage all app content from one place • {totalItems} total items
        </p>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <div className="bg-gradient-to-br from-cyan-500 to-cyan-600 rounded-xl p-4 text-white">
          <div className="text-3xl font-bold">{totalItems}</div>
          <div className="text-cyan-100 text-sm">Total Content Items</div>
        </div>
        <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl p-4 text-white">
          <div className="text-3xl font-bold">{stats.length}</div>
          <div className="text-green-100 text-sm">Content Types</div>
        </div>
        <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl p-4 text-white">
          <div className="text-3xl font-bold">
            {stats.filter(s => s.label.includes('Military') || s.label.includes('Veteran')).reduce((sum, s) => sum + s.count, 0)}
          </div>
          <div className="text-purple-100 text-sm">Military/Veteran Items</div>
        </div>
        <div className="bg-gradient-to-br from-pink-500 to-pink-600 rounded-xl p-4 text-white">
          <div className="text-3xl font-bold">
            {stats.filter(s => s.label.includes('Youth') || s.label.includes('Learning') || s.label.includes('Interest')).reduce((sum, s) => sum + s.count, 0)}
          </div>
          <div className="text-pink-100 text-sm">Youth Items</div>
        </div>
      </div>

      {/* Content Type Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {stats.map((stat) => (
          <Link
            key={stat.table}
            href={stat.href}
            className={`${stat.color} border rounded-xl p-5 hover:shadow-md transition group`}
          >
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-3">
                <span className="text-2xl">{stat.icon}</span>
                <div>
                  <h3 className="font-semibold text-gray-900 group-hover:text-cyan-700 transition">
                    {stat.label}
                  </h3>
                  <p className="text-sm text-gray-500">{stat.count} items</p>
                </div>
              </div>
              <svg 
                className="w-5 h-5 text-gray-400 group-hover:text-cyan-600 transition transform group-hover:translate-x-1" 
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </Link>
        ))}
      </div>

      {/* Setup Instructions */}
      <div className="mt-12 bg-amber-50 border border-amber-200 rounded-xl p-6">
        <h2 className="text-lg font-semibold text-amber-800 mb-2">📦 Database Setup Required</h2>
        <p className="text-amber-700 mb-4">
          To enable content management, run the following SQL files in your Supabase dashboard:
        </p>
        <div className="bg-white rounded-lg p-4 font-mono text-sm space-y-2">
          <div className="text-gray-600">1. <span className="text-cyan-700">mission-objectives-schema.sql</span> - Mission Planner objectives</div>
          <div className="text-gray-600">2. <span className="text-cyan-700">app-content-schema.sql</span> - All other app content</div>
        </div>
        <p className="text-amber-600 text-sm mt-4">
          These files are in the <code className="bg-white px-2 py-1 rounded">supabase/</code> folder.
        </p>
      </div>

      {/* Content Categories Breakdown */}
      <div className="mt-8">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Content by Category</h2>
        
        <div className="space-y-6">
          {/* User Experience */}
          <div className="bg-white rounded-xl border border-gray-200 p-5">
            <h3 className="font-semibold text-gray-700 mb-3 flex items-center gap-2">
              <span className="w-3 h-3 bg-cyan-500 rounded-full"></span>
              Core User Experience
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              {stats.filter(s => ['Mission Objectives', 'Mood Reasons', 'Daily Brief Options', 'After Action Review'].includes(s.label)).map(s => (
                <div key={s.table} className="text-sm">
                  <span className="text-gray-900 font-medium">{s.label}</span>
                  <span className="text-gray-500 ml-2">({s.count})</span>
                </div>
              ))}
            </div>
          </div>

          {/* Military/Veteran */}
          <div className="bg-white rounded-xl border border-gray-200 p-5">
            <h3 className="font-semibold text-gray-700 mb-3 flex items-center gap-2">
              <span className="w-3 h-3 bg-green-500 rounded-full"></span>
              Military & Veteran
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              {stats.filter(s => ['Skills Translator'].includes(s.label)).map(s => (
                <div key={s.table} className="text-sm">
                  <span className="text-gray-900 font-medium">{s.label}</span>
                  <span className="text-gray-500 ml-2">({s.count})</span>
                </div>
              ))}
            </div>
          </div>

          {/* Youth */}
          <div className="bg-white rounded-xl border border-gray-200 p-5">
            <h3 className="font-semibold text-gray-700 mb-3 flex items-center gap-2">
              <span className="w-3 h-3 bg-pink-500 rounded-full"></span>
              Youth & Learning
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              {stats.filter(s => ['Big Feelings Toolkit', 'Quizzes', 'Career Paths', 'Learning & Study', 'Interest Explorer'].includes(s.label)).map(s => (
                <div key={s.table} className="text-sm">
                  <span className="text-gray-900 font-medium">{s.label}</span>
                  <span className="text-gray-500 ml-2">({s.count})</span>
                </div>
              ))}
            </div>
          </div>

          {/* General Content */}
          <div className="bg-white rounded-xl border border-gray-200 p-5">
            <h3 className="font-semibold text-gray-700 mb-3 flex items-center gap-2">
              <span className="w-3 h-3 bg-purple-500 rounded-full"></span>
              General Content
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              {stats.filter(s => ['Tip Cards', 'Checklists', 'Resources', 'Affirmations'].includes(s.label)).map(s => (
                <div key={s.table} className="text-sm">
                  <span className="text-gray-900 font-medium">{s.label}</span>
                  <span className="text-gray-500 ml-2">({s.count})</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
