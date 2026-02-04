'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface ResourceCategory {
  id: string;
  slug: string;
  title: string;
  subtitle: string;
  icon: string;
  accent_color: string;
  target_audience: string;
  sort_order: number;
  is_active: boolean;
}

interface ResourceSection {
  id: string;
  category_id: string;
  title: string;
  icon: string;
  sort_order: number;
}

interface Resource {
  id: string;
  section_id: string;
  title: string;
  subtitle: string;
  description: string;
  icon: string;
  details: string[];
  external_url: string;
  sort_order: number;
  is_active: boolean;
}

export default function ResourcesContentPage() {
  const [categories, setCategories] = useState<ResourceCategory[]>([]);
  const [sections, setSections] = useState<ResourceSection[]>([]);
  const [resources, setResources] = useState<Resource[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [showAddCategory, setShowAddCategory] = useState(false);
  const [newCategory, setNewCategory] = useState({ slug: '', title: '', subtitle: '', target_audience: 'all' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [catRes, secRes, resRes] = await Promise.all([
      supabaseAdmin.from('resource_categories').select('*').order('sort_order'),
      supabaseAdmin.from('resource_sections').select('*').order('sort_order'),
      supabaseAdmin.from('resources').select('*').order('sort_order'),
    ]);

    if (catRes.data) setCategories(catRes.data);
    if (secRes.data) setSections(secRes.data);
    if (resRes.data) setResources(resRes.data);
    setLoading(false);
  }

  async function addCategory() {
    if (!newCategory.title.trim()) return;
    const maxOrder = categories.reduce((max, c) => Math.max(max, c.sort_order), 0);
    
    await supabaseAdmin.from('resource_categories').insert({
      ...newCategory,
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewCategory({ slug: '', title: '', subtitle: '', target_audience: 'all' });
    setShowAddCategory(false);
  }

  async function deleteCategory(id: string) {
    if (!confirm('Delete this category and all its sections/resources?')) return;
    await supabaseAdmin.from('resource_categories').delete().eq('id', id);
    fetchData();
  }

  async function toggleActive(id: string, current: boolean) {
    await supabaseAdmin.from('resource_categories').update({ is_active: !current }).eq('id', id);
    fetchData();
  }

  if (loading) {
    return <div className="p-8"><div className="animate-pulse h-64 bg-gray-200 rounded"></div></div>;
  }

  const selectedCategoryData = selectedCategory ? categories.find(c => c.id === selectedCategory) : null;
  const categorySections = sections.filter(s => s.category_id === selectedCategory);

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
          <h1 className="text-3xl font-bold text-gray-900">Resources</h1>
          <p className="text-gray-600 mt-1">Resource directories and links</p>
        </div>
        <button onClick={() => setShowAddCategory(true)} className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700">
          + Add Category
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-violet-50 rounded-xl p-4 border border-violet-200">
          <div className="text-2xl font-bold text-violet-700">{categories.length}</div>
          <div className="text-sm text-violet-600">Categories</div>
        </div>
        <div className="bg-gray-50 rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-purple-700">{sections.length}</div>
          <div className="text-sm text-purple-600">Sections</div>
        </div>
        <div className="bg-gray-50 rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-pink-700">{resources.length}</div>
          <div className="text-sm text-pink-600">Resources</div>
        </div>
      </div>

      {/* Add Category Form */}
      {showAddCategory && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Resource Category</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input type="text" value={newCategory.slug} onChange={(e) => setNewCategory({ ...newCategory, slug: e.target.value })} placeholder="Slug" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newCategory.title} onChange={(e) => setNewCategory({ ...newCategory, title: e.target.value })} placeholder="Title" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newCategory.subtitle} onChange={(e) => setNewCategory({ ...newCategory, subtitle: e.target.value })} placeholder="Subtitle" className="px-4 py-2 border rounded-lg" />
            <select value={newCategory.target_audience} onChange={(e) => setNewCategory({ ...newCategory, target_audience: e.target.value })} className="px-4 py-2 border rounded-lg">
              <option value="all">All</option>
              <option value="youth">Youth</option>
              <option value="military">Military</option>
              <option value="veteran">Veteran</option>
            </select>
          </div>
          <div className="flex justify-end gap-3 mt-4">
            <button onClick={() => setShowAddCategory(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={addCategory} className="px-4 py-2 bg-cyan-600 rounded-lg">Add Category</button>
          </div>
        </div>
      )}

      {/* Categories Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        {categories.map((cat) => (
          <div
            key={cat.id}
            onClick={() => setSelectedCategory(cat.id === selectedCategory ? null : cat.id)}
            className={`bg-white rounded-xl shadow-sm border-2 p-5 cursor-pointer transition ${
              selectedCategory === cat.id ? 'border-violet-500 ring-2 ring-violet-200' : 'border-gray-200 hover:border-gray-300'
            } ${!cat.is_active ? 'opacity-50' : ''}`}
          >
            <div className="flex items-start justify-between">
              <div>
                <h3 className="font-semibold text-gray-900">{cat.title}</h3>
                <p className="text-sm text-gray-500 mt-1">{cat.subtitle}</p>
                <div className="flex gap-2 mt-2">
                  <span className="text-xs bg-gray-100 px-2 py-1 rounded">{cat.slug}</span>
                  <span className="text-xs bg-violet-100 text-violet-700 px-2 py-1 rounded">{cat.target_audience}</span>
                </div>
              </div>
              <div className="flex gap-1">
                <button onClick={(e) => { e.stopPropagation(); toggleActive(cat.id, cat.is_active); }} className={`text-xs px-2 py-1 rounded ${cat.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100'}`}>
                  {cat.is_active ? 'Active' : 'Inactive'}
                </button>
                <button onClick={(e) => { e.stopPropagation(); deleteCategory(cat.id); }} className="text-xs px-2 py-1 text-red-600">Delete</button>
              </div>
            </div>
            <div className="mt-3 pt-3 border-t text-sm text-gray-500">
              {sections.filter(s => s.category_id === cat.id).length} sections • {
                resources.filter(r => sections.filter(s => s.category_id === cat.id).map(s => s.id).includes(r.section_id)).length
              } resources
            </div>
          </div>
        ))}
      </div>

      {/* Selected Category Details */}
      {selectedCategoryData && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 className="text-xl font-bold mb-4">{selectedCategoryData.title} - Resources</h2>
          
          {categorySections.length === 0 ? (
            <p className="text-gray-500">No sections yet. Add sections via Supabase.</p>
          ) : (
            <div className="space-y-4">
              {categorySections.map((section) => (
                <div key={section.id} className="bg-gray-50 rounded-lg p-4">
                  <h3 className="font-semibold text-gray-900 mb-2">{section.title}</h3>
                  <div className="space-y-2">
                    {resources.filter(r => r.section_id === section.id).map((resource) => (
                      <div key={resource.id} className="bg-white rounded p-3 border">
                        <div className="font-medium">{resource.title}</div>
                        <div className="text-sm text-gray-500">{resource.subtitle}</div>
                        {resource.external_url && (
                          <a href={resource.external_url} target="_blank" rel="noopener noreferrer" className="text-xs text-cyan-600 hover:underline">
                            {resource.external_url}
                          </a>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
