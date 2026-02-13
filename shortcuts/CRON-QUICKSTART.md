#  Cron Dashboard Quick Start

## In 30 Seconds

```bash
# See all cron jobs
cron-dashboard

# Watch jobs update in real-time
cron-dashboard watch

# Or open web dashboard
cron-web-server
# → http://localhost:8765
```

Done! 

## Most Common Commands

```bash
# List all jobs
cron-dashboard

# Only show enabled jobs
cron-dashboard enabled

# See statistics and next runs
cron-dashboard stats

# Get details on a specific job
cron-dashboard detail "Morning briefing"

# Real-time monitor (updates every 5 seconds)
cron-dashboard watch

# Export to CSV, HTML, JSON
cron-dashboard csv > jobs.csv
cron-dashboard html ~/report.html
cron-dashboard json | jq .
```

## Using the Convenient Alias

If you want shorter commands:

```bash
export PATH="$PATH:$HOME/.openclaw/workspace/shortcuts"

# Now these all work:
cron                    # List jobs
cron enabled            # Enabled only
cron stats              # Statistics
cron watch              # Real-time monitor
cron web                # Start web server
cron detail "job name"  # Job details
```

Add to `~/.zshrc` or `~/.bashrc` to make it permanent.

## Understanding the Output

### Status Icons
-  = Job is enabled and will run
- ⏸️ = Job is disabled/paused
-  = Last run succeeded
-  = Last run failed

### Next Run Times
- "20h 52m" = In 20 hours, 52 minutes
- "5m 26s" = In 5 minutes, 26 seconds
- "Past due" = Job should have run already

### Job Info
- **Schedule** — When it runs (cron, one-time, or every N minutes)
- **Next run** — When it's scheduled to go next
- **Last run** — When it last executed and if it succeeded

## Typical Workflows

### Daily Check
```bash
cron-dashboard stats
```
Shows count of jobs and what's coming up.

### Monitor a Specific Job
```bash
cron-dashboard watch 2    # Updates every 2 seconds
# Or in background:
cron-dashboard watch &
```

### See what's running TODAY
```bash
cron-dashboard stats | grep "Next 5"
```

### Find a job by name
```bash
cron-dashboard detail "send-jokes"
```

### Share a report
```bash
cron-dashboard html ~/Desktop/report.html
# Email ~/Desktop/report.html to someone
```

## Web Dashboard

**Start it:**
```bash
cron-web-server
```

**Open in browser:**
```
http://localhost:8765
```

**Features:**
- Auto-refreshes every 5 seconds
- Shows 4 stat cards (total, enabled, last ok, last failed)
- Table with all jobs, schedules, and timings
- Live countdown to next runs
- Responsive design works on mobile too

**Stop it:** Press Ctrl+C

## Customizing

### Change web port
```bash
CRON_PORT=9000 cron-web-server
# → http://localhost:9000
```

### Change watch refresh speed
```bash
cron-dashboard watch 10    # Every 10 seconds
cron-dashboard watch 1     # Every 1 second (fast!)
```

## Troubleshooting

**No output?**
```bash
# Make sure gateway is running
openclaw gateway status
```

**Port 8765 already in use?**
```bash
# Try a different port
CRON_PORT=8766 cron-web-server
```

**Job not found when using detail?**
```bash
# Use partial name (case-insensitive) or exact job ID
cron-dashboard detail "morning"        # Finds "Morning briefing"
cron-dashboard detail "12ca412a-..."   # Use ID
```

## Full Documentation

See `CRON-DASHBOARD-README.md` for complete reference.

## Tips

 Use `watch` mode when debugging job timing
 Use `stats` for a quick daily overview  
 Use web server for a shared monitoring dashboard
 Use `csv` export to track history in spreadsheets
 Alias it in your shell for faster access

---

**Need more help?** Run: `cron-dashboard help`
