'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

/* ─── Types ─────────────────────────────────────────────── */

interface Phase {
  id: string; name: string; timing: string; colour: string;
  feelings_label: string; feelings: string; tips_label: string; tips: string;
  sort_order: number; is_active: boolean;
}
interface Tip {
  id: string; title: string; subtitle: string; emoji: string; colour: string;
  content: string; sort_order: number; is_active: boolean;
}
interface Topic {
  id: string; title: string; subtitle: string; emoji: string; colour: string;
  content: string; sort_order: number; is_active: boolean;
}
interface Strategy {
  id: string; title: string; subtitle: string; emoji: string; colour: string;
  content: string; sort_order: number; is_active: boolean;
}
interface Affirmation {
  id: string; text: string; sort_order: number; is_active: boolean;
}
interface AgeGroup {
  id: string; title: string; subtitle: string; emoji: string; colour: string;
  content: string; sort_order: number; is_active: boolean;
}
interface ChildTip {
  id: string; tip: string; sort_order: number; is_active: boolean;
}
interface HelpSign {
  id: string; sign: string; sort_order: number; is_active: boolean;
}
interface SupportOrg {
  id: string; name: string; description: string; access: string;
  sort_order: number; is_active: boolean;
}

type Tab = 'phases' | 'tips' | 'understand' | 'selfcare' | 'affirmations' | 'children' | 'childtips' | 'helpsigns' | 'orgs';

const TABS: { key: Tab; label: string; emoji: string }[] = [
  { key: 'phases',       label: 'Deployment Phases', emoji: '📅' },
  { key: 'tips',         label: 'Deployment Tips',   emoji: '📋' },
  { key: 'understand',   label: 'Understand',        emoji: '🎖️' },
  { key: 'selfcare',     label: 'Self-Care',         emoji: '💜' },
  { key: 'affirmations', label: 'Affirmations',      emoji: '💪' },
  { key: 'children',     label: 'Children Ages',     emoji: '👶' },
  { key: 'childtips',    label: 'Children Tips',     emoji: '💡' },
  { key: 'helpsigns',    label: 'Help Signs',        emoji: '⚠️' },
  { key: 'orgs',         label: 'Support Orgs',      emoji: '🏥' },
];

/* ─── Page ──────────────────────────────────────────────── */

