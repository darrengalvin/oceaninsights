export interface ContentAreaInfo {
  id: string;
  label: string;
  primary_table: string;
}

export const CONTENT_AREAS: ContentAreaInfo[] = [
  { id: 'navigate_content', label: 'Navigate Content', primary_table: 'content_items' },
  { id: 'learn_articles', label: 'Learn Articles', primary_table: 'learn_articles' },
  { id: 'user_type_screens', label: 'User Type Screens', primary_table: 'user_type_items' },
  { id: 'mission_objectives', label: 'Mission Objectives', primary_table: 'mission_objectives' },
  { id: 'mood_system', label: 'Mood System', primary_table: 'mood_reasons' },
  { id: 'daily_brief', label: 'Daily Brief', primary_table: 'daily_brief_objectives' },
  { id: 'after_action_review', label: 'After Action Review', primary_table: 'aar_went_well_options' },
  { id: 'skills_translator', label: 'Skills Translator', primary_table: 'military_roles' },
  { id: 'feelings_toolkit', label: 'Feelings Toolkit', primary_table: 'feelings' },
  { id: 'quizzes', label: 'Quizzes', primary_table: 'quizzes' },
  { id: 'career_paths', label: 'Career Paths', primary_table: 'career_paths' },
  { id: 'tip_cards', label: 'Tip Cards', primary_table: 'tip_categories' },
  { id: 'checklists', label: 'Checklists', primary_table: 'checklist_templates' },
  { id: 'resources', label: 'Resources', primary_table: 'resource_categories' },
  { id: 'learning_styles', label: 'Learning & Study', primary_table: 'learning_styles' },
  { id: 'affirmations', label: 'Affirmations', primary_table: 'affirmations' },
  { id: 'interest_explorer', label: 'Interest Explorer', primary_table: 'interest_categories' },
  { id: 'harassment_wizard', label: 'Harassment Support Wizard', primary_table: 'harassment_wizard_steps' },
  { id: 'body_education', label: 'Body Education', primary_table: 'body_education_topics' },
  { id: 'sex_education', label: 'Sex Education', primary_table: 'sex_ed_consent_scenarios' },
  { id: 'bullying_support', label: 'Bullying Support', primary_table: 'bullying_guidance_cards' },
  { id: 'health_education', label: 'Health Tracker Education', primary_table: 'health_contraception_methods' },
  { id: 'service_family', label: 'Service Family', primary_table: 'service_family_deployment_phases' },
  { id: 'whats_new', label: "What's New", primary_table: 'whats_new_releases' },
  { id: 'kindness', label: 'Learning to be Kind', primary_table: 'kindness_flip_cards' },
  { id: 'service_culture', label: 'Service Culture (C2 Drill)', primary_table: 'culture_values' },
  { id: 'military_perks', label: 'Military Perks', primary_table: 'perks_facts' },
  { id: 'brain_science', label: 'Brain Science & Psychology', primary_table: 'brain_myths' },
  { id: 'donations', label: 'Donations', primary_table: 'donation_impacts' },
  { id: 'lgbtq_support', label: 'LGBTQ+ Support', primary_table: 'lgbtq_timeline' },
  { id: 'scenarios_v2', label: 'Scenarios & Protocols', primary_table: 'scenarios' },
  { id: 'rituals', label: 'Rituals', primary_table: 'ritual_topics' },
];
