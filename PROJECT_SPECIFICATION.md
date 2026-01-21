# Ocean Insight - Mobile Mental Health Application
## Technical Specification Document

**Version:** 1.0  
**Date:** January 2026  
**Target Audience:** Military personnel, veterans, and their families  
**Primary Use Case:** Offline-first mental health companion for deployed submariners

---

## 1. Executive Summary

Ocean Insight is a comprehensive mental health and wellbeing mobile application designed specifically for military personnel who operate in environments with limited or no internet connectivity. The application provides evidence-based mental health resources, personalised AI-driven insights, guided breathing exercises, mood tracking, educational content, and calm audio—all functioning completely offline after initial setup.

The system consists of three main components:
1. **Mobile Application** (Flutter - iOS/Android/Web)
2. **Admin Content Management System** (Next.js)
3. **Backend Infrastructure** (Supabase PostgreSQL + AI API integration)

### Key Differentiators
- **Privacy-first design**: No GPS, no camera, minimal data collection
- **Fully offline capable**: Works indefinitely without internet after first sync
- **OPSEC-safe**: Designed for operational security requirements
- **Evidence-based**: Includes breathing techniques used by Navy SEALs
- **Charitable component**: £1 from every download goes to Submariners Charity

---

## 2. Technical Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     SYSTEM ARCHITECTURE                          │
└─────────────────────────────────────────────────────────────────┘

Mobile App (Flutter)
├── Hive Local Database (Offline Storage)
├── State Management (Provider)
└── Supabase Client (Sync when online)
    │
    ├── Supabase PostgreSQL Database
    │   ├── Content Management Tables
    │   ├── Learn Articles
    │   ├── Navigation System
    │   └── Row Level Security (RLS)
    │
    └── OpenAI API Integration
        └── Personalised AI Insights

