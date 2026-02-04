-- ============================================
-- RITUAL ITEMS FOR REMAINING TOPICS
-- Run this to populate all empty topics
-- ============================================

-- ============================================
-- HEALTHY EATING MINDSET
-- (Focus on mindful eating, not diet - works anywhere)
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'healthy-eating';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Mindful first bite', 'Start each meal with full attention on the first bite', 'The first bite sets the tone. When you slow down initially, you''re more likely to eat mindfully throughout.', 'Before eating, pause. Look at your food. Take the first bite slowly. Notice texture, temperature, flavor. Chew completely before the second bite.', 2, 'anytime', 'daily', 1, true),
    (topic_id, 'Hunger check-in', 'Rate your hunger before eating', 'We often eat from habit, boredom, or emotion—not hunger. Checking in builds awareness.', 'Before eating, ask: On a scale of 1-10, how hungry am I? 1=stuffed, 5=neutral, 10=starving. Aim to eat at 6-7, stop at 3-4.', 1, 'anytime', 'daily', 2, true),
    (topic_id, 'Gratitude before meals', 'Take a moment of appreciation before eating', 'Gratitude shifts your mindset from consumption to appreciation, naturally slowing you down.', 'Before eating, pause for 3 breaths. Think about where this food came from—the people who grew, prepared, served it. A simple "thank you" counts.', 1, 'anytime', 'daily', 3, true),
    (topic_id, 'Put down the fork', 'Set down utensils between bites', 'This simple habit forces you to slow down and prevents autopilot eating.', 'After each bite, put your fork/spoon down. Chew completely. Swallow. Then pick it up for the next bite. Notice how this changes your pace.', 15, 'anytime', 'daily', 4, true),
    (topic_id, 'Halfway pause', 'Stop eating halfway through to check in', 'It takes 20 minutes for fullness signals to reach your brain. Pausing helps you notice them.', 'When your plate is half empty, stop for 2 minutes. Drink water. Ask yourself: Am I still hungry, or eating from momentum?', 2, 'anytime', 'daily', 5, true),
    (topic_id, 'No-screen meal', 'Eat one meal without any screens', 'Distracted eating leads to overconsumption and missed satisfaction signals.', 'Choose one meal to eat without phone, TV, or computer. Just you and the food. Notice how different it feels.', 20, 'anytime', 'daily', 6, true),
    (topic_id, 'Hydration before meals', 'Drink water 15-30 minutes before eating', 'Thirst is often mistaken for hunger. Hydrating helps you eat appropriate amounts.', 'Have a full glass of water 15-30 mins before meals. This also aids digestion and helps you recognize true hunger.', 1, 'anytime', 'daily', 7, false),
    (topic_id, 'Evening food reflection', 'Review how your eating felt today', 'Reflection without judgment builds awareness and helps identify patterns.', 'Before bed, briefly note: What did I eat today? How did it make me feel? No criticism—just noticing.', 3, 'evening', 'daily', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'I nourish my body with attention and care.', 1),
    (topic_id, 'I eat to feel good, not just to feel full.', 2),
    (topic_id, 'My body knows what it needs.', 3),
    (topic_id, 'I am learning to listen to my hunger.', 4),
    (topic_id, 'Every meal is an opportunity for mindfulness.', 5),
    (topic_id, 'I release guilt and embrace balance.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Awareness Growing', 'One week of mindful eating practice', 7, 'You''re building food awareness! Notice any changes in how you experience meals.', 1),
    (topic_id, 'Habits Forming', 'Two weeks of practice', 14, 'Mindful eating is becoming natural. Your relationship with food is evolving.', 2),
    (topic_id, 'Mindful Eater', 'Three weeks of consistent practice', 21, 'You''ve transformed eating from autopilot to intentional. This is lasting change.', 3);
  END IF;
END $$;

