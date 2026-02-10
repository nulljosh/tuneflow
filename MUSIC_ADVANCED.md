# Music Control System - Advanced Guide

Deep dive into scripting, customization, and integration patterns.

## Scripting & Integration

### Getting Track Information

```bash
#!/bin/bash
# Extract track data for use in other scripts

# Get now playing
PLAYING=$(music now)

# Parse time information
ARTIST=$(music now | grep "👤" | cut -d' ' -f2-)
TRACK=$(music now | head -2 | tail -1)

# Check if playing
if [[ $PLAYING == "⏹️  Stopped" ]]; then
    echo "Music not playing"
    exit 1
fi

echo "Now: $TRACK - $ARTIST"
```

### Conditional Logic

```bash
#!/bin/bash
# Smart queue based on time of day

HOUR=$(date +%H)
CURRENT=$(music info)

case $HOUR in
    06-11)
        # Morning: Uplifting
        music genre indie
        music vol 50
        ;;
    12-16)
        # Afternoon: Focus
        music genre ambient
        music vol 30
        ;;
    17-20)
        # Evening: Social
        music genre electronic
        music vol 60
        ;;
    *)
        # Night: Chill
        music genre jazz
        music vol 40
        ;;
esac

dj start
```

### Loop Through Playlists

```bash
#!/bin/bash
# Process all playlists

PLAYLISTS=$(music playlist)

while IFS= read -r playlist; do
    echo "Processing: $playlist"
    music playlist "$playlist"
    sleep 2
    
    # Do something with this playlist
    # Example: Get first track
    FIRST=$(music now)
    echo "First: $FIRST"
done <<< "$PLAYLISTS"
```

## Error Handling

### Verify Music App

```bash
#!/bin/bash
# Robust music script with error handling

check_music_app() {
    if ! pgrep -x "Music" > /dev/null; then
        echo "❌ Music app not running"
        echo "Opening Music..."
        open -a Music
        sleep 2
    fi
}

safe_play() {
    check_music_app
    
    if ! music play "$1" 2>/dev/null; then
        echo "❌ Play failed for: $1"
        return 1
    fi
    echo "✅ Playing: $1"
    return 0
}

# Use safely
safe_play "Kanye West" || echo "Fallback: playing random"
```

### Retry Logic

```bash
#!/bin/bash
# Retry music commands on failure

retry_music() {
    local cmd="$1"
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        if music $cmd 2>/dev/null; then
            return 0
        fi
        ((retry++))
        sleep 1
    done
    
    echo "❌ Failed after $max_retries retries: $cmd"
    return 1
}

retry_music "play Ed Sheeran" || exit 1
```

## Advanced Auto-DJ

### Custom Queue Builder

```bash
#!/bin/bash
# Build queue based on loved tracks

LOVED=$(music search "loved")  # This is a pseudo-command
# Note: Real implementation would parse Music app's loved playlist

# Queue similar tracks
while IFS= read -r track; do
    ARTIST=$(echo "$track" | cut -d'-' -f2)
    music queue "$ARTIST"  # Queue more by artist
done <<< "$LOVED"

dj start
```

### Create Smart Playlists

```bash
#!/bin/bash
# Generate playlists by mood

create_mood_playlist() {
    local mood="$1"
    local genre="$2"
    
    music genre "$genre"
    sleep 1
    
    # Play it first to test
    music play
    sleep 5
    
    # Save as new playlist
    TIMESTAMP=$(date +%Y-%m-%d)
    music save "${mood} - ${TIMESTAMP}"
    
    echo "✅ Created: ${mood} - ${TIMESTAMP}"
}

create_mood_playlist "Morning Vibes" "indie"
create_mood_playlist "Work Focus" "ambient"
create_mood_playlist "Evening Chill" "jazz"
```

### Analyze Music Taste

```bash
#!/bin/bash
# Generate music statistics

echo "🎵 Music Analysis"
echo ""

echo "Top 10 Tracks:"
music top 10 | head -10
echo ""

echo "Top 25 Tracks:"
music top 25 | wc -l
echo ""

echo "Recent Activity (last 10):"
music recent
echo ""

echo "Favorite Genres:"
music info | grep "Genre" || echo "No info available"
```

## Integration Patterns

### Calendar-Based Music

```bash
#!/bin/bash
# Change music based on calendar events

get_next_event() {
    # Get next calendar event title
    osascript << 'EOF'
tell application "Calendar"
    set nextEvent to ?
    return summary of nextEvent
end tell
EOF
}

EVENT=$(get_next_event)

case "$EVENT" in
    *meeting*|*call*)
        music pause
        ;;
    *break*|*lunch*)
        music play "feel good"
        ;;
    *focus*|*deep*)
        music genre ambient
        music vol 30
        ;;
esac
```

### Location-Based Music

```bash
#!/bin/bash
# Change music based on location (requires Location Services)

# In practice, get from system location services
LOCATION=$(defaults read /Library/Preferences/com.apple.location.plist | grep Location || echo "unknown")

if [[ $LOCATION == *"gym"* ]]; then
    music genre electronic
    music vol 70
elif [[ $LOCATION == *"home"* ]]; then
    music genre indie
    music vol 40
fi
```

### Time-Based Music Scheduling

