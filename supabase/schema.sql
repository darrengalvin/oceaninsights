-- ============================================
-- OCEAN INSIGHT CONTENT MANAGEMENT SCHEMA
-- Run this in Supabase SQL Editor
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- DOMAINS (Life Areas)
-- ============================================
CREATE TABLE domains (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT DEFAULT 'circle',
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default domains
INSERT INTO domains (slug, name, description, icon, display_order) VALUES
  ('relationships', 'Relationships & Connection', 'Partners, friendships, and connections', 'favorite_outline', 1),
  ('family', 'Family, Parenting & Home Life', 'Parents, children, and home', 'home_outlined', 2),
  ('identity', 'Identity, Belonging & Inclusion', 'Know yourself better', 'psychology_outlined', 3),
  ('grief', 'Grief, Change & Life Events', 'Navigating life transitions', 'autorenew', 4),
  ('calm', 'Calm, Confidence & Emotional Skills', 'Your mind and emotions', 'spa_outlined', 5),
  ('sleep', 'Sleep, Energy & Recovery', 'Rest and restoration', 'bedtime_outlined', 6),
  ('health', 'Health, Injury & Physical Wellbeing', 'Body and wellness', 'fitness_center_outlined', 7),
  ('money', 'Money, Housing & Practical Life', 'Money and security', 'account_balance_outlined', 8),
  ('work', 'Work, Purpose & Service Culture', 'Work, growth, and direction', 'work_outline', 9),
  ('leadership', 'Leadership, Boundaries & Communication', 'Leading yourself and others', 'groups_outlined', 10),
  ('transition', 'Transition, Resettlement & Civilian Life', 'Service, transition, and beyond', 'shield_outlined', 11);

-- ============================================
-- CONTENT ITEMS (The tappable options)
-- ============================================
CREATE TYPE pillar_type AS ENUM ('understand', 'reflect', 'grow', 'support');
CREATE TYPE audience_type AS ENUM ('any', 'service_member', 'veteran', 'partner_family');
CREATE TYPE sensitivity_type AS ENUM ('normal', 'sensitive', 'urgent');

CREATE TABLE content_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug TEXT UNIQUE NOT NULL,
  domain_id UUID REFERENCES domains(id) ON DELETE CASCADE,
  pillar pillar_type NOT NULL,
  label TEXT NOT NULL,
  microcopy TEXT,
  audience audience_type DEFAULT 'any',
  sensitivity sensitivity_type DEFAULT 'normal',
  disclosure_level INTEGER DEFAULT 1 CHECK (disclosure_level BETWEEN 1 AND 3),
  keywords TEXT[] DEFAULT '{}',
  is_published BOOLEAN DEFAULT false,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_content_items_domain ON content_items(domain_id);
CREATE INDEX idx_content_items_pillar ON content_items(pillar);
CREATE INDEX idx_content_items_published ON content_items(is_published);
CREATE INDEX idx_content_items_keywords ON content_items USING GIN(keywords);

-- ============================================
-- CONTENT DETAILS (The deep content)
-- ============================================
CREATE TABLE content_details (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content_item_id UUID UNIQUE REFERENCES content_items(id) ON DELETE CASCADE,
  
  -- Understand section
  understand_title TEXT,
  understand_body TEXT,
  understand_insights TEXT[] DEFAULT '{}',
  
  -- Reflect section
  reflect_prompts TEXT[] DEFAULT '{}',
  
  -- Grow section
  grow_title TEXT,
  grow_steps JSONB DEFAULT '[]',  -- Array of {action, detail}
  
  -- Support section (for sensitive/urgent items)
  support_intro TEXT,
  support_resources JSONB DEFAULT '[]',  -- Array of {name, description, contact}
  
  -- Closing
  affirmation TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CONTENT CONNECTIONS (Related items)
-- ============================================
CREATE TYPE connection_type AS ENUM ('leads_to', 'related', 'prerequisite');

CREATE TABLE content_connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  from_item_id UUID REFERENCES content_items(id) ON DELETE CASCADE,
  to_item_id UUID REFERENCES content_items(id) ON DELETE CASCADE,
  connection_type connection_type DEFAULT 'related',
  UNIQUE(from_item_id, to_item_id, connection_type)
);

-- ============================================
-- JOURNEYS (Curated pathways)
-- ============================================
CREATE TABLE journeys (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  audience audience_type DEFAULT 'any',
  item_sequence UUID[] DEFAULT '{}',  -- Ordered array of content_item_ids
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SYNC TRACKING (For app to know what changed)
-- ============================================
CREATE TABLE sync_metadata (
  id INTEGER PRIMARY KEY DEFAULT 1,
  last_content_update TIMESTAMPTZ DEFAULT NOW(),
  content_version INTEGER DEFAULT 1
);

INSERT INTO sync_metadata (id, last_content_update, content_version) VALUES (1, NOW(), 1);

-- Function to update sync metadata when content changes
CREATE OR REPLACE FUNCTION update_sync_metadata()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE sync_metadata 
  SET last_content_update = NOW(), 
      content_version = content_version + 1
  WHERE id = 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to update sync metadata
CREATE TRIGGER content_items_sync_trigger
AFTER INSERT OR UPDATE OR DELETE ON content_items
FOR EACH STATEMENT EXECUTE FUNCTION update_sync_metadata();

CREATE TRIGGER content_details_sync_trigger
AFTER INSERT OR UPDATE OR DELETE ON content_details
FOR EACH STATEMENT EXECUTE FUNCTION update_sync_metadata();

-- ============================================
-- ROW LEVEL SECURITY (Critical for security!)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE journeys ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_metadata ENABLE ROW LEVEL SECURITY;

-- Public read access (using anon key) - ONLY published content
CREATE POLICY "Public can read active domains" ON domains
  FOR SELECT USING (is_active = true);

CREATE POLICY "Public can read published content" ON content_items
  FOR SELECT USING (is_published = true);

CREATE POLICY "Public can read details of published content" ON content_details
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM content_items 
      WHERE content_items.id = content_details.content_item_id 
      AND content_items.is_published = true
    )
  );