-- ============================================
-- GIVING BACK (works in confined environments)
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'giving-back';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Daily kindness intention', 'Set an intention to help someone today', 'Intention creates awareness. When you''re looking for opportunities to help, you find them.', 'Each morning, say: "Today I will look for one way to help someone." Keep your eyes open for opportunities.', 1, 'morning', 'daily', 1, true),
    (topic_id, 'Genuine compliment', 'Give one sincere compliment today', 'Genuine praise costs nothing but can transform someone''s day. It also shifts your focus outward.', 'Notice something genuinely good about someone—their work, attitude, helpfulness. Tell them specifically. Be sincere.', 2, 'anytime', 'daily', 2, true),
    (topic_id, 'Active listening gift', 'Give someone your complete attention', 'In a distracted world, undivided attention is rare and valuable. It''s a gift anyone can give.', 'When someone talks to you, put everything down. Make eye contact. Don''t plan your response—just listen. Ask a follow-up question.', 10, 'anytime', 'daily', 3, true),
    (topic_id, 'Share your knowledge', 'Teach someone something you know', 'Your skills and knowledge have value. Sharing multiplies impact without diminishing yours.', 'Think of something you know well. Offer to explain it to someone who could benefit. Be patient and encouraging.', 15, 'anytime', 'weekly', 4, true),
    (topic_id, 'Anticipate a need', 'Do something helpful before being asked', 'Proactive help shows you notice and care. It removes burden from others.', 'Look around your environment. What task is someone dreading? What do people always forget? Do it without being asked.', 10, 'anytime', 'daily', 5, true),
    (topic_id, 'Check in on someone', 'Reach out to someone who might be struggling', 'A simple "how are you—really?" can be lifeline. Many people are quietly struggling.', 'Think of someone who seemed off lately, or someone you haven''t heard from. Reach out. Ask how they''re really doing. Listen.', 10, 'anytime', 'daily', 6, true),
    (topic_id, 'Gratitude expression', 'Thank someone who helped you', 'Recognition motivates. Many helpers feel invisible. Being seen means everything.', 'Think of someone who helped you recently—even in small ways. Thank them specifically. Tell them the impact.', 5, 'anytime', 'daily', 7, false),
    (topic_id, 'Evening kindness review', 'Reflect on how you helped today', 'Reflection reinforces behavior. Noticing your impact encourages more giving.', 'Before bed, recall: How did I help someone today? How did it feel? What opportunity might I have missed?', 3, 'evening', 'daily', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'Small acts of kindness create ripples of change.', 1),
    (topic_id, 'I have something valuable to give.', 2),
    (topic_id, 'Helping others helps me too.', 3),
    (topic_id, 'I notice opportunities to make a difference.', 4),
    (topic_id, 'My presence can be a gift.', 5),
    (topic_id, 'Generosity expands my world.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Giver Awakened', 'One week of intentional giving', 7, 'You''re seeing the world through generous eyes. Notice how it feels to give.', 1),
    (topic_id, 'Ripples Spreading', 'Two weeks of daily kindness', 14, 'Your kindness is creating ripples. Others may be paying it forward without you knowing.', 2),
    (topic_id, 'Generous Heart', 'Three weeks of giving back', 21, 'Generosity is now part of who you are. You''ve proven that giving enriches the giver.', 3);
  END IF;
END $$;

-- ============================================
-- LEADERSHIP GROWTH
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'leadership-growth';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Morning leadership intention', 'Set a leadership focus for the day', 'Intention shapes behavior. Consciously choosing how to lead makes you more deliberate.', 'Ask yourself: How will I show leadership today? Choose one quality to embody: patience, decisiveness, encouragement, etc.', 2, 'morning', 'daily', 1, true),
    (topic_id, 'Lead yourself first', 'Complete your most important task before helping others', 'Self-leadership is the foundation. You can''t pour from an empty cup or lead from chaos.', 'Identify your #1 priority. Do it before getting pulled into others'' needs. This demonstrates discipline.', 30, 'morning', 'daily', 2, true),
    (topic_id, 'Seek feedback', 'Ask for honest input on your leadership', 'Blind spots limit growth. The best leaders actively seek the truth about their impact.', 'Ask someone: "What''s one thing I could do better as a leader/teammate?" Listen without defending. Thank them.', 10, 'anytime', 'weekly', 3, true),
    (topic_id, 'Praise in public', 'Recognize someone''s contribution publicly', 'Public recognition motivates and shows others what you value. It costs nothing but builds loyalty.', 'When someone does good work, acknowledge it where others can hear. Be specific about what they did and why it mattered.', 2, 'anytime', 'daily', 4, true),
    (topic_id, 'Admit a mistake', 'Own an error without excuse', 'Vulnerability builds trust. Leaders who admit mistakes create psychologically safe environments.', 'When you make a mistake, say: "I was wrong about X. Here''s what I''ll do differently." No blame, no excuses.', 5, 'anytime', 'as_needed', 5, true),
    (topic_id, 'Decision-making practice', 'Make one decision you''ve been avoiding', 'Leadership requires decisiveness. Indecision often causes more harm than imperfect decisions.', 'Identify a decision you''ve been postponing. Gather enough information (not perfect information). Decide. Communicate clearly.', 15, 'anytime', 'daily', 6, true),
    (topic_id, 'Listen more than you speak', 'In one conversation, listen 80% of the time', 'Great leaders listen. It builds trust, surfaces better ideas, and makes others feel valued.', 'In your next meeting or conversation, consciously listen more. Ask questions. Resist the urge to jump in with solutions.', 15, 'anytime', 'daily', 7, false),
    (topic_id, 'Evening leadership reflection', 'Review your leadership impact today', 'Reflection accelerates growth. Noticing patterns helps you improve faster.', 'Before bed: How did I lead today? What worked? What would I do differently? How did I make others feel?', 5, 'evening', 'daily', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'I lead by example, not by title.', 1),
    (topic_id, 'My growth inspires others to grow.', 2),
    (topic_id, 'I am becoming the leader I needed.', 3),
    (topic_id, 'Vulnerability is strength.', 4),
    (topic_id, 'I lift others as I climb.', 5),
    (topic_id, 'Every challenge is leadership practice.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Leading Self', 'One week of intentional leadership', 7, 'You''re building self-leadership—the foundation of all leadership.', 1),
    (topic_id, 'Influence Growing', 'Two weeks of leadership practice', 14, 'Others are starting to notice your growth. Your influence is expanding.', 2),
    (topic_id, 'Leader Emerging', 'One month of consistent practice', 30, 'You''ve developed leadership habits that will serve you for life.', 3);
  END IF;