```bash
#!/bin/bash
# Schedule music changes throughout day

schedule_music() {
    local hour="$1"
    local genre="$2"
    
    # Use launchd to schedule
    cat > ~/Library/LaunchAgents/music-schedule-$hour.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.music.schedule.$hour</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>music genre $genre</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>$hour</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
EOF
    
    launchctl load ~/Library/LaunchAgents/music-schedule-$hour.plist
    echo "✅ Scheduled music change at $hour:00"
}

schedule_music 6 "indie"      # 6 AM: Indie
schedule_music 12 "ambient"   # 12 PM: Ambient
schedule_music 18 "electronic" # 6 PM: Electronic
```

## System Integration

### Alfred Workflow

```bash
# Create Alfred workflow for faster music commands
# Save as workflow in ~/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/

# Link music commands:
# Keyword: "play" → /path/to/music play {query}
# Keyword: "pause" → /path/to/music pause
# Keyword: "next" → /path/to/music next
```

### Keyboard Shortcuts

```bash
# Using Karabiner-Elements or similar:

# Cmd+Alt+Play → music play
# Cmd+Alt+Next → music next
# Cmd+Alt+Prev → music prev
# Cmd+Alt+Love → music love
```

### Spotlight Integration

```bash
# Add to Spotlight by creating an app launcher:

#!/bin/bash
# music-spotlight.app/Contents/MacOS/launcher

QUERY="$@"
/path/to/music play "$QUERY"
```

## Performance Optimization

### Caching Results

```bash
#!/bin/bash
# Cache playlist info to avoid repeated queries

CACHE_FILE="/tmp/music-playlists.cache"
CACHE_AGE=$(($(date +%s) - $(stat -f%m "$CACHE_FILE" 2>/dev/null || echo 0)))

if [ $CACHE_AGE -gt 3600 ]; then
    # Cache older than 1 hour, refresh
    music playlist > "$CACHE_FILE"
fi

# Use cached data
cat "$CACHE_FILE" | head -10
```

### Batch Operations

```bash
#!/bin/bash
# Process multiple operations efficiently

batch_rate_tracks() {
    # Start auto-DJ
    dj start
    
    # Rate multiple tracks without UI lag
    for track in "$@"; do
        music queue "$track"
        sleep 0.5  # Small delay to avoid lag
        music rating 5
    done
    
    dj stop
}

batch_rate_tracks "Track 1" "Track 2" "Track 3"
```

## Debugging & Logging

### Enable Verbose Logging

```bash
#!/bin/bash
# Add debug output to music commands

DEBUG_MUSIC() {
    echo "[DEBUG] $(date +'%Y-%m-%d %H:%M:%S') - $@" >> ~/.music-debug.log
    music "$@"
    echo "[RESULT] $?" >> ~/.music-debug.log
}

# Use instead of music
DEBUG_MUSIC play "test track"

# View log
tail -f ~/.music-debug.log
```

### Monitor Auto-DJ

```bash
#!/bin/bash
# Watch auto-DJ with timestamps

watch_dj_log() {
    while true; do
        clear
        echo "Auto-DJ Activity ($(date))"
        echo "================================"
        dj status
        echo ""
        echo "Recent:"
        tail -10 /tmp/auto-dj.log
        sleep 5
    done
}

watch_dj_log
```

## Custom Extensions

### Music Statistics Dashboard

```bash
#!/bin/bash
# Create a music stats dashboard

music_dashboard() {
    while true; do
        clear
        echo "🎵 Music Dashboard"
        echo "================="
        echo ""
        echo "Now Playing:"
        music now
        echo ""
        echo "Top 5 Tracks:"
        music top 5 | head -5
        echo ""
        echo "DJ Status:"
        dj status | head -1
        echo ""
        sleep 10
    done
}

music_dashboard
```

### Weekly Playlist Generator

```bash
#!/bin/bash
# Auto-generate weekly "best of" playlists

generate_weekly_best() {
    WEEK=$(date +%V)
    YEAR=$(date +%Y)
    
    music top 20 > /tmp/weekly-best.txt
    
    # Create playlist with top tracks
    music playlist "Weekly Best W${WEEK}-${YEAR}"
    
    echo "✅ Generated weekly playlist"
}

# Schedule weekly with cron
# 0 0 * * 0 /path/to/generate_weekly_best.sh
```

## Tips for Reliable Scripts

1. **Always check Music is running**
   ```bash
   pgrep -x "Music" || open -a Music
   ```

2. **Use timeouts**
   ```bash
   timeout 5 music now || echo "Timeout"
   ```

3. **Capture stderr**
   ```bash
   ERROR=$(music play "$TRACK" 2>&1)
   if [ $? -ne 0 ]; then
       echo "Error: $ERROR"
   fi
   ```

4. **Log important events**
   ```bash
   echo "$(date) - Action: $ACTION" >> ~/.music-history.log
   ```

5. **Test before automating**
   ```bash
   # Run script manually first
   bash script.sh
   # Only then add to cron
   ```

## Common Patterns

### Stop-and-Play Pattern
```bash
music pause
sleep 1
music play "new track"
```

### Queue-and-Wait Pattern
```bash
music queue "next track"
while [ "$(music now)" = "$(music now)" ]; do
    sleep 1
done
```

### Safe-Fallback Pattern
```bash
music play "$PRIMARY" || music play "$FALLBACK" || music play "random"
```

---

**Next:** See [MUSIC_SETUP.md](./MUSIC_SETUP.md) for basic usage, or [music](./music) for complete source code.
