-- ================================================================
-- What's New — version release notes managed from admin
-- ================================================================
-- Each row = one version release with its highlights.
-- The app checks the user's last-seen version on launch,
-- and shows any newer entries as a "What's New" sheet.
-- ================================================================

CREATE TABLE IF NOT EXISTS whats_new_releases (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version       TEXT NOT NULL UNIQUE,
  title         TEXT NOT NULL DEFAULT 'What''s New',
  subtitle      TEXT,
  release_date  DATE NOT NULL DEFAULT CURRENT_DATE,
  is_active     BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS whats_new_items (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  release_id    UUID NOT NULL REFERENCES whats_new_releases(id) ON DELETE CASCADE,
  emoji         TEXT NOT NULL DEFAULT '✨',
  title         TEXT NOT NULL,
  description   TEXT NOT NULL,
  sort_order    INT NOT NULL DEFAULT 0,
  is_active     BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for fast lookup by version
CREATE INDEX IF NOT EXISTS idx_whats_new_releases_version ON whats_new_releases(version);
CREATE INDEX IF NOT EXISTS idx_whats_new_items_release ON whats_new_items(release_id);

-- Row Level Security
ALTER TABLE whats_new_releases ENABLE ROW LEVEL SECURITY;
ALTER TABLE whats_new_items    ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read whats_new_releases" ON whats_new_releases FOR SELECT USING (true);
CREATE POLICY "Public read whats_new_items"    ON whats_new_items    FOR SELECT USING (true);
CREATE POLICY "Auth write whats_new_releases"  ON whats_new_releases FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Auth write whats_new_items"     ON whats_new_items    FOR ALL USING (auth.role() = 'authenticated');

-- ================================================================
-- Seed: initial release
-- ================================================================

INSERT INTO whats_new_releases (version, title, subtitle, release_date)
VALUES ('1.0.0', 'Welcome to Below the Surface', 'Your journey starts here.', '2026-02-15')
ON CONFLICT (version) DO NOTHING;

INSERT INTO whats_new_items (release_id, emoji, title, description, sort_order) VALUES
  ((SELECT id FROM whats_new_releases WHERE version = '1.0.0'), '🧘', 'Breathing Exercises', 'Guided breathing techniques to help you stay calm and focused.', 0),
  ((SELECT id FROM whats_new_releases WHERE version = '1.0.0'), '🎯', 'Mission Planner', 'Set daily objectives and track your progress.', 1),
  ((SELECT id FROM whats_new_releases WHERE version = '1.0.0'), '🛡️', 'Service Women Support', 'Harassment support wizard and health tracker — private and on-device.', 2),
  ((SELECT id FROM whats_new_releases WHERE version = '1.0.0'), '👨‍👩‍👧‍👦', 'Service Family', 'Deployment support, coping tools, and guidance for families.', 3),
  ((SELECT id FROM whats_new_releases WHERE version = '1.0.0'), '📚', 'Young Person Education', 'Body education, sex education, and bullying support — all tap-based.', 4),
  ((SELECT id FROM whats_new_releases WHERE version = '1.0.0'), '🎮', 'Mindful Games', 'Zen garden, block stacking, memory match, and more.', 5)
ON CONFLICT DO NOTHING;
