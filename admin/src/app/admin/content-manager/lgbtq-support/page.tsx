'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';

interface TimelineEvent { id: string; year: string; event: string; detail: string; sort_order: number; }
interface Myth { id: string; myth: string; is_true: boolean; explanation: string; sort_order: number; }
interface Term { id: string; term: string; meaning: string; sort_order: number; }
interface AllyScenario { id: string; scenario: string; best_option: number; explanation: string; sort_order: number; options?: AllyOption[]; }
interface AllyOption { id: string; scenario_id: string; option_text: string; option_index: number; }
interface DeployRegion { id: string; region: string; color_hex: string; icon_name: string; countries: string; advice: string; sort_order: number; }
interface SupportOrg { id: string; name: string; description: string; contact: string; website: string; emoji: string; sort_order: number; }
interface Affirmation { id: string; text: string; sort_order: number; }

type Tab = 'timeline' | 'myths' | 'terms' | 'ally' | 'deploy' | 'support' | 'affirmations';

export default function LgbtqSupportEditorPage() {
  const [tab, setTab] = useState<Tab>('timeline');
  const [timeline, setTimeline] = useState<TimelineEvent[]>([]);
  const [myths, setMyths] = useState<Myth[]>([]);
  const [terms, setTerms] = useState<Term[]>([]);
  const [scenarios, setScenarios] = useState<AllyScenario[]>([]);
  const [regions, setRegions] = useState<DeployRegion[]>([]);
  const [orgs, setOrgs] = useState<SupportOrg[]>([]);
  const [affirmations, setAffirmations] = useState<Affirmation[]>([]);
  const [loading, setLoading] = useState(true);

  const [editTimeline, setEditTimeline] = useState<TimelineEvent | null>(null);
  const [editMyth, setEditMyth] = useState<Myth | null>(null);
  const [editTerm, setEditTerm] = useState<Term | null>(null);
  const [editScenario, setEditScenario] = useState<AllyScenario | null>(null);
  const [editRegion, setEditRegion] = useState<DeployRegion | null>(null);
  const [editOrg, setEditOrg] = useState<SupportOrg | null>(null);
  const [editAffirmation, setEditAffirmation] = useState<Affirmation | null>(null);

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [t, m, te, s, o, r, su, a] = await Promise.all([
      supabaseAdmin.from('lgbtq_timeline').select('*').order('sort_order'),
      supabaseAdmin.from('lgbtq_myths').select('*').order('sort_order'),
      supabaseAdmin.from('lgbtq_terms').select('*').order('sort_order'),
      supabaseAdmin.from('lgbtq_ally_scenarios').select('*').order('sort_order'),
      supabaseAdmin.from('lgbtq_ally_options').select('*').order('option_index'),
      supabaseAdmin.from('lgbtq_deploy_regions').select('*').order('sort_order'),
      supabaseAdmin.from('lgbtq_support_orgs').select('*').order('sort_order'),
      supabaseAdmin.from('lgbtq_affirmations').select('*').order('sort_order'),
    ]);
    setTimeline(t.data || []);
    setMyths(m.data || []);
    setTerms(te.data || []);
    const scenariosWithOpts = (s.data || []).map((sc: AllyScenario) => ({
      ...sc,
      options: (o.data || []).filter((opt: AllyOption) => opt.scenario_id === sc.id),
    }));
    setScenarios(scenariosWithOpts);
    setRegions(r.data || []);
    setOrgs(su.data || []);
    setAffirmations(a.data || []);
    setLoading(false);
  }

  // ── Timeline CRUD ──
  async function saveTimeline(item: TimelineEvent) {
    const payload = { year: item.year, event: item.event, detail: item.detail, sort_order: item.sort_order };
    if (item.id) await supabaseAdmin.from('lgbtq_timeline').update(payload).eq('id', item.id);
    else await supabaseAdmin.from('lgbtq_timeline').insert(payload);
    setEditTimeline(null); fetchAll();
  }
  async function deleteTimeline(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('lgbtq_timeline').delete().eq('id', id); fetchAll(); }

  // ── Myths CRUD ──
  async function saveMyth(item: Myth) {
    const payload = { myth: item.myth, is_true: item.is_true, explanation: item.explanation, sort_order: item.sort_order };
    if (item.id) await supabaseAdmin.from('lgbtq_myths').update(payload).eq('id', item.id);
    else await supabaseAdmin.from('lgbtq_myths').insert(payload);
    setEditMyth(null); fetchAll();
  }
  async function deleteMyth(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('lgbtq_myths').delete().eq('id', id); fetchAll(); }

  // ── Terms CRUD ──
  async function saveTerm(item: Term) {
    const payload = { term: item.term, meaning: item.meaning, sort_order: item.sort_order };
    if (item.id) await supabaseAdmin.from('lgbtq_terms').update(payload).eq('id', item.id);
    else await supabaseAdmin.from('lgbtq_terms').insert(payload);
    setEditTerm(null); fetchAll();
  }
  async function deleteTerm(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('lgbtq_terms').delete().eq('id', id); fetchAll(); }

  // ── Ally Scenarios CRUD ──
  async function saveScenario(item: AllyScenario) {
    const payload = { scenario: item.scenario, best_option: item.best_option, explanation: item.explanation, sort_order: item.sort_order };
    let scenarioId = item.id;
    if (item.id) {
      await supabaseAdmin.from('lgbtq_ally_scenarios').update(payload).eq('id', item.id);
      await supabaseAdmin.from('lgbtq_ally_options').delete().eq('scenario_id', item.id);
    } else {
      const { data } = await supabaseAdmin.from('lgbtq_ally_scenarios').insert(payload).select().single();
      scenarioId = data?.id;
    }
    if (scenarioId && item.options) {
      for (const opt of item.options) {
        await supabaseAdmin.from('lgbtq_ally_options').insert({ scenario_id: scenarioId, option_text: opt.option_text, option_index: opt.option_index });
      }
    }
    setEditScenario(null); fetchAll();
  }
  async function deleteScenario(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('lgbtq_ally_scenarios').delete().eq('id', id); fetchAll(); }

  // ── Deploy Regions CRUD ──
  async function saveRegion(item: DeployRegion) {
    const payload = { region: item.region, color_hex: item.color_hex, icon_name: item.icon_name, countries: item.countries, advice: item.advice, sort_order: item.sort_order };
    if (item.id) await supabaseAdmin.from('lgbtq_deploy_regions').update(payload).eq('id', item.id);
    else await supabaseAdmin.from('lgbtq_deploy_regions').insert(payload);
    setEditRegion(null); fetchAll();
  }
  async function deleteRegion(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('lgbtq_deploy_regions').delete().eq('id', id); fetchAll(); }

  // ── Support Orgs CRUD ──
  async function saveOrg(item: SupportOrg) {
    const payload = { name: item.name, description: item.description, contact: item.contact, website: item.website, emoji: item.emoji, sort_order: item.sort_order };
    if (item.id) await supabaseAdmin.from('lgbtq_support_orgs').update(payload).eq('id', item.id);
    else await supabaseAdmin.from('lgbtq_support_orgs').insert(payload);
    setEditOrg(null); fetchAll();
  }
  async function deleteOrg(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('lgbtq_support_orgs').delete().eq('id', id); fetchAll(); }

  // ── Affirmations CRUD ──
  async function saveAffirmation(item: Affirmation) {
    const payload = { text: item.text, sort_order: item.sort_order };
    if (item.id) await supabaseAdmin.from('lgbtq_affirmations').update(payload).eq('id', item.id);
    else await supabaseAdmin.from('lgbtq_affirmations').insert(payload);
    setEditAffirmation(null); fetchAll();
  }
  async function deleteAffirmation(id: string) { if (!confirm('Delete?')) return; await supabaseAdmin.from('lgbtq_affirmations').delete().eq('id', id); fetchAll(); }

  const tabs: { key: Tab; label: string }[] = [
    { key: 'timeline', label: 'Timeline' },
    { key: 'myths', label: 'Myths' },
    { key: 'terms', label: 'Terms' },
    { key: 'ally', label: 'Ally Scenarios' },
    { key: 'deploy', label: 'Deployment Safety' },
    { key: 'support', label: 'Support Orgs' },
    { key: 'affirmations', label: 'Affirmations' },
  ];

  if (loading) return <div className="p-8 text-center text-gray-500">Loading…</div>;

  return (
    <div className="max-w-5xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-2">LGBTQ+ Support Editor</h1>
      <p className="text-sm text-gray-500 mb-6">Manage all LGBTQ+ support content — synced to the mobile app.</p>

      <div className="flex gap-2 mb-6 flex-wrap">
        {tabs.map(t => (
          <button key={t.key} onClick={() => setTab(t.key)}
            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${tab === t.key ? 'bg-purple-100 text-purple-700' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
            {t.label}
          </button>
        ))}
      </div>

      {/* ── Timeline ── */}
      {tab === 'timeline' && (
        <Section title="Timeline Events" onAdd={() => setEditTimeline({ id: '', year: '', event: '', detail: '', sort_order: timeline.length + 1 })}>
          {timeline.map(item => (
            <Card key={item.id}>
              <div className="font-mono text-purple-600 font-bold">{item.year}</div>
              <div className="font-medium">{item.event}</div>
              <div className="text-sm text-gray-500 mt-1 line-clamp-2">{item.detail}</div>
              <CardActions onEdit={() => setEditTimeline(item)} onDelete={() => deleteTimeline(item.id)} />
            </Card>
          ))}
          {editTimeline && <TimelineForm item={editTimeline} onSave={saveTimeline} onCancel={() => setEditTimeline(null)} />}
        </Section>
      )}

      {/* ── Myths ── */}
      {tab === 'myths' && (
        <Section title="Myth Buster" onAdd={() => setEditMyth({ id: '', myth: '', is_true: false, explanation: '', sort_order: myths.length + 1 })}>
          {myths.map(item => (
            <Card key={item.id}>
              <div className="flex items-center gap-2">
                <span className={`text-xs font-bold px-2 py-0.5 rounded ${item.is_true ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>{item.is_true ? 'TRUE' : 'FALSE'}</span>
                <span className="font-medium">{item.myth}</span>
              </div>
              <div className="text-sm text-gray-500 mt-1 line-clamp-2">{item.explanation}</div>
              <CardActions onEdit={() => setEditMyth(item)} onDelete={() => deleteMyth(item.id)} />
            </Card>
          ))}
          {editMyth && <MythForm item={editMyth} onSave={saveMyth} onCancel={() => setEditMyth(null)} />}
        </Section>
      )}

      {/* ── Terms ── */}
      {tab === 'terms' && (
        <Section title="Terminology" onAdd={() => setEditTerm({ id: '', term: '', meaning: '', sort_order: terms.length + 1 })}>
          {terms.map(item => (
            <Card key={item.id}>
              <div className="font-bold text-purple-600">{item.term}</div>
              <div className="text-sm text-gray-500 mt-1">{item.meaning}</div>
              <CardActions onEdit={() => setEditTerm(item)} onDelete={() => deleteTerm(item.id)} />
            </Card>
          ))}
          {editTerm && <TermForm item={editTerm} onSave={saveTerm} onCancel={() => setEditTerm(null)} />}
        </Section>
      )}

      {/* ── Ally Scenarios ── */}
      {tab === 'ally' && (
        <Section title="Ally Scenarios" onAdd={() => setEditScenario({ id: '', scenario: '', best_option: 0, explanation: '', sort_order: scenarios.length + 1, options: [{ id: '', scenario_id: '', option_text: '', option_index: 0 }, { id: '', scenario_id: '', option_text: '', option_index: 1 }, { id: '', scenario_id: '', option_text: '', option_index: 2 }] })}>
          {scenarios.map(item => (
            <Card key={item.id}>
              <div className="font-medium">{item.scenario}</div>
              <div className="text-sm text-gray-500 mt-1">Best: option {item.best_option + 1} | {item.options?.length ?? 0} options</div>
              <CardActions onEdit={() => setEditScenario(item)} onDelete={() => deleteScenario(item.id)} />
            </Card>
          ))}
          {editScenario && <ScenarioForm item={editScenario} onSave={saveScenario} onCancel={() => setEditScenario(null)} />}
        </Section>
      )}

      {/* ── Deploy Regions ── */}
      {tab === 'deploy' && (
        <Section title="Deployment Safety Regions" onAdd={() => setEditRegion({ id: '', region: '', color_hex: '#E74C3C', icon_name: 'warning_rounded', countries: '', advice: '', sort_order: regions.length + 1 })}>
          {regions.map(item => (
            <Card key={item.id}>
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-full" style={{ backgroundColor: item.color_hex }} />
                <span className="font-medium">{item.region}</span>
              </div>
              <div className="text-sm text-gray-500 mt-1 line-clamp-2">{item.countries}</div>
              <CardActions onEdit={() => setEditRegion(item)} onDelete={() => deleteRegion(item.id)} />
            </Card>
          ))}
          {editRegion && <RegionForm item={editRegion} onSave={saveRegion} onCancel={() => setEditRegion(null)} />}
        </Section>
      )}

      {/* ── Support Orgs ── */}
      {tab === 'support' && (
        <Section title="Support Organisations" onAdd={() => setEditOrg({ id: '', name: '', description: '', contact: '', website: '', emoji: '💜', sort_order: orgs.length + 1 })}>
          {orgs.map(item => (
            <Card key={item.id}>
              <div className="flex items-center gap-2">
                <span className="text-xl">{item.emoji}</span>
                <span className="font-medium">{item.name}</span>
              </div>
              <div className="text-sm text-gray-500 mt-1">{item.contact} · {item.website}</div>
              <CardActions onEdit={() => setEditOrg(item)} onDelete={() => deleteOrg(item.id)} />
            </Card>
          ))}
          {editOrg && <OrgForm item={editOrg} onSave={saveOrg} onCancel={() => setEditOrg(null)} />}
        </Section>
      )}

      {/* ── Affirmations ── */}
      {tab === 'affirmations' && (
        <Section title="Affirmations" onAdd={() => setEditAffirmation({ id: '', text: '', sort_order: affirmations.length + 1 })}>
          {affirmations.map(item => (
            <Card key={item.id}>
              <div className="italic text-gray-700">&ldquo;{item.text}&rdquo;</div>
              <CardActions onEdit={() => setEditAffirmation(item)} onDelete={() => deleteAffirmation(item.id)} />
            </Card>
          ))}
          {editAffirmation && <AffirmationForm item={editAffirmation} onSave={saveAffirmation} onCancel={() => setEditAffirmation(null)} />}
        </Section>
      )}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// Shared components
// ═══════════════════════════════════════════════════════════════

function Section({ title, onAdd, children }: { title: string; onAdd: () => void; children: React.ReactNode }) {
  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold">{title}</h2>
        <button onClick={onAdd} className="bg-purple-600 text-white px-4 py-1.5 rounded-lg text-sm hover:bg-purple-700">+ Add</button>
      </div>
      <div className="space-y-3">{children}</div>
    </div>
  );
}

function Card({ children }: { children: React.ReactNode }) {
  return <div className="border rounded-xl p-4 bg-white">{children}</div>;
}

function CardActions({ onEdit, onDelete }: { onEdit: () => void; onDelete: () => void }) {
  return (
    <div className="flex gap-2 mt-3">
      <button onClick={onEdit} className="text-xs text-blue-600 hover:underline">Edit</button>
      <button onClick={onDelete} className="text-xs text-red-500 hover:underline">Delete</button>
    </div>
  );
}

function FormShell({ title, onSave, onCancel, children }: { title: string; onSave: () => void; onCancel: () => void; children: React.ReactNode }) {
  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl p-6 w-full max-w-lg max-h-[90vh] overflow-y-auto">
        <h3 className="font-bold text-lg mb-4">{title}</h3>
        {children}
        <div className="flex gap-3 mt-6">
          <button onClick={onSave} className="flex-1 bg-purple-600 text-white py-2 rounded-lg hover:bg-purple-700">Save</button>
          <button onClick={onCancel} className="flex-1 bg-gray-100 py-2 rounded-lg hover:bg-gray-200">Cancel</button>
        </div>
      </div>
    </div>
  );
}

function Input({ label, value, onChange, textarea }: { label: string; value: string; onChange: (v: string) => void; textarea?: boolean }) {
  const cls = "w-full border rounded-lg px-3 py-2 text-sm mt-1";
  return (
    <label className="block mb-3">
      <span className="text-sm font-medium text-gray-700">{label}</span>
      {textarea ? <textarea className={cls + ' h-24'} value={value} onChange={e => onChange(e.target.value)} /> : <input className={cls} value={value} onChange={e => onChange(e.target.value)} />}
    </label>
  );
}

function NumberInput({ label, value, onChange }: { label: string; value: number; onChange: (v: number) => void }) {
  return (
    <label className="block mb-3">
      <span className="text-sm font-medium text-gray-700">{label}</span>
      <input type="number" className="w-full border rounded-lg px-3 py-2 text-sm mt-1" value={value} onChange={e => onChange(Number(e.target.value))} />
    </label>
  );
}

// ═══════════════════════════════════════════════════════════════
// Forms
// ═══════════════════════════════════════════════════════════════

function TimelineForm({ item, onSave, onCancel }: { item: TimelineEvent; onSave: (i: TimelineEvent) => void; onCancel: () => void }) {
  const [local, setLocal] = useState(item);
  return (
    <FormShell title={item.id ? 'Edit Timeline Event' : 'New Timeline Event'} onSave={() => onSave(local)} onCancel={onCancel}>
      <Input label="Year" value={local.year} onChange={v => setLocal({ ...local, year: v })} />
      <Input label="Event" value={local.event} onChange={v => setLocal({ ...local, event: v })} />
      <Input label="Detail" value={local.detail} onChange={v => setLocal({ ...local, detail: v })} textarea />
      <NumberInput label="Sort Order" value={local.sort_order} onChange={v => setLocal({ ...local, sort_order: v })} />
    </FormShell>
  );
}

function MythForm({ item, onSave, onCancel }: { item: Myth; onSave: (i: Myth) => void; onCancel: () => void }) {
  const [local, setLocal] = useState(item);
  return (
    <FormShell title={item.id ? 'Edit Myth' : 'New Myth'} onSave={() => onSave(local)} onCancel={onCancel}>
      <Input label="Statement" value={local.myth} onChange={v => setLocal({ ...local, myth: v })} textarea />
      <label className="flex items-center gap-2 mb-3">
        <input type="checkbox" checked={local.is_true} onChange={e => setLocal({ ...local, is_true: e.target.checked })} />
        <span className="text-sm font-medium">This statement is TRUE</span>
      </label>
      <Input label="Explanation" value={local.explanation} onChange={v => setLocal({ ...local, explanation: v })} textarea />
      <NumberInput label="Sort Order" value={local.sort_order} onChange={v => setLocal({ ...local, sort_order: v })} />
    </FormShell>
  );
}

function TermForm({ item, onSave, onCancel }: { item: Term; onSave: (i: Term) => void; onCancel: () => void }) {
  const [local, setLocal] = useState(item);
  return (
    <FormShell title={item.id ? 'Edit Term' : 'New Term'} onSave={() => onSave(local)} onCancel={onCancel}>
      <Input label="Term" value={local.term} onChange={v => setLocal({ ...local, term: v })} />
      <Input label="Meaning" value={local.meaning} onChange={v => setLocal({ ...local, meaning: v })} textarea />
      <NumberInput label="Sort Order" value={local.sort_order} onChange={v => setLocal({ ...local, sort_order: v })} />
    </FormShell>
  );
}

function ScenarioForm({ item, onSave, onCancel }: { item: AllyScenario; onSave: (i: AllyScenario) => void; onCancel: () => void }) {
  const [local, setLocal] = useState(item);
  const opts = local.options || [];
  function updateOpt(idx: number, text: string) {
    const next = [...opts];
    next[idx] = { ...next[idx], option_text: text };
    setLocal({ ...local, options: next });
  }
  function addOpt() {
    setLocal({ ...local, options: [...opts, { id: '', scenario_id: '', option_text: '', option_index: opts.length }] });
  }
  return (
    <FormShell title={item.id ? 'Edit Scenario' : 'New Scenario'} onSave={() => onSave(local)} onCancel={onCancel}>
      <Input label="Scenario" value={local.scenario} onChange={v => setLocal({ ...local, scenario: v })} textarea />
      <NumberInput label="Best Option (0-indexed)" value={local.best_option} onChange={v => setLocal({ ...local, best_option: v })} />
      <Input label="Explanation" value={local.explanation} onChange={v => setLocal({ ...local, explanation: v })} textarea />
      <div className="mb-3">
        <span className="text-sm font-medium text-gray-700">Options</span>
        {opts.map((o, i) => (
          <div key={i} className="flex items-center gap-2 mt-1">
            <span className="text-xs text-gray-400 w-5">{i}</span>
            <input className="flex-1 border rounded-lg px-3 py-1.5 text-sm" value={o.option_text} onChange={e => updateOpt(i, e.target.value)} />
          </div>
        ))}
        <button onClick={addOpt} className="text-xs text-purple-600 mt-2 hover:underline">+ Add option</button>
      </div>
      <NumberInput label="Sort Order" value={local.sort_order} onChange={v => setLocal({ ...local, sort_order: v })} />
    </FormShell>
  );
}

function RegionForm({ item, onSave, onCancel }: { item: DeployRegion; onSave: (i: DeployRegion) => void; onCancel: () => void }) {
  const [local, setLocal] = useState(item);
  return (
    <FormShell title={item.id ? 'Edit Region' : 'New Region'} onSave={() => onSave(local)} onCancel={onCancel}>
      <Input label="Region Name" value={local.region} onChange={v => setLocal({ ...local, region: v })} />
      <div className="flex gap-3">
        <Input label="Color Hex" value={local.color_hex} onChange={v => setLocal({ ...local, color_hex: v })} />
        <Input label="Icon Name" value={local.icon_name} onChange={v => setLocal({ ...local, icon_name: v })} />
      </div>
      <Input label="Countries" value={local.countries} onChange={v => setLocal({ ...local, countries: v })} textarea />
      <Input label="Advice" value={local.advice} onChange={v => setLocal({ ...local, advice: v })} textarea />
      <NumberInput label="Sort Order" value={local.sort_order} onChange={v => setLocal({ ...local, sort_order: v })} />
    </FormShell>
  );
}

function OrgForm({ item, onSave, onCancel }: { item: SupportOrg; onSave: (i: SupportOrg) => void; onCancel: () => void }) {
  const [local, setLocal] = useState(item);
  return (
    <FormShell title={item.id ? 'Edit Organisation' : 'New Organisation'} onSave={() => onSave(local)} onCancel={onCancel}>
      <Input label="Name" value={local.name} onChange={v => setLocal({ ...local, name: v })} />
      <Input label="Description" value={local.description} onChange={v => setLocal({ ...local, description: v })} textarea />
      <div className="flex gap-3">
        <Input label="Contact" value={local.contact} onChange={v => setLocal({ ...local, contact: v })} />
        <Input label="Emoji" value={local.emoji} onChange={v => setLocal({ ...local, emoji: v })} />
      </div>
      <Input label="Website" value={local.website} onChange={v => setLocal({ ...local, website: v })} />
      <NumberInput label="Sort Order" value={local.sort_order} onChange={v => setLocal({ ...local, sort_order: v })} />
    </FormShell>
  );
}

function AffirmationForm({ item, onSave, onCancel }: { item: Affirmation; onSave: (i: Affirmation) => void; onCancel: () => void }) {
  const [local, setLocal] = useState(item);
  return (
    <FormShell title={item.id ? 'Edit Affirmation' : 'New Affirmation'} onSave={() => onSave(local)} onCancel={onCancel}>
      <Input label="Affirmation text" value={local.text} onChange={v => setLocal({ ...local, text: v })} textarea />
      <NumberInput label="Sort Order" value={local.sort_order} onChange={v => setLocal({ ...local, sort_order: v })} />
    </FormShell>
  );
}
