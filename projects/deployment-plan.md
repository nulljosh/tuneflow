# Code Projects - Deployment & Development Plan

**Last updated:** 2026-02-08  
**Author:** Claude (clawdejosh)

---

## Executive Summary

**What works:** Static sites (Vite + React + public APIs + GitHub Pages)  
**What doesn't:** Express backends, Docker, complex database setups, Vercel/Render friction  
**Strategy:** Ship static first, avoid backend unless absolutely necessary

---

## Priority Matrix

| Project | Status | Priority | Action |
|---------|--------|----------|--------|
| **finn** | ✅ Live on GitHub Pages | 🟢 Maintain | Consider Wealthsimple auto-sync (research ToS first) |
| **bread** | 🟡 Live but ugly URL | 🟡 Quick fix | Clean up Vercel URL, plan C/iOS version |
| **ideasia** | 🔴 Backend hell | 🔴 Rebuild/simplify | Migrate to client-only or scrap |

---

## Project Details

### 1. finn - Stock Portfolio Tracker

**Current Status:** ✅ Shipped  
**Deployment:** GitHub Pages  
**Tech Stack:** Pure HTML/CSS/JS (no framework)

**What Works:**
- Zero build complexity
- Instant deployment (`git push`)
- No backend to maintain

**Enhancement Ideas:**
- **Auto-sync with Wealthsimple** (⚠️ against ToS - research first)
  - Scrape portfolio data via headless browser
  - Update static JSON daily via GitHub Actions
  - Risk: Account suspension if detected
  - Alternative: Manual CSV import feature

**Next Steps:**
1. Leave it as-is (working product)
2. If auto-sync desired: Research Wealthsimple API (official vs. unofficial)
3. Consider adding charts/visualizations

**Priority:** Low (it works!)

---

### 2. bread - Prediction Markets Dashboard

**Current Status:** 🟡 Live on Vercel, but ugly URL  
**Deployment:** Vercel  
**Tech Stack:** Vite + React + Recharts + external APIs  
**Live URL:** https://bread-m0zrli7pf-nulljosh-9577s-projects.vercel.app

**What Works:**
- Vite build is fast and clean
- Pure frontend (no backend)
- Hits Yahoo Finance + Polymarket APIs directly
- Monte Carlo simulations run client-side

**What Needs Fixing:**

1. **Ugly Vercel URL** (immediate fix)
   - Option A: Link custom domain (heyitsmejosh.com/bread or bread.heyitsmejosh.com)
   - Option B: Rename Vercel project to get cleaner URL
   - **Action:** Run `vercel --prod` with proper project settings

2. **Future Plans** (from README):
   - C low-level rewrite (performance optimization)
   - iOS app (native experience)

**Next Steps:**
1. **Today:** Fix Vercel URL
   ```bash
   cd bread
   # Option 1: Add domain
   vercel domains add bread.heyitsmejosh.com
   
   # Option 2: Rename project in vercel.json
   # Edit vercel.json, set "name": "bread"
   vercel --prod
   ```

2. **This week:** Optimize bundle size (currently 233KB, target <200KB)

3. **Later:** Plan C rewrite architecture (when performance becomes bottleneck)

**Priority:** Medium (works, just needs polish)

---

### 3. ideasia - Idea Marketplace

**Current Status:** 🔴 Struggling  
**Deployment:** Render (ideasia.onrender.com)  
**Tech Stack:** Express + Supabase/PostgreSQL + JWT auth  
**GitHub:** https://github.com/nulljosh/ideasia

**What's Wrong:**
- Backend adds deployment complexity (env vars, database setup, hosting costs)
- Supabase + Express is overkill for what it does
- Render deployment has been problematic
- Database migrations are manual and error-prone

**What It Does:**
- User auth (JWT)
- Post ideas
- Vote on ideas (upvote/downvote)
- Milestone tracking (10, 100, 1000 upvotes)
- Categories (Tech, Business, Social, etc.)

**Why Backend Exists:**
- Auth (login/register)
- Vote counting
- User sessions

**The Problem:**
All of this can be done client-side with Supabase.

---

### ideasia: Migration Options

#### Option 1: Nuke Backend → Client-Only (RECOMMENDED ✅)

**Strategy:** Rewrite to Supabase client SDK (no Express server)

**How it works:**
- Supabase handles auth (built-in)
- Supabase handles database (direct client queries)
- Supabase handles real-time subscriptions
- Deploy as static site (GitHub Pages or Vercel)

