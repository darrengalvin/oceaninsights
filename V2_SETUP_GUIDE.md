# Below the Surface v2.0 - Setup & Deployment Guide

**Decision Training System Complete!** 🎉

This guide will help you deploy and test the new scenario training features.

---

## What's New in v2.0

### **Mobile App Features:**
- ✅ **Scenario Training** - Interactive decision-making with multiple outcomes
- ✅ **Communication Protocols** - Step-by-step guides for workplace situations
- ✅ **Response Profile** - Privacy-safe pattern tracking
- ✅ **Perspective Shifts** - See how choices land with different people
- ✅ **Offline-first** - All content works without internet after sync

### **Admin Panel Features:**
- ✅ **Scenario Management** - Create, edit, and publish scenarios
- ✅ **Protocol Management** - Build communication guides
- ✅ **Content Organization** - Group by context/difficulty/category
- ✅ **Rich Editor** - Options, outcomes, perspectives, and more

---

## Step 1: Database Migration

### **Run the Schema Migration:**

```bash
# Navigate to your Supabase project SQL editor
# Or use the CLI:

cd /Users/darrengalvin/Documents/GIT\ PROJECTS/deepdive/supabase

# Apply the v2 schema
# Copy contents of v2-scenarios-schema.sql and run in Supabase SQL Editor
```

**Files to run in order:**
1. `v2-scenarios-schema.sql` - Core tables and RLS policies
2. `v2-example-scenarios.sql` - 5 example scenarios (optional but recommended)
3. `v2-example-protocols.sql` - 5 example protocols (optional but recommended)

### **Verify Migration:**

Check that these tables exist in Supabase:
- `scenarios`
- `scenario_options`
- `perspective_shifts`
- `protocols`
- `content_packs`
- `analytics_monthly`
- `scenario_sync_metadata`

---

## Step 2: Flutter App Setup

### **Install Dependencies:**

```bash
cd /Users/darrengalvin/Documents/GIT\ PROJECTS/deepdive

# Get dependencies
flutter pub get

# Generate Hive adapters (already done, but if needed)
flutter pub run build_runner build --delete-conflicting-outputs
```

### **Test in Simulator:**

```bash
# Run the app
flutter run

# Or open in Xcode and press ▶️
```

### **Expected Behavior:**
1. App launches with splash screen
2. Home screen shows new sections:
   - "Decision Training"
   - "Communication Protocols"
   - "Response Profile"
3. If no content yet, screens show "Sync Now" buttons
4. Tap "Sync Now" to download scenarios from Supabase
5. After sync, scenarios and protocols appear

---

## Step 3: Admin Panel Setup

### **Install Admin Dependencies:**

```bash
cd admin

# Install packages (if not already done)
npm install
```

### **Run Admin Panel:**

```bash
# Development mode
npm run dev

# Access at http://localhost:3000
```

### **Create Your First Scenario:**

1. Navigate to **Scenarios** in sidebar
2. Click **"+ New Scenario"**
3. Fill in:
   - Title (e.g., "Team Conflict")
   - Situation (2-3 sentences)
   - Context (hierarchy/peer/high-pressure/etc.)
   - Difficulty (1-3)
4. Add **Response Options** (3-5 recommended):
   - Response text
   - Tags (e.g., "direct, assertive")
   - Immediate outcome
   - Long-term consideration
   - Risk level
5. Add **Perspective Shifts** (optional but powerful):
   - Choose viewpoint (command/peer/subordinate)
   - Write interpretation
6. Click **"Create Scenario"**
7. ✅ Check **"Publish immediately"** to make it live

---

## Step 4: Testing the Full Flow

### **Mobile App Test:**

1. **Sync Content:**
   - Open app
   - Tap "Decision Training"
   - Tap "Sync Now" (requires internet)
   - Wait for success message

2. **Browse Scenarios:**
   - See list of available scenarios
   - Filter by context or difficulty
   - Tap a scenario to start

3. **Complete a Scenario:**
   - Read the situation
   - Choose a response option
   - See immediate and long-term outcomes
   - View perspective shifts
   - Tap "Complete" to record choice

4. **Check Response Profile:**
   - Go to Home → "Response Profile"
   - See your patterns emerge:
     - "You tend to communicate directly"
     - "You often choose low-risk options"
   - Watch it evolve with more decisions

5. **Browse Protocols:**
   - Go to Home → "Communication Protocols"
   - Tap a protocol to see step-by-step guide
   - Note "When to use" and "Common failures"

