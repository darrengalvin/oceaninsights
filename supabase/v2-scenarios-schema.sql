-- Below the Surface v2.0 - Scenario Engine Schema
-- Decision training system with scenarios, options, and protocols

-- Content Packs (organize scenarios and protocols)
CREATE TABLE IF NOT EXISTS content_packs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT, -- lucide icon name
  unlock_criteria JSONB, -- { totalDecisions: 10, tags: ['conflict'] }
  sort_order INTEGER DEFAULT 0,
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scenarios (decision training situations)
CREATE TABLE IF NOT EXISTS scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  situation TEXT NOT NULL, -- 2-3 sentences describing the situation
  context TEXT NOT NULL CHECK (context IN ('hierarchy', 'peer', 'high-pressure', 'close-quarters', 'leadership', 'military_workplace', 'civilian_workplace', 'family', 'social')),
  difficulty INTEGER NOT NULL CHECK (difficulty BETWEEN 1 AND 3),
  content_pack_id UUID REFERENCES content_packs(id) ON DELETE SET NULL,
  tags TEXT[] DEFAULT '{}', -- for filtering and unlocks
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scenario Options (response choices)
CREATE TABLE IF NOT EXISTS scenario_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  text TEXT NOT NULL, -- The response option text
  tags TEXT[] NOT NULL DEFAULT '{}', -- e.g. ['direct', 'assertive', 'delayed']
  immediate_outcome TEXT NOT NULL, -- What happens right away
  longterm_outcome TEXT NOT NULL, -- Potential long-term effects
  risk_level TEXT NOT NULL CHECK (risk_level IN ('low', 'medium', 'high')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Perspective Shifts (how the choice lands with different people)
CREATE TABLE IF NOT EXISTS perspective_shifts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  option_id UUID NOT NULL REFERENCES scenario_options(id) ON DELETE CASCADE,
  viewpoint TEXT NOT NULL CHECK (viewpoint IN ('command', 'peer', 'subordinate', 'external')),
  interpretation TEXT NOT NULL, -- How this choice is seen from this viewpoint
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Communication Protocols (step-by-step guides)
CREATE TABLE IF NOT EXISTS protocols (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('communication', 'conflict', 'self-regulation', 'trust', 'recovery')),
  description TEXT, -- Brief overview
  steps JSONB NOT NULL, -- Array of { step: number, title: string, description: string }
  when_to_use TEXT,
  when_not_to_use TEXT,
  common_failures TEXT[],
  related_scenario_ids UUID[],
  content_pack_id UUID REFERENCES content_packs(id) ON DELETE SET NULL,
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Anonymous Analytics (aggregate data only, for admin learning)
CREATE TABLE IF NOT EXISTS analytics_monthly (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  month DATE NOT NULL UNIQUE,
  scenario_completions JSONB DEFAULT '{}', -- { scenarioId: count }
  option_selections JSONB DEFAULT '{}', -- { optionId: count }
  communication_styles JSONB DEFAULT '{}', -- { direct: count, indirect: count, etc }
  protocol_views JSONB DEFAULT '{}', -- { protocolId: count }
  total_active_users INTEGER DEFAULT 0,
  total_decisions INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sync metadata for scenarios (track versions for offline sync)
CREATE TABLE IF NOT EXISTS scenario_sync_metadata (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  version INTEGER NOT NULL DEFAULT 1
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_scenarios_published ON scenarios(published) WHERE published = true;
CREATE INDEX IF NOT EXISTS idx_scenarios_context ON scenarios(context);
CREATE INDEX IF NOT EXISTS idx_scenarios_pack ON scenarios(content_pack_id);
CREATE INDEX IF NOT EXISTS idx_scenario_options_scenario ON scenario_options(scenario_id);
CREATE INDEX IF NOT EXISTS idx_perspective_shifts_option ON perspective_shifts(option_id);
CREATE INDEX IF NOT EXISTS idx_protocols_published ON protocols(published) WHERE published = true;
CREATE INDEX IF NOT EXISTS idx_protocols_category ON protocols(category);

-- Row Level Security (RLS) Policies
ALTER TABLE content_packs ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenario_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE perspective_shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE protocols ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_monthly ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenario_sync_metadata ENABLE ROW LEVEL SECURITY;

-- Public read access to published content (anon users)
CREATE POLICY "Public can read published content packs"
  ON content_packs FOR SELECT
  TO anon
  USING (published = true);

CREATE POLICY "Public can read published scenarios"
  ON scenarios FOR SELECT
  TO anon
  USING (published = true);

CREATE POLICY "Public can read scenario options"
  ON scenario_options FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 FROM scenarios 
      WHERE scenarios.id = scenario_options.scenario_id 
      AND scenarios.published = true
    )
  );

CREATE POLICY "Public can read perspective shifts"
  ON perspective_shifts FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 FROM scenario_options 
      JOIN scenarios ON scenarios.id = scenario_options.scenario_id
      WHERE scenario_options.id = perspective_shifts.option_id 
      AND scenarios.published = true
    )
  );

