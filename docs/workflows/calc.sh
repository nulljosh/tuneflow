#!/bin/bash
# Quick calculation scratch pad
DATE=$(date +%Y-%m-%d)
CALC_DIR="$HOME/.openclaw/workspace/memory/calcs"
CALC_FILE="$CALC_DIR/$DATE.md"

mkdir -p "$CALC_DIR"

if [ ! -f "$CALC_FILE" ]; then
  echo "# Calculations - $DATE" > "$CALC_FILE"
  echo "" >> "$CALC_FILE"
fi

echo "## $(date +%H:%M:%S)" >> "$CALC_FILE"
echo "$@" >> "$CALC_FILE"
echo "" >> "$CALC_FILE"

cat "$CALC_FILE"
