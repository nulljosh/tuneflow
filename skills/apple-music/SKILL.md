---
name: apple-music
description: Control Apple Music on macOS — search, play, pause, skip, queue, and manage playlists via AppleScript. Use when the user asks to play music, search for songs, add/remove tracks from playlists, or control playback.
metadata: {"clawdbot":{"emoji":"","os":["darwin"],"requires":{"bins":["osascript"]}}}
---

# Apple Music Control (macOS)

Control Apple Music entirely via `osascript` (AppleScript) + iTunes Search API fallback. No external CLI needed.

## IMPORTANT: Always-follow rules

1. **Never give up.** If a song isn't in the library, search the Apple Music catalog and open it. Never reply "not found" without trying the catalog.
2. **Always confirm via iMessage** what you did (play, skip, add, remove, etc).
3. **Never open links in the browser.** Always use `music://` protocol, never `https://music.apple.com`.
4. **Be intuitive.** If someone says "play drake" just pick a popular Drake song. Don't ask "which one?"

## Playback Control

```bash
osascript -e 'tell application "Music" to play'
osascript -e 'tell application "Music" to pause'
osascript -e 'tell application "Music" to stop'
osascript -e 'tell application "Music" to next track'
osascript -e 'tell application "Music" to previous track'
osascript -e 'tell application "Music" to set sound volume to 50'
osascript -e 'tell application "Music" to set shuffle enabled to true'
osascript -e 'tell application "Music" to set song repeat to all'
```

## Now Playing

```bash
osascript -e '
tell application "Music"
  set t to current track
  return " " & name of t & " by " & artist of t & " — " & album of t
end tell'
```

## Playing a Song (full flow)

Always follow this exact flow. Search library first, fall back to catalog automatically.

```bash
#!/bin/bash
# STEP 1: Search local library
RESULT=$(osascript -e '
tell application "Music"
  set results to (every track of playlist "Library" whose name contains "SONG_NAME")
  if (count of results) > 0 then
    play item 1 of results
    set t to item 1 of results
    return "Playing: " & name of t & " by " & artist of t
  else
    return "NOT_IN_LIBRARY"
  end if
end tell')

if [ "$RESULT" != "NOT_IN_LIBRARY" ]; then
  echo "$RESULT"
  exit 0
fi

# STEP 2: Not in library — search Apple Music catalog via iTunes API
SEARCH_TERM="URL_ENCODED_SONG_NAME"
TRACK_INFO=$(curl -s "https://itunes.apple.com/search?term=${SEARCH_TERM}&media=music&limit=5")

# STEP 3: Parse the best result
TRACK_URL=$(echo "$TRACK_INFO" | python3 -c "
import json,sys
d=json.load(sys.stdin)
if d['results']:
    r=d['results'][0]
    url=r['trackViewUrl'].replace('https://','music://')
    print(url)
else:
    print('NONE')
")

TRACK_NAME=$(echo "$TRACK_INFO" | python3 -c "
import json,sys
d=json.load(sys.stdin)
if d['results']:
    r=d['results'][0]
    print(f\"{r['trackName']} by {r['artistName']}\")
")

if [ "$TRACK_URL" = "NONE" ]; then
  echo "Could not find that song anywhere."
  exit 1
fi

# STEP 4: Open in Music.app (NOT browser)
open "$TRACK_URL"
echo "Opening in Apple Music: $TRACK_NAME"
```

**CRITICAL: NEVER use `open "https://music.apple.com/..."` — ALWAYS replace `https://` with `music://` to open in the Music app.**

## Search Library

```bash
# Search by name
osascript -e '
tell application "Music"
  set results to (every track of playlist "Library" whose name contains "SEARCH_TERM")
  set output to ""
  repeat with t in results
    set output to output & name of t & " — " & artist of t & " (" & album of t & ")" & linefeed
  end repeat
  return output
end tell'

# Search by artist
osascript -e '
tell application "Music"
  set results to (every track of playlist "Library" whose artist contains "ARTIST_NAME")
  set output to ""
  repeat with t in results
    set output to output & name of t & " — " & artist of t & linefeed
  end repeat
  return output
end tell'
```

## Search Apple Music Catalog (when not in library)

```bash
# Search iTunes API — returns JSON with trackName, artistName, trackViewUrl, etc.
curl -s "https://itunes.apple.com/search?term=SEARCH+TERMS&media=music&limit=5"

# Parse results
python3 -c "
import json,sys
d=json.load(sys.stdin)
for r in d['results']:
    print(f\"{r['trackName']} — {r['artistName']} | {r['trackViewUrl']}\")
"
```

## Playlist Management

```bash
# List all user playlists
osascript -e '
tell application "Music"
  set output to ""
  repeat with p in (every user playlist)
    set output to output & name of p & " (" & (count of tracks of p) & " tracks)" & linefeed
  end repeat
  return output
end tell'

# List tracks in a playlist
osascript -e '
tell application "Music"
  set p to user playlist "PLAYLIST_NAME"
  set output to ""
  set i to 1
  repeat with t in (every track of p)
    set output to output & i & ". " & name of t & " — " & artist of t & linefeed
    set i to i + 1
  end repeat
  return output
end tell'

# Play a playlist
osascript -e 'tell application "Music" to play user playlist "PLAYLIST_NAME"'

# Create a new playlist
osascript -e '
tell application "Music"
  set newPL to (make new user playlist with properties {name:"NEW_PLAYLIST_NAME"})
  return "Created playlist: " & name of newPL
end tell'

# Add a track to a playlist (must be in library already)
osascript -e '
tell application "Music"
  set results to (every track of playlist "Library" whose name contains "SONG_NAME")
  if (count of results) > 0 then
    set t to item 1 of results
    duplicate t to user playlist "PLAYLIST_NAME"
    return "Added " & name of t & " to PLAYLIST_NAME"
  else
    return "Track not found in library."
  end if
end tell'

# Remove a track from a playlist by index (1-based)
osascript -e '
tell application "Music"
  set p to user playlist "PLAYLIST_NAME"
  set t to track INDEX of p
  set trackName to name of t
  delete t
  return "Removed " & trackName & " from PLAYLIST_NAME"
end tell'
```

## Confirmation Messages

**Always send a confirmation iMessage after any music action.** Use the imsg skill:

```bash
imsg send --to REQUESTER_PHONE --text " Now playing: SONG by ARTIST"
imsg send --to REQUESTER_PHONE --text " Added SONG to PLAYLIST_NAME"
imsg send --to REQUESTER_PHONE --text "⏭️ Skipped to: SONG by ARTIST"
imsg send --to REQUESTER_PHONE --text "⏸️ Paused"
imsg send --to REQUESTER_PHONE --text " Found in catalog, opening in Music app: SONG by ARTIST"
```

## Tips

- Playlist names are case-sensitive in AppleScript.
- For large playlists (100+ tracks), limit output or paginate.
- When the user says "play X", search library first, then catalog. Never say "not found" without trying both.
- If they say "add X to [playlist]" and it's not in library, search catalog, open in Music.app, and tell them it needs to be added to library first.
- If someone just names an artist ("play kanye"), pick a well-known song and play it.
- URL-encode search terms for the iTunes API (spaces become +).
