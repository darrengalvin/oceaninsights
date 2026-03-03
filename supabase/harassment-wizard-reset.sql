-- ============================================================
-- RESET HARASSMENT WIZARD DATA
-- Run this to clear and re-seed all content
-- ============================================================

-- Clear existing data (order matters due to foreign keys)
DELETE FROM harassment_wizard_options;
DELETE FROM harassment_wizard_guidance;
DELETE FROM harassment_wizard_contacts;
DELETE FROM harassment_wizard_steps;

-- ============================================================
-- RE-INSERT STEPS
-- ============================================================

INSERT INTO harassment_wizard_steps (title, subtitle, step_number, icon, sort_order) VALUES
('What are you experiencing?', 'Select the option that best describes your situation. Everything here is completely private.', 1, 'psychology', 1),
('Where is this happening?', 'This helps us provide the most relevant guidance.', 2, 'location_on', 2),
('How often is this happening?', 'There is no wrong answer. Your experience is valid.', 3, 'schedule', 3),
('How is this affecting you?', 'Select all that apply. Understanding the impact helps us guide you.', 4, 'favorite_border', 4);

-- ============================================================
-- STEP 1 OPTIONS: What are you experiencing?
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
-- STEP 2 OPTIONS: Where is this happening?
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
-- STEP 3 OPTIONS: How often?
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
-- STEP 4 OPTIONS: How is it affecting you?
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

-- Universal (always shown)
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, is_universal, sort_order) VALUES
('You are not alone', 'What you are experiencing is not your fault, and you do not have to deal with it alone. Many service women have been through similar situations and come out the other side stronger. This tool is here to help you understand your options.', 'info', 'people', 100, true, 1),
('Nothing is recorded', 'This assessment is completely private. No data leaves your device. No record is kept. This is just for you.', 'info', 'lock', 95, true, 2),
('Your rights', 'Under the Armed Forces Act and the Equality Act 2010, you are protected from harassment, bullying, and discrimination. The military has a zero-tolerance policy. You have the right to serve in an environment free from unwanted behaviour.', 'rights', 'gavel', 90, true, 3),
('Formal complaint process', 'You have the right to make a formal Service Complaint. The process is: 1) Speak to your Unit Welfare Officer or another trusted officer. 2) They will guide you through submitting a formal written complaint. 3) An investigation will be conducted. 4) You are protected from retaliation. You can also contact the Service Complaints Ombudsman if you feel the process is not fair.', 'action_formal', 'description', 70, true, 20),
('Informal options', 'Not ready for a formal complaint? That is completely okay. You can: speak to a trusted colleague, mentor, or Padre. Contact SSAFA or other support services anonymously. Use the Confidential Support Line. Speak to your Medical Officer. Sometimes just talking to someone helps you decide your next step.', 'action_informal', 'chat', 65, true, 21);

