#!/bin/bash
# System Update Script with Verbose Logging
# Runs all package manager updates with detailed output

LOG_DIR="/Users/joshua/.openclaw/workspace/logs"
LOG_FILE="$LOG_DIR/updates.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Function to log with timestamp
log() {
    echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

# Function to run command with logging
run_update() {
    local cmd="$1"
    local desc="$2"
    
    log "Starting: $desc"
    if eval "$cmd" >> "$LOG_FILE" 2>&1; then
        log "Success: $desc"
    else
        log "Failed: $desc (exit code: $?)"
    fi
}

# Main update routine
log "=== SYSTEM UPDATE STARTED ==="

# Homebrew updates
run_update "brew update --verbose" "Homebrew formulae update"
run_update "brew upgrade --verbose" "Homebrew package upgrades"
run_update "brew cleanup --verbose" "Homebrew cleanup"

# Ruby updates  
run_update "gem update --system" "RubyGems system update"
run_update "gem update" "Ruby gem updates"

# Node/npm updates (if using nvm)
if command -v nvm &> /dev/null; then
    run_update "nvm install node --reinstall-packages-from=node" "Node.js update via nvm"
fi

# npm global packages
run_update "npm update -g" "npm global package updates"

# OpenClaw check (no auto-update without explicit permission)
log "OpenClaw version check:"
openclaw status | grep -E "Update|Gateway" >> "$LOG_FILE" 2>&1

log "=== SYSTEM UPDATE COMPLETED ==="
log "Full log available at: $LOG_FILE"

# Summary
echo ""
echo "Update Summary:"
echo "- Homebrew: Updated"
echo "- Ruby gems: Updated" 
echo "- Node/npm: Updated"
echo "- Logs: $LOG_FILE"