-- RITUALS FULL MIGRATION
-- Run this in Supabase SQL Editor
-- Generated: 2026-01-27T19:45:31.930Z
-- ===========================================

-- ============================================
-- RITUAL TOPICS & PACKS SCHEMA
-- Run this in Supabase SQL Editor
-- ============================================

-- Enable UUID extension (if not already)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- RITUAL CATEGORIES (High-level groupings)
-- ============================================
CREATE TABLE ritual_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT DEFAULT 'spa_outlined',
  color TEXT DEFAULT '#00D9C4', -- Accent color for this category
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- RITUAL TOPICS (User-selectable focus areas)
-- ============================================
CREATE TYPE ritual_difficulty AS ENUM ('beginner', 'intermediate', 'advanced');

CREATE TABLE ritual_topics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id UUID REFERENCES ritual_categories(id) ON DELETE CASCADE,
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  tagline TEXT, -- Short motivational tagline
  description TEXT,
  icon TEXT DEFAULT 'check_circle_outline',
  cover_image_url TEXT,
  difficulty ritual_difficulty DEFAULT 'beginner',
  estimated_days INTEGER DEFAULT 30, -- Suggested duration
  display_order INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT false,
  subscriber_count INTEGER DEFAULT 0, -- How many users have selected this
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ritual_topics_category ON ritual_topics(category_id);
CREATE INDEX idx_ritual_topics_published ON ritual_topics(is_published);
CREATE INDEX idx_ritual_topics_featured ON ritual_topics(is_featured);

-- ============================================
-- RITUAL ITEMS (Individual rituals within topics)
-- ============================================
CREATE TYPE ritual_time_of_day AS ENUM ('morning', 'afternoon', 'evening', 'anytime');
CREATE TYPE ritual_frequency AS ENUM ('daily', 'weekdays', 'weekends', 'weekly', 'as_needed');

CREATE TABLE ritual_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic_id UUID REFERENCES ritual_topics(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT, -- Detailed explanation
  why_it_helps TEXT, -- The science/reasoning behind it
  how_to TEXT, -- Step-by-step instructions
  duration_minutes INTEGER DEFAULT 5, -- How long it takes
  time_of_day ritual_time_of_day DEFAULT 'anytime',
  frequency ritual_frequency DEFAULT 'daily',
  icon TEXT DEFAULT 'check_circle',
  display_order INTEGER DEFAULT 0,
  is_core BOOLEAN DEFAULT true, -- Core rituals vs optional
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ritual_items_topic ON ritual_items(topic_id);
CREATE INDEX idx_ritual_items_time ON ritual_items(time_of_day);

-- ============================================
-- RITUAL AFFIRMATIONS (Topic-specific affirmations)
-- ============================================
CREATE TABLE ritual_affirmations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic_id UUID REFERENCES ritual_topics(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  attribution TEXT, -- Who said it (if quote)
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ritual_affirmations_topic ON ritual_affirmations(topic_id);

-- ============================================
-- RITUAL MILESTONES (Achievements within topics)
-- ============================================
CREATE TABLE ritual_milestones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic_id UUID REFERENCES ritual_topics(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  day_threshold INTEGER NOT NULL, -- Day to unlock (e.g., day 7, day 14, day 30)
  icon TEXT DEFAULT 'emoji_events',
  celebration_message TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ritual_milestones_topic ON ritual_milestones(topic_id);

-- ============================================
-- RITUAL TIPS (Daily tips/insights for topics)
-- ============================================
CREATE TABLE ritual_tips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic_id UUID REFERENCES ritual_topics(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  day_to_show INTEGER, -- Show on specific day (null = random)
  icon TEXT DEFAULT 'lightbulb_outline',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ritual_tips_topic ON ritual_tips(topic_id);

-- ============================================
-- USER SUBSCRIPTIONS (Which topics user selected)
-- ============================================
CREATE TABLE user_ritual_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL, -- References auth.users
  topic_id UUID REFERENCES ritual_topics(id) ON DELETE CASCADE,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  current_day INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  last_activity_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE(user_id, topic_id)
);

CREATE INDEX idx_user_ritual_subs_user ON user_ritual_subscriptions(user_id);
CREATE INDEX idx_user_ritual_subs_topic ON user_ritual_subscriptions(topic_id);

-- ============================================
-- USER RITUAL COMPLETIONS (Track daily completions)
-- ============================================
CREATE TABLE user_ritual_completions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  ritual_item_id UUID REFERENCES ritual_items(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  completed_date DATE DEFAULT CURRENT_DATE,
  notes TEXT, -- Optional reflection
  UNIQUE(user_id, ritual_item_id, completed_date)
);

CREATE INDEX idx_user_ritual_completions_user ON user_ritual_completions(user_id);
CREATE INDEX idx_user_ritual_completions_date ON user_ritual_completions(completed_at);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
ALTER TABLE ritual_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE ritual_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE ritual_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE ritual_affirmations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ritual_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE ritual_tips ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_ritual_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_ritual_completions ENABLE ROW LEVEL SECURITY;

-- Public read for published content
CREATE POLICY "Public can read active categories" ON ritual_categories
  FOR SELECT USING (is_active = true);

CREATE POLICY "Public can read published topics" ON ritual_topics
  FOR SELECT USING (is_published = true);

CREATE POLICY "Public can read active ritual items" ON ritual_items
  FOR SELECT USING (
    is_active = true AND EXISTS (
      SELECT 1 FROM ritual_topics 
      WHERE ritual_topics.id = ritual_items.topic_id 
      AND ritual_topics.is_published = true
    )
  );

CREATE POLICY "Public can read active affirmations" ON ritual_affirmations
  FOR SELECT USING (
    is_active = true AND EXISTS (
      SELECT 1 FROM ritual_topics 
      WHERE ritual_topics.id = ritual_affirmations.topic_id 
      AND ritual_topics.is_published = true
    )
  );

CREATE POLICY "Public can read milestones" ON ritual_milestones
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM ritual_topics 
      WHERE ritual_topics.id = ritual_milestones.topic_id 
      AND ritual_topics.is_published = true
    )
  );

CREATE POLICY "Public can read active tips" ON ritual_tips
  FOR SELECT USING (
    is_active = true AND EXISTS (
      SELECT 1 FROM ritual_topics 
      WHERE ritual_topics.id = ritual_tips.topic_id 
      AND ritual_topics.is_published = true
    )
  );

-- User-specific data policies
CREATE POLICY "Users can read own subscriptions" ON user_ritual_subscriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscriptions" ON user_ritual_subscriptions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own subscriptions" ON user_ritual_subscriptions
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can read own completions" ON user_ritual_completions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own completions" ON user_ritual_completions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- TRIGGERS
-- ============================================

-- Update subscriber count when users subscribe/unsubscribe
CREATE OR REPLACE FUNCTION update_topic_subscriber_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE ritual_topics 
    SET subscriber_count = subscriber_count + 1 
    WHERE id = NEW.topic_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE ritual_topics 
    SET subscriber_count = subscriber_count - 1 
    WHERE id = OLD.topic_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_subscriber_count
AFTER INSERT OR DELETE ON user_ritual_subscriptions
FOR EACH ROW EXECUTE FUNCTION update_topic_subscriber_count();

-- Update timestamps
CREATE OR REPLACE FUNCTION update_ritual_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ritual_categories_updated_at
BEFORE UPDATE ON ritual_categories
FOR EACH ROW EXECUTE FUNCTION update_ritual_updated_at();

CREATE TRIGGER ritual_topics_updated_at
BEFORE UPDATE ON ritual_topics
FOR EACH ROW EXECUTE FUNCTION update_ritual_updated_at();

CREATE TRIGGER ritual_items_updated_at
BEFORE UPDATE ON ritual_items
FOR EACH ROW EXECUTE FUNCTION update_ritual_updated_at();

-- ============================================
-- VIEWS
-- ============================================

-- Full topic view with category info
CREATE VIEW ritual_topics_full AS
SELECT 
  rt.id,
  rt.slug,
  rt.name,
  rt.tagline,
  rt.description,
  rt.icon,
  rt.cover_image_url,
  rt.difficulty,
  rt.estimated_days,
  rt.is_featured,
  rt.is_published,
  rt.subscriber_count,
  rc.slug as category_slug,
  rc.name as category_name,
  rc.icon as category_icon,
  rc.color as category_color,
  (SELECT COUNT(*) FROM ritual_items ri WHERE ri.topic_id = rt.id AND ri.is_active = true) as ritual_count
FROM ritual_topics rt
JOIN ritual_categories rc ON rt.category_id = rc.id;

COMMENT ON TABLE ritual_categories IS 'High-level groupings for ritual topics';
COMMENT ON TABLE ritual_topics IS 'User-selectable focus areas with specific rituals';
COMMENT ON TABLE ritual_items IS 'Individual ritual tasks within topics';
COMMENT ON TABLE ritual_affirmations IS 'Topic-specific affirmations shown to users';
COMMENT ON TABLE ritual_milestones IS 'Achievement checkpoints within topics';
COMMENT ON TABLE ritual_tips IS 'Daily tips and insights for topics';


-- ===========================================
-- SEED DATA
-- ===========================================

-- ============================================
-- RITUAL TOPICS SEED DATA
-- Run this AFTER rituals-schema.sql
-- ============================================

-- ============================================
-- CATEGORIES
-- ============================================
INSERT INTO ritual_categories (slug, name, description, icon, color, display_order, is_active) VALUES
  ('relationships', 'Relationships & Love', 'Build meaningful connections and nurture love in your life', 'favorite', '#FB7185', 1, true),
  ('career', 'Career & Purpose', 'Find direction, build skills, and thrive professionally', 'work_outline', '#FBBF24', 2, true),
  ('mental-wellness', 'Mental Wellness', 'Strengthen your mind and emotional resilience', 'psychology', '#34D399', 3, true),
  ('health-habits', 'Health & Habits', 'Build sustainable healthy routines', 'fitness_center', '#67E8F9', 4, true),
  ('life-transitions', 'Life Transitions', 'Navigate change with confidence', 'autorenew', '#A78BFA', 5, true),
  ('growth-mindfulness', 'Growth & Mindfulness', 'Expand your awareness and personal development', 'spa', '#00D9C4', 6, true),
  ('social-connection', 'Social Connection', 'Build community and meaningful friendships', 'groups', '#F472B6', 7, true);

-- ============================================
-- TOPICS: RELATIONSHIPS & LOVE
-- ============================================

-- Finding Love
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'relationships'),
  'finding-love',
  'Finding Love',
  'Prepare your heart for connection',
  'A journey to make yourself ready for a healthy, fulfilling relationship. Focus on self-awareness, confidence, and opening yourself to love.',
  'favorite_border',
  'beginner',
  30,
  true,
  true,
  1
);

