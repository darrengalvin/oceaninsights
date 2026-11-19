// Audit areas for content that is built into the Flutter app rather than
// stored in the database. The app's text is captured by
// `npm run audit:snapshot` (scripts/snapshot-app-content.mjs) into
// lib/audit/evidence/app-content-snapshot.json; lib/audit/app-content.ts turns
// it into audit items. This file is the client-safe list of areas only, so the
// dashboard can show them without bundling the snapshot.

import type { ContentAreaInfo } from './areas';

export interface AppContentArea extends ContentAreaInfo {
  /** Feature folders under lib/features (or core groups) that make up this area. */
  groups: string[];
}

export const APP_SNAPSHOT_TABLE = 'app_snapshot';

export const APP_CONTENT_AREAS: AppContentArea[] = [
  { id: 'app_support_contacts', label: 'App: Help, Contacts and Home', primary_table: APP_SNAPSHOT_TABLE,
    groups: ['settings', 'home', 'onboarding', 'whats_new', 'shared_widgets', 'core', 'suicide_awareness', 'neurodiversity'] },
  { id: 'app_learn', label: 'App: Learn Articles (as shown in the app)', primary_table: APP_SNAPSHOT_TABLE, groups: ['learn'] },
  { id: 'app_navigate', label: 'App: Navigate Topics (built-in copy)', primary_table: APP_SNAPSHOT_TABLE, groups: ['navigate'] },
  { id: 'app_user_type_screens', label: 'App: Military, Veteran and Young Person Screens', primary_table: APP_SNAPSHOT_TABLE, groups: ['user_types'] },
  { id: 'app_service_women', label: "App: Service Women and Women's Health", primary_table: APP_SNAPSHOT_TABLE, groups: ['service_women'] },
  { id: 'app_young_person', label: 'App: Young Person (body, sex education, bullying)', primary_table: APP_SNAPSHOT_TABLE, groups: ['young_person'] },
  { id: 'app_family_lgbtq_perks', label: 'App: Service Family, LGBTQ+ and Military Perks', primary_table: APP_SNAPSHOT_TABLE,
    groups: ['service_family', 'lgbtq_support', 'military_perks'] },
  { id: 'app_wellbeing_tools', label: 'App: Breathing, Brain Science and Wellbeing Tools', primary_table: APP_SNAPSHOT_TABLE,
    groups: ['breathing', 'brain_science', 'rituals', 'affirmations', 'quotes', 'kindness', 'goals', 'pay_it_forward', 'scenarios', 'service_culture'] },
  { id: 'app_offline_fallback', label: 'App: Offline Fallback Copies of Database Content', primary_table: APP_SNAPSHOT_TABLE, groups: ['core_services'] },
];

export function isAppContentArea(areaId: string): boolean {
  return APP_CONTENT_AREAS.some(a => a.id === areaId);
}
