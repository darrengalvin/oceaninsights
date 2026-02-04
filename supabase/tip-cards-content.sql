-- ============================================================
-- TIP CARDS CONTENT - INTERNATIONALIZED
-- All content generic, not US-specific
-- ============================================================

-- Clear existing tips and categories
DELETE FROM tips;
DELETE FROM tip_categories;

-- ============================================================
-- VETERAN TIP CATEGORIES
-- ============================================================

-- New Passions
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('new-passions', 'Explore New Passions', 'Discover interests beyond military life', 'explore', 'veteran', 1);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Why Try New Things?', 
'Military life often limited time for hobbies. Now you have the freedom to explore. Finding passions brings purpose and joy.',
ARRAY['No more waiting', 'Low stakes - just try', 'It''s about exploration'], 1
FROM tip_categories WHERE slug = 'new-passions';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Physical Activities', 
'Many veterans thrive with physical challenges. Consider hiking, martial arts, fitness classes, or team sports.',
ARRAY['Maintains fitness', 'Community aspect', 'Healthy competition'], 2
FROM tip_categories WHERE slug = 'new-passions';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Creative Pursuits', 
'Art, music, writing, and crafts can be therapeutic and fulfilling. Many veteran programs offer free classes.',
ARRAY['Expression outlet', 'Often veteran-specific groups', 'No experience needed'], 3
FROM tip_categories WHERE slug = 'new-passions';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Learning & Growth', 
'Take classes in anything that interests you. Languages, cooking, technology, finance - education benefits may cover some.',
ARRAY['Community colleges', 'Online courses', 'Veteran discounts common'], 4
FROM tip_categories WHERE slug = 'new-passions';

-- Family Lifeskills
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('family-lifeskills', 'Family Life Skills', 'Build stronger family connections', 'family_restroom', 'veteran', 2);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Reconnecting After Service', 
'Relationships may have changed during your service. Be patient with yourself and family members as you reconnect.',
ARRAY['Give it time', 'Communicate openly', 'Seek counseling if needed'], 1
FROM tip_categories WHERE slug = 'family-lifeskills';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Parenting Transitions', 
'Adjusting to civilian parenting can be challenging. Your children may need time to adjust to having you more present.',
ARRAY['Be consistent', 'Quality time matters', 'Match partner''s parenting style'], 2
FROM tip_categories WHERE slug = 'family-lifeskills';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Relationship Maintenance', 
'Military life stresses relationships. Invest in your partnership with regular check-ins, date nights, and shared goals.',
ARRAY['Schedule couple time', 'Listen actively', 'Consider couples counseling'], 3
FROM tip_categories WHERE slug = 'family-lifeskills';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Managing Conflict', 
'Use communication skills from your service. Stay calm, listen first, and focus on solutions rather than blame.',
ARRAY['Cool down before discussing', 'Use "I" statements', 'Find compromise'], 4
FROM tip_categories WHERE slug = 'family-lifeskills';

-- Fitness & Nutrition
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('fitness-nutrition', 'Fitness & Nutrition', 'Stay healthy in civilian life', 'fitness_center', 'veteran', 3);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Adjusting Your Fitness', 
'Military PT is intense. You may need to adjust to a sustainable civilian routine. Focus on consistency over intensity.',
ARRAY['Find what you enjoy', 'Recovery is important', 'Set realistic goals'], 1
FROM tip_categories WHERE slug = 'fitness-nutrition';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Dealing with Injuries', 
'Many veterans have service-related injuries. Work with healthcare providers to adapt workouts safely.',
ARRAY['Don''t push through pain', 'Consider physical therapy', 'Modify, don''t quit'], 2
FROM tip_categories WHERE slug = 'fitness-nutrition';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Nutrition Basics', 
'Without military meals, you control your nutrition. Focus on whole foods, adequate protein, and hydration.',
ARRAY['Protein with every meal', 'More vegetables', 'Limit processed foods'], 3
FROM tip_categories WHERE slug = 'fitness-nutrition';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Veteran Fitness Programs', 
'Many programs offer discounts or free access to veterans. Check local gyms and community veteran fitness groups.',
ARRAY['Community programs', 'Veteran fitness groups', 'Local gym veteran discounts'], 4
FROM tip_categories WHERE slug = 'fitness-nutrition';