### **Admin Panel Test:**

1. **View Scenarios:**
   - Navigate to `/scenarios`
   - See list with status, difficulty, options count
   - Edit existing scenarios

2. **Create Protocol:**
   - Navigate to `/protocols`
   - Click "+ New Protocol"
   - Add steps (1-6 recommended)
   - Define when to use / not use
   - Add common failures
   - Publish

3. **Test Sync:**
   - Create new content in admin
   - Go to mobile app
   - Sync content
   - New items appear immediately

---

## Step 5: Deploy to Production

### **Mobile App (iOS):**

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Build for iOS
cd ios
pod install
cd ..

# Open in Xcode
open ios/Runner.xcworkspace

# Archive:
# Product → Archive
# Distribute → App Store Connect
```

### **Admin Panel (Vercel):**

```bash
cd admin

# Build
npm run build

# Deploy to Vercel
vercel --prod
```

### **Database:**
Already live on Supabase! Just run the migrations.

---

## Example Content Included

### **5 Scenarios:**
1. **Interrupted in Briefing** (Hierarchy, Medium)
   - 4 response options with perspectives

2. **Taking Credit for Your Work** (Peer, Medium)
   - 3 response options with peer/command views

3. **Colleague Venting About Leadership** (Peer, Foundational)
   - 4 response options exploring boundaries

4. **Mistake Under Time Pressure** (High-Pressure, Foundational)
   - 3 response options about accountability

5. **Exhausted Colleague Snaps at You** (Close-Quarters, Medium)
   - 4 response options with empathy/boundaries

### **5 Protocols:**
1. **Raising Concerns Up the Chain** (Communication)
2. **De-escalating Under Fatigue** (Conflict)
3. **Receiving Criticism Without Reacting** (Self-Regulation)
4. **Clarifying Miscommunication** (Communication)
5. **Setting Boundaries Without Conflict** (Trust)

---

## Key Features Explained

### **Response Profile (Privacy-Safe):**
- Stores **aggregate patterns only**
- No specific decisions or timestamps
- Local storage only (never synced)
- Resettable by user
- Shows:
  - Communication style (direct/indirect/adaptive)
  - Conflict approach (immediate/delayed)
  - Risk tolerance (low/medium/high)

### **Offline-First:**
- All content synced to local Hive storage
- Works for months without internet
- Syncs when online to get new content
- No data sent to server (privacy-first)

### **Perspective Shifts:**
- Shows how choices land with:
  - Command/leadership
  - Peers/colleagues
  - Subordinates
  - External observers
- Builds empathy without requiring emotion
- Deepens learning beyond immediate outcomes

---

## Troubleshooting

### **"No scenarios available" in mobile app:**
- Ensure Supabase schema is migrated
- Check content is marked as `published = true`
- Tap "Sync Now" in the app
- Check internet connection

### **Admin panel shows errors:**
- Verify `admin/.env.local` has correct Supabase keys
- Check Supabase RLS policies allow authenticated access
- Run `npm install` to ensure dependencies

### **Hive errors in Flutter:**
- Run: `flutter pub run build_runner clean`
- Then: `flutter pub run build_runner build --delete-conflicting-outputs`
- Restart Flutter app

### **iOS build fails:**
- Clean: `flutter clean`
- Pods: `cd ios && pod install && cd ..`
- Xcode: Product → Clean Build Folder
- Try archive again

---

## Next Steps

### **Content Creation:**
1. Create 10-20 scenarios per content pack
2. Write protocols for common situations
3. Test with users and iterate based on feedback

### **Analytics (Future):**
- Admin dashboard showing:
  - Most completed scenarios
  - Option selection distribution
  - Drop-off points
- Aggregate only, fully anonymous

### **Adaptive Unlocking (Future):**
- Advanced scenarios unlock after foundational ones
- Content packs unlock based on progress
- Difficulty increases with demonstrated skill

---

## Support

**Issues?**
- Check `ROADMAP_V2.md` for detailed technical specs
- Review `PROJECT_SPECIFICATION.md` for original design
- Database schema: `supabase/v2-scenarios-schema.sql`

**Questions?**
- Scenarios: How to write effective options and perspectives
- Protocols: Best practices for step-by-step guides
- Technical: Flutter/Supabase integration

---

**v2.0 is complete and ready to deploy!** 🚀

All systems built, tested, and documented. Time to go live!