END $$;

-- ============================================
-- BREAKING BAD HABITS
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'breaking-bad-habits';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Trigger awareness log', 'Notice what triggers your unwanted habit', 'You can''t break a habit without understanding it. Triggers are the starting point.', 'When you catch yourself doing the habit (or about to), note: What happened right before? Where was I? How was I feeling? What time was it?', 2, 'anytime', 'daily', 1, true),
    (topic_id, 'Pause before acting', 'Create a gap between urge and action', 'Habits are automatic. A pause breaks automaticity and gives you choice.', 'When you feel the urge, STOP. Take 3 deep breaths. Count to 10. Ask: Do I really want to do this? Often the urge will pass.', 1, 'anytime', 'as_needed', 2, true),
    (topic_id, 'Replacement behavior', 'Do something else when triggered', 'Habits fill a need. You can''t just remove them—you must replace them with something better.', 'Identify what need your habit fills (boredom, stress, comfort). Choose a healthier behavior that fills the same need. Practice it when triggered.', 5, 'anytime', 'as_needed', 3, true),
    (topic_id, 'Environment design', 'Make the bad habit harder to do', 'Willpower is limited. Design your environment so the bad habit requires effort.', 'Add friction: Hide the thing, remove it from your space, make it inconvenient. The harder it is, the less you''ll do it.', 10, 'morning', 'weekly', 4, true),
    (topic_id, 'Streak tracking', 'Count your habit-free days', 'Tracking creates accountability and makes progress visible. Streaks become motivating.', 'Mark each day you resist the habit. "Don''t break the chain." If you slip, start again immediately without harsh self-judgment.', 1, 'evening', 'daily', 5, true),
    (topic_id, 'Urge surfing', 'Ride the urge wave without acting', 'Urges peak and fade. If you can surf through the peak without acting, the urge weakens.', 'When an urge hits, observe it like a wave. Notice where you feel it in your body. Watch it rise, peak, and fall—without acting.', 5, 'anytime', 'as_needed', 6, true),
    (topic_id, 'Identify the real need', 'Ask what you actually need right now', 'Bad habits often mask deeper needs. Addressing the real need removes the habit''s purpose.', 'Before acting on the habit, ask: What do I really need? Am I tired, lonely, stressed, bored? Address that need directly.', 3, 'anytime', 'as_needed', 7, false),
    (topic_id, 'Evening habit review', 'Reflect on today''s habit battles', 'Reflection builds awareness and helps you prepare for tomorrow''s challenges.', 'Before bed: Did I resist today? What triggered me? What helped? What will I do differently tomorrow?', 5, 'evening', 'daily', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'I am stronger than my urges.', 1),
    (topic_id, 'Every moment is a chance to choose differently.', 2),
    (topic_id, 'I am rewiring my brain with each resistance.', 3),
    (topic_id, 'Slips are data, not failure.', 4),
    (topic_id, 'I am replacing old patterns with new ones.', 5),
    (topic_id, 'Freedom is on the other side of this discomfort.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Awareness Building', 'One week of habit tracking', 7, 'You understand your habit better now. Awareness is the first step to change.', 1),
    (topic_id, 'Pattern Breaking', 'Two weeks of resistance', 14, 'The automatic pull is weakening. Your brain is rewiring.', 2),
    (topic_id, 'New Normal', 'Four weeks habit-free or significantly reduced', 28, 'You''ve proven you can change. This habit no longer controls you.', 3);
  END IF;
END $$;

