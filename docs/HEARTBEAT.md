# HEARTBEAT.md

## Token Check (2x per day - noon & 8pm)
- If >75% usage: Alert with current stats
- If >90%: URGENT alert with reduction steps
- Otherwise: NO_REPLY

## Morning Check (once, around 9-10am)
- If haven't checked calendar today: Quick look at upcoming events (next 48h)
- NO_REPLY otherwise

## Rules
- Late night (11pm-8am): Always NO_REPLY unless critical
- Don't spam - quality over quantity
- If checked something recently (<4h ago), skip it
- Keep checks minimal to reduce token burn
