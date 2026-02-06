-- ============================================================
-- COMPREHENSIVE APP CONTENT SCHEMA
-- All editable content for the Below the Surface app
-- ============================================================

-- ============================================================
-- 1. MOOD TRACKING CONTENT
-- ============================================================

-- Mood reasons (why users feel a certain way)
CREATE TABLE IF NOT EXISTS mood_reasons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mood_type TEXT NOT NULL, -- 'positive', 'neutral', 'negative'
    text TEXT NOT NULL,
    icon TEXT DEFAULT 'circle',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mood responses (personalized messages based on mood + reason)
CREATE TABLE IF NOT EXISTS mood_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mood_type TEXT NOT NULL,
    reason_id UUID REFERENCES mood_reasons(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    suggested_action TEXT,
    action_route TEXT, -- where to navigate
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default mood reasons
INSERT INTO mood_reasons (mood_type, text, icon, sort_order) VALUES
-- Positive reasons
('positive', 'Good sleep', 'bedtime', 1),
('positive', 'Accomplished something', 'check_circle', 2),
('positive', 'Connected with someone', 'people', 3),
('positive', 'Exercise/movement', 'fitness_center', 4),
('positive', 'Grateful for something', 'favorite', 5),
('positive', 'Just feeling good', 'sunny', 6),
-- Neutral reasons
('neutral', 'Just woke up', 'wb_sunny', 10),
('neutral', 'Busy day ahead', 'schedule', 11),
('neutral', 'Taking things slow', 'self_improvement', 12),
('neutral', 'Processing something', 'psychology', 13),
('neutral', 'No particular reason', 'remove', 14),
-- Negative reasons
('negative', 'Poor sleep', 'bedtime', 20),
('negative', 'Anxiety/worry', 'psychology', 21),
('negative', 'Stress', 'warning', 22),
('negative', 'Loneliness', 'person', 23),
('negative', 'Physical discomfort', 'healing', 24),
('negative', 'Work/life pressure', 'work', 25),
('negative', 'Relationship issues', 'people', 26),
('negative', 'Just feeling down', 'cloud', 27);

-- ============================================================
-- 2. DAILY BRIEF CONTENT
-- ============================================================

-- Energy levels for daily brief
CREATE TABLE IF NOT EXISTS daily_brief_energy_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    label TEXT NOT NULL,
    emoji TEXT NOT NULL,
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Daily brief objectives (what to focus on)
CREATE TABLE IF NOT EXISTS daily_brief_objectives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Daily brief challenges (potential obstacles)
CREATE TABLE IF NOT EXISTS daily_brief_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert defaults
INSERT INTO daily_brief_energy_levels (label, emoji, description, sort_order) VALUES
('Fully Charged', '⚡', 'Ready to take on anything', 1),
('Good to Go', '✓', 'Feeling capable and focused', 2),
('Moderate', '~', 'Steady but not peak', 3),
('Low Battery', '↓', 'Need to pace myself', 4),
('Running on Empty', '○', 'Minimal capacity today', 5);

INSERT INTO daily_brief_objectives (text, category, sort_order) VALUES
('Stay focused on one priority', 'Focus', 1),
('Practice patience today', 'Mindset', 2),
('Connect with someone important', 'Relationships', 3),
('Take care of my health', 'Health', 4),
('Make progress on a goal', 'Goals', 5),
('Learn something new', 'Growth', 6),
('Be present and mindful', 'Mindset', 7),
('Handle a difficult task', 'Work', 8),
('Rest and recover', 'Health', 9),
('Help someone else', 'Service', 10);

INSERT INTO daily_brief_challenges (text, category, sort_order) VALUES
('Distractions and interruptions', 'Focus', 1),
('Low energy or motivation', 'Energy', 2),
('Difficult conversations', 'Relationships', 3),
('Time pressure', 'Work', 4),
('Negative thoughts', 'Mindset', 5),
('Physical discomfort', 'Health', 6),
('Uncertainty or anxiety', 'Mindset', 7),
('Competing priorities', 'Work', 8),
('Technology issues', 'Work', 9),
('Weather or environment', 'Environment', 10);

-- ============================================================
-- 3. AFTER ACTION REVIEW CONTENT
-- ============================================================

-- What went well options
CREATE TABLE IF NOT EXISTS aar_went_well_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- What to improve options
CREATE TABLE IF NOT EXISTS aar_improve_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Key takeaway options
CREATE TABLE IF NOT EXISTS aar_takeaway_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert defaults
INSERT INTO aar_went_well_options (text, sort_order) VALUES
('Stayed focused on priorities', 1),
('Handled stress well', 2),
('Connected with others', 3),
('Completed important tasks', 4),
('Practiced self-care', 5),
('Stayed positive', 6),
('Learned something new', 7),
('Helped someone', 8),
('Made good decisions', 9),
('Managed my time well', 10);

INSERT INTO aar_improve_options (text, sort_order) VALUES
('Better time management', 1),
('More focus, less distraction', 2),
('Earlier start to the day', 3),
('More breaks and rest', 4),
('Better communication', 5),
('Less procrastination', 6),
('More patience', 7),
('Better planning', 8),
('Healthier choices', 9),
('More mindfulness', 10);

INSERT INTO aar_takeaway_options (text, sort_order) VALUES
('Small steps lead to big progress', 1),
('I am capable of more than I think', 2),
('Connection matters', 3),
('Rest is productive too', 4),
('Tomorrow is a fresh start', 5),
('I handled today well', 6),
('Challenges help me grow', 7),
('Gratitude changes perspective', 8),
('Consistency beats perfection', 9),
('I am making progress', 10);

-- ============================================================
-- 4. SKILLS TRANSLATOR CONTENT
-- ============================================================

-- Military roles
CREATE TABLE IF NOT EXISTS military_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    branch TEXT, -- Army, Navy, etc.
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Civilian jobs (linked to military roles)
CREATE TABLE IF NOT EXISTS civilian_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    salary_range TEXT,
    growth_outlook TEXT, -- 'High', 'Medium', 'Low'
    key_skills TEXT[],
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Role to job mappings
CREATE TABLE IF NOT EXISTS role_job_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID REFERENCES military_roles(id) ON DELETE CASCADE,
    job_id UUID REFERENCES civilian_jobs(id) ON DELETE CASCADE,
    match_strength INTEGER DEFAULT 80, -- percentage match
    UNIQUE(role_id, job_id)
);

