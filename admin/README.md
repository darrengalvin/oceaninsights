# Ocean Insight Admin Panel

Content management system for the Ocean Insight app.

## Quick Start

### 1. Set up Supabase

1. Go to your Supabase project: https://supabase.com/dashboard
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `../supabase/schema.sql`
4. Click **Run** to create all tables

### 2. Configure Environment

1. Copy `env.example` to `.env.local`:
   ```bash
   cp env.example .env.local
   ```

2. Fill in your Supabase credentials in `.env.local`:
   ```
   NEXT_PUBLIC_SUPABASE_URL=https://vecclmzkzrwsrtokkclr.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
   ```

### 3. Install & Run

```bash
cd admin
npm install
npm run dev
```

The admin panel will be available at http://localhost:3002

## Features

- **Dashboard** - Overview of content stats
- **Content Management** - Create, edit, publish content
- **Domain Management** - Manage life areas
- **Journey Builder** - Create guided pathways
- **Bulk Import** - Import GPT-generated content

## Content Structure

### Domains (Life Areas)
- Relationships & Connection
- Family, Parenting & Home Life
- Identity, Belonging & Inclusion
- Grief, Change & Life Events
- Calm, Confidence & Emotional Skills
- Sleep, Energy & Recovery
- Health, Injury & Physical Wellbeing
- Money, Housing & Practical Life
- Work, Purpose & Service Culture
- Leadership, Boundaries & Communication
- Transition, Resettlement & Civilian Life

### Pillars
1. **Understand** - Educational, normalising content
2. **Reflect** - Self-discovery prompts
3. **Grow** - Practical skills and strategies
4. **Support** - Crisis resources (hidden until needed)

### Audience Types
- `any` - Everyone
- `service_member` - Currently serving military
- `veteran` - Former military
- `partner_family` - Partners and family members

### Sensitivity Levels
- `normal` - Standard content
- `sensitive` - Handle with care
- `urgent` - Crisis-related

## Importing Content

You can bulk import content from your GPT script using the `/api/import` endpoint:

```bash
curl -X POST http://localhost:3002/api/import \
  -H "Content-Type: application/json" \
  -d @your-generated-content.json
```

The import expects the format from your GPT prompt with `{ items: [...] }`.

## Security

- The app uses Row Level Security (RLS) on Supabase
- The Flutter app can only READ published content
- The admin panel uses the service_role key for full access
- Never expose the service_role key in client-side code

## Deployment

For production, deploy to Vercel:

1. Push to GitHub
2. Connect to Vercel
3. Add environment variables in Vercel dashboard
4. Deploy