Admin Panel (Next.js)
├── Supabase Admin Client
├── Content Creation UI
├── Bulk Import System
└── Analytics Dashboard
```

---

## 3. Platform Requirements

### 3.1 Mobile Application

**Framework:** Flutter 3.2.0+  
**Language:** Dart 3.2.0+  
**Target Platforms:**
- iOS 13.0+
- Android 8.0+ (API Level 26+)
- Web (Progressive Web App for demonstrations)

**Key Dependencies:**
- `hive` & `hive_flutter` - Local offline database
- `provider` - State management
- `supabase_flutter` - Backend integration & sync
- `just_audio` - Audio playback (offline audio files)
- `google_fonts` - Typography (Outfit font family)
- `lucide_icons` - Iconography
- `http` - API communication for AI features
- `flutter_animate` - Animation framework
- `url_launcher` - External link handling

### 3.2 Admin Panel

**Framework:** Next.js 14  
**Language:** TypeScript  
**Styling:** Tailwind CSS  
**Port:** 3002 (development)

**Key Dependencies:**
- `@supabase/supabase-js` - Database operations
- `@supabase/ssr` - Server-side rendering support
- `lucide-react` - Icons
- `react` & `react-dom` - UI framework

### 3.3 Backend Infrastructure

**Database:** Supabase (PostgreSQL)  
**Authentication:** Supabase Row Level Security  
**AI Service:** OpenAI API (GPT-4o-mini model)  
**API Base URL:** Configurable OpenAI-compatible endpoint

---

## 4. Core Features Specification

### 4.1 Offline-First Data Management

**Content Synchronisation System:**

The application implements an intelligent sync mechanism:

1. **Initial Sync**: On first launch (requires internet)
   - Downloads all published content from Supabase
   - Caches locally in Hive database
   - Stores version metadata
   - Saves embedded audio files

2. **Background Sync** (when online):
   - Checks `sync_metadata` table for version updates
   - Only downloads if server version > local version
   - Silent background operation
   - Non-blocking for user

3. **Manual Refresh**:
   - User-triggered sync via refresh button
   - Shows "Content updated" notification
   - Updates last sync timestamp

4. **Offline Operation**:
   - All features work without internet
   - Reads from local Hive cache
   - No degradation in functionality
   - Mood tracking persists locally

**Technical Implementation:**
- Service: `ContentService` (Singleton pattern)
- Storage: Hive boxes (`navigate_content`, `user_data`, `mood_entries`, `settings`)
- Sync Detection: Version comparison via `sync_metadata` table

---

### 4.2 Guided Breathing Exercises

**Four Evidence-Based Techniques:**

#### 4.2.1 Box Breathing (Navy SEAL Technique)
- Pattern: 4-4-4-4 (inhale-hold-exhale-hold)
- Visual: Animated box with progress indicator
- Audio: Phase-specific sounds (breath in, hold, breath out)
- Use case: High-stress situations, panic attacks
- Recommended: 4 cycles

#### 4.2.2 Relaxing Breath
- Pattern: 4-6 (inhale-exhale)
- Visual: Expanding/contracting circle
- Audio: Gentle breathing sounds
- Use case: General stress reduction, sleep preparation
- Recommended: 4 cycles

#### 4.2.3 Energising Breath
- Pattern: 2-2 (quick inhale-exhale)
- Visual: Pulsing circle animation
- Audio: Continuous looping breath audio
- Use case: Increase alertness, morning routine
- Recommended: 4 cycles

#### 4.2.4 4-7-8 Calming (Dr. Andrew Weil Method)
- Pattern: 4-7-8 (inhale-hold-exhale)
- Visual: Smooth breathing circle
- Audio: Extended breathing sounds
- Use case: Anxiety, insomnia, emotional regulation
- Recommended: 4 cycles

**Technical Features:**
- Real-time countdown timer
- Cycle tracking (X of Y)
- Expandable "Learn More" sections with:
  - What it is
  - Why it helps (neuroscience explanation)
  - Benefits list
  - How to use
  - Frequency recommendations
- Custom animation controller for visual guidance
- Audio player management (pre-loaded assets)
- Stop/pause functionality

**Audio Assets Required:**
- `breath-in-242641.mp3`
- `breath-out-242642.mp3`
- `heart-beat-137135.mp3`
- `breath-in-and-out-38694.mp3`

---

### 4.3 Mood Tracking & Assessment

**OPSEC-Safe Mood Logging:**

The mood tracking system is designed to be completely private and non-descriptive to maintain operational security.

**Mood Levels:**
- 5 emoji-based levels (😄 😊 😐 😔 😢)
- Simple one-tap interaction
- No text journaling (OPSEC requirement)
- Timestamps recorded locally only

**Features:**
- **Daily Check-in**: One mood entry per day
- **Streak Tracking**: Consecutive days of logging
- **7-Day Average**: Mood trend calculation
- **Recent History**: 14-day visual history
- **Stats Dashboard**:
  - Current streak (days)
  - 7-day average (out of 5)
  - Total check-ins count

**Data Storage:**
- Local only (Hive box: `mood_entries`)
- No server transmission
- Never leaves device
- Cannot be accessed remotely

**Technical Implementation:**
- Provider: `MoodProvider`
- State management for real-time updates
- Date-based grouping and filtering
- Streak calculation algorithm

---

### 4.4 Navigate - Intelligent Content Discovery System

**Overview:**

Navigate is a sophisticated content management system that provides contextually relevant mental health guidance organised by life domains and cognitive pillars.

**11 Life Domains:**

1. **Relationships & Connection** - Partners, friendships, intimacy
2. **Family, Parenting & Home Life** - Family dynamics, parenting
3. **Identity, Belonging & Inclusion** - Self-understanding, LGBTQ+, diversity
4. **Grief, Change & Life Events** - Loss, transitions, major changes
5. **Calm, Confidence & Emotional Skills** - Stress, anxiety, emotional regulation
6. **Sleep, Energy & Recovery** - Insomnia, fatigue, rest
7. **Health, Injury & Physical Wellbeing** - Physical health, recovery
8. **Money, Housing & Practical Life** - Financial stress, practical skills
9. **Work, Purpose & Service Culture** - Career, military culture, meaning
10. **Leadership, Boundaries & Communication** - Leading, boundaries, conflict
11. **Transition, Resettlement & Civilian Life** - Leaving service, resettlement

**Four Content Pillars:**

1. **Understand (35%)** - Educational content, normalising, "how it works"
   - Disclosure Level: 1 (low)
   - Examples: "How trust is built", "Why stress affects sleep"

2. **Grow (35%)** - Practical skills and strategies
   - Disclosure Level: 1-2 (low to medium)
   - Examples: "Repairing after conflict", "Setting healthy boundaries"

3. **Reflect (20%)** - Self-discovery prompts
   - Disclosure Level: 2 (medium)
   - Examples: "What helps you feel respected?", "When do you feel most yourself?"

4. **Support (10%)** - Crisis resources (hidden initially)
   - Disclosure Level: 3 (high)
   - Sensitivity: sensitive/urgent
   - Non-graphic, non-diagnostic guidance

**Content Structure:**

Each content item includes:
- **Label**: 4-9 words, title case
- **Microcopy**: 1-2 sentences, normalising tone
- **Audience Filter**: any, service_member, veteran, partner_family
- **Sensitivity Level**: normal, sensitive, urgent
- **Keywords**: 8-16 searchable terms

**Deep Content Sections:**
- **Understand Section**: Title, body text, key insights (bullet points)
- **Reflect Section**: Gentle prompts (phrased as questions)
- **Grow Section**: Title, actionable steps (JSON array with action + detail)
- **Support Section**: Intro, resources (JSON array with name, description, contact)
- **Affirmation**: Positive closing statement

**Database Schema:**
```sql
- domains (life areas)
- content_items (tappable options)
- content_details (deep content)
- content_connections (related items)
- journeys (curated pathways)
- sync_metadata (version control)
```

**Search & Filtering:**
- Keyword search across labels, microcopy, keywords
- Domain filtering
- Pillar filtering
- Audience filtering
- Related content suggestions

---

### 4.5 Learn - Educational Library

**Three Content Categories:**

#### Brain Science
Articles explaining the neuroscience behind stress, anxiety, emotions, and behaviour.

#### Psychology
Content on emotional validation, understanding feelings, cognitive patterns.

#### Life Situations
Relatable scenarios organised by:
- Age brackets (18-24, 25-34, 35-44, 45-54, 55+)
- Audience type (any, service_member, veteran, partner_family)

**Article Structure:**
- Title & summary
- Category & read time (minutes)
- Structured sections (JSON):
  - Heading
  - Content paragraphs
  - Tips/callouts
- Key takeaways (bullet points)
- View count tracking
- Published/draft status

**Database Schema:**
```sql
- learn_articles (metadata)
- learn_article_content (structured content)
```

**Features:**
- Offline reading after sync
- Reading progress indication
- Related articles suggestions
- Category filtering

---

### 4.6 Calm Music Player

**Embedded Relaxing Audio:**

Pre-loaded audio files for offline playback:
- Ocean waves
- Heartbeat (binaural)
- Submarine ambient sounds
- White noise options

**Player Features:**
- Background playback
- Volume control
- Looping options
- Sleep timer (future enhancement)
- Minimal battery usage

**Technical Implementation:**
- `just_audio` package
- Pre-cached audio assets
- Audio focus management
- Notification controls

---

### 4.7 Daily Affirmations & Gratitude

**Affirmations System:**
- Curated positive statements
- Daily rotation algorithm
- Military-specific affirmations
- Customisable favourites
- Share functionality

**Gratitude Practice:**
- Simple gratitude prompts
- No text entry required (OPSEC)
- Visual acknowledgement system
- Streak tracking

**Data Storage:**
- Local only (Hive)
- No cloud sync
- Private to device

---

### 4.8 Inspirational Quotes

**Quote Library:**
- Curated motivational quotes
- Military & veteran-focused content
- Daily quote rotation
- Save favourites
- Share functionality

**Features:**
- Category filtering
- Random quote generator
- Bookmark system
- Offline access

---

### 4.9 Goals & Action Planning

**Goal Setting System:**

Users can set and track personal goals across categories:
- Relationships
- Health & fitness
- Learning & development
- Work & purpose
- Emotional wellbeing

**Features:**
- Goal creation wizard
- Progress tracking
- Reminder system (local notifications)
- Milestone celebrations
- Reflection prompts

**Goal Flow:**
1. Choose goal category
2. Define specific goal
3. Set timeframe
4. Break into smaller steps
5. Track progress
6. Reflect on completion

**Data Storage:**
- Local Hive database
- Never sent to server
- Exportable (future)

---

### 4.10 AI Personalisation System

**Overview:**

The AI personalisation feature generates a "What I'm Hearing" summary based on user's profile selections during onboarding or profile updates.

**Input Collection (Chip-Based Selection):**

Users select from pre-defined options (chips) across four categories:

1. **Describe Myself As:**
   - Examples: "Currently serving", "Veteran", "Partner/family member"

2. **I Sometimes Struggle With:**
   - Examples: "Sleep", "Stress", "Relationships", "Transitions"

3. **I'm Interested in Learning About:**
   - Examples: "Emotional regulation", "Communication skills", "Sleep science"

4. **My Current Goals Include:**
   - Examples: "Better sleep", "Managing stress", "Improving relationships"

**AI Processing:**

**API Integration:**
- OpenAI-compatible API (default: GPT-4o-mini)
- API key injected at build time: `--dart-define=OPENAI_API_KEY=xxx`
- Configurable base URL for alternative providers
- Temperature: 0.7
- Max tokens: 800

**Structured Prompt:**

The AI is instructed to:
- Use UK English
- Be warm and validating
- NOT over-interpret or invent backstory
- Avoid absolute statements
- Offer 2-3 plausible interpretations
- Ask ONE gentle question
- Provide 2-3 concrete, low-effort next steps
- Avoid therapy-speak

**Audience-Specific Guidance:**
- **Serving**: Time pressure, privacy concerns, routines, performance
- **Deployed**: Distance from home, disrupted sleep, connection challenges
- **Veteran**: Transition, identity, civilian adjustment
- **Alongside** (supporter): Boundaries, communication, avoiding burnout
- **Young Person**: Simpler language, reassuring tone, trusted adult mention

**Output Structure:**

```
SUMMARY: (2-4 sentences)

