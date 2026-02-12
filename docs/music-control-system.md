# AI Music Control System — Complete Documentation

Our flagship automation. Control Apple Music like never before with 25+ commands and intelligent auto-DJ.

## Overview

Transform your Apple Music experience from clicking around to commanding your music with natural language and powerful automation.

**What it does:**
- Full playback control (play, pause, next, skip)
- Smart search and discovery
- Intelligent ratings and loved track tracking
- Auto-DJ with automatic smart queueing
- Automatic playlist generation every 10 songs
- Analytics and top tracks reporting
- Genre-based playback
- Year-based discovery

**Cost:** Included with Gold tier ($1,500) or $500 standalone  
**Setup:** 30 minutes  
**Maintenance:** Zero — it works automatically

## Installation

### Prerequisites
- macOS 12+ (Monterey or newer)
- Apple Music subscription
- Terminal access (basic comfort with command line)

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/nulljosh/music-control.git
cd music-control

# Install dependencies
chmod +x music dj
echo 'export PATH="$PATH:$(pwd)"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
music now
```

That's it! You're ready to go.

## Commands

### Playback Control

```bash
music play <query>          # Search and play (library first, then Apple Music)
music pause                 # Pause current track
music resume               # Resume playback
music next                 # Skip to next track
music prev                 # Go to previous track
music random               # Play a random track from your library
```

**Examples:**
```bash
music play kid cudi        # Play Kid Cudi
music play "get happy"     # Play specific song
music next                 # Skip current track
```

### Now Playing & Info

```bash
music now                  # Show currently playing track
music info                 # Detailed info (year, genre, plays, rating)
music artist               # Play all songs by current artist
music album                # Play current album
```

**Output:**
```
Now Playing: Kid Cudi - Pursuit of Happiness
Artist: Kid Cudi | Album: Man on the Moon
Year: 2009 | Genre: Hip-Hop | ★★★★★ (5 stars)
Played 47 times | Loved
```

### Ratings & Feedback

```bash
music love                 # Love current track
music unlike              # Unlike current track
music rating <1-5>        # Set star rating (1-5 stars)
music rating             # View current track's rating
```

**Smart Learning:** The system learns from your ratings and automatically queues similar tracks.

### Search & Discovery

```bash
music search <query>      # Search library (top 5 results)
music recent             # Recently played (last 10)
music top [n]            # Most played tracks (default 10, max 100)
music genre <name>       # Play songs by genre
music year <year>        # Play songs from specific year
```

**Examples:**
```bash
music search kanye        # Find all Kanye songs
music top 25              # Show your top 25 most-played
music genre hip-hop       # Queue hip-hop mix
music year 2020           # Play all your 2020 favorites
```

### Queue & Playlists

```bash
music queue <query>       # Add song to queue
music clear              # Clear entire queue
music playlist           # List all playlists
music playlist <name>    # Play specific playlist
music save <name>        # Save current track to new playlist
```

**Smart Playlists:**
```bash
music save "Monday Mix"   # Create playlist with current track
music save "Workout"      # Add current track to existing playlist
```

### Volume & Settings

```bash
music vol [0-100]        # Get/set volume (0-100)
music shuffle [on|off]   # Toggle/check shuffle mode
music repeat [off|one|all] # Set repeat mode
```

### Auto-DJ Control

```bash
dj start                  # Start auto-DJ (background daemon)
dj stop                   # Stop auto-DJ
dj status                 # Check if auto-DJ is running
dj log                    # Watch live activity and queueing
```

## Auto-DJ System

The intelligent background automation that keeps your queue fresh.

### How It Works

1. **Continuous Monitoring:** Watches your current track
2. **Smart Queueing:** 20 seconds before song ends, auto-queues next track
3. **Learning:** Uses your ratings (loved/disliked) and star ratings
4. **Auto Playlists:** Every 10 songs, creates "Auto Mix HH:MM" playlist
5. **Genre Matching:** Queues similar tracks based on genre, year, and taste

### Starting Auto-DJ

```bash
dj start
```

This runs in the background. You can close the terminal — it stays active.

**What it creates:**
- Automatic song queueuing
- "Auto Mix 10:30" playlists (every 10 songs)
- Performance logs

### Monitoring Auto-DJ

```bash
dj status
# Returns: "Running (PID 12345)" or "Stopped"

