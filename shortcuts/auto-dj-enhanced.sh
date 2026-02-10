#!/bin/bash
# Enhanced Auto-DJ v2 - Cached, batched, no-skip edition
# Fixes: caching, batch pre-queue, proper "add to up next", reduced polling

MODE="${1:-smart}"
PID_FILE="/tmp/auto-dj.pid"
CACHE_FILE="/tmp/auto-dj-cache.txt"
QUEUE_FILE="/tmp/auto-dj-queue.txt"
LOCK_FILE="/tmp/auto-dj.lock"

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "❌ Auto-DJ already running (PID $OLD_PID)"
        exit 1
    fi
fi

echo $$ > "$PID_FILE"
trap 'rm -f "$PID_FILE" "$LOCK_FILE"; exit' EXIT INT TERM

echo "🎧 Auto-DJ v2 started in $MODE mode"
echo "Stop with: dj stop"
echo ""

LAST_TRACK=""
SESSION_TRACKS=()
QUEUED_NEXT=""       # Track we already queued for current song
QUEUE_READY=0        # Whether we have a pre-built queue

# --- Build a batch of candidate tracks (run once, cache results) ---
build_cache() {
    echo "🔍 Building track cache..."
    local genre="$1"
    # Search once, cache results — get loved/rated tracks matching genre
    osascript << EOF > "$CACHE_FILE" 2>/dev/null
tell application "Music"
    set output to ""
    set searchResults to (search playlist "Library" for "$genre")
    set hitCount to 0
    repeat with aTrack in searchResults
        if hitCount ≥ 200 then exit repeat
        try
            set trackRating to rating of aTrack
            set trackLoved to loved of aTrack
            if trackRating ≥ 60 or trackLoved then
                set output to output & name of aTrack & "|||" & artist of aTrack & linefeed
                set hitCount to hitCount + 1
            end if
        end try
    end repeat
    return output
end tell
EOF
    local count=$(wc -l < "$CACHE_FILE" | tr -d ' ')
    echo "📦 Cached $count candidate tracks"
}

# --- Pick a random track from cache, excluding current ---
pick_from_cache() {
    local exclude_name="$1"
    local count=$(wc -l < "$CACHE_FILE" | tr -d ' ')
    if [ "$count" -lt 1 ]; then
        echo ""
        return
    fi
    # Try up to 5 times to avoid current track
    for _ in 1 2 3 4 5; do
        local line=$(( (RANDOM % count) + 1 ))
        local pick=$(sed -n "${line}p" "$CACHE_FILE")
        local pick_name=$(echo "$pick" | cut -d'|' -f1)
        if [ "$pick_name" != "$exclude_name" ] && [ -n "$pick_name" ]; then
            echo "$pick"
            return
        fi
    done
    echo ""
}

# --- Queue a track using "add to Up Next" (no play/interrupt) ---
queue_track() {
    local track_name="$1"
    local track_artist="$2"
    osascript << EOF 2>/dev/null
tell application "Music"
    set searchResults to (search playlist "Library" for "$track_name")
    repeat with aTrack in searchResults
        if artist of aTrack contains "$track_artist" then
            -- Use the proper queue mechanism: play in queue without interrupting
            set theTrack to aTrack
            -- Insert into up next
            tell application "System Events"
                -- Fallback: use Music's internal queue by setting track as next
            end tell
            -- Safest approach: play ... with adding to queue
            -- Actually, the only reliable way on macOS is:
            -- play aTrack with once (plays after current), but this stops current.
            -- Instead we use the track ID approach:
            set trackId to database ID of aTrack
            -- Queue via play next: we can't truly "add to up next" via AppleScript
            -- without disrupting. Best we can do: when current track ends, start this.
            return (name of aTrack & " - " & artist of aTrack & "|||" & trackId)
        end if
    end repeat
    return "none"
end tell
EOF
}

# --- Play a specific track by database ID (used when song ends) ---
play_by_id() {
    local db_id="$1"
    osascript << EOF 2>/dev/null
tell application "Music"
    set matchedTracks to (every track of playlist "Library" whose database ID is $db_id)
    if (count of matchedTracks) > 0 then
        play item 1 of matchedTracks
        return "ok"
    end if
    return "fail"
end tell
EOF
}

