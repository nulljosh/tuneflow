#!/bin/bash
# Smart play - tries library first, then guides you through catalog

QUERY="$*"

# Try library first
RESULT=$(~/.openclaw/workspace/shortcuts/music search "$QUERY" 2>&1 | head -1)

if [[ "$RESULT" == *"No results found"* ]]; then
    echo "❌ Not in library"
    echo "🔍 Opening Apple Music search..."
    echo ""
    echo "📝 Quick steps:"
    echo "   1. Tap '+' to add to library"
    echo "   2. Tap play"
    echo "   3. Auto-DJ will take over from there"
    
    ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$QUERY'))")
    open "music://music.apple.com/us/search?term=$ENCODED"
else
    # Play from library
    ~/.openclaw/workspace/shortcuts/music play "$QUERY"
fi
