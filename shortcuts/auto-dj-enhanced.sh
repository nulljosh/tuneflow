#!/bin/bash
# Enhanced Auto-DJ - Queues tracks AND creates smart playlists
# Runs in background and monitors playback

MODE="${1:-smart}"
PID_FILE="/tmp/auto-dj.pid"

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "❌ Auto-DJ already running (PID $OLD_PID)"
        echo "Stop it with: kill $OLD_PID"
        exit 1
    fi
fi

# Save our PID
echo $$ > "$PID_FILE"

echo "🎧 Auto-DJ started in $MODE mode"
echo "📝 Will create smart playlists automatically"
echo "Stop with: kill $$"
echo ""

LAST_TRACK=""
SESSION_TRACKS=()
SESSION_START=$(date +%s)

while true; do
    # Get current track info
    CURRENT_INFO=$(osascript << 'EOF'
tell application "Music"
    if player state is playing then
        set currentTrack to current track
        set trackName to name of currentTrack
        set trackArtist to artist of currentTrack
        set trackGenre to genre of currentTrack
        set trackDuration to duration of currentTrack
        set trackPosition to player position
        set timeLeft to trackDuration - trackPosition
        
        return trackName & "|" & trackArtist & "|" & trackGenre & "|" & timeLeft
    else
        return "stopped"
    end if
end tell
EOF
)

    if [ "$CURRENT_INFO" = "stopped" ]; then
        sleep 5
        continue
    fi
    
    TRACK_NAME=$(echo "$CURRENT_INFO" | cut -d'|' -f1)
    TRACK_ARTIST=$(echo "$CURRENT_INFO" | cut -d'|' -f2)
    TRACK_GENRE=$(echo "$CURRENT_INFO" | cut -d'|' -f3)
    TIME_LEFT=$(echo "$CURRENT_INFO" | cut -d'|' -f4 | cut -d'.' -f1)
    
    TRACK_ID="${TRACK_NAME}|${TRACK_ARTIST}"
    
    # New track detected
    if [ "$TRACK_ID" != "$LAST_TRACK" ]; then
        echo "🎵 Now: $TRACK_NAME - $TRACK_ARTIST"
        SESSION_TRACKS+=("$TRACK_NAME|||$TRACK_ARTIST")
        LAST_TRACK="$TRACK_ID"
        
        # Save playlist every 10 songs
        if [ ${#SESSION_TRACKS[@]} -ge 10 ]; then
            PLAYLIST_NAME="Auto Mix $(date +%H:%M)"
            echo "💾 Creating playlist: $PLAYLIST_NAME"
            
            # Create playlist with session tracks
            osascript << EOF
tell application "Music"
    -- Create playlist
    try
        delete playlist "$PLAYLIST_NAME"
    end try
    set newPlaylist to make new user playlist with properties {name:"$PLAYLIST_NAME"}
    
    -- Add tracks
    set trackCount to 0
    repeat with trackInfo in {"${SESSION_TRACKS[@]}"}
        set trackData to my split(trackInfo, "|||")
        set trackName to item 1 of trackData
        set trackArtist to item 2 of trackData
        
        set searchResults to (search playlist "Library" for trackName)
        repeat with aTrack in searchResults
            if artist of aTrack contains trackArtist then
                duplicate aTrack to newPlaylist
                set trackCount to trackCount + 1
                exit repeat
            end if
        end repeat
    end repeat
    
    return trackCount
end tell

on split(theString, theDelimiter)
    set oldDelimiters to AppleScript's text item delimiters
    set AppleScript's text item delimiters to theDelimiter
    set theArray to every text item of theString
    set AppleScript's text item delimiters to oldDelimiters
    return theArray
end split
EOF
            
            echo "✅ Saved $PLAYLIST_NAME with ${#SESSION_TRACKS[@]} tracks"
            SESSION_TRACKS=()  # Reset for next session
        fi
    fi
    
    # Queue next track when 20 seconds left
    if [ "$TIME_LEFT" -lt 20 ] && [ "$TIME_LEFT" -gt 15 ]; then
        echo "⏰ Queuing next track..."
        
        # Find similar track
        NEXT_TRACK=$(osascript << EOF
tell application "Music"
    set currentTrack to current track
    set currentGenre to "$TRACK_GENRE"
    set currentArtist to "$TRACK_ARTIST"
    
    -- Search for similar tracks
    set allTracks to (search playlist "Library" for currentGenre)
    set candidates to {}
    
    repeat with aTrack in allTracks
        try
            if name of aTrack is not "$TRACK_NAME" then
                -- Prefer loved or rated tracks
                set trackRating to rating of aTrack
                set trackLoved to loved of aTrack
                
                if trackRating ≥ 60 or trackLoved then
                    set end of candidates to aTrack
                end if
            end if
        end try
    end repeat
    
    -- Pick random from candidates
    if (count of candidates) > 0 then
        set randomIndex to (random number from 1 to (count of candidates))
        set nextTrack to item randomIndex of candidates
        
        -- Add to up next
        play nextTrack
        delay 0.5
        play currentTrack
        
        return name of nextTrack & " - " & artist of nextTrack
    else
        return "none"
    end if
end tell
EOF
)
        
        if [ "$NEXT_TRACK" != "none" ]; then
            echo "➕ Queued: $NEXT_TRACK"
        fi
        
        sleep 20  # Don't queue again for this track
    fi
    
    sleep 3
done
