'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

// ============================================================
// TYPES
// ============================================================

interface WizardStep {
  id: string;
  title: string;
  subtitle: string;
  step_number: number;
  icon: string;
  is_active: boolean;
  sort_order: number;
}

interface WizardOption {
  id: string;
  step_id: string;
  text: string;
  description: string | null;
  icon: string;
  tag: string;
  sort_order: number;
  is_active: boolean;
}

interface GuidanceCard {
  id: string;
  title: string;
  message: string;
  guidance_type: string;
  icon: string;
  priority: number;
  match_tags: string[];
  is_universal: boolean;
  sort_order: number;
  is_active: boolean;
}

interface SupportContact {
  id: string;
  name: string;
  description: string | null;
  phone: string | null;
  website: string | null;
  availability: string | null;
  icon: string;
  is_emergency: boolean;
  sort_order: number;
  is_active: boolean;
}

type TabType = 'steps' | 'guidance' | 'contacts';

// ============================================================
// MAIN PAGE
// ============================================================

export default function HarassmentWizardPage() {
  const [activeTab, setActiveTab] = useState<TabType>('steps');
  const [steps, setSteps] = useState<WizardStep[]>([]);
  const [options, setOptions] = useState<WizardOption[]>([]);
  const [guidance, setGuidance] = useState<GuidanceCard[]>([]);
  const [contacts, setContacts] = useState<SupportContact[]>([]);
  const [loading, setLoading] = useState(true);
  const [expandedStep, setExpandedStep] = useState<string | null>(null);

  // Add forms
  const [showAddOption, setShowAddOption] = useState<string | null>(null);
  const [showAddGuidance, setShowAddGuidance] = useState(false);
  const [showAddContact, setShowAddContact] = useState(false);

  // New item state
  const [newOption, setNewOption] = useState({ text: '', description: '', icon: 'circle', tag: '' });
  const [newGuidance, setNewGuidance] = useState({
    title: '', message: '', guidance_type: 'info', icon: 'info_outline',
    priority: 0, match_tags: '', is_universal: false,
  });
  const [newContact, setNewContact] = useState({
    name: '', description: '', phone: '', website: '',
    availability: '', icon: 'phone', is_emergency: false,
  });

  useEffect(() => {
    fetchAll();
  }, []);

  async function fetchAll() {
    setLoading(true);
    const [stepsRes, optionsRes, guidanceRes, contactsRes] = await Promise.all([
      supabaseAdmin.from('harassment_wizard_steps').select('*').order('step_number'),
      supabaseAdmin.from('harassment_wizard_options').select('*').order('sort_order'),
      supabaseAdmin.from('harassment_wizard_guidance').select('*').order('sort_order'),
      supabaseAdmin.from('harassment_wizard_contacts').select('*').order('sort_order'),
    ]);

    if (stepsRes.data) setSteps(stepsRes.data);
    if (optionsRes.data) setOptions(optionsRes.data);
    if (guidanceRes.data) setGuidance(guidanceRes.data);
    if (contactsRes.data) setContacts(contactsRes.data);
    setLoading(false);
  }

  // ============================================================
  // CRUD OPERATIONS
  // ============================================================

  async function addOption(stepId: string) {
    if (!newOption.text.trim() || !newOption.tag.trim()) return;
    const stepOptions = options.filter(o => o.step_id === stepId);
    const maxOrder = stepOptions.reduce((max, o) => Math.max(max, o.sort_order), 0);

    const { error } = await supabaseAdmin.from('harassment_wizard_options').insert({
      step_id: stepId,
      text: newOption.text,
      description: newOption.description || null,
      icon: newOption.icon,
      tag: newOption.tag,
      sort_order: maxOrder + 1,
      is_active: true,
    });

    if (error) {
      alert(`Error: ${error.message}`);
    } else {
      fetchAll();
      setNewOption({ text: '', description: '', icon: 'circle', tag: '' });
      setShowAddOption(null);
    }
  }

  async function addGuidanceCard() {
    if (!newGuidance.title.trim() || !newGuidance.message.trim()) return;
    const maxOrder = guidance.reduce((max, g) => Math.max(max, g.sort_order), 0);

    const tags = newGuidance.match_tags
      .split(',')
      .map(t => t.trim())
      .filter(t => t.length > 0);

    const { error } = await supabaseAdmin.from('harassment_wizard_guidance').insert({
      title: newGuidance.title,
      message: newGuidance.message,
      guidance_type: newGuidance.guidance_type,
      icon: newGuidance.icon,
      priority: newGuidance.priority,
      match_tags: tags,
      is_universal: newGuidance.is_universal,
      sort_order: maxOrder + 1,
      is_active: true,
    });

    if (error) {
      alert(`Error: ${error.message}`);
    } else {
      fetchAll();
      setNewGuidance({
        title: '', message: '', guidance_type: 'info', icon: 'info_outline',
        priority: 0, match_tags: '', is_universal: false,
      });
      setShowAddGuidance(false);
    }
  }

  async function addContactEntry() {
    if (!newContact.name.trim()) return;
    const maxOrder = contacts.reduce((max, c) => Math.max(max, c.sort_order), 0);

    const { error } = await supabaseAdmin.from('harassment_wizard_contacts').insert({
      name: newContact.name,
      description: newContact.description || null,
      phone: newContact.phone || null,
      website: newContact.website || null,
      availability: newContact.availability || null,
      icon: newContact.icon,
      is_emergency: newContact.is_emergency,
      sort_order: maxOrder + 1,
      is_active: true,
    });

    if (error) {
      alert(`Error: ${error.message}`);
    } else {
      fetchAll();
      setNewContact({
        name: '', description: '', phone: '', website: '',
        availability: '', icon: 'phone', is_emergency: false,
      });
      setShowAddContact(false);
    }
  }

  async function toggleActive(table: string, id: string, current: boolean) {
    await supabaseAdmin.from(table).update({ is_active: !current }).eq('id', id);
    fetchAll();
  }

  async function deleteItem(table: string, id: string, label: string) {
    if (!confirm(`Delete "${label}"?`)) return;
    await supabaseAdmin.from(table).delete().eq('id', id);
    fetchAll();
  }

  // ============================================================
  // GUIDANCE TYPE HELPERS
  // ============================================================

  const guidanceTypeColors: Record<string, string> = {
    classification: 'bg-blue-100 text-blue-800',
    rights: 'bg-purple-100 text-purple-800',
    action_formal: 'bg-orange-100 text-orange-800',
    action_informal: 'bg-green-100 text-green-800',
    support: 'bg-cyan-100 text-cyan-800',
    self_care: 'bg-pink-100 text-pink-800',
    info: 'bg-gray-100 text-gray-800',
    warning: 'bg-red-100 text-red-800',
  };

  const guidanceTypes = [
    'classification', 'rights', 'action_formal', 'action_informal',
    'support', 'self_care', 'info', 'warning',
  ];

  // ============================================================
  // RENDER
  // ============================================================

  if (loading) {
    return (
      <div className="p-8">
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 rounded w-1/3"></div>
          <div className="h-64 bg-gray-200 rounded"></div>
        </div>
      </div>
    );
  }

  const tabs = [
    { id: 'steps' as const, label: 'Steps & Options', count: steps.length, icon: '📋' },
    { id: 'guidance' as const, label: 'Guidance Cards', count: guidance.length, icon: '💬' },
    { id: 'contacts' as const, label: 'Support Contacts', count: contacts.length, icon: '📞' },
  ];

  return (
    <div className="p-8 max-w-6xl mx-auto">
      {/* Breadcrumb */}
      <div className="mb-6">
        <Link href="/admin/content-manager" className="text-cyan-600 hover:text-cyan-800 text-sm flex items-center gap-1">
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          Back to Content Manager
        </Link>
      </div>

      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-2">
          <span className="text-3xl">🛡️</span>
          <h1 className="text-3xl font-bold text-gray-900">Harassment Support Wizard</h1>
        </div>
        <p className="text-gray-600">
          Manage the guided assessment tool for service women. All interactions are tap-only — no free text input.
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-900">{steps.length}</div>
          <div className="text-sm text-gray-500">Wizard Steps</div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-900">{options.length}</div>
          <div className="text-sm text-gray-500">Tap Options</div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-900">{guidance.length}</div>
          <div className="text-sm text-gray-500">Guidance Cards</div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="text-2xl font-bold text-gray-900">{contacts.length}</div>
          <div className="text-sm text-gray-500">Support Contacts</div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6 flex-wrap">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`px-4 py-2 rounded-lg font-medium transition flex items-center gap-2 ${
              activeTab === tab.id
                ? 'bg-cyan-600 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            <span>{tab.icon}</span>
            {tab.label}
            <span className={`text-xs px-2 py-0.5 rounded-full ${
              activeTab === tab.id ? 'bg-white/20' : 'bg-gray-200'
            }`}>{tab.count}</span>
          </button>
        ))}
      </div>

      {/* Tab Content */}
      {activeTab === 'steps' && (
        <div className="space-y-4">
          {steps.map((step) => {
            const stepOptions = options.filter(o => o.step_id === step.id);
            const isExpanded = expandedStep === step.id;

            return (
              <div key={step.id} className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                {/* Step header */}
                <button
                  onClick={() => setExpandedStep(isExpanded ? null : step.id)}
                  className="w-full p-5 flex items-center justify-between hover:bg-gray-50 transition"
                >
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-full bg-cyan-100 flex items-center justify-center text-cyan-700 font-bold">
                      {step.step_number}
                    </div>
                    <div className="text-left">
                      <h3 className="font-semibold text-gray-900">{step.title}</h3>
                      <p className="text-sm text-gray-500">{step.subtitle}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-sm text-gray-400">{stepOptions.length} options</span>
                    <svg
                      className={`w-5 h-5 text-gray-400 transition-transform ${isExpanded ? 'rotate-180' : ''}`}
                      fill="none" stroke="currentColor" viewBox="0 0 24 24"
                    >
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                    </svg>
                  </div>
                </button>

                {/* Expanded options */}
                {isExpanded && (
                  <div className="border-t border-gray-200 p-5 bg-gray-50">
                    <div className="space-y-3 mb-4">
                      {stepOptions.map((option) => (
                        <div
                          key={option.id}
                          className={`bg-white rounded-lg p-4 border border-gray-200 ${!option.is_active ? 'opacity-50' : ''}`}
                        >
                          <div className="flex items-start justify-between">
                            <div className="flex-1">
                              <div className="flex items-center gap-2 mb-1">
                                <span className="font-medium text-gray-900">{option.text}</span>
                                <span className="text-xs px-2 py-0.5 rounded-full bg-cyan-100 text-cyan-700 font-mono">
                                  {option.tag}
                                </span>
                              </div>
                              {option.description && (
                                <p className="text-sm text-gray-500">{option.description}</p>
                              )}
                            </div>
                            <div className="flex items-center gap-2 ml-4">
                              <button
                                onClick={() => toggleActive('harassment_wizard_options', option.id, option.is_active)}
                                className={`text-xs px-2 py-1 rounded ${option.is_active ? 'text-green-600' : 'text-gray-400'}`}
                              >
                                {option.is_active ? 'Active' : 'Inactive'}
                              </button>
                              <button
                                onClick={() => deleteItem('harassment_wizard_options', option.id, option.text)}
                                className="text-red-500 hover:text-red-700 text-xs"
                              >
                                Delete
                              </button>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>

                    {/* Add option form */}
                    {showAddOption === step.id ? (
                      <div className="bg-white rounded-lg p-4 border-2 border-dashed border-cyan-300">
                        <h4 className="font-medium mb-3">Add New Option</h4>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                          <input
                            type="text"
                            value={newOption.text}
                            onChange={(e) => setNewOption({ ...newOption, text: e.target.value })}
                            placeholder="Option text (e.g., Unwanted comments)"
                            className="px-3 py-2 border rounded-lg text-sm text-gray-900"
                          />
                          <input
                            type="text"
                            value={newOption.tag}
                            onChange={(e) => setNewOption({ ...newOption, tag: e.target.value })}
                            placeholder="Tag (e.g., verbal)"
                            className="px-3 py-2 border rounded-lg text-sm font-mono text-gray-900"
                          />
                          <input
                            type="text"
                            value={newOption.description}
                            onChange={(e) => setNewOption({ ...newOption, description: e.target.value })}
                            placeholder="Description (optional)"
                            className="px-3 py-2 border rounded-lg text-sm md:col-span-2 text-gray-900"
                          />
                        </div>
                        <div className="flex justify-end gap-2 mt-3">
                          <button onClick={() => setShowAddOption(null)} className="px-3 py-1.5 text-sm text-gray-600">Cancel</button>
                          <button
                            onClick={() => addOption(step.id)}
                            disabled={!newOption.text.trim() || !newOption.tag.trim()}
                            className="px-3 py-1.5 text-sm bg-cyan-600 text-white rounded-lg disabled:opacity-50"
                          >
                            Add
                          </button>
                        </div>
                      </div>
                    ) : (
                      <button
                        onClick={() => setShowAddOption(step.id)}
                        className="w-full py-3 border-2 border-dashed border-gray-300 rounded-lg text-gray-500 hover:border-cyan-400 hover:text-cyan-600 transition text-sm"
                      >
                        + Add Option to Step {step.step_number}
                      </button>
                    )}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      {activeTab === 'guidance' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <p className="text-sm text-gray-500">
              Guidance cards are shown based on tag matching. Universal cards always appear.
            </p>
            <button
              onClick={() => setShowAddGuidance(!showAddGuidance)}
              className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 transition text-sm flex items-center gap-2"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
              </svg>
              Add Guidance Card
            </button>
          </div>

          {/* Add guidance form */}
          {showAddGuidance && (
            <div className="bg-white rounded-xl border-2 border-dashed border-cyan-300 p-6 mb-6">
              <h3 className="font-semibold mb-4">New Guidance Card</h3>
              <div className="space-y-3">
                <input
                  type="text"
                  value={newGuidance.title}
                  onChange={(e) => setNewGuidance({ ...newGuidance, title: e.target.value })}
                  placeholder="Title"
                  className="w-full px-4 py-2 border rounded-lg text-gray-900"
                />
                <textarea
                  value={newGuidance.message}
                  onChange={(e) => setNewGuidance({ ...newGuidance, message: e.target.value })}
                  placeholder="Guidance message..."
                  rows={4}
                  className="w-full px-4 py-2 border rounded-lg text-gray-900"
                />
                <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                  <select
                    value={newGuidance.guidance_type}
                    onChange={(e) => setNewGuidance({ ...newGuidance, guidance_type: e.target.value })}
                    className="px-4 py-2 border rounded-lg text-gray-900"
                  >
                    {guidanceTypes.map(t => (
                      <option key={t} value={t}>{t.replace('_', ' ')}</option>
                    ))}
                  </select>
                  <input
                    type="number"
                    value={newGuidance.priority}
                    onChange={(e) => setNewGuidance({ ...newGuidance, priority: parseInt(e.target.value) || 0 })}
                    placeholder="Priority (higher = first)"
                    className="px-4 py-2 border rounded-lg text-gray-900"
                  />
                  <label className="flex items-center gap-2 px-4 py-2">
                    <input
                      type="checkbox"
                      checked={newGuidance.is_universal}
                      onChange={(e) => setNewGuidance({ ...newGuidance, is_universal: e.target.checked })}
                      className="rounded"
                    />
                    <span className="text-sm text-gray-700">Always show (universal)</span>
                  </label>
                </div>
                {!newGuidance.is_universal && (
                  <input
                    type="text"
                    value={newGuidance.match_tags}
                    onChange={(e) => setNewGuidance({ ...newGuidance, match_tags: e.target.value })}
                    placeholder="Match tags (comma-separated, e.g.: verbal, gender_bullying)"
                    className="w-full px-4 py-2 border rounded-lg text-sm font-mono text-gray-900"
                  />
                )}
                <div className="flex justify-end gap-2">
                  <button onClick={() => setShowAddGuidance(false)} className="px-4 py-2 text-gray-600">Cancel</button>
                  <button
                    onClick={addGuidanceCard}
                    disabled={!newGuidance.title.trim() || !newGuidance.message.trim()}
                    className="px-4 py-2 bg-cyan-600 text-white rounded-lg disabled:opacity-50"
                  >
                    Add Guidance Card
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Guidance list */}
          <div className="space-y-3">
            {guidance.map((card) => (
              <div
                key={card.id}
                className={`bg-white rounded-xl border border-gray-200 p-5 ${!card.is_active ? 'opacity-50' : ''}`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <h3 className="font-semibold text-gray-900">{card.title}</h3>
                      <span className={`text-xs px-2 py-0.5 rounded-full ${guidanceTypeColors[card.guidance_type] || 'bg-gray-100'}`}>
                        {card.guidance_type.replace('_', ' ')}
                      </span>
                      {card.is_universal && (
                        <span className="text-xs px-2 py-0.5 rounded-full bg-yellow-100 text-yellow-800">
                          Universal
                        </span>
                      )}
                      <span className="text-xs text-gray-400">Priority: {card.priority}</span>
                    </div>
                    <p className="text-sm text-gray-600 mb-2">{card.message}</p>
                    {card.match_tags && card.match_tags.length > 0 && (
                      <div className="flex flex-wrap gap-1">
                        {card.match_tags.map((tag) => (
                          <span key={tag} className="text-xs px-2 py-0.5 rounded bg-cyan-50 text-cyan-700 font-mono">
                            {tag}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                  <div className="flex items-center gap-2 ml-4">
                    <button
                      onClick={() => toggleActive('harassment_wizard_guidance', card.id, card.is_active)}
                      className={`text-xs px-2 py-1 rounded ${card.is_active ? 'text-green-600' : 'text-gray-400'}`}
                    >
                      {card.is_active ? 'Active' : 'Inactive'}
                    </button>
                    <button
                      onClick={() => deleteItem('harassment_wizard_guidance', card.id, card.title)}
                      className="text-red-500 hover:text-red-700 text-xs"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === 'contacts' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <p className="text-sm text-gray-500">
              Support contacts shown at the end of the assessment. Emergency contacts appear first.
            </p>
            <button
              onClick={() => setShowAddContact(!showAddContact)}
              className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 transition text-sm flex items-center gap-2"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
              </svg>
              Add Contact
            </button>
          </div>

          {/* Add contact form */}
          {showAddContact && (
            <div className="bg-white rounded-xl border-2 border-dashed border-cyan-300 p-6 mb-6">
              <h3 className="font-semibold mb-4">New Support Contact</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                <input
                  type="text"
                  value={newContact.name}
                  onChange={(e) => setNewContact({ ...newContact, name: e.target.value })}
                  placeholder="Organisation name"
                  className="px-4 py-2 border rounded-lg text-gray-900"
                />
                <input
                  type="text"
                  value={newContact.phone}
                  onChange={(e) => setNewContact({ ...newContact, phone: e.target.value })}
                  placeholder="Phone number"
                  className="px-4 py-2 border rounded-lg text-gray-900"
                />
                <input
                  type="text"
                  value={newContact.description}
                  onChange={(e) => setNewContact({ ...newContact, description: e.target.value })}
                  placeholder="Description"
                  className="px-4 py-2 border rounded-lg md:col-span-2 text-gray-900"
                />
                <input
                  type="text"
                  value={newContact.website}
                  onChange={(e) => setNewContact({ ...newContact, website: e.target.value })}
                  placeholder="Website URL"
                  className="px-4 py-2 border rounded-lg text-gray-900"
                />
                <input
                  type="text"
                  value={newContact.availability}
                  onChange={(e) => setNewContact({ ...newContact, availability: e.target.value })}
                  placeholder="Availability (e.g., 24/7)"
                  className="px-4 py-2 border rounded-lg text-gray-900"
                />
                <label className="flex items-center gap-2 px-4 py-2">
                  <input
                    type="checkbox"
                    checked={newContact.is_emergency}
                    onChange={(e) => setNewContact({ ...newContact, is_emergency: e.target.checked })}
                    className="rounded"
                  />
                  <span className="text-sm text-gray-700">Emergency contact (shown at top)</span>
                </label>
              </div>
              <div className="flex justify-end gap-2 mt-4">
                <button onClick={() => setShowAddContact(false)} className="px-4 py-2 text-gray-600">Cancel</button>
                <button
                  onClick={addContactEntry}
                  disabled={!newContact.name.trim()}
                  className="px-4 py-2 bg-cyan-600 text-white rounded-lg disabled:opacity-50"
                >
                  Add Contact
                </button>
              </div>
            </div>
          )}

          {/* Contacts list */}
          <div className="space-y-3">
            {/* Emergency contacts first */}
            {contacts.filter(c => c.is_emergency).length > 0 && (
              <div className="mb-2">
                <h3 className="text-sm font-semibold text-red-600 mb-2">EMERGENCY</h3>
                {contacts.filter(c => c.is_emergency).map((contact) => (
                  <div
                    key={contact.id}
                    className={`bg-red-50 rounded-xl border border-red-200 p-5 mb-3 ${!contact.is_active ? 'opacity-50' : ''}`}
                  >
                    <div className="flex items-start justify-between">
                      <div>
                        <h4 className="font-semibold text-gray-900">{contact.name}</h4>
                        {contact.description && <p className="text-sm text-gray-600">{contact.description}</p>}
                        <div className="flex items-center gap-4 mt-2 text-sm">
                          {contact.phone && <span className="text-red-700 font-medium">{contact.phone}</span>}
                          {contact.availability && <span className="text-gray-500">{contact.availability}</span>}
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => toggleActive('harassment_wizard_contacts', contact.id, contact.is_active)}
                          className={`text-xs px-2 py-1 ${contact.is_active ? 'text-green-600' : 'text-gray-400'}`}
                        >
                          {contact.is_active ? 'Active' : 'Inactive'}
                        </button>
                        <button
                          onClick={() => deleteItem('harassment_wizard_contacts', contact.id, contact.name)}
                          className="text-red-500 hover:text-red-700 text-xs"
                        >
                          Delete
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Non-emergency contacts */}
            <h3 className="text-sm font-semibold text-gray-500 mb-2">SUPPORT SERVICES</h3>
            {contacts.filter(c => !c.is_emergency).map((contact) => (
              <div
                key={contact.id}
                className={`bg-white rounded-xl border border-gray-200 p-5 ${!contact.is_active ? 'opacity-50' : ''}`}
              >
                <div className="flex items-start justify-between">
                  <div>
                    <h4 className="font-semibold text-gray-900">{contact.name}</h4>
                    {contact.description && <p className="text-sm text-gray-600">{contact.description}</p>}
                    <div className="flex items-center gap-4 mt-2 text-sm flex-wrap">
                      {contact.phone && <span className="text-cyan-700 font-medium">{contact.phone}</span>}
                      {contact.website && (
                        <a href={contact.website} target="_blank" className="text-cyan-600 hover:underline">
                          Website
                        </a>
                      )}
                      {contact.availability && <span className="text-gray-500">{contact.availability}</span>}
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => toggleActive('harassment_wizard_contacts', contact.id, contact.is_active)}
                      className={`text-xs px-2 py-1 ${contact.is_active ? 'text-green-600' : 'text-gray-400'}`}
                    >
                      {contact.is_active ? 'Active' : 'Inactive'}
                    </button>
                    <button
                      onClick={() => deleteItem('harassment_wizard_contacts', contact.id, contact.name)}
                      className="text-red-500 hover:text-red-700 text-xs"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* How it works info */}
      <div className="mt-12 bg-cyan-50 border border-cyan-200 rounded-xl p-6">
        <h2 className="text-lg font-semibold text-cyan-800 mb-3">How the Wizard Works</h2>
        <div className="space-y-2 text-sm text-cyan-700">
          <p><strong>1. Steps:</strong> The user taps through each step, selecting one option per step (except step 4 which allows multiple).</p>
          <p><strong>2. Tags:</strong> Each option has a tag (e.g., &quot;verbal&quot;, &quot;workplace&quot;, &quot;regular&quot;). These tags determine which guidance cards appear.</p>
          <p><strong>3. Guidance Cards:</strong> Cards with matching tags are shown in the results. Universal cards always appear. Higher priority cards appear first.</p>
          <p><strong>4. Support Contacts:</strong> Always shown at the bottom of results. Emergency contacts appear first with a prominent display.</p>
          <p><strong>5. Privacy:</strong> No data is stored or transmitted. Everything happens locally on the device.</p>
        </div>
      </div>

      {/* Setup Instructions */}
      <div className="mt-6 bg-amber-50 border border-amber-200 rounded-xl p-6">
        <h2 className="text-lg font-semibold text-amber-800 mb-2">Setup</h2>
        <p className="text-amber-700 text-sm">
          Run <code className="bg-white px-2 py-1 rounded font-mono">harassment-wizard-schema.sql</code> in
          your Supabase dashboard to create the tables and default content.
        </p>
      </div>
    </div>
  );
}
