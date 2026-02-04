'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface Screen {
  id: string;
  slug: string;
  title: string;
  subtitle: string;
  icon: string;
  sort_order: number;
  is_active: boolean;
}

interface Section {
  id: string;
  screen_id: string;
  title: string;
  icon: string;
  sort_order: number;
  is_active: boolean;
}

interface Item {
  id: string;
  section_id: string;
  title: string;
  subtitle: string;
  icon: string;
  action_type: string;
  action_data: string;
  sort_order: number;
  is_active: boolean;
}

const ACTION_TYPES = [
  { value: 'tip_cards', label: 'Tip Cards' },
  { value: 'checklist', label: 'Checklist' },
  { value: 'resources', label: 'Resources' },
  { value: 'breathing', label: 'Breathing Exercise' },
  { value: 'quiz', label: 'Quiz' },
  { value: 'skills_translator', label: 'Skills Translator' },
  { value: 'contact_help', label: 'Contact/Help' },
  { value: 'goals', label: 'Goals' },
  { value: 'daily_brief', label: 'Daily Brief' },
  { value: 'mission_planner', label: 'Mission Planner' },
  { value: 'after_action_review', label: 'After Action Review' },
  { value: 'interest_explorer', label: 'Interest Explorer' },
  { value: 'confidence_builder', label: 'Confidence Builder' },
  { value: 'study_smarter', label: 'Study Smarter' },
  { value: 'career_sampler', label: 'Career Sampler' },
  { value: 'big_feelings', label: 'Big Feelings Toolkit' },
  { value: 'scenarios', label: 'Scenarios Library' },
  { value: 'protocols', label: 'Protocols Library' },
  { value: 'external_link', label: 'External Link' },
];