-- Financial Planning
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('financial-maximizer', 'Financial Planning', 'Maximize your benefits and income', 'attach_money', 'veteran', 4);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Know Your Benefits', 
'Many veterans don''t use all their earned benefits. Review disability compensation, education, healthcare, and loan benefits available in your country.',
ARRAY['Check your entitlements', 'Education benefits often available', 'Healthcare is earned'], 1
FROM tip_categories WHERE slug = 'financial-maximizer';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Retirement Fund Management', 
'Your military pension or savings plan is portable. Consider your options carefully before making changes.',
ARRAY['Don''t cash out early - penalties!', 'Review allocation', 'Seek financial advice'], 2
FROM tip_categories WHERE slug = 'financial-maximizer';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Tax Benefits', 
'Veterans may have specific tax advantages. Disability compensation is often tax-free. Check your local tax laws.',
ARRAY['Disability often tax-free', 'Check local benefits', 'Property tax exemptions possible'], 3
FROM tip_categories WHERE slug = 'financial-maximizer';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Credit Building', 
'Good credit opens doors. Check your credit report annually, dispute errors, and build positive history.',
ARRAY['Free credit reports', 'Service member protections may apply', 'Many veteran credit programs'], 4
FROM tip_categories WHERE slug = 'financial-maximizer';

-- Job Search (Internationalized)
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('job-search', 'Job Search', 'Find the right civilian career', 'search', 'veteran', 5);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Target Veteran-Friendly Employers', 
'Many companies actively recruit veterans. Look for those with veteran hiring programs or veteran leadership.',
ARRAY['Search for veteran employer lists', 'Look for veteran employee groups', 'Research company culture'], 1
FROM tip_categories WHERE slug = 'job-search';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Use Veteran Resources', 
'Take advantage of veteran-specific job boards, career fairs, and placement services in your country.',
ARRAY['Veteran employment organizations', 'Military transition programs', 'Government employment services'], 2
FROM tip_categories WHERE slug = 'job-search';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Network Actively', 
'Many jobs come through connections. Reach out to fellow veterans, attend events, and use professional networks.',
ARRAY['Veterans help veterans', 'Attend networking events', 'Be active on LinkedIn'], 3
FROM tip_categories WHERE slug = 'job-search';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Be Patient but Persistent', 
'Finding the right fit takes time. Keep applying, keep networking, and don''t settle for the first offer if it''s not right.',
ARRAY['Quality over speed', 'Learn from rejections', 'Keep improving'], 4
FROM tip_categories WHERE slug = 'job-search';

-- Networking (Internationalized)
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('networking', 'Networking', 'Build connections that lead to opportunities', 'connect_without_contact', 'veteran', 6);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Start with Fellow Veterans', 
'Veterans help veterans. Start networking within the veteran community where trust is built-in.',
ARRAY['Join veteran organizations', 'Attend veteran events', 'Use veteran LinkedIn groups'], 1
FROM tip_categories WHERE slug = 'networking';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Be Helpful First', 
'Networking is about relationships, not transactions. Help others before asking for help.',
ARRAY['Share information', 'Make introductions', 'Be genuinely interested'], 2
FROM tip_categories WHERE slug = 'networking';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Follow Up', 
'After meeting someone, follow up within 48 hours. Connect on LinkedIn with a personalized note.',
ARRAY['Send thank you notes', 'Reference your conversation', 'Stay in touch'], 3
FROM tip_categories WHERE slug = 'networking';

