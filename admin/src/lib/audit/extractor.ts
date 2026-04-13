import { SupabaseClient } from '@supabase/supabase-js';
import { ExtractedContentArea, ExtractedContentItem } from './types';

interface AreaConfig {
  id: string;
  label: string;
  primary_table: string;
  extract: (supabase: SupabaseClient) => Promise<ExtractedContentItem[]>;
}

async function queryTable(
  supabase: SupabaseClient,
  table: string,
  select = '*',
  orderBy = 'created_at'
): Promise<Record<string, unknown>[]> {
  const { data, error } = await supabase
    .from(table)
    .select(select)
    .order(orderBy, { ascending: true });
  if (error) {
    console.error(`Failed to query ${table}:`, error.message);
    return [];
  }
  return data || [];
}

function toItems(
  rows: Record<string, unknown>[],
  area: string,
  table: string,
  labelField = 'title'
): ExtractedContentItem[] {
  return rows.map(row => ({
    id: String(row.id || ''),
    label: String(row[labelField] || row.name || row.text || row.label || `${table} item`),
    source_table: table,
    content_area: area,
    data: row,
  }));
}

function flattenHierarchy(
  parent: Record<string, unknown>,
  children: Record<string, unknown>[],
  childKey: string
): Record<string, unknown> {
  return { ...parent, [childKey]: children };
}

