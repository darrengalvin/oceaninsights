-- Example Protocols for Communication Guides
-- Run this after v2-scenarios-schema.sql

-- ==============================================
-- PROTOCOL 1: Raising Concerns Up the Chain
-- ==============================================
INSERT INTO protocols (
  title, 
  category, 
  description,
  steps,
  when_to_use,
  when_not_to_use,
  common_failures,
  published
) VALUES (
  'Raising Concerns Up the Chain',
  'communication',
  'A structured approach to bringing issues to leadership in a professional, solution-focused manner.',
  '[
    {
      "step": 1,
      "title": "Prepare",
      "description": "Know exactly what you''re asking for - a decision, an action, or just awareness. Clarity prevents confusion."
    },
    {
      "step": 2,
      "title": "Time it",
      "description": "Choose a moment when they''re not mid-task. Respect their current workload and stress level."
    },
    {
      "step": 3,
      "title": "Frame it",
      "description": "Open with: ''Sir/Ma''am, I have a concern about X. Is now a good time?'' Gives them control."
    },
    {
      "step": 4,
      "title": "State it clearly",
      "description": "One issue, one sentence. Don''t bury the concern in context or explanation."
    },
    {
      "step": 5,
      "title": "Propose",
      "description": "Suggest a solution if you have one. ''I think Y might help. What do you think?''"
    },
    {
      "step": 6,
      "title": "Accept the call",
      "description": "Even if it''s not what you wanted, acknowledge their decision professionally."
    }
  ]'::jsonb,
  'Use for safety concerns, resource gaps, team friction, or operational issues that need command awareness.',
  'Minor complaints, personal preferences, or issues you can resolve at your level. Don''t skip your immediate supervisor.',
  ARRAY[
    'Bringing the problem without a proposed solution',
    'Raising it at the worst possible time',
    'Being vague about what action you''re requesting',
    'Bypassing your immediate chain of command'
  ],
  true
);

-- ==============================================
-- PROTOCOL 2: De-escalating Under Fatigue
-- ==============================================
INSERT INTO protocols (
  title,
  category,
  description,
  steps,
  when_to_use,
  when_not_to_use,
  common_failures,
  published
) VALUES (
  'De-escalating Under Fatigue',
  'conflict',
  'How to manage rising frustration when exhaustion is affecting your responses.',
  '[
    {
      "step": 1,
      "title": "Recognize",
      "description": "Notice your irritation rising. Fatigue amplifies everything. Awareness is the first step."
    },
    {
      "step": 2,
      "title": "Pause",
      "description": "Take 2 seconds before responding. Count to three in your head. It breaks the automatic reaction."
    },
    {
      "step": 3,
      "title": "Label (internally)",
      "description": "Think: ''I''m tired, they''re tired.'' Separates the person from the behaviour."
    },
    {
      "step": 4,
      "title": "Simplify",
      "description": "Respond to content only, not tone. Strip emotion from your reply."
    },
    {
      "step": 5,
      "title": "Exit if needed",
      "description": "If you''re still escalating, say: ''Let me think on that and come back.'' No one argues with a pause."
    }
  ]'::jsonb,
  'Long shifts, close quarters, high stress, or when you notice yourself reacting disproportionately to minor issues.',
  'Genuine safety or behavioral issues that need immediate addressing. Fatigue doesn''t excuse real problems.',
  ARRAY[
    'Assuming fatigue excuses harmful behavior',
    'Skipping the pause and reacting immediately',
    'Letting exhaustion prevent necessary conversations',
    'Not recognizing your own fatigue signals'
  ],
  true
);

-- ==============================================
-- PROTOCOL 3: Receiving Criticism Without Reacting
-- ==============================================
INSERT INTO protocols (
  title,
  category,
  description,
  steps,
  when_to_use,
  when_not_to_use,
  common_failures,
  published
) VALUES (
  'Receiving Criticism Without Reacting',
  'self-regulation',
  'A method for processing feedback professionally, even when it feels unfair or harsh.',
  '[
    {
      "step": 1,
      "title": "Breathe",
      "description": "Your body will want to defend immediately. Take a slow breath before speaking."
    },
    {
      "step": 2,
      "title": "Listen fully",
      "description": "Don''t plan your defense while they''re talking. Just absorb what''s being said."
    },
    {
      "step": 3,
      "title": "Repeat back",
      "description": "''So you''re concerned about X because Y. Is that right?'' Shows you''re listening and clarifies intent."
    },
    {
      "step": 4,
      "title": "Ask for specifics",
      "description": "If feedback is vague, ask: ''Can you give me an example?'' Turns criticism into actionable information."
    },
    {
      "step": 5,
      "title": "Acknowledge",
      "description": "Even if you disagree, say: ''I hear you. Let me consider that.'' Buys you time to process."
    },
    {
      "step": 6,
      "title": "Reflect later",
      "description": "After 24 hours, revisit the feedback. Some of it might be valid once the sting fades."
    }
  ]'::jsonb,
  'Performance reviews, post-incident debriefs, or when receiving unexpected negative feedback from leadership or peers.',
  'Abusive or disrespectful criticism. This protocol is for professional feedback, not personal attacks.',
  ARRAY[
    'Defending immediately without listening',
    'Taking all criticism as personal attack',
    'Dismissing feedback without reflection',
    'Not asking clarifying questions'
  ],
  true
);

