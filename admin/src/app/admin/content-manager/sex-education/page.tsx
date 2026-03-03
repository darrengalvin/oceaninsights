'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface ConsentPrinciple { id: string; letter: string; word: string; description: string; colour: string; sort_order: number; is_active: boolean; }
interface ConsentScenario { id: string; scenario: string; question: string; correct_option_id: string; explanation: string; sort_order: number; is_active: boolean; }
interface ScenarioOption { id: string; scenario_id: string; option_id: string; text: string; sort_order: number; is_active: boolean; }
interface RelationshipSign { id: string; sign_type: 'healthy' | 'warning'; text: string; sort_order: number; is_active: boolean; }
interface RelationshipRight { id: string; text: string; sort_order: number; is_active: boolean; }
interface StiInfo { id: string; name: string; description: string; symptoms: string; treatment: string; prevention: string; treatable: boolean; sort_order: number; is_active: boolean; }
interface KeyFact { id: string; title: string; subtitle: string; content: string; icon: string; colour: string; sort_order: number; is_active: boolean; }

type TabType = 'consent' | 'relationships' | 'sti' | 'facts';

export default function SexEducationPage() {
  const [activeTab, setActiveTab] = useState<TabType>('consent');
  const [principles, setPrinciples] = useState<ConsentPrinciple[]>([]);
  const [scenarios, setScenarios] = useState<ConsentScenario[]>([]);
  const [scenarioOptions, setScenarioOptions] = useState<ScenarioOption[]>([]);
  const [healthySigns, setHealthySigns] = useState<RelationshipSign[]>([]);
  const [warningSigns, setWarningSigns] = useState<RelationshipSign[]>([]);
  const [rights, setRights] = useState<RelationshipRight[]>([]);
  const [stis, setStis] = useState<StiInfo[]>([]);
  const [facts, setFacts] = useState<KeyFact[]>([]);
  const [loading, setLoading] = useState(true);

  // Add/edit state
  const [showAdd, setShowAdd] = useState(false);
  const [editItem, setEditItem] = useState<any>(null);
  const [formData, setFormData] = useState<any>({});

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [pRes, sRes, soRes, rsRes, rrRes, stiRes, fRes] = await Promise.all([
      supabaseAdmin.from('sex_ed_consent_principles').select('*').order('sort_order'),
      supabaseAdmin.from('sex_ed_consent_scenarios').select('*').order('sort_order'),
      supabaseAdmin.from('sex_ed_scenario_options').select('*').order('sort_order'),
      supabaseAdmin.from('sex_ed_relationship_signs').select('*').order('sort_order'),
      supabaseAdmin.from('sex_ed_relationship_rights').select('*').order('sort_order'),
      supabaseAdmin.from('sex_ed_sti_info').select('*').order('sort_order'),
      supabaseAdmin.from('sex_ed_key_facts').select('*').order('sort_order'),
    ]);
    if (pRes.data) setPrinciples(pRes.data);
    if (sRes.data) setScenarios(sRes.data);
    if (soRes.data) setScenarioOptions(soRes.data);
    if (rsRes.data) {
      setHealthySigns(rsRes.data.filter((s: RelationshipSign) => s.sign_type === 'healthy'));
      setWarningSigns(rsRes.data.filter((s: RelationshipSign) => s.sign_type === 'warning'));
    }
    if (rrRes.data) setRights(rrRes.data);
    if (stiRes.data) setStis(stiRes.data);
    if (fRes.data) setFacts(fRes.data);
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

  async function saveItem(table: string, payload: any, id?: string) {
    if (id) {
      await supabaseAdmin.from(table).update(payload).eq('id', id);
    } else {
      await supabaseAdmin.from(table).insert(payload);
    }
    fetchAll();
    setShowAdd(false);
    setEditItem(null);
    setFormData({});
  }

  function resetForm() { setShowAdd(false); setEditItem(null); setFormData({}); }

  if (loading) {
    return <div className="p-8"><div className="animate-pulse h-64 bg-gray-200 rounded"></div></div>;
  }

  const tabs = [
    { id: 'consent' as const, label: 'Consent', count: principles.length + scenarios.length, icon: '🤝' },
    { id: 'relationships' as const, label: 'Relationships', count: healthySigns.length + warningSigns.length + rights.length, icon: '❤️' },
    { id: 'sti' as const, label: 'STI Awareness', count: stis.length, icon: '🛡️' },
    { id: 'facts' as const, label: 'Key Facts', count: facts.length, icon: '💡' },
  ];

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <Link href="/admin/content-manager" className="text-cyan-600 hover:text-cyan-800 text-sm">← Back to Content Manager</Link>
      </div>

      <div className="mb-8">
        <div className="flex items-center gap-3 mb-2">
          <span className="text-3xl">💜</span>
          <h1 className="text-3xl font-bold text-gray-900">Sex Education</h1>
        </div>
        <p className="text-gray-600">Manage consent scenarios, relationship guidance, STI info, and key facts.</p>
      </div>

      <div className="flex gap-2 mb-6 flex-wrap">
        {tabs.map(t => (
          <button key={t.id} onClick={() => { setActiveTab(t.id); resetForm(); }}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition ${activeTab === t.id ? 'bg-purple-600 text-white' : 'bg-white text-gray-600 border hover:bg-gray-50'}`}>
            {t.icon} {t.label} ({t.count})
          </button>
        ))}
      </div>

      {/* CONSENT TAB */}
      {activeTab === 'consent' && (
        <div className="space-y-8">
          {/* Principles */}
          <section>
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-semibold">FRIES Principles ({principles.length})</h2>
              <button onClick={() => { setShowAdd(true); setFormData({ _type: 'principle', letter: '', word: '', description: '', colour: '#A78BFA' }); }}
                className="bg-purple-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add</button>
            </div>
            {showAdd && formData._type === 'principle' && (
              <div className="bg-white border rounded-xl p-4 mb-4 space-y-3">
                <div className="grid grid-cols-3 gap-3">
                  <input placeholder="Letter (e.g. F)" value={formData.letter} onChange={e => setFormData({...formData, letter: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                  <input placeholder="Word (e.g. Freely given)" value={formData.word} onChange={e => setFormData({...formData, word: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                  <input placeholder="Colour" value={formData.colour} onChange={e => setFormData({...formData, colour: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                </div>
                <textarea placeholder="Description" value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" rows={2} />
                <div className="flex gap-2">
                  <button onClick={() => saveItem('sex_ed_consent_principles', { letter: formData.letter, word: formData.word, description: formData.description, colour: formData.colour, sort_order: principles.length })} className="bg-purple-600 text-white px-4 py-2 rounded text-sm">Save</button>
                  <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
                </div>
              </div>
            )}
            <div className="space-y-2">
              {principles.map(p => (
                <div key={p.id} className={`bg-white border rounded-lg p-3 flex justify-between items-center ${!p.is_active ? 'opacity-50' : ''}`}>
                  <div className="flex items-center gap-3">
                    <span className="text-xl font-bold" style={{color: p.colour}}>{p.letter}</span>
                    <div><span className="font-medium">{p.word}</span> — <span className="text-sm text-gray-500">{p.description}</span></div>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => toggleActive('sex_ed_consent_principles', p.id, p.is_active)} className="text-xs text-gray-500 hover:underline">{p.is_active ? 'Disable' : 'Enable'}</button>
                    <button onClick={() => deleteItem('sex_ed_consent_principles', p.id, p.word)} className="text-xs text-red-500 hover:underline">Delete</button>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* Scenarios */}
          <section>
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-semibold">Consent Scenarios ({scenarios.length})</h2>
              <button onClick={() => { setShowAdd(true); setFormData({ _type: 'scenario', scenario: '', question: '', explanation: '', correct_option_id: '', options: '' }); }}
                className="bg-purple-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add</button>
            </div>
            {showAdd && formData._type === 'scenario' && (
              <div className="bg-white border rounded-xl p-4 mb-4 space-y-3">
                <textarea placeholder="Scenario description" value={formData.scenario} onChange={e => setFormData({...formData, scenario: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" rows={3} />
                <input placeholder="Question (e.g. 'Can Sam give consent?')" value={formData.question} onChange={e => setFormData({...formData, question: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
                <textarea placeholder="Options (one per line, format: id|text)" value={formData.options} onChange={e => setFormData({...formData, options: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" rows={3} />
                <input placeholder="Correct option ID" value={formData.correct_option_id} onChange={e => setFormData({...formData, correct_option_id: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
                <textarea placeholder="Explanation" value={formData.explanation} onChange={e => setFormData({...formData, explanation: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" rows={2} />
                <div className="flex gap-2">
                  <button onClick={async () => {
                    const { data } = await supabaseAdmin.from('sex_ed_consent_scenarios').insert({
                      scenario: formData.scenario, question: formData.question, correct_option_id: formData.correct_option_id,
                      explanation: formData.explanation, sort_order: scenarios.length,
                    }).select().single();
                    if (data) {
                      const opts = formData.options.split('\n').filter((l: string) => l.includes('|')).map((l: string, i: number) => {
                        const [oid, text] = l.split('|');
                        return { scenario_id: data.id, option_id: oid.trim(), text: text.trim(), sort_order: i };
                      });
                      if (opts.length) await supabaseAdmin.from('sex_ed_scenario_options').insert(opts);
                    }
                    fetchAll(); resetForm();
                  }} className="bg-purple-600 text-white px-4 py-2 rounded text-sm">Save</button>
                  <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
                </div>
              </div>
            )}
            <div className="space-y-3">
              {scenarios.map((s, i) => (
                <div key={s.id} className={`bg-white border rounded-xl p-4 ${!s.is_active ? 'opacity-50' : ''}`}>
                  <div className="flex justify-between">
                    <span className="text-xs text-gray-400">Scenario {i + 1}</span>
                    <div className="flex gap-2">
                      <button onClick={() => toggleActive('sex_ed_consent_scenarios', s.id, s.is_active)} className="text-xs text-gray-500 hover:underline">{s.is_active ? 'Disable' : 'Enable'}</button>
                      <button onClick={() => deleteItem('sex_ed_consent_scenarios', s.id, s.scenario.slice(0, 30))} className="text-xs text-red-500 hover:underline">Delete</button>
                    </div>
                  </div>
                  <p className="text-sm text-gray-900 mt-1">{s.scenario}</p>
                  <p className="text-sm font-medium text-purple-700 mt-1">{s.question}</p>
                  <div className="mt-2 space-y-1">
                    {scenarioOptions.filter(o => o.scenario_id === s.id).map(o => (
                      <div key={o.id} className={`text-xs px-2 py-1 rounded ${o.option_id === s.correct_option_id ? 'bg-green-50 text-green-700 font-medium' : 'bg-gray-50 text-gray-600'}`}>
                        [{o.option_id}] {o.text} {o.option_id === s.correct_option_id && '✓'}
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </section>
        </div>
      )}

      {/* RELATIONSHIPS TAB */}
      {activeTab === 'relationships' && (
        <div className="space-y-8">
          {/* Healthy Signs */}
          <section>
            <div className="flex justify-between items-center mb-3">
              <h2 className="text-lg font-semibold">✅ Healthy Signs ({healthySigns.length})</h2>
              <button onClick={() => { setShowAdd(true); setFormData({ _type: 'sign', sign_type: 'healthy', text: '' }); }}
                className="bg-green-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add</button>
            </div>
            {showAdd && formData._type === 'sign' && formData.sign_type === 'healthy' && (
              <div className="bg-white border rounded-xl p-4 mb-3 flex gap-2">
                <input placeholder="Healthy sign text" value={formData.text} onChange={e => setFormData({...formData, text: e.target.value})} className="border rounded px-3 py-2 text-sm flex-1" />
                <button onClick={() => saveItem('sex_ed_relationship_signs', { sign_type: 'healthy', text: formData.text, sort_order: healthySigns.length })} className="bg-green-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            )}
            {healthySigns.map(s => (
              <div key={s.id} className="bg-white border rounded-lg p-3 mb-2 flex justify-between items-center">
                <span className="text-sm">✅ {s.text}</span>
                <button onClick={() => deleteItem('sex_ed_relationship_signs', s.id, s.text)} className="text-xs text-red-500 hover:underline">Delete</button>
              </div>
            ))}
          </section>

          {/* Warning Signs */}
          <section>
            <div className="flex justify-between items-center mb-3">
              <h2 className="text-lg font-semibold">🚩 Warning Signs ({warningSigns.length})</h2>
              <button onClick={() => { setShowAdd(true); setFormData({ _type: 'sign', sign_type: 'warning', text: '' }); }}
                className="bg-red-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add</button>
            </div>
            {showAdd && formData._type === 'sign' && formData.sign_type === 'warning' && (
              <div className="bg-white border rounded-xl p-4 mb-3 flex gap-2">
                <input placeholder="Warning sign text" value={formData.text} onChange={e => setFormData({...formData, text: e.target.value})} className="border rounded px-3 py-2 text-sm flex-1" />
                <button onClick={() => saveItem('sex_ed_relationship_signs', { sign_type: 'warning', text: formData.text, sort_order: warningSigns.length })} className="bg-red-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            )}
            {warningSigns.map(s => (
              <div key={s.id} className="bg-white border rounded-lg p-3 mb-2 flex justify-between items-center">
                <span className="text-sm">🚩 {s.text}</span>
                <button onClick={() => deleteItem('sex_ed_relationship_signs', s.id, s.text)} className="text-xs text-red-500 hover:underline">Delete</button>
              </div>
            ))}
          </section>

          {/* Rights */}
          <section>
            <div className="flex justify-between items-center mb-3">
              <h2 className="text-lg font-semibold">🛡️ Your Rights ({rights.length})</h2>
              <button onClick={() => { setShowAdd(true); setFormData({ _type: 'right', text: '' }); }}
                className="bg-purple-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add</button>
            </div>
            {showAdd && formData._type === 'right' && (
              <div className="bg-white border rounded-xl p-4 mb-3 flex gap-2">
                <input placeholder="Right text" value={formData.text} onChange={e => setFormData({...formData, text: e.target.value})} className="border rounded px-3 py-2 text-sm flex-1" />
                <button onClick={() => saveItem('sex_ed_relationship_rights', { text: formData.text, sort_order: rights.length })} className="bg-purple-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            )}
            {rights.map(r => (
              <div key={r.id} className="bg-white border rounded-lg p-3 mb-2 flex justify-between items-center">
                <span className="text-sm">✓ {r.text}</span>
                <button onClick={() => deleteItem('sex_ed_relationship_rights', r.id, r.text)} className="text-xs text-red-500 hover:underline">Delete</button>
              </div>
            ))}
          </section>
        </div>
      )}

      {/* STI TAB */}
      {activeTab === 'sti' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">🛡️ STI Information ({stis.length})</h2>
            <button onClick={() => { setShowAdd(true); setFormData({ _type: 'sti', name: '', description: '', symptoms: '', treatment: '', prevention: '', treatable: true }); }}
              className="bg-emerald-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add STI</button>
          </div>
          {showAdd && formData._type === 'sti' && (
            <div className="bg-white border rounded-xl p-4 mb-4 space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <input placeholder="Name" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={formData.treatable} onChange={e => setFormData({...formData, treatable: e.target.checked})} /> Treatable (vs Manageable)</label>
              </div>
              <textarea placeholder="Description" rows={2} value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <textarea placeholder="Symptoms" rows={2} value={formData.symptoms} onChange={e => setFormData({...formData, symptoms: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <textarea placeholder="Treatment" rows={2} value={formData.treatment} onChange={e => setFormData({...formData, treatment: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <textarea placeholder="Prevention" rows={2} value={formData.prevention} onChange={e => setFormData({...formData, prevention: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <div className="flex gap-2">
                <button onClick={() => saveItem('sex_ed_sti_info', { name: formData.name, description: formData.description, symptoms: formData.symptoms, treatment: formData.treatment, prevention: formData.prevention, treatable: formData.treatable, sort_order: stis.length })} className="bg-emerald-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            </div>
          )}
          <div className="space-y-3">
            {stis.map(s => (
              <div key={s.id} className={`bg-white border rounded-xl p-4 ${!s.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between items-start">
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="font-semibold">{s.name}</h3>
                      <span className={`text-xs px-2 py-0.5 rounded ${s.treatable ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'}`}>{s.treatable ? 'Treatable' : 'Manageable'}</span>
                    </div>
                    <p className="text-sm text-gray-600 mt-1">{s.description}</p>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => toggleActive('sex_ed_sti_info', s.id, s.is_active)} className="text-xs text-gray-500 hover:underline">{s.is_active ? 'Disable' : 'Enable'}</button>
                    <button onClick={() => deleteItem('sex_ed_sti_info', s.id, s.name)} className="text-xs text-red-500 hover:underline">Delete</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* KEY FACTS TAB */}
      {activeTab === 'facts' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">💡 Key Facts ({facts.length})</h2>
            <button onClick={() => { setShowAdd(true); setFormData({ _type: 'fact', title: '', subtitle: '', content: '', icon: 'lightbulb', colour: '#FBBF24' }); }}
              className="bg-amber-600 text-white px-3 py-1.5 rounded-lg text-sm">+ Add Fact</button>
          </div>
          {showAdd && formData._type === 'fact' && (
            <div className="bg-white border rounded-xl p-4 mb-4 space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <input placeholder="Title" value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Subtitle" value={formData.subtitle} onChange={e => setFormData({...formData, subtitle: e.target.value})} className="border rounded px-3 py-2 text-sm" />
              </div>
              <textarea placeholder="Content" rows={6} value={formData.content} onChange={e => setFormData({...formData, content: e.target.value})} className="border rounded px-3 py-2 text-sm w-full" />
              <div className="grid grid-cols-2 gap-3">
                <input placeholder="Icon name" value={formData.icon} onChange={e => setFormData({...formData, icon: e.target.value})} className="border rounded px-3 py-2 text-sm" />
                <input placeholder="Colour (#hex)" value={formData.colour} onChange={e => setFormData({...formData, colour: e.target.value})} className="border rounded px-3 py-2 text-sm" />
              </div>
              <div className="flex gap-2">
                <button onClick={() => saveItem('sex_ed_key_facts', { title: formData.title, subtitle: formData.subtitle, content: formData.content, icon: formData.icon, colour: formData.colour, sort_order: facts.length })} className="bg-amber-600 text-white px-4 py-2 rounded text-sm">Save</button>
                <button onClick={resetForm} className="bg-gray-200 px-4 py-2 rounded text-sm">Cancel</button>
              </div>
            </div>
          )}
          <div className="space-y-3">
            {facts.map(f => (
              <div key={f.id} className={`bg-white border rounded-xl p-4 ${!f.is_active ? 'opacity-50' : ''}`}>
                <div className="flex justify-between items-start">
                  <div>
                    <h3 className="font-semibold">{f.title}</h3>
                    <p className="text-sm text-gray-500">{f.subtitle}</p>
                    <p className="text-sm text-gray-600 mt-1 line-clamp-2">{f.content}</p>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => toggleActive('sex_ed_key_facts', f.id, f.is_active)} className="text-xs text-gray-500 hover:underline">{f.is_active ? 'Disable' : 'Enable'}</button>
                    <button onClick={() => deleteItem('sex_ed_key_facts', f.id, f.title)} className="text-xs text-red-500 hover:underline">Delete</button>
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