-- Resume & Interview
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('resume-interview', 'Resume & Interview', 'Translate your service for civilian employers', 'description', 'military', 7);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Translate Military Terms', 
'Replace jargon with civilian equivalents. "Led a 12-person fire team" becomes "Managed a 12-person team in high-pressure environments."',
ARRAY['Avoid acronyms', 'Use civilian job titles', 'Quantify achievements'], 1
FROM tip_categories WHERE slug = 'resume-interview';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Highlight Leadership', 
'Military service builds leadership skills employers value. Emphasize decision-making, team management, and accountability.',
ARRAY['Show responsibility level', 'Include budget/resources managed', 'Mention training you provided'], 2
FROM tip_categories WHERE slug = 'resume-interview';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Interview Preparation', 
'Practice the STAR method: Situation, Task, Action, Result. Have 3-5 stories ready that show your skills.',
ARRAY['STAR method for answers', 'Practice out loud', 'Research the company'], 3
FROM tip_categories WHERE slug = 'resume-interview';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Common Questions', 
'Be ready for: "Why are you leaving the military?" "How do your skills transfer?" "Tell me about a challenge you overcame."',
ARRAY['Stay positive about transition', 'Connect your experience', 'Show eagerness to learn'], 4
FROM tip_categories WHERE slug = 'resume-interview';

-- ============================================================
-- MILITARY TIP CATEGORIES
-- ============================================================

-- Shift & Sleep Support
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('shift-sleep', 'Shift & Sleep Support', 'Manage irregular schedules and get better rest', 'bedtime', 'military', 8);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Before Night Shift', 
'Prepare your body for the switch. Nap before your shift if possible, eat a light meal, and avoid caffeine close to when you need to sleep.',
ARRAY['Nap 90 minutes before shift', 'Light meal, not heavy', 'Caffeine only early in shift'], 1
FROM tip_categories WHERE slug = 'shift-sleep';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'During Night Shift', 
'Stay alert with bright light exposure. Take short walks, stay hydrated, and save caffeine for the first half of your shift.',
ARRAY['Bright lights help alertness', 'Move every hour', 'Hydrate frequently'], 2
FROM tip_categories WHERE slug = 'shift-sleep';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'After Night Shift', 
'Wind down properly. Wear sunglasses on the way home, avoid screens, and create a dark, cool sleeping environment.',
ARRAY['Sunglasses block wake signals', 'Blackout curtains essential', 'Keep room cool: 18-20°C / 65-68°F'], 3
FROM tip_categories WHERE slug = 'shift-sleep';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Rotating Schedules', 
'Give your body time to adjust. Stick to consistent meal times, exercise regularly, and protect your sleep windows.',
ARRAY['Meals anchor your rhythm', 'Exercise but not before sleep', 'Prioritize sleep above all'], 4
FROM tip_categories WHERE slug = 'shift-sleep';

-- Focus Under Pressure
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('focus-pressure', 'Focus Under Pressure', 'Perform when it matters most', 'psychology', 'military', 9);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Box Breathing', 
'Inhale 4 seconds, hold 4 seconds, exhale 4 seconds, hold 4 seconds. Repeat 4 times. This activates your calm response.',
ARRAY['Used by elite military units', 'Lowers heart rate', 'Clears mental fog'], 1
FROM tip_categories WHERE slug = 'focus-pressure';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'The 5-Second Rule', 
'When you hesitate, count 5-4-3-2-1 and move. Don''t give your brain time to talk you out of action.',
ARRAY['Interrupt hesitation', 'Create forward momentum', 'Works for any decision'], 2
FROM tip_categories WHERE slug = 'focus-pressure';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Visualization', 
'Before high-pressure situations, mentally rehearse success. See yourself performing calmly and confidently.',
ARRAY['Picture each step clearly', 'Include the feeling of success', 'Do this daily for key tasks'], 3
FROM tip_categories WHERE slug = 'focus-pressure';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Focus Cue', 
'Choose a physical trigger - touching your thumb to finger, deep breath - to activate focus. Practice linking it to calm, clear thinking.',
ARRAY['Pick a simple gesture', 'Practice in calm moments', 'Use before high-stakes moments'], 4
FROM tip_categories WHERE slug = 'focus-pressure';