-- ==============================================
-- PROTOCOL 4: Clarifying Miscommunication
-- ==============================================
INSERT INTO protocols (
  title,
  category,
  description,
  steps,
  when_to_use,
  when_not_to_use,
  common_failures,
  published
) VALUES (
  'Clarifying Miscommunication',
  'communication',
  'How to address misunderstandings quickly before they escalate into larger issues.',
  '[
    {
      "step": 1,
      "title": "Assume good intent",
      "description": "Start with the belief that the miscommunication was unintentional. Approach with curiosity, not accusation."
    },
    {
      "step": 2,
      "title": "Name it early",
      "description": "''I think we might have miscommunicated about X.'' Neutral framing prevents defensiveness."
    },
    {
      "step": 3,
      "title": "Share your understanding",
      "description": "''My understanding was Y. What was yours?'' Reveals where the wires crossed."
    },
    {
      "step": 4,
      "title": "Listen without interrupting",
      "description": "Let them explain fully. The gap might be smaller than you think, or bigger in a different way."
    },
    {
      "step": 5,
      "title": "Align going forward",
      "description": "''So moving forward, we''re agreed on Z?'' Creates shared clarity for next steps."
    }
  ]'::jsonb,
  'When expectations don''t match reality, tasks are misunderstood, or instructions were unclear. Best used as soon as you notice the disconnect.',
  'When someone intentionally misled you or the issue is about dishonesty rather than misunderstanding.',
  ARRAY[
    'Waiting too long to address it',
    'Assuming the other person should have known better',
    'Not checking your own assumptions',
    'Focusing on blame instead of clarity'
  ],
  true
);

-- ==============================================
-- PROTOCOL 5: Setting Boundaries Without Conflict
-- ==============================================
INSERT INTO protocols (
  title,
  category,
  description,
  steps,
  when_to_use,
  when_not_to_use,
  common_failures,
  published
) VALUES (
  'Setting Boundaries Without Conflict',
  'trust',
  'How to establish and maintain professional boundaries in a respectful, non-confrontational manner.',
  '[
    {
      "step": 1,
      "title": "Know your limit",
      "description": "Before speaking, be clear on what you''re willing and unwilling to do. Vague boundaries are unenforceable."
    },
    {
      "step": 2,
      "title": "Use ''I'' statements",
      "description": "''I''m not comfortable with that'' or ''I need to prioritize X.'' Owns your position without blaming."
    },
    {
      "step": 3,
      "title": "Offer an alternative",
      "description": "''I can''t do X, but I can do Y'' or ''Let''s talk to Z about that.'' Shows you''re still helpful."
    },
    {
      "step": 4,
      "title": "Don''t over-explain",
      "description": "A simple ''no'' with brief context is enough. Over-justifying invites negotiation."
    },
    {
      "step": 5,
      "title": "Stay calm",
      "description": "If they push back, repeat your boundary calmly without escalating. ''I understand, and I''m still not able to do that.''"
    },
    {
      "step": 6,
      "title": "Follow through",
      "description": "If you set a boundary, honor it. Inconsistency teaches people your boundaries don''t matter."
    }
  ]'::jsonb,
  'When requests exceed your capacity, violate your values, or when someone repeatedly oversteps professional lines.',
  'Emergency situations, direct orders within your role, or when flexibility is part of the job expectation.',
  ARRAY[
    'Apologizing excessively for having boundaries',
    'Negotiating your own limit after stating it',
    'Setting boundaries only when angry',
    'Not enforcing boundaries consistently'
  ],
  true
);

COMMENT ON TABLE protocols IS 'Example protocols successfully inserted';

