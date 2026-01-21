# GPT Content Generation Prompt

## Instructions

Copy this entire prompt and paste into ChatGPT (GPT-4 or Claude). Adjust the `BATCH_SIZE`, `BATCH_INDEX`, and `SEED` at the bottom before each run.

---

You are GPT-5.2. Act as a content architect for a **growth-focused "wellness library"** designed for **military personnel, veterans, and partner/family members**.

## GOAL
Generate a large catalogue of tappable options for predictive text that feels **positive, educational, and empowering** — NOT like a symptom checker. Avoid planting negative ideas. Use **UK English**.

## OUTPUT FORMAT (STRICT JSON)
Return ONLY valid JSON (no markdown, no commentary). Schema:

```json
{
  "meta": {
    "batch_size": 50,
    "batch_index": 1,
    "seed": "run-001",
    "notes": "First batch focusing on relationships",
    "next_cursor": "seed=run-001;batch=2;salt=abc123"
  },
  "items": [
    {
      "id": "relationships.understand.building-trust",
      "domain": "Relationships & Connection",
      "pillar": "Understand",
      "label": "Building Trust in Relationships",
      "microcopy": "Trust takes time to build through consistent small actions. You deserve relationships where you feel safe.",
      "audience": "any",
      "disclosure_level": 1,
      "sensitivity": "normal",
      "keywords": ["trust", "safety", "relationships", "partnership", "honesty", "communication", "connection", "reliability"]
    }
  ]
}
```

## DOMAIN LIST (MUST USE EXACT NAMES)

**CRITICAL:** The "domain" field MUST be one of these EXACT strings:

1. **"Relationships & Connection"**
   - Partners, friendships, connections, dating, marriage, intimacy, communication in relationships

2. **"Family, Parenting & Home Life"**
   - Parents, children, home, parenting, caring responsibilities, family dynamics, siblings

3. **"Identity, Belonging & Inclusion"**
   - Self-understanding, identity, belonging, discrimination, LGBTQ+, gender, race, culture, values

4. **"Grief, Change & Life Events"**
   - Loss, bereavement, divorce, separation, life transitions, major changes, endings

5. **"Calm, Confidence & Emotional Skills"**
   - Stress management, anxiety, emotions, confidence, self-esteem, emotional regulation, coping

6. **"Sleep, Energy & Recovery"**
   - Sleep quality, insomnia, fatigue, rest, recovery, energy management, burnout prevention

7. **"Health, Injury & Physical Wellbeing"**
   - Physical health, injury recovery, chronic pain, disability, fitness, body image

8. **"Money, Housing & Practical Life"**
   - Financial stress, budgeting, housing, debt, practical life skills, daily management

9. **"Work, Purpose & Service Culture"**
   - Career, work stress, purpose, meaning, military culture, hierarchy, mission, job satisfaction

10. **"Leadership, Boundaries & Communication"**
    - Leading others, setting boundaries, communication skills, conflict resolution, assertiveness

11. **"Transition, Resettlement & Civilian Life"**
    - Leaving military, resettlement, civilian transition, identity shift, career change, adjustment

## THE REFRAME (NON-NEGOTIABLE)

### ❌ BAD (Problem-Focused):
- "My partner doesn't listen"
- "I'm struggling with anxiety"
- "I feel like a failure"
- "My relationship is toxic"

### ✅ GOOD (Growth-Focused):
- "Improving communication at home"
- "Finding calm under pressure"
- "Building confidence"
- "Understanding healthy relationships"

### Rules:
- Do NOT write items as problems or complaints
- Write as **learning intentions** and **growth areas**
- Use affirming language: "Many people find...", "It's common to...", "You're not alone..."
- Always end microcopy with hope or a next step

## PILLARS + DISCLOSURE RULES

### 1. Understand (35% of content)
- **disclosure_level:** 1
- **sensitivity:** mostly "normal"
- Educational, normalising, "how it works" topics
- Examples: "How trust is built", "What boundaries look like", "How stress affects sleep"

### 2. Grow (35% of content)
- **disclosure_level:** 1-2
- **sensitivity:** mostly "normal", some "sensitive"
- Practical skills and strategies framed positively
- Examples: "Repairing after conflict", "Reconnecting after time apart", "Planning for change"

### 3. Reflect (20% of content)
- **disclosure_level:** 2
- **sensitivity:** mostly "normal"
- Optional self-discovery prompts phrased gently as questions
- Examples: "What helps you feel respected?", "When do you feel most like yourself?"

### 4. Support (10% of content)
- **disclosure_level:** 3
- **sensitivity:** "sensitive" or "urgent"
- Hidden until user chooses. Phrase as "If you're in a difficult situation..." / "When things feel unsafe..."
- Keep it **non-graphic**, non-diagnostic, non-instructional
- For urgent items: generic wording about contacting support (no phone numbers in labels)

## MILITARY CONTEXT (IMPORTANT)

Include natural themes relevant to service life without operational detail:

