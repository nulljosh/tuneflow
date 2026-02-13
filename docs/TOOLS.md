# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

### Music (Apple Music)

CLI: `~/.openclaw/workspace/shortcuts/music`

**Playback:**
- `music play <query>` - Search & play song/artist (library first, then Apple Music)
- `music pause` - Pause playback
- `music resume` - Resume playback
- `music next` - Skip to next track
- `music prev` - Previous track
- `music random` - Play random song

**Info & Ratings:**
- `music now` - Show now playing (track, artist, album, time)
- `music info` - Detailed track info (year, genre, plays, rating)
- `music love` - Love current track
- `music unlike` - Unlike current track
- `music rating [1-5]` - Get/set star rating

**Search & Discovery:**
- `music search <query>` - Search library (top 5 results)
- `music recent` - Recently played (last 10)
- `music top [n]` - Most played tracks (default 10)

**Smart Playback:**
- `music artist` - Play all by current artist
- `music album` - Play current album
- `music genre <name>` - Play songs by genre
- `music year <year>` - Play songs from year

**Queue & Playlists:**
- `music queue <query>` - Add song to queue
- `music clear` - Clear queue
- `music playlist` - List all playlists
- `music playlist <name>` - Play specific playlist
- `music save <name>` - Save current track to playlist

**Controls:**
- `music vol [0-100]` - Get/set volume
- `music shuffle [on|off]` - Toggle/check shuffle mode
- `music repeat [off|one|all]` - Set repeat mode

**Natural language examples:**
- "play kid cudi" / "put on some drake"
- "love this" / "this song slaps"
- "what's playing?" / "who is this?"
- "top 25" / "show me my most played"
- "genre hip-hop" / "play some rap"
- "queue pursuit of happiness" / "add this to queue"
- "turn it up" / "volume 80"
- "shuffle on" / "random mode"

### Auto-DJ

CLI: `~/.openclaw/workspace/shortcuts/dj`

**Smart auto-queueing + playlist creation** - Monitors playback, queues similar tracks automatically, and creates smart playlists.

**Commands:**
- `dj start` - Start auto-DJ (runs in background)
- `dj stop` - Stop auto-DJ
- `dj status` - Check if running
- `dj log` - Watch live activity

**How it works:**
- Queues next track when 20 seconds left (matching genre, loved/rated 3+ stars)
- Tracks what you've listened to during the session
- Every 10 songs, automatically creates a playlist: "Auto Mix HH:MM"
- Keeps building your music library intelligently

---

Add whatever helps you do your job. This is your cheat sheet.
