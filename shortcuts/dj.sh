#!/bin/bash
# DJ mode - intelligent music queueing based on current vibe
# Usage: bash dj.sh [mode] [count]

MODE="${1:-vibe}"
COUNT="${2:-10}"

case "$MODE" in
    vibe)
        # Queue similar songs based on current track
        osascript << EOF
tell application "Music"
    if player state is playing or player state is paused then
        set currentTrack to current track
        set currentArtist to artist of currentTrack
        set currentGenre to genre of currentTrack
        set currentYear to year of currentTrack
        
        -- Find similar tracks
        set allTracks to (get every track of playlist "Library")
        set similarTracks to {}
        
        repeat with aTrack in allTracks
            try
                -- Match genre, similar year, or same artist
                set trackGenre to genre of aTrack
                set trackYear to year of aTrack
                set trackArtist to artist of aTrack
                
                if trackGenre contains currentGenre or ¬
                   (trackYear ≥ (currentYear - 5) and trackYear ≤ (currentYear + 5)) or ¬
                   trackArtist contains currentArtist then
                    -- Check if highly rated or loved
                    set trackRating to rating of aTrack
                    set trackLoved to loved of aTrack
                    
                    if trackRating ≥ 60 or trackLoved then
                        set end of similarTracks to aTrack
                    end if
                end if
            end try
        end repeat
        
        -- Queue up to $COUNT tracks
        set queuedCount to 0
        set resultText to "🎧 DJ Mode: Queueing vibe-matched tracks..." & return & return
        
        repeat with aTrack in similarTracks
            if queuedCount ≥ $COUNT then exit repeat
            if aTrack is not currentTrack then
                -- Queue track by playing and immediately skipping
                play aTrack
                set player position to (duration of aTrack)
                set queuedCount to queuedCount + 1
                set resultText to resultText & queuedCount & ". " & name of aTrack & " - " & artist of aTrack & return
            end if
        end repeat
        
        -- Return to current track
        play currentTrack
        
        return resultText & return & "✅ Queued " & queuedCount & " tracks based on current vibe"
    else
        return "❌ No track playing - start a song first"
    end if
end tell
EOF
        ;;
    
    party)
        # Queue high-energy, popular tracks
        osascript << EOF
tell application "Music"
    set allTracks to (get every track of playlist "Library")
    set partyTracks to {}
    
    -- Find high-energy tracks (high play count, loved, good ratings)
    repeat with aTrack in allTracks
        try
            set trackPlays to played count of aTrack
            set trackRating to rating of aTrack
            set trackLoved to loved of aTrack
            set trackGenre to genre of aTrack
            
            -- High-energy genres and metrics
            if (trackPlays > 5 or trackLoved or trackRating ≥ 80) and ¬
               (trackGenre contains "Hip-Hop" or trackGenre contains "Rap" or ¬
                trackGenre contains "Electronic" or trackGenre contains "Dance") then
                set end of partyTracks to aTrack
            end if
        end try
    end repeat
    
    -- Queue random selection
    set queuedCount to 0
    set resultText to "🎉 Party Mode: Queueing bangers..." & return & return
    
    repeat with i from 1 to $COUNT
        if (count of partyTracks) = 0 then exit repeat
        set randomIndex to (random number from 1 to (count of partyTracks))
        set selectedTrack to item randomIndex of partyTracks
        
        play selectedTrack
        set player position to (duration of selectedTrack)
        set queuedCount to queuedCount + 1
        set resultText to resultText & queuedCount & ". " & name of selectedTrack & " - " & artist of selectedTrack & return
        
        -- Remove from pool to avoid duplicates
        set partyTracks to (items 1 thru (randomIndex - 1) of partyTracks) & ¬
                         (items (randomIndex + 1) thru -1 of partyTracks)
    end repeat
    
    -- Play first track
    if queuedCount > 0 then
        play
    end if
    
    return resultText & return & "🔥 Queued " & queuedCount & " party tracks"
end tell
EOF
        ;;
    
    chill)
        # Queue relaxed, mellow tracks
        osascript << EOF