-- ============================================
-- ENERGY BOOST
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'energy-boost';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Morning movement burst', 'Get your body moving within 10 minutes of waking', 'Movement increases blood flow and cortisol (the wake-up hormone). It signals to your body that it''s time to be alert.', '10 jumping jacks, 10 squats, 10 arm circles. Or just dance to one song. Anything that gets your heart rate up slightly.', 3, 'morning', 'daily', 1, true),
    (topic_id, 'Cold water face splash', 'Shock your system awake with cold water', 'Cold triggers your sympathetic nervous system, releasing adrenaline and increasing alertness instantly.', 'Splash cold water on your face 3-5 times. For more impact, let cold water run over your wrists for 30 seconds.', 1, 'morning', 'daily', 2, true),
    (topic_id, 'Hydration first thing', 'Drink a full glass of water before anything else', 'You''re dehydrated after 8 hours of sleep. Dehydration causes fatigue. Water jumpstarts your metabolism.', 'Keep water by your bed. Drink a full glass before checking your phone or having coffee. Add lemon for extra boost.', 2, 'morning', 'daily', 3, true),
    (topic_id, 'Afternoon reset walk', 'Take a 5-minute walk when energy dips', 'The post-lunch slump is real. Brief movement increases blood flow and oxygen to your brain.', 'When you feel the afternoon drag, walk for 5 minutes. Up stairs if possible. Fresh air is a bonus. Return more alert.', 5, 'afternoon', 'daily', 4, true),
    (topic_id, 'Strategic caffeine timing', 'Wait 90 minutes after waking for caffeine', 'Cortisol naturally peaks after waking. Caffeine during this time is less effective and disrupts your rhythm.', 'Delay your first coffee until 90 mins after waking. When you do have it, drink it within a 2-hour window—no sipping all day.', 1, 'morning', 'daily', 5, true),
    (topic_id, 'Power pose break', 'Do 2 minutes of expansive posture', 'Open postures increase testosterone and decrease cortisol, boosting energy and confidence.', 'Stand tall, hands on hips like a superhero, or stretch arms wide. Hold for 2 minutes. Breathe deeply. Feel the difference.', 2, 'anytime', 'daily', 6, true),
    (topic_id, 'Eye rest for energy', 'Give your eyes a break from screens', 'Eye strain causes fatigue. The 20-20-20 rule prevents it: every 20 mins, look 20 feet away for 20 seconds.', 'Set a timer. Every 20 minutes, look at something far away for 20 seconds. Blink intentionally. Close eyes for 10 seconds.', 1, 'anytime', 'daily', 7, false),
    (topic_id, 'Evening energy prep', 'Prepare tomorrow for an energized start', 'Morning decisions drain energy. Preparation the night before gives you momentum.', 'Before bed: Lay out clothes. Prepare breakfast items. Write tomorrow''s top 3 priorities. Set up for an effortless morning.', 10, 'evening', 'daily', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'I have abundant energy for what matters.', 1),
    (topic_id, 'My energy is renewable.', 2),
    (topic_id, 'I choose habits that fuel me.', 3),
    (topic_id, 'I listen to my body''s energy signals.', 4),
    (topic_id, 'Vitality flows through me.', 5),
    (topic_id, 'I am awake, alert, and alive.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Energy Awareness', 'One week of energy rituals', 7, 'You''re learning your energy patterns. Notice what makes the biggest difference.', 1),
    (topic_id, 'Vitality Rising', 'Two weeks of consistent practice', 14, 'Your baseline energy is rising. These habits are becoming automatic.', 2);
  END IF;
END $$;

