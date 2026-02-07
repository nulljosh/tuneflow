---
name: macos-calendar
description: Manage macOS Calendar.app events and calendars via CLI. Use when user asks to create, list, check, or manage calendar events, availability, appointments, or schedules on macOS. Supports event creation, listing upcoming events, and calendar management.
---

# macOS Calendar

Manage native Calendar.app on macOS using AppleScript bridge.

## Quick Reference

**List all calendars:**
```bash
python3 scripts/calendar_cli.py list-calendars
```

**List upcoming events (next 7 days):**
```bash
python3 scripts/calendar_cli.py list-events
```

**List events from specific calendar:**
```bash
python3 scripts/calendar_cli.py list-events --calendar "Work"
```

**List events for next 14 days:**
```bash
python3 scripts/calendar_cli.py list-events --days 14
```

**Create a new event:**
```bash
python3 scripts/calendar_cli.py create-event "Team Meeting" "2026-02-10T14:00:00" \
  --duration 60 \
  --calendar "Work" \
  --location "Conference Room A" \
  --notes "Discuss Q1 roadmap"
```

## Usage Patterns

### Check availability
List events for the requested timeframe and identify free slots.

### Create event
Use `create-event` with ISO datetime format. Default duration is 60 minutes.

### Find specific events
Use `list-events` with appropriate `--days` parameter and filter output.

## Notes

- Times use local system timezone
- ISO datetime format: `YYYY-MM-DDTHH:MM:SS`
- Script requires macOS with Calendar.app
- May require Automation permissions on first run
