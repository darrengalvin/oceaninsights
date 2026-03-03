-- ============================================================
-- HARASSMENT SUPPORT WIZARD SCHEMA
-- Service Women's guided assessment tool (zero free-text, tap-only)
-- All content admin-managed via the admin panel
-- ============================================================

-- ============================================================
-- 1. WIZARD STEPS
-- The questions presented to the user (e.g., "What are you experiencing?")
-- ============================================================

CREATE TABLE IF NOT EXISTS harassment_wizard_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,                    -- "What are you experiencing?"
    subtitle TEXT,                          -- "Select the option that best describes your situation"
    step_number INTEGER NOT NULL UNIQUE,    -- 1, 2, 3... determines order
    icon TEXT DEFAULT 'help_outline',
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 2. WIZARD OPTIONS
-- Tappable options within each step
-- Each option has a tag used to match guidance cards later
-- ============================================================

CREATE TABLE IF NOT EXISTS harassment_wizard_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    step_id UUID NOT NULL REFERENCES harassment_wizard_steps(id) ON DELETE CASCADE,
    text TEXT NOT NULL,                     -- "Unwanted comments"
    description TEXT,                       -- Optional longer description shown on tap
    icon TEXT DEFAULT 'circle',
    tag TEXT NOT NULL,                      -- e.g., 'verbal', 'workplace', 'frequent' — used for matching
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 3. WIZARD GUIDANCE CARDS
-- Personalised guidance shown at the end based on selections
-- Cards are tagged and shown when the user's selection tags match
-- ============================================================

CREATE TABLE IF NOT EXISTS harassment_wizard_guidance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,                    -- "What this is classified as"
    message TEXT NOT NULL,                  -- The actual guidance content
    guidance_type TEXT NOT NULL DEFAULT 'info',
    -- Types: 'classification', 'rights', 'action_formal', 'action_informal', 
    --        'support', 'self_care', 'info', 'warning'
    icon TEXT DEFAULT 'info_outline',
    priority INTEGER DEFAULT 0,            -- Higher = shown first in results
    match_tags TEXT[] DEFAULT '{}',        -- Array of tags — shown when ANY match user selections
    is_universal BOOLEAN DEFAULT false,    -- If true, always shown regardless of selections
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 4. SUPPORT CONTACTS
-- Emergency and non-emergency contacts shown in results
-- ============================================================

CREATE TABLE IF NOT EXISTS harassment_wizard_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,                     -- "SSAFA"
    description TEXT,                       -- "Forces charity providing support..."
    phone TEXT,                             -- Phone number (tap to call)
    website TEXT,                           -- Website URL (tap to open)
    availability TEXT,                      -- "24/7" or "Mon-Fri 9am-5pm"
    icon TEXT DEFAULT 'phone',
    is_emergency BOOLEAN DEFAULT false,     -- Emergency contacts shown at top
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- INSERT DEFAULT CONTENT
-- ============================================================

-- Step 1: What are you experiencing?
INSERT INTO harassment_wizard_steps (title, subtitle, step_number, icon, sort_order) VALUES
('What are you experiencing?', 'Select the option that best describes your situation. Everything here is completely private.', 1, 'psychology', 1);

-- Step 2: Where is this happening?
INSERT INTO harassment_wizard_steps (title, subtitle, step_number, icon, sort_order) VALUES
('Where is this happening?', 'This helps us provide the most relevant guidance.', 2, 'location_on', 2);

-- Step 3: How often?
INSERT INTO harassment_wizard_steps (title, subtitle, step_number, icon, sort_order) VALUES
('How often is this happening?', 'There is no wrong answer. Your experience is valid.', 3, 'schedule', 3);

-- Step 4: How is it affecting you?
INSERT INTO harassment_wizard_steps (title, subtitle, step_number, icon, sort_order) VALUES
('How is this affecting you?', 'Select all that apply. Understanding the impact helps us guide you.', 4, 'favorite_border', 4);