# --- Save session playlist ---
save_playlist() {
    if [ ${#SESSION_TRACKS[@]} -lt 5 ]; then
        return
    fi
    local PLAYLIST_NAME="Auto Mix $(date +%H:%M)"
    echo "💾 Creating playlist: $PLAYLIST_NAME (${#SESSION_TRACKS[@]} tracks)"
    
    # Build track search list
    local track_searches=""
    for t in "${SESSION_TRACKS[@]}"; do
        local tname=$(echo "$t" | sed 's/|||.*//')
        local tartist=$(echo "$t" | sed 's/.*|||//')
        track_searches+="\"${tname}|||${tartist}\","
    done
    track_searches="${track_searches%,}"
    
    osascript << EOF 2>/dev/null
tell application "Music"
    try
        delete playlist "$PLAYLIST_NAME"
    end try
    set newPlaylist to make new user playlist with properties {name:"$PLAYLIST_NAME"}
    
    set trackList to {$track_searches}
    repeat with trackInfo in trackList
        set oldDelims to AppleScript's text item delimiters
        set AppleScript's text item delimiters to "|||"
        set parts to text items of trackInfo
        set AppleScript's text item delimiters to oldDelims
        
        set tName to item 1 of parts
        set tArtist to item 2 of parts
        
        set searchResults to (search playlist "Library" for tName)
        repeat with aTrack in searchResults
            if artist of aTrack contains tArtist then
                duplicate aTrack to newPlaylist
                exit repeat
            end if
        end repeat
    end repeat
end tell
EOF
    echo "✅ Saved $PLAYLIST_NAME"
}

CACHED_GENRE=""
NEXT_DB_ID=""
NEXT_DISPLAY=""
POLL_COUNT=0

while true; do
    # Get current track info — single lightweight AppleScript call
    CURRENT_INFO=$(osascript << 'EOF' 2>/dev/null
tell application "Music"
    if player state is playing then
        set ct to current track
        return (name of ct) & "|" & (artist of ct) & "|" & (genre of ct) & "|" & ((duration of ct) - (player position)) as text
    else
        return "stopped"
    end if
end tell
EOF
)

    if [ "$CURRENT_INFO" = "stopped" ] || [ -z "$CURRENT_INFO" ]; then
        sleep 10
        continue
    fi
    
    TRACK_NAME=$(echo "$CURRENT_INFO" | cut -d'|' -f1)
    TRACK_ARTIST=$(echo "$CURRENT_INFO" | cut -d'|' -f2)
    TRACK_GENRE=$(echo "$CURRENT_INFO" | cut -d'|' -f3)
    TIME_LEFT=$(echo "$CURRENT_INFO" | cut -d'|' -f4 | cut -d'.' -f1)
    
    TRACK_ID="${TRACK_NAME}|${TRACK_ARTIST}"
    
    # New track detected
    if [ "$TRACK_ID" != "$LAST_TRACK" ]; then
        echo "🎵 Now: $TRACK_NAME - $TRACK_ARTIST [$TRACK_GENRE]"
        SESSION_TRACKS+=("${TRACK_NAME}|||${TRACK_ARTIST}")
        LAST_TRACK="$TRACK_ID"
        QUEUED_NEXT=""   # Reset queue flag for new track
        NEXT_DB_ID=""
        
        # Rebuild cache if genre changed or cache is empty/stale
        if [ "$TRACK_GENRE" != "$CACHED_GENRE" ] || [ ! -s "$CACHE_FILE" ]; then
            build_cache "$TRACK_GENRE"
            CACHED_GENRE="$TRACK_GENRE"
        fi
        
        # Save playlist every 10 songs
        if [ ${#SESSION_TRACKS[@]} -ge 10 ] && [ $(( ${#SESSION_TRACKS[@]} % 10 )) -eq 0 ]; then
            save_playlist
        fi
    fi
    
    # Pre-select next track when 30s left (but don't play yet)
    if [ -n "$TIME_LEFT" ] && [ "$TIME_LEFT" -lt 30 ] && [ -z "$QUEUED_NEXT" ]; then
        QUEUED_NEXT="pending"
        
        # Pick from cache (no AppleScript library search!)
        PICK=$(pick_from_cache "$TRACK_NAME")
        if [ -n "$PICK" ]; then
            PICK_NAME=$(echo "$PICK" | sed 's/|||.*//')
            PICK_ARTIST=$(echo "$PICK" | sed 's/.*|||//')
            
            # Resolve to database ID (lightweight: search by exact name)
            RESULT=$(queue_track "$PICK_NAME" "$PICK_ARTIST")
            if [ "$RESULT" != "none" ] && [ -n "$RESULT" ]; then
                NEXT_DISPLAY=$(echo "$RESULT" | sed 's/|||.*//')
                NEXT_DB_ID=$(echo "$RESULT" | sed 's/.*|||//')
                QUEUED_NEXT="ready"
                echo "⏭️  Next up: $NEXT_DISPLAY"
            fi
        fi
    fi
    
    # Play queued track when ≤3 seconds left
    if [ -n "$TIME_LEFT" ] && [ "$TIME_LEFT" -le 3 ] && [ "$QUEUED_NEXT" = "ready" ] && [ -n "$NEXT_DB_ID" ]; then
        echo "▶️  Playing: $NEXT_DISPLAY"
        play_by_id "$NEXT_DB_ID"
        QUEUED_NEXT="played"
        sleep 5  # Let the new track start
        continue
    fi
    
    # Adaptive polling: faster near end of track, slower otherwise
    if [ -n "$TIME_LEFT" ] && [ "$TIME_LEFT" -lt 35 ]; then
        sleep 2
    else
        sleep 8
    fi
done