dj log
# Shows live activity:
# [10:32] Queued: The Weekend - Blinding Lights
# [10:42] Created playlist: Auto Mix 10:42
# [10:44] Queued: SZA - Good Days
```

### Stopping Auto-DJ

```bash
dj stop
```

The daemon stops. You can restart anytime with `dj start`.

## Features in Detail

### Natural Language

The system understands natural language queries:

```bash
music play "who do you love"      # Finds "Who Do You Love"
music search can't tell me        # Finds "Can't Tell Me Nothing"
music play drake                  # Starts Drake mix
```

### Library Priority

When you search, it checks your library first:
- Your personal collection gets priority
- If not found, searches Apple Music catalog
- Seamless fallback to streaming library

### Analytics

```bash
music top 10               # Top 10 all-time
music top 50              # Top 50 most-played
music top 100             # Top 100 (full year)
music recent              # Last 10 played
```

**Perfect for:**
- Discovering what you love most
- Sharing with friends
- Analyzing your music taste

### Genre Support

Works with any genre in Apple Music:
- hip-hop, rap, r&b
- rock, indie, alternative
- pop, dance, electronic
- jazz, classical, ambient
- country, folk, bluegrass
- And 50+ more...

```bash
music genre jazz          # Queue jazz mix
music year 1970          # Play 70s classics
```

## Advanced Usage

### Creating Smart Playlists

```bash
# Start playing an artist
music artist

# Love tracks you like
music love

# Create a playlist with loved tracks
music save "My Favorites"
```

### Building Your Discovery Mix

```bash
# Start with genre
music genre indie

# Love what you like
music love

# Auto-DJ will queue similar tracks
dj start
```

### Integration with Scripts

The music system can be called from other scripts:

```bash
#!/bin/bash
# Morning routine
music play "Good as Hell"
music vol 50
sleep 3
music love
```

## Configuration

### Change Voice (if available)

```bash
export VOICE="Polly.Matthew-Neural"  # US Male
export VOICE="Polly.Amy-Neural"      # UK Female
export VOICE="Polly.Joanna-Neural"   # Default (US Female)
```

### Custom Queue Settings

Edit `~/.music-config` (auto-created on first run):

```
# Auto-DJ settings
QUEUE_AHEAD=20          # Seconds to queue before end
PLAYLIST_INTERVAL=10    # Songs between auto-playlists
AUTO_DJ_LOG=/tmp/dj.log # Log location
```

## Troubleshooting

### Commands not found?

```bash
# Make sure music script is in PATH
which music
# If not found, run:
export PATH="$PATH:~/path/to/music/folder"
```

### Apple Music not responding?

```bash
# Restart Music app
killall Music
open -a Music

# Then retry command
music now
```

### Auto-DJ not queuing?

```bash
# Check if running
dj status

# If not, start it
dj start

# Watch the log
dj log
```

## Performance

- **Startup:** <100ms
- **Search:** 200-500ms
- **Queue:** <50ms
- **Auto-DJ polling:** Every 5 seconds (minimal CPU impact)

## Privacy

-  Everything runs locally on your Mac
-  No data sent to external servers
-  No analytics or tracking
-  No account requirements beyond Apple Music
-  Complete local control

## Customization

All scripts are open source and fully documented. You can:

-  Modify commands
-  Add new features
-  Integrate with other tools
-  Share customizations
-  Use in other projects

## Examples

### Morning Routine Script

```bash
#!/bin/bash
# morning.sh - Start your day

echo "☀️ Good morning!"

# Start with uplifting music
music play "good as hell"
music love
music vol 50

# Start auto-DJ for background music
dj start

echo "Music started. Auto-DJ running."
```

### Work Session Setup

```bash
#!/bin/bash
# work.sh

# Queue focus music
music genre ambient
music vol 30

# Show current track
music now

# Start auto-DJ
dj start
```

### Workout Playlist Creator

```bash
#!/bin/bash
# Generate workout playlist

echo "Creating workout mix..."

# Start with high-energy genre
music genre electronic

# Love tracks to train system
music love

# Save playlist
music save "Workout Mix $(date +'%Y-%m-%d')"

echo "Playlist created!"
```

## Support

**Issues or questions?**
- GitHub Issues: [nulljosh/music-control](https://github.com/nulljosh/music-control/issues)
- Email: contact@heyitsmejosh.com
- Response time: Usually within 2 hours

## Updates

The music system is automatically updated with:
- New Apple Music features
- Bug fixes
- Performance improvements
- New commands based on user feedback

You'll always have the latest version.

---

**Ready to control your music?** Try `music now` or [return to docs →](./README.md)