-- ============================================
-- POST-BREAKUP RECOVERY
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'post-breakup';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Morning identity affirmation', 'Remind yourself who you are beyond the relationship', 'Breakups can make you feel lost. Reconnecting with your individual identity aids recovery.', 'Each morning, say: "I am [your name]. I am whole on my own. My worth is not determined by any relationship." Mean it.', 2, 'morning', 'daily', 1, true),
    (topic_id, 'No-contact commitment', 'Recommit to no contact with your ex', 'Contact prolongs pain and delays healing. Each day of no-contact is progress.', 'Each morning, recommit: "Today I will not contact them. Not to check in, not to get closure, not for any reason." One day at a time.', 1, 'morning', 'daily', 2, true),
    (topic_id, 'Feeling without fixing', 'Allow emotions without trying to change them', 'Suppressed emotions resurface. Allowing them to flow through helps them pass.', 'Set a timer for 10 minutes. Feel whatever comes up—sadness, anger, relief. Don''t judge it. Let it be. When the timer ends, move on.', 10, 'anytime', 'daily', 3, true),
    (topic_id, 'Reclaim something', 'Do one thing you stopped doing in the relationship', 'Relationships involve compromise. Rediscovering lost parts of yourself rebuilds identity.', 'Think of something you gave up—a hobby, music taste, friend, habit. Do that thing today. Notice how it feels to reclaim it.', 30, 'anytime', 'daily', 4, true),
    (topic_id, 'Gratitude for the lesson', 'Find one thing you learned from this', 'Every relationship teaches us something. Finding the lesson transforms pain into growth.', 'Ask: What did I learn about myself? About what I need? About red flags? Write one lesson. The pain had purpose.', 5, 'anytime', 'daily', 5, true),
    (topic_id, 'Physical release', 'Move your body to process emotions', 'Emotions are stored in the body. Physical movement helps release them.', 'Exercise, dance, shake, punch a pillow—any physical release. Let your body express what words can''t.', 15, 'anytime', 'daily', 6, true),
    (topic_id, 'Social connection', 'Reach out to someone who cares', 'Isolation worsens heartbreak. Connection reminds you that you are loved and not alone.', 'Text or call one person who cares about you. You don''t have to talk about the breakup. Just connect.', 10, 'anytime', 'daily', 7, false),
    (topic_id, 'Evening self-compassion', 'Speak to yourself like a friend', 'You''d never talk to a friend the way you talk to yourself. Self-compassion speeds healing.', 'Before bed, say: "This is hard. It''s okay that I''m hurting. I''m handling this the best I can. Tomorrow is a new day."', 3, 'evening', 'daily', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'I am whole on my own.', 1),
    (topic_id, 'This pain is temporary. My growth is permanent.', 2),
    (topic_id, 'I am becoming stronger through this.', 3),
    (topic_id, 'I deserve love that stays.', 4),
    (topic_id, 'I release what was never meant for me.', 5),
    (topic_id, 'Better things are coming.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Surviving', 'One week of recovery', 7, 'You''ve survived a full week. That took strength. Keep going.', 1),
    (topic_id, 'Healing', 'Two weeks of daily practice', 14, 'The acute pain is lessening. You''re healing, even when it doesn''t feel like it.', 2),
    (topic_id, 'Rising', 'Four weeks of recovery', 28, 'You''re emerging from this stronger. The person you''re becoming is worth this journey.', 3);
  END IF;
END $$;

-- ============================================
-- MAJOR LIFE CHANGE
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'major-change';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Anchor in constants', 'Identify what remains stable', 'In times of change, anchoring in what''s constant provides stability and security.', 'List 3 things that haven''t changed: core values, relationships, skills. These are your anchors. Return to them when overwhelmed.', 5, 'morning', 'daily', 1, true),
    (topic_id, 'One controllable action', 'Do one thing within your control', 'Change often feels out of control. Taking action on what you CAN control builds agency.', 'Ask: What''s one small thing I can control today? Do that thing. It could be as simple as making your bed or taking a walk.', 10, 'morning', 'daily', 2, true),
    (topic_id, 'Validate the difficulty', 'Acknowledge that this is hard', 'Pretending change is easy adds suffering. Acknowledging difficulty is self-compassion.', 'Say out loud: "This is hard. It''s okay that I''m struggling. Change is always uncomfortable." Give yourself permission to not be okay.', 2, 'anytime', 'daily', 3, true),
    (topic_id, 'Find one opportunity', 'Identify one positive possibility', 'Every change contains opportunity. Looking for it shifts your mindset from victim to active participant.', 'Ask: What becomes possible because of this change? What door might be opening? Write one potential positive outcome.', 5, 'anytime', 'daily', 4, true),
    (topic_id, 'Small routine maintenance', 'Keep one small routine consistent', 'Routines provide structure when everything else is shifting. Even small ones help.', 'Choose one small routine to protect: morning coffee ritual, evening walk, bedtime reading. Keep it no matter what.', 15, 'anytime', 'daily', 5, true),
    (topic_id, 'Progress not perfection', 'Celebrate one thing you navigated', 'Change requires constant navigation. Celebrating small wins builds confidence.', 'End each day by noting: What did I navigate today? What did I figure out? Celebrate the learning, not just the outcome.', 3, 'evening', 'daily', 6, true),
    (topic_id, 'Connect with supporters', 'Reach out to your support network', 'You don''t have to navigate change alone. Others have wisdom and can share the load.', 'Text or call someone in your support network. Share what you''re going through. Ask for advice or just vent.', 15, 'anytime', 'daily', 7, false),
    (topic_id, 'Future self visualization', 'Imagine yourself having adapted', 'Visualization creates a roadmap. Seeing your future adapted self makes it feel achievable.', 'Close your eyes. Imagine yourself 6 months from now, having adapted to this change. What does that look like? Feel it.', 5, 'evening', 'daily', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'I have navigated change before. I will again.', 1),
    (topic_id, 'Discomfort is not danger.', 2),
    (topic_id, 'I am adaptable and resilient.', 3),
    (topic_id, 'This chapter is not the whole story.', 4),
    (topic_id, 'I trust my ability to figure this out.', 5),
    (topic_id, 'Change is making me stronger.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Grounding', 'One week of navigating change', 7, 'You''re finding your footing. The initial shock is passing.', 1),
    (topic_id, 'Adapting', 'Two weeks of daily practice', 14, 'You''re adapting. What felt impossible is becoming manageable.', 2),
    (topic_id, 'Thriving', 'Three weeks into the transition', 21, 'You''re not just surviving—you''re growing through this change.', 3);
  END IF;
