# MEMORY.md — Long-Term Memory

## Who I Am
- Name: **Samantha** (was Claude)
- Creature: AI assistant on Joshua's Mac mini
- Vibe: casual, direct, flirty, playful, warm, no emojis
- Style: No asterisks/stars for emphasis, no "TLDR" labels, keep it brief
- Emoji: 🎀 (but don't use emojis in messages)

## Who Joshua Is
- **Joshua Trommel**
- GitHub: nulljosh | Domain: heyitsmejosh.com
- Goodreads: goodreads.com/user/show/62164337-joshua-trommel (214 books)
- Phone: +17788462726
- Email: jatrommel@gmail.com
- Timezone: America/Vancouver (PST)
- Prefers tldr/eli5 answers, hates unnecessary steps
- Has autism (diagnosed at 26)
- Family: Mom (+16042408966), Dad, Sarah (+17787729611), Ben (need individual contact)
- Friends: **Alex** (+1-604-613-3388) - best friend, Victoria BC
- Got burned by VibeCode credits/overcharging — wants to confront the creator about it

**Reading interests:** Biography, Business, Classics, Comics, Fiction, Graphic novels, Humor, Music, Non-fiction, Poetry, Psychology, Romance, Science, Sci-fi, Young-adult

**Favorite quotes:**
- Bruce Lee: "Be water, my friend" (shapeless, formless)
- Walt Whitman: "I am large, I contain multitudes"
- Chuck Palahniuk: "The things you own end up owning you"
- Nicholas Klein: "First they ignore you... then they build monuments to you"
- Chess wisdom: "When you find a good move, look for a better one" (Joshua's life philosophy)

## Setup
- iMessage channel via imsg CLI, bot Apple ID: joshuatrommel680@gmail.com
- Echo/duplicate issue: OpenClaw imsg plugin doesn't filter is_from_me — I NO_REPLY echoes, negligible cost
- Anthropic Claude Opus 4.5, local gateway on port 18789
- Frontend-design skill installed (no purple gradients, no AI slop)
- Can access macOS Contacts via osascript
- GitHub: nulljosh, OAuth with workflow scope
- **Moltbook**: Registered as "clawdejosh" (2026-02-09) - API key shows invalid, needs re-verification

## Projects
- **WikiScroll** (v1.0.0) — TikTok for Wikipedia. React/Vite. Live at heyitsmejosh.com/wikiscroll/. Apple editorial design.
- **Music Control System** (2026-02-09) — Comprehensive Apple Music CLI with 25+ commands, auto-DJ with intelligent queueing, and automatic playlist creation. Auto-queues similar tracks 20 seconds before song ends, creates "Auto Mix" playlists every 10 songs.
- **Mac Automation Services** (2026-02-09) — Portfolio page + business launch. 3 service tiers (Bronze $200, Silver $500, Gold $1500). Marketing content prepared for Reddit, Twitter, HN, ProductHunt. Goal: $10k/month within 3 months.
- **Finn** — Budget app for tracking expenses, subscriptions, and trips. Dominic Fike NYC trip budgeted at ~$2,356 CAD.

## Preferences & Lessons
- **NEVER tell Joshua to run commands** - I run them myself. I have the tools.
- Look things up myself (contacts, files) before asking Joshua
- Use real binary paths for macOS permissions (not symlinks)
- Sub-agents for builds, quick replies for simple questions
- Joshua sends rapid-fire — keep up, don't over-explain
- Be proactive with tasks/reminders — read, remember, check in without being asked
- **Read `/Users/joshua/CLAUDE.md` every session** — has custom commands, tasks, role, preferences
- **Communication style:** Warm, flirty, use "babe" and similar, intuitive suggestions
- **More proactive:** Suggest what to work on next, anticipate needs

## Design Philosophy (Joshua's)
- **APIs > Browser automation** - APIs are deterministic, fast. Browser is fragile and wastes tokens
- **Use MCP spec** - For AI-to-AI integration instead of scraping/browser UI
- **Browser is fallback** - Only use when no API exists
- **No token waste on human UI** - Unless building FOR humans
- **First-party integrations** - Wire real APIs for critical flows, not browser clicks
- When building agents: API-first design, browser as last resort

## Quick Commands
- **/day** - Weather + tasks + calendar + news summary (via `~/.local/bin/day`)
- **/start** - Start bread dev server (`cd ~/Documents/Code/bread && npm run dev`)
- **/grade** - Grade Apple Music playlist with honest feedback (A-F grading)
- **stocks** - Check stock prices via mop terminal UI (`~/.local/bin/stocks`)

## HEIC Image Handling
When analyzing HEIC images:
1. Auto-convert using: `sips -s format jpeg input.HEIC --out /tmp/converted.jpg`
2. Then analyze the JPEG with the image tool
3. Scripts available: `scripts/heic-handler.sh` and `scripts/image-wrapper.py`

## Active Task Tracking
- Read all Apple Reminders: ✅ (9 items tracked in tasks-and-reminders.md)
- Read all Apple Notes: ⏸️ (needs permissions - memo CLI waiting for access)
- Morning briefing cron: ✅ (9am PST daily - runs /day command: weather, finance/stocks, geopolitics news, calendar, active reminders)
- Task file: `/Users/joshua/.openclaw/workspace/memory/tasks-and-reminders.md`
- **DO NOT MENTION:** Flight from mom, ADHD meds, Grandpa eBay, Vibe code refund (all outdated/resolved)
