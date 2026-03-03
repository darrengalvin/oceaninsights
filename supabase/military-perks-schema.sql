-- ═══════════════════════════════════════════════════════════════
-- Military Perks — Supabase Schema
-- ═══════════════════════════════════════════════════════════════

-- Did You Know fact cards
CREATE TABLE IF NOT EXISTS perks_facts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  emoji TEXT NOT NULL DEFAULT '💡',
  title TEXT NOT NULL,
  detail TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE perks_facts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read perks_facts" ON perks_facts FOR SELECT USING (true);
CREATE POLICY "Auth write perks_facts" ON perks_facts FOR ALL USING (auth.role() = 'authenticated');

-- Regret stories
CREATE TABLE IF NOT EXISTS perks_regret_stories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quote TEXT NOT NULL,
  branch TEXT NOT NULL DEFAULT 'Army',
  years_served TEXT NOT NULL DEFAULT '10 years',
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE perks_regret_stories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read perks_regret_stories" ON perks_regret_stories FOR SELECT USING (true);
CREATE POLICY "Auth write perks_regret_stories" ON perks_regret_stories FOR ALL USING (auth.role() = 'authenticated');

-- Perk calculator categories (allows admin to tweak benefit values)
CREATE TABLE IF NOT EXISTS perks_benefit_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  base_value INTEGER NOT NULL DEFAULT 0,
  description TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE perks_benefit_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read perks_benefit_items" ON perks_benefit_items FOR SELECT USING (true);
CREATE POLICY "Auth write perks_benefit_items" ON perks_benefit_items FOR ALL USING (auth.role() = 'authenticated');

-- Seed data
INSERT INTO perks_facts (emoji, title, detail, sort_order) VALUES
('🏡', 'FHTB — Forces Help to Buy', 'The military will give you up to £25,000 as an interest-free loan to help you buy a house. Interest free. No civilian employer does this. You repay it gradually from salary over 10 years.', 1),
('🚗', 'GYH(T) — Get You Home Travel', 'If you own a home, the military pays you 25p per mile to travel home every month. That adds up fast — someone living 200 miles from base gets around £600 a year just for going home.', 2),
('⚓', 'GYH(S) — Get You Home Seagoers', 'Submariners and seagoers get 10 warrants per year to travel home and see their families. The military pays for you to get home — because they know how hard time away is.', 3),
('💰', 'Pension Value', 'Your military pension is worth hundreds of thousands over a lifetime. Most civilian employers don''t offer anything close to this defined-benefit scheme.', 4),
('🏥', 'Healthcare', 'You get priority NHS treatment, military medical facilities, and dental care — all free. A family health plan privately costs £3,000+ per year.', 5),
('🎓', 'Education', 'Enhanced Learning Credits give you up to £2,000 per year for qualifications. Many service members leave with degrees paid for entirely.', 6),
('🏠', 'Subsidised Housing', 'Service Family Accommodation is heavily subsidised. The equivalent rent in many areas would be £800–£1,200 per month. And with FHTB, getting on the property ladder is within reach.', 7),
('💪', 'Fitness', 'Free gym access, sports facilities, and paid time to exercise. A civilian gym membership alone costs £40–£80 per month.', 8),
('🌴', 'Leave', 'You get 38 days leave per year — far more than the UK average of 28 days (including bank holidays).', 9),
('🛡️', 'Job Security', 'In uncertain economic times, military careers offer a level of job security that most industries simply cannot match.', 10),
('📈', 'Career Progression', 'Clear, structured promotion pathways. You know exactly what you need to do to progress — no office politics.', 11),
('🤝', 'Community', 'A built-in support network wherever you go. The friendships and bonds formed in service last a lifetime.', 12),
('🎖️', 'Transition Support', 'The Career Transition Partnership helps you find civilian work with CV workshops, training, and job matching.', 13),
('👨‍👩‍👧', 'Family Support', 'HIVE information services, welfare support, childcare vouchers, and family activity centres on most bases.', 14);

INSERT INTO perks_regret_stories (quote, branch, years_served, sort_order) VALUES
('I left after 12 years thinking civilian life would be easier. Within 6 months I realised nobody cares about you the way the military does. No structure, no purpose, no mates around the corner.', 'Army', '12 years', 1),
('The pension I walked away from haunts me. I''d have been set by 40. Instead I''m starting again at 35 with nothing saved.', 'Royal Navy', '8 years', 2),
('I thought I''d find better opportunities outside. What I found was loneliness. The camaraderie you have in service doesn''t exist in civvy street.', 'RAF', '10 years', 3),
('My biggest regret is not appreciating what I had. Free gym, free healthcare, guaranteed housing. Now I''m paying £1,500 a month rent for a flat half the size of my quarter.', 'Royal Marines', '6 years', 4),
('I left because I thought the grass was greener. It''s not. It''s just different grass, and nobody mows it for you.', 'Army', '9 years', 5),
('People said "you''ll walk into a job with your military experience." That''s not how it works. I spent 8 months unemployed and lost all my confidence.', 'RAF', '14 years', 6);
