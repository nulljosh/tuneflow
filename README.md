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

- **`scripts/`** - Music control (music, dj)
- **`shortcuts/`** - Automation shortcuts
- **`skills/`** - Custom skills
- **`docs/`** - Documentation
- **`lists/`** - Media lists
- **`memory/`** - Agent memory
- **`logs/`** - Session logs
- **`archive/`** - Old projects

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

## Build Framework

5-phase workflow for building apps:

1. **Discovery** - Understand requirements, challenge assumptions, prioritize
2. **Planning** - Propose v1, explain technical approach, estimate complexity
3. **Building** - Build iteratively, explain decisions, test and check in
4. **Polish** - Professional touches, edge cases, finishing details
5. **Handoff** - Deploy, document, clear instructions

**Rules:** User is product owner. Build real, not mockups. No jargon. Push back when needed. Be honest about limitations.

## Contact

**Email:** jatrommel@gmail.com
**Portfolio:** [heyitsmejosh.com](https://heyitsmejosh.com)
**GitHub:** [@nulljosh](https://github.com/nulljosh)

---

Built by Joshua Trommel | February 2026

## Project Map

```svg
<svg viewBox="0 0 680 420" width="680" height="420" xmlns="http://www.w3.org/2000/svg" style="font-family:monospace;background:#f8fafc;border-radius:12px">
  <text x="340" y="28" text-anchor="middle" font-size="13" font-weight="bold" fill="#1e293b">tuneflow — Apple Music Automation System</text>

  <!-- Root node -->
  <rect x="260" y="48" width="160" height="36" rx="8" fill="#0071e3"/>
  <text x="340" y="70" text-anchor="middle" font-size="11" fill="white" font-weight="bold">tuneflow/</text>

  <!-- Dashed lines from root -->
  <line x1="290" y1="84" x2="110" y2="150" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>
  <line x1="315" y1="84" x2="240" y2="150" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>
  <line x1="340" y1="84" x2="340" y2="150" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>
  <line x1="365" y1="84" x2="440" y2="150" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>
  <line x1="390" y1="84" x2="570" y2="150" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>

  <!-- skills/ -->
  <rect x="30" y="150" width="160" height="36" rx="8" fill="#6366f1"/>
  <text x="110" y="168" text-anchor="middle" font-size="11" fill="white" font-weight="bold">skills/</text>
  <text x="110" y="180" text-anchor="middle" font-size="9" fill="#e0e7ff">25+ automation skills</text>

  <!-- scripts/ -->
  <rect x="200" y="150" width="120" height="36" rx="8" fill="#6366f1"/>
  <text x="260" y="168" text-anchor="middle" font-size="11" fill="white" font-weight="bold">scripts/</text>
  <text x="260" y="180" text-anchor="middle" font-size="9" fill="#e0e7ff">helper scripts</text>

  <!-- docs/ -->
  <rect x="290" y="150" width="100" height="36" rx="8" fill="#86efac"/>
  <text x="340" y="168" text-anchor="middle" font-size="11" fill="#14532d">docs/</text>
  <text x="340" y="180" text-anchor="middle" font-size="9" fill="#64748b">documentation</text>

  <!-- lists/ logs/ memory/ -->
  <rect x="400" y="150" width="120" height="36" rx="8" fill="#e0f2fe"/>
  <text x="460" y="165" text-anchor="middle" font-size="10" fill="#0c4a6e">lists/ logs/</text>
  <text x="460" y="180" text-anchor="middle" font-size="9" fill="#64748b">memory/</text>

  <!-- package.json etc -->
  <rect x="530" y="150" width="130" height="36" rx="8" fill="#7dd3fc"/>
  <text x="595" y="168" text-anchor="middle" font-size="11" fill="#0c4a6e">package.json</text>
  <text x="595" y="180" text-anchor="middle" font-size="9" fill="#64748b">index.html / config</text>

  <!-- skills children -->
  <line x1="60" y1="186" x2="60" y2="250" stroke="#6366f1" stroke-width="1.5"/>
  <line x1="110" y1="186" x2="110" y2="250" stroke="#6366f1" stroke-width="1.5"/>
  <line x1="160" y1="186" x2="160" y2="250" stroke="#6366f1" stroke-width="1.5"/>

  <rect x="10" y="250" width="100" height="30" rx="6" fill="#e0e7ff"/>
  <text x="60" y="269" text-anchor="middle" font-size="9" fill="#3730a3">apple-music/</text>

  <rect x="60" y="250" width="100" height="30" rx="6" fill="#e0e7ff"/>
  <text x="110" y="269" text-anchor="middle" font-size="9" fill="#3730a3">weather/</text>

  <rect x="110" y="250" width="100" height="30" rx="6" fill="#e0e7ff"/>
  <text x="160" y="269" text-anchor="middle" font-size="9" fill="#3730a3">dominos/</text>

  <!-- scripts children -->
  <line x1="245" y1="186" x2="225" y2="250" stroke="#6366f1" stroke-width="1.5"/>
  <line x1="275" y1="186" x2="295" y2="250" stroke="#6366f1" stroke-width="1.5"/>

  <rect x="175" y="250" width="100" height="30" rx="6" fill="#e0e7ff"/>
  <text x="225" y="269" text-anchor="middle" font-size="9" fill="#3730a3">music/</text>

  <rect x="245" y="250" width="110" height="30" rx="6" fill="#e0e7ff"/>
  <text x="300" y="269" text-anchor="middle" font-size="9" fill="#3730a3">dj / heic-handler</text>

  <!-- Feature boxes -->
  <rect x="380" y="250" width="280" height="155" rx="8" fill="#f1f5f9"/>
  <text x="520" y="272" text-anchor="middle" font-size="11" font-weight="bold" fill="#1e293b">Automation Features</text>
  <text x="520" y="292" text-anchor="middle" font-size="10" fill="#475569">25+ Apple Music commands</text>
  <text x="520" y="310" text-anchor="middle" font-size="10" fill="#475569">Auto-DJ — intelligent queueing</text>
  <text x="520" y="328" text-anchor="middle" font-size="10" fill="#475569">Smart playlists every 10 songs</text>
  <text x="520" y="346" text-anchor="middle" font-size="10" fill="#475569">Learning system (ratings/loved)</text>
  <text x="520" y="364" text-anchor="middle" font-size="10" fill="#475569">Shortcuts + skill routing</text>
  <text x="520" y="382" text-anchor="middle" font-size="10" fill="#475569">Session logs + memory</text>
  <text x="520" y="400" text-anchor="middle" font-size="10" fill="#475569">archive/ — retired skills</text>
</svg>
```
