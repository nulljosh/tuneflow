#!/bin/bash
# Smart image analyzer with automatic HEIC conversion

set -e

IMAGE_PATH="$1"
PROMPT="${2:-What's in this image?}"

if [[ -z "$IMAGE_PATH" ]]; then
    echo "Usage: $0 <image_path> [prompt]"
    exit 1
fi

if [[ ! -f "$IMAGE_PATH" ]]; then
    echo "Error: File not found: $IMAGE_PATH"
    exit 1
fi

# Check file type
FILE_EXT="${IMAGE_PATH##*.}"
FILE_EXT_LOWER="${FILE_EXT,,}"

ANALYSIS_PATH="$IMAGE_PATH"

# Convert HEIC if needed
if [[ "$FILE_EXT_LOWER" == "heic" ]]; then
    echo "HEIC detected, converting..."
    CONVERTED_PATH=$(/Users/joshua/.openclaw/workspace/scripts/heic-handler.sh "$IMAGE_PATH")
    if [[ $? -eq 0 ]] && [[ -f "$CONVERTED_PATH" ]]; then
        ANALYSIS_PATH="$CONVERTED_PATH"
        echo "Converted to: $ANALYSIS_PATH"
    else
        echo "Error: HEIC conversion failed"
        exit 1
    fi
fi

# Now analyze the image
echo "Analyzing image..."
echo "Path: $ANALYSIS_PATH"
echo "Prompt: $PROMPT"

# Cleanup temp file if we created one
if [[ "$ANALYSIS_PATH" != "$IMAGE_PATH" ]] && [[ "$ANALYSIS_PATH" == /tmp/* ]]; then
    echo "Cleanup: $ANALYSIS_PATH"
fi