-- Insert defaults
INSERT INTO military_roles (title, branch, sort_order) VALUES
('Infantry', 'Army', 1),
('Medic/Corpsman', 'All', 2),
('Intelligence Analyst', 'All', 3),
('Logistics/Supply', 'All', 4),
('Communications', 'All', 5),
('Engineer', 'All', 6),
('Military Police', 'All', 7),
('Aviation', 'All', 8),
('Admin/Personnel', 'All', 9),
('Special Operations', 'All', 10);

INSERT INTO civilian_jobs (title, description, salary_range, growth_outlook) VALUES
('Security Manager', 'Oversee security operations and personnel', '$60K-$100K', 'High'),
('Project Manager', 'Lead teams and manage complex projects', '$70K-$120K', 'High'),
('Healthcare Administrator', 'Manage healthcare facilities and staff', '$65K-$110K', 'High'),
('Emergency Medical Technician', 'Provide emergency medical care', '$35K-$55K', 'Medium'),
('Data Analyst', 'Analyze data and create insights', '$55K-$95K', 'High'),
('Cybersecurity Specialist', 'Protect systems from threats', '$75K-$130K', 'High'),
('Supply Chain Manager', 'Manage logistics and operations', '$65K-$110K', 'High'),
('Operations Manager', 'Oversee daily business operations', '$60K-$100K', 'High'),
('Law Enforcement Officer', 'Protect and serve communities', '$45K-$80K', 'Medium'),
('Pilot/Aviation Manager', 'Fly or manage aviation operations', '$80K-$150K', 'Medium');

-- ============================================================
-- 5. BIG FEELINGS TOOLKIT (Youth)
-- ============================================================

