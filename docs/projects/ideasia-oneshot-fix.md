# Ideasia One-Shot Fix Command

**Paste this entire block into Claude Code or Claude Chrome:**

---

## Task

Fix ideasia deployment on Render. It's currently timing out (not responding).

**Repo:** https://github.com/nulljosh/ideasia  
**Live URL (broken):** https://ideasia.onrender.com  
**Render Dashboard:** https://dashboard.render.com

---

## Steps (Do All Automatically)

### 1. Check Render Logs

Go to https://dashboard.render.com → ideasia service → Logs tab  
Look for:
- Startup errors
- Database connection failures
- Port binding issues
- Any crashes

**Report what you find.**

---

### 2. Verify Supabase Database

**Supabase Project:** https://supabase.com/dashboard/project/tjsxsqlxjmanwvmywwvw

**Check:**
1. SQL Editor → Run: `SELECT * FROM users LIMIT 1;`
2. If error "relation does not exist" → tables not created
3. If tables exist → check if populated

**If tables missing:**
- Go to SQL Editor
- Copy contents of `database/combined-setup.sql` from repo
- Paste and run

---

### 3. Fix Common Issues

**If app won't start:**

**Issue A: Port mismatch**
- `render.yaml` says PORT=10000
- `app.js` might be hardcoded to 3030
- Fix: Update `app.js` to use `process.env.PORT || 3030`

**Issue B: Database connection**
- Verify `DATABASE_URL` in Render env vars matches Supabase
- Should be: `postgresql://postgres:demo123demo!@db.tjsxsqlxjmanwvmywwvw.supabase.co:5432/postgres`

**Issue C: Missing JWT_SECRET**
- If not set, generate one: `openssl rand -base64 64`
- Add to Render env vars

---

### 4. Redeploy

After fixing:
- Render dashboard → Manual Deploy → Deploy latest commit
- Or: Push empty commit to trigger deploy
  ```bash
  git commit --allow-empty -m "Trigger redeploy"
  git push origin main
  ```

---

### 5. Test

Once deployed:
- Visit https://ideasia.onrender.com
- Should see signup/login page
- Create account → verify it works
- Create post → verify voting works

---

## Expected Result

Working ideasia site at https://ideasia.onrender.com with:
- User registration 
- Post creation 
- Voting 
- No errors 

---

## Credentials

**Supabase (from render.yaml):**
- URL: https://tjsxsqlxjmanwvmywwvw.supabase.co
- Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
- DB Password: demo123demo!

**Render:**
- Joshua is logged in at dashboard.render.com

**GitHub:**
- https://github.com/nulljosh/ideasia

---

## Report Back

After completing, tell me:
1. What was broken
2. What you fixed
3. Current status (live URL + test results)

**GO!** 
