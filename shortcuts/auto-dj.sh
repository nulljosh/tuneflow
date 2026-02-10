#!/bin/bash
# Auto-DJ - Intelligently queues next song based on current track
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
echo "Stop with: kill $$"
echo ""

LAST_TRACK=""

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
        LAST_TRACK="$TRACK_ID"
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
