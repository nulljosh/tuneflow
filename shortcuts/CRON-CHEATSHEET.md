# ⏰ Cron Dashboard Cheat Sheet

## One-Liners

```bash
# View
cron-dashboard                           # List all
cron-dashboard enabled                   # Enabled only
cron-dashboard stats                     # Stats + next 5

# Monitor
cron-dashboard watch                     # Real-time (5s refresh)
cron-dashboard watch 2                   # Real-time (2s refresh)

# Details
cron-dashboard detail "Morning briefing"  # One job
cron-dashboard json | jq '.[0]'         # First job as JSON

# Export
cron-dashboard csv > jobs.csv            # CSV export
cron-dashboard html ~/report.html        # HTML report
cron-dashboard json --pretty             # Pretty JSON

# Web
cron-web-server                          # Start web UI
cron-web-server &                        # Start in background
CRON_PORT=9000 cron-web-server           # Custom port

# Help
cron-dashboard help                      # All commands
cron-dashboard --help                    # Same
```

## Command Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `list` | All jobs (default) | `cron-dashboard` |
| `enabled` | Only enabled | `cron-dashboard enabled` |
| `disabled` | Only disabled | `cron-dashboard disabled` |
| `detail` | Full job info | `cron-dashboard detail "name"` |
| `watch` | Real-time monitor | `cron-dashboard watch [seconds]` |
| `stats` | Overview + next runs | `cron-dashboard stats` |
| `json` | JSON export | `cron-dashboard json [--pretty]` |
| `csv` | CSV export | `cron-dashboard csv` |
| `html` | HTML report | `cron-dashboard html [file]` |
| `help` | Show help | `cron-dashboard help` |

## Web Dashboard

```bash
cron-web-server              # Start server
# Open: http://localhost:8765

# API endpoints:
curl http://localhost:8765/api/jobs     # All jobs (JSON)
curl http://localhost:8765/health       # Server health
```

## Watch Mode

```bash
cron-dashboard watch        # Every 5 seconds (default)
cron-dashboard watch 1      # Every 1 second (fast)
cron-dashboard watch 10     # Every 10 seconds (slow)
# Press Ctrl+C to stop
```

## Symbols Explained

| Symbol | Meaning |
|--------|---------|
|  | Job enabled, will run |
| ⏸️ | Job disabled, won't run |
|  | Last run succeeded |
|  | Last run failed |
| — | Not scheduled / Never run |

## Time Format Examples

```
Feb 11, 2026, 09:00:00 AM      → Next run date/time
20h 52m                         → In 20 hours, 52 minutes
5m 26s                          → In 5 minutes, 26 seconds
Past due                        → Should have run already
Never                           → Never executed
```

## Schedule Types

| Type | Example | Meaning |
|------|---------|---------|
| Cron | `09:00 daily` | Runs every day at 9 AM |
| Cron | `Every 10m` | Runs every 10 minutes |
| At | `Mar 6, 2026 6:00 PM` | Runs once at that time |
| Every | `Every 30m` | Runs every 30 minutes |

## Useful Filters

```bash
# Find jobs running today
cron-dashboard stats | grep "Next"

# Find failed jobs
cron-dashboard json | jq '.[] | select(.state.lastStatus == "error")'

# Find jobs by name
cron-dashboard detail "send"              # Partial match (case-insensitive)

# Count enabled jobs
cron-dashboard json | jq '[.[] | select(.enabled == true)] | length'

# Export just enabled jobs
cron-dashboard json | jq '.[] | select(.enabled == true)' > enabled.json
```

## Tips & Tricks

**Quick daily check:**
```bash
cron-dashboard stats
```

**Monitor in terminal:**
```bash
cron-dashboard watch &          # Background
# Do other work...
# Brings updates to your attention
```

**Track changes over time:**
```bash
cron-dashboard json > jobs-$(date +%Y%m%d-%H%M).json
# Run daily, compare snapshots
```

**Share a report:**
```bash
cron-dashboard html ~/Desktop/report.html
# Email ~/Desktop/report.html to team
```

**Check next 5 runs:**
```bash
cron-dashboard stats
# Shows "Next 5 Runs" section
```

**Find a specific job:**
```bash
cron-dashboard detail "morning"     # Partial name match
cron-dashboard detail "12ca412a"    # Or full job ID
```

**Get JSON for scripts:**
```bash
cron-dashboard json | jq '.[] | select(.name | contains("send"))'
# Use with other tools
```

## Setup for Repeated Use

Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Path for cron tools
export PATH="$PATH:$HOME/.openclaw/workspace/shortcuts"

# Useful aliases
alias cron-watch='cron-dashboard watch 3'
alias cron-stats='cron-dashboard stats'
alias cron-web='cron-web-server'
```

Then restart terminal, use:
```bash
cron-watch          # Real-time monitor
cron-stats          # Quick stats
cron-web            # Web UI
```

## Troubleshooting

**"cron-dashboard: command not found"**
```bash
# Full path:
~/.openclaw/workspace/shortcuts/cron-dashboard

# Or add to PATH:
export PATH="$PATH:$HOME/.openclaw/workspace/shortcuts"
```

**"Failed to read cron config"**
```bash
# Check if gateway is running:
openclaw gateway status

# Should show: Runtime: running
```

**Web server won't start**
```bash
# Port 8765 might be in use
lsof -i :8765

# Try custom port:
CRON_PORT=8766 cron-web-server
```

**"Job not found"**
```bash
# Use exact name (case-insensitive partial works)
cron-dashboard detail "morning"  # Finds "Morning briefing"

# Or use job ID:
cron-dashboard detail "12ca412a-1252-46bb-819d-..."
```

## Performance

| Operation | Time |
|-----------|------|
| List 21 jobs | ~100ms |
| Watch refresh | ~200ms |
| HTML generation | ~300ms |
| CSV export | ~150ms |
| Web server start | ~50ms |
| Web page refresh | 5 seconds |

## Common Workflows

**Morning routine:**
```bash
cron-dashboard stats        # See what's running today
cron-dashboard enabled      # Check enabled jobs
```

**Debug a job:**
```bash
cron-dashboard detail "job-name"    # See full details
cron-dashboard watch 2              # Monitor it
```

**Create backup:**
```bash
cron-dashboard json > ~/backups/cron-$(date +%Y%m%d).json
```

**Share status:**
```bash
cron-dashboard html ~/report.html
# Email report.html
```

**Monitor in background:**
```bash
cron-dashboard watch 10 &
# [1] 12345  (shows job ID)
# fg           (bring to foreground if needed)
```

---

**Full Docs:** See `CRON-DASHBOARD-README.md` or run `cron-dashboard help`
