# Ideasia → Supabase Client-Only Migration

**Time estimate:** 15-20 minutes (when you get home)  
**What you're doing:** Removing Express backend, switching to Supabase client-only

---

## Before You Start

**What I prepped for you:**
-  `supabase-schema.sql` - Complete database schema with RLS policies
-  `client-example.js` - Working auth/posts/voting code
-  This guide

**What you need:**
- Supabase account (free tier is fine)
- 15-20 minutes

---

## Step 1: Create Supabase Project (2 min)

1. Go to https://supabase.com
2. Sign in (or create account)
3. Click **New Project**
4. Fill in:
   - Name: `ideasia`
   - Database Password: (save this!)
   - Region: West US (closest to Vancouver)
5. Click **Create Project**
6. Wait ~2 minutes for it to spin up

---

## Step 2: Run Database Schema (1 min)

1. In Supabase dashboard, click **SQL Editor** (left sidebar)
2. Click **New Query**
3. Open `supabase-schema.sql` (in this folder)
4. **Copy entire file** and paste into SQL Editor
5. Click **Run** (bottom right)
6. You should see: `Success. No rows returned`

**What this did:**
- Created tables (users, posts, votes, milestones)
- Added indexes for performance
- Set up voting functions (upvote_post, downvote_post)
- Enabled Row Level Security (RLS)
- Added demo users (optional)

---

## Step 3: Get API Keys (1 min)

1. Click **Project Settings** (gear icon, bottom left)
2. Click **API** (in left menu)
3. Find these two values:
   - **Project URL** (copy it)
   - **anon public** key (copy it)

**Save them!** You'll need them in a sec.

---

## Step 4: Create New Vite App (2 min)

```bash
cd ~/projects
npm create vite@latest ideasia-v2 -- --template react
cd ideasia-v2
npm install
npm install @supabase/supabase-js
```

---

## Step 5: Set Up Environment Variables (1 min)

Create `.env.local` in your new project:

```bash
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key_here
```

Replace with your actual values from Step 3.

---

## Step 6: Copy Client Code (1 min)

1. Copy `client-example.js` to `src/lib/supabase.js`
2. Import it in your components:

```javascript
import { signIn, createPost, getPosts, upvotePost } from './lib/supabase'
```

---

## Step 7: Build a Quick Test Page (5 min)

Replace `src/App.jsx` with this:

```jsx
import { useState, useEffect } from 'react'
import { signIn, signUp, getPosts, createPost, upvotePost } from './lib/supabase'

function App() {
  const [posts, setPosts] = useState([])
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [user, setUser] = useState(null)

  useEffect(() => {
    loadPosts()
  }, [])

  async function loadPosts() {
    const data = await getPosts()
    setPosts(data)
  }

  async function handleSignUp() {
    try {
      await signUp('testuser', email, password)
      alert('Signed up! Now sign in.')
    } catch (error) {
      alert(error.message)
    }
  }

  async function handleSignIn() {
    try {
      const user = await signIn(email, password)
      setUser(user)
      alert('Signed in!')
    } catch (error) {
      alert(error.message)
    }
  }

  async function handleCreatePost() {
    const title = prompt('Post title:')
    const content = prompt('Post content:')
    if (title && content) {
      await createPost({ title, content, category: 'tech' })
      loadPosts()
    }
  }

  async function handleUpvote(postId) {
    await upvotePost(postId)
    loadPosts()
  }

  return (
    <div style={{ padding: '20px' }}>
      <h1>Ideasia v2</h1>
      
      {!user && (
        <div>
          <input placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} />
          <input placeholder="Password" type="password" value={password} onChange={e => setPassword(e.target.value)} />
          <button onClick={handleSignIn}>Sign In</button>
          <button onClick={handleSignUp}>Sign Up</button>
        </div>
      )}

      {user && (
        <div>
          <p>Signed in as {user.email}</p>
          <button onClick={handleCreatePost}>Create Post</button>
        </div>
      )}

      <h2>Posts</h2>
      {posts.map(post => (
        <div key={post.id} style={{ border: '1px solid #ccc', padding: '10px', margin: '10px 0' }}>
          <h3>{post.title}</h3>
          <p>{post.content}</p>
          <p>By: {post.author.username} | Score: {post.score} (↑{post.upvotes} ↓{post.downvotes})</p>
          {user && <button onClick={() => handleUpvote(post.id)}>Upvote</button>}
        </div>
      ))}
    </div>
  )
}

export default App
```

---

## Step 8: Test It (2 min)

```bash
npm run dev
```

Open http://localhost:5173

**Try:**
1. Sign up with a test account
2. Sign in
3. Create a post
4. Upvote it
5. Refresh - your vote should persist

**If it works:** You're done! Backend eliminated. 

---

## Step 9: Deploy (5 min)

### Option A: Vercel (easiest)

```bash
npm run build
vercel --prod
```

When prompted for env vars:
- Add `VITE_SUPABASE_URL`
- Add `VITE_SUPABASE_ANON_KEY`

### Option B: GitHub Pages

```bash
npm run build
# Push dist/ to gh-pages branch
```

---

## What Changed vs. Old ideasia

| Old (Express) | New (Supabase) |
|---------------|----------------|
| JWT auth logic | Supabase auth SDK |
| Express routes | Direct Supabase calls |
| PostgreSQL connection | Supabase client |
| Bcrypt password hashing | Handled by Supabase |
| Manual vote counting | RPC functions |
| Hosted on Render | Static site (Vercel/GH Pages) |
| Backend server cost | Free (Supabase free tier) |

---

## Common Issues

### "Invalid JWT"
- Check that your API keys are correct in `.env.local`
- Restart dev server after changing `.env.local`

### "User already exists"
- Email might be in use from previous test
- Try a different email or delete user in Supabase dashboard

### "Row Level Security policy violation"
- Make sure RLS policies were created (Step 2)
- Check Supabase logs: **Database → Logs**

---

## Next Steps

Once the basic version works:

1. **Port the old UI** - Copy styles/components from old ideasia
2. **Add categories filter** - Already in `getPosts({ category: 'tech' })`
3. **Add milestones** - Track when posts hit 10/100/1000 upvotes
4. **Real-time updates** - Use `subscribeToPostUpdates()` (already in client-example.js)
5. **Profile pages** - Show user's posts, karma, etc.

---

## Why This is Better

**Old way (Express):**
- Deploy backend to Render ($$$)
- Set up Supabase connection
- Write JWT logic
- Manage sessions
- Debug server logs
- Cold starts on free tier

**New way (Supabase client-only):**
- Deploy static site (free)
- Supabase handles auth
- No backend to maintain
- Instant deploys
- Scales to millions
- Works offline with local cache

**You just eliminated 90% of deployment complexity.** 

---

## Questions?

Ask me:
- How to add a feature (comments, user profiles, etc.)
- Debug RLS policies
- Optimize queries
- Add real-time subscriptions

I'll help when you get home! 