CREATE POLICY "Public can read published protocols"
  ON protocols FOR SELECT
  TO anon
  USING (published = true);

CREATE POLICY "Public can read sync metadata"
  ON scenario_sync_metadata FOR SELECT
  TO anon
  USING (true);

-- Authenticated users (admin) have full access
CREATE POLICY "Authenticated users have full access to content packs"
  ON content_packs FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users have full access to scenarios"
  ON scenarios FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users have full access to scenario options"
  ON scenario_options FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users have full access to perspective shifts"
  ON perspective_shifts FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users have full access to protocols"
  ON protocols FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users have full access to analytics"
  ON analytics_monthly FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Trigger to update scenario_sync_metadata when scenarios change
CREATE OR REPLACE FUNCTION update_scenario_sync_version()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE scenario_sync_metadata 
  SET last_updated = NOW(), version = version + 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER scenarios_sync_trigger
  AFTER INSERT OR UPDATE OR DELETE ON scenarios
  FOR EACH STATEMENT
  EXECUTE FUNCTION update_scenario_sync_version();

CREATE TRIGGER scenario_options_sync_trigger
  AFTER INSERT OR UPDATE OR DELETE ON scenario_options
  FOR EACH STATEMENT
  EXECUTE FUNCTION update_scenario_sync_version();

CREATE TRIGGER protocols_sync_trigger
  AFTER INSERT OR UPDATE OR DELETE ON protocols
  FOR EACH STATEMENT
  EXECUTE FUNCTION update_scenario_sync_version();

-- Insert initial sync metadata
INSERT INTO scenario_sync_metadata (last_updated, version) 
VALUES (NOW(), 1)
ON CONFLICT DO NOTHING;

-- Insert example content pack
INSERT INTO content_packs (name, description, icon, sort_order, published) VALUES
  ('Communication Fundamentals', 'Core scenarios for clear, respectful communication in professional settings', 'MessageSquare', 1, true),
  ('Hierarchy & Authority', 'Navigate up-chain communication and disagreement with command', 'Shield', 2, true),
  ('Peer Dynamics', 'Handle conflict, trust, and collaboration with colleagues', 'Users', 3, true),
  ('High Pressure', 'Maintain composure and clarity under time constraints and stress', 'Zap', 4, true),
  ('Leadership', 'Influence without formal authority, set boundaries, maintain standards', 'Award', 5, false)
ON CONFLICT (name) DO NOTHING;

COMMENT ON TABLE scenarios IS 'Decision training scenarios with multiple response options';
COMMENT ON TABLE scenario_options IS 'Response choices for scenarios with outcomes and tags';
COMMENT ON TABLE perspective_shifts IS 'How different people interpret each response choice';
COMMENT ON TABLE protocols IS 'Step-by-step communication and conflict management guides';
COMMENT ON TABLE analytics_monthly IS 'Anonymous aggregate usage data for learning and improvement';