-- Self-Love First
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'relationships'),
  'self-love-first',
  'Self-Love First',
  'You can''t pour from an empty cup',
  'Build a strong, loving relationship with yourself before seeking it in others. Learn to appreciate, respect, and care for yourself.',
  'self_improvement',
  'beginner',
  21,
  true,
  true,
  2
);

-- Healing from Heartbreak
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'relationships'),
  'healing-heartbreak',
  'Healing from Heartbreak',
  'From pain to growth',
  'Process past relationships, heal emotional wounds, and rebuild your confidence. Transform heartbreak into wisdom and strength.',
  'healing',
  'intermediate',
  28,
  false,
  true,
  3
);

-- Better Communication
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'relationships'),
  'better-communication',
  'Better Communication',
  'Say what you mean, hear what they say',
  'Master the art of expressing your needs, listening actively, and resolving conflicts with compassion.',
  'forum',
  'intermediate',
  21,
  false,
  true,
  4
);

-- Deepening Intimacy
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'relationships'),
  'deepening-intimacy',
  'Deepening Intimacy',
  'Connect on a deeper level',
  'Strengthen emotional and physical closeness with your partner through intentional connection practices.',
  'connect_without_contact',
  'intermediate',
  30,
  false,
  true,
  5
);

-- ============================================
-- TOPICS: CAREER & PURPOSE
-- ============================================

-- Job Interview Prep
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'career'),
  'interview-prep',
  'Job Interview Prep',
  'Walk in confident, walk out hired',
  'Build mental confidence, prepare your mindset, and reduce anxiety before important interviews.',
  'work',
  'beginner',
  14,
  true,
  true,
  1
);

-- Career Transition
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'career'),
  'career-transition',
  'Career Transition',
  'Embrace the change ahead',
  'Navigate career changes with confidence. Build resilience, explore new paths, and embrace new beginnings.',
  'trending_up',
  'intermediate',
  30,
  false,
  true,
  2
);