-- Tag-matched guidance
INSERT INTO harassment_wizard_guidance (title, message, guidance_type, icon, priority, match_tags, sort_order) VALUES
('Understanding unwanted remarks', 'Unwanted comments — even if disguised as "banter" or "jokes" — can constitute harassment if they are unwelcome and relate to your gender, appearance, or personal characteristics. You do not have to laugh it off or accept it.', 'classification', 'info_outline', 80, ARRAY['verbal', 'gender_bullying'], 10),
('Unwanted physical contact', 'Any physical contact that you have not consented to is unacceptable, regardless of the other person''s intention. This includes touching, grabbing, blocking your path, or invading your personal space. This can be classified as assault.', 'classification', 'warning', 85, ARRAY['physical'], 11),
('Pressure and coercion', 'Being pressured into a relationship or sexual activity — especially by someone in a position of authority — is a serious matter. This may constitute sexual harassment or misconduct under service regulations, regardless of whether anything physical occurred.', 'classification', 'warning', 85, ARRAY['coercion', 'safety'], 12),
('Digital harassment', 'Receiving unwanted sexual or demeaning content digitally is harassment. This includes messages, images, videos, or social media behaviour. Screenshots and evidence can be helpful if you choose to report, but you do not have to gather evidence alone.', 'classification', 'info_outline', 75, ARRAY['digital', 'online'], 13),
('A pattern of behaviour', 'When unwanted behaviour happens regularly or constantly, it often indicates a pattern that is unlikely to stop on its own. Patterns of behaviour are taken more seriously in formal complaints and are easier to act on.', 'warning', 'trending_up', 80, ARRAY['regular', 'constant', 'few_times'], 14),
('Support during deployment', 'Being deployed can feel isolating, especially when experiencing harassment. You still have access to support: your Chain of Command has a duty of care, Welfare Officers are available on deployment, and confidential phone lines operate 24/7. You are not stuck. Options exist even in the field.', 'support', 'flight_takeoff', 70, ARRAY['deployment'], 22),
('Safety in accommodation', 'If you feel unsafe in your accommodation, you have the right to request a move. Speak to your Unit Welfare Officer or Accommodation Warrant Officer. Your safety takes priority over administrative convenience.', 'action_informal', 'home', 75, ARRAY['accommodation'], 23),
('Before you consider leaving', 'If harassment is making you think about leaving the service, please know: the problem is the behaviour, not you. Many women have stayed, resolved the situation, and gone on to have fulfilling careers. Getting support now could change everything. Do not let someone else''s behaviour end your career.', 'support', 'military_tech', 70, ARRAY['impact_leaving'], 24),
('Looking after yourself', 'What you are going through is stressful. It is normal to feel anxious, angry, or exhausted. Make sure you are: getting rest where you can, talking to someone you trust, using breathing and grounding techniques (available in this app), and not blaming yourself — none of this is your fault.', 'self_care', 'self_improvement', 60, ARRAY['impact_anxiety', 'impact_sleep', 'impact_confidence', 'impact_isolation', 'impact_anger'], 25);

-- ============================================================
-- SUPPORT CONTACTS
-- No location-specific numbers. Service personnel deploy worldwide.
-- All contacts are military-internal or accessible from anywhere.
-- ============================================================

-- Emergency — no phone number, just guidance (112 works in 80+ countries, 999 UK only)
INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Local Emergency Services', 'If you are in immediate danger, call your local emergency number. In the UK: 999. International: 112. On base: contact the Guardroom or Duty Officer.', NULL, NULL, '24/7', 'emergency', true, 1);

-- Military-internal support (accessible worldwide)
INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Your Unit Welfare Officer', 'Your first point of contact for confidential support within your unit. Available wherever you are posted or deployed.', NULL, NULL, 'During working hours or via Duty Officer', 'support_agent', false, 2),
('Your Chain of Command', 'You can report to any officer in your Chain of Command. If the issue involves your Chain of Command, you can go to the next level up or to a Welfare Officer.', NULL, NULL, 'Available at all times', 'groups', false, 3),
('Unit Padre / Chaplain', 'Chaplains provide completely confidential support regardless of your faith. Conversations with a Padre are privileged — they cannot be compelled to disclose.', NULL, NULL, 'Available at all times', 'volunteer_activism', false, 4),
('Service Police / Provost Staff', 'Report a crime or assault through your Unit Provost staff. You can also report directly to the Service Police.', NULL, 'https://www.gov.uk/guidance/report-a-crime-in-the-armed-forces', 'Available at all times', 'local_police', false, 5);

-- Charities and helplines (accessible from anywhere with phone/internet)
INSERT INTO harassment_wizard_contacts (name, description, phone, website, availability, icon, is_emergency, sort_order) VALUES
('Confidential Support Line', 'Free, anonymous, confidential emotional support for Armed Forces. Call from anywhere in the world.', '+44 1011 4131', NULL, '24/7 worldwide', 'phone_in_talk', false, 10),
('SSAFA', 'Forces charity providing confidential emotional and practical support to serving personnel and families worldwide.', NULL, 'https://www.ssafa.org.uk', 'Online support available worldwide', 'support_agent', false, 11),
('Service Complaints Ombudsman', 'Independent oversight of the Service Complaints process. Can be contacted from anywhere.', NULL, 'https://www.scoaf.org.uk', 'Online contact form available', 'balance', false, 12),
('Combat Stress', 'Mental health charity for veterans and serving personnel. Helpline and online support.', NULL, 'https://combatstress.org.uk', '24/7 helpline and online', 'psychology', false, 13),
('Rape Crisis', 'Specialist support for sexual violence. Live chat available online from anywhere.', NULL, 'https://rapecrisis.org.uk', 'Live chat available online', 'healing', false, 14);
