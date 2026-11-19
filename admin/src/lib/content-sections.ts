// One place that describes every editable part of the app in plain English:
// what each section is, which database tables hold its words, and how the
// tables relate. The Content Manager uses it to give every section an
// "Edit any item" view, so the client can correct wording anywhere, not
// only add and delete.

export interface ColumnDef {
  name: string
  type: 'text' | 'number' | 'boolean' | 'json' | 'uuid' | 'timestamp' | 'date'
  array?: boolean
  ref?: string
  required?: boolean
  options?: string[]
}

export interface TableDef {
  table: string
  /** Plain-English name for one kind of item, plural, e.g. "Tip cards". */
  label: string
  /** Column that best names a row in a list. */
  titleField: string
  /** Which column links this row to a parent row (e.g. a tip to its category). */
  parentField?: string
  /** Set when the app does not read this table yet, so edits will not show. */
  notInApp?: boolean
}

export interface SectionDef {
  slug: string
  label: string
  /** Where people see this in the app. */
  appLocation: string
  /** Path to the original screen for this section. */
  href: string
  group: 'Everyday tools' | 'Support topics' | 'Young people' | 'Service life' | 'App-wide'
  tables: TableDef[]
}

export const SECTIONS: SectionDef[] = [
  // Everyday tools
  {
    slug: 'mood', label: 'Mood check-in', group: 'Everyday tools', href: '/admin/content-manager/mood',
    appLocation: 'The reasons people can pick when they log how they feel.',
    tables: [{ table: 'mood_reasons', label: 'Mood reasons', titleField: 'text' }],
  },
  {
    slug: 'daily-brief', label: 'Daily Brief', group: 'Everyday tools', href: '/admin/content-manager/daily-brief',
    appLocation: 'The morning planner: energy levels, objectives and challenges people choose from.',
    tables: [
      { table: 'daily_brief_energy_levels', label: 'Energy levels', titleField: 'label' },
      { table: 'daily_brief_objectives', label: 'Objectives', titleField: 'text' },
      { table: 'daily_brief_challenges', label: 'Challenges', titleField: 'text' },
    ],
  },
  {
    slug: 'aar', label: 'After Action Review', group: 'Everyday tools', href: '/admin/content-manager/aar',
    appLocation: 'The evening reflection: what went well, what to improve, and takeaways.',
    tables: [
      { table: 'aar_went_well_options', label: 'Went well options', titleField: 'text' },
      { table: 'aar_improve_options', label: 'Improve options', titleField: 'text' },
      { table: 'aar_takeaway_options', label: 'Takeaway options', titleField: 'text' },
    ],
  },
  {
    slug: 'objectives', label: 'Mission objectives', group: 'Everyday tools', href: '/admin/objectives',
    appLocation: 'The objectives people can add to their mission planner.',
    tables: [{ table: 'mission_objectives', label: 'Objectives', titleField: 'text' }],
  },
  {
    slug: 'affirmations', label: 'Affirmations and confidence', group: 'Everyday tools', href: '/admin/content-manager/affirmations',
    appLocation: 'Positive messages, confidence challenges and small confidence actions.',
    tables: [
      { table: 'affirmations', label: 'Affirmations', titleField: 'text' },
      { table: 'confidence_challenges', label: 'Confidence challenges', titleField: 'text' },
      { table: 'confidence_actions', label: 'Confidence actions', titleField: 'text' },
    ],
  },
  {
    slug: 'tips', label: 'Tip cards', group: 'Everyday tools', href: '/admin/content-manager/tips',
    appLocation: 'Swipeable tip cards, grouped into categories.',
    tables: [
      { table: 'tip_categories', label: 'Tip categories', titleField: 'title' },
      { table: 'tips', label: 'Tips', titleField: 'title', parentField: 'category_id' },
    ],
  },
  {
    slug: 'checklists', label: 'Checklists', group: 'Everyday tools', href: '/admin/content-manager/checklists',
    appLocation: 'Tick-box checklists, each with sections and items.',
    tables: [
      { table: 'checklist_templates', label: 'Checklists', titleField: 'title' },
      { table: 'checklist_sections', label: 'Checklist sections', titleField: 'title', parentField: 'template_id' },
      { table: 'checklist_items', label: 'Checklist items', titleField: 'title', parentField: 'section_id' },
    ],
  },
  {
    slug: 'resources', label: 'Resources and helplines', group: 'Everyday tools', href: '/admin/content-manager/resources',
    appLocation: 'The directory of organisations, links and helplines.',
    tables: [
      { table: 'resource_categories', label: 'Resource categories', titleField: 'title' },
      { table: 'resource_sections', label: 'Resource sections', titleField: 'title', parentField: 'category_id' },
      { table: 'resources', label: 'Resources', titleField: 'title', parentField: 'section_id' },
    ],
  },
  {
    slug: 'quizzes', label: 'Quizzes', group: 'Everyday tools', href: '/admin/content-manager/quizzes',
    appLocation: 'Personality-style quizzes such as "Who am I?".',
    tables: [
      { table: 'quizzes', label: 'Quizzes', titleField: 'title' },
      { table: 'quiz_questions', label: 'Questions', titleField: 'question_text', parentField: 'quiz_id' },
      { table: 'quiz_options', label: 'Answer options', titleField: 'option_text', parentField: 'question_id' },
      { table: 'quiz_results', label: 'Results', titleField: 'title', parentField: 'quiz_id' },
    ],
  },
  {
    slug: 'brain-science', label: 'Brain science and psychology', group: 'Everyday tools', href: '/admin/content-manager/brain-science',
    appLocation: 'Myth or fact cards, thinking bias games and famous experiments.',
    tables: [
      { table: 'brain_myths', label: 'Myths and facts', titleField: 'statement' },
      { table: 'brain_biases', label: 'Thinking biases', titleField: 'scenario' },
      { table: 'brain_bias_options', label: 'Bias answer options', titleField: 'option_text', parentField: 'bias_id' },
      { table: 'brain_experiments', label: 'Experiments', titleField: 'title' },
      { table: 'brain_experiment_steps', label: 'Experiment steps', titleField: 'step_text', parentField: 'experiment_id' },
    ],
  },
  {
    slug: 'kindness', label: 'Learning to be kind', group: 'Everyday tools', href: '/admin/content-manager/kindness',
    appLocation: 'Flip cards and "how would you react?" scenarios.',
    tables: [
      { table: 'kindness_flip_cards', label: 'Flip cards', titleField: 'judgement' },
      { table: 'kindness_react_scenarios', label: 'Scenarios', titleField: 'scenario' },
      { table: 'kindness_react_options', label: 'Scenario reactions', titleField: 'reaction_text', parentField: 'scenario_id' },
    ],
  },

  // Support topics
  {
    slug: 'harassment-wizard', label: 'Harassment support', group: 'Support topics', href: '/admin/content-manager/harassment-wizard',
    appLocation: 'The step-by-step helper for anyone experiencing harassment, with guidance and contacts.',
    tables: [
      { table: 'harassment_wizard_steps', label: 'Steps', titleField: 'title' },
      { table: 'harassment_wizard_options', label: 'Step options', titleField: 'text', parentField: 'step_id' },
      { table: 'harassment_wizard_guidance', label: 'Guidance messages', titleField: 'title' },
      { table: 'harassment_wizard_contacts', label: 'Contacts', titleField: 'name' },
    ],
  },
  {
    slug: 'bullying-support', label: 'Bullying support', group: 'Support topics', href: '/admin/content-manager/bullying-support',
    appLocation: 'Guidance cards, bystander actions, coping strategies and support organisations.',
    tables: [
      { table: 'bullying_guidance_cards', label: 'Guidance cards', titleField: 'title' },
      { table: 'bullying_bystander_actions', label: 'Bystander actions', titleField: 'title' },
      { table: 'bullying_coping_strategies', label: 'Coping strategies', titleField: 'title' },
      { table: 'bullying_support_orgs', label: 'Support organisations', titleField: 'name' },
      { table: 'bullying_assessment_questions', label: 'Assessment questions', titleField: 'question', notInApp: true },
      { table: 'bullying_assessment_options', label: 'Assessment options', titleField: 'text', parentField: 'question_id', notInApp: true },
    ],
  },
  {
    slug: 'lgbtq-support', label: 'LGBTQ+ support', group: 'Support topics', href: '/admin/content-manager/lgbtq-support',
    appLocation: 'Timeline, myths, terms, ally scenarios, deployment regions and support organisations.',
    tables: [
      { table: 'lgbtq_timeline', label: 'Timeline events', titleField: 'event' },
      { table: 'lgbtq_myths', label: 'Myths', titleField: 'myth' },
      { table: 'lgbtq_terms', label: 'Terms', titleField: 'term' },
      { table: 'lgbtq_ally_scenarios', label: 'Ally scenarios', titleField: 'scenario' },
      { table: 'lgbtq_ally_options', label: 'Ally scenario options', titleField: 'option_text', parentField: 'scenario_id' },
      { table: 'lgbtq_deploy_regions', label: 'Deployment regions', titleField: 'region' },
      { table: 'lgbtq_support_orgs', label: 'Support organisations', titleField: 'name' },
      { table: 'lgbtq_affirmations', label: 'Affirmations', titleField: 'text' },
    ],
  },
  {
    slug: 'sex-education', label: 'Sex education', group: 'Support topics', href: '/admin/content-manager/sex-education',
    appLocation: 'STI information and key facts. Consent and relationship content is stored here but the app does not read it yet.',
    tables: [
      { table: 'sex_ed_sti_info', label: 'STI information', titleField: 'name' },
      { table: 'sex_ed_key_facts', label: 'Key facts', titleField: 'title' },
      { table: 'sex_ed_consent_principles', label: 'Consent principles', titleField: 'word', notInApp: true },
      { table: 'sex_ed_consent_scenarios', label: 'Consent scenarios', titleField: 'scenario', notInApp: true },
      { table: 'sex_ed_scenario_options', label: 'Consent scenario options', titleField: 'text', parentField: 'scenario_id', notInApp: true },
      { table: 'sex_ed_relationship_signs', label: 'Relationship signs', titleField: 'text', notInApp: true },
      { table: 'sex_ed_relationship_rights', label: 'Relationship rights', titleField: 'text', notInApp: true },
    ],
  },
  {
    slug: 'body-education', label: 'Body education', group: 'Support topics', href: '/admin/content-manager/body-education',
    appLocation: 'Body topics and the fact or myth quiz.',
    tables: [
      { table: 'body_education_topics', label: 'Topics', titleField: 'title' },
      { table: 'body_education_quiz', label: 'Fact or myth quiz', titleField: 'statement' },
    ],
  },
  {
    slug: 'health-education', label: 'Health tracker education', group: 'Support topics', href: '/admin/content-manager/health-education',
    appLocation: 'Contraception methods and pregnancy topics.',
    tables: [
      { table: 'health_contraception_methods', label: 'Contraception methods', titleField: 'name' },
      { table: 'health_pregnancy_topics', label: 'Pregnancy topics', titleField: 'title' },
    ],
  },

  // Young people
  {
    slug: 'feelings', label: 'Big feelings toolkit', group: 'Young people', href: '/admin/content-manager/feelings',
    appLocation: 'Feelings young people can pick, each with coping tools.',
    tables: [
      { table: 'feelings', label: 'Feelings', titleField: 'name' },
      { table: 'coping_tools', label: 'Coping tools', titleField: 'title', parentField: 'feeling_id' },
    ],
  },
  {
    slug: 'interests', label: 'Interest explorer', group: 'Young people', href: '/admin/content-manager/interests',
    appLocation: 'Interest categories and activities to try.',
    tables: [
      { table: 'interest_categories', label: 'Interest categories', titleField: 'name' },
      { table: 'interest_activities', label: 'Activities', titleField: 'title', parentField: 'category_id' },
    ],
  },
  {
    slug: 'learning', label: 'Learning and study', group: 'Young people', href: '/admin/content-manager/learning',
    appLocation: 'Learning styles and study strategies.',
    tables: [
      { table: 'learning_styles', label: 'Learning styles', titleField: 'name' },
      { table: 'study_strategies', label: 'Study strategies', titleField: 'name' },
    ],
  },
  {
    slug: 'careers', label: 'Career paths', group: 'Young people', href: '/admin/content-manager/careers',
    appLocation: 'The Career Sampler.',
    tables: [{ table: 'career_paths', label: 'Career paths', titleField: 'title' }],
  },

  // Service life
  {
    slug: 'skills', label: 'Skills translator', group: 'Service life', href: '/admin/content-manager/skills',
    appLocation: 'Service roles and the civilian jobs they translate to.',
    tables: [
      { table: 'military_roles', label: 'Service roles', titleField: 'title' },
      { table: 'civilian_jobs', label: 'Civilian jobs', titleField: 'title' },
    ],
  },
  {
    slug: 'service-family', label: 'Service family', group: 'Service life', href: '/admin/content-manager/service-family',
    appLocation: 'Support for partners and families: deployment phases, tips, children and support organisations.',
    tables: [
      { table: 'service_family_deployment_phases', label: 'Deployment phases', titleField: 'name' },
      { table: 'service_family_deployment_tips', label: 'Deployment tips', titleField: 'title' },
      { table: 'service_family_understand_topics', label: 'Understanding topics', titleField: 'title' },
      { table: 'service_family_selfcare_strategies', label: 'Self-care strategies', titleField: 'title' },
      { table: 'service_family_children_age_groups', label: 'Children by age group', titleField: 'title' },
      { table: 'service_family_children_tips', label: 'Children tips', titleField: 'tip' },
      { table: 'service_family_help_signs', label: 'Signs to seek help', titleField: 'sign' },
      { table: 'service_family_support_orgs', label: 'Support organisations', titleField: 'name' },
      { table: 'service_family_affirmations', label: 'Affirmations', titleField: 'text' },
    ],
  },
  {
    slug: 'service-culture', label: 'Service culture', group: 'Service life', href: '/admin/content-manager/service-culture',
    appLocation: 'Values and the scenario drill.',
    tables: [
      { table: 'culture_values', label: 'Values', titleField: 'name' },
      { table: 'culture_scenarios', label: 'Scenarios', titleField: 'scenario' },
    ],
  },
  {
    slug: 'military-perks', label: 'Service perks', group: 'Service life', href: '/admin/content-manager/military-perks',
    appLocation: 'Facts about service benefits and stories from people who left.',
    tables: [
      { table: 'perks_facts', label: 'Facts', titleField: 'title' },
      { table: 'perks_regret_stories', label: 'Stories', titleField: 'quote' },
    ],
  },

  // App-wide
  {
    slug: 'user-screens', label: 'Home screens by user type', group: 'App-wide', href: '/admin/content-manager/user-screens',
    appLocation: 'The home screen tiles shown to each type of user.',
    tables: [
      { table: 'user_type_screens', label: 'Screens', titleField: 'title' },
      { table: 'user_type_sections', label: 'Screen sections', titleField: 'title', parentField: 'screen_id' },
      { table: 'user_type_items', label: 'Tiles', titleField: 'title', parentField: 'section_id' },
    ],
  },
  {
    slug: 'whats-new', label: "What's new", group: 'App-wide', href: '/admin/content-manager/whats-new',
    appLocation: 'The release notes people see after an update.',
    tables: [
      { table: 'whats_new_releases', label: 'Releases', titleField: 'title' },
      { table: 'whats_new_items', label: 'Release items', titleField: 'title', parentField: 'release_id' },
    ],
  },
  {
    slug: 'domains', label: 'Navigate topics', group: 'App-wide', href: '/admin/domains',
    appLocation: 'The topic areas on the Navigate screen (for example Relationships or Family).',
    tables: [{ table: 'domains', label: 'Topics', titleField: 'name' }],
  },
  {
    slug: 'journeys', label: 'Journeys', group: 'App-wide', href: '/admin/journeys',
    appLocation: 'Guided pathways. The app does not show journeys yet.',
    tables: [{ table: 'journeys', label: 'Journeys', titleField: 'title', notInApp: true }],
  },
]