-- Work-Life Balance
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'career'),
  'work-life-balance',
  'Work-Life Balance',
  'Success without sacrifice',
  'Set healthy boundaries, disconnect from work, and recharge. Create space for what matters most.',
  'balance',
  'beginner',
  21,
  true,
  true,
  3
);

-- Finding Your Purpose
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'career'),
  'finding-purpose',
  'Finding Your Purpose',
  'Discover what drives you',
  'Explore your passions, values, and strengths. Align your work with what gives your life meaning.',
  'explore',
  'intermediate',
  28,
  false,
  true,
  4
);

-- Leadership Growth
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'career'),
  'leadership-growth',
  'Leadership Growth',
  'Lead yourself first, then others',
  'Develop leadership skills starting with self-leadership. Build confidence, influence, and impact.',
  'leaderboard',
  'advanced',
  30,
  false,
  true,
  5
);

-- ============================================
-- TOPICS: MENTAL WELLNESS
-- ============================================

-- Anxiety Management
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'mental-wellness'),
  'anxiety-management',
  'Anxiety Management',
  'From overwhelm to calm',
  'Daily grounding practices, worry reduction techniques, and calming rituals to manage anxiety.',
  'spa',
  'beginner',
  30,
  true,
  true,
  1
);

-- Stress Relief
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'mental-wellness'),
  'stress-relief',
  'Stress Relief',
  'Exhale the pressure',
  'Decompress routines, mental reset techniques, and practices to release daily stress.',
  'air',
  'beginner',
  21,
  true,
  true,
  2
);

-- Building Resilience
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'mental-wellness'),
  'building-resilience',
  'Building Resilience',
  'Bounce back stronger',
  'Develop mental toughness, reframe setbacks, and build the strength to overcome challenges.',
  'shield',
  'intermediate',
  28,
  false,
  true,
  3
);

-- Confidence Building
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'mental-wellness'),
  'confidence-building',
  'Confidence Building',
  'Believe in your capability',
  'Challenge self-doubt, celebrate wins, and build unshakeable self-confidence.',
  'emoji_events',
  'beginner',
  21,
  true,
  true,
  4
);

-- Overthinking Control
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'mental-wellness'),
  'overthinking-control',
  'Overthinking Control',
  'Quiet the mental noise',
  'Break the cycle of rumination and learn to quiet an overactive mind.',
  'psychology',
  'intermediate',
  21,
  false,
  true,
  5
);

-- Depression Support
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'mental-wellness'),
  'depression-support',
  'Depression Support',
  'Small steps, big impact',
  'Gentle daily practices to support mental health during difficult times. Remember: seeking help is strength.',
  'favorite',
  'beginner',
  30,
  false,
  true,
  6
);

-- ============================================
-- TOPICS: HEALTH & HABITS
-- ============================================

-- Better Sleep
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'health-habits'),
  'better-sleep',
  'Better Sleep',
  'Wake up refreshed',
  'Wind-down routines, sleep hygiene habits, and practices for deeper, more restful sleep.',
  'bedtime',
  'beginner',
  21,
  true,
  true,
  1
);

-- Fitness Start
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'health-habits'),
  'fitness-start',
  'Fitness Start',
  'Every journey starts with one step',
  'Build an exercise habit incrementally. Start small, stay consistent, see results.',
  'directions_run',
  'beginner',
  30,
  true,
  true,
  2
);

-- Breaking Bad Habits
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'health-habits'),
  'breaking-bad-habits',
  'Breaking Bad Habits',
  'Replace, don''t just remove',
  'Identify triggers, build replacement habits, and break free from patterns that don''t serve you.',
  'block',
  'intermediate',
  28,
  false,
  true,
  3
);

-- Phone Detox
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'health-habits'),
  'phone-detox',
  'Phone Detox',
  'Reclaim your attention',
  'Reduce phone addiction, set digital boundaries, and be more present in real life.',
  'phonelink_off',
  'intermediate',
  21,
  true,
  true,
  4
);

-- Energy Boost
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'health-habits'),
  'energy-boost',
  'Energy Boost',
  'Feel alive again',
  'Morning activation, afternoon revival, and habits to maintain energy throughout the day.',
  'bolt',
  'beginner',
  14,
  false,
  true,
  5
);

-- Healthy Eating Mindset
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'health-habits'),
  'healthy-eating',
  'Healthy Eating Mindset',
  'Nourish your body with intention',
  'Build a healthy relationship with food through mindful eating practices and positive habits.',
  'restaurant',
  'beginner',
  21,
  false,
  true,
  6
);

-- ============================================
-- TOPICS: LIFE TRANSITIONS
-- ============================================

-- New City Fresh Start
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'life-transitions'),
  'new-city',
  'New City Fresh Start',
  'Bloom where you''re planted',
  'Adapt to new surroundings, build new routines, and find community in a new place.',
  'location_city',
  'beginner',
  30,
  false,
  true,
  1
);

-- Becoming a Parent
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'life-transitions'),
  'new-parent',
  'Becoming a Parent',
  'Care for yourself to care for them',
  'Self-care practices while caring for others. Maintain your identity while embracing parenthood.',
  'child_care',
  'intermediate',
  30,
  true,
  true,
  2
);

-- Post-Breakup Recovery
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'life-transitions'),
  'post-breakup',
  'Post-Breakup Recovery',
  'Rediscover yourself',
  'Rebuild your identity, rediscover your interests, and emerge stronger after a relationship ends.',
  'refresh',
  'intermediate',
  28,
  false,
  true,
  3
);

-- Major Life Change
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'life-transitions'),
  'major-change',
  'Major Life Change',
  'Change is the only constant',
  'General support for navigating any significant life transition with grace and resilience.',
  'autorenew',
  'beginner',
  21,
  true,
  true,
  4
);

-- Empty Nest
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'life-transitions'),
  'empty-nest',
  'Empty Nest',
  'A new chapter begins',
  'Rediscover yourself when children leave home. Find new purpose and embrace this next phase.',
  'home',
  'intermediate',
  30,
  false,
  true,
  5
);

-- Grief & Loss
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'life-transitions'),
  'grief-loss',
  'Grief & Loss',
  'Honouring what was',
  'Gentle practices for processing grief. There is no timeline for healing.',
  'sentiment_dissatisfied',
  'beginner',
  30,
  false,
  true,
  6
);

-- ============================================
-- TOPICS: GROWTH & MINDFULNESS
-- ============================================