-- ============================================================
-- Step 1 Options: What are you experiencing?
-- ============================================================

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'Unwanted comments or remarks', 'Comments about your appearance, gender, or personal life that make you uncomfortable', 'chat_bubble_outline', 'verbal', 1
FROM harassment_wizard_steps WHERE step_number = 1;

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'Unwanted physical contact', 'Any physical contact that you did not invite or welcome', 'do_not_touch', 'physical', 2
FROM harassment_wizard_steps WHERE step_number = 1;

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'Being excluded or isolated', 'Deliberately left out of activities, briefings, or social situations', 'person_remove', 'exclusion', 3
FROM harassment_wizard_steps WHERE step_number = 1;

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'Inappropriate messages or images', 'Receiving unwanted messages, images, or content of a sexual or demeaning nature', 'report', 'digital', 4
FROM harassment_wizard_steps WHERE step_number = 1;

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'Pressure for relationship or favours', 'Being pressured into a relationship, date, or sexual activity', 'warning', 'coercion', 5
FROM harassment_wizard_steps WHERE step_number = 1;

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'Feeling unsafe', 'A general sense of not feeling safe around a specific person or in a specific environment', 'shield', 'safety', 6
FROM harassment_wizard_steps WHERE step_number = 1;

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'Bullying related to gender', 'Being targeted, mocked, or undermined because of your gender', 'group_off', 'gender_bullying', 7
FROM harassment_wizard_steps WHERE step_number = 1;

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'Something else that feels wrong', 'You may not have a name for it, but you know it does not feel right', 'help_outline', 'other', 8
FROM harassment_wizard_steps WHERE step_number = 1;

-- ============================================================
-- Step 2 Options: Where is this happening?
-- ============================================================

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'In the workplace', 'work', 'workplace', 1
FROM harassment_wizard_steps WHERE step_number = 2;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'In accommodation or barracks', 'hotel', 'accommodation', 2
FROM harassment_wizard_steps WHERE step_number = 2;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'Online or social media', 'phone_android', 'online', 3
FROM harassment_wizard_steps WHERE step_number = 2;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'During deployment or exercise', 'flight_takeoff', 'deployment', 4
FROM harassment_wizard_steps WHERE step_number = 2;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'During training', 'fitness_center', 'training', 5
FROM harassment_wizard_steps WHERE step_number = 2;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'At social events', 'celebration', 'social', 6
FROM harassment_wizard_steps WHERE step_number = 2;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'Multiple locations', 'place', 'multiple_locations', 7
FROM harassment_wizard_steps WHERE step_number = 2;

-- ============================================================
-- Step 3 Options: How often?
-- ============================================================

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'It happened once', 'A single incident', 'looks_one', 'once', 1
FROM harassment_wizard_steps WHERE step_number = 3;

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'A few times', 'It has happened more than once but not regularly', 'repeat', 'few_times', 2
FROM harassment_wizard_steps WHERE step_number = 3;

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'Regularly', 'It happens on a recurring basis', 'event_repeat', 'regular', 3
FROM harassment_wizard_steps WHERE step_number = 3;

INSERT INTO harassment_wizard_options (step_id, text, description, icon, tag, sort_order)
SELECT id, 'Constantly', 'It feels like it never stops', 'all_inclusive', 'constant', 4
FROM harassment_wizard_steps WHERE step_number = 3;

-- ============================================================
-- Step 4 Options: How is it affecting you?
-- ============================================================

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'Anxiety or worry', 'psychology', 'impact_anxiety', 1
FROM harassment_wizard_steps WHERE step_number = 4;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'Difficulty sleeping', 'bedtime', 'impact_sleep', 2
FROM harassment_wizard_steps WHERE step_number = 4;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'Loss of confidence', 'trending_down', 'impact_confidence', 3
FROM harassment_wizard_steps WHERE step_number = 4;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'Avoiding certain people or places', 'directions_walk', 'impact_avoidance', 4
FROM harassment_wizard_steps WHERE step_number = 4;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'Affecting my work performance', 'work_off', 'impact_work', 5
FROM harassment_wizard_steps WHERE step_number = 4;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'Feeling angry or frustrated', 'sentiment_very_dissatisfied', 'impact_anger', 6
FROM harassment_wizard_steps WHERE step_number = 4;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'Thinking about leaving the service', 'exit_to_app', 'impact_leaving', 7
FROM harassment_wizard_steps WHERE step_number = 4;

INSERT INTO harassment_wizard_options (step_id, text, icon, tag, sort_order)
SELECT id, 'Feeling isolated or alone', 'person', 'impact_isolation', 8
FROM harassment_wizard_steps WHERE step_number = 4;