export default function ServiceFamilyPage() {
  const [tab, setTab] = useState<Tab>('phases');
  const [loading, setLoading] = useState(true);

  // Data arrays
  const [phases, setPhases]           = useState<Phase[]>([]);
  const [tips, setTips]               = useState<Tip[]>([]);
  const [topics, setTopics]           = useState<Topic[]>([]);
  const [strategies, setStrategies]   = useState<Strategy[]>([]);
  const [affirmations, setAffirmations] = useState<Affirmation[]>([]);
  const [ageGroups, setAgeGroups]     = useState<AgeGroup[]>([]);
  const [childTips, setChildTips]     = useState<ChildTip[]>([]);
  const [helpSigns, setHelpSigns]     = useState<HelpSign[]>([]);
  const [orgs, setOrgs]               = useState<SupportOrg[]>([]);

  // Add forms
  const [showAdd, setShowAdd] = useState(false);

  // Generic new item state
  const emptyPhase   = { name: '', timing: '', colour: '#60A5FA', feelings_label: 'Common feelings:', feelings: '', tips_label: 'What helps:', tips: '' };
  const emptyTip     = { title: '', subtitle: '', emoji: '📋', colour: '#60A5FA', content: '' };
  const emptyTopic   = { title: '', subtitle: '', emoji: '🎖️', colour: '#FBBF24', content: '' };
  const emptyStrat   = { title: '', subtitle: '', emoji: '💜', colour: '#E879A0', content: '' };
  const emptyAff     = { text: '' };
  const emptyAge     = { title: '', subtitle: '', emoji: '👶', colour: '#60A5FA', content: '' };
  const emptyChildT  = { tip: '' };
  const emptySign    = { sign: '' };
  const emptyOrg     = { name: '', description: '', access: '' };

  const [newPhase, setNewPhase]     = useState(emptyPhase);
  const [newTip, setNewTip]         = useState(emptyTip);
  const [newTopic, setNewTopic]     = useState(emptyTopic);
  const [newStrat, setNewStrat]     = useState(emptyStrat);
  const [newAff, setNewAff]         = useState(emptyAff);
  const [newAge, setNewAge]         = useState(emptyAge);
  const [newChildT, setNewChildT]   = useState(emptyChildT);
  const [newSign, setNewSign]       = useState(emptySign);
  const [newOrg, setNewOrg]         = useState(emptyOrg);

  // Editing
  const [editingId, setEditingId] = useState<string | null>(null);

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [r1, r2, r3, r4, r5, r6, r7, r8, r9] = await Promise.all([
      supabaseAdmin.from('service_family_deployment_phases').select('*').order('sort_order'),
      supabaseAdmin.from('service_family_deployment_tips').select('*').order('sort_order'),
      supabaseAdmin.from('service_family_understand_topics').select('*').order('sort_order'),
      supabaseAdmin.from('service_family_selfcare_strategies').select('*').order('sort_order'),
      supabaseAdmin.from('service_family_affirmations').select('*').order('sort_order'),
      supabaseAdmin.from('service_family_children_age_groups').select('*').order('sort_order'),
      supabaseAdmin.from('service_family_children_tips').select('*').order('sort_order'),
      supabaseAdmin.from('service_family_help_signs').select('*').order('sort_order'),
      supabaseAdmin.from('service_family_support_orgs').select('*').order('sort_order'),
    ]);
    if (r1.data) setPhases(r1.data);
    if (r2.data) setTips(r2.data);
    if (r3.data) setTopics(r3.data);
    if (r4.data) setStrategies(r4.data);
    if (r5.data) setAffirmations(r5.data);
    if (r6.data) setAgeGroups(r6.data);
    if (r7.data) setChildTips(r7.data);
    if (r8.data) setHelpSigns(r8.data);
    if (r9.data) setOrgs(r9.data);
    setLoading(false);
  }

  /* ── CRUD helpers ────────────────────────────────────── */

  async function addItem(table: string, data: Record<string, unknown>) {
    const count = currentItems().length;
    await supabaseAdmin.from(table).insert({ ...data, sort_order: count });
    await fetchAll();
    setShowAdd(false);
  }

  async function deleteItem(table: string, id: string) {
    await supabaseAdmin.from(table).delete().eq('id', id);
    await fetchAll();
  }

  async function toggleActive(table: string, id: string, current: boolean) {
    await supabaseAdmin.from(table).update({ is_active: !current }).eq('id', id);
    await fetchAll();
  }

  async function saveEdit(table: string, id: string, data: Record<string, unknown>) {
    await supabaseAdmin.from(table).update({ ...data, updated_at: new Date().toISOString() }).eq('id', id);
    setEditingId(null);
    await fetchAll();
  }

  /* ── Helpers ──────────────────────────────────────────── */

  function currentTable(): string {
    const map: Record<Tab, string> = {
      phases: 'service_family_deployment_phases',
      tips: 'service_family_deployment_tips',
      understand: 'service_family_understand_topics',
      selfcare: 'service_family_selfcare_strategies',
      affirmations: 'service_family_affirmations',
      children: 'service_family_children_age_groups',
      childtips: 'service_family_children_tips',
      helpsigns: 'service_family_help_signs',
      orgs: 'service_family_support_orgs',
    };
    return map[tab];
  }

  function currentItems(): { id: string; is_active: boolean }[] {
    const map: Record<Tab, unknown[]> = {
      phases, tips, understand: topics, selfcare: strategies,
      affirmations, children: ageGroups, childtips: childTips,
      helpsigns: helpSigns, orgs,
    };
    return map[tab] as { id: string; is_active: boolean }[];
  }

  /* ── Render ──────────────────────────────────────────── */

  if (loading) return (
    <div className="p-8">
      <div className="animate-pulse space-y-4">
        <div className="h-8 bg-gray-200 rounded w-1/4"></div>
        <div className="grid grid-cols-1 gap-4">{[...Array(6)].map((_, i) => <div key={i} className="h-16 bg-gray-200 rounded-xl"></div>)}</div>
      </div>
    </div>
  );

  return (
    <div className="p-8 max-w-6xl mx-auto">
      {/* Header */}
      <div className="mb-6 flex items-center gap-4">
        <Link href="/admin/content-manager" className="text-gray-400 hover:text-gray-600 transition">← Back</Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">👨‍👩‍👧‍👦 Service Family Content</h1>
          <p className="text-gray-500 text-sm">Manage all Service Family module content</p>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex flex-wrap gap-2 mb-6">
        {TABS.map(t => (
          <button key={t.key} onClick={() => { setTab(t.key); setShowAdd(false); setEditingId(null); }}
            className={`px-3 py-1.5 rounded-full text-sm font-medium transition ${tab === t.key ? 'bg-cyan-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}`}>
            {t.emoji} {t.label}
          </button>
        ))}
      </div>

      {/* Add button */}
      <div className="mb-4 flex justify-between items-center">
        <span className="text-sm text-gray-500">{currentItems().length} items</span>
        <button onClick={() => setShowAdd(!showAdd)} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700 transition">
          {showAdd ? 'Cancel' : '+ Add'}
        </button>
      </div>

      {/* Add form */}
      {showAdd && renderAddForm()}

      {/* Items list */}
      <div className="space-y-3">
        {renderItems()}
      </div>
    </div>
  );

  /* ── ADD FORMS ──────────────────────────────────────── */

  function renderAddForm() {
    switch (tab) {
      case 'phases': return (
        <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
          <input className="w-full border rounded-lg p-2 text-sm" placeholder="Phase name" value={newPhase.name} onChange={e => setNewPhase({ ...newPhase, name: e.target.value })} />
          <input className="w-full border rounded-lg p-2 text-sm" placeholder="Timing (e.g. 4-6 weeks before)" value={newPhase.timing} onChange={e => setNewPhase({ ...newPhase, timing: e.target.value })} />
          <input className="w-full border rounded-lg p-2 text-sm" placeholder="Colour hex" value={newPhase.colour} onChange={e => setNewPhase({ ...newPhase, colour: e.target.value })} />
          <textarea className="w-full border rounded-lg p-2 text-sm" rows={3} placeholder="Common feelings" value={newPhase.feelings} onChange={e => setNewPhase({ ...newPhase, feelings: e.target.value })} />
          <textarea className="w-full border rounded-lg p-2 text-sm" rows={3} placeholder="Tips / what helps" value={newPhase.tips} onChange={e => setNewPhase({ ...newPhase, tips: e.target.value })} />
          <button onClick={() => { addItem(currentTable(), newPhase); setNewPhase(emptyPhase); }} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
        </div>
      );
      case 'tips':
      case 'understand':
      case 'selfcare':
      case 'children': {
        const cur = tab === 'tips' ? newTip : tab === 'understand' ? newTopic : tab === 'selfcare' ? newStrat : newAge;
        const setCur = tab === 'tips' ? setNewTip : tab === 'understand' ? setNewTopic : tab === 'selfcare' ? setNewStrat : setNewAge;
        const empty = tab === 'tips' ? emptyTip : tab === 'understand' ? emptyTopic : tab === 'selfcare' ? emptyStrat : emptyAge;
        return (
          <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
            <input className="w-full border rounded-lg p-2 text-sm" placeholder="Title" value={cur.title} onChange={e => setCur({ ...cur, title: e.target.value })} />
            <input className="w-full border rounded-lg p-2 text-sm" placeholder="Subtitle" value={cur.subtitle} onChange={e => setCur({ ...cur, subtitle: e.target.value })} />
            <div className="flex gap-2">
              <input className="w-20 border rounded-lg p-2 text-sm" placeholder="Emoji" value={cur.emoji} onChange={e => setCur({ ...cur, emoji: e.target.value })} />
              <input className="flex-1 border rounded-lg p-2 text-sm" placeholder="Colour hex" value={cur.colour} onChange={e => setCur({ ...cur, colour: e.target.value })} />
            </div>
            <textarea className="w-full border rounded-lg p-2 text-sm" rows={5} placeholder="Content" value={cur.content} onChange={e => setCur({ ...cur, content: e.target.value })} />
            <button onClick={() => { addItem(currentTable(), cur); setCur(empty); }} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
          </div>
        );
      }
      case 'affirmations': return (
        <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
          <input className="w-full border rounded-lg p-2 text-sm" placeholder="Affirmation text" value={newAff.text} onChange={e => setNewAff({ text: e.target.value })} />
          <button onClick={() => { addItem(currentTable(), newAff); setNewAff(emptyAff); }} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
        </div>
      );
      case 'childtips': return (
        <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
          <input className="w-full border rounded-lg p-2 text-sm" placeholder="Tip text" value={newChildT.tip} onChange={e => setNewChildT({ tip: e.target.value })} />
          <button onClick={() => { addItem(currentTable(), newChildT); setNewChildT(emptyChildT); }} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
        </div>
      );
      case 'helpsigns': return (
        <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
          <input className="w-full border rounded-lg p-2 text-sm" placeholder="Warning sign" value={newSign.sign} onChange={e => setNewSign({ sign: e.target.value })} />
          <button onClick={() => { addItem(currentTable(), newSign); setNewSign(emptySign); }} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
        </div>
      );
      case 'orgs': return (
        <div className="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4 space-y-3">
          <input className="w-full border rounded-lg p-2 text-sm" placeholder="Organisation name" value={newOrg.name} onChange={e => setNewOrg({ ...newOrg, name: e.target.value })} />
          <textarea className="w-full border rounded-lg p-2 text-sm" rows={2} placeholder="Description" value={newOrg.description} onChange={e => setNewOrg({ ...newOrg, description: e.target.value })} />
          <input className="w-full border rounded-lg p-2 text-sm" placeholder="How to access" value={newOrg.access} onChange={e => setNewOrg({ ...newOrg, access: e.target.value })} />
          <button onClick={() => { addItem(currentTable(), newOrg); setNewOrg(emptyOrg); }} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
        </div>
      );
    }
  }

  /* ── ITEMS RENDERING ──────────────────────────────────── */

  function renderItems() {
    const tbl = currentTable();
    switch (tab) {
      case 'phases': return phases.map(p => (
        <ItemCard key={p.id} id={p.id} active={p.is_active} table={tbl}
          title={p.name} subtitle={p.timing} badge={<span style={{ color: p.colour }}>●</span>}>
          <p className="text-xs text-gray-500 mt-1">{p.feelings.substring(0, 100)}…</p>
        </ItemCard>
      ));
      case 'tips': return tips.map(t => (
        <ItemCard key={t.id} id={t.id} active={t.is_active} table={tbl}
          title={`${t.emoji} ${t.title}`} subtitle={t.subtitle}>
          <p className="text-xs text-gray-500 mt-1">{t.content.substring(0, 100)}…</p>
        </ItemCard>
      ));
      case 'understand': return topics.map(t => (
        <ItemCard key={t.id} id={t.id} active={t.is_active} table={tbl}
          title={`${t.emoji} ${t.title}`} subtitle={t.subtitle}>
          <p className="text-xs text-gray-500 mt-1">{t.content.substring(0, 100)}…</p>
        </ItemCard>
      ));
      case 'selfcare': return strategies.map(s => (
        <ItemCard key={s.id} id={s.id} active={s.is_active} table={tbl}
          title={`${s.emoji} ${s.title}`} subtitle={s.subtitle}>
          <p className="text-xs text-gray-500 mt-1">{s.content.substring(0, 100)}…</p>
        </ItemCard>
      ));
      case 'affirmations': return affirmations.map(a => (
        <ItemCard key={a.id} id={a.id} active={a.is_active} table={tbl}
          title={`"${a.text}"`} subtitle="" />
      ));
      case 'children': return ageGroups.map(g => (
        <ItemCard key={g.id} id={g.id} active={g.is_active} table={tbl}
          title={`${g.emoji} ${g.title}`} subtitle={g.subtitle}>
          <p className="text-xs text-gray-500 mt-1">{g.content.substring(0, 100)}…</p>
        </ItemCard>
      ));
      case 'childtips': return childTips.map(t => (
        <ItemCard key={t.id} id={t.id} active={t.is_active} table={tbl}
          title={t.tip} subtitle="" />
      ));
      case 'helpsigns': return helpSigns.map(h => (
        <ItemCard key={h.id} id={h.id} active={h.is_active} table={tbl}
          title={h.sign} subtitle="" />
      ));
      case 'orgs': return orgs.map(o => (
        <ItemCard key={o.id} id={o.id} active={o.is_active} table={tbl}
          title={o.name} subtitle={o.access}>
          <p className="text-xs text-gray-500 mt-1">{o.description.substring(0, 100)}…</p>
        </ItemCard>
      ));
    }
  }

  /* ── Reusable card ────────────────────────────────────── */

  function ItemCard({ id, active, table, title, subtitle, badge, children }: {
    id: string; active: boolean; table: string;
    title: string; subtitle: string;
    badge?: React.ReactNode; children?: React.ReactNode;
  }) {
    return (
      <div className={`border rounded-xl p-4 flex items-start justify-between ${active ? 'bg-white border-gray-200' : 'bg-gray-50 border-gray-100 opacity-60'}`}>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            {badge}
            <span className="font-medium text-gray-900 text-sm truncate">{title}</span>
          </div>
          {subtitle && <p className="text-xs text-gray-500">{subtitle}</p>}
          {children}
        </div>
        <div className="flex items-center gap-2 ml-3 flex-shrink-0">
          <button onClick={() => toggleActive(table, id, active)} className={`px-2 py-1 rounded text-xs ${active ? 'bg-green-100 text-green-700' : 'bg-gray-200 text-gray-500'}`}>
            {active ? 'Active' : 'Hidden'}
          </button>
          <button onClick={() => { if (confirm('Delete this item?')) deleteItem(table, id); }}
            className="px-2 py-1 rounded text-xs bg-red-50 text-red-600 hover:bg-red-100 transition">
            Delete
          </button>
        </div>
      </div>
    );
  }
}