-- Gratitude Practice
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'growth-mindfulness'),
  'gratitude-practice',
  'Gratitude Practice',
  'See the good that''s already there',
  'Notice the positive, shift your perspective, and cultivate appreciation for life.',
  'volunteer_activism',
  'beginner',
  21,
  true,
  true,
  1
);

-- Present Moment Living
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'growth-mindfulness'),
  'present-moment',
  'Present Moment Living',
  'Be here now',
  'Mindfulness practices to reduce overthinking and live fully in the present moment.',
  'self_improvement',
  'intermediate',
  28,
  true,
  true,
  2
);

-- Learning to Say No
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'growth-mindfulness'),
  'saying-no',
  'Learning to Say No',
  'Your boundaries matter',
  'Set healthy boundaries, prioritize yourself, and learn that "no" is a complete sentence.',
  'do_not_disturb',
  'intermediate',
  21,
  false,
  true,
  3
);

-- Financial Wellness
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'growth-mindfulness'),
  'financial-wellness',
  'Financial Wellness',
  'Peace of mind with money',
  'Build a healthy money mindset, reduce financial anxiety, and make intentional spending choices.',
  'savings',
  'beginner',
  30,
  false,
  true,
  4
);

-- Letting Go
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'growth-mindfulness'),
  'letting-go',
  'Letting Go',
  'Release what no longer serves you',
  'Practice non-attachment, release control, and find peace in accepting what is.',
  'air',
  'advanced',
  28,
  false,
  true,
  5
);

-- Daily Meditation
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'growth-mindfulness'),
  'daily-meditation',
  'Daily Meditation',
  'Still the mind, calm the soul',
  'Build a consistent meditation practice from scratch. Start with just 2 minutes a day.',
  'spa',
  'beginner',
  30,
  true,
  true,
  6
);

-- ============================================
-- TOPICS: SOCIAL CONNECTION
-- ============================================

-- Making New Friends
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'social-connection'),
  'making-friends',
  'Making New Friends',
  'Quality over quantity',
  'Build social confidence, conversation skills, and create meaningful friendships.',
  'group_add',
  'beginner',
  28,
  true,
  true,
  1
);

-- Social Anxiety
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'social-connection'),
  'social-anxiety',
  'Social Anxiety',
  'Small steps, big world',
  'Gradual exposure, comfort techniques, and practices to feel more at ease in social situations.',
  'groups',
  'intermediate',
  30,
  false,
  true,
  2
);

-- Family Relationships
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'social-connection'),
  'family-relationships',
  'Family Relationships',
  'Choose connection',
  'Navigate family dynamics with boundaries, communication skills, and forgiveness practices.',
  'family_restroom',
  'intermediate',
  21,
  false,
  true,
  3
);

-- Being More Outgoing
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'social-connection'),
  'being-outgoing',
  'Being More Outgoing',
  'Open up, reach out',
  'Build confidence to initiate conversations, attend events, and put yourself out there.',
  'emoji_people',
  'beginner',
  21,
  false,
  true,
  4
);

-- Giving Back
INSERT INTO ritual_topics (category_id, slug, name, tagline, description, icon, difficulty, estimated_days, is_featured, is_published, display_order)
VALUES (
  (SELECT id FROM ritual_categories WHERE slug = 'social-connection'),
  'giving-back',
  'Giving Back',
  'The joy of service',
  'Build habits of generosity, volunteering, and contributing to your community.',
  'volunteer_activism',
  'beginner',
  21,
  false,
  true,
  5
);

-- ============================================
-- RITUAL ITEMS: FINDING LOVE
-- ============================================

DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'finding-love';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning self-worth affirmation', 'Start your day by affirming your value and worthiness of love', 'Self-worth is the foundation of healthy relationships. When you believe you deserve love, you attract it.', 'Look in the mirror, make eye contact with yourself, and say: "I am worthy of deep, meaningful love. I bring value to any relationship."', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Identify one thing you love about yourself', 'Notice and appreciate something genuine about who you are', 'Building self-awareness of your positive qualities helps you understand what you bring to a relationship.', 'Reflect on your day. What moment made you proud? What quality did you demonstrate? Write it down or say it aloud.', 3, 'evening', 'daily', 2, true),
  (topic_id, 'Release past relationship energy', 'Let go of resentment, hurt, or baggage from past relationships', 'Holding onto past pain creates blocks to new love. Releasing it creates space for healthy connection.', 'Write down any lingering feelings about past relationships. Then, either burn the paper safely or tear it up while saying "I release this."', 10, 'evening', 'weekly', 3, true),
  (topic_id, 'Practice receiving compliments', 'When someone compliments you, simply say "thank you" without deflecting', 'Many people deflect compliments, which signals unworthiness. Learning to receive opens you to receiving love.', 'Notice when you want to deflect ("Oh, this old thing?"). Instead, pause, smile, and say "Thank you, that means a lot."', 1, 'anytime', 'daily', 4, true),
  (topic_id, 'Visualize your ideal partnership', 'Spend time imagining what a healthy, loving relationship looks like for you', 'Clarity about what you want helps you recognize it when it appears and avoid settling for less.', 'Close your eyes. Imagine a normal Tuesday evening with your future partner. How do you feel? How do they treat you? What are you doing together?', 5, 'morning', 'daily', 5, false),
  (topic_id, 'Do one thing that expands your world', 'Step outside your routine to increase chances of meeting new people', 'Love rarely knocks on a door that never opens. Expanding your world creates opportunities.', 'Try a new coffee shop, attend an event, take a different route, start a conversation with a stranger. Small expansions add up.', 15, 'anytime', 'daily', 6, false),
  (topic_id, 'Evening gratitude for connection', 'Appreciate the connections you already have', 'Gratitude for existing relationships raises your vibration and attracts more connection.', 'Name three people you''re grateful for today and why. Send one of them a quick message of appreciation.', 5, 'evening', 'daily', 7, true);
  
  -- Add affirmations for this topic
  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I am worthy of deep, unconditional love.', 1),
  (topic_id, 'The right person will recognize my value.', 2),
  (topic_id, 'I release past hurts and open my heart to new possibilities.', 3),
  (topic_id, 'I am complete on my own, and I choose to share my life with someone special.', 4),
  (topic_id, 'Love flows to me easily and effortlessly.', 5),
  (topic_id, 'I deserve a relationship that feels safe and supportive.', 6),
  (topic_id, 'My heart is open and ready for love.', 7),
  (topic_id, 'I attract partners who respect and cherish me.', 8);
  
  -- Add milestones
  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Heart Opening', 'You''ve committed to this journey for a full week', 7, 'One week of opening your heart! You''re building the foundation for love.', 1),
  (topic_id, 'Self-Worth Rising', 'Two weeks of recognizing your value', 14, 'Your self-worth is growing stronger every day. Keep going!', 2),
  (topic_id, 'Love Ready', 'You''ve completed the full 30-day journey', 30, 'You are ready. You''ve done the inner work. Now trust the timing.', 3);
  
  -- Add tips
  INSERT INTO ritual_tips (topic_id, title, content, day_to_show) VALUES
  (topic_id, 'Quality over urgency', 'Rushing into a relationship often means settling. Trust that the right person is worth waiting for.', 3),
  (topic_id, 'Red flags are not challenges', 'When someone shows you who they are, believe them. You can''t love someone into being right for you.', 7),
  (topic_id, 'Your standards protect you', 'Having standards isn''t being picky—it''s knowing your worth. Don''t lower them for anyone.', 12),
  (topic_id, 'Love yourself first', 'The relationship you have with yourself sets the template for every other relationship in your life.', 18),
  (topic_id, 'Be the partner you seek', 'Work on becoming the kind of partner you want to attract. Growth attracts growth.', 25);
