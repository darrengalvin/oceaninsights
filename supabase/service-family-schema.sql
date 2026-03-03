-- ================================================================
-- Service Family — Supabase schema
-- ================================================================
-- Tables:
--   1. service_family_deployment_phases    (interactive timeline)
--   2. service_family_deployment_tips      (expandable cards on Deployment tab)
--   3. service_family_understand_topics    (Understanding Military Life tab)
--   4. service_family_selfcare_strategies  (Self-Care tab)
--   5. service_family_affirmations         (motivational quotes)
--   6. service_family_children_age_groups  (Children tab — age-specific guidance)
--   7. service_family_children_tips        (General tips list)
--   8. service_family_help_signs           (When to seek help indicators)
--   9. service_family_support_orgs         (Support organisations)
-- ================================================================

-- 1. Deployment Phases (timeline cards)
CREATE TABLE IF NOT EXISTS service_family_deployment_phases (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  timing      TEXT NOT NULL,
  colour      TEXT NOT NULL DEFAULT '#60A5FA',
  feelings_label TEXT NOT NULL DEFAULT 'Common feelings:',
  feelings    TEXT NOT NULL,
  tips_label  TEXT NOT NULL DEFAULT 'What helps:',
  tips        TEXT NOT NULL,
  sort_order  INT  NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Deployment Tips (expandable cards)
CREATE TABLE IF NOT EXISTS service_family_deployment_tips (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL,
  subtitle    TEXT NOT NULL,
  emoji       TEXT NOT NULL DEFAULT '📋',
  colour      TEXT NOT NULL DEFAULT '#60A5FA',
  content     TEXT NOT NULL,
  sort_order  INT  NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Understanding Military Life topics
CREATE TABLE IF NOT EXISTS service_family_understand_topics (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL,
  subtitle    TEXT NOT NULL,
  emoji       TEXT NOT NULL DEFAULT '🎖️',
  colour      TEXT NOT NULL DEFAULT '#FBBF24',
  content     TEXT NOT NULL,
  sort_order  INT  NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Self-care strategies
CREATE TABLE IF NOT EXISTS service_family_selfcare_strategies (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL,
  subtitle    TEXT NOT NULL,
  emoji       TEXT NOT NULL DEFAULT '💜',
  colour      TEXT NOT NULL DEFAULT '#E879A0',
  content     TEXT NOT NULL,
  sort_order  INT  NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. Family affirmations
CREATE TABLE IF NOT EXISTS service_family_affirmations (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text        TEXT NOT NULL,
  sort_order  INT  NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. Children age groups (age-specific guidance)
CREATE TABLE IF NOT EXISTS service_family_children_age_groups (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL,
  subtitle    TEXT NOT NULL,
  emoji       TEXT NOT NULL DEFAULT '👶',
  colour      TEXT NOT NULL DEFAULT '#60A5FA',
  content     TEXT NOT NULL,
  sort_order  INT  NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. General children tips
CREATE TABLE IF NOT EXISTS service_family_children_tips (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tip         TEXT NOT NULL,
  sort_order  INT  NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. When to seek help signs
CREATE TABLE IF NOT EXISTS service_family_help_signs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sign        TEXT NOT NULL,
  sort_order  INT  NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 9. Support organisations
CREATE TABLE IF NOT EXISTS service_family_support_orgs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  description TEXT NOT NULL,
  access      TEXT NOT NULL,
  sort_order  INT  NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ================================================================
-- Row Level Security
-- ================================================================

ALTER TABLE service_family_deployment_phases    ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_family_deployment_tips      ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_family_understand_topics    ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_family_selfcare_strategies  ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_family_affirmations         ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_family_children_age_groups  ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_family_children_tips        ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_family_help_signs           ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_family_support_orgs         ENABLE ROW LEVEL SECURITY;

-- Public read
CREATE POLICY "Public read service_family_deployment_phases"   ON service_family_deployment_phases   FOR SELECT USING (true);
CREATE POLICY "Public read service_family_deployment_tips"     ON service_family_deployment_tips     FOR SELECT USING (true);
CREATE POLICY "Public read service_family_understand_topics"   ON service_family_understand_topics   FOR SELECT USING (true);
CREATE POLICY "Public read service_family_selfcare_strategies" ON service_family_selfcare_strategies FOR SELECT USING (true);
CREATE POLICY "Public read service_family_affirmations"        ON service_family_affirmations        FOR SELECT USING (true);
CREATE POLICY "Public read service_family_children_age_groups" ON service_family_children_age_groups FOR SELECT USING (true);
CREATE POLICY "Public read service_family_children_tips"       ON service_family_children_tips       FOR SELECT USING (true);
CREATE POLICY "Public read service_family_help_signs"          ON service_family_help_signs          FOR SELECT USING (true);
CREATE POLICY "Public read service_family_support_orgs"        ON service_family_support_orgs        FOR SELECT USING (true);

-- Authenticated write
CREATE POLICY "Auth write service_family_deployment_phases"   ON service_family_deployment_phases   FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write service_family_deployment_tips"     ON service_family_deployment_tips     FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write service_family_understand_topics"   ON service_family_understand_topics   FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write service_family_selfcare_strategies" ON service_family_selfcare_strategies FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write service_family_affirmations"        ON service_family_affirmations        FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write service_family_children_age_groups" ON service_family_children_age_groups FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write service_family_children_tips"       ON service_family_children_tips       FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write service_family_help_signs"          ON service_family_help_signs          FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write service_family_support_orgs"        ON service_family_support_orgs        FOR ALL USING (auth.role() = 'authenticated');
