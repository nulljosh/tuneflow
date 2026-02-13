# Music Control System

## Commands

### Basic Playback
- `music play <query>` - Play from library or search Apple Music
- `music play <apple-music-url>` - Open Apple Music link (requires manual play)
- `music pause/resume` - Control playback
- `music next/prev` - Skip tracks

### Auto-DJ
- `dj start` - Start intelligent auto-queueing
- `dj stop` - Stop auto-DJ
- `dj status` - Check status

## Limitations & Workarounds

### Apple Music Catalog Songs

**Problem:** AppleScript cannot auto-play songs from Apple Music catalog (only library songs)

**Workarounds:**
1. **Add to library first** (recommended)
   - Open Apple Music link
   - Tap "+" to add to library
   - Then use `music play "Song Name"`

2. **Let auto-DJ handle it**
   - Manually play the first song
   - Auto-DJ will queue similar tracks automatically

3. **Use playlists**
   - Create playlist with catalog songs
   - `music playlist "Playlist Name"`

### URL Handling

**Apple Music URLs:**
- https://music.apple.com/... → Opens in Music app (not browser)
- Requires manual tap to play
- Shows helpful message about limitation

**Error Messages:**
-  "Opened in Apple Music (tap play to start)"
-  " Opened Apple Music search for: [query]"
-  " Not found in library"

## Test Cases

Run: `bash /Users/joshua/.openclaw/workspace/shortcuts/music-tests.sh`

### Automated Tests
1.  Apple Music URL (https) opens in Music app
2.  Apple Music URL (http) opens in Music app
3.  Search returns top 5 results
4.  Now playing shows current track
5.  Play from library works
6.  Info shows track details
7.  Volume get/set works
8.  Shuffle status works
9.  Invalid commands show usage
10.  Error messages are helpful

### Manual Tests
- [ ] Apple Music URLs open in Music app (not Chrome/Safari)
- [ ] Catalog songs show clear limitation message
- [ ] Auto-DJ queues next track at 20 seconds
- [ ] Auto-DJ creates playlist after 10 songs
- [ ] Library songs play immediately

## Auto-DJ Behavior

1. **Monitors playback** - Checks current track every 3 seconds
2. **Queues intelligently** - At 20 seconds left, finds similar track:
   - Matching genre
   - Loved or rated 3+ stars
   - Not recently played
3. **Creates playlists** - Every 10 songs → "Auto Mix HH:MM"
4. **Logs activity** - `/tmp/auto-dj.log`

## Known Issues

1. **Catalog songs** - Cannot auto-play (Apple Music API limitation)
2. **Large libraries** - Complex DJ queries may be slow (use dj-simple.sh)
3. **Queue management** - Apple Music queue is not fully accessible via AppleScript

## Future Improvements

- [ ] Spotify integration
- [ ] Voice commands via Siri shortcuts
- [ ] ML-based recommendations
- [ ] Cross-platform sync (iOS/Mac)
- [ ] Lyrics display