END $$;

-- ============================================
-- RITUAL ITEMS: ANXIETY MANAGEMENT
-- ============================================

DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'anxiety-management';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning grounding ritual', 'Ground yourself before anxiety has a chance to build', 'Starting the day grounded sets a calm baseline. It''s easier to prevent anxiety than to calm it once activated.', 'Before getting out of bed, take 5 deep breaths. Feel your body on the mattress. Name 3 things you can hear. Wiggle your toes. Then slowly rise.', 3, 'morning', 'daily', 1, true),
  (topic_id, '4-7-8 breathing exercise', 'A proven technique to activate your body''s calm response', 'This breathing pattern stimulates the vagus nerve, triggering your parasympathetic nervous system (rest & digest mode).', 'Breathe in through your nose for 4 counts. Hold for 7 counts. Exhale slowly through your mouth for 8 counts. Repeat 4 times.', 3, 'anytime', 'as_needed', 2, true),
  (topic_id, 'Worry time container', 'Schedule your worrying instead of letting it control your day', 'Giving worry a designated time reduces its power over your entire day. You''re not ignoring worries—just containing them.', 'Set a 10-minute "worry appointment" at the same time each day. When worries arise outside this time, write them down and say "I''ll address you at worry time."', 10, 'afternoon', 'daily', 3, true),
  (topic_id, 'Body scan for tension', 'Identify where you''re holding anxiety in your body', 'Anxiety often manifests physically before we notice it mentally. Body awareness is early detection.', 'Close your eyes. Scan from head to toe. Notice: Is your jaw clenched? Shoulders raised? Stomach tight? Wherever you find tension, breathe into it and release.', 5, 'anytime', 'daily', 4, true),
  (topic_id, '5-4-3-2-1 sensory grounding', 'Use your senses to anchor yourself in the present moment', 'Anxiety pulls you into "what if" futures. This technique forces your brain back to the present moment.', 'Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste. Take your time with each one.', 5, 'anytime', 'as_needed', 5, true),
  (topic_id, 'Evening worry download', 'Clear anxious thoughts before sleep', 'Writing worries externalizes them, preventing rumination loops that keep you awake.', 'Before bed, write down everything on your mind. Don''t organize or solve—just dump. Then close the notebook and say "I''ll handle this tomorrow."', 5, 'evening', 'daily', 6, true),
  (topic_id, 'Cold water reset', 'Use the dive reflex to instantly calm your nervous system', 'Cold water on your face triggers the mammalian dive reflex, immediately lowering heart rate and calming the body.', 'Run cold water over your wrists for 30 seconds, or splash cold water on your face. For intense anxiety, hold a cold pack to your face.', 2, 'anytime', 'as_needed', 7, false),
  (topic_id, 'Gratitude shift', 'Redirect your mind from threat to appreciation', 'Anxiety and gratitude can''t occupy the same mental space. Gratitude is a pattern interrupt.', 'When anxiety rises, pause and name 3 specific things you''re grateful for RIGHT NOW. Be specific: "The warmth of this coffee" not "coffee."', 2, 'anytime', 'daily', 8, false);
  
  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'This feeling will pass. It always does.', 1),
  (topic_id, 'I am safe in this moment.', 2),
  (topic_id, 'My anxiety does not define me.', 3),
  (topic_id, 'I can feel anxious and still be okay.', 4),
  (topic_id, 'I have survived 100% of my worst days.', 5),
  (topic_id, 'Breath by breath, I return to calm.', 6),
  (topic_id, 'My nervous system is learning to feel safe.', 7),
  (topic_id, 'I release what I cannot control.', 8);
  
  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Grounding Begun', 'One week of daily grounding practice', 7, 'You''re building a foundation of calm. Your nervous system is starting to learn new patterns.', 1),
  (topic_id, 'Tools Equipped', 'Two weeks of anxiety management', 14, 'You now have a toolkit of techniques. Remember: you can handle whatever comes.', 2),
  (topic_id, 'Calm Cultivated', 'A full month of practice', 30, 'You''ve rewired your response to anxiety. It may still visit, but it no longer lives rent-free.', 3);
  
  INSERT INTO ritual_tips (topic_id, title, content, day_to_show) VALUES
  (topic_id, 'Anxiety is not the enemy', 'Anxiety is your brain trying to protect you. Thank it, then show it that you''re safe.', 2),
  (topic_id, 'Movement helps', 'Anxiety is energy. Sometimes the best cure is to move your body—walk, stretch, shake it out.', 8),
  (topic_id, 'Caffeine check', 'Caffeine can mimic and amplify anxiety symptoms. Consider how your intake affects your baseline.', 14),
  (topic_id, 'It''s not about elimination', 'The goal isn''t to never feel anxious—it''s to respond to anxiety rather than react to it.', 21);
END $$;

-- ============================================
-- RITUAL ITEMS: BETTER SLEEP
-- ============================================

DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'better-sleep';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Set a consistent wake time', 'Wake up at the same time every day, even weekends', 'Your circadian rhythm thrives on consistency. A regular wake time is more important than bedtime.', 'Choose a wake time and stick to it within 30 minutes, 7 days a week. Your body will start waking naturally before your alarm.', 1, 'morning', 'daily', 1, true),
  (topic_id, 'Morning light exposure', 'Get bright light within 30 minutes of waking', 'Morning light resets your circadian clock and helps your body produce melatonin at the right time later.', 'Go outside for 5-10 minutes after waking. If that''s impossible, use a light therapy lamp or sit by a bright window while having breakfast.', 10, 'morning', 'daily', 2, true),
  (topic_id, 'Caffeine curfew', 'No caffeine after 2pm (or 8 hours before bed)', 'Caffeine has a half-life of 5-6 hours. That afternoon coffee is still 25% active at midnight.', 'Set a hard cutoff time for caffeine. If you must have something warm, try herbal tea or decaf after your curfew.', 1, 'afternoon', 'daily', 3, true),
  (topic_id, 'Digital sunset', 'Stop screens 1 hour before bed', 'Blue light suppresses melatonin production. Plus, content can be mentally stimulating.', 'Set an alarm for 1 hour before bed. When it goes off, put devices in another room. Read, stretch, or talk instead.', 60, 'evening', 'daily', 4, true),
  (topic_id, 'Evening wind-down routine', 'Create a consistent pre-sleep ritual', 'Routines signal to your brain that sleep is coming, triggering the wind-down process automatically.', 'Create a 20-30 minute routine: dim lights, brush teeth, skincare, light stretching, reading. Do it in the same order nightly.', 30, 'evening', 'daily', 5, true),
  (topic_id, 'Brain dump before bed', 'Clear your mind of tomorrow''s concerns', 'An active mind is the #1 cause of insomnia. Externalizing thoughts stops rumination loops.', 'Keep a notebook by your bed. Before sleep, write down: tomorrow''s priorities, any worries, and anything else on your mind. Then close it.', 5, 'evening', 'daily', 6, true),
  (topic_id, 'Cool bedroom check', 'Ensure your bedroom is cool (65-68°F / 18-20°C)', 'Your body temperature naturally drops for sleep. A cool room supports this process.', 'Check your thermostat. Open a window if possible. Consider lighter bedding. Your feet can be under covers while keeping the room cool.', 2, 'evening', 'daily', 7, false),
  (topic_id, 'Body scan relaxation', 'Systematically relax your body for sleep', 'Physical tension keeps you awake. Progressive relaxation signals safety to your nervous system.', 'Lying in bed, tense then release each muscle group from toes to head. Spend 5 seconds tensing, then let go completely. Notice the warmth.', 10, 'evening', 'daily', 8, true);
  
  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'Sleep comes naturally to me.', 1),
  (topic_id, 'I release the day and welcome rest.', 2),
  (topic_id, 'My body knows how to sleep deeply.', 3),
  (topic_id, 'Tomorrow''s challenges can wait until tomorrow.', 4),
  (topic_id, 'I am safe to let go and rest.', 5),
  (topic_id, 'Each night, my sleep improves.', 6);
  
  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Routine Established', 'One week of consistent sleep hygiene', 7, 'You''re training your brain for better sleep. Keep building those neural pathways.', 1),
  (topic_id, 'Pattern Forming', 'Two weeks of better sleep habits', 14, 'Your body is starting to expect sleep at the right times. Notice if you''re waking more naturally.', 2),
  (topic_id, 'Sleep Restored', 'Three weeks of practice', 21, 'Research shows 21 days builds a habit. You''ve transformed your relationship with sleep.', 3);
END $$;

-- ============================================
-- RITUAL ITEMS: CONFIDENCE BUILDING
-- ============================================

DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'confidence-building';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Power pose morning', 'Start your day in a confident physical posture', 'Your body influences your mind. Research shows expansive postures increase testosterone and decrease cortisol.', 'After waking, stand tall with feet wide, hands on hips (Wonder Woman pose) or arms raised in a V. Hold for 2 minutes. Breathe deeply.', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Daily win acknowledgment', 'Recognize and celebrate one thing you did well', 'Confident people aren''t more successful—they''re better at noticing their successes. This builds evidence.', 'Each evening, identify ONE win from today. It can be small: "I spoke up in the meeting" or "I helped someone." Say it aloud: "I did that."', 2, 'evening', 'daily', 2, true),
  (topic_id, 'Challenge the inner critic', 'Notice and reframe negative self-talk', 'We all have an inner critic. Confident people don''t have a quieter critic—they challenge it.', 'When you notice self-criticism, ask: "Would I say this to a friend?" Reframe the thought as you would for someone you love.', 3, 'anytime', 'as_needed', 3, true),
  (topic_id, 'One uncomfortable thing', 'Do something slightly outside your comfort zone daily', 'Confidence grows through action, not preparation. Small brave acts compound into boldness.', 'Identify one small uncomfortable thing: speak up, make eye contact, introduce yourself, share your opinion. Do it. That''s today''s win.', 5, 'anytime', 'daily', 4, true),
  (topic_id, 'Body language check', 'Notice and adjust your posture throughout the day', 'Slouching, crossing arms, and looking down all signal low confidence—to yourself and others.', 'Set 3 random alarms. When they go off, check: Are your shoulders back? Is your chin level? Are you making eye contact? Adjust.', 1, 'anytime', 'daily', 5, false),
  (topic_id, 'Confidence journaling', 'Write about a time you felt confident', 'Reliving confident moments reinforces neural pathways and makes confidence more accessible.', 'Describe a time you felt unstoppable. What were you doing? How did you feel? What did you accomplish? Let yourself re-experience it.', 5, 'evening', 'daily', 6, true),
  (topic_id, 'Prepare one talking point', 'Have something ready to contribute in conversations', 'Confidence in social situations comes from having something to say. Preparation enables spontaneity.', 'Before meetings or social events, prepare one interesting thing to share: a question, an observation, or a small story. Just one.', 3, 'morning', 'daily', 7, false),
  (topic_id, 'Mirror affirmation', 'Speak confidence into existence', 'Hearing your own voice declare positive truths rewires your self-image over time.', 'Look yourself in the eyes in a mirror. Say: "I am capable. I am worthy. I belong in any room I enter." Mean it.', 2, 'morning', 'daily', 8, true);
  
  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I am enough, exactly as I am.', 1),
  (topic_id, 'I belong in any room I enter.', 2),
  (topic_id, 'My voice matters and deserves to be heard.', 3),
  (topic_id, 'I am capable of handling whatever comes.', 4),
  (topic_id, 'Confidence is a skill, and I am building it daily.', 5),
  (topic_id, 'I release the need for others'' approval.', 6),
  (topic_id, 'My worth is not determined by my achievements.', 7),
  (topic_id, 'I celebrate my progress, not just my perfection.', 8);
  
  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Foundation Laid', 'One week of confidence-building', 7, 'You''re showing up for yourself every day. That IS confidence.', 1),
  (topic_id, 'Inner Voice Shifting', 'Two weeks of practice', 14, 'Your inner dialogue is changing. You''re catching the critic more often now.', 2),
  (topic_id, 'Confidence Embodied', 'Three weeks of growth', 21, 'Confidence isn''t the absence of doubt—it''s moving forward anyway. You''ve proven you can.', 3);
