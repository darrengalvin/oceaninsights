# Navigate Content Management System

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         CONTENT FLOW                             │
└─────────────────────────────────────────────────────────────────┘

1. YOU (Owner)
   ↓
2. Admin Panel (http://localhost:3002)
   - Create/edit content
   - Publish when ready
   ↓
3. Supabase Database
   - Stores all content
   - Row Level Security (only published content is public)
   ↓
4. Flutter App (http://localhost:3001)
   - Syncs on startup
   - Caches locally in Hive
   - Works offline forever
   ↓
5. USERS (Clients)
   - See published content
   - Works offline after first sync
```

## 📱 Flutter App (Port 3001)

**What it does:**
- User-facing mobile/web app
- Automatically syncs content on startup
- Caches everything locally for offline use
- Manual refresh button in Navigate screen

**Key files:**
- `lib/core/services/content_service.dart` - Handles sync & caching
- `lib/features/navigate/screens/navigate_screen.dart` - Main UI with refresh button
- `lib/main.dart` - Initialises ContentService on startup

**How to run:**
```bash
cd /Users/darrengalvin/Documents/GIT\ PROJECTS/deepdive
flutter run -d chrome --web-port=3001 --dart-define=OPENAI_API_KEY=your-key
```

## 🖥️ Admin Panel (Port 3002)

**What it does:**
- Content management system (CMS)
- Create, edit, publish content
- Bulk import from GPT
- View stats and analytics

**Key files:**
- `admin/src/app/page.tsx` - Dashboard
- `admin/src/app/content/page.tsx` - Content list
- `admin/src/app/content/new/page.tsx` - Content editor
- `admin/src/app/api/` - API routes

**How to run:**
```bash
cd /Users/darrengalvin/Documents/GIT\ PROJECTS/deepdive/admin
npm run dev
```

**Access:** http://localhost:3002

## 🗄️ Database (Supabase)

**URL:** https://vecclmzkzrwsrtokkclr.supabase.co

**Tables:**
- `domains` - Life areas (Relationships, Family, etc.)
- `content_items` - Tappable options with labels
- `content_details` - Deep content (Understand/Reflect/Grow/Support)
- `content_connections` - Related items
- `journeys` - Curated pathways

**Security:**
- Public (anon key) can only READ published content
- Admin (service_role key) has full access
- Row Level Security enforces this

## 🔄 Content Sync Flow

### First Time User Opens App:
1. App calls `ContentService.instance.init()`
2. Checks Supabase for published content
3. Downloads and caches locally in Hive
4. User sees content immediately

### Returning User (Online):
1. App checks `sync_metadata` table for version
2. If new content available, syncs in background
3. Updates local cache
4. User sees updated content

### Returning User (Offline):
1. App reads from Hive cache
2. No network calls
3. Everything works normally

### Manual Refresh:
1. User taps refresh button in Navigate screen
2. Calls `ContentService.instance.syncContent()`
3. Shows "Content updated" snackbar

## 📝 Creating Content

### Option 1: Admin Panel UI
1. Go to http://localhost:3002
2. Click "Add Content"
3. Fill in all fields:
   - Basic info (domain, pillar, label)
   - Understand section (educational content)
   - Reflect section (questions)
   - Grow section (practical steps)
   - Affirmation (positive closing)
4. Save as Draft or Publish immediately

### Option 2: Bulk Import from GPT
1. Generate content using your GPT prompt
2. Save to `content.json`
3. Import via API:
   ```bash
   curl -X POST http://localhost:3002/api/import \
     -H "Content-Type: application/json" \
     -d @content.json
   ```
4. Content imported as drafts
5. Review and publish in admin panel

## 🎯 Content Structure

### Domains (11 total)
1. Relationships & Connection
2. Family, Parenting & Home Life
3. Identity, Belonging & Inclusion
4. Grief, Change & Life Events
5. Calm, Confidence & Emotional Skills
6. Sleep, Energy & Recovery
7. Health, Injury & Physical Wellbeing
8. Money, Housing & Practical Life
9. Work, Purpose & Service Culture
10. Leadership, Boundaries & Communication
11. Transition, Resettlement & Civilian Life

### Pillars
- **Understand** (35%) - Educational, normalising
- **Grow** (35%) - Practical skills
- **Reflect** (20%) - Self-discovery questions
- **Support** (10%) - Crisis resources

### Audience Filtering
- `any` - Everyone
- `service_member` - Currently serving
- `veteran` - Former military
- `partner_family` - Partners and family

### Sensitivity Levels
- `normal` (80%) - Standard content
- `sensitive` (18%) - Handle with care
- `urgent` (2%) - Crisis-related

## 🔐 Security Notes

### Safe to Commit:
- `lib/core/config/supabase_config.dart` (anon key is public by design)
- Flutter app code

### NEVER Commit:
- `admin/.env.local` (contains service_role key)
- Service role key anywhere in client code

### How Security Works:
- Anon key can only read published content (enforced by RLS)
- Service role key has full access (only used in admin panel server-side)
- Even if someone has the anon key, they can't:
  - Write/update/delete content
  - Read unpublished content
  - Access admin functions

## 🚀 Deployment

### Flutter App
- Build: `flutter build web`
- Deploy to: Firebase Hosting, Netlify, Vercel, etc.
- Users download and sync content on first launch

### Admin Panel
- Deploy to: Vercel (recommended)
- Add environment variables in Vercel dashboard
- Only you access this URL

### Database
- Already hosted on Supabase
- No deployment needed
- Automatic backups

## 📊 Monitoring

### Check Sync Status:
- Open Flutter app
- Go to Navigate screen
- Look for "Last updated: Xm ago" at the top

### Check Content Stats:
- Open admin panel
- Dashboard shows:
  - Total content items
  - Published vs drafts
  - Domains count

### Force Refresh:
- Flutter app: Tap refresh button in Navigate
- Admin: Refresh browser

## 🐛 Troubleshooting

### "No content found" in Flutter app:
1. Check internet connection
2. Check Supabase is up
3. Verify content is published in admin
4. Try manual refresh button

### Admin panel won't start:
1. Check `.env.local` exists
2. Verify Supabase keys are correct
3. Kill port 3002: `lsof -ti:3002 | xargs kill -9`

### Content not syncing:
1. Check `sync_metadata` table in Supabase
2. Check Flutter console for errors
3. Try `ContentService.instance.forceRefresh()`

## 📈 Next Steps

1. ✅ Database schema created
2. ✅ Admin panel built
3. ✅ Flutter integration done
4. ⏳ Generate content with GPT
5. ⏳ Import and publish content
6. ⏳ Test on real devices
7. ⏳ Deploy admin panel
8. ⏳ Deploy Flutter app



