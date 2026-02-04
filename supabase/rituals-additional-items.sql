-- ============================================
-- ADDITIONAL RITUAL ITEMS FOR ALL TOPICS
-- Run this after the initial seed data
-- ============================================

-- ============================================
-- SELF-LOVE FIRST
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'self-love-first';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning mirror moment', 'Start your day with kind words to yourself', 'How you speak to yourself first thing sets the tone. Self-criticism depletes; self-compassion energizes.', 'Look in the mirror and say: "Good morning. I''m glad you exist." Add one specific thing you appreciate about yourself.', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Honor one need today', 'Identify and meet one personal need', 'Self-love is action, not just feeling. Meeting your own needs builds self-trust and self-worth.', 'Ask yourself: "What do I need today?" Rest? Connection? Movement? Food? Choose ONE and make it happen.', 5, 'morning', 'daily', 2, true),
  (topic_id, 'Boundary practice', 'Say no to one thing that doesn''t serve you', 'Every yes to something wrong is a no to yourself. Boundaries are self-love in action.', 'Identify something you''re doing out of obligation, guilt, or people-pleasing. Practice saying no—even to something small.', 5, 'anytime', 'daily', 3, true),
  (topic_id, 'Self-date', 'Spend quality time alone doing something you enjoy', 'You''d plan special time for someone you love. You deserve the same treatment from yourself.', 'Schedule 30 minutes for something that brings YOU joy—not productivity, not for others. A walk, a bath, a book, a hobby.', 30, 'anytime', 'daily', 4, true),
  (topic_id, 'Forgive yourself for one thing', 'Release guilt or shame you''re carrying', 'Holding onto self-blame is self-harm. Forgiveness isn''t approval—it''s freedom.', 'Think of something you''re still beating yourself up about. Say: "I did the best I could with what I knew. I forgive myself."', 3, 'evening', 'daily', 5, true),
  (topic_id, 'Celebrate your effort', 'Acknowledge yourself for trying, regardless of outcome', 'We celebrate others'' attempts but judge our own results. Effort deserves recognition.', 'Name one thing you tried today, even if it didn''t go perfectly. Say: "I''m proud of myself for trying."', 2, 'evening', 'daily', 6, true),
  (topic_id, 'Body appreciation', 'Thank your body for what it does', 'We criticize how our bodies look but rarely appreciate what they do. Shift from critic to grateful friend.', 'Touch a part of your body you''ve criticized. Say: "Thank you for [what it does]." Example: "Thank you, legs, for carrying me."', 3, 'evening', 'daily', 7, false);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I am worthy of my own love and care.', 1),
  (topic_id, 'My needs matter, and I honor them.', 2),
  (topic_id, 'I treat myself with the same kindness I give others.', 3),
  (topic_id, 'I am learning to be my own best friend.', 4),
  (topic_id, 'Self-love is not selfish—it''s necessary.', 5),
  (topic_id, 'I forgive myself for past mistakes.', 6),
  (topic_id, 'I deserve gentleness, especially from myself.', 7);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Self-Care Started', 'One week of prioritizing yourself', 7, 'You''re learning that you matter. This is huge.', 1),
  (topic_id, 'Inner Friend Growing', 'Two weeks of self-compassion', 14, 'Your inner voice is becoming kinder. Keep nurturing this friendship.', 2),
  (topic_id, 'Self-Love Rooted', 'Three weeks of practice', 21, 'You''ve proven you can show up for yourself. This changes everything.', 3);
END $$;

-- ============================================
-- HEALING FROM HEARTBREAK
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'healing-heartbreak';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning grounding', 'Start the day by anchoring yourself in the present', 'Heartbreak pulls you into the past or anxious future. Grounding brings you back to now, where healing happens.', 'Before checking your phone, take 5 breaths. Feel your feet on the floor. Say: "I am here. I am healing. Today is a new day."', 3, 'morning', 'daily', 1, true),
  (topic_id, 'Emotion check-in', 'Name what you''re feeling without judgment', 'Suppressed emotions stay stuck. Naming them reduces their intensity and helps processing.', 'Pause and ask: "What am I feeling right now?" Name it specifically: "lonely," "angry," "relieved," "confused." Let it exist without fixing.', 3, 'anytime', 'daily', 2, true),
  (topic_id, 'No-contact reinforcement', 'Recommit to space from your ex', 'Contact reopens wounds. Space allows healing. Every day of distance is progress.', 'If tempted to reach out, write what you''d say in a journal instead. Then close it. The urge will pass.', 5, 'anytime', 'as_needed', 3, true),
  (topic_id, 'One thing just for you', 'Do something that reconnects you to yourself', 'In relationships, we often lose parts of ourselves. Heartbreak is a chance to reclaim who YOU are.', 'Do one activity you enjoy that has nothing to do with your ex. Something from before, or something new. This is YOUR life.', 20, 'anytime', 'daily', 4, true),
  (topic_id, 'Gratitude for the lesson', 'Find one thing the relationship taught you', 'Pain without meaning stays painful. Finding lessons transforms suffering into growth.', 'Ask: "What did this relationship teach me about myself, my needs, or what I want?" Write one insight.', 5, 'evening', 'daily', 5, false),
  (topic_id, 'Release ritual', 'Let go of one memory or attachment', 'Holding on keeps you stuck. Releasing creates space for what''s next.', 'Write down a memory, hope, or "what if" that''s haunting you. Read it, acknowledge the pain, then tear it up or burn it safely.', 10, 'evening', 'weekly', 6, true),
  (topic_id, 'Self-compassion moment', 'Speak kindly to your hurting heart', 'You''d comfort a friend in pain. Your own heart deserves the same tenderness.', 'Put your hand on your heart. Say: "This is really hard. It''s okay to hurt. I''m here for you." Breathe.', 2, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'This pain is temporary. I am healing.', 1),
  (topic_id, 'I am learning and growing from this experience.', 2),
  (topic_id, 'My worth is not determined by this relationship ending.', 3),
  (topic_id, 'I release what was to make room for what will be.', 4),
  (topic_id, 'I am stronger than this heartbreak.', 5),
  (topic_id, 'Better things are coming. I trust the journey.', 6),
  (topic_id, 'I choose myself, and that''s enough.', 7);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Surviving', 'One week of showing up for yourself', 7, 'You''re still here. You''re doing this. That takes strength.', 1),
  (topic_id, 'Processing', 'Two weeks of healing work', 14, 'The fog is starting to lift. You''re not just surviving—you''re healing.', 2),
  (topic_id, 'Emerging', 'Four weeks of growth', 28, 'You''ve transformed pain into progress. You''re not who you were—you''re stronger.', 3);
END $$;

