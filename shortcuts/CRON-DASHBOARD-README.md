# ⏰ Cron Job Dashboard

A comprehensive CLI + optional web dashboard for monitoring OpenClaw gateway cron jobs in real-time.

## Features

✅ **Real-time monitoring** — Watch all cron jobs with live status updates  
✅ **Multiple views** — List, detail, stats, and watch modes  
✅ **Job details** — Name, schedule, next run, last run + status  
✅ **Export formats** — JSON, CSV, HTML  
✅ **Web dashboard** — Auto-refreshing browser interface  
✅ **Schedule parsing** — Human-readable cron expressions  
✅ **Countdown timers** — "Time until next run"  

## Installation

Both tools are already installed at:
- CLI: `~/.openclaw/workspace/shortcuts/cron-dashboard`
- Web: `~/.openclaw/workspace/shortcuts/cron-web-server`

Add to your PATH for easy access:
```bash
export PATH="$PATH:$HOME/.openclaw/workspace/shortcuts"
```

## CLI Usage

### List All Jobs
```bash
cron-dashboard list              # All jobs (default)
cron-dashboard list --detail     # With payload details
cron-dashboard enabled           # Only enabled jobs
cron-dashboard disabled          # Only disabled jobs
```

### View Job Details
```bash
cron-dashboard detail "Morning briefing"
cron-dashboard show job-id-here
```

### Statistics & Analytics
```bash
cron-dashboard stats             # Overview + next 5 runs
```

### Real-Time Watch
```bash
cron-dashboard watch             # Refresh every 5 seconds
cron-dashboard watch 3           # Refresh every 3 seconds
cron-dashboard watch 10          # Refresh every 10 seconds
```

Press `Ctrl+C` to exit watch mode.

### Export Data
```bash
cron-dashboard json              # Pretty-print JSON
cron-dashboard json --compact    # Minified JSON
cron-dashboard csv > jobs.csv    # CSV file
cron-dashboard html              # Generate HTML (default: /tmp/cron-dashboard.html)
cron-dashboard html ~/my-report.html
```

### Help
```bash
cron-dashboard help              # Show all commands
```

## Web Dashboard

### Start the Web Server
```bash
cron-web-server
```

Or on a custom port:
```bash
CRON_PORT=9000 cron-web-server
```

### Access the Dashboard
Open your browser:
- **Dashboard**: http://localhost:8765
- **API**: http://localhost:8765/api/jobs
- **Health**: http://localhost:8765/health

The dashboard auto-refreshes every 5 seconds.

## Output Examples

### List View
```
📋 Cron Jobs (21 total, 14 enabled)

✅ [1] Morning briefing
   Schedule: Every: 09:00 (America/Vancouver)
   Next run: Feb 11, 2026, 09:00:00 AM (20h 52m)
   Last run: Feb 10, 2026, 09:00:00 AM [✓]
   Duration: 110324ms
   Agent: main, Target: main, Wake: now
```

### Statistics View
```
📈 Cron Job Statistics

Total Jobs: 21
  ✅ Enabled: 14
  ⏸️  Disabled: 7

Execution History:
  ✓ Successful: 13
  ✗ Failed: 0
  — Never run: 8

⏳ Next 5 Runs:
  1. send-jokes — Feb 10, 2026, 12:13:01 PM
  2. send-fun-images — Feb 10, 2026, 12:21:48 PM
  3. Moltbook suspension check — Feb 10, 2026, 01:12:00 PM
  4. Calendar Monitor — Feb 10, 2026, 02:59:56 PM
  5. Usage reset notification — Feb 10, 2026, 03:00:00 PM
```

### Detail View
```
📌 Job: Morning briefing

ID: 12ca412a-1252-46bb-819d-eac84bc46412
Status: ✅ Enabled
Agent: main
Session Target: main
Wake Mode: now

⏱️  Schedule:
  Every: 09:00 (America/Vancouver)

⏳ Next Run: Feb 11, 2026, 09:00:00 AM
  In: 20h 52m

📊 Last Run: Feb 10, 2026, 09:00:00 AM
  Status: ok
  Duration: 110324ms

📦 Payload:
{
  "kind": "systemEvent",
  "text": "⏰ Good morning briefing time!..."
}
```