export const ALL_TABLES: TableDef[] = SECTIONS.flatMap((s) => s.tables)

export function findTable(table: string): { section: SectionDef; def: TableDef } | null {
  for (const section of SECTIONS) {
    const def = section.tables.find((t) => t.table === table)
    if (def) return { section, def }
  }
  return null
}

export function findSectionByPath(pathname: string): SectionDef | null {
  return SECTIONS.find((s) => pathname === s.href || pathname.startsWith(s.href + '/')) ?? null
}

// Friendly names for column names that are not self-explanatory.
const FIELD_LABELS: Record<string, string> = {
  is_active: 'Show in the app',
  is_published: 'Published',
  sort_order: 'Position in list',
  display_order: 'Position in list',
  emoji: 'Emoji',
  icon: 'Icon name',
  colour: 'Colour',
  color: 'Colour',
  accent_color: 'Accent colour',
  color_hex: 'Colour',
  external_url: 'Website link',
  website: 'Website link',
  target_audience: 'Who sees it',
  user_types: 'Who sees it',
  key_points: 'Key points',
  match_tags: 'Matching tags',
  is_true: 'This statement is true',
  is_fact: 'This statement is a fact',
  is_emergency: 'Emergency contact',
  is_universal: 'Show to everyone',
  correct_option_index: 'Correct answer number (first answer is 0)',
  best_reaction_index: 'Best reaction number (first is 0)',
  best_option: 'Best option number (first is 0)',
  option_index: 'Option number (first is 0)',
  slug: 'Short web name',
  action_type: 'What tapping it does',
  action_data: 'Tap settings',
}

