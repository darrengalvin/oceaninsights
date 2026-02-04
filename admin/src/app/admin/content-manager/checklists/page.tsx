'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface ChecklistTemplate {
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

interface ChecklistSection {
  id: string;
  template_id: string;
  title: string;
  icon: string;
  color: string;
  sort_order: number;
}

interface ChecklistItem {
  id: string;
  section_id: string;
  title: string;
  subtitle: string;
  sort_order: number;
  is_active: boolean;
}

export default function ChecklistsContentPage() {
  const [templates, setTemplates] = useState<ChecklistTemplate[]>([]);
  const [sections, setSections] = useState<ChecklistSection[]>([]);
  const [items, setItems] = useState<ChecklistItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedTemplate, setSelectedTemplate] = useState<string | null>(null);
  const [showAddTemplate, setShowAddTemplate] = useState(false);
  const [newTemplate, setNewTemplate] = useState({ slug: '', title: '', subtitle: '', target_audience: 'all' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [tempRes, secRes, itemRes] = await Promise.all([
      supabaseAdmin.from('checklist_templates').select('*').order('sort_order'),
      supabaseAdmin.from('checklist_sections').select('*').order('sort_order'),
      supabaseAdmin.from('checklist_items').select('*').order('sort_order'),
    ]);

    if (tempRes.data) setTemplates(tempRes.data);
    if (secRes.data) setSections(secRes.data);
    if (itemRes.data) setItems(itemRes.data);
    setLoading(false);
  }

  async function addTemplate() {
    if (!newTemplate.title.trim()) return;
    const maxOrder = templates.reduce((max, t) => Math.max(max, t.sort_order), 0);
    
    await supabaseAdmin.from('checklist_templates').insert({
      ...newTemplate,
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewTemplate({ slug: '', title: '', subtitle: '', target_audience: 'all' });
    setShowAddTemplate(false);
  }

  async function deleteTemplate(id: string) {
    if (!confirm('Delete this checklist template and all its sections/items?')) return;
    await supabaseAdmin.from('checklist_templates').delete().eq('id', id);
    fetchData();
  }

  async function toggleActive(id: string, current: boolean) {
    await supabaseAdmin.from('checklist_templates').update({ is_active: !current }).eq('id', id);
    fetchData();
  }

  if (loading) {
    return <div className="p-8"><div className="animate-pulse h-64 bg-gray-200 rounded"></div></div>;
  }

  const selectedTemplateData = selectedTemplate ? templates.find(t => t.id === selectedTemplate) : null;
  const templateSections = sections.filter(s => s.template_id === selectedTemplate);

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
          <h1 className="text-3xl font-bold text-gray-900">Checklists</h1>
          <p className="text-gray-600 mt-1">Interactive checklist templates</p>
        </div>
        <button onClick={() => setShowAddTemplate(true)} className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700">
          + Add Checklist
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-emerald-50 rounded-xl p-4 border border-emerald-200">
          <div className="text-2xl font-bold text-emerald-700">{templates.length}</div>
          <div className="text-sm text-emerald-600">Templates</div>
        </div>
        <div className="bg-teal-50 rounded-xl p-4 border border-teal-200">
          <div className="text-2xl font-bold text-teal-700">{sections.length}</div>
          <div className="text-sm text-teal-600">Sections</div>
        </div>
        <div className="bg-cyan-50 rounded-xl p-4 border border-cyan-200">
          <div className="text-2xl font-bold text-cyan-700">{items.length}</div>
          <div className="text-sm text-cyan-600">Items</div>
        </div>
      </div>

      {/* Add Template Form */}
      {showAddTemplate && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Checklist Template</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input type="text" value={newTemplate.slug} onChange={(e) => setNewTemplate({ ...newTemplate, slug: e.target.value })} placeholder="Slug (e.g., morning-routine)" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newTemplate.title} onChange={(e) => setNewTemplate({ ...newTemplate, title: e.target.value })} placeholder="Title" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newTemplate.subtitle} onChange={(e) => setNewTemplate({ ...newTemplate, subtitle: e.target.value })} placeholder="Subtitle" className="px-4 py-2 border rounded-lg" />
            <select value={newTemplate.target_audience} onChange={(e) => setNewTemplate({ ...newTemplate, target_audience: e.target.value })} className="px-4 py-2 border rounded-lg">
              <option value="all">All</option>
              <option value="youth">Youth</option>
              <option value="military">Military</option>
              <option value="veteran">Veteran</option>
            </select>
          </div>
          <div className="flex justify-end gap-3 mt-4">
            <button onClick={() => setShowAddTemplate(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={addTemplate} className="px-4 py-2 bg-cyan-600 rounded-lg">Add Template</button>
          </div>
        </div>
      )}

      {/* Templates Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        {templates.map((template) => (
          <div
            key={template.id}
            onClick={() => setSelectedTemplate(template.id === selectedTemplate ? null : template.id)}
            className={`bg-white rounded-xl shadow-sm border-2 p-5 cursor-pointer transition ${
              selectedTemplate === template.id ? 'border-emerald-500 ring-2 ring-emerald-200' : 'border-gray-200 hover:border-gray-300'
            } ${!template.is_active ? 'opacity-50' : ''}`}
          >
            <div className="flex items-start justify-between">
              <div>
                <h3 className="font-semibold text-gray-900">{template.title}</h3>
                <p className="text-sm text-gray-500 mt-1">{template.subtitle}</p>
                <div className="flex gap-2 mt-2">
                  <span className="text-xs bg-gray-100 px-2 py-1 rounded">{template.slug}</span>
                  <span className="text-xs bg-emerald-100 text-emerald-700 px-2 py-1 rounded">{template.target_audience}</span>
                </div>
              </div>
              <div className="flex gap-1">
                <button onClick={(e) => { e.stopPropagation(); toggleActive(template.id, template.is_active); }} className={`text-xs px-2 py-1 rounded ${template.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100'}`}>
                  {template.is_active ? 'Active' : 'Inactive'}
                </button>
                <button onClick={(e) => { e.stopPropagation(); deleteTemplate(template.id); }} className="text-xs px-2 py-1 text-red-600">Delete</button>
              </div>
            </div>
            <div className="mt-3 pt-3 border-t text-sm text-gray-500">
              {sections.filter(s => s.template_id === template.id).length} sections • {
                items.filter(i => sections.filter(s => s.template_id === template.id).map(s => s.id).includes(i.section_id)).length
              } items
            </div>
          </div>
        ))}
      </div>

      {/* Selected Template Details */}
      {selectedTemplateData && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 className="text-xl font-bold mb-4">{selectedTemplateData.title} - Sections</h2>
          
          {templateSections.length === 0 ? (
            <p className="text-gray-500">No sections yet. Add sections via Supabase.</p>
          ) : (
            <div className="space-y-4">
              {templateSections.map((section) => (
                <div key={section.id} className="bg-gray-50 rounded-lg p-4">
                  <h3 className="font-semibold text-gray-900 mb-2">{section.title}</h3>
                  <div className="space-y-1">
                    {items.filter(i => i.section_id === section.id).map((item) => (
                      <div key={item.id} className="flex items-center gap-2 text-sm">
                        <span className="w-4 h-4 rounded border border-gray-300"></span>
                        <span>{item.title}</span>
                        {item.subtitle && <span className="text-gray-400">- {item.subtitle}</span>}
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