CREATE POLICY "Public can read connections of published content" ON content_connections
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM content_items 
      WHERE content_items.id = content_connections.from_item_id 
      AND content_items.is_published = true
    )
  );

CREATE POLICY "Public can read published journeys" ON journeys
  FOR SELECT USING (is_published = true);

CREATE POLICY "Public can read sync metadata" ON sync_metadata
  FOR SELECT USING (true);

-- Service role (admin) has full access - no policies needed as service_role bypasses RLS

-- ============================================
-- VIEWS (For easier querying)
-- ============================================

-- Full content view with domain info
CREATE VIEW content_full AS
SELECT 
  ci.id,
  ci.slug,
  ci.label,
  ci.microcopy,
  ci.pillar,
  ci.audience,
  ci.sensitivity,
  ci.disclosure_level,
  ci.keywords,
  ci.is_published,
  d.slug as domain_slug,
  d.name as domain_name,
  d.icon as domain_icon,
  cd.understand_title,
  cd.understand_body,
  cd.understand_insights,
  cd.reflect_prompts,
  cd.grow_title,
  cd.grow_steps,
  cd.support_intro,
  cd.support_resources,
  cd.affirmation
FROM content_items ci
JOIN domains d ON ci.domain_id = d.id
LEFT JOIN content_details cd ON ci.id = cd.content_item_id;

-- ============================================
-- SAMPLE CONTENT (So it's not empty)
-- ============================================

-- Get the relationships domain ID
DO $$
DECLARE
  rel_domain_id UUID;
  item_id UUID;
BEGIN
  SELECT id INTO rel_domain_id FROM domains WHERE slug = 'relationships';
  
  -- Insert a sample content item
  INSERT INTO content_items (slug, domain_id, pillar, label, microcopy, audience, is_published, keywords)
  VALUES (
    'relationships.understand.trust-and-safety',
    rel_domain_id,
    'understand',
    'How Trust Is Built',
    'Healthy relationships are built on a foundation of trust. This takes time and requires consistent actions, not just words.',
    'any',
    true,
    ARRAY['trust', 'safety', 'relationships', 'partnership', 'honesty', 'communication']
  )
  RETURNING id INTO item_id;
  
  -- Insert the details
  INSERT INTO content_details (content_item_id, understand_title, understand_body, understand_insights, affirmation)
  VALUES (
    item_id,
    'Understanding Trust in Relationships',
    'Healthy relationships are built on a foundation of trust. This means feeling safe to be yourself, knowing your partner will be honest, and believing they have your best interests at heart. Trust takes time to build and requires consistent actions, not just words.

Trust isn''t about perfection - it''s about reliability. It''s built through small moments: keeping promises, being present, responding with care when things go wrong.

When trust has been damaged, rebuilding takes patience. It requires the person who broke trust to be consistently reliable over time, and the person hurt to be willing to gradually open up again.',
    ARRAY[
      'Trust is built through consistent small actions, not grand gestures',
      'Feeling safe to be vulnerable is a sign of healthy trust',
      'Rebuilding trust after it''s broken takes time and patience from both people'
    ],
    'You deserve relationships where you feel safe.'
  );
END $$;

COMMENT ON TABLE content_items IS 'Main content items - the tappable options users see';
COMMENT ON TABLE content_details IS 'Deep content for each item - the actual guidance';
COMMENT ON TABLE journeys IS 'Curated pathways through related content';

