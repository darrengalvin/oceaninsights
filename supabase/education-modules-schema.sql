-- ============================================================
-- EDUCATION MODULES SCHEMA
-- Body Education, Sex Education, Bullying Support, Health Tracker Education
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. BODY EDUCATION
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS body_education_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tab TEXT NOT NULL CHECK (tab IN ('female', 'male')),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '📘',
  colour TEXT NOT NULL DEFAULT '#60A5FA',
  content TEXT NOT NULL,
  normal_range TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS body_education_quiz (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  statement TEXT NOT NULL,
  is_fact BOOLEAN NOT NULL,
  explanation TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ────────────────────────────────────────────────────────────
-- 2. SEX EDUCATION
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS sex_ed_consent_principles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  letter TEXT NOT NULL,
  word TEXT NOT NULL,
  description TEXT NOT NULL,
  colour TEXT NOT NULL DEFAULT '#A78BFA',
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sex_ed_consent_scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario TEXT NOT NULL,
  question TEXT NOT NULL,
  correct_option_id TEXT NOT NULL,
  explanation TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sex_ed_scenario_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID NOT NULL REFERENCES sex_ed_consent_scenarios(id) ON DELETE CASCADE,
  option_id TEXT NOT NULL,
  text TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS sex_ed_relationship_signs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sign_type TEXT NOT NULL CHECK (sign_type IN ('healthy', 'warning')),
  text TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sex_ed_relationship_rights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sex_ed_sti_info (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  symptoms TEXT NOT NULL,
  treatment TEXT NOT NULL,
  prevention TEXT NOT NULL,
  treatable BOOLEAN NOT NULL DEFAULT true,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sex_ed_key_facts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  content TEXT NOT NULL,
  icon TEXT NOT NULL DEFAULT 'lightbulb',
  colour TEXT NOT NULL DEFAULT '#FBBF24',
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ────────────────────────────────────────────────────────────
-- 3. BULLYING SUPPORT
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bullying_assessment_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '🤔',
  subtext TEXT,
  step_number INT NOT NULL UNIQUE,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bullying_assessment_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES bullying_assessment_questions(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '❓',
  tag TEXT NOT NULL,
  subtext TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS bullying_guidance_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  action_steps TEXT[] NOT NULL DEFAULT '{}',
  match_tags TEXT[] NOT NULL DEFAULT '{}',
  icon TEXT NOT NULL DEFAULT 'info',
  colour TEXT NOT NULL DEFAULT '#F59E0B',
  priority INT NOT NULL DEFAULT 5,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bullying_bystander_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  content TEXT NOT NULL,
  examples TEXT[] NOT NULL DEFAULT '{}',
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bullying_coping_strategies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '💡',
  colour TEXT NOT NULL DEFAULT '#34D399',
  content TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bullying_support_orgs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  access TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ────────────────────────────────────────────────────────────
-- 4. HEALTH TRACKER EDUCATIONAL CONTENT
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS health_contraception_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '💊',
  category TEXT NOT NULL,
  how_it_works TEXT NOT NULL,
  effectiveness TEXT NOT NULL,
  duration TEXT NOT NULL,
  service_notes TEXT NOT NULL,
  side_effects TEXT[] NOT NULL DEFAULT '{}',
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS health_pregnancy_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  content TEXT NOT NULL,
  icon TEXT NOT NULL DEFAULT 'info',
  colour TEXT NOT NULL DEFAULT '#F472B6',
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- ────────────────────────────────────────────────────────────

ALTER TABLE body_education_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE body_education_quiz ENABLE ROW LEVEL SECURITY;
ALTER TABLE sex_ed_consent_principles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sex_ed_consent_scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE sex_ed_scenario_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE sex_ed_relationship_signs ENABLE ROW LEVEL SECURITY;
ALTER TABLE sex_ed_relationship_rights ENABLE ROW LEVEL SECURITY;
ALTER TABLE sex_ed_sti_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE sex_ed_key_facts ENABLE ROW LEVEL SECURITY;
ALTER TABLE bullying_assessment_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bullying_assessment_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE bullying_guidance_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE bullying_bystander_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bullying_coping_strategies ENABLE ROW LEVEL SECURITY;
ALTER TABLE bullying_support_orgs ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_contraception_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_pregnancy_topics ENABLE ROW LEVEL SECURITY;

-- Public read for app
CREATE POLICY "Public read body_education_topics" ON body_education_topics FOR SELECT USING (true);
CREATE POLICY "Public read body_education_quiz" ON body_education_quiz FOR SELECT USING (true);
CREATE POLICY "Public read sex_ed_consent_principles" ON sex_ed_consent_principles FOR SELECT USING (true);
CREATE POLICY "Public read sex_ed_consent_scenarios" ON sex_ed_consent_scenarios FOR SELECT USING (true);
CREATE POLICY "Public read sex_ed_scenario_options" ON sex_ed_scenario_options FOR SELECT USING (true);
CREATE POLICY "Public read sex_ed_relationship_signs" ON sex_ed_relationship_signs FOR SELECT USING (true);
CREATE POLICY "Public read sex_ed_relationship_rights" ON sex_ed_relationship_rights FOR SELECT USING (true);
CREATE POLICY "Public read sex_ed_sti_info" ON sex_ed_sti_info FOR SELECT USING (true);
CREATE POLICY "Public read sex_ed_key_facts" ON sex_ed_key_facts FOR SELECT USING (true);
CREATE POLICY "Public read bullying_assessment_questions" ON bullying_assessment_questions FOR SELECT USING (true);
CREATE POLICY "Public read bullying_assessment_options" ON bullying_assessment_options FOR SELECT USING (true);
CREATE POLICY "Public read bullying_guidance_cards" ON bullying_guidance_cards FOR SELECT USING (true);
CREATE POLICY "Public read bullying_bystander_actions" ON bullying_bystander_actions FOR SELECT USING (true);
CREATE POLICY "Public read bullying_coping_strategies" ON bullying_coping_strategies FOR SELECT USING (true);
CREATE POLICY "Public read bullying_support_orgs" ON bullying_support_orgs FOR SELECT USING (true);
CREATE POLICY "Public read health_contraception_methods" ON health_contraception_methods FOR SELECT USING (true);
CREATE POLICY "Public read health_pregnancy_topics" ON health_pregnancy_topics FOR SELECT USING (true);

-- Authenticated write for admin
CREATE POLICY "Auth write body_education_topics" ON body_education_topics FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write body_education_quiz" ON body_education_quiz FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write sex_ed_consent_principles" ON sex_ed_consent_principles FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write sex_ed_consent_scenarios" ON sex_ed_consent_scenarios FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write sex_ed_scenario_options" ON sex_ed_scenario_options FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write sex_ed_relationship_signs" ON sex_ed_relationship_signs FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write sex_ed_relationship_rights" ON sex_ed_relationship_rights FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write sex_ed_sti_info" ON sex_ed_sti_info FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write sex_ed_key_facts" ON sex_ed_key_facts FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write bullying_assessment_questions" ON bullying_assessment_questions FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write bullying_assessment_options" ON bullying_assessment_options FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write bullying_guidance_cards" ON bullying_guidance_cards FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write bullying_bystander_actions" ON bullying_bystander_actions FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write bullying_coping_strategies" ON bullying_coping_strategies FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write bullying_support_orgs" ON bullying_support_orgs FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write health_contraception_methods" ON health_contraception_methods FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write health_pregnancy_topics" ON health_pregnancy_topics FOR ALL USING (auth.role() = 'authenticated');