-- Tactical Mindset
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('tactical-mindset', 'Tactical Mindset', 'Mental edge for operational readiness', 'shield', 'military', 10);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Situational Awareness', 
'Stay alert without being paranoid. Regularly scan your environment. Know exits, notice changes, trust your instincts.',
ARRAY['Know your exits', 'Notice what''s normal', 'Trust gut feelings'], 1
FROM tip_categories WHERE slug = 'tactical-mindset';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Pre-Mission Mindset', 
'Before any operation, run through your role mentally. Visualize contingencies. Accept uncertainty.',
ARRAY['Mental rehearsal', 'Plan for problems', 'Accept what you can''t control'], 2
FROM tip_categories WHERE slug = 'tactical-mindset';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Recovery After Ops', 
'Debrief mentally. What went well? What would you do differently? Then let it go - dwelling doesn''t help.',
ARRAY['Learn from each experience', 'Don''t ruminate', 'Move forward'], 3
FROM tip_categories WHERE slug = 'tactical-mindset';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Maintaining Edge', 
'Stay sharp through regular training, physical fitness, and mental challenges. Complacency is the enemy.',
ARRAY['Train consistently', 'Challenge yourself', 'Stay humble'], 4
FROM tip_categories WHERE slug = 'tactical-mindset';

-- ============================================================
-- YOUTH TIP CATEGORIES
-- ============================================================

-- Subject Explorer
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('subject-explorer', 'Subject Explorer', 'Discover where each subject can take you', 'explore', 'youth', 11);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Maths', 
'Maths opens doors to engineering, finance, data science, architecture, and game development. It teaches logical thinking that applies everywhere.',
ARRAY['Engineering & Architecture', 'Finance & Banking', 'Data Science & AI', 'Game Development'], 1
FROM tip_categories WHERE slug = 'subject-explorer';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Science', 
'Science leads to medicine, research, environmental work, and technology. It teaches you to question, test, and discover.',
ARRAY['Medicine & Healthcare', 'Environmental Science', 'Research & Lab Work', 'Tech & Innovation'], 2
FROM tip_categories WHERE slug = 'subject-explorer';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'English & Writing', 
'Communication skills are valued everywhere. Writing leads to journalism, marketing, law, and creative careers.',
ARRAY['Journalism & Media', 'Marketing & Advertising', 'Law & Policy', 'Content Creation'], 3
FROM tip_categories WHERE slug = 'subject-explorer';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'History & Social Studies', 
'Understanding the past and society prepares you for law, politics, teaching, and business leadership.',
ARRAY['Law & Politics', 'Teaching & Education', 'Business Strategy', 'Social Work'], 4
FROM tip_categories WHERE slug = 'subject-explorer';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Arts & Design', 
'Creativity is increasingly valuable. Art leads to design, entertainment, marketing, and entrepreneurship.',
ARRAY['Graphic & UX Design', 'Film & Animation', 'Fashion & Interior Design', 'Advertising'], 5
FROM tip_categories WHERE slug = 'subject-explorer';

-- Friendship Skills
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('friendship', 'Friendship Skills', 'Build stronger connections', 'people', 'youth', 12);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Being a Good Listener', 
'Really listen when friends talk. Put your phone away, make eye contact, and ask follow-up questions.',
ARRAY['Don''t just wait to talk', 'Show you heard them', 'Remember details'], 1
FROM tip_categories WHERE slug = 'friendship';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Setting Boundaries', 
'It''s okay to say no. Good friends respect your limits and don''t pressure you.',
ARRAY['No is a complete sentence', 'You don''t owe explanations', 'True friends understand'], 2
FROM tip_categories WHERE slug = 'friendship';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Handling Conflict', 
'Disagreements happen. Address issues calmly, use "I feel" statements, and be willing to apologize.',
ARRAY['Cool down before talking', 'Focus on the issue, not the person', 'Apologize when wrong'], 3
FROM tip_categories WHERE slug = 'friendship';

