#!/bin/bash
# Music command test suite
# Usage: bash music-tests.sh

MUSIC_CMD="/Users/joshua/.openclaw/workspace/shortcuts/music"

echo "🧪 Music Command Test Suite"
echo "=========================="
echo ""

# Test 1: Apple Music URL (https)
echo "Test 1: Apple Music URL (https://)"
$MUSIC_CMD play "https://music.apple.com/ca/album/bluish/1869945700?i=1869945701"
echo ""
sleep 1

# Test 2: Apple Music URL (http)
echo "Test 2: Apple Music URL (http://)"
$MUSIC_CMD play "http://music.apple.com/us/album/test/123?i=456"
echo ""
sleep 1

# Test 3: Regular search query
echo "Test 3: Regular search query"
$MUSIC_CMD search "Kid Cudi"
echo ""

# Test 4: Now playing
echo "Test 4: Now playing"
$MUSIC_CMD now
echo ""

# Test 5: Play from library
echo "Test 5: Play from library"
$MUSIC_CMD play "Kanye West"
echo ""
sleep 1

# Test 6: Info command
echo "Test 6: Track info"
$MUSIC_CMD info
echo ""

# Test 7: Volume get
echo "Test 7: Get volume"
$MUSIC_CMD vol
echo ""

# Test 8: Volume set
echo "Test 8: Set volume to 50"
$MUSIC_CMD vol 50
echo ""

# Test 9: Shuffle status
echo "Test 9: Shuffle status"
$MUSIC_CMD shuffle
echo ""

# Test 10: Invalid command
echo "Test 10: Invalid command (should show usage)"
$MUSIC_CMD invalidcommand
echo ""

echo "=========================="
echo "✅ Test suite complete"
echo ""
echo "Manual tests needed:"
echo "  - Test Apple Music URL opens in Music app (not browser)"
echo "  - Test catalog songs show helpful error message"
echo "  - Test auto-DJ creates playlists after 10 songs"
