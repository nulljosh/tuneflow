# Security Issues & Fixes

**Date:** 2026-02-07

---

## 🚨 OpenClaw Security Issues

### Issue 1: Memory Leakage Across Sessions

**Problem:**
- MEMORY.md loads for ALL sessions (main + iMessage contacts)
- Anyone texting Joshua's iMessage number can access his personal info
- Example: +17788407755 (zkml label guy) could ask "what's Joshua's schedule today?"

**Impact:** HIGH - Personal data exposed to strangers

**Fix Options:**

**Option A: Session-based memory filtering (recommended)**
```javascript
// In AGENTS.md, add conditional memory loading:

## Memory Loading Rules

MEMORY.md and memory/*.md should ONLY load when:
1. Session is "main" (direct OpenClaw chat)
2. Channel is "imessage" AND contact is in allowlist

DO NOT load memory for:
- Unknown phone numbers
- Group chats
- Public channels (Discord, etc.)
```

**Option B: Separate Apple IDs**
- Personal iMessage → Main account (has memory access)
- Public iMessage → Separate account (no memory)
- Requires second phone number or Apple ID

**Option C: Manual approval per number**
```bash
# Add to USER.md:
## Trusted Contacts (Memory Access)
- +17788462726 (Joshua - full access)
- Mom: +16042408966 (partial - calendar only)

## Public Contacts (No Memory)
- +17788407755 (stranger - no personal data)
```

**Recommendation:** Implement Option A + C together
- Default: NO memory access
- Allowlist specific numbers for memory
- Log all memory access attempts

---

### Issue 2: No Session Isolation

**Problem:**
- All iMessage contacts share the same agent session
- No per-user context separation
- Conversation history could leak between contacts

**Impact:** MEDIUM - Context bleeding between users

**Fix:**
Create session keys per phone number:
```javascript
// Instead of: agent:main:main
// Use: agent:main:imessage-17788462726
//      agent:main:imessage-17788407755
```

This requires OpenClaw config changes or gateway restart.

---

### Issue 3: File System Access

**Problem:**
- Assistant has read/write access to entire system
- Could accidentally expose sensitive files
- No sandboxing between projects

**Impact:** MEDIUM - Potential data leaks

**Fix:**
1. Create project-specific directories:
   ```
   ~/Projects/ideasia/
   ~/Projects/zkml-tool/
   ~/Projects/personal/ (restricted)
   ```

2. Add to AGENTS.md:
   ```markdown
   ## File Access Policy
   - ONLY access files in ~/Projects/ and ~/.openclaw/workspace/
   - NEVER read files in:
     - ~/Documents/Private/
     - ~/.ssh/
     - ~/.env files outside project dirs
   - ASK before accessing new directories
   ```

3. Use the healthcheck skill to audit file permissions

---

### Issue 4: No Authentication for Skills

**Problem:**
- Skills can execute arbitrary code
- No verification of skill source
- Could install malicious skill

**Impact:** HIGH - Code execution vulnerability

**Fix:**
1. Only install skills from trusted sources:
   - Official OpenClaw skills
   - Your own verified repos
   - Never install from unknown GitHub repos

2. Review skill code before installing:
   ```bash
   # Before installing:
   cat SKILL.md
   cat scripts/*.py
   ```

3. Use skill-creator skill to audit existing skills

---

## 🔒 Ideasia Security Issues

### Issue 1: No Input Validation (Critical)

**Problem:**
Current code has basic validation but needs strengthening:
- XSS attacks possible in idea descriptions
- SQL injection (MongoDB equivalent)
- File upload vulnerabilities (if added later)

**Fix:**
```javascript
// In app.js, add stricter validation:
const validator = require('validator');
const DOMPurify = require('isomorphic-dompurify');

// Sanitize all user input
app.post('/posts', (req, res) => {
  const { title, content } = req.body;
  
  // Validate
  if (!validator.isLength(title, { min: 5, max: 200 })) {
    return res.status(400).json({ error: 'Invalid title length' });
  }
  
  // Sanitize HTML
  const cleanContent = DOMPurify.sanitize(content, {
    ALLOWED_TAGS: ['b', 'i', 'u', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href']
  });
  
  // Save cleanContent to DB
});
```

**Install packages:**
```bash
npm install validator isomorphic-dompurify
```

---

### Issue 2: JWT Secret in .env

**Problem:**
- JWT_SECRET in .env could be exposed in Git
- Currently: `jwt_secret_change_me_in_production`
- .env file might get committed accidentally

**Fix:**
1. Add to .gitignore (already done, but verify):
   ```bash
   echo ".env" >> .gitignore
   ```

2. Generate strong secret:
   ```bash
   openssl rand -base64 64
   ```

3. Use environment variables in production:
   ```bash
   # On Vercel:
   # Settings → Environment Variables → JWT_SECRET
   ```

4. Add to README security section:
   ```markdown
   ## Security Setup
   1. NEVER commit .env to Git
   2. Generate strong JWT_SECRET: `openssl rand -base64 64`
   3. Rotate secrets every 90 days
   ```

---

### Issue 3: No Rate Limiting on AI Endpoints

**Problem:**
- `/ai/feedback` has 5/month limit but not enforced server-side
- Users could spam API, rack up Claude API costs
- Currently only rate limiting on auth (5/15min)