-- Feelings
CREATE TABLE IF NOT EXISTS feelings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    emoji TEXT NOT NULL,
    color TEXT DEFAULT '#00D9C4',
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Coping tools for feelings
CREATE TABLE IF NOT EXISTS coping_tools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feeling_id UUID REFERENCES feelings(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    duration TEXT, -- '2 min', '5 min', etc.
    icon TEXT DEFAULT 'self_improvement',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert defaults
INSERT INTO feelings (name, emoji, color, sort_order) VALUES
('Anxious', '😰', '#F59E0B', 1),
('Angry', '😠', '#EF4444', 2),
('Sad', '😢', '#3B82F6', 3),
('Overwhelmed', '🤯', '#8B5CF6', 4),
('Lonely', '😔', '#6366F1', 5),
('Scared', '😨', '#EC4899', 6);

-- Insert coping tools (need to do after feelings are inserted)
-- This would be done via triggers or separate inserts in production

-- ============================================================
-- 6. QUIZ CONTENT (Who Am I, etc.)
-- ============================================================

-- Quizzes
CREATE TABLE IF NOT EXISTS quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT,
    icon TEXT DEFAULT 'quiz',
    target_audience TEXT DEFAULT 'all', -- 'youth', 'military', 'veteran', 'all'
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz questions
CREATE TABLE IF NOT EXISTS quiz_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz options (answers)
CREATE TABLE IF NOT EXISTS quiz_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID REFERENCES quiz_questions(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    result_key TEXT NOT NULL, -- maps to a result type
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz results
CREATE TABLE IF NOT EXISTS quiz_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
    result_key TEXT NOT NULL,
    title TEXT NOT NULL,
    emoji TEXT,
    description TEXT NOT NULL,
    strengths TEXT[],
    growth_areas TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert Who Am I quiz
INSERT INTO quizzes (slug, title, description, target_audience) VALUES
('who-am-i', 'Who Am I?', 'Discover your personality type and strengths', 'youth');

-- ============================================================
-- 7. CAREER CONTENT
-- ============================================================

-- Career paths for youth/career sampler
CREATE TABLE IF NOT EXISTS career_paths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    emoji TEXT NOT NULL,
    tagline TEXT NOT NULL,
    description TEXT NOT NULL,
    day_in_life TEXT,
    skills_needed TEXT[],
    education_path TEXT,
    salary_range TEXT,
    color TEXT DEFAULT '#00D9C4',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert defaults
INSERT INTO career_paths (title, emoji, tagline, description, skills_needed, salary_range, sort_order) VALUES
('Software Developer', '💻', 'Build the future with code', 'Create apps, websites, and software that millions of people use every day.', ARRAY['Problem solving', 'Logic', 'Creativity', 'Patience'], '$70K-$150K', 1),
('Healthcare Professional', '🏥', 'Help people heal and thrive', 'Make a direct impact on people''s lives through medical care.', ARRAY['Empathy', 'Attention to detail', 'Communication', 'Resilience'], '$50K-$200K', 2),
('Creative Designer', '🎨', 'Turn ideas into visual stories', 'Design everything from logos to user interfaces to entire brand experiences.', ARRAY['Creativity', 'Visual thinking', 'Communication', 'Adaptability'], '$45K-$100K', 3),
('Entrepreneur', '🚀', 'Build your own path', 'Start and grow your own business, solving problems your way.', ARRAY['Risk-taking', 'Leadership', 'Persistence', 'Adaptability'], 'Varies widely', 4),
('Environmental Scientist', '🌍', 'Protect our planet', 'Study and solve environmental challenges for a sustainable future.', ARRAY['Research', 'Analysis', 'Passion', 'Communication'], '$50K-$100K', 5),
('Content Creator', '📱', 'Share your voice with the world', 'Create videos, podcasts, or written content that entertains and informs.', ARRAY['Creativity', 'Consistency', 'Communication', 'Tech-savvy'], '$30K-$500K+', 6);

-- ============================================================
-- 8. TIP CARDS CONTENT
-- ============================================================

-- Tip card categories
CREATE TABLE IF NOT EXISTS tip_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    subtitle TEXT,
    icon TEXT DEFAULT 'lightbulb',
    accent_color TEXT DEFAULT '#00D9C4',
    target_audience TEXT DEFAULT 'all',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Individual tips
CREATE TABLE IF NOT EXISTS tips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES tip_categories(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    icon TEXT,
    key_points TEXT[],
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert some categories
INSERT INTO tip_categories (slug, title, subtitle, target_audience, sort_order) VALUES
('resilience', 'Building Resilience', 'Strategies for tough times', 'all', 1),
('sleep', 'Better Sleep', 'Rest and recovery tips', 'all', 2),
('focus', 'Improving Focus', 'Concentration techniques', 'all', 3),
('transition', 'Transition Tips', 'Navigating life changes', 'military', 4),
('study', 'Study Strategies', 'Learn more effectively', 'youth', 5),
('confidence', 'Building Confidence', 'Believe in yourself', 'youth', 6);

-- ============================================================
-- 9. CHECKLIST CONTENT
-- ============================================================

-- Checklist templates
CREATE TABLE IF NOT EXISTS checklist_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    subtitle TEXT,
    icon TEXT DEFAULT 'checklist',
    accent_color TEXT DEFAULT '#00D9C4',
    target_audience TEXT DEFAULT 'all',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Checklist categories (sections within a checklist)
CREATE TABLE IF NOT EXISTS checklist_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID REFERENCES checklist_templates(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    icon TEXT DEFAULT 'folder',
    color TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Checklist items
CREATE TABLE IF NOT EXISTS checklist_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID REFERENCES checklist_sections(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subtitle TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert some templates
INSERT INTO checklist_templates (slug, title, subtitle, target_audience, sort_order) VALUES
('morning-routine', 'Morning Routine', 'Start your day right', 'all', 1),
('evening-wind-down', 'Evening Wind Down', 'Prepare for restful sleep', 'all', 2),
('transition-prep', 'Transition Preparation', 'Get ready for civilian life', 'military', 3),
('exam-prep', 'Exam Preparation', 'Study checklist', 'youth', 4);

-- ============================================================
-- 10. RESOURCE LISTS
-- ============================================================

-- Resource categories
CREATE TABLE IF NOT EXISTS resource_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    subtitle TEXT,
    icon TEXT DEFAULT 'folder',
    accent_color TEXT DEFAULT '#00D9C4',
    target_audience TEXT DEFAULT 'all',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Resource sections (groups within a category)
CREATE TABLE IF NOT EXISTS resource_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES resource_categories(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    icon TEXT DEFAULT 'list',
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Individual resources
CREATE TABLE IF NOT EXISTS resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID REFERENCES resource_sections(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subtitle TEXT,
    description TEXT,
    icon TEXT DEFAULT 'link',
    details TEXT[],
    external_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert some categories
INSERT INTO resource_categories (slug, title, subtitle, target_audience, sort_order) VALUES
('veteran-benefits', 'Veteran Benefits', 'Resources and support', 'veteran', 1),
('mental-health', 'Mental Health Support', 'Help when you need it', 'all', 2),
('career-resources', 'Career Resources', 'Job search and growth', 'all', 3),
('youth-support', 'Youth Support', 'Help for young people', 'youth', 4);

-- ============================================================
-- 11. LEARNING STYLES & STUDY CONTENT
-- ============================================================

-- Learning styles
CREATE TABLE IF NOT EXISTS learning_styles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    emoji TEXT NOT NULL,
    description TEXT NOT NULL,
    tips TEXT[],
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Study strategies
CREATE TABLE IF NOT EXISTS study_strategies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    best_for TEXT[], -- learning style names
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert defaults
INSERT INTO learning_styles (name, emoji, description, tips, sort_order) VALUES
('Visual', '👁️', 'You learn best by seeing', ARRAY['Use diagrams and charts', 'Color-code your notes', 'Watch video tutorials'], 1),
('Auditory', '👂', 'You learn best by hearing', ARRAY['Record lectures', 'Discuss topics out loud', 'Use podcasts and audiobooks'], 2),
('Reading/Writing', '📝', 'You learn best through text', ARRAY['Take detailed notes', 'Rewrite key concepts', 'Create summaries'], 3),
('Kinesthetic', '🤲', 'You learn best by doing', ARRAY['Use hands-on practice', 'Take frequent breaks', 'Act out scenarios'], 4);

INSERT INTO study_strategies (name, description, best_for, sort_order) VALUES
('Pomodoro Technique', '25 min focus, 5 min break', ARRAY['All styles'], 1),
('Mind Mapping', 'Visual diagram of connected ideas', ARRAY['Visual', 'Kinesthetic'], 2),
('Teach Someone', 'Explain concepts to others', ARRAY['Auditory', 'Kinesthetic'], 3),
('Flashcards', 'Quick recall practice', ARRAY['Visual', 'Reading/Writing'], 4),
('Practice Problems', 'Learn by doing exercises', ARRAY['Kinesthetic', 'Reading/Writing'], 5);

-- ============================================================
-- 12. CONFIDENCE BUILDER CONTENT
-- ============================================================

-- Confidence challenges
CREATE TABLE IF NOT EXISTS confidence_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Affirmations
CREATE TABLE IF NOT EXISTS affirmations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    target_audience TEXT DEFAULT 'all',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Daily confidence actions
CREATE TABLE IF NOT EXISTS confidence_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    difficulty TEXT DEFAULT 'easy', -- 'easy', 'medium', 'hard'
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert defaults
INSERT INTO confidence_challenges (text, sort_order) VALUES
('Speaking up in groups', 1),
('Trying new things', 2),
('Meeting new people', 3),
('Handling criticism', 4),
('Making decisions', 5),
('Asking for help', 6);

INSERT INTO affirmations (text, target_audience, sort_order) VALUES
('I am capable and strong', 'all', 1),
('My voice matters', 'all', 2),
('I learn from every experience', 'all', 3),
('I am enough exactly as I am', 'all', 4),
('I can handle whatever comes', 'all', 5),
('I choose courage over comfort', 'all', 6);

INSERT INTO confidence_actions (text, difficulty, sort_order) VALUES
('Give someone a genuine compliment', 'easy', 1),
('Share an idea in a group', 'medium', 2),
('Try something you''ve never done', 'medium', 3),
('Start a conversation with someone new', 'hard', 4),
('Ask a question when confused', 'easy', 5),
('Stand up for something you believe in', 'hard', 6);

-- ============================================================
-- 13. INTEREST EXPLORER (Youth)
-- ============================================================

-- Interest categories
CREATE TABLE IF NOT EXISTS interest_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    emoji TEXT NOT NULL,
    color TEXT DEFAULT '#00D9C4',
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Interest challenges/activities
CREATE TABLE IF NOT EXISTS interest_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES interest_categories(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    difficulty TEXT DEFAULT 'easy',
    duration TEXT, -- '5 min', '30 min', etc.
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert defaults
INSERT INTO interest_categories (name, emoji, color, sort_order) VALUES
('Creative', '🎨', '#EC4899', 1),
('Tech', '💻', '#3B82F6', 2),
('Active', '⚽', '#22C55E', 3),
('Nature', '🌿', '#10B981', 4),
('Social', '👥', '#F59E0B', 5),
('Learning', '📚', '#8B5CF6', 6);

-- ============================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================

DO $$ 
DECLARE 
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        AND table_name IN (
            'mood_reasons', 'mood_responses',
            'daily_brief_energy_levels', 'daily_brief_objectives', 'daily_brief_challenges',
            'aar_went_well_options', 'aar_improve_options', 'aar_takeaway_options',
            'military_roles', 'civilian_jobs', 'role_job_mappings',
            'feelings', 'coping_tools',
            'quizzes', 'quiz_questions', 'quiz_options', 'quiz_results',
            'career_paths',
            'tip_categories', 'tips',
            'checklist_templates', 'checklist_sections', 'checklist_items',
            'resource_categories', 'resource_sections', 'resources',
            'learning_styles', 'study_strategies',
            'confidence_challenges', 'affirmations', 'confidence_actions',
            'interest_categories', 'interest_activities'
        )
    LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('CREATE POLICY "Public read access" ON %I FOR SELECT USING (true)', t);
        EXECUTE format('CREATE POLICY "Authenticated write access" ON %I FOR ALL USING (auth.role() = ''authenticated'')', t);
    END LOOP;
END $$;

-- ============================================================
-- UPDATED_AT TRIGGERS
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at to tables that need it
DO $$ 
DECLARE 
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        AND table_name IN (
            'mood_reasons', 'daily_brief_energy_levels', 'daily_brief_objectives',
            'military_roles', 'civilian_jobs', 'feelings', 'quizzes', 'career_paths',
            'tip_categories', 'checklist_templates', 'resource_categories',
            'learning_styles', 'affirmations'
        )
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()', t);
            EXECUTE format('CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()', t);
        EXCEPTION WHEN OTHERS THEN
            -- Trigger might already exist
            NULL;
        END;
    END LOOP;
END $$;
