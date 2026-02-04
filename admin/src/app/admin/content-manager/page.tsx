'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
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
    { table: 'user_type_items', label: 'User Type Screens', icon: '👥', href: '/admin/content-manager/user-screens', color: 'bg-white border-gray-200' },
    { table: 'mission_objectives', label: 'Mission Objectives', icon: '🎯', href: '/admin/objectives', color: 'bg-white border-gray-200' },
    { table: 'mood_reasons', label: 'Mood Reasons', icon: '😊', href: '/admin/content-manager/mood', color: 'bg-white border-gray-200' },
    { table: 'daily_brief_objectives', label: 'Daily Brief Options', icon: '📋', href: '/admin/content-manager/daily-brief', color: 'bg-white border-gray-200' },
    { table: 'aar_went_well_options', label: 'After Action Review', icon: '📝', href: '/admin/content-manager/aar', color: 'bg-white border-gray-200' },
    { table: 'military_roles', label: 'Skills Translator', icon: '🎖️', href: '/admin/content-manager/skills', color: 'bg-white border-gray-200' },
    { table: 'feelings', label: 'Big Feelings Toolkit', icon: '💭', href: '/admin/content-manager/feelings', color: 'bg-white border-gray-200' },
    { table: 'quizzes', label: 'Quizzes', icon: '❓', href: '/admin/content-manager/quizzes', color: 'bg-white border-gray-200' },
    { table: 'career_paths', label: 'Career Paths', icon: '🚀', href: '/admin/content-manager/careers', color: 'bg-white border-gray-200' },
    { table: 'tip_categories', label: 'Tip Cards', icon: '💡', href: '/admin/content-manager/tips', color: 'bg-white border-gray-200' },
    { table: 'checklist_templates', label: 'Checklists', icon: '✅', href: '/admin/content-manager/checklists', color: 'bg-white border-gray-200' },
    { table: 'resource_categories', label: 'Resources', icon: '📚', href: '/admin/content-manager/resources', color: 'bg-white border-gray-200' },
    { table: 'learning_styles', label: 'Learning & Study', icon: '📖', href: '/admin/content-manager/learning', color: 'bg-white border-gray-200' },
    { table: 'affirmations', label: 'Affirmations', icon: '✨', href: '/admin/content-manager/affirmations', color: 'bg-white border-gray-200' },
    { table: 'interest_categories', label: 'Interest Explorer', icon: '🎨', href: '/admin/content-manager/interests', color: 'bg-white border-gray-200' },
  ];

  useEffect(() => {
    fetchStats();
  }, []);

  async function fetchStats() {
    setLoading(true);
    
    const statsPromises = contentTypes.map(async (type) => {
      const { count } = await supabaseAdmin
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
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-900">{totalItems}</div>
          <div className="text-gray-500 text-sm">Total Items</div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-900">{stats.length}</div>
          <div className="text-gray-500 text-sm">Content Types</div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-900">
            {stats.filter(s => s.label.includes('Skills') || s.label.includes('Mission') || s.label.includes('Action')).reduce((sum, s) => sum + s.count, 0)}
          </div>
          <div className="text-gray-500 text-sm">Military/Veteran</div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-900">
            {stats.filter(s => s.label.includes('Feelings') || s.label.includes('Learning') || s.label.includes('Interest') || s.label.includes('Career')).reduce((sum, s) => sum + s.count, 0)}
          </div>
          <div className="text-gray-500 text-sm">Youth</div>
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

    </div>
  );
}