export default function UserScreensPage() {
  const [screens, setScreens] = useState<Screen[]>([]);
  const [sections, setSections] = useState<Section[]>([]);
  const [items, setItems] = useState<Item[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedScreen, setSelectedScreen] = useState<string | null>(null);
  const [selectedSection, setSelectedSection] = useState<string | null>(null);
  const [showAddSection, setShowAddSection] = useState(false);
  const [showAddItem, setShowAddItem] = useState(false);
  const [editingItem, setEditingItem] = useState<Item | null>(null);
  
  const [newSection, setNewSection] = useState({ title: '', icon: 'folder' });
  const [newItem, setNewItem] = useState({ title: '', subtitle: '', action_type: 'tip_cards', action_data: '' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [screenRes, sectionRes, itemRes] = await Promise.all([
      supabaseAdmin.from('user_type_screens').select('*').order('sort_order'),
      supabaseAdmin.from('user_type_sections').select('*').order('sort_order'),
      supabaseAdmin.from('user_type_items').select('*').order('sort_order'),
    ]);

    if (screenRes.data) {
      setScreens(screenRes.data);
      if (!selectedScreen && screenRes.data.length > 0) {
        setSelectedScreen(screenRes.data[0].id);
      }
    }
    if (sectionRes.data) setSections(sectionRes.data);
    if (itemRes.data) setItems(itemRes.data);
    setLoading(false);
  }

  const screenSections = sections.filter(s => s.screen_id === selectedScreen);
  const sectionItems = items.filter(i => i.section_id === selectedSection);

  async function addSection() {
    if (!newSection.title.trim() || !selectedScreen) return;
    const maxOrder = screenSections.reduce((max, s) => Math.max(max, s.sort_order), 0);
    
    await supabaseAdmin.from('user_type_sections').insert({
      screen_id: selectedScreen,
      title: newSection.title,
      icon: newSection.icon,
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewSection({ title: '', icon: 'folder' });
    setShowAddSection(false);
  }

  async function addItem() {
    if (!newItem.title.trim() || !selectedSection) return;
    const maxOrder = sectionItems.reduce((max, i) => Math.max(max, i.sort_order), 0);
    
    await supabaseAdmin.from('user_type_items').insert({
      section_id: selectedSection,
      title: newItem.title,
      subtitle: newItem.subtitle,
      action_type: newItem.action_type,
      action_data: newItem.action_data || null,
      sort_order: maxOrder + 1,
      is_active: true,
    });
    
    fetchData();
    setNewItem({ title: '', subtitle: '', action_type: 'tip_cards', action_data: '' });
    setShowAddItem(false);
  }

  async function updateItem(item: Item) {
    await supabaseAdmin.from('user_type_items').update({
      title: item.title,
      subtitle: item.subtitle,
      action_type: item.action_type,
      action_data: item.action_data,
    }).eq('id', item.id);
    
    fetchData();
    setEditingItem(null);
  }

  async function deleteSection(id: string) {
    if (!confirm('Delete this section and all its items?')) return;
    await supabaseAdmin.from('user_type_sections').delete().eq('id', id);
    if (selectedSection === id) setSelectedSection(null);
    fetchData();
  }

  async function deleteItem(id: string) {
    if (!confirm('Delete this item?')) return;
    await supabaseAdmin.from('user_type_items').delete().eq('id', id);
    fetchData();
  }

  async function toggleActive(table: string, id: string, current: boolean) {
    await supabaseAdmin.from(table).update({ is_active: !current }).eq('id', id);
    fetchData();
  }

  if (loading) {
    return <div className="p-8"><div className="animate-pulse h-64 bg-gray-200 rounded"></div></div>;
  }

  return (
    <div className="p-8 max-w-7xl mx-auto">
      <div className="mb-6">
        <Link href="/admin/content-manager" className="text-cyan-600 hover:text-cyan-800 text-sm flex items-center gap-1">
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          Back to Content Manager
        </Link>
      </div>

      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">User Type Screens</h1>
        <p className="text-gray-600 mt-1">Manage Military, Veteran, and Youth screen content</p>
      </div>

      {/* Screen Tabs */}
      <div className="flex gap-2 mb-6">
        {screens.map((screen) => (
          <button
            key={screen.id}
            onClick={() => { setSelectedScreen(screen.id); setSelectedSection(null); }}
            className={`px-6 py-3 rounded-lg font-medium transition ${
              selectedScreen === screen.id
                ? 'bg-cyan-600 text-white'
                : 'bg-white text-gray-600 hover:bg-gray-100 border border-gray-200'
            }`}
          >
            {screen.title}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Sections Column */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex justify-between items-center mb-4">
            <h2 className="font-semibold text-gray-900">Sections</h2>
            <button
              onClick={() => setShowAddSection(true)}
              className="text-sm px-3 py-1 bg-cyan-600 text-white rounded hover:bg-cyan-700"
            >
              + Add
            </button>
          </div>

          {showAddSection && (
            <div className="mb-4 p-3 bg-gray-50 rounded-lg">
              <input
                type="text"
                value={newSection.title}
                onChange={(e) => setNewSection({ ...newSection, title: e.target.value })}
                placeholder="Section title"
                className="w-full px-3 py-2 border rounded mb-2"
              />
              <input
                type="text"
                value={newSection.icon}
                onChange={(e) => setNewSection({ ...newSection, icon: e.target.value })}
                placeholder="Icon name"
                className="w-full px-3 py-2 border rounded mb-2"
              />
              <div className="flex gap-2">
                <button onClick={() => setShowAddSection(false)} className="text-gray-500 text-sm">Cancel</button>
                <button onClick={addSection} className="text-cyan-600 text-sm font-medium">Save</button>
              </div>
            </div>
          )}

          <div className="space-y-2">
            {screenSections.map((section) => (
              <div
                key={section.id}
                onClick={() => setSelectedSection(section.id)}
                className={`p-3 rounded-lg cursor-pointer transition ${
                  selectedSection === section.id
                    ? 'bg-cyan-50 border border-cyan-200'
                    : 'bg-gray-50 hover:bg-gray-100'
                } ${!section.is_active ? 'opacity-50' : ''}`}
              >
                <div className="flex justify-between items-start">
                  <div>
                    <div className="font-medium text-gray-900">{section.title}</div>
                    <div className="text-xs text-gray-500">{items.filter(i => i.section_id === section.id).length} items</div>
                  </div>
                  <div className="flex gap-1">
                    <button
                      onClick={(e) => { e.stopPropagation(); toggleActive('user_type_sections', section.id, section.is_active); }}
                      className={`text-xs ${section.is_active ? 'text-green-600' : 'text-gray-400'}`}
                    >
                      {section.is_active ? '✓' : '○'}
                    </button>
                    <button
                      onClick={(e) => { e.stopPropagation(); deleteSection(section.id); }}
                      className="text-red-500 text-xs"
                    >
                      ×
                    </button>
                  </div>
                </div>
              </div>
            ))}
            {screenSections.length === 0 && (
              <div className="text-gray-400 text-center py-8">No sections yet</div>
            )}
          </div>
        </div>

        {/* Items Column */}
        <div className="lg:col-span-2 bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex justify-between items-center mb-4">
            <h2 className="font-semibold text-gray-900">
              Items {selectedSection && `(${sections.find(s => s.id === selectedSection)?.title})`}
            </h2>
            {selectedSection && (
              <button
                onClick={() => setShowAddItem(true)}
                className="text-sm px-3 py-1 bg-cyan-600 text-white rounded hover:bg-cyan-700"
              >
                + Add Item
              </button>
            )}
          </div>

          {!selectedSection ? (
            <div className="text-gray-400 text-center py-12">Select a section to view items</div>
          ) : (
            <>
              {showAddItem && (
                <div className="mb-4 p-4 bg-gray-50 rounded-lg">
                  <div className="grid grid-cols-2 gap-3 mb-3">
                    <input
                      type="text"
                      value={newItem.title}
                      onChange={(e) => setNewItem({ ...newItem, title: e.target.value })}
                      placeholder="Item title"
                      className="px-3 py-2 border rounded"
                    />
                    <input
                      type="text"
                      value={newItem.subtitle}
                      onChange={(e) => setNewItem({ ...newItem, subtitle: e.target.value })}
                      placeholder="Subtitle"
                      className="px-3 py-2 border rounded"
                    />
                    <select
                      value={newItem.action_type}
                      onChange={(e) => setNewItem({ ...newItem, action_type: e.target.value })}
                      className="px-3 py-2 border rounded"
                    >
                      {ACTION_TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
                    </select>
                    <input
                      type="text"
                      value={newItem.action_data}
                      onChange={(e) => setNewItem({ ...newItem, action_data: e.target.value })}
                      placeholder="Action data (slug/id)"
                      className="px-3 py-2 border rounded"
                    />
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => setShowAddItem(false)} className="text-gray-500 text-sm">Cancel</button>
                    <button onClick={addItem} className="text-cyan-600 text-sm font-medium">Save</button>
                  </div>
                </div>
              )}

              <div className="space-y-2">
                {sectionItems.map((item) => (
                  <div
                    key={item.id}
                    className={`p-4 rounded-lg border ${!item.is_active ? 'opacity-50 bg-gray-50' : 'bg-white'}`}
                  >
                    {editingItem?.id === item.id ? (
                      <div className="grid grid-cols-2 gap-3">
                        <input
                          type="text"
                          value={editingItem.title}
                          onChange={(e) => setEditingItem({ ...editingItem, title: e.target.value })}
                          className="px-3 py-2 border rounded"
                        />
                        <input
                          type="text"
                          value={editingItem.subtitle}
                          onChange={(e) => setEditingItem({ ...editingItem, subtitle: e.target.value })}
                          className="px-3 py-2 border rounded"
                        />
                        <select
                          value={editingItem.action_type}
                          onChange={(e) => setEditingItem({ ...editingItem, action_type: e.target.value })}
                          className="px-3 py-2 border rounded"
                        >
                          {ACTION_TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
                        </select>
                        <input
                          type="text"
                          value={editingItem.action_data || ''}
                          onChange={(e) => setEditingItem({ ...editingItem, action_data: e.target.value })}
                          className="px-3 py-2 border rounded"
                        />
                        <div className="col-span-2 flex gap-2">
                          <button onClick={() => setEditingItem(null)} className="text-gray-500 text-sm">Cancel</button>
                          <button onClick={() => updateItem(editingItem)} className="text-cyan-600 text-sm font-medium">Save</button>
                        </div>
                      </div>
                    ) : (
                      <div className="flex justify-between items-start">
                        <div>
                          <div className="font-medium text-gray-900">{item.title}</div>
                          <div className="text-sm text-gray-500">{item.subtitle}</div>
                          <div className="flex gap-2 mt-2">
                            <span className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded">
                              {ACTION_TYPES.find(t => t.value === item.action_type)?.label || item.action_type}
                            </span>
                            {item.action_data && (
                              <span className="text-xs bg-gray-100 text-gray-500 px-2 py-1 rounded">
                                {item.action_data}
                              </span>
                            )}
                          </div>
                        </div>
                        <div className="flex gap-2">
                          <button
                            onClick={() => setEditingItem(item)}
                            className="text-cyan-600 text-sm"
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => toggleActive('user_type_items', item.id, item.is_active)}
                            className={`text-sm ${item.is_active ? 'text-green-600' : 'text-gray-400'}`}
                          >
                            {item.is_active ? 'Active' : 'Inactive'}
                          </button>
                          <button
                            onClick={() => deleteItem(item.id)}
                            className="text-red-500 text-sm"
                          >
                            Delete
                          </button>
                        </div>
                      </div>
                    )}
                  </div>
                ))}
                {sectionItems.length === 0 && (
                  <div className="text-gray-400 text-center py-8">No items in this section</div>
                )}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
