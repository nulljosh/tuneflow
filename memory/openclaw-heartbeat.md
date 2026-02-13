# OpenClaw Heartbeat Status
*Last updated: 2026-02-11 late night*

## TL;DR

**Status:** ✅ Working (on local fallback)

**What's happening:**
- OpenClaw's Anthropic API credits exhausted
- Falling back to local qwen model (slower but free)
- Morning news automation running (7:45 AM daily)

## ELI5: Why You're Seeing "Billing Errors"

**Two separate Claude systems:**

1. **Your personal Claude Max 5x** ($136.60/mo)
   - What you're using in Claude Code right now
   - Has tons of usage left (3% weekly)
   - This is YOUR Netflix account

2. **OpenClaw's API key** (separate account)
   - What OpenClaw uses to talk to Claude
   - OUT OF CREDITS (causes billing errors)
   - This is a completely different Hulu account

**Why it still works:** Automatic fallback chain

```
Try Sonnet → FAIL (no credits)
  ↓
Try Haiku → FAIL (same account, no credits)
  ↓
Try Gemini → FAIL (free tier quota exhausted, 20/day limit)
  ↓
Use qwen LOCAL → ✅ WORKS (slow but free)
```

## What You Get with Each Model

| Model | Speed | Quality | Cost | Tool Use | Current Events |
|-------|-------|---------|------|----------|----------------|
| **Sonnet 4.5** | Fast | Excellent | Paid | ✅ | ✅ (Jan 2025) |
| **Haiku 4.5** | Very Fast | Good | Paid | ✅ | ✅ (Jan 2025) |
| **Gemini 2.5** | Fast | Good | Free* | ❌ Broken | ❌ (Mid 2024) |
| **qwen local** | Slow | Weak | Free | ✅ | ❌ (Old) |

*Free tier = 20 requests/day, then quota exhausted

## Current Automation Schedule

- **7:45 AM** - Morning news digest (HN, Reddit, Twitter)
- **Daily** - Full Disk Access permission check
- **Nightly** - Journal backup

## Fix Options

**Option 1: Do Nothing** (current)
- Let it use qwen (local, free, weak but functional)
- Good for basic questions, not great for complex tasks

**Option 2: Add OpenClaw API Credits**
- Costs money
- Defeats the purpose of local fallback
- Not recommended

**Option 3: Wait for Gemini Quota Reset**
- Resets daily
- But only 20 requests/day
- Still can't use tools properly

**Recommendation:** Stick with Option 1. qwen is good enough for iMessage chats.

## Common Issues

### "API provider returned a billing error"
- **Not your fault** - OpenClaw's API credits out
- **Will still work** - falls back to qwen
- **Just slower** - local model takes longer

### Agent seems dumber lately
- **Yep** - qwen is way weaker than Claude
- **Expected** - 0.5B params vs Claude's billions
- **Temporary** - Gemini quota resets daily

### Messages taking forever
- **Normal** - local model processing
- **Wait it out** - qwen is slow but functional
- **Alternative** - use claude.ai/new for urgent stuff

## Bottom Line

OpenClaw is working fine on local fallback. Expect:
- Slower responses (qwen is local, not cloud)
- Weaker reasoning (tiny model)
- But it's FREE and FUNCTIONAL

Your personal Claude subscription is untouched - this is OpenClaw's separate API account that ran out.
