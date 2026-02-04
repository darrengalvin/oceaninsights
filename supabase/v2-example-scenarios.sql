-- Example Scenarios for Decision Training System
-- Run this after v2-scenarios-schema.sql

-- Get the content pack IDs
DO $$
DECLARE
  comm_pack_id UUID;
  hier_pack_id UUID;
  peer_pack_id UUID;
  press_pack_id UUID;
  
  -- Scenario IDs
  scenario1_id UUID := gen_random_uuid();
  scenario2_id UUID := gen_random_uuid();
  scenario3_id UUID := gen_random_uuid();
  scenario4_id UUID := gen_random_uuid();
  scenario5_id UUID := gen_random_uuid();
  
  -- Option IDs
  opt1_1 UUID := gen_random_uuid();
  opt1_2 UUID := gen_random_uuid();
  opt1_3 UUID := gen_random_uuid();
  opt1_4 UUID := gen_random_uuid();
  
  opt2_1 UUID := gen_random_uuid();
  opt2_2 UUID := gen_random_uuid();
  opt2_3 UUID := gen_random_uuid();
  
  opt3_1 UUID := gen_random_uuid();
  opt3_2 UUID := gen_random_uuid();
  opt3_3 UUID := gen_random_uuid();
  opt3_4 UUID := gen_random_uuid();
  
  opt4_1 UUID := gen_random_uuid();
  opt4_2 UUID := gen_random_uuid();
  opt4_3 UUID := gen_random_uuid();
  
  opt5_1 UUID := gen_random_uuid();
  opt5_2 UUID := gen_random_uuid();
  opt5_3 UUID := gen_random_uuid();
  opt5_4 UUID := gen_random_uuid();
  
