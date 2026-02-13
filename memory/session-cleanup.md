# Session Cleanup Notes

## Old iMessage Sessions
- Found old session: agent:main:main (48k tokens)
- Removed transcript: 5d7b9036-290a-4726-9fc8-dbdd199e9595.jsonl

## Auto-cleanup Strategy
Currently no built-in way to auto-kill old sessions. Options:
1. Manually remove transcript files when needed
2. Create cron job to clean old session files
3. Use /new to start fresh (leaves old sessions dormant)

Sessions only use RAM when dormant, not tokens.