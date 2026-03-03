-- ═══════════════════════════════════════════════════════════════
-- Brain Science & Psychology — Supabase Schema
-- ═══════════════════════════════════════════════════════════════

-- Myth Buster questions
CREATE TABLE IF NOT EXISTS brain_myths (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  statement TEXT NOT NULL,
  is_true BOOLEAN NOT NULL DEFAULT false,
  explanation TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE brain_myths ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read brain_myths" ON brain_myths FOR SELECT USING (true);
CREATE POLICY "Auth write brain_myths" ON brain_myths FOR ALL USING (auth.role() = 'authenticated');

-- Bias Spotter scenarios
CREATE TABLE IF NOT EXISTS brain_biases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  scenario TEXT NOT NULL,
  correct_option_index INTEGER NOT NULL DEFAULT 0,
  explanation TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE brain_biases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read brain_biases" ON brain_biases FOR SELECT USING (true);
CREATE POLICY "Auth write brain_biases" ON brain_biases FOR ALL USING (auth.role() = 'authenticated');

-- Bias options
CREATE TABLE IF NOT EXISTS brain_bias_options (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  bias_id UUID NOT NULL REFERENCES brain_biases(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE brain_bias_options ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read brain_bias_options" ON brain_bias_options FOR SELECT USING (true);
CREATE POLICY "Auth write brain_bias_options" ON brain_bias_options FOR ALL USING (auth.role() = 'authenticated');

-- Famous Experiments
CREATE TABLE IF NOT EXISTS brain_experiments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  year TEXT NOT NULL,
  researcher TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE brain_experiments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read brain_experiments" ON brain_experiments FOR SELECT USING (true);
CREATE POLICY "Auth write brain_experiments" ON brain_experiments FOR ALL USING (auth.role() = 'authenticated');

-- Experiment steps
CREATE TABLE IF NOT EXISTS brain_experiment_steps (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  experiment_id UUID NOT NULL REFERENCES brain_experiments(id) ON DELETE CASCADE,
  step_text TEXT NOT NULL,
  step_type TEXT NOT NULL DEFAULT 'info', -- 'info', 'choice', 'reveal'
  options_json TEXT, -- JSON array of choice options if step_type='choice'
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE brain_experiment_steps ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read brain_experiment_steps" ON brain_experiment_steps FOR SELECT USING (true);
CREATE POLICY "Auth write brain_experiment_steps" ON brain_experiment_steps FOR ALL USING (auth.role() = 'authenticated');

-- Seed myths
INSERT INTO brain_myths (statement, is_true, explanation, sort_order) VALUES
('We only use 10% of our brain.', false, 'Brain scans show activity across the entire brain, even during sleep. Every region has a known function.', 1),
('People are either left-brained or right-brained.', false, 'Both hemispheres work together for virtually all tasks. The idea of dominant sides is a myth.', 2),
('Stress can physically shrink your brain.', true, 'Chronic stress releases cortisol which can reduce the size of the prefrontal cortex and hippocampus.', 3),
('Your brain uses 20% of your body''s energy.', true, 'Despite being only 2% of body weight, the brain consumes roughly 20% of your oxygen and calories.', 4),
('Memories are stored in a single location in the brain.', false, 'Memories are distributed across networks of neurons. Different aspects are stored in different regions.', 5),
('Sleep deprivation can cause hallucinations.', true, 'After 48-72 hours without sleep, many people experience visual and auditory hallucinations.', 6),
('Adults cannot grow new brain cells.', false, 'Neurogenesis continues in the hippocampus throughout adulthood, especially with exercise.', 7),
('Listening to Mozart makes you smarter.', false, 'The "Mozart Effect" was based on a small, unreplicated study. Music can improve mood but doesn''t increase IQ.', 8),
('Exercise is as effective as medication for mild depression.', true, 'Multiple studies show regular exercise can be as effective as antidepressants for mild to moderate depression.', 9),
('Your brain processes rejection like physical pain.', true, 'fMRI studies show social rejection activates the same brain regions as physical pain.', 10);