-- ============================================
-- BETTER COMMUNICATION
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'better-communication';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning intention: listen more', 'Set an intention to truly hear others today', 'Most people listen to respond, not to understand. Setting an intention shifts your default.', 'Say: "Today I will listen to understand, not to reply. I will pause before responding."', 1, 'morning', 'daily', 1, true),
  (topic_id, 'Practice "I" statements', 'Express feelings without blame', '"You" statements trigger defensiveness. "I" statements express truth without attack.', 'When frustrated, use: "I feel [emotion] when [situation] because [reason]." Example: "I feel unheard when interrupted because my thoughts matter."', 3, 'anytime', 'daily', 2, true),
  (topic_id, 'Pause before reacting', 'Create space between stimulus and response', 'Reactions are automatic. Responses are chosen. The pause is where emotional intelligence lives.', 'When triggered, count to 5 before speaking. Ask: "What do I want to happen here?" Then respond intentionally.', 1, 'anytime', 'as_needed', 3, true),
  (topic_id, 'Reflect back', 'Repeat what someone said before responding', 'People feel heard when their words are acknowledged. This prevents misunderstandings and shows respect.', 'After someone speaks, say: "So what I''m hearing is..." or "It sounds like you''re saying..." Then check: "Did I get that right?"', 2, 'anytime', 'daily', 4, true),
  (topic_id, 'Ask curious questions', 'Replace assumptions with genuine inquiry', 'We often assume we know what others think. Questions reveal truth and show you care.', 'When you assume someone''s intent, stop. Ask instead: "Can you help me understand...?" or "What did you mean when...?"', 3, 'anytime', 'daily', 5, true),
  (topic_id, 'Evening communication review', 'Reflect on one conversation from today', 'Reflection builds awareness. Awareness enables growth. You can''t improve what you don''t examine.', 'Think of one conversation. What went well? What would you do differently? No judgment—just learning.', 5, 'evening', 'daily', 6, true),
  (topic_id, 'Express appreciation', 'Tell someone specifically why you value them', 'We think appreciation but rarely speak it. Expressed gratitude strengthens every relationship.', 'Tell someone what you appreciate about them—be specific. "I appreciate how you [action] because [impact]."', 2, 'anytime', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I communicate with clarity and compassion.', 1),
  (topic_id, 'I listen to understand, not just to respond.', 2),
  (topic_id, 'My words have power, and I use them wisely.', 3),
  (topic_id, 'I express my needs clearly and kindly.', 4),
  (topic_id, 'Conflict is an opportunity for deeper understanding.', 5),
  (topic_id, 'I am learning to speak my truth with love.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Awareness Growing', 'One week of mindful communication', 7, 'You''re noticing your patterns. That''s where change begins.', 1),
  (topic_id, 'Skills Building', 'Two weeks of practice', 14, 'New communication habits are forming. Others are starting to notice.', 2),
  (topic_id, 'Communicator Evolved', 'Three weeks of growth', 21, 'You''ve transformed how you connect. Relationships will never be the same.', 3);
END $$;

-- ============================================
-- JOB INTERVIEW PREP
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'interview-prep';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning confidence boost', 'Prime your mindset for success', 'Your mental state affects performance. Starting with confidence creates a positive spiral.', 'Stand tall, take 3 deep breaths. Say: "I am prepared. I am capable. I have valuable experience to share."', 3, 'morning', 'daily', 1, true),
  (topic_id, 'Visualize success', 'Mentally rehearse the interview going well', 'Visualization activates the same neural pathways as actual experience. Your brain can''t tell the difference.', 'Close your eyes. See yourself walking in confidently, answering questions clearly, connecting with interviewers. Feel the success.', 5, 'morning', 'daily', 2, true),
  (topic_id, 'Practice one answer', 'Rehearse a common interview question', 'Practice reduces anxiety. The more you rehearse, the more natural you''ll sound.', 'Pick one question: "Tell me about yourself," "Why this role?" etc. Say your answer OUT LOUD. Time it. Refine it.', 10, 'anytime', 'daily', 3, true),
  (topic_id, 'Power pose before interviews', 'Use body language to boost confidence', 'Two minutes of expansive posture increases testosterone and decreases cortisol. You''ll feel and appear more confident.', 'Before the interview, find a private space. Stand with hands on hips or arms raised in a V for 2 minutes. Breathe deeply.', 2, 'anytime', 'as_needed', 4, true),
  (topic_id, 'Research the company', 'Learn something new about the organization', 'Knowledge builds confidence and shows genuine interest. Informed candidates stand out.', 'Spend 10 minutes learning about recent company news, their mission, or the interviewer''s background on LinkedIn.', 10, 'anytime', 'daily', 5, true),
  (topic_id, 'Prepare thoughtful questions', 'Have questions ready that show genuine interest', 'Good questions demonstrate curiosity and help you evaluate if the role is right for you.', 'Write 3-5 questions about the role, team, or company culture. Avoid questions answered on their website.', 10, 'evening', 'daily', 6, false),
  (topic_id, 'Evening anxiety release', 'Let go of interview stress before bed', 'Carrying worry to bed disrupts sleep and next-day performance. Release it consciously.', 'Write down any worries about the interview. For each, write one reason it will be okay. Then close the notebook.', 5, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I am the right candidate for the right role.', 1),
  (topic_id, 'I have valuable skills and experience to offer.', 2),
  (topic_id, 'I am calm, confident, and prepared.', 3),
  (topic_id, 'I interview with clarity and authenticity.', 4),
  (topic_id, 'Each interview is practice, regardless of outcome.', 5),
  (topic_id, 'The right opportunity is coming to me.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Preparation Started', 'One week of interview prep', 7, 'You''re building confidence. Preparation is your superpower.', 1),
  (topic_id, 'Ready to Shine', 'Two weeks of practice', 14, 'You''re more prepared than most candidates. Trust your preparation.', 2);
END $$;

-- ============================================
-- CAREER TRANSITION
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'career-transition';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning possibility mindset', 'Start the day open to new opportunities', 'Transitions trigger fear. Consciously choosing possibility over fear changes what you see and attract.', 'Say: "Today I''m open to new opportunities. Change is taking me somewhere better." Believe it.', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Identify transferable skills', 'Recognize abilities that work across industries', 'You have more relevant skills than you think. Identifying them builds confidence and expands options.', 'List 3 skills you''ve developed in your career. How could each apply to a new field? Write it down.', 10, 'anytime', 'daily', 2, true),
  (topic_id, 'One networking action', 'Connect with someone in your target field', 'Most jobs come through connections. One conversation can open unexpected doors.', 'Send one message: reconnect with a contact, comment on a post, or request an informational interview. Just one.', 10, 'anytime', 'daily', 3, true),
  (topic_id, 'Learn something new', 'Develop a skill relevant to your target career', 'Learning builds confidence and makes you more competitive. Small daily progress compounds.', 'Spend 15 minutes on a course, article, or video related to your target field. Consistency beats intensity.', 15, 'anytime', 'daily', 4, true),
  (topic_id, 'Reframe the fear', 'Turn anxiety into excitement', 'Fear and excitement feel similar physically. Reframing changes the experience from threat to opportunity.', 'When fear arises, say: "I''m not scared—I''m excited. This feeling means I''m growing."', 2, 'anytime', 'as_needed', 5, true),
  (topic_id, 'Evening wins & learning', 'Celebrate progress and extract lessons', 'Transitions are marathons. Acknowledging progress sustains motivation through the long game.', 'What went well today? What did you learn? What will you try tomorrow? Celebrate any forward movement.', 5, 'evening', 'daily', 6, true),
  (topic_id, 'Envision your future self', 'Imagine life after the successful transition', 'Clarity of destination pulls you forward. Seeing the end result makes the journey meaningful.', 'Close your eyes. Imagine yourself 1 year from now, thriving in your new career. What are you doing? How do you feel?', 5, 'evening', 'daily', 7, false);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I am capable of reinventing my career.', 1),
  (topic_id, 'Every ending is a new beginning.', 2),
  (topic_id, 'My skills are valuable and transferable.', 3),
  (topic_id, 'I trust the process of change.', 4),
  (topic_id, 'The right opportunity is finding its way to me.', 5),
  (topic_id, 'I am brave enough to start over.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Journey Begun', 'One week of transition work', 7, 'You''ve taken the hardest step—starting. Keep moving.', 1),
  (topic_id, 'Momentum Building', 'Two weeks of progress', 14, 'You''re building skills and connections. The path is becoming clearer.', 2),
  (topic_id, 'Transformation Underway', 'One month of growth', 30, 'You''re not the same person who started. Your new career is taking shape.', 3);
END $$;

-- ============================================
-- FINDING YOUR PURPOSE
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'finding-purpose';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning purpose question', 'Start with inquiry about meaning', 'Questions open your mind. Asking daily keeps purpose at the forefront of awareness.', 'Ask yourself: "What would make today meaningful?" Let the answer guide your priorities.', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Notice what energizes you', 'Pay attention to moments of engagement', 'Purpose hides in plain sight. Noticing what lights you up reveals clues to your calling.', 'Throughout the day, notice: What activities make time fly? When do you feel most alive? Write it down.', 5, 'anytime', 'daily', 2, true),
  (topic_id, 'Values exploration', 'Identify what matters most to you', 'Purpose aligns with values. Knowing your values points toward meaningful work.', 'Pick 3-5 core values (freedom, creativity, service, security, growth...). How are you honoring them? How could you honor them more?', 10, 'anytime', 'daily', 3, true),
  (topic_id, 'Childhood curiosity recall', 'Remember what fascinated you as a child', 'Before society told you who to be, you had natural interests. Those threads often lead to purpose.', 'What did you love as a child? What could you do for hours? How might that connect to your adult life?', 5, 'anytime', 'weekly', 4, false),
  (topic_id, 'Impact imagination', 'Envision the difference you want to make', 'Purpose is often about contribution. Imagining your impact clarifies your direction.', 'If you could solve one problem in the world, what would it be? How might your skills contribute to that?', 5, 'evening', 'daily', 5, true),
  (topic_id, 'Gratitude for meaning', 'Appreciate moments of purpose today', 'Purpose isn''t just future—it''s now. Noticing present meaning makes it grow.', 'What moment today felt meaningful? What made it so? How can you create more moments like that?', 5, 'evening', 'daily', 6, true),
  (topic_id, 'Purpose journaling', 'Write freely about your evolving sense of calling', 'Writing clarifies thinking. Your purpose reveals itself through reflection over time.', 'Write for 5 minutes about what you think your purpose might be. Don''t edit—just explore.', 5, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'My purpose is unfolding perfectly.', 1),
  (topic_id, 'I trust that my path will become clear.', 2),
  (topic_id, 'I have unique gifts the world needs.', 3),
  (topic_id, 'Purpose is found, not forced.', 4),
  (topic_id, 'Every experience is preparing me for my calling.', 5),
  (topic_id, 'I am exactly where I need to be right now.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Exploration Begun', 'One week of purpose inquiry', 7, 'You''re asking the right questions. Answers will come.', 1),
  (topic_id, 'Clues Emerging', 'Two weeks of discovery', 14, 'Patterns are forming. Your purpose is becoming clearer.', 2),
  (topic_id, 'Direction Found', 'Four weeks of searching', 28, 'You have a much clearer sense of your path. Trust it.', 3);
