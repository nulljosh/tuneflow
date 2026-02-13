# TuneFlow

Advanced Apple Music automation system with intelligent AI-powered features.


## Live Site

**Portfolio:** [heyitsmejosh.com/automation](https://heyitsmejosh.com/automation)

## Featured Work: AI Music Control System

Complete Apple Music automation built in 1 day.

### What It Does

- **25+ Commands** - Control every aspect of Apple Music
- **Auto-DJ** - Intelligent queueing based on your taste
- **Smart Playlists** - Automatic creation every 10 songs
- **Learning System** - Tracks ratings/loved songs
- **Discovery Mode** - Finds hidden gems
- **Analytics** - Top played, history, genre breakdowns

### Installation

All scripts organized in folders:

```bash
# Main music control
scripts/music play kid cudi
scripts/music search kanye
scripts/music love
scripts/music top 25

# Auto-DJ (intelligent background queueing)
scripts/dj start
scripts/dj status
scripts/dj stop
```

### Project Structure

- **`scripts/`** - Music control scripts (music, dj, analyze_header.py)
- **`shortcuts/`** - Automation shortcuts and enhanced auto-dj
- **`generators/`** - 80s graphics generators (HTML/JS/Python + images)
- **`zkml/`** - ZKML analysis tools
- **`config/`** - Configuration files (.env.kimi, context-monitor.json)
- **`docs/`** - Documentation and guides
- **`skills/`** - Custom skills
- **`lists/`** - Music and content lists
- **`memory/`** - Agent memory storage
- **`logs/`** - Session logs
- **`archive/`** - Archived files

### Main Scripts

- **`scripts/music`** - 25+ commands for complete Apple Music control
- **`scripts/dj`** - Auto-DJ control (start/stop/status)
- **`shortcuts/auto-dj-enhanced.sh`** - Background daemon with smart queueing v2

### Tech Stack

- AppleScript - Deep Apple Music integration
- Bash - CLI & daemon process
- OpenClaw - AI orchestration
- Background process - Auto-queueing engine

### Features

**Playback:**
- play, pause, resume, next, prev, random

**Info & Ratings:**
- now, info, love, unlike, rating

**Discovery:**
- search, recent, top, artist, album, genre, year

**Smart Features:**
- Auto-DJ monitors playback
- Queues similar tracks 20 seconds before song ends
- Creates "Auto Mix HH:MM" playlists every 10 songs
- Learns from loved tracks and ratings

## Contact

**Email:** jatrommel@gmail.com  
**Portfolio:** [heyitsmejosh.com](https://heyitsmejosh.com)  
**GitHub:** [@nulljosh](https://github.com/nulljosh)

---

Built by Joshua Trommel | February 2026
