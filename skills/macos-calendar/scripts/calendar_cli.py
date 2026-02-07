#!/usr/bin/env python3
"""
macOS Calendar.app CLI interface using AppleScript bridge
"""
import subprocess
import sys
import json
from datetime import datetime, timedelta
import argparse


def run_applescript(script):
    """Execute AppleScript and return output"""
    result = subprocess.run(
        ['osascript', '-e', script],
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        print(f"Error: {result.stderr}", file=sys.stderr)
        sys.exit(1)
    return result.stdout.strip()


def list_calendars():
    """List all available calendars"""
    script = '''
    tell application "Calendar"
        set calList to {}
        repeat with cal in calendars
            set end of calList to name of cal
        end repeat
        return calList
    end tell
    '''
    output = run_applescript(script)
    # Parse AppleScript list format
    cals = output.split(', ')
    for cal in cals:
        print(cal)


def list_events(calendar_name=None, days_ahead=7):
    """List upcoming events"""
    start_date = datetime.now()
    end_date = start_date + timedelta(days=days_ahead)
    
    cal_filter = f'name is "{calendar_name}"' if calendar_name else 'true'
    
    script = f'''
    tell application "Calendar"
        set startDate to (current date)
        set endDate to startDate + ({days_ahead} * days)
        set eventList to {{}}
        
        repeat with cal in (calendars where {cal_filter})
            repeat with evt in (events of cal whose start date ≥ startDate and start date ≤ endDate)
                set eventInfo to (summary of evt) & " | " & (start date of evt as string) & " | " & (name of cal)
                set end of eventList to eventInfo
            end repeat
        end repeat
        
        return eventList
    end tell
    '''
    output = run_applescript(script)
    if output:
        events = output.split(', ')
        for event in events:
            print(event)


def create_event(title, start_time, duration_minutes=60, calendar_name=None, location=None, notes=None):
    """Create a new calendar event"""
    # Parse start time
    try:
        start_dt = datetime.fromisoformat(start_time)
    except:
        print(f"Error: Invalid datetime format. Use ISO format: YYYY-MM-DDTHH:MM:SS", file=sys.stderr)
        sys.exit(1)
    
    end_dt = start_dt + timedelta(minutes=duration_minutes)
    
    cal_clause = f'calendar "{calendar_name}"' if calendar_name else 'default calendar'
    location_clause = f'set location of newEvent to "{location}"' if location else ''
    notes_clause = f'set description of newEvent to "{notes}"' if notes else ''
    
    script = f'''
    tell application "Calendar"
        tell {cal_clause}
            set newEvent to make new event with properties {{summary:"{title}", start date:date "{start_dt.strftime('%A, %B %d, %Y at %I:%M:%S %p')}", end date:date "{end_dt.strftime('%A, %B %d, %Y at %I:%M:%S %p')}"}}
            {location_clause}
            {notes_clause}
        end tell
        return "Event created: " & summary of newEvent
    end tell
    '''
    output = run_applescript(script)
    print(output)


def main():
    parser = argparse.ArgumentParser(description='macOS Calendar CLI')
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    # List calendars
    subparsers.add_parser('list-calendars', help='List all calendars')
    
    # List events
    list_parser = subparsers.add_parser('list-events', help='List upcoming events')
    list_parser.add_argument('--calendar', help='Filter by calendar name')
    list_parser.add_argument('--days', type=int, default=7, help='Days ahead to show (default: 7)')
    
    # Create event
    create_parser = subparsers.add_parser('create-event', help='Create a new event')
    create_parser.add_argument('title', help='Event title')
    create_parser.add_argument('start', help='Start time (ISO format: YYYY-MM-DDTHH:MM:SS)')
    create_parser.add_argument('--duration', type=int, default=60, help='Duration in minutes (default: 60)')
    create_parser.add_argument('--calendar', help='Calendar name')
    create_parser.add_argument('--location', help='Event location')
    create_parser.add_argument('--notes', help='Event notes/description')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    if args.command == 'list-calendars':
        list_calendars()
    elif args.command == 'list-events':
        list_events(args.calendar, args.days)
    elif args.command == 'create-event':
        create_event(args.title, args.start, args.duration, args.calendar, args.location, args.notes)


if __name__ == '__main__':
    main()