THIS MIGHT BE PART OF IT:
• (interpretation 1)
• (interpretation 2)
• (interpretation 3)

QUICK QUESTION: (1 sentence ending with ?)

SMALL NEXT STEPS:
• (step 1)
• (step 2)
• (step 3, optional)
```

**Fallback Mechanism:**

If AI API is unavailable:
- Generates sensible fallback response
- Uses main struggle and goal from selections
- Generic but supportive messaging
- No error shown to user

**Privacy & Security:**
- API calls only when user explicitly triggers
- No persistent storage of API responses (optional local cache)
- API key never exposed in client code (build-time injection)
- User can opt-out of AI features

**Technical Implementation:**
- Service: `AIService` class
- Build-time key injection via `--dart-define`
- HTTP client for API communication
- Structured response parsing
- Error handling with graceful degradation

---

### 4.11 User Profile & Onboarding

**First-Time Onboarding Flow:**

1. **Welcome Screen** - Introduction to app purpose
2. **Privacy Explanation** - What data is/isn't collected
3. **Name Collection** - First name only
4. **Age Bracket** - Broad categories (18-24, 25-34, 35-44, 45-54, 55+)
5. **Audience Selection** - Service member, veteran, partner/family, young person
6. **Optional AI Profile** - Chip-based selections for personalisation

**Profile Management:**
- Edit name
- Change age bracket
- Update audience type
- Retake AI profile quiz
- View personalised insights

**Settings:**
- Theme selection (multiple palettes)
- API key management (for AI features)
- Privacy policy access
- About & contact information
- Data export (future)

**Data Minimalism:**
- First name only (no surname)
- Age bracket (not exact age)
- No email required
- No phone number
- No location data
- No camera access

---

## 5. Admin Content Management System

### 5.1 Overview

A Next.js-based CMS for content creation, editing, publishing, and analytics.

**Access:** http://localhost:3002 (development)  
**Authentication:** Supabase service role key (server-side only)

### 5.2 Features

#### Dashboard
- Total content items count
- Published vs draft statistics
- Domain distribution
- Recent activity feed
- Sync metadata version

#### Content Management
- **List View**: All content items with filters
- **Create New**: Full content editor
- **Edit Existing**: Modify any field
- **Publish/Unpublish**: Toggle visibility in app
- **Delete**: Remove content (with confirmation)

#### Domain Management
- Add/edit/remove life domains
- Reorder display order
- Set icons (Material Icons codes)
- Activate/deactivate domains

#### Learn Articles
- Create/edit educational articles
- Structured section editor (JSON)
- Category assignment
- Read time estimation
- Publish workflow

#### Journey Builder (Future)
- Create curated content pathways
- Sequence content items
- Audience targeting
- Progress tracking

#### Bulk Import System
- **GPT Content Generation**: Documented prompt system
- **JSON Import API**: `/api/import`
- **Batch Processing**: Import 50-100 items at once
- **Validation**: Schema validation before insert
- **Duplicate Detection**: Checks for existing slugs/labels

#### Analytics
- View counts per content item
- Popular domains
- Pillar distribution
- Audience breakdown

### 5.3 Content Creation Workflow

1. **Generate Content** (Optional)
   - Use GPT prompt (provided in `gpt-content-generator.md`)
   - Generate JSON with structured content
   - Save to file

2. **Import or Create**
   - Bulk import JSON via API, OR
   - Manually create in UI

3. **Review & Edit**
   - Check content quality
   - Edit any fields
   - Add related content connections

4. **Publish**
   - Toggle `is_published` flag
   - Content immediately available for sync

5. **App Syncs**
   - Mobile app detects version change
   - Downloads new/updated content
   - Caches locally

### 5.4 API Endpoints

**Admin API Routes:**

```
GET  /api/stats - Dashboard statistics
GET  /api/content - List all content items
GET  /api/content/[id] - Get single content item
POST /api/content - Create new content
PUT  /api/content/[id] - Update content
DELETE /api/content/[id] - Delete content

