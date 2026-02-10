#!/bin/bash
# Helper script to handle Apple Music URLs sent via iMessage
# Automatically detects and plays Apple Music links

# Check if argument looks like an Apple Music URL
if [[ "$1" =~ music\.apple\.com ]]; then
    echo "🎵 Detected Apple Music link"
    ~/.openclaw/workspace/shortcuts/music play "$1"
else
    # Regular music command
    ~/.openclaw/workspace/shortcuts/music play "$@"
fi