-- ============================================================
-- GUIDANCE CARDS
-- ============================================================

-- Universal guidance (always shown)
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, is_universal, sort_order) VALUES
('You are not alone', 'What you are experiencing is not your fault, and you do not have to deal with it alone. Many service women have been through similar situations and come out the other side stronger. This tool is here to help you understand your options.', 'info', 'people', 100, true, 1);

INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, is_universal, sort_order) VALUES
('Your rights', 'Under the Armed Forces Act and the Equality Act 2010, you are protected from harassment, bullying, and discrimination. The military has a zero-tolerance policy. You have the right to serve in an environment free from unwanted behaviour.', 'rights', 'gavel', 90, true, 2);

INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, is_universal, sort_order) VALUES
('Nothing is recorded', 'This assessment is completely private. No data leaves your device. No record is kept. This is just for you.', 'info', 'lock', 95, true, 3);

-- Verbal harassment guidance
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, match_tags, sort_order) VALUES
('Understanding unwanted remarks', 'Unwanted comments — even if disguised as "banter" or "jokes" — can constitute harassment if they are unwelcome and relate to your gender, appearance, or personal characteristics. You do not have to laugh it off or accept it.', 'classification', 'info_outline', 80, ARRAY['verbal', 'gender_bullying'], 10);

-- Physical harassment guidance
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, match_tags, sort_order) VALUES
('Unwanted physical contact', 'Any physical contact that you have not consented to is unacceptable, regardless of the other person''s intention. This includes touching, grabbing, blocking your path, or invading your personal space. This can be classified as assault.', 'classification', 'warning', 85, ARRAY['physical'], 11);

-- Coercion guidance
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, match_tags, sort_order) VALUES
('Pressure and coercion', 'Being pressured into a relationship or sexual activity — especially by someone in a position of authority — is a serious matter. This may constitute sexual harassment or misconduct under service regulations, regardless of whether anything physical occurred.', 'classification', 'warning', 85, ARRAY['coercion', 'safety'], 12);

-- Digital harassment guidance
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, match_tags, sort_order) VALUES
('Digital harassment', 'Receiving unwanted sexual or demeaning content digitally is harassment. This includes messages, images, videos, or social media behaviour. Screenshots and evidence can be helpful if you choose to report, but you do not have to gather evidence alone.', 'classification', 'info_outline', 75, ARRAY['digital', 'online'], 13);

-- Frequent/escalating pattern
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, match_tags, sort_order) VALUES
('A pattern of behaviour', 'When unwanted behaviour happens regularly or constantly, it often indicates a pattern that is unlikely to stop on its own. Patterns of behaviour are taken more seriously in formal complaints and are easier to act on.', 'warning', 'trending_up', 80, ARRAY['regular', 'constant', 'few_times'], 14);

-- Formal action guidance
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, is_universal, sort_order) VALUES
('Formal complaint process', 'You have the right to make a formal Service Complaint. The process is: 1) Speak to your Unit Welfare Officer or another trusted officer. 2) They will guide you through submitting a formal written complaint. 3) An investigation will be conducted. 4) You are protected from retaliation. You can also contact the Service Complaints Ombudsman if you feel the process is not fair.', 'action_formal', 'description', 70, true, 20);

-- Informal options
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, is_universal, sort_order) VALUES
('Informal options', 'Not ready for a formal complaint? That is completely okay. You can: speak to a trusted colleague, mentor, or Padre. Contact SSAFA or other support services anonymously. Use the Confidential Support Line. Speak to your Medical Officer. Sometimes just talking to someone helps you decide your next step.', 'action_informal', 'chat', 65, true, 21);

-- Deployment-specific guidance
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, match_tags, sort_order) VALUES
('Support during deployment', 'Being deployed can feel isolating, especially when experiencing harassment. You still have access to support: your Chain of Command has a duty of care, Welfare Officers are available on deployment, and confidential phone lines operate 24/7. You are not stuck. Options exist even in the field.', 'support', 'flight_takeoff', 70, ARRAY['deployment'], 22);