**Fix:**
```javascript
// Add to app.js:
const rateLimitAI = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5, // 5 requests per hour for free tier
  message: 'AI quota exceeded. Upgrade to paid tier.',
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => req.user.id // Rate limit per user
});

app.post('/ai/feedback', authenticate, rateLimitAI, async (req, res) => {
  // Existing logic
});
```

**For paid tiers:**
```javascript
const getRateLimit = (user) => {
  if (user.tier === 'starter') return 50; // 50/hour
  if (user.tier === 'launch') return 200;
  if (user.tier === 'scale') return 1000;
  return 5; // Free tier
};
```

---

### Issue 4: Stripe Webhook Security

**Problem:**
- Webhook endpoint `/payments/webhook` needs signature verification
- Without it, attackers could fake payment confirmations
- Currently not implemented

**Fix:**
```javascript
// In routes/payments.js:
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

app.post('/payments/webhook', 
  express.raw({ type: 'application/json' }), 
  async (req, res) => {
    const sig = req.headers['stripe-signature'];
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
    
    let event;
    
    try {
      event = stripe.webhooks.constructEvent(
        req.body, 
        sig, 
        webhookSecret
      );
    } catch (err) {
      console.log('Webhook signature verification failed:', err.message);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }
    
    // Handle event
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      // Unlock tier for user
    }
    
    res.json({ received: true });
  }
);
```

**Get webhook secret:**
```bash
stripe listen --forward-to localhost:3030/payments/webhook
# Copy the webhook signing secret to .env
```

---

### Issue 5: MongoDB Injection

**Problem:**
- Query parameters from user could execute arbitrary MongoDB commands
- Example: `GET /posts?category[$ne]=null` → returns all posts

**Fix:**
```javascript
// Use mongoose validation + sanitization:
const mongoSanitize = require('express-mongo-sanitize');

app.use(mongoSanitize()); // Removes $ and . from req.body/query/params

// Also validate ObjectIds:
const mongoose = require('mongoose');

app.get('/posts/:id', (req, res) => {
  if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
    return res.status(400).json({ error: 'Invalid ID format' });
  }
  // Continue with query
});
```

**Install:**
```bash
npm install express-mongo-sanitize
```

---

### Issue 6: No HTTPS Enforcement

**Problem:**
- Production should force HTTPS
- JWTs sent over HTTP are vulnerable

**Fix:**
```javascript
// In app.js (production only):
if (process.env.NODE_ENV === 'production') {
  app.use((req, res, next) => {
    if (req.header('x-forwarded-proto') !== 'https') {
      return res.redirect(`https://${req.header('host')}${req.url}`);
    }
    next();
  });
}
```

Vercel handles this automatically, but good to enforce.

---

### Issue 7: Exposed API Keys in Frontend

**Problem:**
- If Claude API key is used client-side, it's exposed
- Anyone can copy key from browser DevTools

**Fix:**
- NEVER put API keys in frontend code
- Always proxy AI requests through backend:
  ```
  Frontend → Backend API → Claude API
  ```
- Backend validates user auth before calling Claude

---

### Issue 8: No CORS Configuration

**Problem:**
- CORS is set to `FRONTEND_URL` in .env
- If misconfigured, allows any origin
- Could enable CSRF attacks

**Fix:**
```javascript
// In app.js, make CORS more strict:
const corsOptions = {
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));
```

---

## 🛡️ Security Checklist (Before Launch)

### OpenClaw
- [ ] Implement memory access allowlist
- [ ] Add session isolation per phone number
- [ ] Restrict file access to project directories
- [ ] Audit all installed skills
- [ ] Enable security skill for periodic checks
- [ ] Set up logging for sensitive operations

### Ideasia
- [ ] Add DOMPurify for XSS prevention
- [ ] Generate strong JWT_SECRET (64+ chars)
- [ ] Implement per-user AI rate limiting
- [ ] Add Stripe webhook signature verification
- [ ] Install express-mongo-sanitize
- [ ] Verify .env is in .gitignore
- [ ] Force HTTPS in production
- [ ] Restrict CORS to production domain
- [ ] Add CSP headers (Content Security Policy)
- [ ] Set up monitoring/alerts for suspicious activity

### Infrastructure
- [ ] Enable 2FA on GitHub
- [ ] Use environment variables (not .env) in production
- [ ] Set up backup strategy for MongoDB
- [ ] Enable Vercel deployment protection
- [ ] Add rate limiting to all public endpoints
- [ ] Implement logging (Winston or similar)

---

## 📋 Immediate Actions (Priority Order)

### Today
1. **OpenClaw:** Add memory access allowlist to USER.md
2. **Ideasia:** Add .env to .gitignore (verify)
3. **Ideasia:** Generate new JWT_SECRET

### This Week
4. **OpenClaw:** Implement session isolation
5. **Ideasia:** Add input sanitization (DOMPurify)
6. **Ideasia:** Add AI rate limiting per user
7. **Ideasia:** Implement Stripe webhook verification

### Before Launch
8. **Ideasia:** Full security audit with all fixes applied
9. **OpenClaw:** Enable healthcheck skill for monitoring
10. **Both:** Set up error logging and alerts

---

## 🔗 Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Express Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [Stripe Webhook Security](https://stripe.com/docs/webhooks/signatures)
- [MongoDB Security Checklist](https://www.mongodb.com/docs/manual/administration/security-checklist/)

---

**Next Steps:**
1. Review this document with Joshua
2. Prioritize fixes by impact
3. Implement immediate actions today
4. Schedule full security review before Ideasia launch