-- Money Basics
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('money-basics', 'Money Basics', 'Build smart money habits early', 'attach_money', 'youth', 13);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'The 50/30/20 Rule', 
'A simple way to split your money: 50% needs, 30% wants, 20% savings.',
ARRAY['Needs: food, transport, essentials', 'Wants: entertainment, extras', 'Savings: future you will thank you'], 1
FROM tip_categories WHERE slug = 'money-basics';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Start Saving Now', 
'Even small amounts add up. Save something from every bit of money you get.',
ARRAY['Open a savings account', 'Set up automatic transfers', 'Watch it grow over time'], 2
FROM tip_categories WHERE slug = 'money-basics';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Avoid Impulse Buys', 
'Wait 24-48 hours before buying something you want. If you still want it, go for it.',
ARRAY['Sleep on big purchases', 'Ask: do I need this?', 'Compare prices first'], 3
FROM tip_categories WHERE slug = 'money-basics';

-- Time Management
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('time-management', 'Time Management', 'Get more done, stress less', 'schedule', 'youth', 14);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Prioritize First', 
'Not everything is equally important. Do the most important or urgent things first.',
ARRAY['Make a quick list', 'Number by importance', 'Start with #1'], 1
FROM tip_categories WHERE slug = 'time-management';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Use Time Blocks', 
'Schedule specific times for homework, breaks, and fun. Your brain works better with structure.',
ARRAY['25-50 min work blocks', '5-10 min breaks', 'Longer break after 2-3 blocks'], 2
FROM tip_categories WHERE slug = 'time-management';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Eliminate Distractions', 
'Phone notifications kill focus. Put your phone in another room when you need to concentrate.',
ARRAY['Turn off notifications', 'Use apps to block distractions', 'Tell others you''re focusing'], 3
FROM tip_categories WHERE slug = 'time-management';

-- Digital Life
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('digital-life', 'Digital Life', 'Stay safe and healthy online', 'phone_android', 'youth', 15);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Protect Your Privacy', 
'Think before you share. Once it''s online, it''s hard to take back.',
ARRAY['Don''t share location publicly', 'Use strong passwords', 'Be careful with personal info'], 1
FROM tip_categories WHERE slug = 'digital-life';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Social Media Balance', 
'Social media is designed to keep you scrolling. Set limits and take breaks.',
ARRAY['Set daily time limits', 'Unfollow accounts that make you feel bad', 'Real life > online life'], 2
FROM tip_categories WHERE slug = 'digital-life';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Dealing with Cyberbullying', 
'If someone is harassing you online, don''t engage. Screenshot, block, and tell an adult.',
ARRAY['Don''t respond to trolls', 'Save evidence', 'Report and block'], 3
FROM tip_categories WHERE slug = 'digital-life';

-- College vs Trades
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('college-vs-trades', 'College vs Trades', 'Both paths can lead to great careers', 'compare_arrows', 'youth', 16);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'University Path', 
'University gives you broad education, time to explore, and is required for some careers like medicine or law.',
ARRAY['3-4+ years of study', 'Broader career options', 'More student debt typically', 'Required for some professions'], 1
FROM tip_categories WHERE slug = 'college-vs-trades';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Trade School Path', 
'Trade schools teach specific skills quickly. You can start earning sooner in high-demand fields.',
ARRAY['6 months to 2 years typically', 'Hands-on learning', 'Less debt, faster income', 'High demand: plumbing, electrical, HVAC'], 2
FROM tip_categories WHERE slug = 'college-vs-trades';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Apprenticeships', 
'Get paid while you learn. Apprenticeships combine work experience with education.',
ARRAY['Earn while you learn', 'Real-world experience', 'Available in many industries', 'Often leads to full-time jobs'], 3
FROM tip_categories WHERE slug = 'college-vs-trades';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'The Real Truth', 
'Neither path is "better." It depends on your interests, learning style, and goals. Many successful people take both paths at different times.',
ARRAY['You can change paths later', 'Success comes in many forms', 'What matters is finding your fit'], 4
FROM tip_categories WHERE slug = 'college-vs-trades';

