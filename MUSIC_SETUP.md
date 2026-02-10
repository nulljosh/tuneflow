# Music Control System - Setup & Usage Guide

Complete guide to the AI Music Control System with 25+ commands and intelligent auto-DJ.

## What It Does

Control Apple Music completely from the command line. Search, play, queue, rate, discover, and auto-DJ your music collection with natural language queries.

**Features:**
- ✅ 25+ commands for complete music control
- ✅ Intelligent auto-DJ with genre matching
- ✅ Smart playlist generation (every 10 songs)
- ✅ Search library with natural language
- ✅ Rating and love/unlike tracking
- ✅ Analytics: top tracks, recent plays
- ✅ Volume and playback mode control
- ✅ Full scripting support (use in other scripts)

## Installation

### 1. Copy Scripts

```bash
# From mac-automation-services folder
cp music ~/bin/music
cp dj ~/bin/dj
chmod +x ~/bin/music ~/bin/dj
```

Or add to PATH:
```bash
# Add to ~/.zshrc
export PATH="$PATH:~/Documents/Code/mac-automation-services"
```

### 2. Verify Installation

```bash
music now       # Should show current track
dj status       # Should say "not running"
```

### 3. Optional: Create Alias

```bash
# Add to ~/.zshrc for shorter commands
alias m="music"
alias d="dj"

# Reload shell
source ~/.zshrc
```

## Quick Start

### Play Music

```bash
# Play by song name
music play "Shape of You"

# Play by artist
music play Ed Sheeran

# Search and show results
music search "indie"

# Play artist's full catalog
music artist

# Play current album
music album

# Play by genre
music genre indie

# Play songs from year
music year 2020
```

### Queue & Playlists

```bash
# Queue next track
music queue "Feel Good Inc"

# Queue artist
music queue Gorillaz

# Show all playlists
music playlist

# Play specific playlist
music playlist "Workout Mix"

# Save current track to playlist
music save "My Favorites"

# Clear current queue
music clear
```

### Playback Control

```bash
# Play/pause/resume
music play
music pause
music resume

# Skip / Previous
music next
music prev

# Random track
music random

# Volume
music vol 50      # Set to 50%
music vol         # Show current

# Repeat modes
music repeat one  # Repeat current
music repeat all  # Loop playlist
music repeat off  # Normal

# Shuffle
music shuffle on
music shuffle off
music shuffle      # Check status
```

### Info & Ratings

```bash
# Currently playing
music now

# Detailed info
music info

# Love/unlike
music love
music unlike

# Rate (1-5 stars)
music rating 5    # Set to 5 stars
music rating      # Show current
```

### Discovery

```bash
# Top tracks (all time)
music top 10
music top 50
music top 100

# Recently played
music recent

# Genre playlists
music genre indie
music genre jazz
music genre hip-hop

# Year-based discovery
music year 1980
music year 2010
music year 2024
```

### Auto-DJ

```bash
# Start intelligent background queueing
dj start

# Check status and recent activity
dj status

# Watch live activity
dj log

# Stop DJ
dj stop
```

## How Auto-DJ Works

The auto-DJ monitors what's playing and automatically queues the next track.

**Smart Queueing:**
1. Monitors current track (updates every 5 seconds)
2. When 20 seconds remain, queues next track
3. Next track matches genre, mood, rating of current track
4. Every 10 songs, creates "Auto Mix HH:MM" playlist

**Learning:**
- Tracks songs you love (❤️)
- Learns from ratings (⭐)
- Groups by genre
- Suggests similar artists

**Output:**
- Creates playlists automatically
- Logs all queueing decisions
- View log: `dj log`

## Command Reference

### Playback

| Command | Effect |
|---------|--------|
| `music play [query]` | Search & play (library first, then Apple Music) |
| `music pause` | Pause |
| `music resume` / `unpause` | Resume |
| `music next` / `skip` | Skip to next |
| `music prev` / `back` | Previous track |
| `music random` | Play random track |

### Info

| Command | Effect |
|---------|--------|
| `music now` | Show current track & time |
| `music info` | Detailed track info (year, genre, plays, rating) |
| `music artist` | Play all by current artist |
| `music album` | Play current album |

### Ratings

| Command | Effect |
|---------|--------|
| `music love` | Mark as loved ❤️ |
| `music unlike` | Mark as unliked 💔 |
| `music rating [1-5]` | Set/get star rating |

### Search & Discovery

| Command | Effect |
|---------|--------|
| `music search [query]` | Search library (top 5) |
| `music top [n]` | Most played tracks (default 10) |
| `music recent` | Recently played (last 10) |
| `music genre [name]` | Play by genre |
| `music year [year]` | Play songs from year |
| `music playlist` | List all playlists |
| `music playlist [name]` | Play specific playlist |

### Queue & Playlists

| Command | Effect |
|---------|--------|
| `music queue [query]` | Add to queue |
| `music save [name]` | Save current track to playlist |
| `music clear` | Clear queue |

### Volume & Modes

| Command | Effect |
|---------|--------|
| `music vol [0-100]` | Get/set volume |
| `music shuffle [on/off]` | Toggle/check shuffle |
| `music repeat [off/one/all]` | Set repeat mode |

### Auto-DJ