### Service-Specific Topics:
- Deployments and separation
- Postings and relocations
- Shift work and irregular hours
- Unit culture and hierarchy
- Resettlement and transition
- Identity shifts after leaving service

### Universal Life Events (framed positively):
- Relationship changes (divorce/separation, co-parenting)
- Bereavement and loss
- Caring responsibilities
- Gender identity exploration
- Coming out
- Discrimination concerns
- Loneliness and isolation
- Burnout and exhaustion
- Injury and recovery
- Financial pressure

### Avoid:
- Operational details
- Anything that encourages wrongdoing
- Politically sensitive topics

## QUALITY CONSTRAINTS

### Per Item:
- **Label:** 4-9 words, title case, no emojis
- **Microcopy:** 1-2 sentences, max 240 characters, normalising and hopeful
- **Keywords:** 8-16 items, lowercase, include synonyms and search-friendly terms
- **ID format:** `{domain-slug}.{pillar}.{short-slug}`
  - Example: `relationships.understand.building-trust`
  - Must be unique and stable

### Distribution Targets:
- **Pillars:** Understand 35%, Grow 35%, Reflect 20%, Support 10%
- **Audience:** any 55%, service_member 20%, partner_family 15%, veteran 10%
- **Sensitivity:** normal 80%, sensitive 18%, urgent 2% (only in Support)

### Audience Types:
- `any` - Everyone (55% of content)
- `service_member` - Currently serving military (20%)
- `veteran` - Former military (10%)
- `partner_family` - Partners, spouses, family members (15%)

### Sensitivity Levels:
- `normal` - Standard content (80%)
- `sensitive` - Handle with care, personal topics (18%)
- `urgent` - Crisis-related, immediate help (2%, Support pillar only)

## DEDUP & STABILITY

- **No duplicate labels** across all batches
- **IDs must be stable** and human-readable
- Use lowercase, hyphens only in IDs
- If generating multiple batches, ensure labels don't repeat

## DOMAIN GUIDANCE

### Distribution Suggestion:
Try to balance across domains. Each domain should get roughly equal content over multiple batches.

### Domain-Specific Examples:

**Relationships & Connection:**
- Understanding attachment styles
- Improving communication patterns
- Recognising healthy vs unhealthy dynamics
- Rebuilding trust after hurt
- Managing conflict constructively

**Family, Parenting & Home Life:**
- Co-parenting after separation
- Managing family expectations
- Balancing work and home
- Supporting children through change
- Setting boundaries with family

**Identity, Belonging & Inclusion:**
- Exploring your values
- Finding your community
- Navigating discrimination
- Coming out and authenticity
- Cultural identity and belonging

**Grief, Change & Life Events:**
- Processing loss and endings
- Adjusting to major life changes
- Moving through divorce/separation
- Coping with bereavement
- Finding meaning after loss

**Calm, Confidence & Emotional Skills:**
- Managing anxiety and stress
- Building self-confidence
- Emotional regulation techniques
- Overcoming self-doubt
- Finding calm in chaos

**Sleep, Energy & Recovery:**
- Improving sleep quality
- Managing fatigue and exhaustion
- Recovery after burnout
- Energy management strategies
- Understanding sleep science

**Health, Injury & Physical Wellbeing:**
- Recovery from injury
- Managing chronic pain
- Body image and acceptance
- Physical health and mental health link
- Adapting to physical changes

**Money, Housing & Practical Life:**
- Managing financial stress
- Budgeting and planning
- Breaking avoidance around money
- Accessing support with housing
- Building financial confidence

**Work, Purpose & Service Culture:**
- Finding purpose and meaning
- Navigating workplace stress
- Understanding military culture
- Career development
- Dealing with hierarchy

**Leadership, Boundaries & Communication:**
- Leading with authenticity
- Setting clear boundaries
- Assertive communication
- Resolving conflicts
- Giving and receiving feedback

**Transition, Resettlement & Civilian Life:**
- Leaving military service
- Identity after the military
- Adjusting to civilian life
- Career transition planning
- Finding new purpose

---

## RUN PARAMETERS

**Set these before each run:**

```json
{
  "BATCH_SIZE": 50,
  "BATCH_INDEX": 1,
  "SEED": "run-001",
  "EXCLUDE_IDS": [],
  "EXCLUDE_LABELS": []
}
```

- **BATCH_SIZE:** Number of items to generate (recommend 50-100)
- **BATCH_INDEX:** Which batch this is (1, 2, 3...)
- **SEED:** Identifier for this generation run
- **EXCLUDE_IDS:** Array of IDs already generated (to avoid duplicates)
- **EXCLUDE_LABELS:** Array of labels already used (to avoid duplicates)

## EXCLUSION RULE
If an ID is in EXCLUDE_IDS or a label matches EXCLUDE_LABELS (case-insensitive), do not include it.

## NEXT CURSOR
Set `meta.next_cursor` to: `"seed={SEED};batch={BATCH_INDEX+1};salt={random}"`

---

## NOW GENERATE

**Generate exactly BATCH_SIZE items following all rules above.**

Return ONLY the JSON object. No markdown, no commentary.

