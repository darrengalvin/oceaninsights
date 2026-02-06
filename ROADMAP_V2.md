# Below the Surface - Version 2.0 Product Roadmap

**Date:** January 2026  
**Current Version:** 1.0 (Reading + Breathing + Mood)  
**Next Evolution:** Decision Training System

---

## Vision Statement

**From:** A content library with breathing exercises  
**To:** An offline decision-training system for communication, trust, and connection under constraint

**Not:** A wellbeing app, therapy tool, or diary  
**Is:** A mental drill system, simulator, and operational competence builder

---

## Design Constraints (Mission-Critical)

### ✅ MUST BE:
- Fully functional offline for months
- Safe to audit/inspect by command
- No sensitive personal data storage
- Anonymous and resettable
- Professional, operational language
- Training-focused, not therapy-focused

### ❌ MUST NOT HAVE:
- Free-text journaling
- Mood tracking with personal timestamps
- Gamification (points, badges, streaks)
- Push notifications
- Cloud sync of user behavior
- Emotion labels tied to individuals
- Anything resembling therapy

---

## V2.0 Core Systems

### 1. **Scenario Engine** (Non-Negotiable)

**What:**
- Short hypothetical workplace/military situations
- 3-5 response options per scenario
- Immediate consequence feedback
- Replayable with different choices

**Why:**
- Transforms passive reading into active rehearsal
- Works fully offline
- Feels intelligent without live AI

**Data Structure:**
```typescript
interface Scenario {
  id: string;
  title: string;
  situation: string; // 2-3 sentences
  context: 'hierarchy' | 'peer' | 'high-pressure' | 'close-quarters';
  difficulty: 1 | 2 | 3;
  options: Option[];
}

interface Option {
  id: string;
  text: string;
  tags: string[]; // e.g. ['direct', 'assertive', 'delayed']
  outcome: {
    immediate: string;
    longTerm: string;
    riskLevel: 'low' | 'medium' | 'high';
  };
  perspectiveShifts?: PerspectiveShift[];
}

interface PerspectiveShift {
  viewpoint: 'command' | 'peer' | 'subordinate';
  interpretation: string;
}
```

**Example Scenario:**

> **Title:** Interrupted in Briefing
> 
> **Situation:** You're presenting to command when a senior officer interrupts mid-sentence to challenge your data. You're confident in your numbers, but the tone suggests they're not open to discussion.
> 
> **Options:**
> 1. "Sir, if I could finish the slide, the source is cited there."
>    - Tag: `direct`, `assertive`
>    - Immediate: Maintains credibility, may increase tension
>    - Long-term: Establishes you don't back down, but may be remembered
>    - Risk: Medium
> 
> 2. Pause, acknowledge: "Good question. Let me address that now before continuing."
>    - Tag: `adaptive`, `respectful`
>    - Immediate: De-escalates, shows flexibility
>    - Long-term: Seen as collaborative, but may lose presentation momentum
>    - Risk: Low
> 
> 3. Continue without acknowledging: "As you'll see in the data..."
>    - Tag: `indirect`, `avoidant`
>    - Immediate: Avoids confrontation
>    - Long-term: May be seen as dismissive or weak
>    - Risk: High

---

### 2. **Choice Analytics (Aggregate Only)**

**What:**
- Track which response tags user selects
- Store counts only, no timestamps, no sequences
- Build response profile over time

**Why:**
- Enables personalization safely
- Shows patterns without logging sensitive data
- Audit-safe

**Storage:**
```typescript
interface UserResponseProfile {
  // Aggregate counts only
  communicationStyle: {
    direct: number;
    indirect: number;
    adaptive: number;
    avoidant: number;
    assertive: number;
    collaborative: number;
  };
  riskTolerance: {
    highRisk: number;
    mediumRisk: number;
    lowRisk: number;
  };
  conflictApproach: {
    immediate: number;
    delayed: number;
    escalated: number;
    deescalated: number;
  };
  // No timestamps, no scenario IDs, no text
  totalDecisions: number;
  profileVersion: string;
}
```

**User-Facing Display:**
- "You tend to prioritize calm clarification"
- "You rarely choose immediate confrontation"
- "You often adapt your approach based on context"

---

### 3. **Communication Protocol Library**

**What:**
- Step-by-step operational guides
- Feels like checklists, not therapy
- When to use / when not to use / common failures

**Why:**
- Highly acceptable in military context
- Reusable in real situations
- Builds competence

**Examples:**

#### **Protocol: Raising Concerns Up the Chain**
1. **Prepare:** Know exactly what you're asking for (decision, action, or just awareness)
2. **Time it:** Choose a moment when they're not mid-task
3. **Frame it:** "Sir/Ma'am, I have a concern about X. Is now a good time?"
4. **State it clearly:** One issue, one sentence
5. **Propose:** "I think Y might help. What do you think?"
6. **Accept the call:** Even if it's not what you wanted

**When to use:** Safety concerns, resource gaps, team friction  
**When NOT to use:** Minor complaints, personal preferences  
**Common failure:** Bringing the problem without a proposed solution