-- Ask for Help
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('ask-for-help', 'Ask for Help', 'Scripts and tips for getting support', 'support_agent', 'youth', 17);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Talking to Teachers', 
'Teachers want to help. Approach them after class or during office hours. Be specific about what you need.',
ARRAY['Say: "I''m struggling with X. Can you help?"', 'Ask for extra practice or resources', 'Email if talking in person feels hard'], 1
FROM tip_categories WHERE slug = 'ask-for-help';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Talking to Parents', 
'Pick a calm moment, not during an argument. Start with how you feel, not what you want them to do.',
ARRAY['Say: "I want to talk about something"', 'Use "I feel" statements', 'Be patient - they might need time'], 2
FROM tip_categories WHERE slug = 'ask-for-help';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'School Counselors', 
'Counselors are trained to help with academic, social, and emotional issues. Everything is confidential.',
ARRAY['You can ask to see them anytime', 'They can help with stress, friends, family', 'They won''t judge you'], 3
FROM tip_categories WHERE slug = 'ask-for-help';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'When It Feels Too Hard', 
'If you''re really struggling, it''s okay to say so. You don''t have to figure everything out alone.',
ARRAY['Write it down if speaking is hard', 'Ask a friend to come with you', 'One conversation can change things'], 4
FROM tip_categories WHERE slug = 'ask-for-help';

-- Family Dynamics
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('family-dynamics', 'Family Dynamics', 'Navigate family relationships', 'family_restroom', 'youth', 18);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Managing Expectations', 
'Parents want the best for you, but sometimes their vision differs from yours. Communicate openly about your goals.',
ARRAY['Share your perspective calmly', 'Listen to their concerns', 'Find middle ground'], 1
FROM tip_categories WHERE slug = 'family-dynamics';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'During Arguments', 
'Stay calm, don''t escalate. If things get heated, it''s okay to take a break and come back later.',
ARRAY['Take deep breaths', 'Say "I need a minute"', 'Revisit when calm'], 2
FROM tip_categories WHERE slug = 'family-dynamics';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Building Trust', 
'Trust is built over time through consistent actions. Follow through on commitments and be honest.',
ARRAY['Keep your promises', 'Communicate proactively', 'Admit mistakes'], 3
FROM tip_categories WHERE slug = 'family-dynamics';

-- Real Student Stories
INSERT INTO tip_categories (slug, title, subtitle, icon, target_audience, sort_order) VALUES
('student-stories', 'Real Stories', 'You''re not alone in your journey', 'auto_stories', 'youth', 19);

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'From Failing to Top of Class', 
'Marcus was failing maths in year 9. He asked for help, found a study group, and by year 11 was tutoring others.',
ARRAY['Asked for help', 'Found study partners', 'Turned weakness into strength'], 1
FROM tip_categories WHERE slug = 'student-stories';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Finding My Voice', 
'Sofia was terrified of public speaking. She joined drama club on a dare and discovered she loved performing.',
ARRAY['Tried something scary', 'Found hidden talent', 'Now leads school events'], 2
FROM tip_categories WHERE slug = 'student-stories';

INSERT INTO tips (category_id, title, content, key_points, sort_order) 
SELECT id, 'Different Path, Same Success', 
'Jamal skipped university for trade school. Now he runs his own electrical business and earns more than many of his university friends.',
ARRAY['Chose his own path', 'Learned practical skills', 'Built his own business'], 3
FROM tip_categories WHERE slug = 'student-stories';