| Command | Effect |
|---------|--------|
| `dj start` | Start background auto-DJ |
| `dj stop` | Stop auto-DJ |
| `dj status` | Check status & recent |
| `dj log` | Watch live activity |

## Examples

### Morning Routine Script

```bash
#!/bin/bash
# morning.sh - Start your day with music

# Play uplifting music
music play "good as hell"
music love
music vol 40

# Start auto-DJ for background music during work
dj start
```

### Workout Mix Builder

```bash
#!/bin/bash
# Build a workout playlist

# High energy genre
music genre electronic

# Rate tracks you like
music love

# Create named playlist
music save "Workout $(date +%Y-%m-%d)"
```

### Focus Session

```bash
#!/bin/bash
# Deep work mode

# Ambient/focus music
music genre ambient
music vol 30

# Start auto-DJ for smooth background music
dj start

echo "📚 Deep work session started"
echo "Stop with: dj stop"
```

### Music Stats Finder

```bash
#!/bin/bash
# Find your music patterns

echo "🎵 Your Top 25 Tracks:"
music top 25

echo ""
echo "🔄 Recently Played:"
music recent

echo ""
echo "❤️  Check what you've loved:"
music search ""  # This will search the loved playlist
```

## Natural Language Support

The `music play` command understands natural language:

```bash
music play "who do you love"       # Finds "Who Do You Love"
music play "can't tell me nothing" # Finds "Can't Tell Me Nothing"
music play "good as hell"          # Finds "Good As Hell"
music play drake                   # Starts Drake mix
music play "kanye ye"              # Album or artist
```

## Troubleshooting

### "Music app not responding"

**Cause:** Music app is closed or stuck

**Solution:**
```bash
# Restart Music app
killall Music
open -a Music
sleep 2

# Try command again
music now
```

### Commands not found

**Cause:** Scripts not in PATH

**Solution:**
```bash
# Verify location
which music

# If not found:
export PATH="$PATH:~/Documents/Code/mac-automation-services"

# Or copy to bin
cp music ~/bin/music
```

### Auto-DJ not queuing tracks

**Cause:** DJ daemon not running

**Solution:**
```bash
# Start it
dj start

# Check status
dj status

# Watch log
dj log
```

### Playlist creation not working

**Cause:** Playlist name conflict or AppleScript error

**Solution:**
```bash
# Specify a unique name
music save "My Mix $(date +%s)"

# Check Music app for duplicates
# Delete old "Auto Mix HH:MM" playlists
```

## Advanced Usage

### Use in Scripts

```bash
#!/bin/bash
# custom-workflow.sh

# Get currently playing track
NOW=$(music now)
if [[ $NOW == "⏹️  Stopped" ]]; then
    music play "default playlist"
fi

# Rate it
music rating 5

# Queue next
music queue "suggested-track"

echo "Setup complete!"
```

### Integration Examples

**Trigger music on calendar event:**
```bash
# When meeting ends, start uplifting music
music play "feel good"
music vol 50
dj start
```

**Change music based on time:**
```bash
HOUR=$(date +%H)

if [ $HOUR -lt 12 ]; then
    # Morning: uplifting
    music genre indie
elif [ $HOUR -lt 17 ]; then
    # Afternoon: focus
    music genre ambient
else
    # Evening: relaxing
    music genre jazz
fi
```

## Performance Notes

- **Startup:** <500ms (fast enough for real-time response)
- **Search:** 200-500ms (AppleScript library search)
- **Playback:** Immediate (no lag)
- **Auto-DJ:** Runs in background, checks every 5 seconds

## Security Notes

- All commands run locally on your Mac
- No data sent to external servers
- AppleScript operates within Music app sandbox
- Playlists and ratings stored locally in Music app

## Limitations & Workarounds

**Can't auto-play catalog songs** (Apple's restriction)
- Workaround: Add to library first, then play

**Can't modify Genius playlists** (Apple limitation)
- Workaround: Use smart playlist creation instead

**Can't access Spatial Audio metadata**
- Limitation: Not exposed to AppleScript

**Can't set custom playback speed**
- Limitation: Music app doesn't expose this

## Tips & Tricks

### Faster searches
```bash
music search "kanye"  # Quick search instead of full name
```

### Create mood playlists
```bash
music genre indie
music love    # Mark what you like
music save "Indie Gems $(date +%Y-%m-%d)"
```

### Nighttime discovery
```bash
music year 2010    # Find songs from that era
music genre ambient # Get in the mood
```

### Find new artists
```bash
music search "indie"   # Find all indie tracks
music artist           # See current artist
music queue artist     # Queue more by them
```

## Getting Help

**See all commands:**
```bash
music           # Shows help
dj              # Shows help
```

**Watch auto-DJ activity:**
```bash
dj log
```

**Check what's currently playing:**
```bash
music info
```

## Next Steps

1. ✅ Install scripts
2. ✅ Try basic commands (`music now`, `music play`)
3. ✅ Start auto-DJ (`dj start`)
4. ✅ Create your first playlist
5. ✅ Build scripts that use these commands

---

**Questions?** Check TROUBLESHOOTING above or see [MUSIC_ADVANCED.md](./MUSIC_ADVANCED.md) for advanced topics.