#### **Protocol: De-escalating Under Fatigue**
1. **Recognize:** Notice your irritation rising
2. **Pause:** Take 2 seconds before responding
3. **Label (internally):** "I'm tired, they're tired"
4. **Simplify:** Respond to content only, not tone
5. **Exit if needed:** "Let me think on that and come back"

**When to use:** Long shifts, close quarters, high stress  
**When NOT to use:** Genuine safety or behavioral issues  
**Common failure:** Assuming fatigue excuses harm

---

### 4. **Perspective Rotation Mode**

**What:**
- After a scenario choice, show how it lands from different viewpoints
- No user input required, just reading

**Why:**
- Builds empathy without asking for emotion
- Deepens learning
- Safe and private

**Example:**
User chooses: "I'll address it later privately"

**Perspectives shown:**
- **From Command:** "Shows discretion and professionalism. May wonder if it gets resolved."
- **From Peer:** "Appreciated not being called out publicly. May be waiting to see follow-through."
- **From Subordinate (if applicable):** "Notices you didn't react immediately. May see it as weakness or patience, depending on relationship."

---

### 5. **Adaptive Content Unlocking**

**What:**
- Deeper scenarios unlock based on choice patterns, not time
- Advanced protocols appear after foundational ones are explored
- Difficulty layers unlock based on demonstrated readiness

**Why:**
- Feels personalized without being creepy
- Encourages exploration
- Prevents overwhelm

**Unlock Logic Examples:**
- Unlock "High-Stakes Confrontation" scenarios after 10+ conflict scenarios completed
- Unlock "Command Communication" after showing preference for direct approaches
- Unlock "Fatigue Management" protocols after 15+ total decisions

---

## V2.0 Feature Priority

### **PHASE 1: Core Systems (v2.0)**
1. ✅ Scenario Engine (backend + UI)
2. ✅ Choice Analytics (local storage, aggregate)
3. ✅ Response Profile Screen
4. ✅ Communication Protocol Library (5-7 protocols)
5. ✅ Perspective Rotation (integrated into scenarios)

### **PHASE 2: Depth (v2.1)**
6. ✅ Difficulty Layers (same scenario, different constraints)
7. ✅ Content Packs (Conflict, Leadership, Trust, Close-Quarters)
8. ✅ Adaptive Unlocking System
9. ✅ Daily Drill Selector (stateless)

### **PHASE 3: Polish (v2.2)**
10. ✅ Reset & Control Tools (clear profile, reset aggregates)
11. ✅ Training Snapshots (periodic summaries)
12. ✅ Enhanced breathing exercises with more variety

---

## Admin Dashboard Requirements (v2.0)

### **Analytics (Aggregate, Anonymous)**

**Track:**
- Which scenarios are completed most
- Which options are selected most frequently (aggregate across all users)
- Drop-off points in scenario flows
- Content pack engagement
- Protocol access patterns

**Do NOT track:**
- Individual user choices over time
- Sequences of decisions
- Personal identifiers linked to choices
- Timestamps beyond "month aggregated"

**Purpose:**
- Learn what resonates
- Identify confusing scenarios
- Optimize content effectiveness
- Prioritize new content creation

**Dashboard Metrics:**
```typescript
interface AdminAnalytics {
  // Aggregated across all users
  topScenarios: { scenarioId: string; completions: number }[];
  optionDistribution: { 
    scenarioId: string; 
    options: { optionId: string; percentage: number }[] 
  }[];
  contentPackEngagement: { 
    packId: string; 
    views: number; 
    avgTimeSpent: number 
  }[];
  communicationStyleTrends: {
    direct: number;
    indirect: number;
    adaptive: number;
    // etc
  };
  // Monthly aggregates only
  month: string;
  totalActiveUsers: number;
  totalDecisionsMade: number;
}
```

---

## Content Strategy

### **Scenario Categories**
1. **Hierarchy & Authority**
   - Disagreeing upward
   - Receiving harsh feedback
   - Bypassed in decision-making
   
2. **Peer Dynamics**
   - Conflict in close quarters
   - Covering for others
   - Trust erosion
   
3. **Leadership Without Authority**
   - Influencing laterally
   - Setting boundaries
   - Maintaining standards
   
4. **High Pressure**
   - Fatigue-driven mistakes
   - Time-critical decisions
   - Public vs private correction
   
5. **Long-Term Relationships**
   - Accumulated resentment
   - Changing dynamics
   - Forgiveness and moving forward

### **Protocol Categories**
1. Communication Protocols
2. Conflict De-escalation
3. Self-Regulation Under Stress
4. Trust-Building Actions
5. Recovery After Rupture

---

## Technical Architecture Changes

### **New Database Tables (Supabase)**