END $$;

-- ============================================
-- BUILDING RESILIENCE
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'building-resilience';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning strength affirmation', 'Remind yourself of your capacity to handle hard things', 'Resilience is built by remembering past strength. Starting with this reminder primes your mindset.', 'Say: "I have survived difficult times before. I can handle whatever today brings."', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Reframe one challenge', 'Find the growth opportunity in difficulty', 'Resilient people see challenges as teachers. Reframing transforms obstacles into stepping stones.', 'Identify one challenge you''re facing. Ask: "What might this be teaching me? How could this make me stronger?"', 5, 'anytime', 'daily', 2, true),
  (topic_id, 'Comfort zone expansion', 'Do one slightly uncomfortable thing', 'Resilience grows by facing discomfort intentionally. Small challenges build capacity for big ones.', 'Do something that feels slightly uncomfortable: a cold shower, a difficult conversation, a new experience. Feel your capability grow.', 10, 'anytime', 'daily', 3, true),
  (topic_id, 'Failure reframe', 'Change how you view setbacks', 'Failure is feedback, not finale. Resilient people see setbacks as data, not destiny.', 'Think of a recent "failure." Ask: "What can I learn? What would I do differently? How is this helping me grow?"', 5, 'anytime', 'as_needed', 4, true),
  (topic_id, 'Reach out to support', 'Connect with someone who strengthens you', 'Resilience isn''t solo. Strong people have strong support networks. Connection is strength.', 'Message or call someone who believes in you. Share something you''re working through. Accept their support.', 10, 'anytime', 'daily', 5, false),
  (topic_id, 'Evening resilience journal', 'Document how you handled today''s challenges', 'Writing builds awareness of your strength. Seeing evidence of resilience reinforces it.', 'What was hard today? How did you handle it? What strength did you demonstrate? Celebrate your resilience.', 5, 'evening', 'daily', 6, true),
  (topic_id, 'Gratitude for difficulties', 'Thank a past challenge for what it taught you', 'The hardest times often become our greatest teachers. Gratitude completes the learning.', 'Think of a past difficulty. Say: "Thank you for teaching me [lesson]. I am stronger because of you."', 3, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I can handle hard things.', 1),
  (topic_id, 'Every challenge is making me stronger.', 2),
  (topic_id, 'I bend but I don''t break.', 3),
  (topic_id, 'Setbacks are setups for comebacks.', 4),
  (topic_id, 'I have survived 100% of my difficult days.', 5),
  (topic_id, 'I am more resilient than I know.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Foundation Building', 'One week of resilience practice', 7, 'You''re strengthening your capacity. Each day adds to your reservoir.', 1),
  (topic_id, 'Strength Growing', 'Two weeks of practice', 14, 'Challenges feel more manageable. You''re proving your resilience.', 2),
  (topic_id, 'Resilience Embodied', 'Four weeks of growth', 28, 'You''ve built mental muscles that will serve you for life.', 3);
END $$;

-- ============================================
-- OVERTHINKING CONTROL
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'overthinking-control';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning brain dump', 'Empty your mind before it spirals', 'Getting thoughts out of your head prevents them from looping. Externalize to neutralize.', 'Before starting your day, write down everything on your mind. Don''t organize—just dump. Then close the notebook.', 5, 'morning', 'daily', 1, true),
  (topic_id, 'Thought labeling', 'Name what your mind is doing', 'Labeling thoughts creates distance from them. You are not your thoughts—you observe them.', 'When you notice overthinking, say: "I''m having the thought that..." or "My mind is doing its worrying thing again."', 1, 'anytime', 'as_needed', 2, true),
  (topic_id, 'The 5-5-5 rule', 'Put worries in perspective', 'Most things we worry about don''t matter long-term. Perspective dissolves anxiety.', 'Ask yourself: "Will this matter in 5 minutes? 5 months? 5 years?" Act accordingly.', 2, 'anytime', 'as_needed', 3, true),
  (topic_id, 'Action or release', 'Decide if you can act or need to let go', 'Overthinking thrives on ambiguity. Deciding to act or release breaks the loop.', 'For each worry, ask: "Can I do something about this now?" If yes, do it. If no, say "I release this" and move on.', 5, 'anytime', 'daily', 4, true),
  (topic_id, 'Body movement break', 'Get out of your head and into your body', 'Overthinking is being trapped in your head. Physical movement shifts energy and breaks patterns.', 'When stuck in thought loops: 20 jumping jacks, a short walk, or dance to one song. Move the mental energy.', 5, 'anytime', 'as_needed', 5, true),
  (topic_id, 'Worry window', 'Contain worrying to a specific time', 'Giving worry its own time reduces its intrusion on the rest of your day.', 'Schedule 15 minutes of "worry time" daily. When worries arise outside this window, write them down for later.', 15, 'afternoon', 'daily', 6, true),
  (topic_id, 'Evening mind clearing', 'Release the day''s mental clutter', 'Carrying thoughts to bed disrupts sleep. Conscious release creates peace.', 'Before bed, imagine your thoughts as leaves floating down a stream. Watch them drift away. You can pick them up tomorrow if needed.', 5, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'My thoughts are not facts.', 1),
  (topic_id, 'I can observe my mind without believing everything it says.', 2),
  (topic_id, 'I release what I cannot control.', 3),
  (topic_id, 'Clarity comes when I quiet the noise.', 4),
  (topic_id, 'I trust myself to handle whatever happens.', 5),
  (topic_id, 'Peace is available to me in this moment.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Awareness Building', 'One week of catching overthinking', 7, 'You''re noticing the patterns. That''s the first step to changing them.', 1),
  (topic_id, 'Tools Working', 'Two weeks of practice', 14, 'The loops are shorter. You''re getting better at breaking free.', 2),
  (topic_id, 'Mind Quieted', 'Three weeks of growth', 21, 'Your mind is calmer. You''ve learned to be the observer, not the thought.', 3);
END $$;

-- ============================================
-- PHONE DETOX
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'phone-detox';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Phone-free morning', 'Start the day without your phone for 30 minutes', 'Morning phone use hijacks your agenda with others'' priorities. Protecting this time protects your mindset.', 'Keep your phone in another room or on airplane mode for 30 minutes after waking. Own your morning.', 30, 'morning', 'daily', 1, true),
  (topic_id, 'Intention before unlock', 'Pause before mindlessly opening your phone', 'Most phone pickups are unconscious habit. Adding intention breaks the automatic pattern.', 'Before unlocking, ask: "What am I looking for?" If you don''t have an answer, put it down.', 1, 'anytime', 'as_needed', 2, true),
  (topic_id, 'App time check', 'Review your screen time daily', 'Awareness is the first step to change. Knowing the reality motivates action.', 'Check your screen time in settings. Which apps took the most time? Was it worth it? Set a goal for tomorrow.', 3, 'evening', 'daily', 3, true),
  (topic_id, 'Notification audit', 'Disable unnecessary notifications', 'Every notification is an interruption. Most aren''t urgent. Reclaim your attention.', 'Go through your notification settings. Disable alerts for apps that don''t need immediate attention. Be ruthless.', 10, 'anytime', 'weekly', 4, false),
  (topic_id, 'Phone-free meals', 'Eat without your phone present', 'Meals are opportunities for presence and connection. Phones steal both.', 'Put your phone in another room during meals. Taste your food. Talk to people. Be here.', 20, 'anytime', 'daily', 5, true),
  (topic_id, 'Replace the reach', 'When you reach for your phone, do something else', 'The urge to check is a habit. Replacing the behavior with something else rewires the pattern.', 'Notice when you unconsciously reach. Instead: take 3 breaths, look around, stretch, or just sit with the urge.', 2, 'anytime', 'as_needed', 6, true),
  (topic_id, 'Phone-free hour before bed', 'Create space between screens and sleep', 'Blue light and stimulating content disrupt sleep. The hour before bed should be yours.', 'Put your phone to bed 1 hour before you sleep. Charge it in another room. Read, stretch, or talk instead.', 60, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I control my phone—it doesn''t control me.', 1),
  (topic_id, 'My attention is valuable, and I protect it.', 2),
  (topic_id, 'I choose presence over distraction.', 3),
  (topic_id, 'Real life happens off-screen.', 4),
  (topic_id, 'I don''t need to be constantly connected.', 5),
  (topic_id, 'Peace comes from disconnecting.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Awareness Activated', 'One week of conscious phone use', 7, 'You''re seeing the pattern clearly now. That''s power.', 1),
  (topic_id, 'Control Returning', 'Two weeks of practice', 14, 'The urge is weakening. You''re reclaiming your attention.', 2),
  (topic_id, 'Freedom Found', 'Three weeks of detox', 21, 'You''ve broken the unconscious habit. Your attention is yours again.', 3);
END $$;

-- ============================================
-- FITNESS START
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'fitness-start';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning movement (2 min)', 'Start with the smallest possible exercise', 'Tiny habits are sustainable habits. 2 minutes is so small you can''t say no.', 'Upon waking, do 2 minutes of movement: stretching, jumping jacks, dancing—anything. Just 2 minutes.', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Lay out workout clothes', 'Remove barriers to exercise', 'Environment design beats willpower. Making it easy makes it happen.', 'Before bed, lay out tomorrow''s workout clothes. When you see them, you''re more likely to use them.', 2, 'evening', 'daily', 2, true),
  (topic_id, 'One more minute', 'Gradually extend your exercise time', 'Progress happens at the edges of comfort. Adding one minute compounds into major gains.', 'Whatever movement you did yesterday, add one minute today. Slow, sustainable progress.', 1, 'anytime', 'daily', 3, true),
  (topic_id, 'Movement snacks', 'Add brief exercise throughout the day', 'You don''t need an hour at the gym. Movement scattered through the day adds up.', 'Every hour, do 1 minute of movement: 10 squats, a walk to the kitchen, stairs instead of elevator.', 5, 'anytime', 'daily', 4, true),
  (topic_id, 'Celebrate showing up', 'Acknowledge yourself for moving, regardless of intensity', 'The habit of showing up matters more than the workout itself. Celebration reinforces the behavior.', 'After any movement, say: "I showed up for myself today." Feel proud, even if it was small.', 1, 'anytime', 'daily', 5, true),
  (topic_id, 'Find your joy movement', 'Discover exercise you actually enjoy', 'Sustainable fitness requires enjoyment. Forcing yourself leads to quitting.', 'Try different activities: walking, dancing, swimming, yoga, sports. What feels like play, not punishment?', 15, 'anytime', 'weekly', 6, false),
  (topic_id, 'Rest day pride', 'Embrace recovery as part of fitness', 'Rest is when your body rebuilds. Skipping rest leads to burnout and injury.', 'On rest days, say: "Rest is part of getting stronger." Enjoy the recovery without guilt.', 1, 'anytime', 'as_needed', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'Every movement counts.', 1),
  (topic_id, 'I am building a body that serves me well.', 2),
  (topic_id, 'Progress, not perfection, is my goal.', 3),
  (topic_id, 'I deserve to feel strong and energized.', 4),
  (topic_id, 'Small steps lead to big changes.', 5),
  (topic_id, 'I move my body because I love it, not because I hate it.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Motion Started', 'One week of daily movement', 7, 'You''ve moved every day for a week. The habit is forming!', 1),
  (topic_id, 'Habit Building', 'Two weeks of consistency', 14, 'Two weeks! Your body is adapting. Keep going.', 2),
  (topic_id, 'Mover', 'One month of practice', 30, 'You''ve built a movement habit. You''re now someone who exercises.', 3);
END $$;

-- ============================================
-- DEPRESSION SUPPORT
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'depression-support';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Get out of bed', 'Make getting up the first win', 'When depressed, everything feels heavy. Getting up is a victory—acknowledge it as such.', 'When you wake, count 3-2-1 and sit up. Then stand. Then take one step. Each is a win. Celebrate them.', 2, 'morning', 'daily', 1, true),
  (topic_id, 'One hygiene task', 'Do one self-care action', 'Depression steals energy for self-care. Doing ONE thing maintains dignity and momentum.', 'Pick one: brush teeth, wash face, change clothes, shower. Just one. That''s enough for today.', 5, 'morning', 'daily', 2, true),
  (topic_id, 'Step outside', 'Get fresh air and natural light', 'Sunlight and fresh air affect brain chemistry. Even 5 minutes helps.', 'Step outside for 5 minutes. You don''t have to go anywhere. Just stand in daylight and breathe.', 5, 'morning', 'daily', 3, true),
  (topic_id, 'One tiny task', 'Accomplish something small', 'Depression tells you you can''t do anything. Completing ONE task proves it wrong.', 'Pick the smallest task: send one text, wash one dish, pick up one thing. Do it. You did something.', 5, 'anytime', 'daily', 4, true),
  (topic_id, 'Connect with one person', 'Reach out to another human', 'Isolation feeds depression. Connection—even brief—provides lifeline.', 'Text someone. Call someone. Say hi to a neighbor. Any human contact counts.', 5, 'anytime', 'daily', 5, true),
  (topic_id, 'Feel without judgment', 'Allow your feelings to exist', 'Fighting depression adds exhaustion. Accepting "I feel this way right now" reduces suffering.', 'When hard feelings come, say: "I''m feeling depressed right now. This is temporary. I''m doing my best."', 3, 'anytime', 'as_needed', 6, true),
  (topic_id, 'Name one okay thing', 'Find something that isn''t terrible', 'Depression colors everything dark. Finding ONE neutral or positive thing creates cracks for light.', 'Before bed, name one thing that was okay today. Not great—just okay. "The coffee was warm." That counts.', 2, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I am doing the best I can, and that is enough.', 1),
  (topic_id, 'This feeling is temporary, not permanent.', 2),
  (topic_id, 'I deserve compassion, especially from myself.', 3),
  (topic_id, 'Small steps still move me forward.', 4),
  (topic_id, 'Asking for help is strength, not weakness.', 5),
  (topic_id, 'I matter, even when I can''t feel it.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Still Here', 'One week of showing up', 7, 'You showed up for yourself 7 days in a row. That takes immense strength.', 1),
  (topic_id, 'Keeping Going', 'Two weeks of practice', 14, 'Two weeks. You''re proving that you can do this, even when it''s hard.', 2),
  (topic_id, 'Warrior', 'One month of strength', 30, 'A full month of fighting for yourself. You are stronger than you know.', 3);
END $$;

-- ============================================
-- NEW PARENT
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'new-parent';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning self-check', 'Check in with yourself before caregiving', 'You can''t pour from an empty cup. Knowing your state helps you meet your needs too.', 'Before tending to anyone else, ask: "How am I feeling? What do I need?" Acknowledge it, even if you can''t act immediately.', 2, 'morning', 'daily', 1, true),
  (topic_id, 'One thing just for you', 'Claim one moment of personal time', 'Parenting can consume all identity. One personal moment maintains your sense of self.', 'Find 10 minutes for something YOU enjoy: a chapter, a song, a quiet coffee. Guard this time fiercely.', 10, 'anytime', 'daily', 2, true),
  (topic_id, 'Ask for help', 'Request support from someone', 'Doing it all alone leads to burnout. Asking for help is good parenting, not failure.', 'Ask for one specific thing today: "Can you hold baby while I shower?" "Can you bring dinner?" Accept help.', 2, 'anytime', 'daily', 3, true),
  (topic_id, 'Good enough parenting', 'Release the perfection pressure', 'Perfect parenting doesn''t exist. Good enough is actually good enough.', 'When you feel like you''re failing, say: "I am a good enough parent. My child needs love, not perfection."', 1, 'anytime', 'as_needed', 4, true),
  (topic_id, 'Partner connection', 'Have one meaningful moment with your partner', 'Children can eclipse relationships. Brief connection maintains the partnership foundation.', 'Share one thing from your day. Ask one question. Hold hands for 30 seconds. Small moments maintain connection.', 5, 'evening', 'daily', 5, false),
  (topic_id, 'Celebrate a parenting win', 'Acknowledge something you did well', 'We notice every mistake but ignore successes. Celebrating wins builds parenting confidence.', 'Name one thing you did well as a parent today. "I was patient." "I showed up." "I tried my best."', 2, 'evening', 'daily', 6, true),
  (topic_id, 'Sleep when possible', 'Prioritize rest without guilt', 'Sleep deprivation affects everything. Rest is not lazy—it''s survival.', 'When baby sleeps, give yourself permission to rest. Chores can wait. Your rest matters.', 15, 'anytime', 'as_needed', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I am the perfect parent for my child.', 1),
  (topic_id, 'I deserve rest and care too.', 2),
  (topic_id, 'Good enough is good enough.', 3),
  (topic_id, 'Asking for help makes me a good parent.', 4),
  (topic_id, 'I am doing better than I think.', 5),
  (topic_id, 'My needs matter alongside my child''s.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Self-Care Started', 'One week of caring for yourself too', 7, 'You''re learning to care for yourself while caring for others. Essential.', 1),
  (topic_id, 'Balance Building', 'Two weeks of practice', 14, 'You''re finding rhythms that work. You''re doing amazing.', 2),
  (topic_id, 'Thriving Parent', 'One month of growth', 30, 'You''ve maintained yourself while nurturing another life. That''s extraordinary.', 3);
END $$;

-- ============================================
-- MAKING FRIENDS
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'making-friends';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Smile at strangers', 'Practice friendly openness', 'Friendships start with approachability. Smiling signals you''re open to connection.', 'Make eye contact and smile at 3 people today. That''s it. Build the muscle of friendly openness.', 1, 'anytime', 'daily', 1, true),
  (topic_id, 'Start one conversation', 'Initiate contact with someone', 'Waiting for others to approach rarely works. Taking initiative creates opportunities.', 'Talk to one person: a colleague, neighbor, or stranger. Comment on something shared: weather, environment, situation.', 5, 'anytime', 'daily', 2, true),
  (topic_id, 'Ask a follow-up question', 'Show genuine interest in others', 'People love talking about themselves. Questions show you care and create connection.', 'In any conversation, ask one follow-up question: "Tell me more about that." "How did that feel?" "What happened next?"', 2, 'anytime', 'daily', 3, true),
  (topic_id, 'Say yes to one invitation', 'Accept opportunities to connect', 'Friendship requires showing up. Saying yes, even when nervous, creates possibility.', 'When invited somewhere, say yes—even if anxious. One yes leads to more connection.', 1, 'anytime', 'as_needed', 4, true),
  (topic_id, 'Reach out to someone', 'Make the first move to deepen a connection', 'Most people wait for others to reach out. Being the initiator sets you apart.', 'Message someone you''d like to know better: "Hey, want to grab coffee?" "That thing you mentioned sounds cool—tell me more."', 5, 'anytime', 'daily', 5, true),
  (topic_id, 'Find your places', 'Go where like-minded people gather', 'Random friendship is rare. Shared interests create natural connection points.', 'Identify one place where people who share your interests gather. Commit to going regularly.', 10, 'anytime', 'weekly', 6, false),
  (topic_id, 'Appreciate existing connections', 'Nurture the friendships you have', 'Chasing new friends while neglecting current ones is backward. Deepen what exists.', 'Message one existing friend to check in. Express appreciation. Nurture what you have.', 5, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I am worthy of friendship.', 1),
  (topic_id, 'The right friends are finding their way to me.', 2),
  (topic_id, 'I have interesting things to offer.', 3),
  (topic_id, 'Connection is worth the awkwardness.', 4),
  (topic_id, 'Quality friendships take time to build.', 5),
  (topic_id, 'I am learning to be a great friend.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Opening Up', 'One week of social practice', 7, 'You''re putting yourself out there. That takes courage.', 1),
  (topic_id, 'Connections Growing', 'Two weeks of effort', 14, 'Seeds are planted. Some will bloom into friendships.', 2),
  (topic_id, 'Friend Maker', 'Four weeks of practice', 28, 'You''ve built skills and confidence. Friendships are forming.', 3);
END $$;

-- ============================================
-- SOCIAL ANXIETY
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'social-anxiety';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning grounding', 'Start with calm before social challenges', 'Anxiety builds on anxiety. Starting grounded gives you a better baseline.', 'Before facing the day, take 5 slow breaths. Say: "I am safe. People are not as focused on me as I think."', 3, 'morning', 'daily', 1, true),
  (topic_id, 'Challenge one anxious thought', 'Question the accuracy of social fears', 'Anxious thoughts are not facts. Challenging them reveals their distortion.', 'When you think "Everyone will judge me," ask: "Is this definitely true? What''s the evidence? What would I tell a friend?"', 3, 'anytime', 'as_needed', 2, true),
  (topic_id, 'One small exposure', 'Face a tiny social fear daily', 'Avoidance feeds anxiety. Small exposures build tolerance and confidence.', 'Do one thing that''s slightly anxiety-provoking: make eye contact, say hi, ask a question. Small steps compound.', 5, 'anytime', 'daily', 3, true),
  (topic_id, 'Focus outward', 'Shift attention from yourself to others', 'Social anxiety is self-focused attention. Looking outward reduces self-consciousness.', 'In social situations, focus on the other person: What are they wearing? What might they be feeling? Curiosity replaces anxiety.', 1, 'anytime', 'as_needed', 4, true),
  (topic_id, 'Prepare one thing to say', 'Have a conversation starter ready', 'Anxiety increases with uncertainty. Having something prepared reduces "what do I say" panic.', 'Before social events, prepare one question or comment. Just one. Having it ready provides security.', 3, 'morning', 'daily', 5, false),
  (topic_id, 'Self-compassion after socializing', 'Be kind about any awkwardness', 'Post-event rumination is torture. Self-compassion breaks the cycle of self-criticism.', 'After social situations, resist replaying mistakes. Say: "I did my best. Awkward moments happen to everyone."', 3, 'anytime', 'as_needed', 6, true),
  (topic_id, 'Celebrate showing up', 'Acknowledge your courage', 'Every social situation faced is a victory when you have anxiety. Celebrate it.', 'After any social interaction, say: "I did it. I showed up despite feeling scared. That''s brave."', 1, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I am not as visible as my anxiety tells me.', 1),
  (topic_id, 'Everyone feels awkward sometimes.', 2),
  (topic_id, 'I can feel anxious and still connect.', 3),
  (topic_id, 'Each social situation is practice, not a test.', 4),
  (topic_id, 'My worth doesn''t depend on social performance.', 5),
  (topic_id, 'I am learning to feel more comfortable.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Facing Fears', 'One week of small exposures', 7, 'You''re doing the hard work of facing your anxiety. That''s courage.', 1),
  (topic_id, 'Building Tolerance', 'Two weeks of practice', 14, 'Social situations are becoming slightly easier. You''re rewiring your brain.', 2),
  (topic_id, 'Growing Confidence', 'One month of progress', 30, 'You''ve proven you can handle social situations. The anxiety may remain, but so does your strength.', 3);
END $$;

-- ============================================
-- GRIEF & LOSS
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'grief-loss';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning acknowledgment', 'Acknowledge your grief upon waking', 'Grief doesn''t disappear by ignoring it. Acknowledging it allows it to move through you.', 'Upon waking, notice how you feel. Say: "I am grieving. This is hard. I will be gentle with myself today."', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Feel what comes', 'Allow emotions without judgment', 'Grief comes in waves. Fighting it extends suffering. Allowing it helps it pass.', 'When emotions arise, let them. Cry if you need to. Anger is okay. Numbness is okay. All of it is valid.', 5, 'anytime', 'as_needed', 2, true),
  (topic_id, 'One basic need', 'Meet one physical need today', 'Grief is exhausting. Basic self-care maintains your foundation when everything feels hard.', 'Eat something. Drink water. Sleep when you can. Choose one basic need and meet it.', 10, 'anytime', 'daily', 3, true),
  (topic_id, 'Connection touch-point', 'Reach out to someone', 'Grief isolates. Connection reminds you that you''re not alone.', 'Talk to someone—even briefly. Share if you want, or just be in company. You don''t have to carry this alone.', 10, 'anytime', 'daily', 4, true),
  (topic_id, 'Memory moment', 'Spend time with a memory of what/who you lost', 'Grief is love with nowhere to go. Honoring memories keeps connection alive.', 'Look at a photo, read something they wrote, visit a meaningful place. Let yourself remember.', 10, 'anytime', 'daily', 5, false),
  (topic_id, 'Permission to pause', 'Take a break from grief work', 'Constant grief is unsustainable. Breaks aren''t betrayal—they''re survival.', 'Give yourself permission to watch a show, laugh at something, or feel okay for a moment. Grief will still be there.', 15, 'anytime', 'as_needed', 6, true),
  (topic_id, 'Evening gentleness', 'End the day with self-compassion', 'You survived another day of grief. That deserves acknowledgment.', 'Before sleep, say: "I made it through today. I am doing the best I can. Tomorrow I will try again."', 2, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'There is no right way to grieve.', 1),
  (topic_id, 'My grief is a measure of my love.', 2),
  (topic_id, 'Healing is not forgetting.', 3),
  (topic_id, 'I am allowed to feel whatever I feel.', 4),
  (topic_id, 'I will carry this loss and still find moments of peace.', 5),
  (topic_id, 'I am not alone in my grief.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'One Week', 'One week of grieving', 7, 'You''re still here, still trying. That matters.', 1),
  (topic_id, 'Two Weeks', 'Two weeks of mourning', 14, 'Grief has no timeline. You''re doing this at your own pace.', 2),
  (topic_id, 'One Month', 'One month of loss', 30, 'A month of carrying this. You''re stronger than you know.', 3);
END $$;

-- ============================================
-- PRESENT MOMENT LIVING
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'present-moment';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning presence', 'Begin the day fully present', 'The first moments set the tone. Starting present creates a mindful foundation.', 'Before getting up, take 5 breaths. Feel the bed beneath you. Notice sounds. Say: "I am here, now."', 3, 'morning', 'daily', 1, true),
  (topic_id, 'Anchor to senses', 'Use your senses to return to now', 'The mind wanders to past and future. Senses exist only in the present moment.', 'Throughout the day, pause and notice: What do I see? Hear? Feel? Smell? Taste? This is presence.', 2, 'anytime', 'daily', 2, true),
  (topic_id, 'Single-tasking', 'Do one thing at a time with full attention', 'Multitasking fractures presence. Single-tasking is mindfulness in action.', 'Choose one task and do ONLY that. When your mind wanders to the next thing, return to this one.', 15, 'anytime', 'daily', 3, true),
  (topic_id, 'Mindful eating', 'Eat one meal with full attention', 'We often eat while distracted. Mindful eating is a daily presence practice.', 'For one meal, no screens. Taste each bite. Notice textures. Chew slowly. Experience eating.', 15, 'anytime', 'daily', 4, true),
  (topic_id, 'Thought watching', 'Observe thoughts without following them', 'You are not your thoughts. Watching them creates space and presence.', 'For 2 minutes, watch your thoughts like clouds passing. Don''t engage—just observe. This is awareness.', 2, 'anytime', 'daily', 5, true),
  (topic_id, 'Nature presence', 'Connect fully with something natural', 'Nature demands nothing. It invites pure presence without agenda.', 'Spend 5 minutes with something natural: a tree, the sky, a plant. Just observe. Be with it completely.', 5, 'anytime', 'daily', 6, false),
  (topic_id, 'Evening presence gratitude', 'Appreciate moments of presence from today', 'Noticing when you were present reinforces the practice.', 'Recall a moment today when you were fully present. How did it feel? Appreciate that glimpse of now.', 3, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'This moment is all there is.', 1),
  (topic_id, 'I release the past and trust the future.', 2),
  (topic_id, 'Peace is found in the present.', 3),
  (topic_id, 'I choose to be here now.', 4),
  (topic_id, 'Life happens in this moment, nowhere else.', 5),
  (topic_id, 'I am learning to inhabit my life fully.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Awareness Awakening', 'One week of presence practice', 7, 'You''re catching yourself more often. Presence is growing.', 1),
  (topic_id, 'Presence Building', 'Two weeks of mindfulness', 14, 'Moments of presence are lasting longer. The muscle is strengthening.', 2),
  (topic_id, 'Here and Now', 'Four weeks of practice', 28, 'You''ve transformed your relationship with the present moment. Life feels more vivid.', 3);
END $$;

-- ============================================
-- LEARNING TO SAY NO
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'saying-no';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Morning boundary intention', 'Set an intention to protect your limits', 'Without intention, old patterns win. Setting the intention primes boundary awareness.', 'Say: "Today I will honor my limits. My no is valid. I don''t need to justify my boundaries."', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Pause before yes', 'Create space between request and response', 'Automatic yes is a habit. The pause creates space for authentic choice.', 'When asked for something, don''t answer immediately. Say: "Let me think about that" or "I''ll get back to you."', 1, 'anytime', 'as_needed', 2, true),
  (topic_id, 'Practice a small no', 'Say no to something low-stakes', 'No is a muscle. Small practice builds capacity for bigger boundaries.', 'Find something small to decline: an offer of food you don''t want, a plan that doesn''t excite you. Say no.', 2, 'anytime', 'daily', 3, true),
  (topic_id, 'Check your why', 'Examine why you''re about to say yes', 'Many yeses come from guilt, fear, or obligation. Checking motives reveals authentic choice.', 'Before agreeing to something, ask: "Am I saying yes because I want to, or because I''m afraid to say no?"', 2, 'anytime', 'as_needed', 4, true),
  (topic_id, 'Script a boundary', 'Prepare language for difficult conversations', 'Having words ready reduces anxiety and increases follow-through.', 'Write out what you want to say for a boundary you need to set. Practice it aloud. Having the script helps.', 10, 'anytime', 'as_needed', 5, false),
  (topic_id, 'Release guilt', 'Let go of guilt after setting a boundary', 'Guilt after no is normal but unfounded. Processing it prevents backtracking.', 'After setting a boundary, notice any guilt. Say: "I am allowed to have limits. Their reaction is not my responsibility."', 3, 'anytime', 'as_needed', 6, true),
  (topic_id, 'Celebrate a boundary', 'Acknowledge yourself for holding a limit', 'Boundaries deserve celebration. They''re hard. Acknowledging success reinforces the behavior.', 'At day''s end, name one boundary you held. Say: "I honored my limits today. I''m proud of myself."', 2, 'evening', 'daily', 7, true);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'No is a complete sentence.', 1),
  (topic_id, 'My boundaries protect my energy and peace.', 2),
  (topic_id, 'I can say no and still be a good person.', 3),
  (topic_id, 'Other people''s disappointment is not my emergency.', 4),
  (topic_id, 'Every no to something wrong is a yes to myself.', 5),
  (topic_id, 'I deserve relationships that respect my limits.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Boundaries Beginning', 'One week of boundary practice', 7, 'You''re learning to honor your limits. This changes everything.', 1),
  (topic_id, 'No Getting Easier', 'Two weeks of saying no', 14, 'The guilt is lessening. The boundaries are holding. You''re doing it.', 2),
  (topic_id, 'Boundary Setter', 'Three weeks of practice', 21, 'You''ve transformed your relationship with no. Your life has more space for yes.', 3);
END $$;

-- ============================================
-- FINANCIAL WELLNESS
-- ============================================
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM ritual_topics WHERE slug = 'financial-wellness';
  
  INSERT INTO ritual_items (topic_id, title, description, why_it_helps, how_to, duration_minutes, time_of_day, frequency, display_order, is_core) VALUES
  (topic_id, 'Money mindset moment', 'Start with a positive financial thought', 'Money anxiety creates more anxiety. Intentionally shifting mindset breaks the fear cycle.', 'Say: "I am learning to manage money well. I am capable of financial peace." Believe it''s possible.', 2, 'morning', 'daily', 1, true),
  (topic_id, 'Check your accounts', 'Look at your balances without judgment', 'Avoidance increases financial anxiety. Knowledge—even hard knowledge—is power.', 'Open your accounts. Look at the numbers. No judgment. Just awareness. This is step one.', 5, 'morning', 'daily', 2, true),
  (topic_id, 'Pause before purchasing', 'Create space before spending', 'Impulse spending is often emotional. The pause reveals whether you actually want/need it.', 'Before buying anything non-essential, wait 24 hours. Ask: "Do I really need this? Will I care about it next week?"', 1, 'anytime', 'as_needed', 3, true),
  (topic_id, 'Track one expense category', 'Know where your money actually goes', 'You can''t improve what you don''t measure. Tracking creates clarity and control.', 'Pick one category (food, entertainment, subscriptions). Track every expense there for a week.', 5, 'evening', 'daily', 4, true),
  (topic_id, 'Gratitude for what you have', 'Appreciate your current resources', 'Scarcity mindset creates desperation. Gratitude shifts focus from lack to sufficiency.', 'Name 3 things money has provided: a roof, food, safety. Appreciate what your resources give you.', 3, 'evening', 'daily', 5, true),
  (topic_id, 'Learn one financial concept', 'Build money knowledge', 'Financial literacy is empowering. Understanding money reduces fear of it.', 'Spend 10 minutes learning about one concept: budgeting, investing basics, compound interest.', 10, 'anytime', 'daily', 6, false),
  (topic_id, 'Money talk', 'Have one honest conversation about finances', 'Money shame thrives in silence. Talking normalizes financial struggles and reveals solutions.', 'Talk to someone about money—your situation, goals, or fears. Breaking silence reduces shame.', 10, 'anytime', 'weekly', 7, false);

  INSERT INTO ritual_affirmations (topic_id, text, display_order) VALUES
  (topic_id, 'I am capable of managing my money well.', 1),
  (topic_id, 'Financial peace is possible for me.', 2),
  (topic_id, 'I release shame about my financial past.', 3),
  (topic_id, 'Every small step improves my financial future.', 4),
  (topic_id, 'I am learning to have a healthy relationship with money.', 5),
  (topic_id, 'I deserve financial stability and abundance.', 6);

  INSERT INTO ritual_milestones (topic_id, title, description, day_threshold, celebration_message, display_order) VALUES
  (topic_id, 'Awareness Growing', 'One week of financial attention', 7, 'You''re facing your finances. That takes courage.', 1),
  (topic_id, 'Habits Forming', 'Two weeks of practice', 14, 'New money habits are forming. You''re taking control.', 2),
  (topic_id, 'Financial Wellness', 'One month of growth', 30, 'You''ve transformed your relationship with money. The anxiety is lifting.', 3);
END $$;

-- Final message
SELECT 'Additional ritual items inserted successfully!' AS status;
