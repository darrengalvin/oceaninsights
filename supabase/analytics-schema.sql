-- ============================================
-- ANONYMOUS ANALYTICS SCHEMA
-- Privacy-compliant analytics without user accounts
-- ============================================

-- ============================================
-- DEVICES TABLE (Anonymous Users)
-- ============================================
CREATE TABLE IF NOT EXISTS analytics_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT UNIQUE NOT NULL, -- Anonymous device identifier
  platform TEXT NOT NULL, -- 'ios', 'android'
  os_version TEXT,
  app_version TEXT NOT NULL,
  device_model TEXT,
  country TEXT, -- Derived from IP, not stored precisely
  user_type TEXT, -- 'submariner', 'veteran', etc. (anonymous category)
  age_bracket TEXT, -- Anonymous age range
  first_seen_at TIMESTAMPTZ DEFAULT NOW(),
  last_seen_at TIMESTAMPTZ DEFAULT NOW(),
  total_sessions INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for querying active users
CREATE INDEX IF NOT EXISTS idx_analytics_devices_last_seen ON analytics_devices(last_seen_at);
CREATE INDEX IF NOT EXISTS idx_analytics_devices_platform ON analytics_devices(platform);
CREATE INDEX IF NOT EXISTS idx_analytics_devices_first_seen ON analytics_devices(first_seen_at);

-- ============================================
-- SESSIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS analytics_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT NOT NULL REFERENCES analytics_devices(device_id) ON DELETE CASCADE,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  duration_seconds INTEGER,
  screens_viewed INTEGER DEFAULT 0,
  events_count INTEGER DEFAULT 0,
  app_version TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_sessions_device ON analytics_sessions(device_id);
CREATE INDEX IF NOT EXISTS idx_analytics_sessions_started ON analytics_sessions(started_at);

-- ============================================
-- EVENTS TABLE (Feature Usage)
-- ============================================
CREATE TABLE IF NOT EXISTS analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT NOT NULL,
  session_id UUID REFERENCES analytics_sessions(id) ON DELETE SET NULL,
  event_name TEXT NOT NULL, -- 'screen_view', 'feature_used', 'content_viewed', etc.
  event_category TEXT, -- 'navigation', 'breathing', 'mood', 'games', etc.
  event_data JSONB, -- Additional event-specific data
  screen_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_events_device ON analytics_events(device_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_name ON analytics_events(event_name);
CREATE INDEX IF NOT EXISTS idx_analytics_events_category ON analytics_events(event_category);
CREATE INDEX IF NOT EXISTS idx_analytics_events_created ON analytics_events(created_at);

-- ============================================
-- DAILY AGGREGATES (Pre-computed for dashboard)
-- ============================================
CREATE TABLE IF NOT EXISTS analytics_daily_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE UNIQUE NOT NULL,
  total_devices INTEGER DEFAULT 0,
  new_devices INTEGER DEFAULT 0,
  active_devices INTEGER DEFAULT 0,
  total_sessions INTEGER DEFAULT 0,
  total_events INTEGER DEFAULT 0,
  avg_session_duration INTEGER DEFAULT 0,
  ios_devices INTEGER DEFAULT 0,
  android_devices INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_daily_date ON analytics_daily_stats(date);

-- ============================================
-- FEATURE USAGE AGGREGATES
-- ============================================
CREATE TABLE IF NOT EXISTS analytics_feature_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  feature_name TEXT NOT NULL,
  usage_count INTEGER DEFAULT 0,
  unique_users INTEGER DEFAULT 0,
  avg_duration_seconds INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(date, feature_name)
);

CREATE INDEX IF NOT EXISTS idx_analytics_feature_date ON analytics_feature_stats(date);
CREATE INDEX IF NOT EXISTS idx_analytics_feature_name ON analytics_feature_stats(feature_name);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
ALTER TABLE analytics_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_daily_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_feature_stats ENABLE ROW LEVEL SECURITY;

-- Allow anonymous inserts (from app)
CREATE POLICY "Allow anonymous device registration"
  ON analytics_devices FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow anonymous device updates"
  ON analytics_devices FOR UPDATE
  USING (true);

CREATE POLICY "Allow anonymous session inserts"
  ON analytics_sessions FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow anonymous session updates"
  ON analytics_sessions FOR UPDATE
  USING (true);

CREATE POLICY "Allow anonymous event inserts"
  ON analytics_events FOR INSERT
  WITH CHECK (true);

-- Allow public read for aggregates (dashboard)
CREATE POLICY "Allow public read of daily stats"
  ON analytics_daily_stats FOR SELECT
  USING (true);

CREATE POLICY "Allow public read of feature stats"
  ON analytics_feature_stats FOR SELECT
  USING (true);

CREATE POLICY "Allow public read of devices"
  ON analytics_devices FOR SELECT
  USING (true);

CREATE POLICY "Allow public read of sessions"
  ON analytics_sessions FOR SELECT
  USING (true);

CREATE POLICY "Allow public read of events"
  ON analytics_events FOR SELECT
  USING (true);

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function to update daily stats (run via cron or on event)
CREATE OR REPLACE FUNCTION update_daily_analytics()
RETURNS void AS $$
DECLARE
  target_date DATE := CURRENT_DATE;
BEGIN
  INSERT INTO analytics_daily_stats (
    date,
    total_devices,
    new_devices,
    active_devices,
    total_sessions,
    total_events,
    avg_session_duration,
    ios_devices,
    android_devices
  )
  SELECT
    target_date,
    (SELECT COUNT(*) FROM analytics_devices),
    (SELECT COUNT(*) FROM analytics_devices WHERE DATE(first_seen_at) = target_date),
    (SELECT COUNT(DISTINCT device_id) FROM analytics_sessions WHERE DATE(started_at) = target_date),
    (SELECT COUNT(*) FROM analytics_sessions WHERE DATE(started_at) = target_date),
    (SELECT COUNT(*) FROM analytics_events WHERE DATE(created_at) = target_date),
    (SELECT COALESCE(AVG(duration_seconds), 0) FROM analytics_sessions WHERE DATE(started_at) = target_date AND duration_seconds IS NOT NULL),
    (SELECT COUNT(*) FROM analytics_devices WHERE platform = 'ios'),
    (SELECT COUNT(*) FROM analytics_devices WHERE platform = 'android')
  ON CONFLICT (date) DO UPDATE SET
    total_devices = EXCLUDED.total_devices,
    new_devices = EXCLUDED.new_devices,
    active_devices = EXCLUDED.active_devices,
    total_sessions = EXCLUDED.total_sessions,
    total_events = EXCLUDED.total_events,
    avg_session_duration = EXCLUDED.avg_session_duration,
    ios_devices = EXCLUDED.ios_devices,
    android_devices = EXCLUDED.android_devices,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to update feature stats
CREATE OR REPLACE FUNCTION update_feature_analytics()
RETURNS void AS $$
DECLARE
  target_date DATE := CURRENT_DATE;
BEGIN
  INSERT INTO analytics_feature_stats (date, feature_name, usage_count, unique_users)
  SELECT 
    target_date,
    event_category,
    COUNT(*),
    COUNT(DISTINCT device_id)
  FROM analytics_events 
  WHERE DATE(created_at) = target_date
    AND event_category IS NOT NULL
  GROUP BY event_category
  ON CONFLICT (date, feature_name) DO UPDATE SET
    usage_count = EXCLUDED.usage_count,
    unique_users = EXCLUDED.unique_users;
END;
$$ LANGUAGE plpgsql;
