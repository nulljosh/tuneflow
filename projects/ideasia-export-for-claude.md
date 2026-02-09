# Ideasia Project Context - Export for Claude Chrome

**Task:** Deploy ideasia to production (Render) - it should be one-shot but isn't working.

---

## Project Overview

**Name:** Ideasia  
**GitHub:** https://github.com/nulljosh/ideasia  
**Current URL:** https://ideasia.onrender.com (deployed but has issues)  
**Goal:** AI-powered idea marketplace with voting, milestones, auth

---

## Tech Stack

- **Backend:** Express.js, Node.js
- **Database:** Supabase (PostgreSQL)
- **Auth:** JWT + bcrypt
- **Deploy:** Render (configured via render.yaml)

---

## Current Status

**What works:**
- Code is complete (Express routes, auth, voting, posts)
- Database schema exists (`database/combined-setup.sql`)
- Render config exists (`render.yaml`)

**What's broken:**
- Deployment on Render is failing or not connecting properly
- Need to diagnose why one-shot deploy isn't working

---

## Repository Structure

```
ideasia/
├── app.js                 # Main Express server
├── package.json           # Dependencies
├── render.yaml            # Render deployment config (has Supabase creds)
├── schema.sql            # Database schema
├── database/
│   └── combined-setup.sql # Full DB setup with seed data
├── routes/               # API routes
├── middleware/           # Auth, validation
└── public/               # Static files
```

---

## render.yaml (Current Config)

```yaml
services:
  - type: web
    name: ideasia
    runtime: node
    buildCommand: npm install
    startCommand: node app.js
    envVars:
      - key: DATABASE_URL
        value: postgresql://postgres:demo123demo!@db.tjsxsqlxjmanwvmywwvw.supabase.co:5432/postgres
      - key: SUPABASE_URL
        value: https://tjsxsqlxjmanwvmywwvw.supabase.co
      - key: SUPABASE_KEY
        value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqc3hzcWx4am1hbnd2bXl3d3Z3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0OTc0MDEsImV4cCI6MjA4NjA3MzQwMX0.LphLfho3wdQC20MhtcnBpzQUNuBoTOobrugQbNGxc68
      - key: JWT_SECRET
        value: S7m/oEuXi7bUmm5kMjSH/sLU3eyopaTMtRNjmsiOHM/BAEgg1aASF0YCh6j6SqVV58ayiuiQzNmzr1bFg9RXRQ==
      - key: NODE_ENV
        value: production
      - key: PORT
        value: 10000
```

**⚠️ ISSUE:** Credentials are hardcoded in Git (security issue, but set aside for now)

---

## Expected Deployment Flow

1. Push code to GitHub (already done)
2. Go to render.com → New Web Service
3. Connect GitHub repo: `nulljosh/ideasia`
4. Render auto-detects `render.yaml`
5. Runs `npm install` → `node app.js`
6. Should be live at `ideasia.onrender.com`

---

## What I Need You To Do

1. **Diagnose why the current deployment isn't working**
   - Check Render dashboard logs
   - Verify Supabase connection
   - Check if database schema was run

2. **Fix deployment issues**
   - Is the DB populated? (Run `database/combined-setup.sql` in Supabase if not)
   - Are env vars correct?
   - Is the app starting but crashing?

3. **Get it live and working**

---

## Access Info

**Render:** Log in at render.com (Joshua should be logged in)  
**Supabase:** Credentials in render.yaml above  
**GitHub:** https://github.com/nulljosh/ideasia

---

## Success Criteria

- Visit https://ideasia.onrender.com
- Sign up for an account
- Create a post
- Upvote it
- Everything works

---

## Notes

- The app is **already configured for Render** (render.yaml exists)
- Database schema is ready (just needs to be run in Supabase)
- This should be a 5-10 minute fix, not a rebuild

**Don't rewrite the app. Just fix deployment.**

---

## Questions to Answer

1. Is Render even running the app? (Check logs)
2. Is Supabase connected? (Test DB connection)
3. Is the schema populated? (Check Supabase tables)
4. Are there any errors in Render logs?

---

**Once you've diagnosed, report back with:**
- What was broken
- What you fixed
- Current status (live URL working or not)

Go! 🚀