END $$;

-- ============================================
-- LETTING GO
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'letting-go';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Morning release intention', 'Set an intention to release one thing today', 'Conscious intention creates awareness. Naming what you''re releasing gives it less power.', 'Each morning, identify one thing to release: a grudge, worry, expectation, regret. Say: "Today I practice releasing [X]."', 2, 'morning', 'daily', 1, true),
    (topic_id, 'Physical unclenching', 'Release physical tension that mirrors mental holding', 'We hold emotions in our bodies. Releasing physical tension helps release mental grip.', 'Notice where you''re tense: jaw, shoulders, hands. Consciously clench tighter, then release completely. Feel the letting go.', 3, 'anytime', 'daily', 2, true),
    (topic_id, 'Exhale the attachment', 'Use breath to symbolically release', 'Breath is both physical and symbolic. Long exhales activate the relaxation response.', 'Breathe in. On a long exhale, visualize releasing what you''re holding onto. Watch it dissolve as you breathe out. Repeat 5 times.', 3, 'anytime', 'daily', 3, true),
    (topic_id, 'Accept what is', 'Practice radical acceptance of reality', 'Suffering = pain × resistance. Accepting reality as it is reduces suffering.', 'Identify something you''re fighting against. Say: "This is how it is right now. I accept this moment as it is." Acceptance is not approval.', 5, 'anytime', 'daily', 4, true),
    (topic_id, 'Forgiveness practice', 'Forgive one small thing', 'Forgiveness is releasing the hope that the past could be different. It frees you.', 'Think of a small grievance. Say: "I release this. Holding onto it hurts me more than them. I choose to let go." Start small.', 5, 'anytime', 'daily', 5, true),
    (topic_id, 'Control inventory', 'Identify what''s not yours to control', 'We exhaust ourselves trying to control the uncontrollable. Letting go of that reclaims energy.', 'Write: What am I trying to control that isn''t mine to control? Others'' opinions? The past? Outcomes? Release your grip on those.', 5, 'anytime', 'daily', 6, true),
    (topic_id, 'Gratitude for what was', 'Thank what you''re releasing for its lessons', 'Gratitude transforms letting go from loss to completion. Everything served a purpose.', 'Before releasing something, thank it: "Thank you for what you taught me. You served your purpose. I release you with gratitude."', 3, 'anytime', 'daily', 7, false),
    (topic_id, 'Evening release ritual', 'Let go of today before sleep', 'Carrying the day into sleep disrupts rest. A release ritual clears the slate.', 'Before bed, mentally scan the day. For anything still clinging, say: "I release today. Tomorrow is fresh." Let your shoulders drop.', 5, 'evening', 'daily', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'I release what no longer serves me.', 1),
    (topic_id, 'Letting go creates space for better.', 2),
    (topic_id, 'I am not my past.', 3),
    (topic_id, 'I release control over what was never mine.', 4),
    (topic_id, 'Holding on hurts more than letting go.', 5),
    (topic_id, 'I am free when I release.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Loosening Grip', 'One week of release practice', 7, 'You''re learning to loosen your grip. Notice what''s becoming lighter.', 1),
    (topic_id, 'Releasing', 'Two weeks of letting go', 14, 'The practice is working. Some things you were holding feel less heavy.', 2),
    (topic_id, 'Free', 'Four weeks of release', 28, 'You''ve experienced the freedom of letting go. This skill is yours for life.', 3);
  END IF;
END $$;