**Migration Steps:**

1. **Set up Supabase project**
   ```bash
   # Already have Supabase project? Use existing.
   # Otherwise: Create new project at supabase.com
   ```

2. **Rewrite frontend to use Supabase client**
   ```bash
   npm install @supabase/supabase-js
   ```

   ```javascript
   import { createClient } from '@supabase/supabase-js'
   
   const supabase = createClient(
     process.env.VITE_SUPABASE_URL,
     process.env.VITE_SUPABASE_ANON_KEY
   )
   
   // Auth
   const { data, error } = await supabase.auth.signUp({
     email: 'user@example.com',
     password: 'password'
   })
   
   // Query posts
   const { data: posts } = await supabase
     .from('posts')
     .select('*')
     .order('created_at', { ascending: false })
   
   // Upvote
   const { data } = await supabase.rpc('upvote_post', { post_id: 'abc' })
   ```

3. **Migrate database schema**
   - Copy `database/combined-setup.sql` to Supabase SQL Editor
   - Add Row Level Security (RLS) policies:
     ```sql
     -- Users can only update their own posts
     CREATE POLICY "Users can update own posts"
       ON posts FOR UPDATE
       USING (auth.uid() = user_id);
     
     -- Anyone can read posts
     CREATE POLICY "Anyone can read posts"
       ON posts FOR SELECT
       USING (true);
     ```

4. **Convert to Vite app**
   ```bash
   npm create vite@latest ideasia-v2 -- --template react
   cd ideasia-v2
   npm install @supabase/supabase-js
   ```

   Copy over:
   - `/public` assets
   - Frontend logic from `/routes` and `/api`
   - Rewrite API calls to Supabase client calls

5. **Deploy**
   ```bash
   npm run build
   vercel --prod
   # Or: Push to GitHub, enable GitHub Pages on /dist
   ```

**Pros:**
- No backend to maintain
- No Express, no JWT complexity
- Deploy as static site (like WikiScroll)
- Supabase free tier is generous
- Real-time features available