tell application "Music"
    set allTracks to (get every track of playlist "Library")
    set chillTracks to {}
    
    repeat with aTrack in allTracks
        try
            set trackGenre to genre of aTrack
            set trackRating to rating of aTrack
            
            -- Chill genres
            if (trackGenre contains "R&B" or trackGenre contains "Soul" or ¬
                trackGenre contains "Jazz" or trackGenre contains "Indie" or ¬
                trackGenre contains "Alternative") and trackRating ≥ 60 then
                set end of chillTracks to aTrack
            end if
        end try
    end repeat
    
    set queuedCount to 0
    set resultText to "🌊 Chill Mode: Queueing mellow tracks..." & return & return
    
    repeat with i from 1 to $COUNT
        if (count of chillTracks) = 0 then exit repeat
        set randomIndex to (random number from 1 to (count of chillTracks))
        set selectedTrack to item randomIndex of chillTracks
        
        play selectedTrack
        set player position to (duration of selectedTrack)
        set queuedCount to queuedCount + 1
        set resultText to resultText & queuedCount & ". " & name of selectedTrack & " - " & artist of selectedTrack & return
        
        set chillTracks to (items 1 thru (randomIndex - 1) of chillTracks) & ¬
                         (items (randomIndex + 1) thru -1 of chillTracks)
    end repeat
    
    if queuedCount > 0 then
        play
    end if
    
    return resultText & return & "😌 Queued " & queuedCount & " chill tracks"
end tell
EOF
        ;;
    
    throwback)
        # Queue older tracks (5+ years ago)
        osascript << EOF
tell application "Music"
    set allTracks to (get every track of playlist "Library")
    set throwbackTracks to {}
    set currentYear to (do shell script "date +%Y") as integer
    set throwbackYear to currentYear - 5
    
    repeat with aTrack in allTracks
        try
            set trackYear to year of aTrack
            if trackYear ≤ throwbackYear then
                set end of throwbackTracks to aTrack
            end if
        end try
    end repeat
    
    set queuedCount to 0
    set resultText to "🕰️  Throwback Mode: Queueing classics..." & return & return
    
    repeat with i from 1 to $COUNT
        if (count of throwbackTracks) = 0 then exit repeat
        set randomIndex to (random number from 1 to (count of throwbackTracks))
        set selectedTrack to item randomIndex of throwbackTracks
        
        play selectedTrack
        set player position to (duration of selectedTrack)
        set queuedCount to queuedCount + 1
        set resultText to resultText & queuedCount & ". " & name of selectedTrack & " (" & year of selectedTrack & ") - " & artist of selectedTrack & return
        
        set throwbackTracks to (items 1 thru (randomIndex - 1) of throwbackTracks) & ¬
                             (items (randomIndex + 1) thru -1 of throwbackTracks)
    end repeat
    
    if queuedCount > 0 then
        play
    end if
    
    return resultText & return & "📻 Queued " & queuedCount & " throwback tracks"
end tell
EOF
        ;;
    
    discovery)
        # Queue rarely played tracks (play count < 3)
        osascript << EOF
tell application "Music"
    set allTracks to (get every track of playlist "Library")
    set newTracks to {}
    
    repeat with aTrack in allTracks
        try
            set trackPlays to played count of aTrack
            if trackPlays < 3 then
                set end of newTracks to aTrack
            end if
        end try
    end repeat
    
    set queuedCount to 0
    set resultText to "🔍 Discovery Mode: Queueing hidden gems..." & return & return
    
    repeat with i from 1 to $COUNT
        if (count of newTracks) = 0 then exit repeat
        set randomIndex to (random number from 1 to (count of newTracks))
        set selectedTrack to item randomIndex of newTracks
        
        play selectedTrack
        set player position to (duration of selectedTrack)
        set queuedCount to queuedCount + 1
        set resultText to resultText & queuedCount & ". " & name of selectedTrack & " - " & artist of selectedTrack & return
        
        set newTracks to (items 1 thru (randomIndex - 1) of newTracks) & ¬
                       (items (randomIndex + 1) thru -1 of newTracks)
    end repeat
    
    if queuedCount > 0 then
        play
    end if
    
    return resultText & return & "💎 Queued " & queuedCount & " discovery tracks"
end tell
EOF
        ;;
    
    *)
        cat << 'USAGE'
🎧 DJ Mode - Intelligent Music Queueing

Usage: bash dj.sh [mode] [count]

Modes:
  vibe         Queue tracks similar to current song (genre, year, artist)
  party        High-energy bangers (popular, loved, high-rated hip-hop/electronic)
  chill        Relaxed vibes (R&B, soul, jazz, indie, alternative)
  throwback    Classics from 5+ years ago
  discovery    Rarely played tracks (hidden gems)

Examples:
  bash dj.sh vibe 15         # Queue 15 vibe-matched tracks
  bash dj.sh party           # Queue 10 party tracks (default)
  bash dj.sh chill 20        # Queue 20 chill tracks
  bash dj.sh throwback       # Queue 10 throwback tracks
  bash dj.sh discovery 25    # Queue 25 discovery tracks
USAGE
        ;;
esac
