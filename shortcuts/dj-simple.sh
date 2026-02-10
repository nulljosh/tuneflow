#!/bin/bash
# Fast DJ mode using music commands
# Usage: bash dj-simple.sh [mode]

MODE="${1:-vibe}"

case "$MODE" in
    party)
        echo "🎉 DJ Party Mode - Queueing bangers..."
        ~/.openclaw/workspace/shortcuts/music shuffle on
        ~/.openclaw/workspace/shortcuts/music play "Kanye West"
        ;;
    
    chill)
        echo "🌊 DJ Chill Mode - Queueing mellow vibes..."
        ~/.openclaw/workspace/shortcuts/music shuffle on
        ~/.openclaw/workspace/shortcuts/music genre "R&B"
        ;;
    
    cudi)
        echo "🎧 DJ Cudi Mode - KIDS SEE GHOSTS vibes..."
        ~/.openclaw/workspace/shortcuts/music shuffle on
        ~/.openclaw/workspace/shortcuts/music artist
        ;;
    
    ye)
        echo "🐻 DJ Ye Mode - Kanye classics..."
        ~/.openclaw/workspace/shortcuts/music playlist "Top 25 - Ye, Kendrick & Cudi"
        ;;
    
    random)
        echo "🎲 DJ Random Mode - Surprise me..."
        ~/.openclaw/workspace/shortcuts/music shuffle on
        ~/.openclaw/workspace/shortcuts/music random
        ;;
    
    *)
        cat << 'USAGE'
🎧 DJ Mode (Fast)

Usage: bash dj-simple.sh [mode]

Modes:
  party      Hip-hop/rap bangers
  chill      R&B/soul vibes
  cudi       KIDS SEE GHOSTS/Cudi
  ye         Kanye classics
  random     Shuffle everything

Examples:
  bash dj-simple.sh party
  bash dj-simple.sh chill
  bash dj-simple.sh ye
USAGE
        ;;
esac