**Cons:**
- Rewrite effort (~2-4 hours)
- Need to learn Supabase client SDK (but it's simple)

**Time estimate:** 1 day (if focused)

---

#### Option 2: Simplify Backend

**Strategy:** Keep Express but make deployment easier

**Changes:**
- Switch from Render to **Railway** or **Fly.io** (better DX)
- Use **Railway PostgreSQL** instead of Supabase (single provider)
- Simplify deployment to one command

**Pros:**
- Keep existing backend code
- Less rewrite work

**Cons:**
- Still have backend to maintain
- Still paying for hosting
- Railway free tier is limited

**Time estimate:** 2-4 hours (migration + testing)

---

#### Option 3: Scrap & Rebuild

**Strategy:** Start fresh with proven stack (WikiScroll pattern)

**Pros:**
- Apply all lessons learned
- Clean codebase
- Ship in 1 day

**Cons:**
- Lose existing code
- Have to rebuild features

**Time estimate:** 1 day (if starting from WikiScroll template)

---

### ideasia: Recommended Path

**Go with Option 1: Client-only Supabase migration**

**Why:**
- Aligns with what works (static sites)
- Eliminates deployment headaches
- Future-proof (scales to millions of users)
- Supabase is modern, well-documented, and free

**Execution Plan:**

**Phase 1: Prep (30 min)**
1. Read Supabase docs: https://supabase.com/docs/guides/auth
2. Create new Supabase project (or use existing)
3. Run database schema in Supabase SQL Editor

**Phase 2: Build (2-3 hours)**
1. Create new Vite app
2. Install Supabase client
3. Migrate auth logic
4. Migrate posts/voting logic
5. Add RLS policies

**Phase 3: Test (1 hour)**
1. Test auth flow
2. Test posting/voting
3. Test on mobile

**Phase 4: Deploy (30 min)**
1. Build for production
2. Deploy to Vercel or GitHub Pages
3. Update DNS if using custom domain

**Total time:** 4-5 hours (one focused session)

---

## Lessons Learned

### ✅ What Works

**Pattern:** Vite + React + Public APIs + Static Hosting

**Examples:**
- WikiScroll (Wikipedia API → GitHub Pages) ✅
- bread (Yahoo Finance API → Vercel) ✅
- finn (Static HTML → GitHub Pages) ✅

**Why it works:**
- No backend = no deployment complexity
- No database = no migrations
- No env vars = no secrets management
- Git push = instant deploy
- Free hosting (GitHub Pages, Vercel, Netlify)

**Golden rule:** If you can hit a public API from the browser, do that instead of building a backend.

---

### ❌ What Doesn't Work

**Pattern:** Express + Database + Cloud Hosting

**Examples:**
- ideasia (Express + Supabase + Render) ❌

**Why it fails:**
- Multiple services to configure (backend, database, hosting)
- Env vars need to be set in multiple places
- Database migrations are manual
- Backend needs to stay running (costs $)
- Debugging requires tailing logs in web UI
- Render/Vercel free tiers have cold starts

**Avoid unless:** You genuinely need server-side logic (auth tokens, rate limiting, etc.)

---

### 🤔 When to Use a Backend

**Only if you need:**
- **Server-side secrets** (API keys that can't be exposed)
- **Rate limiting** (prevent abuse)
- **Complex auth** (OAuth, JWT refresh tokens)
- **Server-side rendering** (SEO-critical dynamic pages)
- **Webhooks** (receive POST requests from third parties)

**For ideasia:** None of these apply. Supabase client handles auth + database.

---

## Tools That Ship Fast

| Tool | Use Case | DX Rating |
|------|----------|-----------|
| **Vite** | Frontend bundler | ⭐⭐⭐⭐⭐ Fast, simple |
| **GitHub Pages** | Static hosting | ⭐⭐⭐⭐⭐ Git push = deploy |
| **Vercel** | Static + serverless | ⭐⭐⭐⭐ Good, but URL issues |
| **Supabase** | Database + auth (client-only) | ⭐⭐⭐⭐ Great for static apps |
| **Railway** | Backend hosting | ⭐⭐⭐ Better than Render |
| **Render** | Backend hosting | ⭐⭐ Free tier cold starts |
| **Docker** | Containerization | ⭐ Overkill for solo projects |

---

## Deployment Checklist

### Before You Build

- [ ] Can this be static? (If yes, build static)
- [ ] Can I use a public API? (If yes, no backend needed)
- [ ] Do I need a database? (If yes, can Supabase client handle it?)
- [ ] Do I need server-side logic? (If no, don't build a backend)

### For Static Sites

- [ ] Initialize with Vite (`npm create vite@latest`)
- [ ] Use GitHub Pages or Vercel for hosting
- [ ] Set up deploy script: `npm run build && vercel --prod`
- [ ] Test on mobile (use Vercel preview URLs)

### For Apps with Databases

- [ ] Use Supabase (client-only, no backend)
- [ ] Set up RLS policies (secure by default)
- [ ] Store env vars in `.env.local` (Vite auto-loads)
- [ ] Still deploy as static (Supabase API calls are client-side)

### For Backends (if absolutely necessary)

- [ ] Use Railway or Fly.io (not Render)
- [ ] Keep backend minimal (thin API layer)
- [ ] Use Railway PostgreSQL (single provider = simpler)
- [ ] Set up Railway CLI for one-command deploys

---

## Next Actions

**This Week:**

1. **finn:** ✅ Done (leave as-is)

2. **bread:** 🟡 Fix Vercel URL
   ```bash
   cd ~/projects/bread
   # Edit vercel.json, set "name": "bread"
   vercel --prod
   ```

3. **ideasia:** 🔴 Decide on migration path
   - Read this plan
   - Choose Option 1 (client-only) or Option 2 (simplify backend)
   - Block 4-5 hours for migration

**This Month:**

- Consider WikiScroll v2 features
- Plan iOS version of bread (research React Native vs. Swift)
- Archive old projects that aren't shipping

**Long-term:**

- Build a project template (Vite + React + Supabase)
- Reuse template for future ideas (ship in hours, not days)

---

## Resources

### Docs
- [Supabase Auth Guide](https://supabase.com/docs/guides/auth)
- [Supabase Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)
- [Vercel Deployment](https://vercel.com/docs/deployments/overview)

### Inspiration
- WikiScroll source: https://github.com/nulljosh/wikiscroll
- bread source: https://github.com/nulljosh/bread

---

## Questions?

Ask Claude (me) to:
- Walk through Supabase migration step-by-step
- Debug deployment issues
- Review code before shipping
- Generate Vercel config files

---

**End of Plan** 🐾