END $$;

-- ============================================
-- RITUAL ITEMS: GRATITUDE PRACTICE
-- ============================================

DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'gratitude-practice';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning gratitude moment', 'Start your day by noticing what''s good', 'Gratitude first thing sets a positive filter for your entire day. Your brain starts scanning for good.', 'Before getting out of bed, think of 3 things you''re grateful for. Be specific: not "family" but "the way my daughter laughs at breakfast."', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Gratitude for challenges', 'Find the lesson or growth in something difficult', 'True gratitude includes hard things. Reframing challenges as teachers transforms suffering into growth.', 'Think of one challenge you''re facing. Ask: "What is this teaching me? How might this make me stronger?" Write it down.', 3, 'evening', 'daily', 2, true),
  (topic_id, 'Thank someone silently', 'Send gratitude to someone without them knowing', 'Gratitude doesn''t require the other person to know. The practice itself changes YOU.', 'Think of someone who helped you, even in a small way. In your mind, say "Thank you for ____." Feel it genuinely.', 1, 'anytime', 'daily', 3, false),
  (topic_id, 'Gratitude letter (unsent)', 'Write a heartfelt thank-you to someone', 'Deep gratitude writing activates more neural pathways than just thinking grateful thoughts.', 'Choose someone who impacted your life. Write them a letter explaining how they helped you. You don''t have to send it.', 10, 'anytime', 'weekly', 4, false),
  (topic_id, 'Evening gratitude journal', 'End your day by recording what went well', 'Writing gratitude before sleep shifts your brain from problem-mode to appreciation-mode.', 'Write 3 good things from today. For each, add: why it happened, and why it matters to you. This deepens the practice.', 5, 'evening', 'daily', 5, true),
  (topic_id, 'Gratitude for your body', 'Appreciate what your body does for you', 'We often criticize our bodies. Gratitude for what it DOES (not how it looks) builds a healthier relationship.', 'Name 3 things your body did for you today: "My legs carried me. My lungs breathed. My hands created."', 2, 'evening', 'daily', 6, true),
  (topic_id, 'Say thank you meaningfully', 'Express genuine gratitude to someone today', 'Expressed gratitude strengthens relationships and doubles the impact—for you AND them.', 'Find an opportunity to thank someone genuinely. Be specific about what they did and why it mattered. Look them in the eye.', 2, 'anytime', 'daily', 7, true),
  (topic_id, 'Ordinary moment appreciation', 'Notice something ordinary that''s actually extraordinary', 'We overlook daily miracles. Clean water, warm beds, safe homes—billions lack what we take for granted.', 'Pause during a mundane moment (morning coffee, hot shower). Really notice it. Say: "This is actually amazing."', 1, 'anytime', 'daily', 8, false);
  
  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'There is always something to be grateful for.', 1),
  (topic_id, 'Gratitude transforms what I have into enough.', 2),
  (topic_id, 'I see abundance all around me.', 3),
  (topic_id, 'Even in difficulty, blessings are present.', 4),
  (topic_id, 'My life is full of small wonders.', 5),
  (topic_id, 'I appreciate what is, while working toward what could be.', 6),
  (topic_id, 'Gratitude is my natural state.', 7);
  
  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Eyes Opening', 'One week of gratitude practice', 7, 'You''re starting to notice more good in your days. Keep looking!', 1),
  (topic_id, 'Perspective Shifting', 'Two weeks of appreciation', 14, 'Your brain is rewiring to scan for positivity. That''s powerful.', 2),
  (topic_id, 'Gratitude Embodied', 'Three weeks of practice', 21, 'Gratitude is becoming your default lens. You''ll never see the world the same way.', 3);
END $$;

-- ============================================
-- RITUAL ITEMS: WORK-LIFE BALANCE
-- ============================================

DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'work-life-balance';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Define your hard stop', 'Set a non-negotiable end to your work day', 'Without a clear boundary, work expands to fill all available time. A hard stop protects your life.', 'Choose your work end time. Set an alarm. When it goes off, save your work and close your laptop. No exceptions.', 1, 'evening', 'daily', 1, true),
  (topic_id, 'Morning intention: one priority', 'Identify the ONE thing that would make today a win', 'Endless to-do lists create anxiety. One clear priority creates focus and achievable satisfaction.', 'Before starting work, ask: "If I could only accomplish ONE thing today, what would make the biggest difference?" That''s your priority.', 3, 'morning', 'daily', 2, true),
  (topic_id, 'Lunch away from desk', 'Take a real break midday', 'Eating at your desk isn''t a break. Actual separation restores energy and creativity.', 'Leave your workspace for lunch. Even 15 minutes. Eat mindfully. Look at something other than a screen. Let your mind wander.', 15, 'afternoon', 'daily', 3, true),
  (topic_id, 'Device-free evening hour', 'One hour of no work devices', 'Physical separation from devices creates mental separation from work. Your brain needs the signal.', 'Put work devices in another room for at least 1 hour each evening. Be present with family, hobbies, or yourself.', 60, 'evening', 'daily', 4, true),
  (topic_id, 'Weekly review & reset', 'Reflect on what worked and adjust', 'Without reflection, you repeat the same patterns. Weekly review creates intentional improvement.', 'Each Sunday: What went well this week? What drained me? What will I do differently? What am I looking forward to?', 15, 'anytime', 'weekly', 5, true),
  (topic_id, 'Schedule personal time first', 'Block life before work fills it', 'If you schedule work first, life gets the scraps. Schedule exercise, family, rest FIRST, then work around it.', 'At the start of each week, block time for: exercise, family, rest, and one joy activity. Treat these as non-negotiable meetings.', 10, 'morning', 'weekly', 6, true),
  (topic_id, 'Two-minute transition ritual', 'Create a clear boundary between work and life', 'Rituals signal to your brain that a context change is happening. This prevents work bleed.', 'When work ends, do a 2-minute ritual: close all tabs, write tomorrow''s priority, change clothes, wash hands—anything that signals "work is done."', 2, 'evening', 'daily', 7, true),
  (topic_id, 'Reclaim one lunch per week', 'Have lunch with someone you care about', 'Work often steals connection time. Reclaiming one lunch protects relationships.', 'Block one lunch per week for non-work connection: a friend, family member, or even yourself doing something enjoyable.', 45, 'afternoon', 'weekly', 8, false);
  
  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'My worth is not measured by my productivity.', 1),
  (topic_id, 'Rest makes me more effective, not less.', 2),
  (topic_id, 'I have permission to leave work at work.', 3),
  (topic_id, 'My time outside work is valuable and protected.', 4),
  (topic_id, 'I can be successful AND have a life I enjoy.', 5),
  (topic_id, 'Boundaries are an act of self-respect.', 6),
  (topic_id, 'There will always be more to do. I am enough today.', 7);
  
  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Boundaries Set', 'One week of intentional balance', 7, 'You''re taking back your time. Notice how it feels to have clear edges.', 1),
  (topic_id, 'Balance Building', 'Two weeks of practice', 14, 'Your life is expanding beyond work. This is what sustainable success looks like.', 2),
  (topic_id, 'Life Reclaimed', 'Three weeks of balance', 21, 'You''ve proven that boundaries don''t hurt performance—they enable sustainability.', 3);