GET  /api/domains - List all domains
POST /api/domains - Create domain
PUT  /api/domains/[id] - Update domain

POST /api/import - Bulk import content (JSON)

GET  /api/learn - List learn articles
POST /api/learn - Create article
PUT  /api/learn/[id] - Update article

POST /api/generate - AI content generation helper
```

### 5.5 Security

**Row Level Security (RLS):**

Supabase implements RLS policies:

- **Anon Key** (mobile app):
  - Read-only access
  - Published content only
  - Cannot write/update/delete

- **Service Role Key** (admin panel):
  - Full access (bypasses RLS)
  - Server-side only (never in client code)
  - Create/read/update/delete all records

**Environment Variables:**
```
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx (safe to commit)
SUPABASE_SERVICE_ROLE_KEY=xxx (NEVER commit)
```

---

## 6. Database Schema

### 6.1 Core Tables

#### `domains`
```sql
id UUID PRIMARY KEY
slug TEXT UNIQUE NOT NULL
name TEXT NOT NULL
description TEXT
icon TEXT (Material Icon name)
display_order INTEGER
is_active BOOLEAN
created_at TIMESTAMPTZ
updated_at TIMESTAMPTZ
```

#### `content_items`
```sql
id UUID PRIMARY KEY
slug TEXT UNIQUE NOT NULL
domain_id UUID REFERENCES domains
pillar pillar_type (understand|reflect|grow|support)
label TEXT NOT NULL
microcopy TEXT
audience audience_type (any|service_member|veteran|partner_family)
sensitivity sensitivity_type (normal|sensitive|urgent)
disclosure_level INTEGER (1-3)
keywords TEXT[]
is_published BOOLEAN
view_count INTEGER
created_at TIMESTAMPTZ
updated_at TIMESTAMPTZ
```

#### `content_details`
```sql
id UUID PRIMARY KEY
content_item_id UUID UNIQUE REFERENCES content_items

-- Understand section
understand_title TEXT
understand_body TEXT
understand_insights TEXT[]

-- Reflect section
reflect_prompts TEXT[]

-- Grow section
grow_title TEXT
grow_steps JSONB -- [{action, detail}]

-- Support section
support_intro TEXT
support_resources JSONB -- [{name, description, contact}]

-- Closing
affirmation TEXT

