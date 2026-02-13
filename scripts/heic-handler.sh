#!/bin/bash
# HEIC to JPEG converter for OpenClaw image analysis

set -e

HEIC_FILE="$1"
if [[ -z "$HEIC_FILE" ]]; then
    echo "Usage: $0 <heic_file>"
    exit 1
fi

if [[ ! -f "$HEIC_FILE" ]]; then
    echo "Error: File not found: $HEIC_FILE"
    exit 1
fi

# Check if it's actually a HEIC file
if [[ ! "$HEIC_FILE" =~ \.(heic|HEIC)$ ]]; then
    echo "Error: Not a HEIC file: $HEIC_FILE"
    exit 1
fi

# Generate temp JPEG path
TEMP_JPEG="/tmp/openclaw_heic_$(date +%s).jpg"

# Convert using sips
echo "Converting HEIC to JPEG..."
sips -s format jpeg "$HEIC_FILE" --out "$TEMP_JPEG" 2>/dev/null

if [[ -f "$TEMP_JPEG" ]]; then
    echo "$TEMP_JPEG"
else
    echo "Error: Conversion failed"
    exit 1
fi