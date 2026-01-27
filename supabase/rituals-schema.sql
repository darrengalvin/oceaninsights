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
