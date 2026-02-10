#!/bin/bash
# Play Apple Music catalog song using Shortcuts app
# Creates a temporary shortcut and runs it

SONG="$*"

if [ -z "$SONG" ]; then
    echo "Usage: $0 <song name or artist>"
    exit 1
fi

echo "🎵 Trying to play from catalog: $SONG"

# Method 1: Try creating and running a Shortcut
osascript << EOF
tell application "Shortcuts Events"
    try
        run shortcut "Play Music" with input "$SONG"
    on error errMsg
        return "Shortcut method failed: " & errMsg
    end try
end tell
EOF

# Method 2: Use Music app URL with action parameter
ENCODED_SONG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$SONG'))")
open "music://music.apple.com/us/search?term=$ENCODED_SONG"

# Method 3: Simulate Siri command (requires accessibility permissions)
# osascript << 'SIRI_SCRIPT'
# tell application "System Events"
#     keystroke "play $SONG in Apple Music"
#     key code 36 -- Return key
# end tell
# SIRI_SCRIPT

echo ""
echo "⚠️  AppleScript limitation: Cannot auto-play catalog songs"
echo "💡 Workarounds:"
echo "   1. Add song to library first, then use: music play '$SONG'"
echo "   2. Manually tap play in the Music app window"
echo "   3. Use Siri: Say 'Hey Siri, play $SONG'"