const AREA_CONFIGS: AreaConfig[] = [
  {
    id: 'navigate_content',
    label: 'Navigate Content',
    primary_table: 'content_items',
    extract: async (sb) => {
      const items = await queryTable(sb, 'content_items', '*, domains(slug, name, icon)');
      const details = await queryTable(sb, 'content_details');
      const detailMap = new Map(details.map(d => [String(d.content_item_id), d]));
      return items.map(item => ({
        id: String(item.id),
        label: String(item.label || ''),
        source_table: 'content_items',
        content_area: 'navigate_content',
        data: { ...item, details: detailMap.get(String(item.id)) || null },
      }));
    },
  },
  {
    id: 'learn_articles',
    label: 'Learn Articles',
    primary_table: 'learn_articles',
    extract: async (sb) => {
      const articles = await queryTable(sb, 'learn_articles');
      const content = await queryTable(sb, 'learn_article_content');
      const contentMap = new Map(content.map(c => [String(c.article_id), c]));
      return articles.map(a => ({
        id: String(a.id),
        label: String(a.title || ''),
        source_table: 'learn_articles',
        content_area: 'learn_articles',
        data: { ...a, content: contentMap.get(String(a.id)) || null },
      }));
    },
  },
  {
    id: 'user_type_screens',
    label: 'User Type Screens',
    primary_table: 'user_type_items',
    extract: async (sb) => {
      const items = await queryTable(sb, 'user_type_items');
      return toItems(items, 'user_type_screens', 'user_type_items');
    },
  },
  {
    id: 'mission_objectives',
    label: 'Mission Objectives',
    primary_table: 'mission_objectives',
    extract: async (sb) => {
      const rows = await queryTable(sb, 'mission_objectives');
      return toItems(rows, 'mission_objectives', 'mission_objectives', 'text');
    },
  },
  {
    id: 'mood_system',
    label: 'Mood System',
    primary_table: 'mood_reasons',
    extract: async (sb) => {
      const rows = await queryTable(sb, 'mood_reasons');
      return toItems(rows, 'mood_system', 'mood_reasons', 'text');
    },
  },
  {
    id: 'daily_brief',
    label: 'Daily Brief',
    primary_table: 'daily_brief_objectives',
    extract: async (sb) => {
      const rows = await queryTable(sb, 'daily_brief_objectives');
      return toItems(rows, 'daily_brief', 'daily_brief_objectives', 'text');
    },
  },
  {
    id: 'after_action_review',
    label: 'After Action Review',
    primary_table: 'aar_went_well_options',
    extract: async (sb) => {
      const well = await queryTable(sb, 'aar_went_well_options');
      const improve = await queryTable(sb, 'aar_improve_options');
      const takeaway = await queryTable(sb, 'aar_takeaway_options');
      return [
        ...toItems(well, 'after_action_review', 'aar_went_well_options', 'text'),
        ...toItems(improve, 'after_action_review', 'aar_improve_options', 'text'),
        ...toItems(takeaway, 'after_action_review', 'aar_takeaway_options', 'text'),
      ];
    },
  },
  {
    id: 'skills_translator',
    label: 'Skills Translator',
    primary_table: 'military_roles',
    extract: async (sb) => {
      const roles = await queryTable(sb, 'military_roles');
      const jobs = await queryTable(sb, 'civilian_jobs');
      return [
        ...toItems(roles, 'skills_translator', 'military_roles'),
        ...toItems(jobs, 'skills_translator', 'civilian_jobs'),
      ];
    },
  },
  {
    id: 'feelings_toolkit',
    label: 'Feelings Toolkit',
    primary_table: 'feelings',
    extract: async (sb) => {
      const feelings = await queryTable(sb, 'feelings');
      const tools = await queryTable(sb, 'coping_tools');
      const toolsByFeeling = new Map<string, Record<string, unknown>[]>();
      for (const t of tools) {
        const fid = String(t.feeling_id);
        if (!toolsByFeeling.has(fid)) toolsByFeeling.set(fid, []);
        toolsByFeeling.get(fid)!.push(t);
      }
      return feelings.map(f => ({
        id: String(f.id),
        label: String(f.name || ''),
        source_table: 'feelings',
        content_area: 'feelings_toolkit',
        data: flattenHierarchy(f, toolsByFeeling.get(String(f.id)) || [], 'coping_tools'),
      }));
    },
  },
  {
    id: 'quizzes',
    label: 'Quizzes',
    primary_table: 'quizzes',
    extract: async (sb) => {
      const quizzes = await queryTable(sb, 'quizzes');
      const questions = await queryTable(sb, 'quiz_questions');
      const options = await queryTable(sb, 'quiz_options');
      const optionsByQ = new Map<string, Record<string, unknown>[]>();
      for (const o of options) {
        const qid = String(o.question_id);
        if (!optionsByQ.has(qid)) optionsByQ.set(qid, []);
        optionsByQ.get(qid)!.push(o);
      }
      const qByQuiz = new Map<string, Record<string, unknown>[]>();
      for (const q of questions) {
        const quizId = String(q.quiz_id);
        if (!qByQuiz.has(quizId)) qByQuiz.set(quizId, []);
        qByQuiz.get(quizId)!.push({ ...q, options: optionsByQ.get(String(q.id)) || [] });
      }
      return quizzes.map(quiz => ({
        id: String(quiz.id),
        label: String(quiz.title || ''),
        source_table: 'quizzes',
        content_area: 'quizzes',
        data: flattenHierarchy(quiz, qByQuiz.get(String(quiz.id)) || [], 'questions'),
      }));
    },
  },
  {
    id: 'career_paths',
    label: 'Career Paths',
    primary_table: 'career_paths',
    extract: async (sb) => {
      const rows = await queryTable(sb, 'career_paths');
      return toItems(rows, 'career_paths', 'career_paths');
    },
  },
  {
    id: 'tip_cards',
    label: 'Tip Cards',
    primary_table: 'tip_categories',
    extract: async (sb) => {
      const cats = await queryTable(sb, 'tip_categories');
      const tips = await queryTable(sb, 'tips');
      const tipsByCat = new Map<string, Record<string, unknown>[]>();
      for (const t of tips) {
        const cid = String(t.category_id);
        if (!tipsByCat.has(cid)) tipsByCat.set(cid, []);
        tipsByCat.get(cid)!.push(t);
      }
      return cats.map(c => ({
        id: String(c.id),
        label: String(c.title || ''),
        source_table: 'tip_categories',
        content_area: 'tip_cards',
        data: flattenHierarchy(c, tipsByCat.get(String(c.id)) || [], 'tips'),
      }));
    },
  },
  {
    id: 'checklists',
    label: 'Checklists',
    primary_table: 'checklist_templates',
    extract: async (sb) => {
      const templates = await queryTable(sb, 'checklist_templates');
      const sections = await queryTable(sb, 'checklist_sections');
      const items = await queryTable(sb, 'checklist_items');
      const itemsBySec = new Map<string, Record<string, unknown>[]>();
      for (const i of items) {
        const sid = String(i.section_id);
        if (!itemsBySec.has(sid)) itemsBySec.set(sid, []);
        itemsBySec.get(sid)!.push(i);
      }
      const secByTemplate = new Map<string, Record<string, unknown>[]>();
      for (const s of sections) {
        const tid = String(s.template_id);
        if (!secByTemplate.has(tid)) secByTemplate.set(tid, []);
        secByTemplate.get(tid)!.push({ ...s, items: itemsBySec.get(String(s.id)) || [] });
      }
      return templates.map(t => ({
        id: String(t.id),
        label: String(t.title || ''),
        source_table: 'checklist_templates',
        content_area: 'checklists',
        data: flattenHierarchy(t, secByTemplate.get(String(t.id)) || [], 'sections'),
      }));
    },
  },
  {
    id: 'resources',
    label: 'Resources',
    primary_table: 'resource_categories',
    extract: async (sb) => {
      const cats = await queryTable(sb, 'resource_categories');
      const sections = await queryTable(sb, 'resource_sections');
      const resources = await queryTable(sb, 'resources');
      const resBySec = new Map<string, Record<string, unknown>[]>();
      for (const r of resources) {
        const sid = String(r.section_id);
        if (!resBySec.has(sid)) resBySec.set(sid, []);
        resBySec.get(sid)!.push(r);
      }
      const secByCat = new Map<string, Record<string, unknown>[]>();
      for (const s of sections) {
        const cid = String(s.category_id);
        if (!secByCat.has(cid)) secByCat.set(cid, []);
        secByCat.get(cid)!.push({ ...s, resources: resBySec.get(String(s.id)) || [] });
      }
      return cats.map(c => ({
        id: String(c.id),
        label: String(c.title || ''),
        source_table: 'resource_categories',
        content_area: 'resources',
        data: flattenHierarchy(c, secByCat.get(String(c.id)) || [], 'sections'),
      }));
    },
  },
  {
    id: 'learning_styles',
    label: 'Learning & Study',
    primary_table: 'learning_styles',
    extract: async (sb) => {
      const rows = await queryTable(sb, 'learning_styles');
      return toItems(rows, 'learning_styles', 'learning_styles', 'name');
    },
  },
  {
    id: 'affirmations',
    label: 'Affirmations',
    primary_table: 'affirmations',
    extract: async (sb) => {
      const rows = await queryTable(sb, 'affirmations');
      return toItems(rows, 'affirmations', 'affirmations', 'text');
    },
  },
  {
    id: 'interest_explorer',
    label: 'Interest Explorer',
    primary_table: 'interest_categories',
    extract: async (sb) => {
      const cats = await queryTable(sb, 'interest_categories');
      const activities = await queryTable(sb, 'interest_activities');
      const actByCat = new Map<string, Record<string, unknown>[]>();
      for (const a of activities) {
        const cid = String(a.category_id);
        if (!actByCat.has(cid)) actByCat.set(cid, []);
        actByCat.get(cid)!.push(a);
      }
      return cats.map(c => ({
        id: String(c.id),
        label: String(c.name || ''),
        source_table: 'interest_categories',
        content_area: 'interest_explorer',
        data: flattenHierarchy(c, actByCat.get(String(c.id)) || [], 'activities'),
      }));
    },
  },
  {
    id: 'harassment_wizard',
    label: 'Harassment Support Wizard',
    primary_table: 'harassment_wizard_steps',
    extract: async (sb) => {
      const steps = await queryTable(sb, 'harassment_wizard_steps');
      const options = await queryTable(sb, 'harassment_wizard_options');
      const guidance = await queryTable(sb, 'harassment_wizard_guidance');
      const contacts = await queryTable(sb, 'harassment_wizard_contacts');
      const optByStep = new Map<string, Record<string, unknown>[]>();
      for (const o of options) {
        const sid = String(o.step_id);
        if (!optByStep.has(sid)) optByStep.set(sid, []);
        optByStep.get(sid)!.push(o);
      }
      const allItems: ExtractedContentItem[] = steps.map(s => ({
        id: String(s.id),
        label: String(s.title || ''),
        source_table: 'harassment_wizard_steps',
        content_area: 'harassment_wizard',
        data: flattenHierarchy(s, optByStep.get(String(s.id)) || [], 'options'),
      }));
      for (const g of guidance) {
        allItems.push({
          id: String(g.id),
          label: String(g.title || 'Guidance'),
          source_table: 'harassment_wizard_guidance',
          content_area: 'harassment_wizard',
          data: g,
        });
      }
      for (const c of contacts) {
        allItems.push({
          id: String(c.id),
          label: String(c.name || 'Contact'),
          source_table: 'harassment_wizard_contacts',
          content_area: 'harassment_wizard',
          data: c,
        });
      }
      return allItems;
    },
  },
  {
    id: 'body_education',
    label: 'Body Education',
    primary_table: 'body_education_topics',
    extract: async (sb) => {
      const rows = await queryTable(sb, 'body_education_topics');
      return toItems(rows, 'body_education', 'body_education_topics');
    },
  },
  {
    id: 'sex_education',
    label: 'Sex Education',
    primary_table: 'sex_ed_consent_scenarios',
    extract: async (sb) => {
      const scenarios = await queryTable(sb, 'sex_ed_consent_scenarios');
      const options = await queryTable(sb, 'sex_ed_scenario_options');
      const optByScenario = new Map<string, Record<string, unknown>[]>();
      for (const o of options) {
        const sid = String(o.scenario_id);
        if (!optByScenario.has(sid)) optByScenario.set(sid, []);
        optByScenario.get(sid)!.push(o);
      }
      return scenarios.map(s => ({
        id: String(s.id),
        label: String(s.scenario || s.question || ''),
        source_table: 'sex_ed_consent_scenarios',
        content_area: 'sex_education',
        data: flattenHierarchy(s, optByScenario.get(String(s.id)) || [], 'options'),
      }));
    },
  },
  {
    id: 'bullying_support',
    label: 'Bullying Support',
    primary_table: 'bullying_guidance_cards',
    extract: async (sb) => {
      const rows = await queryTable(sb, 'bullying_guidance_cards');
      return toItems(rows, 'bullying_support', 'bullying_guidance_cards');
    },
  },
  {
    id: 'health_education',
    label: 'Health Tracker Education',
    primary_table: 'health_contraception_methods',
    extract: async (sb) => {
      const methods = await queryTable(sb, 'health_contraception_methods');
      return toItems(methods, 'health_education', 'health_contraception_methods', 'name');
    },
  },
  {
    id: 'service_family',
    label: 'Service Family',
    primary_table: 'service_family_deployment_phases',
    extract: async (sb) => {
      const rows = await queryTable(sb, 'service_family_deployment_phases');
      return toItems(rows, 'service_family', 'service_family_deployment_phases', 'name');
    },
  },
  {
    id: 'whats_new',
    label: "What's New",
    primary_table: 'whats_new_releases',
    extract: async (sb) => {
      const releases = await queryTable(sb, 'whats_new_releases');
      const items = await queryTable(sb, 'whats_new_items');
      const itemsByRelease = new Map<string, Record<string, unknown>[]>();
      for (const i of items) {
        const rid = String(i.release_id);
        if (!itemsByRelease.has(rid)) itemsByRelease.set(rid, []);
        itemsByRelease.get(rid)!.push(i);
      }
      return releases.map(r => ({
        id: String(r.id),
        label: String(r.title || r.version || ''),
        source_table: 'whats_new_releases',
        content_area: 'whats_new',
        data: flattenHierarchy(r, itemsByRelease.get(String(r.id)) || [], 'items'),
      }));
    },
  },
  {
    id: 'kindness',
    label: 'Learning to be Kind',
    primary_table: 'kindness_flip_cards',
    extract: async (sb) => {
      const cards = await queryTable(sb, 'kindness_flip_cards');
      const scenarios = await queryTable(sb, 'kindness_react_scenarios');
      return [
        ...toItems(cards, 'kindness', 'kindness_flip_cards', 'judgement'),
        ...toItems(scenarios, 'kindness', 'kindness_react_scenarios', 'scenario'),
      ];
    },
  },
  {
    id: 'service_culture',
    label: 'Service Culture (C2 Drill)',
    primary_table: 'culture_values',
    extract: async (sb) => {
      const values = await queryTable(sb, 'culture_values');
      const scenarios = await queryTable(sb, 'culture_scenarios');
      return [
        ...toItems(values, 'service_culture', 'culture_values', 'name'),
        ...toItems(scenarios, 'service_culture', 'culture_scenarios', 'scenario'),
      ];
    },
  },
  {
    id: 'military_perks',
    label: 'Military Perks',
    primary_table: 'perks_facts',
    extract: async (sb) => {
      const facts = await queryTable(sb, 'perks_facts');
      return toItems(facts, 'military_perks', 'perks_facts');
    },
  },
  {
    id: 'brain_science',
    label: 'Brain Science & Psychology',
    primary_table: 'brain_myths',
    extract: async (sb) => {
      const myths = await queryTable(sb, 'brain_myths');
      const biases = await queryTable(sb, 'brain_biases');
      const experiments = await queryTable(sb, 'brain_experiments');
      return [
        ...toItems(myths, 'brain_science', 'brain_myths', 'statement'),
        ...toItems(biases, 'brain_science', 'brain_biases', 'name'),
        ...toItems(experiments, 'brain_science', 'brain_experiments'),
      ];
    },
  },
  {
    id: 'donations',
    label: 'Donations',
    primary_table: 'donation_impacts',
    extract: async (sb) => {
      const rows = await queryTable(sb, 'donation_impacts');
      return toItems(rows, 'donations', 'donation_impacts', 'impact_text');
    },
  },
  {
    id: 'lgbtq_support',
    label: 'LGBTQ+ Support',
    primary_table: 'lgbtq_timeline',
    extract: async (sb) => {
      const timeline = await queryTable(sb, 'lgbtq_timeline');
      const myths = await queryTable(sb, 'lgbtq_myths');
      const terms = await queryTable(sb, 'lgbtq_terms');
      const allyScenarios = await queryTable(sb, 'lgbtq_ally_scenarios');
      const regions = await queryTable(sb, 'lgbtq_deploy_regions');
      const orgs = await queryTable(sb, 'lgbtq_support_orgs');
      const affirmations = await queryTable(sb, 'lgbtq_affirmations');
      return [
        ...toItems(timeline, 'lgbtq_support', 'lgbtq_timeline', 'event'),
        ...toItems(myths, 'lgbtq_support', 'lgbtq_myths', 'myth'),
        ...toItems(terms, 'lgbtq_support', 'lgbtq_terms', 'term'),
        ...toItems(allyScenarios, 'lgbtq_support', 'lgbtq_ally_scenarios', 'scenario'),
        ...toItems(regions, 'lgbtq_support', 'lgbtq_deploy_regions', 'region'),
        ...toItems(orgs, 'lgbtq_support', 'lgbtq_support_orgs', 'name'),
        ...toItems(affirmations, 'lgbtq_support', 'lgbtq_affirmations', 'text'),
      ];
    },
  },
  {
    id: 'scenarios_v2',
    label: 'Scenarios & Protocols',
    primary_table: 'scenarios',
    extract: async (sb) => {
      const scenarios = await queryTable(sb, 'scenarios');
      const options = await queryTable(sb, 'scenario_options');
      const protocols = await queryTable(sb, 'protocols');
      const optByScenario = new Map<string, Record<string, unknown>[]>();
      for (const o of options) {
        const sid = String(o.scenario_id);
        if (!optByScenario.has(sid)) optByScenario.set(sid, []);
        optByScenario.get(sid)!.push(o);
      }
      const scenarioItems = scenarios.map(s => ({
        id: String(s.id),
        label: String(s.title || ''),
        source_table: 'scenarios',
        content_area: 'scenarios_v2',
        data: flattenHierarchy(s, optByScenario.get(String(s.id)) || [], 'options'),
      }));
      const protocolItems = toItems(protocols, 'scenarios_v2', 'protocols');
      return [...scenarioItems, ...protocolItems];
    },
  },
  {
    id: 'rituals',
    label: 'Rituals',
    primary_table: 'ritual_topics',
    extract: async (sb) => {
      const topics = await queryTable(sb, 'ritual_topics');
      return toItems(topics, 'rituals', 'ritual_topics');
    },
  },
];

