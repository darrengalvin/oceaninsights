-- ============================================================
-- USER TYPE SCREENS SCHEMA
-- Admin-controlled content for Military, Veteran, Youth screens
-- ============================================================

-- Screen types (military, veteran, youth)
CREATE TABLE IF NOT EXISTS user_type_screens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL, -- 'military', 'veteran', 'youth'
    title TEXT NOT NULL,
    subtitle TEXT,
    icon TEXT DEFAULT 'person',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sections within each screen (Personal Growth, Health & Wellness, etc.)
CREATE TABLE IF NOT EXISTS user_type_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    screen_id UUID REFERENCES user_type_screens(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    icon TEXT DEFAULT 'folder',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Items within each section (New Passions, Fitness & Nutrition, etc.)
CREATE TABLE IF NOT EXISTS user_type_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID REFERENCES user_type_sections(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subtitle TEXT,
    icon TEXT DEFAULT 'arrow_forward',
    -- Action type determines what happens when tapped
    action_type TEXT NOT NULL DEFAULT 'tip_cards', 
    -- 'tip_cards', 'checklist', 'resources', 'breathing', 'quiz', 'skills_translator', 'contact_help', 'goals', 'external_link'
    action_data TEXT, -- JSON or slug reference for the action
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default screens
INSERT INTO user_type_screens (slug, title, subtitle, icon, sort_order) VALUES
('military', 'Military', 'For active duty service members', 'military_tech', 1),
('veteran', 'Veterans', 'For those who have served', 'shield', 2),
('youth', 'Young People', 'For young people finding their way', 'school', 3)
ON CONFLICT (slug) DO NOTHING;

-- Get the screen IDs for inserts
DO $$
DECLARE
    military_screen_id UUID;
    veteran_screen_id UUID;
    youth_screen_id UUID;
    section_id UUID;
BEGIN
    SELECT id INTO military_screen_id FROM user_type_screens WHERE slug = 'military';
    SELECT id INTO veteran_screen_id FROM user_type_screens WHERE slug = 'veteran';
    SELECT id INTO youth_screen_id FROM user_type_screens WHERE slug = 'youth';

    -- ============================================================
    -- VETERAN SECTIONS & ITEMS
    -- ============================================================
    
    -- Personal Growth
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (veteran_screen_id, 'Personal Growth', 'trending_up', 1) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'New Passions', 'Classes, hobbies, and personal interests to explore', 'tip_cards', 'new-passions', 1),
    (section_id, 'Family Lifeskills', 'Parenting, relationships, and family tools', 'tip_cards', 'family-lifeskills', 2),
    (section_id, 'Vet To Entrepreneur', 'Startup guide and business resources', 'resources', 'vet-entrepreneur', 3);

    -- Health & Wellness
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (veteran_screen_id, 'Health & Wellness', 'favorite', 2) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Fitness & Nutrition', 'Vet-tailored workout & diet plans', 'tip_cards', 'fitness-nutrition', 1),
    (section_id, 'Health Routine Tracker', 'Simple app to keep your health on point', 'checklist', 'health-tracker', 2),
    (section_id, 'Whole Health VA', 'Integrated approach to mind and body care', 'resources', 'whole-health-va', 3);

    -- Finances & Benefits
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (veteran_screen_id, 'Finances & Benefits', 'account_balance', 3) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Financial Maximizer', 'Vet-specific advice to optimize your finances', 'tip_cards', 'financial-maximizer', 1),
    (section_id, 'VA & DoD Benefits', 'Tools to stay current and maximize your benefits', 'resources', 'va-benefits', 2),
    (section_id, 'Retirement Resources', 'Pension options, TSP, and estate planning', 'resources', 'retirement', 3);

    -- Veteran Events & Activities
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (veteran_screen_id, 'Veteran Events & Activities', 'event', 4) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Local Vet Meetups', 'Event list by city and interests', 'resources', 'local-meetups', 1),
    (section_id, 'Vet-Friendly Conferences', 'Learn & network with other vets', 'tip_cards', 'vet-conferences', 2),
    (section_id, 'Sports & Adventure', 'Outdoor trips and veteran rec leagues', 'resources', 'sports-adventure', 3);

    -- Volunteer & Community
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (veteran_screen_id, 'Volunteer & Community', 'volunteer_activism', 5) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Ways to Volunteer', 'Opportunities to serve your community', 'resources', 'volunteer', 1),
    (section_id, 'Mentorship Programs', 'Guide vets and youth through transition', 'resources', 'mentorship', 2),
    (section_id, 'Veteran Outreach', 'Help those struggling the most', 'tip_cards', 'vet-outreach', 3);

    -- VetTech & Employment
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (veteran_screen_id, 'VetTech & Employment', 'computer', 6) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'VetTech Training', 'Best schools and free enrollment advice', 'resources', 'vettech', 1),
    (section_id, 'Job Boards & Apps', 'Veteran-focused job sites and apps', 'resources', 'job-boards', 2),
    (section_id, 'Networking Tips', 'Build your professional network', 'tip_cards', 'networking', 3);

    -- Mindfulness & Calm
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (veteran_screen_id, 'Mindfulness & Calm', 'self_improvement', 7) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Breathing Exercises', 'Quick stress relief', 'breathing', NULL, 1),
    (section_id, 'Civilian Skills Translator', 'Translate your experience', 'skills_translator', NULL, 2);

    -- Legacy Planning
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (veteran_screen_id, 'Legacy Planning', 'gavel', 8) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Estate Planning', 'Manage wills, trusts, and survivor benefits', 'checklist', 'estate-planning', 1),
    (section_id, 'Veteran Memorials', 'Honor and remember those we''ve lost', 'tip_cards', 'memorials', 2),
    (section_id, 'Veteran History Projects', 'Get involved in preserving military history', 'tip_cards', 'history-projects', 3);

    -- Crisis & Support Access
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (veteran_screen_id, 'Crisis & Support Access', 'health_and_safety', 9) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'When You''re Not OK', 'Clear, calm support pathways', 'contact_help', 'crisis', 1),
    (section_id, 'Veterans Crisis Line', 'Immediate support: 988 Press 1', 'contact_help', 'crisis-line', 2);

    -- ============================================================
    -- MILITARY SECTIONS & ITEMS (Active Duty Mode)
    -- ============================================================
    
    -- Daily Ops & Structure
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (military_screen_id, 'Daily Ops & Structure', 'assignment', 1) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Daily Brief', 'Short prompt for mission focus', 'daily_brief', NULL, 1),
    (section_id, 'Mission Planner', 'Plan the day: Primary / Secondary / Contingency', 'mission_planner', NULL, 2),
    (section_id, 'After Action Review', 'Quick debrief: What worked? What didn''t?', 'after_action_review', NULL, 3);

    -- Mental Readiness
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (military_screen_id, 'Mental Readiness', 'psychology', 2) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Stress Reset Drills', 'Quick mental reset routines', 'breathing', NULL, 1),
    (section_id, 'Shift & Sleep Support', 'Adjust to night, rotations, shift work', 'tip_cards', 'shift-sleep', 2),
    (section_id, 'Focus Under Pressure', 'Mindset drills for performance', 'tip_cards', 'focus-pressure', 3),
    (section_id, 'Tactical Mindset Drills', 'Mental preparation techniques', 'tip_cards', 'tactical-mindset', 4);

    -- Leadership & Team Skills
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (military_screen_id, 'Leadership & Team Skills', 'groups', 3) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Situational Leadership', 'Scenarios to practice tactical leadership', 'scenarios', NULL, 1),
    (section_id, 'Difficult Conversations', 'Exercise rank-appropriate talks', 'protocols', NULL, 2);

    -- Transition & Career Support
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (military_screen_id, 'Transition & Career Support', 'work', 4) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Civilian Skills Translator', 'MOS to civilian job translator', 'skills_translator', NULL, 1),
    (section_id, 'Resume & Interview Help', 'Translate experience, prep for interviews', 'tip_cards', 'resume-interview', 2);

    -- Crisis & Support Access
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (military_screen_id, 'Crisis & Support Access', 'health_and_safety', 5) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'When You''re Not OK', 'Clear, calm support pathways', 'contact_help', 'crisis', 1),
    (section_id, 'Emergency Help', 'Region-aware resources', 'contact_help', 'emergency', 2);

    -- ============================================================
    -- YOUTH SECTIONS & ITEMS
    -- ============================================================
    
    -- Identity & Self-Discovery
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (youth_screen_id, 'Identity & Self-Discovery', 'person_search', 1) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Who Am I?', 'Values, strengths, and personality quizzes', 'quiz', 'who-am-i', 1),
    (section_id, 'Explore Interests', 'Try mini challenges in art, tech, sports, writing', 'interest_explorer', NULL, 2),
    (section_id, 'Confidence Builder', 'Tools for self-esteem and self-expression', 'confidence_builder', NULL, 3);

    -- School & Learning
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (youth_screen_id, 'School & Learning', 'menu_book', 2) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Study Smarter', 'Learning styles, focus tools, revision tips', 'study_smarter', NULL, 1),
    (section_id, 'Subject Explorer', 'What different subjects can lead to', 'tip_cards', 'subject-explorer', 2),
    (section_id, 'Ask for Help', 'How to talk to teachers, counselors, and parents', 'tip_cards', 'ask-for-help', 3);

    -- Future Pathways
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (youth_screen_id, 'Future Pathways', 'route', 3) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Career Sampler', 'Short previews of different jobs', 'career_sampler', NULL, 1),
    (section_id, 'College vs Trades', 'Understand your options early', 'tip_cards', 'college-vs-trades', 2),
    (section_id, 'Goal Setting', 'Plan short-term and long-term goals', 'goals', NULL, 3);

    -- Mental Health & Emotions
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (youth_screen_id, 'Mental Health & Emotions', 'psychology', 4) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Big Feelings Toolkit', 'Anxiety, anger, sadness - tools to cope', 'big_feelings', NULL, 1),
    (section_id, 'Stress Coping Skills', 'Manage stress and find calm', 'breathing', NULL, 2),
    (section_id, 'Daily Check-In', 'Build awareness of how you''re feeling', 'goals', NULL, 3);

    -- Relationships & Belonging
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (youth_screen_id, 'Relationships & Belonging', 'people', 5) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Friendship Skills', 'Communication and boundaries', 'tip_cards', 'friendship', 1),
    (section_id, 'Family Dynamics', 'Handling expectations and conflict', 'tip_cards', 'family-dynamics', 2),
    (section_id, 'Finding Your People', 'Clubs, teams, and communities', 'resources', 'finding-your-people', 3);

    -- Life Skills
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (youth_screen_id, 'Life Skills', 'lightbulb', 6) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Money Basics', 'Saving, budgeting, and spending', 'tip_cards', 'money-basics', 1),
    (section_id, 'Time Management', 'Homework + life balance', 'tip_cards', 'time-management', 2),
    (section_id, 'Digital Life', 'Social media, privacy, safety', 'tip_cards', 'digital-life', 3);

    -- Inspiration & Role Models
    INSERT INTO user_type_sections (screen_id, title, icon, sort_order) 
    VALUES (youth_screen_id, 'Inspiration & Role Models', 'bolt', 7) RETURNING id INTO section_id;
    
    INSERT INTO user_type_items (section_id, title, subtitle, action_type, action_data, sort_order) VALUES
    (section_id, 'Real Student Stories', 'Different journeys, same struggles', 'tip_cards', 'student-stories', 1),
    (section_id, 'Mentor Connect', 'Older students or young professionals', 'resources', 'mentor-connect', 2),
    (section_id, 'Try Something New', 'Monthly challenges', 'checklist', 'monthly-challenges', 3);

END $$;

-- Enable RLS with permissive policy
ALTER TABLE user_type_screens ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_type_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_type_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all operations" ON user_type_screens FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON user_type_sections FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON user_type_items FOR ALL USING (true) WITH CHECK (true);
