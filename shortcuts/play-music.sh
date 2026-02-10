#!/bin/bash
# Play music from Apple Music (library or catalog)
# Usage: ./play-music.sh "song name" ["artist name"]

SONG="$1"
ARTIST="$2"

if [ -z "$SONG" ]; then
    echo "Usage: $0 'song name' ['artist name']"
    exit 1
fi

# Try library first
if [ -n "$ARTIST" ]; then
    SEARCH_TERM="$ARTIST $SONG"
else
    SEARCH_TERM="$SONG"
fi

osascript << EOF
tell application "Music"
    set searchResults to (search playlist "Library" for "$SEARCH_TERM")
    
    if (count of searchResults) > 0 then
        set foundTrack to item 1 of searchResults
        play foundTrack
        return "Playing from library: " & name of foundTrack & " by " & artist of foundTrack
    else
        -- Not in library - open Apple Music search
        set encodedSearch to do shell script "python3 -c 'import urllib.parse; print(urllib.parse.quote(\"$SEARCH_TERM\"))'"
        set applemusicURL to "music://music.apple.com/us/search?term=" & encodedSearch
        open location applemusicURL
        return "Opened Apple Music search - manually select and play the song to add it to your library"
    end if
end tell
EOF