export { CONTENT_AREAS } from './areas';

export async function extractContentArea(
  supabase: SupabaseClient,
  areaId: string
): Promise<ExtractedContentArea | null> {
  const config = AREA_CONFIGS.find(a => a.id === areaId);
  if (!config) return null;

  const items = await config.extract(supabase);
  return {
    id: config.id,
    label: config.label,
    items,
  };
}

export async function extractAllContentAreas(
  supabase: SupabaseClient
): Promise<ExtractedContentArea[]> {
  const areas: ExtractedContentArea[] = [];
  for (const config of AREA_CONFIGS) {
    try {
      const items = await config.extract(supabase);
      areas.push({ id: config.id, label: config.label, items });
    } catch (err) {
      console.error(`Failed to extract ${config.id}:`, err);
      areas.push({ id: config.id, label: config.label, items: [] });
    }
  }
  return areas;
}

export function serializeContentAreaForReview(area: ExtractedContentArea): string {
  const lines: string[] = [
    `=== CONTENT AREA: ${area.label} (${area.id}) ===`,
    `Total items: ${area.items.length}`,
    '',
  ];

  for (const item of area.items) {
    lines.push(`--- ITEM: ${item.label} ---`);
    lines.push(`  ID: ${item.id}`);
    lines.push(`  Source table: ${item.source_table}`);
    lines.push(`  Data:`);
    lines.push(formatData(item.data, 4));
    lines.push('');
  }

  return lines.join('\n');
}

function formatData(data: Record<string, unknown>, indent: number): string {
  const pad = ' '.repeat(indent);
  const lines: string[] = [];

  for (const [key, value] of Object.entries(data)) {
    if (key === 'id' || key === 'created_at' || key === 'updated_at') continue;

    if (value === null || value === undefined) continue;

    if (Array.isArray(value)) {
      if (value.length === 0) continue;
      if (typeof value[0] === 'object') {
        lines.push(`${pad}${key}:`);
        for (const item of value) {
          lines.push(`${pad}  - ${JSON.stringify(item)}`);
        }
      } else {
        lines.push(`${pad}${key}: [${value.join(', ')}]`);
      }
    } else if (typeof value === 'object') {
      lines.push(`${pad}${key}:`);
      lines.push(formatData(value as Record<string, unknown>, indent + 2));
    } else {
      lines.push(`${pad}${key}: ${String(value)}`);
    }
  }

  return lines.join('\n');
}
