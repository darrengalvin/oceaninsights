'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface AssessmentQuestion { id: string; question: string; emoji: string; subtext: string | null; step_number: number; is_active: boolean; }
interface AssessmentOption { id: string; question_id: string; text: string; emoji: string; tag: string; subtext: string | null; sort_order: number; is_active: boolean; }
interface GuidanceCard { id: string; title: string; content: string; action_steps: string[]; match_tags: string[]; icon: string; colour: string; priority: number; is_active: boolean; }
interface BystanderAction { id: string; title: string; subtitle: string; content: string; examples: string[]; sort_order: number; is_active: boolean; }
interface CopingStrategy { id: string; title: string; subtitle: string; emoji: string; colour: string; content: string; sort_order: number; is_active: boolean; }
interface SupportOrg { id: string; name: string; description: string; access: string; sort_order: number; is_active: boolean; }

type TabType = 'assessment' | 'guidance' | 'bystander' | 'coping' | 'support';

export default function BullyingSupportPage() {
  const [activeTab, setActiveTab] = useState<TabType>('assessment');
  const [questions, setQuestions] = useState<AssessmentQuestion[]>([]);
  const [options, setOptions] = useState<AssessmentOption[]>([]);
  const [guidance, setGuidance] = useState<GuidanceCard[]>([]);
  const [bystander, setBystander] = useState<BystanderAction[]>([]);
  const [coping, setCoping] = useState<CopingStrategy[]>([]);
  const [support, setSupport] = useState<SupportOrg[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [formData, setFormData] = useState<any>({});
  const [expandedQ, setExpandedQ] = useState<string | null>(null);

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [qRes, oRes, gRes, bRes, cRes, sRes] = await Promise.all([
      supabaseAdmin.from('bullying_assessment_questions').select('*').order('step_number'),
      supabaseAdmin.from('bullying_assessment_options').select('*').order('sort_order'),
      supabaseAdmin.from('bullying_guidance_cards').select('*').order('priority', { ascending: false }),
      supabaseAdmin.from('bullying_bystander_actions').select('*').order('sort_order'),
      supabaseAdmin.from('bullying_coping_strategies').select('*').order('sort_order'),
      supabaseAdmin.from('bullying_support_orgs').select('*').order('sort_order'),
    ]);
    if (qRes.data) setQuestions(qRes.data);
    if (oRes.data) setOptions(oRes.data);
    if (gRes.data) setGuidance(gRes.data);
    if (bRes.data) setBystander(bRes.data);
    if (cRes.data) setCoping(cRes.data);
    if (sRes.data) setSupport(sRes.data);
    setLoading(false);
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
  async function saveItem(table: string, payload: any) {
    await supabaseAdmin.from(table).insert(payload);
    fetchAll(); setShowAdd(false); setFormData({});
  }
  function resetForm() { setShowAdd(false); setFormData({}); }

  if (loading) return <div className="p-8"><div className="animate-pulse h-64 bg-gray-200 rounded"></div></div>;

  const tabs = [
    { id: 'assessment' as const, label: 'Assessment', count: questions.length, icon: '🤔' },
    { id: 'guidance' as const, label: 'Guidance Cards', count: guidance.length, icon: '💬' },
    { id: 'bystander' as const, label: 'Bystander Guide', count: bystander.length, icon: '👥' },
    { id: 'coping' as const, label: 'Coping Tools', count: coping.length, icon: '🧘' },
    { id: 'support' as const, label: 'Support Orgs', count: support.length, icon: '📞' },
  ];

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <Link href="/admin/content-manager" className="text-cyan-600 hover:text-cyan-800 text-sm">← Back to Content Manager</Link>
      </div>
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-2">
          <span className="text-3xl">🛡️</span>
          <h1 className="text-3xl font-bold text-gray-900">Bullying Support</h1>
        </div>
        <p className="text-gray-600">Manage assessment questions, guidance, bystander actions, coping tools, and support organisations.</p>
      </div>

      <div className="flex gap-2 mb-6 flex-wrap">
        {tabs.map(t => (
          <button key={t.id} onClick={() => { setActiveTab(t.id); resetForm(); }}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition ${activeTab === t.id ? 'bg-amber-600 text-white' : 'bg-white text-gray-600 border hover:bg-gray-50'}`}>
            {t.icon} {t.label} ({t.count})
          </button>
        ))}
      </div>

      {/* ASSESSMENT */}
      {activeTab === 'assessment' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Assessment Questions & Options</h2>
            <button onClick={() => { setShowAdd(true); setFormData({ _type: 'option', question_id: '', text: '', emoji: '❓', tag: '', subtext: '' }); }}
              className="bg-amber-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add Option</button>
          </div>
          {showAdd && formData._type === 'option' && (
            <div className="bg-white border rounded-xl p-4 mb-4 space-y-3">
              <select value={formData.question_id} onChange={e => setFormData({...formData, question_id: e.target.value})} className="border rounded px-3 py-2 text-sm w-full">
                <option value="">Select question...</option>
                {questions.map(q => <option key={q.id} value={q.id}>Step {q.step_number}: {q.question}</option>)}
              </select>
              <div className="grid grid-cols-3 gap-3">
                <input placeholder="Option text" value={formData.text} onChange={e => setFormData({...formData, text: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Emoji" value={formData.emoji} onChange={e => setFormData({...formData, emoji: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Tag" value={formData.tag} onChange={e => setFormData({...formData, tag: e.target.value})} className="border rounded px-3 py-2 text-sm" />
              </div>
              <input placeholder="Subtext (optional)" value={formData.subtext} onChange={e => setFormData({...formData, subtext: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <div className="flex gap-2">
                <button onClick={() => saveItem('bullying_assessment_options', { question_id: formData.question_id, text: formData.text, emoji: formData.emoji, tag: formData.tag, subtext: formData.subtext || null, sort_order: options.filter(o => o.question_id === formData.question_id).length })}
                  className="bg-amber-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            </div>
          )}
          <div className="space-y-4">
            {questions.map(q => (
              <div key={q.id} className="bg-white border rounded-xl overflow-hidden">
                <button onClick={() => setExpandedQ(expandedQ === q.id ? null : q.id)} className="w-full p-4 flex justify-between items-center text-left hover:bg-gray-50">
                  <div className="flex items-center gap-3">
                    <span className="text-xl">{q.emoji}</span>
                    <div>
                      <span className="text-xs text-gray-400">Step {q.step_number}</span>
                      <p className="font-medium">{q.question}</p>
                    </div>
                  </div>
                  <span className="text-gray-400">{expandedQ === q.id ? '▲' : '▼'}</span>
                </button>
                {expandedQ === q.id && (
                  <div className="border-t p-4 space-y-2">
                    {options.filter(o => o.question_id === q.id).map(o => (
                      <div key={o.id} className={`flex justify-between items-center p-3 rounded-lg border ${!o.is_active ? 'opacity-50' : ''}`}>
                        <div className="flex items-center gap-3">
                          <span>{o.emoji}</span>
                          <div>
                            <span className="text-sm font-medium">{o.text}</span>
                            {o.subtext && <p className="text-xs text-gray-500">{o.subtext}</p>}
                            <span className="text-xs bg-gray-100 px-1.5 py-0.5 rounded text-gray-500 ml-1">{o.tag}</span>
                          </div>
                        </div>
                        <div className="flex gap-2">
                          <button onClick={() => toggleActive('bullying_assessment_options', o.id, o.is_active)} className="text-xs text-gray-500 hover:underline">{o.is_active ? 'Disable' : 'Enable'}</button>
                          <button onClick={() => deleteItem('bullying_assessment_options', o.id, o.text)} className="text-xs text-red-500 hover:underline">Delete</button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* GUIDANCE CARDS */}
      {activeTab === 'guidance' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Guidance Cards ({guidance.length})</h2>
            <button onClick={() => { setShowAdd(true); setFormData({ _type: 'guidance', title: '', content: '', action_steps: '', match_tags: '', icon: 'info', colour: '#F59E0B', priority: 5 }); }}
              className="bg-amber-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add Card</button>
          </div>
          {showAdd && formData._type === 'guidance' && (
            <div className="bg-white border rounded-xl p-4 mb-4 space-y-3">
              <div className="grid grid-cols-3 gap-3">
                <input placeholder="Title" value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} className="border rounded px-3 py-2 text-sm col-span-2" />
                <input placeholder="Priority (1-10)" type="number" value={formData.priority} onChange={e => setFormData({...formData, priority: parseInt(e.target.value) || 5})} className="border rounded px-3 py-2 text-sm" />
              </div>
              <textarea placeholder="Content" rows={3} value={formData.content} onChange={e => setFormData({...formData, content: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <textarea placeholder="Action steps (one per line)" rows={3} value={formData.action_steps} onChange={e => setFormData({...formData, action_steps: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <input placeholder="Match tags (comma-separated, e.g. verbal,school)" value={formData.match_tags} onChange={e => setFormData({...formData, match_tags: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <div className="flex gap-2">
                <button onClick={() => saveItem('bullying_guidance_cards', {
                  title: formData.title, content: formData.content, priority: formData.priority,
                  action_steps: formData.action_steps.split('\n').filter((s: string) => s.trim()),
                  match_tags: formData.match_tags.split(',').map((t: string) => t.trim()).filter((t: string) => t),
                  icon: formData.icon, colour: formData.colour,
                })} className="bg-amber-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            </div>
          )}
          <div className="space-y-3">
            {guidance.map(g => (
              <div key={g.id} className={`bg-white border rounded-xl p-4 ${!g.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between items-start">
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="font-semibold">{g.title}</h3>
                      <span className="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded">P{g.priority}</span>
                    </div>
                    <p className="text-sm text-gray-600 mt-1 line-clamp-2">{g.content}</p>
                    <div className="flex gap-1 mt-2 flex-wrap">
                      {g.match_tags.map(t => <span key={t} className="text-xs bg-gray-100 px-1.5 py-0.5 rounded text-gray-500">{t}</span>)}
                      {g.match_tags.length === 0 && <span className="text-xs bg-blue-50 text-blue-600 px-1.5 py-0.5 rounded">universal</span>}
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => toggleActive('bullying_guidance_cards', g.id, g.is_active)} className="text-xs text-gray-500 hover:underline">{g.is_active ? 'Disable' : 'Enable'}</button>
                    <button onClick={() => deleteItem('bullying_guidance_cards', g.id, g.title)} className="text-xs text-red-500 hover:underline">Delete</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* BYSTANDER */}
      {activeTab === 'bystander' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Bystander Actions ({bystander.length})</h2>
            <button onClick={() => { setShowAdd(true); setFormData({ _type: 'bystander', title: '', subtitle: '', content: '', examples: '' }); }}
              className="bg-indigo-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add Action</button>
          </div>
          {showAdd && formData._type === 'bystander' && (
            <div className="bg-white border rounded-xl p-4 mb-4 space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <input placeholder="Title (e.g. 'Direct — Speak Up')" value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Subtitle" value={formData.subtitle} onChange={e => setFormData({...formData, subtitle: e.target.value})} className="border rounded px-3 py-2 text-sm" />
              </div>
              <textarea placeholder="Content" rows={3} value={formData.content} onChange={e => setFormData({...formData, content: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <textarea placeholder="Examples (one per line)" rows={3} value={formData.examples} onChange={e => setFormData({...formData, examples: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <div className="flex gap-2">
                <button onClick={() => saveItem('bullying_bystander_actions', {
                  title: formData.title, subtitle: formData.subtitle, content: formData.content,
                  examples: formData.examples.split('\n').filter((s: string) => s.trim()), sort_order: bystander.length,
                })} className="bg-indigo-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            </div>
          )}
          <div className="space-y-3">
            {bystander.map((b, i) => (
              <div key={b.id} className={`bg-white border rounded-xl p-4 ${!b.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between">
                  <div>
                    <span className="text-xs text-gray-400">#{i + 1}</span>
                    <h3 className="font-semibold">{b.title}</h3>
                    <p className="text-sm text-gray-500">{b.subtitle}</p>
                    <p className="text-sm text-gray-600 mt-1 line-clamp-2">{b.content}</p>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => toggleActive('bullying_bystander_actions', b.id, b.is_active)} className="text-xs text-gray-500 hover:underline">{b.is_active ? 'Disable' : 'Enable'}</button>
                    <button onClick={() => deleteItem('bullying_bystander_actions', b.id, b.title)} className="text-xs text-red-500 hover:underline">Delete</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* COPING */}
      {activeTab === 'coping' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Coping Strategies ({coping.length})</h2>
            <button onClick={() => { setShowAdd(true); setFormData({ _type: 'coping', title: '', subtitle: '', emoji: '💡', colour: '#34D399', content: '' }); }}
              className="bg-emerald-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add Strategy</button>
          </div>
          {showAdd && formData._type === 'coping' && (
            <div className="bg-white border rounded-xl p-4 mb-4 space-y-3">
              <div className="grid grid-cols-4 gap-3">
                <input placeholder="Title" value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} className="border rounded px-3 py-2 text-sm col-span-2" />
                <input placeholder="Emoji" value={formData.emoji} onChange={e => setFormData({...formData, emoji: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Colour" value={formData.colour} onChange={e => setFormData({...formData, colour: e.target.value})} className="border rounded px-3 py-2 text-sm" />
              </div>
              <input placeholder="Subtitle" value={formData.subtitle} onChange={e => setFormData({...formData, subtitle: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <textarea placeholder="Content" rows={5} value={formData.content} onChange={e => setFormData({...formData, content: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <div className="flex gap-2">
                <button onClick={() => saveItem('bullying_coping_strategies', { title: formData.title, subtitle: formData.subtitle, emoji: formData.emoji, colour: formData.colour, content: formData.content, sort_order: coping.length })}
                  className="bg-emerald-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            </div>
          )}
          <div className="space-y-3">
            {coping.map(c => (
              <div key={c.id} className={`bg-white border rounded-xl p-4 ${!c.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between">
                  <div className="flex items-center gap-3">
                    <span className="text-xl">{c.emoji}</span>
                    <div>
                      <h3 className="font-semibold">{c.title}</h3>
                      <p className="text-sm text-gray-500">{c.subtitle}</p>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => toggleActive('bullying_coping_strategies', c.id, c.is_active)} className="text-xs text-gray-500 hover:underline">{c.is_active ? 'Disable' : 'Enable'}</button>
                    <button onClick={() => deleteItem('bullying_coping_strategies', c.id, c.title)} className="text-xs text-red-500 hover:underline">Delete</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* SUPPORT ORGS */}
      {activeTab === 'support' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Support Organisations ({support.length})</h2>
            <button onClick={() => { setShowAdd(true); setFormData({ _type: 'support', name: '', description: '', access: '' }); }}
              className="bg-violet-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add Organisation</button>
          </div>
          {showAdd && formData._type === 'support' && (
            <div className="bg-white border rounded-xl p-4 mb-4 space-y-3">
              <input placeholder="Organisation name" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <input placeholder="Description" value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <input placeholder="How to access (website, phone, etc.)" value={formData.access} onChange={e => setFormData({...formData, access: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <div className="flex gap-2">
                <button onClick={() => saveItem('bullying_support_orgs', { name: formData.name, description: formData.description, access: formData.access, sort_order: support.length })}
                  className="bg-violet-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            </div>
          )}
          <div className="space-y-3">
            {support.map(s => (
              <div key={s.id} className={`bg-white border rounded-xl p-4 ${!s.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between">
                  <div>
                    <h3 className="font-semibold">{s.name}</h3>
                    <p className="text-sm text-gray-500">{s.description}</p>
                    <p className="text-sm text-violet-600 mt-1">{s.access}</p>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => toggleActive('bullying_support_orgs', s.id, s.is_active)} className="text-xs text-gray-500 hover:underline">{s.is_active ? 'Disable' : 'Enable'}</button>
                    <button onClick={() => deleteItem('bullying_support_orgs', s.id, s.name)} className="text-xs text-red-500 hover:underline">Delete</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
