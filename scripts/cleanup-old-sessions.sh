#!/bin/bash
# Auto-cleanup old iMessage sessions

# Get list of current iMessage session IDs from session list
IMESSAGE_SESSIONS=$(openclaw sessions list --json 2>/dev/null | jq -r '.sessions[] | select(.channel == "imessage") | .sessionId' 2>/dev/null)

# Find and remove iMessage session transcripts older than 1 hour
find /Users/joshua/.openclaw/agents/main/sessions/ -name "*.jsonl" -type f -mmin +60 | while read file; do
    SESSION_ID=$(basename "$file" .jsonl)
    
    # Check if this session ID is in the list of iMessage sessions
    if echo "$IMESSAGE_SESSIONS" | grep -q "^$SESSION_ID$"; then
        # Skip the current active session
        if ! lsof "$file" >/dev/null 2>&1; then
            echo "Removing old iMessage session: $(basename "$file")"
            rm -f "$file"
        fi
    fi
done

# Also clean up any orphaned sessions (files that don't appear in session list)
echo "Checking for orphaned session files..."
ALL_FILES=$(find /Users/joshua/.openclaw/agents/main/sessions/ -name "*.jsonl" -type f -mmin +60 -exec basename {} .jsonl \;)
ALL_SESSIONS=$(openclaw sessions list --json 2>/dev/null | jq -r '.sessions[].sessionId' 2>/dev/null)

for FILE_ID in $ALL_FILES; do
    if ! echo "$ALL_SESSIONS" | grep -q "^$FILE_ID$"; then
        FILE_PATH="/Users/joshua/.openclaw/agents/main/sessions/${FILE_ID}.jsonl"
        if ! lsof "$FILE_PATH" >/dev/null 2>&1; then
            echo "Removing orphaned session file: ${FILE_ID}.jsonl"
            rm -f "$FILE_PATH"
        fi
    fi
done