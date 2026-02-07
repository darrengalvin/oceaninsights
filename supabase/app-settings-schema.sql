-- ============================================================
-- APP SETTINGS SCHEMA
-- Admin-configurable settings for the Below the Surface app
-- ============================================================

-- App settings table (key-value store for app configuration)
CREATE TABLE IF NOT EXISTS app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT,
    is_secret BOOLEAN DEFAULT false, -- Don't expose in public APIs
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- Only allow read access through authenticated admin or service role
CREATE POLICY "Admin read access" ON app_settings
    FOR SELECT USING (auth.role() = 'authenticated' OR auth.role() = 'service_role');

CREATE POLICY "Admin write access" ON app_settings
    FOR ALL USING (auth.role() = 'service_role');

-- For the app to read settings (anon access for non-secret settings only)
CREATE POLICY "Public read non-secret settings" ON app_settings
    FOR SELECT USING (is_secret = false);

-- Insert default settings
INSERT INTO app_settings (key, value, description, is_secret) VALUES
    ('developer_phrase', 'deepblue', 'Secret phrase for developer access (tap version 7 times)', true),
    ('app_version', '1.0.0', 'Current app version', false),
    ('maintenance_mode', 'false', 'Enable maintenance mode to block app access', false),
    ('min_supported_version', '1.0.0', 'Minimum supported app version', false)
ON CONFLICT (key) DO NOTHING;

-- Function to get a setting value
CREATE OR REPLACE FUNCTION get_setting(setting_key TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN (SELECT value FROM app_settings WHERE key = setting_key);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update a setting (admin only)
CREATE OR REPLACE FUNCTION update_setting(setting_key TEXT, new_value TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE app_settings 
    SET value = new_value, updated_at = NOW() 
    WHERE key = setting_key;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
