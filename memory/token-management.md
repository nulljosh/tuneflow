# Token Management & Monitoring

## Daily Limits
- **Daily quota**: 200,000 tokens (resets at 3pm PST)
- **Average usage**: ~30-40k tokens/day (normal operations)
- **Danger zone**: >150k tokens before reset

## Token Burn Sources (Highest to Lowest)
1. **Cron jobs with context** - Each isolated session loads full system prompt
2. **Long sessions** - Context accumulates over time
3. **Sub-agent spawns** - Each gets full context
4. **Browser automation** - Snapshots are token-heavy
5. **Memory searches** - Semantic search on large files

## Cost Reduction Strategies
1. **Disable unnecessary cron jobs** - Each one burns tokens on schedule
2. **Use shorter system prompts for isolated tasks**
3. **Clear old sessions regularly**
4. **Prefer APIs over browser automation**
5. **Use memory_get instead of reading full files**
6. **Keep HEARTBEAT.md minimal**

## Monitoring Commands
```bash
# Check current usage
openclaw status

# Session-specific usage
📊 session_status

# List all sessions with token counts
sessions_list
```

## Emergency Actions
If approaching limit:
1. Kill all cron jobs: `cron list` then remove each
2. Clear old sessions
3. Switch to cheaper model temporarily
4. Disable heartbeats if needed

## Auto-Alerts
Set up usage alerts at key thresholds:
- 50% (100k) - Info
- 75% (150k) - Warning
- 90% (180k) - Critical

Last updated: 2026-02-11