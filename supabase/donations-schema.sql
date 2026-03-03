-- ═══════════════════════════════════════════════════════════════
-- Donations — Supabase Schema
-- ═══════════════════════════════════════════════════════════════

-- Donation impact tiers
CREATE TABLE IF NOT EXISTS donation_impacts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  amount INTEGER NOT NULL,
  emoji TEXT NOT NULL DEFAULT '💛',
  impact_text TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE donation_impacts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read donation_impacts" ON donation_impacts FOR SELECT USING (true);
CREATE POLICY "Auth write donation_impacts" ON donation_impacts FOR ALL USING (auth.role() = 'authenticated');

-- Donation settings (URL, message, etc.)
CREATE TABLE IF NOT EXISTS donation_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  key TEXT NOT NULL UNIQUE,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE donation_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read donation_settings" ON donation_settings FOR SELECT USING (true);
CREATE POLICY "Auth write donation_settings" ON donation_settings FOR ALL USING (auth.role() = 'authenticated');

-- Seed data
INSERT INTO donation_impacts (amount, emoji, impact_text, sort_order) VALUES
(1, '💬', 'Help fund a crisis text-line shift for someone who needs to talk', 1),
(5, '🎒', 'Provide wellbeing resources to a young person in need', 2),
(10, '👨‍👩‍👧', 'Help a military family access specialist counselling', 3),
(25, '🏠', 'Contribute to a veteran housing support programme', 4),
(50, '🤝', 'Help fund a community wellbeing event for service members', 5);

INSERT INTO donation_settings (key, value) VALUES
('donate_url', 'https://belowthesurface.co.uk/donate'),
('thank_you_message', 'Every penny goes to charity — not to us. Below the Surface connects you with organisations making a real difference for service members, veterans, and their families.');