BEGIN
  -- Get content pack IDs
  SELECT id INTO comm_pack_id FROM content_packs WHERE name = 'Communication Fundamentals';
  SELECT id INTO hier_pack_id FROM content_packs WHERE name = 'Hierarchy & Authority';
  SELECT id INTO peer_pack_id FROM content_packs WHERE name = 'Peer Dynamics';
  SELECT id INTO press_pack_id FROM content_packs WHERE name = 'High Pressure';

  -- ==============================================
  -- SCENARIO 1: Interrupted in Briefing
  -- ==============================================
  INSERT INTO scenarios (id, title, situation, context, difficulty, content_pack_id, tags, published) VALUES
  (scenario1_id, 
   'Interrupted in Briefing',
   'You''re presenting to command when a senior officer interrupts mid-sentence to challenge your data. You''re confident in your numbers, but the tone suggests they''re not open to discussion. The room is silent, waiting for your response.',
   'hierarchy',
   2,
   hier_pack_id,
   ARRAY['authority', 'communication', 'professional'],
   true);

  -- Options for Scenario 1
  INSERT INTO scenario_options (id, scenario_id, text, tags, immediate_outcome, longterm_outcome, risk_level, sort_order) VALUES
  (opt1_1, scenario1_id, 
   '"Sir, if I could finish the slide, the source is cited there."',
   ARRAY['direct', 'assertive', 'firm'],
   'Maintains credibility and shows confidence. May slightly increase tension in the room.',
   'Establishes that you don''t back down under pressure, but could be remembered as combative if not handled carefully.',
   'medium',
   0),
  (opt1_2, scenario1_id,
   'Pause, acknowledge: "Good question. Let me address that now before continuing."',
   ARRAY['adaptive', 'respectful', 'collaborative'],
   'De-escalates tension immediately and shows flexibility. Command appreciates the acknowledgment.',
   'Seen as collaborative and professional. Builds trust with leadership without sacrificing the presentation.',
   'low',
   1),
  (opt1_3, scenario1_id,
   'Continue without acknowledging: "As you''ll see in the data..."',
   ARRAY['indirect', 'avoidant', 'dismissive'],
   'Avoids direct confrontation but appears dismissive. The officer looks annoyed.',
   'May be seen as either stubborn or disrespectful. Could damage relationship with senior leadership.',
   'high',
   2),
  (opt1_4, scenario1_id,
   'Stop entirely: "Would you like me to address that concern first, or shall I continue?"',
   ARRAY['deferential', 'adaptive', 'respectful'],
   'Shows respect for hierarchy and gives control to the senior officer. Tension drops.',
   'Demonstrates humility and flexibility. May be seen as either professional or overly passive.',
   'low',
   3);

  -- Perspective shifts for Scenario 1
  INSERT INTO perspective_shifts (option_id, viewpoint, interpretation) VALUES
  (opt1_1, 'command', 'Shows confidence and backbone. Appreciates the directness but notes the potential for friction.'),
  (opt1_1, 'peer', 'Impressed by your composure but worried you might have pushed too hard with senior leadership.'),
  (opt1_2, 'command', 'Professional response that maintains order. Respects your ability to adapt under pressure.'),
  (opt1_2, 'peer', 'Smart move - you defused the situation without backing down on your position.'),
  (opt1_3, 'command', 'Appears disrespectful or tone-deaf. Ignoring a senior officer rarely ends well.'),
  (opt1_3, 'peer', 'That was risky - they looked really put off by being ignored.'),
  (opt1_4, 'command', 'Appreciates the respect for hierarchy. Some may see it as appropriate, others as too deferential.'),
  (opt1_4, 'peer', 'You handed them control completely - not sure if that was necessary.');

  -- ==============================================
  -- SCENARIO 2: Taking Credit for Your Work
  -- ==============================================
  INSERT INTO scenarios (id, title, situation, context, difficulty, content_pack_id, tags, published) VALUES
  (scenario2_id,
   'Taking Credit for Your Work',
   'In a team meeting, your colleague presents an idea you developed and shared with them yesterday. They don''t mention your contribution, and your supervisor seems impressed. No one else in the room knows it was your work.',
   'peer',
   2,
   peer_pack_id,
   ARRAY['conflict', 'trust', 'boundaries'],
   true);

  -- Options for Scenario 2
  INSERT INTO scenario_options (id, scenario_id, text, tags, immediate_outcome, longterm_outcome, risk_level, sort_order) VALUES
  (opt2_1, scenario2_id,
   'Speak up immediately: "Actually, that''s something I proposed to you yesterday. Happy to expand on it."',
   ARRAY['direct', 'assertive', 'immediate'],
   'Clarifies the record publicly. Your colleague looks embarrassed, and the room gets awkward.',
   'Protects your contribution but may be seen as confrontational. Relationship with colleague damaged.',
   'high',
   0),
  (opt2_2, scenario2_id,
   'Wait until after and speak privately: "I was surprised you didn''t mention we discussed this yesterday."',
   ARRAY['delayed', 'diplomatic', 'private'],
   'Avoids public confrontation. Colleague apologizes and says they''ll clarify with the supervisor.',
   'Maintains relationship while addressing the issue. Gives them a chance to make it right.',
   'low',
   1),
  (opt2_3, scenario2_id,
   'Let it go this time but make a mental note.',
   ARRAY['avoidant', 'indirect', 'passive'],
   'No immediate conflict. You feel frustrated but don''t show it.',
   'Issue unresolved. May happen again. You might resent the colleague over time.',
   'medium',
   2);

  -- Perspective shifts for Scenario 2
  INSERT INTO perspective_shifts (option_id, viewpoint, interpretation) VALUES
  (opt2_1, 'command', 'Appreciates honesty but notes the awkwardness. Wonders if it could have been handled more tactfully.'),
  (opt2_1, 'peer', 'Glad you spoke up, but that was intense. Your colleague won''t forget that.'),
  (opt2_2, 'command', 'Won''t know about the situation unless the colleague follows through. Trusts your professionalism.'),
  (opt2_2, 'peer', 'Smart move - you protected yourself without burning the bridge.'),
  (opt2_3, 'command', 'Unaware of the situation. Your contribution goes unrecognized.'),
  (opt2_3, 'peer', 'Respects that you didn''t make a scene, but worries you''re being taken advantage of.');

  -- ==============================================
  -- SCENARIO 3: Colleague Venting About Leadership
  -- ==============================================
  INSERT INTO scenarios (id, title, situation, context, difficulty, content_pack_id, tags, published) VALUES
  (scenario3_id,
   'Colleague Venting About Leadership',
   'A colleague approaches you privately and starts criticising your shared supervisor, calling their recent decisions "incompetent" and asking if you agree. You have your own frustrations, but you''re aware this could escalate.',
   'peer',
   1,
   comm_pack_id,
   ARRAY['trust', 'boundaries', 'loyalty'],
   true);

  -- Options for Scenario 3
  INSERT INTO scenario_options (id, scenario_id, text, tags, immediate_outcome, longterm_outcome, risk_level, sort_order) VALUES
  (opt3_1, scenario3_id,
   '"I hear your frustration, but I''m not comfortable discussing that. Have you brought it up directly with them?"',
   ARRAY['firm', 'boundary-setting', 'professional'],
   'Sets a clear boundary. Colleague backs off but seems a bit put off.',
   'Protects you from potential gossip and maintains professionalism. Colleague may not confide in you again.',
   'low',
   0),
  (opt3_2, scenario3_id,
   'Agree and share your own frustrations.',
   ARRAY['collaborative', 'venting', 'solidarity'],
   'Colleague feels validated and you bond over shared frustrations. Feels cathartic.',
   'Creates solidarity but also risk. If this gets back to leadership, you''re both implicated.',
   'high',
   1),
  (opt3_3, scenario3_id,
   'Listen without agreeing or disagreeing: "That sounds frustrating. What are you thinking of doing about it?"',
   ARRAY['neutral', 'listening', 'empathetic'],
   'Colleague vents but you don''t commit. They appreciate being heard.',
   'Allows venting without implicating yourself. Maintains relationship while staying professional.',
   'low',
   2),
  (opt3_4, scenario3_id,
   'Defend the supervisor: "I think they''re doing their best under difficult circumstances."',
   ARRAY['loyal', 'defensive', 'direct'],
   'Colleague stops venting immediately. They seem surprised and a bit shut down.',
   'Protects leadership but may damage trust with the colleague. They may see you as unapproachable.',
   'medium',
   3);

  -- Perspective shifts for Scenario 3
  INSERT INTO perspective_shifts (option_id, viewpoint, interpretation) VALUES
  (opt3_1, 'command', 'If they knew, they''d appreciate your professionalism and refusal to engage in gossip.'),
  (opt3_1, 'peer', 'Respects your boundary but might not come to you with concerns in the future.'),
  (opt3_2, 'command', 'If this gets back to them, you''ll be seen as disloyal or unprofessional.'),
  (opt3_2, 'peer', 'Feels validated and closer to you. Sees you as someone they can trust with frustrations.'),
  (opt3_3, 'command', 'Neutral approach protects you. Command wouldn''t see this as problematic.'),
  (opt3_3, 'peer', 'Appreciates that you listened without judgment. Feels supported but not encouraged.'),
  (opt3_4, 'command', 'Would appreciate your loyalty if they knew, but colleague now sees you differently.'),
  (opt3_4, 'peer', 'Sees you as defensive or a "yes person." May not confide in you again.');

  -- ==============================================
  -- SCENARIO 4: Mistake Under Time Pressure
  -- ==============================================
  INSERT INTO scenarios (id, title, situation, context, difficulty, content_pack_id, tags, published) VALUES
  (scenario4_id,
   'Mistake Under Time Pressure',
   'You''ve just realized you made an error in a report that''s due in 30 minutes. Fixing it will make you late. Your supervisor is already stressed about the deadline. The error is significant but not catastrophic.',
   'high-pressure',
   1,
   press_pack_id,
   ARRAY['accountability', 'pressure', 'time'],
   true);

  -- Options for Scenario 4
  INSERT INTO scenario_options (id, scenario_id, text, tags, immediate_outcome, longterm_outcome, risk_level, sort_order) VALUES
  (opt4_1, scenario4_id,
   'Fix the error and send it late with an explanation.',
   ARRAY['accountable', 'quality-focused', 'delayed'],
   'Report is late but accurate. Supervisor is annoyed about the delay but appreciates the correction.',
   'Shows you prioritise accuracy over speed. Builds trust in your work quality.',
   'low',
   0),
  (opt4_2, scenario4_id,
   'Send it on time and flag the error: "Attached, with one item that needs correction - details below."',
   ARRAY['transparent', 'immediate', 'accountable'],
   'Meets deadline and shows transparency. Supervisor can decide how to handle it.',
   'Demonstrates honesty and responsibility. Supervisor appreciates being informed.',
   'low',
   1),
  (opt4_3, scenario4_id,
   'Send it on time without mentioning the error and fix it later.',
   ARRAY['avoidant', 'risky', 'time-focused'],
   'Deadline met. Error goes unnoticed for now, but you''re anxious about discovery.',
   'High risk if discovered. Could damage trust significantly. Honesty would have been better.',
   'high',
   2);

  -- Perspective shifts for Scenario 4
  INSERT INTO perspective_shifts (option_id, viewpoint, interpretation) VALUES
  (opt4_1, 'command', 'Frustrated by the delay but respects your commitment to quality over speed.'),
  (opt4_1, 'peer', 'Impressed you took the time to fix it despite the pressure. Shows integrity.'),
  (opt4_2, 'command', 'Appreciates transparency and timely delivery. Trusts you more because you were upfront.'),
  (opt4_2, 'peer', 'Smart approach - you met the deadline and showed accountability.'),
  (opt4_3, 'command', 'Unaware for now, but if the error is discovered, trust will be seriously damaged.'),
  (opt4_3, 'peer', 'Understands the pressure but worries about what happens if it''s found out.');

  -- ==============================================
  -- SCENARIO 5: Exhausted Colleague Snaps at You
  -- ==============================================
  INSERT INTO scenarios (id, title, situation, context, difficulty, content_pack_id, tags, published) VALUES
  (scenario5_id,
   'Exhausted Colleague Snaps at You',
   'A usually friendly colleague snaps at you harshly over a minor question. They''ve been working long hours and look visibly exhausted. Other team members witnessed the exchange. It stung.',
   'close-quarters',
   2,
   peer_pack_id,
   ARRAY['empathy', 'conflict', 'fatigue'],
   true);

  -- Options for Scenario 5
  INSERT INTO scenario_options (id, scenario_id, text, tags, immediate_outcome, longterm_outcome, risk_level, sort_order) VALUES
  (opt5_1, scenario5_id,
   'Call it out immediately: "That was uncalled for. I was just asking a question."',
   ARRAY['assertive', 'direct', 'boundary-setting'],
   'They look taken aback and mutter an apology. The room is tense.',
   'Sets a clear boundary. They know not to do it again, but the relationship may be strained.',
   'medium',
   0),
  (opt5_2, scenario5_id,
   'Let it go in the moment, address it later: "Hey, you seemed stressed earlier. Everything okay?"',
   ARRAY['empathetic', 'delayed', 'compassionate'],
   'They apologize sincerely and explain they''re overwhelmed. You offer support.',
   'Preserves the relationship and shows empathy. They feel understood and regret the snap.',
   'low',
   1),
  (opt5_3, scenario5_id,
   'Ignore it entirely and avoid them for a while.',
   ARRAY['avoidant', 'passive', 'withdrawn'],
   'No immediate conflict. You feel hurt but don''t address it. Relationship feels awkward.',
   'Issue unresolved. Resentment may build. Colleague may not realize the impact.',
   'medium',
   2),
  (opt5_4, scenario5_id,
   'Respond with humor: "Wow, someone needs a coffee. I''ll come back later."',
   ARRAY['deflective', 'lighthearted', 'indirect'],
   'Diffuses the tension. They crack a small smile and apologize. Others relax.',
   'Maintains relationship without confrontation. May work if they respect humor in tough moments.',
   'low',
   3);

  -- Perspective shifts for Scenario 5
  INSERT INTO perspective_shifts (option_id, viewpoint, interpretation) VALUES
  (opt5_1, 'command', 'Appreciates you standing up for yourself, but notes the public nature of the exchange.'),
  (opt5_1, 'peer', 'Glad you called it out. They deserved that. But now things are awkward.'),
  (opt5_2, 'command', 'Won''t know about the private follow-up, but would respect the empathy if they did.'),
  (opt5_2, 'peer', 'Really mature approach. You handled that with grace and gave them a chance to make it right.'),
  (opt5_3, 'command', 'Unaware of the tension. May notice the distance between you two over time.'),
  (opt5_3, 'peer', 'Understands why you''re avoiding them, but wishes you''d addressed it.'),
  (opt5_4, 'command', 'Humor diffused it well. Shows emotional intelligence and flexibility.'),
  (opt5_4, 'peer', 'Perfect response - you didn''t escalate but also didn''t let it slide completely.');

END $$;

COMMENT ON TABLE scenarios IS 'Example scenarios successfully inserted';