-- Accommodation guidance
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, match_tags, sort_order) VALUES
('Safety in accommodation', 'If you feel unsafe in your accommodation, you have the right to request a move. Speak to your Unit Welfare Officer or Accommodation Warrant Officer. Your safety takes priority over administrative convenience.', 'action_informal', 'home', 75, ARRAY['accommodation'], 23);

-- Impact-specific: thinking of leaving
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, match_tags, sort_order) VALUES
('Before you consider leaving', 'If harassment is making you think about leaving the service, please know: the problem is the behaviour, not you. Many women have stayed, resolved the situation, and gone on to have fulfilling careers. Getting support now could change everything. Do not let someone else''s behaviour end your career.', 'support', 'military_tech', 70, ARRAY['impact_leaving'], 24);

-- Self-care guidance
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, match_tags, sort_order) VALUES
('Looking after yourself', 'What you are going through is stressful. It is normal to feel anxious, angry, or exhausted. Make sure you are: getting rest where you can, talking to someone you trust, using breathing and grounding techniques (available in this app), and not blaming yourself — none of this is your fault.', 'self_care', 'self_improvement', 60, ARRAY['impact_anxiety', 'impact_sleep', 'impact_confidence', 'impact_isolation', 'impact_anger'], 25);

-- ============================================================
-- SUPPORT CONTACTS
-- ============================================================

INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Emergency Services', 'If you are in immediate danger', '999', NULL, '24/7', 'emergency', true, 1);

INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Service Police / Chain of Command', 'Report a crime or assault through your Unit Provost staff or Chain of Command', NULL, 'https://www.gov.uk/guidance/report-a-crime-in-the-armed-forces', '24/7 via your unit', 'local_police', false, 10);

INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('SSAFA', 'Forces charity providing confidential emotional and practical support', '0800 260 6767', 'https://www.ssafa.org.uk', '09:00 - 17:30 Mon-Fri', 'support_agent', false, 3);

INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Confidential Support Line', 'Free, anonymous, confidential emotional support for Armed Forces', '0800 731 4880', NULL, '24/7', 'phone_in_talk', false, 4);

INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Service Complaints Ombudsman', 'Independent oversight of the Service Complaints process', '020 7877 3450', 'https://www.scoaf.org.uk', '09:00 - 17:00 Mon-Fri', 'balance', false, 5);

INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Combat Stress', 'Mental health charity for veterans and serving personnel', '0800 138 1619', 'https://combatstress.org.uk', '24/7', 'psychology', false, 6);

INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Rape Crisis', 'Specialist support for sexual violence', '0808 500 2222', 'https://rapecrisis.org.uk', '24/7', 'healing', false, 7);

INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Army Welfare Service', 'Welfare and support for Army personnel and families', NULL, 'https://www.army.mod.uk/people/support-well', '09:00 - 17:00 Mon-Fri', 'military_tech', false, 8);

INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Naval Families Federation', 'Independent voice for Naval Service families', NULL, 'https://nff.org.uk', '09:00 - 17:00 Mon-Fri', 'anchor', false, 9);

-- ============================================================
-- ENABLE RLS
-- ============================================================

ALTER TABLE harassment_wizard_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE harassment_wizard_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE harassment_wizard_guidance ENABLE ROW LEVEL SECURITY;
ALTER TABLE harassment_wizard_contacts ENABLE ROW LEVEL SECURITY;

-- Public read for app (all content is non-sensitive — the responses are private/local)
CREATE POLICY "Public read access" ON harassment_wizard_steps FOR SELECT USING (true);
CREATE POLICY "Public read access" ON harassment_wizard_options FOR SELECT USING (true);
CREATE POLICY "Public read access" ON harassment_wizard_guidance FOR SELECT USING (true);
CREATE POLICY "Public read access" ON harassment_wizard_contacts FOR SELECT USING (true);

-- Authenticated write for admin
CREATE POLICY "Authenticated write access" ON harassment_wizard_steps FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated write access" ON harassment_wizard_options FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated write access" ON harassment_wizard_guidance FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated write access" ON harassment_wizard_contacts FOR ALL USING (auth.role() = 'authenticated');

-- Updated at triggers
CREATE TRIGGER set_updated_at BEFORE UPDATE ON harassment_wizard_steps
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON harassment_wizard_guidance
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