created_at TIMESTAMPTZ
updated_at TIMESTAMPTZ
```

#### `content_connections`
```sql
id UUID PRIMARY KEY
from_item_id UUID REFERENCES content_items
to_item_id UUID REFERENCES content_items
connection_type connection_type (leads_to|related|prerequisite)
UNIQUE(from_item_id, to_item_id, connection_type)
```

#### `journeys`
```sql
id UUID PRIMARY KEY
slug TEXT UNIQUE NOT NULL
title TEXT NOT NULL
description TEXT
audience audience_type
item_sequence UUID[] -- Ordered array of content_item_ids
is_published BOOLEAN
created_at TIMESTAMPTZ
updated_at TIMESTAMPTZ
```

#### `sync_metadata`
```sql
id INTEGER PRIMARY KEY (always 1)
last_content_update TIMESTAMPTZ
content_version INTEGER
```

### 6.2 Learn Tables

#### `learn_articles`
```sql
id UUID PRIMARY KEY
slug TEXT UNIQUE NOT NULL
title TEXT NOT NULL
summary TEXT NOT NULL
category article_category (brain_science|psychology|life_situation)
read_time_minutes INTEGER
age_brackets TEXT[]
audience TEXT
is_published BOOLEAN
view_count INTEGER
created_at TIMESTAMPTZ
updated_at TIMESTAMPTZ
```

#### `learn_article_content`
```sql
id UUID PRIMARY KEY
article_id UUID UNIQUE REFERENCES learn_articles
sections JSONB -- [{heading, content, tip}]
key_takeaways TEXT[]
created_at TIMESTAMPTZ
updated_at TIMESTAMPTZ
```

### 6.3 Views

#### `content_full`
```sql
-- Combines content_items + domains + content_details
-- Used by mobile app for efficient querying
```

### 6.4 Triggers

#### `update_sync_metadata()`
Automatically increments `content_version` when:
- content_items updated
- content_details updated
- Triggers mobile app to sync

---

## 7. State Management & Data Flow

### 7.1 Provider Architecture

**UserProvider**
- User profile (name, age bracket, audience)
- Onboarding status
- AI profile selections
- Persists to Hive box: `user_data`

**MoodProvider**
- Mood entries (date-based)
- Streak calculation
- Statistics computation
- Persists to Hive box: `mood_entries`

**ThemeProvider**
- Selected colour palette
- Light/dark mode
- Custom theme configuration
- Persists to Hive box: `settings`

### 7.2 Service Layer

**ContentService** (Singleton)
- Supabase client initialisation
- Content synchronisation
- Local caching (Hive)
- Version checking
- Search & filtering

**AIService**
- OpenAI API communication
- Prompt construction
- Response parsing
- Fallback handling
- Error management

### 7.3 Data Persistence Strategy

**Hive Boxes:**
```
user_data - User profile
mood_entries - Mood logs
settings - App preferences
navigate_content - Navigate content cache
```

**Sync Strategy:**
- Write locally first
- Background sync when online
- Never block UI
- Version-based updates only

---

## 8. Design System & UI/UX

### 8.1 Typography

**Font Family:** Outfit (Google Fonts)

**Type Scale:**
- Display Large: 64px, Weight 200
- Display Small: 32px, Weight 400
- Headline Medium: 28px, Weight 600
- Headline Small: 24px, Weight 600
- Title Large: 22px, Weight 600
- Title Medium: 16px, Weight 500
- Body Large: 16px, Weight 400
- Body Medium: 14px, Weight 400
- Body Small: 12px, Weight 400

### 8.2 Colour Palettes

**Multiple Theme Options:**

The app supports several colour palettes (configurable):
- Ocean Blue (primary)
- Forest Green
- Sunset Orange
- Deep Purple
- Neutral Grey

Each palette includes:
- Primary colour
- Accent colour
- Background colours (light/dark)
- Card colours
- Border colours
- Text colours (bright, light, muted)

**No Gradients:**  
Per user preference, the design avoids gradients (especially purple) to maintain a professional, non-"cheap" aesthetic appropriate for military users.

### 8.3 Spacing System

**Base Unit:** 4px

**Spacing Scale:**
- xxs: 4px
- xs: 8px
- sm: 12px
- md: 16px
- lg: 20px
- xl: 24px
- xxl: 32px
- xxxl: 48px

### 8.4 Component Library

**Reusable Components:**
- FeatureCard - Home screen feature tiles
- MoodCheckCard - Quick mood logging
- StatCard - Statistics display
- ExerciseCard - Breathing exercise cards (with expandable info)
- ContentCard - Navigate content items

**UI Patterns:**
- Bottom sheets for additional info
- Expandable cards with "Learn More"
- Swipe gestures for navigation
- Pull-to-refresh for sync
- Toast notifications for feedback

### 8.5 Navigation

**Bottom Tab Navigation:**
1. Home
2. Navigate
3. Learn
4. More (Settings/Profile)

**Screen Transitions:**
- Standard push/pop navigation
- Smooth hero animations
- Fade transitions for modals

### 8.6 Accessibility

**Requirements:**
- WCAG AA compliance
- Screen reader support
- Adjustable font sizes
- High contrast mode
- Touch target sizes (minimum 44x44)
- Focus indicators

---

## 9. Audio Assets & Media

### 9.1 Required Audio Files

**Breathing Exercises:**
- `breath-in-242641.mp3` (355 lines duration)
- `breath-out-242642.mp3` (601 lines duration)
- `heart-beat-137135.mp3` (1634 lines duration)
- `breath-in-and-out-38694.mp3` (460 lines duration)

**Calm Music:**
- `ocean-waves-crashing-the-shoreline-423649.mp3` (1064 lines duration)
- Additional nature sounds (to be sourced)

**Licensing:**
- Royalty-free or original compositions
- Sources: Freesound.org, Mixkit.co, Pixabay
- Proper attribution in app

### 9.2 Image Assets

**Icons:**
- Lucide Icons (vector-based)
- Material Icons (for admin panel)
- Custom app icon (iOS/Android)

**Illustrations:**
- Optional: Onboarding illustrations
- Optional: Empty state graphics
- Must align with military/professional aesthetic

---

## 10. Security & Privacy

### 10.1 Data Collection Policy

**Collected Data:**
- First name only
- Age bracket (not exact age)
- Audience type (service member, veteran, etc.)
- Mood logs (local only)
- App usage statistics (anonymous, local only)

**NOT Collected:**
- Surname
- Email address
- Phone number
- GPS location
- Photo/camera data
- Biometric data
- Device identifiers (beyond standard analytics)

### 10.2 Data Storage

**Local Storage:**
- All user data stored in Hive (encrypted at rest by OS)
- Never transmitted to server
- Controlled by user (can be cleared)

**Server Storage:**
- Only content (articles, guidance)
- No personally identifiable information
- Anon key can only read published content

### 10.3 OPSEC Considerations

**Operational Security Design:**
- No text journaling (too identifiable)
- No location tracking
- No timestamps sent to server
- No photo/video capture
- Simple emoji-based mood tracking
- All data local by default

### 10.4 Compliance

**Privacy Regulations:**
- GDPR compliant (EU)
- UK Data Protection Act
- MOD security guidelines (appropriate for military use)

**Legal Requirements:**
- Privacy policy
- Terms of service
- Data deletion process
- Age verification (13+ or appropriate)

---

## 11. Deployment & Infrastructure

### 11.1 Mobile App Distribution

**iOS:**
- Apple App Store
- TestFlight for beta testing
- App Store Connect setup
- Required: Apple Developer account (£99/year)
- Bundle ID: `com.oceaninsight.deepdive` (or similar)

**Android:**
- Google Play Store
- Closed/open testing tracks
- Play Console setup
- Required: Google Play Developer account ($25 one-time)
- Package name: `com.oceaninsight.deepdive` (or similar)

**Web:**
- Firebase Hosting, Netlify, or Vercel
- For demonstrations/previews only
- Not primary platform

### 11.2 Admin Panel Deployment

**Recommended:** Vercel

**Requirements:**
- Environment variables (Supabase keys)
- Server-side rendering enabled
- Protected route (password or auth)
- HTTPS only

**Alternative:** Netlify, AWS Amplify, DigitalOcean App Platform

### 11.3 Backend (Supabase)

**Hosting:** Supabase Cloud (managed PostgreSQL)

**Tier Recommendations:**
- Development: Free tier
- Production: Pro tier ($25/month)
  - Better performance
  - Automatic backups
  - More storage
  - Support

**Configuration:**
- Row Level Security enabled
- Automatic backups
- Point-in-time recovery
- Connection pooling

### 11.4 CI/CD Pipeline

**Recommended Tools:**
- GitHub Actions for automation
- Fastlane for iOS/Android builds
- Code signing management

**Pipeline Stages:**
1. Lint & test
2. Build (iOS/Android/Web)
3. Deploy to TestFlight/Internal Testing
4. Production release (manual trigger)

---

## 12. Testing Requirements

### 12.1 Unit Testing

**Flutter App:**
- Service layer tests (ContentService, AIService)
- Provider tests (UserProvider, MoodProvider, ThemeProvider)
- Utility function tests
- Target: 70%+ code coverage

**Admin Panel:**
- API route tests
- Component tests
- Integration tests

### 12.2 Widget Testing

**Flutter:**
- Feature screens
- Reusable components
- Navigation flows
- State changes

### 12.3 Integration Testing

**Flutter:**
- End-to-end user flows
- Offline scenarios
- Sync scenarios
- Audio playback

### 12.4 Manual Testing

**Devices:**
- iOS: iPhone 12+, iPad
- Android: Variety of devices (Samsung, Google Pixel)
- Web: Chrome, Safari, Firefox

**Scenarios:**
- First-time onboarding
- Offline usage (airplane mode)
- Sync after content update
- Audio playback
- Theme switching
- Mood tracking over multiple days

### 12.5 Performance Testing

**Metrics:**
- App launch time (< 3 seconds)
- Screen transition time (< 300ms)
- Content sync time (< 10 seconds for 500 items)
- Audio playback latency (< 500ms)
- Memory usage (< 150MB)

---

## 13. Analytics & Monitoring

### 13.1 Local Analytics

**Tracked Locally (No Server Transmission):**
- Feature usage counts
- Screen view counts
- Breathing exercise completions
- Content item views
- Mood logging frequency
- Time spent in app

**Purpose:**
- Understand usage patterns
- Improve UX
- Prioritise features

**Privacy:**
- All analytics local only
- User can clear data
- No user identification
- No tracking across devices

### 13.2 Server-Side Monitoring

**Supabase Metrics:**
- API request counts
- Database query performance
- Error rates
- Storage usage

**Admin Panel Analytics:**
- Content publish events
- Bulk import operations
- User actions (admin-side only)

### 13.3 Error Tracking

**Recommended Tool:** Sentry

**Captures:**
- Unhandled exceptions
- Network errors
- Database errors
- AI API failures

**Privacy:**
- No PII in error logs
- Sanitised error messages
- User can opt out

---

## 14. Charitable Component

### 14.1 Submariners Charity Partnership

**Commitment:** £1 from every app download goes to the Submariners Charity

**Implementation Options:**

1. **One-Time Purchase Model:**
   - App priced at £2.99 (example)
   - £1 donated per download
   - Tracked via app store sales reports
   - Quarterly donations

2. **Freemium Model:**
   - Free download
   - Optional "Support the Charity" in-app donation
   - £1 minimum suggested

3. **Sponsorship Model:**
   - Free app
   - Organisational sponsorship covers donations
   - Public recognition of sponsors

**Transparency:**
- Total donations displayed in app
- Regular reports to charity
- Public acknowledgement

---

## 15. Future Enhancements (Out of Scope for Initial Build)

### 15.1 Planned Features

1. **Physical Exercise Library**
   - Guided workouts
   - No equipment required
   - Video demonstrations (offline)

2. **Sleep Tracking**
   - Sleep schedule recommendations
   - Sleep hygiene education
   - Integration with breathing exercises

3. **Community Connection** (Carefully Designed)
   - Anonymous peer support
   - Moderated forums
   - OPSEC-safe design
   - Optional feature

4. **Journeys System**
   - Curated content pathways
   - Multi-day programs
   - Progress tracking
   - Completion rewards

5. **Push Notifications**
   - Gentle reminders (opt-in)
   - Daily affirmations
   - Mood check-in prompts
   - Breathing exercise suggestions

6. **Data Export**
   - Export mood data (CSV)
   - Anonymised insights
   - Share with therapist (optional)

7. **Multilingual Support**
   - Initially: UK English only
   - Future: US English, Welsh, Gaelic

8. **Wearable Integration**
   - Apple Watch companion
   - Breathing exercises on wrist
   - Quick mood logging

### 15.2 Research Opportunities

1. **Clinical Validation**
   - Partner with mental health researchers
   - Measure effectiveness
   - Publish findings

2. **User Feedback Collection**
   - In-app feedback mechanism
   - User interviews
   - Surveys (anonymous)

3. **Accessibility Enhancements**
   - Voice control
   - Dyslexia-friendly fonts
   - Reduced motion option

---

## 16. Content Generation Strategy

### 16.1 GPT-Assisted Content Creation

**Process:**

A detailed GPT prompt is provided (`gpt-content-generator.md`) to generate content at scale.

**Prompt Parameters:**
- Batch size: 50-100 items
- Batch index: Sequential numbering
- Seed: Run identifier
- Exclude lists: Prevent duplicates

**Output Format:**
```json
{
  "meta": {
    "batch_size": 50,
    "batch_index": 1,
    "seed": "run-001"
  },
  "items": [
    {
      "id": "domain-slug.pillar.topic-slug",
      "domain": "Exact domain name",
      "pillar": "understand|reflect|grow|support",
      "label": "4-9 word title",
      "microcopy": "1-2 sentences",
      "audience": "any|service_member|veteran|partner_family",
      "disclosure_level": 1-3,
      "sensitivity": "normal|sensitive|urgent",
      "keywords": ["array", "of", "keywords"]
    }
  ]
}
```

**Quality Guidelines:**
- Growth-focused (not problem-focused)
- UK English
- Positive, empowering tone
- Non-diagnostic
- Military-aware but not operational

### 16.2 Content Review Workflow

1. **Generate** - Use GPT prompt
2. **Import** - Bulk import via API
3. **Review** - Admin panel review
4. **Edit** - Refine as needed
5. **Add Details** - Deep content sections
6. **Publish** - Make available to app

### 16.3 Content Maintenance

**Regular Tasks:**
- Add new content monthly
- Update outdated information
- Remove deprecated content
- Monitor view counts
- Gather user feedback

**Version Control:**
- Sync metadata tracks changes
- Apps auto-update
- Rollback capability

---

## 17. Legal & Compliance

### 17.1 Disclaimers

**Required In-App Disclaimer:**

"Ocean Insight is designed to support your mental wellbeing and is not a substitute for professional medical advice, diagnosis, or treatment. If you are experiencing a mental health crisis or emergency, please contact emergency services or a mental health professional immediately."

**Placement:**
- Onboarding screen
- Settings/About section
- Support pillar content

### 17.2 Terms of Service

**Key Points:**
- App is informational/educational
- Not a medical device
- User responsibility for seeking professional help
- Liability limitations
- Service availability
- Data usage

### 17.3 Privacy Policy

**Required Sections:**
- What data is collected
- How data is stored
- Who has access (nobody)
- User rights (delete, export)
- Cookie policy (if web version)
- Contact information

### 17.4 Age Restrictions

**Recommendation:** 13+ (or 17+ depending on content sensitivity)

**Considerations:**
- Parental guidance for under-18s
- Age-appropriate content
- Safeguarding measures

### 17.5 Intellectual Property

**Content Ownership:**
- Original content: Client-owned
- Licensed content: Proper attribution
- User-generated: Terms of use
- Open-source libraries: License compliance

---

## 18. Budget Estimation Guidelines

### 18.1 Development Time Estimates

**Mobile App (Flutter):**
- Core architecture & setup: 1-2 weeks
- Offline data management: 2-3 weeks
- Breathing exercises: 2 weeks
- Mood tracking: 1 week
- Navigate system: 3-4 weeks
- Learn system: 1-2 weeks
- Audio player: 1 week
- Affirmations/Quotes/Goals: 2 weeks
- AI personalisation: 1-2 weeks
- Onboarding/Profile: 1 week
- Settings & themes: 1 week
- Testing & polish: 2-3 weeks

**Estimated Total:** 18-25 weeks (1 mobile developer)

**Admin Panel (Next.js):**
- Setup & authentication: 1 week
- Dashboard: 1 week
- Content CRUD: 2 weeks
- Learn articles CRUD: 1 week
- Bulk import: 1 week
- Analytics: 1 week
- Testing & polish: 1 week

**Estimated Total:** 8 weeks (1 web developer)

**Backend & Integration:**
- Supabase setup: 3 days
- Schema implementation: 1 week
- RLS policies: 2 days
- API endpoints: 1 week
- Content migration scripts: 3 days
- Testing: 1 week

**Estimated Total:** 4 weeks (1 backend developer)

**Design:**
- Brand identity: 1 week
- UI design system: 2 weeks
- Screen designs: 3-4 weeks
- Illustrations/assets: 1-2 weeks
- Design QA: 1 week

**Estimated Total:** 8-10 weeks (1 UI/UX designer)

**Project Management & QA:**
- Throughout project: 20-25% of development time

### 18.2 Ongoing Costs

**Annual:**
- Apple Developer Account: £99/year
- Google Play Developer Account: $25 (one-time)
- Supabase Pro: $300/year ($25/month)
- Domain registration: £15/year
- OpenAI API usage: Variable (estimate £50-200/month depending on usage)

**Optional:**
- Error tracking (Sentry): $26-80/month
- CI/CD (GitHub Actions): Included with GitHub
- Analytics (if external service): £0-50/month

### 18.3 Content Creation Costs

**Options:**

1. **DIY with GPT:**
   - GPT-4 API costs: ~£50-100 for 1000 items
   - Time: ~10-20 hours for review/editing

2. **Professional Content Writer:**
   - Rate: £50-100/hour
   - Estimate: 100 hours for 500 items
   - Total: £5,000-10,000

3. **Clinical Psychologist Review:**
   - Rate: £75-150/hour
   - Estimate: 20-30 hours review
   - Total: £1,500-4,500

---

## 19. Success Criteria

### 19.1 Technical Metrics

- [ ] App launches in < 3 seconds
- [ ] Works 100% offline after first sync
- [ ] Syncs content in < 10 seconds
- [ ] Zero crashes (crash-free rate > 99.9%)
- [ ] App size < 100MB (excluding audio)
- [ ] Memory usage < 150MB
- [ ] Battery drain < 5%/hour during active use

### 19.2 User Experience Metrics

- [ ] Onboarding completion rate > 80%
- [ ] Daily active user retention > 30% at 30 days
- [ ] Average session length > 5 minutes
- [ ] Feature usage: All features used by > 50% of users within first week
- [ ] App Store rating > 4.5 stars
- [ ] App Store reviews mention "offline" positively

### 19.3 Content Metrics

- [ ] 500+ content items across all domains
- [ ] 50+ learn articles
- [ ] 100+ affirmations
- [ ] 100+ quotes
- [ ] Content updated monthly

### 19.4 Business Metrics

- [ ] 10,000 downloads in first year
- [ ] £10,000+ donated to Submariners Charity in first year
- [ ] Featured in Apple App Store or Google Play
- [ ] Positive media coverage
- [ ] Partnership with military organisations

---

## 20. Documentation Requirements

### 20.1 Technical Documentation

**Required:**
- API documentation (admin endpoints)
- Database schema documentation
- Setup instructions (README)
- Environment configuration guide
- Build & deployment guide
- Troubleshooting guide

### 20.2 User Documentation

**Required:**
- In-app help text
- Feature tutorials (first-time use)
- FAQ section
- Contact/support information

**Optional:**
- Video tutorials
- User guides (PDF)
- Community forum

### 20.3 Admin Documentation

**Required:**
- Admin panel user guide
- Content creation guidelines
- GPT content generation instructions
- Bulk import process
- Publishing workflow
- Troubleshooting guide

---

## 21. Handover Requirements

### 21.1 Source Code

**Repositories:**
- Mobile app (Flutter)
- Admin panel (Next.js)
- Documentation

**Requirements:**
- Clean, commented code
- Consistent naming conventions
- Git history preserved
- No sensitive keys in repo
- `.gitignore` properly configured

### 21.2 Assets

**Deliverables:**
- Design files (Figma or Adobe XD)
- Image assets (PNG, SVG)
- Audio files
- Font files
- App icons (all sizes)

### 21.3 Access & Credentials

**Transferred:**
- Apple Developer account access
- Google Play Console access
- Supabase project ownership
- Domain registrar access
- GitHub repository ownership
- OpenAI API key ownership

### 21.4 Training

**Required:**
- Admin panel training session (2 hours)
- Content creation workflow training (1 hour)
- Deployment process training (1 hour)
- Support & maintenance guidance (1 hour)

---

## 22. Assumptions & Constraints

### 22.1 Assumptions

1. Client has Apple Developer and Google Play Developer accounts (or will create)
2. Client will provide or approve all content
3. Client has rights to use audio files
4. Client will handle customer support
5. OpenAI API is acceptable for AI features (or alternative provided)
6. UK English is the only required language initially

### 22.2 Constraints

1. Must work fully offline (non-negotiable)
2. Minimal data collection (OPSEC requirement)
3. No video content (storage/bandwidth constraints)
4. Portrait orientation only (mobile app)
5. iOS 13+ and Android 8+ (no older versions)
6. Must be accessible without account creation

### 22.3 Out of Scope

Unless specifically requested:
- Backend server (using Supabase only)
- Custom authentication system (not required)
- Social features (deferred)
- In-app purchases beyond initial purchase
- Android tablet optimisation
- iPad-specific UI (uses mobile UI)
- Apple Watch or Android Wear apps
- Multi-language support
- Video content

---

## 23. Risk Assessment

### 23.1 Technical Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Supabase downtime | High | Low | Local caching, graceful degradation |
| OpenAI API changes | Medium | Medium | Configurable API endpoint, fallback responses |
| Large app size | Medium | Medium | Audio compression, lazy loading |
| Sync conflicts | Medium | Low | Version-based sync, conflict resolution strategy |
| Audio playback issues | Medium | Medium | Thorough testing across devices, fallback to silent mode |

### 23.2 Business Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Low adoption | High | Medium | Marketing plan, partnerships, user research |
| App store rejection | High | Low | Follow guidelines, thorough testing, legal review |
| Negative reviews | Medium | Medium | Beta testing, user feedback loops, responsive support |
| Charitable donations tracking | Medium | Low | Clear accounting, public transparency |

### 23.3 Legal Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Medical liability | High | Low | Clear disclaimers, not marketed as medical device |
| Privacy violation | High | Low | Minimal data collection, privacy-by-design, legal review |
| Content copyright | Medium | Low | Original content, proper licensing, attribution |
| Age restriction issues | Medium | Low | Clear age gates, parental guidance notices |

---

## 24. Questions for Vendor/Developer

### 24.1 Technical Questions

1. What is your experience with Flutter and offline-first architecture?
2. Have you built apps with Supabase or similar BaaS platforms?
3. How do you handle app store submission and rejections?
4. What is your testing approach for offline scenarios?
5. Do you have experience with audio playback in Flutter?
6. What is your approach to app performance optimisation?
7. How do you handle CI/CD for mobile apps?

### 24.2 Process Questions

8. What is your typical sprint/iteration length?
9. How do you handle change requests during development?
10. What project management tools do you use?
11. How often will we have progress reviews?
12. What is your availability for post-launch support?
13. Do you provide warranty/bug-fix period?

### 24.3 Cost Questions

14. What is your hourly or project rate?
15. Are there any additional costs beyond development?
16. How do you handle scope changes and pricing?
17. What payment schedule do you propose?
18. Do you offer maintenance contracts?

### 24.4 Portfolio Questions

19. Can you share similar projects you've built?
20. Do you have references we can contact?
21. Have you built apps for military/healthcare sectors?
22. What was your largest Flutter project?

---

## 25. Conclusion

Ocean Insight represents a comprehensive, privacy-first mental health solution specifically designed for military personnel operating in offline environments. The application balances sophisticated features (AI personalisation, content management, rich media) with strict privacy requirements and operational security constraints.

The three-component architecture (mobile app, admin panel, backend) provides scalability, maintainability, and content flexibility while ensuring the core user experience remains fully offline-capable.

This specification should provide development companies with sufficient detail to:
1. Understand the full scope of the project
2. Estimate development time and costs accurately
3. Identify potential technical challenges
4. Propose appropriate solutions and alternatives
5. Plan resources and timelines

**Document Version:** 1.0  
**Last Updated:** January 2026  
**For Quotation Purposes Only**

---

## Appendix A: Glossary

**OPSEC** - Operational Security: Protecting sensitive information that could compromise military operations  
**RLS** - Row Level Security: Database-level access control  
**BaaS** - Backend as a Service: Cloud-based backend infrastructure  
**PWA** - Progressive Web App: Web application with app-like features  
**Hive** - Local NoSQL database for Flutter  
**Supabase** - Open-source Firebase alternative (PostgreSQL-based)  
**GPT** - Generative Pre-trained Transformer: AI language model  

---

## Appendix B: Reference Documents

1. `README.md` - Project overview
2. `SETUP.md` - Development setup guide
3. `NAVIGATE_SYSTEM.md` - Navigate content system documentation
4. `gpt-content-generator.md` - GPT content generation prompt
5. `PALETTE_OPTIONS.md` - Theme colour options
6. `supabase/schema.sql` - Main database schema
7. `supabase/learn-schema.sql` - Learn articles schema
8. `admin/IMPORT_GUIDE.md` - Content import documentation

---

## Appendix C: Contact Information

**For Questions Regarding This Specification:**

[Client contact details to be inserted]

**For Technical Clarifications:**

[Technical lead contact details to be inserted]

---

**END OF SPECIFICATION DOCUMENT**

