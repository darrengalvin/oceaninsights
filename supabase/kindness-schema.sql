-- ═══════════════════════════════════════════════════════════════
-- Learning to be Kind — Supabase Schema
-- ═══════════════════════════════════════════════════════════════

-- Flip the Story cards
CREATE TABLE IF NOT EXISTS kindness_flip_cards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  emoji TEXT NOT NULL DEFAULT '💭',
  judgement TEXT NOT NULL,
  reality TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE kindness_flip_cards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read kindness_flip_cards" ON kindness_flip_cards FOR SELECT USING (true);
CREATE POLICY "Auth write kindness_flip_cards" ON kindness_flip_cards FOR ALL USING (auth.role() = 'authenticated');

-- React or Reflect scenarios
CREATE TABLE IF NOT EXISTS kindness_react_scenarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  scenario TEXT NOT NULL,
  reveal TEXT NOT NULL,
  best_reaction_index INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE kindness_react_scenarios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read kindness_react_scenarios" ON kindness_react_scenarios FOR SELECT USING (true);
CREATE POLICY "Auth write kindness_react_scenarios" ON kindness_react_scenarios FOR ALL USING (auth.role() = 'authenticated');

-- Reactions for each scenario
CREATE TABLE IF NOT EXISTS kindness_react_options (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  scenario_id UUID NOT NULL REFERENCES kindness_react_scenarios(id) ON DELETE CASCADE,
  reaction_text TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE kindness_react_options ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read kindness_react_options" ON kindness_react_options FOR SELECT USING (true);
CREATE POLICY "Auth write kindness_react_options" ON kindness_react_options FOR ALL USING (auth.role() = 'authenticated');

-- ═══════════════════════════════════════════════════════════════
-- Seed data — Flip Cards
-- ═══════════════════════════════════════════════════════════════

INSERT INTO kindness_flip_cards (emoji, judgement, reality, sort_order) VALUES
('🚗', 'That car is driving so slowly… how annoying.', 'They have a newborn baby sleeping in the back seat.', 1),
('👩', 'That woman keeps staring at me… what''s her problem?', 'She just lost her child and you remind her of them.', 2),
('💔', 'She gets around… everyone talks about her.', 'She has no other way of feeling loved or valued.', 3),
('😶', '"It was only a joke" — why are they so sensitive?', 'That "joke" just ruined their entire week.', 4),
('🏠', 'He never comes out anymore. What a loner.', 'He''s caring for a parent with dementia every night.', 5),
('⏰', 'They''re always late. So disrespectful.', 'They''re working two jobs and barely sleeping.', 6),
('😢', 'Why is that person crying in public? So embarrassing.', 'They just got a call that their best friend passed away.', 7),
('🪖', 'That soldier is so quiet. Probably thinks he''s better than us.', 'He''s processing something he can''t talk about yet.', 8),
('🙂', 'She never smiles. Miserable person.', 'She smiles at home, where her kids make her feel safe.', 9),
('🍽️', 'He eats lunch alone every day. Weird.', 'It''s the only peace he gets between two difficult shifts.', 10),
('💬', 'They snapped at me for no reason.', 'They just found out their partner is leaving them.', 11),
('📱', 'They''re always on their phone. So rude.', 'They''re checking on a sick family member back home.', 12);

-- ═══════════════════════════════════════════════════════════════
-- Seed data — React or Reflect scenarios
-- ═══════════════════════════════════════════════════════════════

INSERT INTO kindness_react_scenarios (scenario, reveal, best_reaction_index, sort_order) VALUES
('A colleague bumps into you in the corridor and doesn''t apologise.', 'They just got called into a meeting about potential redundancies and their mind was racing.', 2, 1),
('Someone in your unit hasn''t volunteered for anything in weeks.', 'They''ve been struggling with sleep and anxiety but are afraid to speak up.', 1, 2),
('A friend cancels plans at the last minute — again.', 'They had a panic attack in the car park and couldn''t bring themselves to leave.', 1, 3),
('Your neighbour plays music late at night.', 'They were alone on the anniversary of losing someone and the silence was unbearable.', 2, 4),
('Someone at the gym keeps hogging the equipment and won''t let anyone work in.', 'It''s the one hour a day they feel in control. Everything else is falling apart.', 2, 5),
('A young recruit keeps asking the same questions over and over.', 'They grew up in care and never had anyone patient enough to teach them things twice.', 1, 6);

-- Now insert reaction options for each scenario
DO $$
DECLARE
  s1_id UUID; s2_id UUID; s3_id UUID; s4_id UUID; s5_id UUID; s6_id UUID;
BEGIN
  SELECT id INTO s1_id FROM kindness_react_scenarios WHERE sort_order = 1;
  SELECT id INTO s2_id FROM kindness_react_scenarios WHERE sort_order = 2;
  SELECT id INTO s3_id FROM kindness_react_scenarios WHERE sort_order = 3;
  SELECT id INTO s4_id FROM kindness_react_scenarios WHERE sort_order = 4;
  SELECT id INTO s5_id FROM kindness_react_scenarios WHERE sort_order = 5;
  SELECT id INTO s6_id FROM kindness_react_scenarios WHERE sort_order = 6;

  INSERT INTO kindness_react_options (scenario_id, reaction_text, sort_order) VALUES
  (s1_id, 'Rude. No manners.', 0),
  (s1_id, 'They probably didn''t notice.', 1),
  (s1_id, 'They must be in a rush.', 2),

  (s2_id, 'Lazy. Doesn''t care about the team.', 0),
  (s2_id, 'Maybe they''re going through something.', 1),
  (s2_id, 'Not my problem.', 2),

  (s3_id, 'They clearly don''t value my time.', 0),
  (s3_id, 'Something might be wrong.', 1),
  (s3_id, 'I''m done making plans with them.', 2),

  (s4_id, 'So inconsiderate. I''ll complain tomorrow.', 0),
  (s4_id, 'Maybe they don''t realise how loud it is.', 1),
  (s4_id, 'They''re probably trying to drown out something.', 2),

  (s5_id, 'Selfish. No gym etiquette.', 0),
  (s5_id, 'They might not know the norm.', 1),
  (s5_id, 'They could be pushing through something personal.', 2),

  (s6_id, 'They should have listened the first time.', 0),
  (s6_id, 'They''re probably nervous and want to get it right.', 1),
  (s6_id, 'Not my job to teach them.', 2);
END $$;