-- ============================================
-- DEEPENING INTIMACY
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'deepening-intimacy';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Morning appreciation', 'Start the day with gratitude for your partner', 'Appreciation builds connection. Voicing it out loud makes your partner feel valued.', 'Each morning, tell your partner one specific thing you appreciate about them. Be specific: "I love how you..." not just "I love you."', 2, 'morning', 'daily', 1, true),
    (topic_id, 'Device-free connection time', 'Spend 15 minutes fully present together', 'Quality time requires presence. Devices fragment attention and signal "something else is more important."', 'Set aside 15 minutes with no phones, TV, or distractions. Just be together—talk, sit, hold hands. Full attention.', 15, 'evening', 'daily', 2, true),
    (topic_id, 'Ask a deeper question', 'Go beyond "how was your day"', 'Surface conversations maintain distance. Deeper questions create emotional intimacy.', 'Ask questions like: "What''s weighing on you?" "What are you excited about?" "How can I support you better?"', 10, 'evening', 'daily', 3, true),
    (topic_id, 'Physical touch without agenda', 'Offer affection with no expectation', 'Non-sexual touch builds trust and connection. It says "I want to be close to you, period."', 'Hold hands, hug, cuddle, give a massage—with zero expectation of it leading anywhere. Just connect physically.', 10, 'anytime', 'daily', 4, true),
    (topic_id, 'Share a vulnerability', 'Tell your partner something you''re struggling with', 'Vulnerability deepens trust. Sharing struggles invites your partner into your inner world.', 'Share something you''re worried about, afraid of, or struggling with. Not to vent—to let them know you. Let them support you.', 10, 'anytime', 'weekly', 5, true),
    (topic_id, 'Remember the beginning', 'Recall what drew you together', 'Long relationships can lose spark. Remembering the beginning reconnects you to why you chose each other.', 'Share a memory from early in your relationship—what attracted you, a special moment, why you fell in love. Relive it together.', 10, 'anytime', 'weekly', 6, true),
    (topic_id, 'Create a ritual together', 'Establish something that''s "ours"', 'Shared rituals build identity as a couple. They become anchors that connect you.', 'Create a small ritual: Sunday morning walks, Friday movie night, a special way you say goodbye. Make it consistent and yours.', 30, 'anytime', 'weekly', 7, false),
    (topic_id, 'Bedtime gratitude exchange', 'End each day with mutual appreciation', 'Ending the day positively creates a pattern of connection and sends you to sleep feeling loved.', 'Before sleep, each share one thing you''re grateful for about the other today. Be specific. Make eye contact. Mean it.', 5, 'evening', 'daily', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'We grow closer every day.', 1),
    (topic_id, 'I choose my partner again today.', 2),
    (topic_id, 'Vulnerability is how we deepen.', 3),
    (topic_id, 'Our connection is worth protecting.', 4),
    (topic_id, 'I am safe to be fully seen.', 5),
    (topic_id, 'Love is a practice, not just a feeling.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Reconnecting', 'One week of intentional connection', 7, 'You''re prioritizing your relationship. Notice any shifts in closeness.', 1),
    (topic_id, 'Deepening', 'Two weeks of intimacy rituals', 14, 'You''re creating new patterns of connection. Your bond is strengthening.', 2),
    (topic_id, 'Intimate', 'One month of consistent practice', 30, 'You''ve deepened your relationship intentionally. This investment pays dividends forever.', 3);
  END IF;
END $$;

-- ============================================
-- NEW CITY FRESH START
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'new-city';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Morning explorer mindset', 'Approach today as an adventure', 'Your mindset shapes your experience. Choosing curiosity over anxiety makes the new exciting.', 'Each morning, say: "Today I''m an explorer, not a stranger. What will I discover?" Set an intention to notice something new.', 2, 'morning', 'daily', 1, true),
    (topic_id, 'Discover one new thing', 'Find one new place, route, or spot daily', 'Familiarity builds belonging. Each discovery makes the city more yours.', 'Each day, find one new thing: a coffee shop, shortcut, park bench, view. Take a photo. Build your personal map.', 20, 'anytime', 'daily', 2, true),
    (topic_id, 'Create a local routine', 'Establish a regular spot or habit', 'Regularity creates roots. Having "your" places makes you a local, not a visitor.', 'Pick one place to become a regular: a café, gym, market stall. Go consistently. Let them start to recognize you.', 30, 'anytime', 'daily', 3, true),
    (topic_id, 'One conversation with a stranger', 'Make small talk with someone local', 'Connection starts with small talk. Each conversation is a potential friendship seed.', 'Start a conversation: with a barista, neighbor, person at the gym. Just a few words counts. You''re building your network.', 5, 'anytime', 'daily', 4, true),
    (topic_id, 'Stay connected to old friends', 'Reach out to someone from your previous life', 'Maintaining old connections while building new ones provides stability.', 'Message or call one person from your previous city. Stay connected. They''re still your people.', 10, 'anytime', 'daily', 5, true),
    (topic_id, 'Join one thing', 'Sign up for a local class, group, or activity', 'Shared activities create natural connection opportunities. It''s easier than cold networking.', 'Find one group to join: fitness class, hobby group, volunteering. Show up regularly. Let relationships form naturally.', 60, 'anytime', 'weekly', 6, true),
    (topic_id, 'Evening gratitude for the new', 'Find one thing you appreciate about your new city', 'Gratitude helps you fall in love with your new home. It shifts focus from what you miss to what you''ve found.', 'Each evening, note one thing you appreciate about your new city that didn''t exist in your old one. Build a list.', 3, 'evening', 'daily', 7, false),
    (topic_id, 'Homesickness acknowledgment', 'Honor what you miss without dwelling', 'Denying homesickness makes it louder. Acknowledging it with compassion helps it pass.', 'When homesick, acknowledge it: "I miss [X]. That''s natural. I can miss it AND build something new here." Both are true.', 5, 'anytime', 'as_needed', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'I am capable of building a life anywhere.', 1),
    (topic_id, 'This city is becoming my home.', 2),
    (topic_id, 'New beginnings are opportunities.', 3),
    (topic_id, 'I carry my home within me.', 4),
    (topic_id, 'Connection is possible wherever I am.', 5),
    (topic_id, 'I am brave for starting fresh.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Settling In', 'One week in your new city', 7, 'You''re surviving the hardest part—the very beginning. It only gets easier.', 1),
    (topic_id, 'Finding Your Way', 'Two weeks of exploration', 14, 'The city is becoming more familiar. You have "your" places now.', 2),
    (topic_id, 'Local', 'One month of building your new life', 30, 'You''ve built the foundation of your new life. This place is becoming home.', 3);
  END IF;