END $$;

-- ============================================
-- Add more ritual items for remaining topics...
-- (Following the same pattern for other topics)
-- ============================================

-- Add default rituals for STRESS RELIEF
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'stress-relief';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning stress prevention', 'Start before stress does', 'A calm morning creates resilience for the day. You build a buffer before challenges arrive.', 'Wake 15 minutes earlier. No phone for the first 30 minutes. Breathe, stretch, drink water. Enter the day calm, not rushed.', 15, 'morning', 'daily', 1, true),
  (topic_id, 'Breath breaks', 'Micro-moments of calm throughout the day', 'Regular breathing breaks prevent stress accumulation. Small releases keep the pressure valve open.', 'Set 3-4 alarms throughout the day. When they ring, take 6 slow breaths. That''s it. Then continue.', 1, 'anytime', 'daily', 2, true),
  (topic_id, 'Physical tension release', 'Move stress out of your body', 'Stress creates physical tension. Movement releases it. Your body and mind are connected.', 'Choose one: 10 jumping jacks, shake your body for 30 seconds, do a forward fold, or roll your shoulders 10 times. Move the stress OUT.', 2, 'anytime', 'daily', 3, true),
  (topic_id, 'Nature moment', 'Connect with something natural', 'Nature exposure lowers cortisol, blood pressure, and stress hormones. Even brief contact helps.', 'Step outside for 5 minutes. No phone. Feel the air, look at the sky, notice plants or trees. Let nature reset you.', 5, 'afternoon', 'daily', 4, true),
  (topic_id, 'Evening decompression', 'Release the day before sleep', 'What you don''t release, you carry to bed. Evening decompression prevents sleep-disrupting stress.', 'Write down anything still on your mind. Do 5 minutes of stretching. Take a warm shower. Signal to your body: the day is done.', 15, 'evening', 'daily', 5, true);
  
  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I release what I cannot control.', 1),
  (topic_id, 'This too shall pass.', 2),
  (topic_id, 'I am bigger than my stress.', 3),
  (topic_id, 'Peace is always available to me.', 4),
  (topic_id, 'I exhale tension, I inhale calm.', 5);
END $$;

-- Add default rituals for DAILY MEDITATION
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'daily-meditation';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning meditation', 'Start with stillness', 'Morning meditation sets the tone for your entire day. You train your mind before it trains you.', 'Sit comfortably. Set a timer for 5 minutes (increase as you progress). Focus on your breath. When your mind wanders, gently return. That''s it.', 5, 'morning', 'daily', 1, true),
  (topic_id, 'One mindful minute', 'Brief awareness throughout the day', 'You don''t need 30 minutes. Even one minute of presence builds the habit and provides benefits.', 'At random moments, pause everything. Close your eyes. Take 3 deep breaths. Notice how you feel. Open your eyes. Continue.', 1, 'anytime', 'daily', 2, true),
  (topic_id, 'Walking meditation', 'Meditate in motion', 'Not everyone can sit still. Walking meditation brings awareness to movement, making it accessible.', 'Walk slowly and deliberately for 5 minutes. Feel each footstep. Notice the sensation of movement. When distracted, return to the feeling of walking.', 5, 'anytime', 'daily', 3, false),
  (topic_id, 'Evening gratitude meditation', 'End with appreciation', 'Combining gratitude with meditation compounds benefits. You train both attention and positivity.', 'Sit quietly for 5 minutes. With each exhale, mentally say something you''re grateful for from today. Let the feeling fill you.', 5, 'evening', 'daily', 4, true),
  (topic_id, 'Body scan meditation', 'Cultivate body awareness', 'The body holds wisdom the mind ignores. Body scanning builds the connection between physical and mental.', 'Lie down or sit comfortably. Starting from your feet, slowly move attention up through your body. Notice sensations without judging.', 10, 'evening', 'daily', 5, false);
  
  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'Stillness is my natural state.', 1),
  (topic_id, 'I am not my thoughts; I am the observer.', 2),
  (topic_id, 'Every breath is a new beginning.', 3),
  (topic_id, 'Peace is always available within me.', 4),
  (topic_id, 'My mind is a tool I am learning to use wisely.', 5);
  
  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Practice Started', 'One week of daily meditation', 7, 'You''re building the most powerful habit for mental health. 7 days is huge!', 1),
  (topic_id, 'Neural Pathways Forming', 'Two weeks of practice', 14, 'Brain scans show changes in just 2 weeks of meditation. You''re literally changing your brain.', 2),
  (topic_id, 'Meditator', 'One month of practice', 30, 'You''ve built a meditation practice. This is a skill you''ll have for life.', 3);
END $$;

-- Final update to mark all content as published
UPDATE ritual_topics SET is_published = true;
UPDATE ritual_categories SET is_active = true;