```sql
-- Scenarios
CREATE TABLE scenarios (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  situation TEXT NOT NULL,
  context TEXT NOT NULL,
  difficulty INTEGER CHECK (difficulty BETWEEN 1 AND 3),
  content_pack_id UUID REFERENCES content_packs(id),
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scenario Options
CREATE TABLE scenario_options (
  id UUID PRIMARY KEY,
  scenario_id UUID REFERENCES scenarios(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  tags TEXT[] NOT NULL,
  immediate_outcome TEXT NOT NULL,
  longterm_outcome TEXT NOT NULL,
  risk_level TEXT CHECK (risk_level IN ('low', 'medium', 'high')),
  sort_order INTEGER NOT NULL
);

-- Perspective Shifts
CREATE TABLE perspective_shifts (
  id UUID PRIMARY KEY,
  option_id UUID REFERENCES scenario_options(id) ON DELETE CASCADE,
  viewpoint TEXT NOT NULL,
  interpretation TEXT NOT NULL
);

-- Communication Protocols
CREATE TABLE protocols (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  steps JSONB NOT NULL, -- Array of step objects
  when_to_use TEXT,
  when_not_to_use TEXT,
  common_failures TEXT,
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Content Packs
CREATE TABLE content_packs (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT,
  unlock_criteria JSONB, -- { totalDecisions: 10, tags: ['conflict'] }
  sort_order INTEGER
);

-- Anonymous Aggregate Analytics (Admin Only)
CREATE TABLE analytics_monthly (
  id UUID PRIMARY KEY,
  month DATE NOT NULL,
  scenario_completions JSONB, -- { scenarioId: count }
  option_selections JSONB, -- { optionId: count }
  communication_styles JSONB, -- { direct: count, indirect: count }
  total_active_users INTEGER,
  total_decisions INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### **Local Storage (Flutter/Hive)**

```dart
// User's response profile (stored locally only)
class UserResponseProfile {
  Map<String, int> communicationStyle;
  Map<String, int> riskTolerance;
  Map<String, int> conflictApproach;
  int totalDecisions;
  String profileVersion;
  DateTime lastUpdated;
}

// Scenario completion tracking (local only, for unlocks)
class ScenarioProgress {
  Set<String> completedScenarioIds;
  Map<String, int> categoryCompletions;
  int totalCompleted;
}

// Content pack sync metadata
class ContentPackMeta {
  String packId;
  DateTime lastSynced;
  int version;
  bool downloaded;
}
```

---

## UI/UX Changes

### **New Screens**

1. **Scenario Training Screen**
   - Situation display
   - Option cards (not buttons - cards feel less like a test)
   - Outcome reveal
   - Perspective rotation view
   - "Try Again" or "Next Scenario"

2. **Response Profile Screen**
   - Visual representation of tendencies
   - Simple language, non-judgmental
   - "Reset Profile" button
   - Privacy explanation

3. **Protocol Library Screen**
   - Category tabs
   - Step-by-step display
   - When to use / not use sections
   - Related scenarios link

4. **Daily Drill Screen**
   - One scenario suggestion
   - One protocol suggestion
   - One quick exercise
   - "Skip" and "Start" options

### **Navigation Changes**

**Home Screen becomes:**
```
┌─────────────────────────────┐
│  Today's Training           │
│  ├─ 1 Scenario              │
│  ├─ 1 Protocol              │
│  └─ 1 Exercise              │
├─────────────────────────────┤
│  Scenario Library           │
│  Protocol Library           │
│  Learn (Reading Content)    │
│  Breathing Exercises        │
├─────────────────────────────┤
│  Your Response Profile      │
│  Settings                   │
└─────────────────────────────┘
```

---

## Language Guidelines (Mission-Safe)

### **Use This Language:**
- Training, drills, practice, rehearsal
- Scenarios, protocols, procedures
- Communication skills, operational competence
- Decision-making, conflict management
- Team dynamics, professional relationships

### **Avoid This Language:**
- Therapy, healing, wellness, self-care
- Feelings, emotions (use "responses", "reactions")
- Mental health, diagnosis, treatment
- Safe space, vulnerability, sharing
- Personal growth (use "skill development")

---

## Success Metrics (v2.0)

### **Engagement**
- Average scenarios completed per week
- Protocol library access rate
- Return usage over 30+ days
- Content pack completion rates

### **Learning**
- Choice diversity (trying different options)
- Protocol→Scenario connection rate
- Difficulty progression
- Response profile evolution

### **Safety**
- Zero sensitive data leaks
- Audit approval maintained
- User-initiated resets used
- No complaints about privacy

---

## What This Is NOT

This is not:
- A mood tracker
- A journaling app
- A meditation app with scenarios added
- A gamified learning platform
- A social network
- A therapy substitute

This is:
- **An offline decision-training system for communication competence under operational constraint**

---

## Next Steps After v1.0 Launch

1. **Gather v1.0 feedback** (2-4 weeks of TestFlight)
2. **Content creation** (write 20-30 scenarios, 10 protocols)
3. **Admin dashboard** (analytics + scenario management)
4. **Scenario engine build** (mobile + admin)
5. **v2.0 beta** (TestFlight with new features)
6. **Iterate based on usage patterns**
7. **Full v2.0 launch**

---

## Timeline Estimate

- **v1.0 Launch:** January 2026 ✅
- **Content Creation:** February 2026
- **v2.0 Development:** March-April 2026
- **v2.0 Beta:** May 2026
- **v2.0 Launch:** June 2026

---

**End of Roadmap**