END $$;

-- ============================================
-- EMPTY NEST
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'empty-nest';
  
  IF topic_id IS NOT NULL THEN
    INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
    (topic_id, 'Morning identity affirmation', 'Affirm who you are beyond "parent"', 'Your identity expanded when you became a parent. It''s still there underneath.', 'Each morning, say: "I am more than a parent. I am [list your roles, qualities, passions]. This is my time."', 3, 'morning', 'daily', 1, true),
    (topic_id, 'Reclaim one thing', 'Do something you put aside for parenting', 'Parenting required sacrifice. This season is for recovering what you set aside.', 'What hobby, interest, or dream did you put on hold? Take one small step toward it today.', 30, 'anytime', 'daily', 2, true),
    (topic_id, 'Create new space rituals', 'Transform the empty space positively', 'Empty rooms can feel sad or like possibility. Choose to see opportunity.', 'Pick one room that feels "empty" now. Plan how to use it for YOU: art studio, reading nook, exercise space. Make it yours.', 15, 'anytime', 'weekly', 3, true),
    (topic_id, 'Nurture your relationship', 'Invest in your partnership (if applicable)', 'Kids often became the focus. Now you have space to rediscover each other.', 'Plan one thing for just the two of you: dinner, walk, activity. Reconnect as partners, not just co-parents.', 60, 'anytime', 'weekly', 4, true),
    (topic_id, 'Healthy connection with kids', 'Reach out without hovering', 'Staying connected without smothering respects their independence while maintaining the bond.', 'Send a brief message: "Thinking of you" or share something funny. Don''t expect immediate response. Trust the bond.', 5, 'anytime', 'daily', 5, true),
    (topic_id, 'Build new community', 'Connect with people in your life stage', 'Others understand what you''re experiencing. Shared experience creates connection.', 'Reach out to others in your stage of life. Join groups for empty nesters. Share your experience.', 30, 'anytime', 'weekly', 6, true),
    (topic_id, 'Celebrate the success', 'Acknowledge what you accomplished', 'You raised humans who are ready to be independent. That''s the goal achieved.', 'Write: What qualities did my children develop? What did I do right? Take credit for this massive accomplishment.', 10, 'anytime', 'weekly', 7, false),
    (topic_id, 'Evening vision for this chapter', 'Imagine what''s possible now', 'This isn''t an ending—it''s a beginning. Visioning creates excitement for what''s ahead.', 'Before bed, imagine: What can I do now that I couldn''t before? What does my best life look like in this chapter?', 5, 'evening', 'daily', 8, false);
    
    INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
    (topic_id, 'I raised independent humans. That''s the goal.', 1),
    (topic_id, 'This chapter is mine to write.', 2),
    (topic_id, 'I am still their parent, just differently.', 3),
    (topic_id, 'Freedom is not emptiness.', 4),
    (topic_id, 'I am rediscovering myself.', 5),
    (topic_id, 'The best is not behind me.', 6);
    
    INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
    (topic_id, 'Adjusting', 'One week of empty nest rituals', 7, 'You''re surviving the adjustment. The quiet will become comfortable.', 1),
    (topic_id, 'Discovering', 'Two weeks of rediscovery', 14, 'You''re rediscovering who you are beyond parenting. There''s so much to explore.', 2),
    (topic_id, 'Thriving', 'One month into this new chapter', 30, 'You''re not just surviving the empty nest—you''re beginning to thrive in it.', 3);
  END IF;
END $$;
