# Context Monitor Cron Job

Auto-check OpenClaw context usage and send proactive warnings.

## Schedule

Every 2 minutes during active hours (7am-2am):
```cron
*/2 7-23,0-1 * * * ~/.openclaw/workspace/shortcuts/context-monitor check
```

## What it does

1. Checks current token usage for main session
2. Calculates percentage used (current/200k)
3. Sends warnings at 80%, 90%, 95% thresholds
4. Auto-saves context and triggers `/new` at 95% (if enabled)

## Installation

Add to crontab:
```bash
crontab -e
```

Add line:
```
*/2 7-23,0-1 * * * ~/.openclaw/workspace/shortcuts/context-monitor check
```

Or use the cron shortcut:
```bash
~/.openclaw/workspace/shortcuts/cron add "*/2 7-23,0-1 * * *" "~/.openclaw/workspace/shortcuts/context-monitor check"
```

## Manual commands

- `context-monitor status` - Show current usage
- `context-monitor check` - Run check now
- `context-monitor test-warning 80` - Test 80% warning notification
- `context-monitor reset` - Reset warning flags
