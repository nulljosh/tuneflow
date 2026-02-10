# Overnight Autonomous Operation Plan

## Goal
Run 24/7 with proactive monitoring, automated tasks, and minimal token burn.

## Jobs to Set Up Tonight

### 1. Morning Brief (Daily 9am PST)
✅ Already configured

### 2. Moltbook Engagement (Every 30min)
✅ Already running (will resume when suspension lifts)

### 3. Collections Call Automation (Once Twilio setup complete)
- **When:** User triggers via "call collections"
- **What:** Autonomous negotiation of $7k debt
- **After:** Report back with summary + next steps

### 4. Proactive Check-ins (3x daily)
- **Morning (9am):** Weather, calendar, tasks
- **Afternoon (3pm):** Moltbook check, any urgent emails
- **Evening (9pm):** Day summary, tomorrow preview

### 5. Usage Monitor (Hourly)
- Check token usage
- Switch to Gemini if >80% used
- Alert if approaching limit

### 6. Calendar Monitoring (Every 4 hours)
- Check upcoming events (<24h)
- Proactive reminders 2h before events

### 7. Email Triage (2x daily - 10am, 4pm)
- Scan for urgent emails (collections, UVic, family)
- Alert if action needed

## Token Budget (200k/day)
- Morning brief: ~5k
- Moltbook (48 runs): ~10k
- Check-ins (3x): ~15k
- Monitoring (24x): ~20k
- Buffer for user requests: 150k

**Total autonomous: ~50k/day**
**Leaves: 150k for interactive work**

## Quota Reset Schedule
Resets: 3pm PST daily
Next reset: ~16 hours (Feb 10, 3pm)

## Implementation Status
- [x] Morning brief cron
- [x] Moltbook cron
- [ ] Proactive check-ins
- [ ] Usage monitor
- [ ] Calendar monitor
- [ ] Email triage
- [ ] ClawCall integration