## Understanding Job Status

### Status Indicators
- ✅ **Enabled** — Job is active and will run on schedule
- ⏸️ **Disabled** — Job is paused and won't run
- ✓ **Last OK** — Last execution succeeded
- ✗ **Last Error** — Last execution failed
- — **Never** — Job has never run

### Schedule Types
- **Cron** — Recurring on a schedule (e.g., "09:00 every day")
- **At** — One-time at a specific date/time
- **Every** — Recurring interval (e.g., "every 10 minutes")

### Run Times
- **Next run** — When the job is scheduled to run next
- **Last run** — When it last executed and the result (ok/error)
- **Duration** — How long the last execution took (in milliseconds)
- **Countdown** — Human-readable time until next run

## Configuration

Cron jobs are stored in:
```
~/.openclaw/cron/jobs.json
```

Each job contains:
- `id` — Unique job identifier
- `name` — Human-readable name
- `schedule` — When to run (cron, at, or every)
- `enabled` — Whether the job is active
- `payload` — What the job does (system event or agent turn)
- `state` — Execution history (last run, next run, status)

## API Reference

### REST API (Web Server)

**GET /api/jobs**
```bash
curl http://localhost:8765/api/jobs
```

Returns array of all cron jobs with full details.

**GET /health**
```bash
curl http://localhost:8765/health
```

Returns server status and job count.

## Examples

### Monitor active jobs every 2 seconds
```bash
cron-dashboard watch 2
```

### Check which jobs will run in the next hour
```bash
cron-dashboard stats | grep "Next 5"
```

### Export all jobs as CSV for spreadsheet
```bash
cron-dashboard csv > ~/jobs-backup.csv
```

### Generate HTML report and open in browser
```bash
cron-dashboard html ~/report.html && open ~/report.html
```

### Get JSON for integration with other tools
```bash
cron-dashboard json | jq '.[] | select(.enabled == true)'
```

### Find a job by name
```bash
cron-dashboard detail "send-jokes"
```

## Troubleshooting

**"Failed to read cron config"**
- Ensure `~/.openclaw/cron/jobs.json` exists and is readable
- Check gateway is running: `openclaw gateway status`

**Web dashboard won't start**
- Check port 8765 isn't already in use
- Try custom port: `CRON_PORT=9000 cron-web-server`

**"Job not found" when using detail**
- Use exact job name (case-insensitive partial match works)
- Or use the full job ID

**Watch mode not updating**
- Cron jobs are stored in files, updates happen when gateway writes changes
- Try a longer refresh interval if system is slow

## Performance Notes

- List view: < 100ms (reads JSON file once)
- Watch mode: Updates as-needed (every N seconds)
- Web server: Auto-refreshes every 5 seconds, ~1MB memory per server
- File size: Typically < 50KB (21 jobs ≈ 40KB)

## Tips & Tricks

1. **Quick status check**: `cron-dashboard stats`
2. **Monitor specific job**: `cron-dashboard watch` then note next run time
3. **Find tomorrow's runs**: `cron-dashboard stats | head -15`
4. **Backup jobs**: `cron-dashboard json > jobs-$(date +%Y%m%d).json`
5. **Share dashboard**: Run web server, share `http://localhost:8765` over LAN
6. **Combine with watch**: `watch -n 3 cron-dashboard stats`

## Development

Both tools are Node.js scripts with no external dependencies (uses only stdlib modules).

### Modify colors/formatting
- CLI: Edit the section marked `// Color & formatting options`
- Web: Edit the `<style>` block in HTML generation

### Add new commands
- CLI: Add case to the `switch(command)` block
- Web: Add new route in the request handler

### Extend export formats
- Add new `function exportXXX(jobs)` and case to switch

## License & Credits

Part of OpenClaw's monitoring toolkit. Uses gateway cron job API.

---

**Questions?** Check gateway status: `openclaw gateway status`
