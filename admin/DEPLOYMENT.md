# Admin Panel Deployment Guide

## Deploying to Vercel

### Prerequisites
- GitHub repository with your code
- Supabase project set up
- Vercel account (https://vercel.com)

### Step 1: Get Supabase Credentials
1. Go to https://supabase.com/dashboard
2. Select your project
3. Go to **Settings** → **API**
4. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key**

### Step 2: Deploy to Vercel
1. Go to https://vercel.com/new
2. Import your GitHub repository
3. **IMPORTANT:** Set **Root Directory** to `admin`
4. Framework should auto-detect as **Next.js**

### Step 3: Add Environment Variables
In Vercel project settings, add:

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
```

### Step 4: Deploy
Click **Deploy** and wait ~2 minutes.

Your admin panel will be live at: `https://your-project-name.vercel.app`

---

## Local Development

Create a `.env.local` file in the `admin/` directory:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
```

Then run:
```bash
cd admin
npm install
npm run dev
```

---

## Troubleshooting

### "Module not found" errors
- Make sure Root Directory is set to `admin` in Vercel
- Check that package.json is in the admin folder

### "Environment variables not working"
- Add variables in Vercel Dashboard → Settings → Environment Variables
- Redeploy after adding variables

### "Build failed"
- Check build logs in Vercel dashboard
- Ensure all dependencies are in package.json
- Try building locally first: `npm run build`

