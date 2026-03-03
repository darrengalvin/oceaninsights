-- ═══════════════════════════════════════════════════════════════
-- Work Service Culture (C2 Drill) — Supabase Schema
-- ═══════════════════════════════════════════════════════════════

-- Core values
CREATE TABLE IF NOT EXISTS culture_values (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '⭐',
  description TEXT NOT NULL,
  daily_challenge TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE culture_values ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read culture_values" ON culture_values FOR SELECT USING (true);
CREATE POLICY "Auth write culture_values" ON culture_values FOR ALL USING (auth.role() = 'authenticated');

-- Scenario challenges
CREATE TABLE IF NOT EXISTS culture_scenarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  scenario TEXT NOT NULL,
  correct_value TEXT NOT NULL,
  explanation TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE culture_scenarios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read culture_scenarios" ON culture_scenarios FOR SELECT USING (true);
CREATE POLICY "Auth write culture_scenarios" ON culture_scenarios FOR ALL USING (auth.role() = 'authenticated');

-- ═══════════════════════════════════════════════════════════════
-- Seed data — Values
-- ═══════════════════════════════════════════════════════════════

INSERT INTO culture_values (name, emoji, description, daily_challenge, sort_order) VALUES
('Courage', '🦁', 'The willingness to face fear, uncertainty, and danger. Speaking up when others stay silent.', 'Today, speak up about something you''d normally stay quiet about.', 1),
('Commitment', '💪', 'Giving your all, every day, even when no one is watching. Seeing things through to the end.', 'Today, finish one task you''ve been putting off — no matter how small.', 2),
('Respect', '🤝', 'Treating every person with dignity — regardless of rank, background, or situation.', 'Today, go out of your way to acknowledge someone you normally wouldn''t.', 3),
('Discipline', '⚡', 'Doing the right thing consistently, maintaining standards, and holding yourself accountable.', 'Today, do one thing properly that you''d normally cut corners on.', 4),
('Integrity', '🎯', 'Being honest and truthful in all actions. Your word is your bond.', 'Today, tell someone a truth you''ve been avoiding — kindly.', 5),
('Loyalty', '🛡️', 'Standing by your team, your unit, and your values — especially when it''s hard.', 'Today, check in on someone who might be struggling.', 6);

-- ═══════════════════════════════════════════════════════════════
-- Seed data — Scenarios
-- ═══════════════════════════════════════════════════════════════

INSERT INTO culture_scenarios (scenario, correct_value, explanation, sort_order) VALUES
('A colleague is being singled out by seniors. Nobody else speaks up. Do you?', 'Courage', 'Standing up when others stay silent requires Courage — even when it may cost you.', 1),
('You''re exhausted after a long exercise but your section still has duties to complete.', 'Commitment', 'Pushing through when your body wants to quit is the essence of Commitment.', 2),
('A junior member makes a mistake that delays the whole team.', 'Respect', 'How you treat someone at their worst shows your Respect — for them and the team.', 3),
('You''re off duty but spot a serious safety hazard on base.', 'Discipline', 'Doing what''s right even when nobody is watching — that''s Discipline.', 4),
('You discover a senior is falsifying equipment checks.', 'Integrity', 'Choosing truth over convenience, especially upward, demands Integrity.', 5),
('A friend is being posted to a difficult location and everyone else is avoiding them.', 'Loyalty', 'Standing by someone when the situation isn''t easy — that''s Loyalty.', 6),
('You''re asked to lead a task you''ve never done before in front of the whole platoon.', 'Courage', 'Accepting the risk of failure in front of others takes real Courage.', 7),
('Your unit has a boring but critical daily routine. Some people skip it.', 'Discipline', 'Maintaining standards in the mundane — that''s where Discipline truly lives.', 8);