export function fieldLabel(name: string): string {
  if (FIELD_LABELS[name]) return FIELD_LABELS[name]
  const s = name.replace(/_id$/, '').replace(/_/g, ' ')
  return s.charAt(0).toUpperCase() + s.slice(1)
}

// Fields a content editor should not normally need to touch.
export const ADVANCED_FIELDS = new Set(['slug', 'icon', 'action_type', 'action_data', 'options_json', 'result_key', 'option_id', 'correct_option_id', 'item_sequence'])
export const SYSTEM_FIELDS = new Set(['id', 'created_at', 'updated_at', 'view_count', 'subscriber_count'])

// Fields that usually hold a paragraph rather than a line.
const LONG_TEXT = /^(content|description|explanation|detail|details|message|reality|reveal|advice|meaning|how_it_works|side_effects|service_notes|symptoms|treatment|prevention|day_in_life|education_path|why_it_helps|how_to|celebration_message|situation|context|scenario|tips|feelings|subtext|access|tagline|microcopy)$/

export function isLongText(name: string): boolean {
  return LONG_TEXT.test(name)
}

// Client rule: information must come from the NHS or a trusted source.
export const TRUSTED_DOMAINS = ['nhs.uk', 'rcpsych.ac.uk', 'mind.org.uk', 'mentalhealth.org.uk']

export function untrustedLinks(text: string): string[] {
  const urls = text.match(/https?:\/\/[^\s)"']+/gi) || []
  return urls.filter((u) => {
    try {
      const host = new URL(u).hostname.toLowerCase()
      return !TRUSTED_DOMAINS.some((d) => host === d || host.endsWith('.' + d))
    } catch {
      return true
    }
  })
}
