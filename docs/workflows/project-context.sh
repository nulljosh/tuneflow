#!/bin/bash
# Load project context quickly
PROJECT="$1"

if [ -z "$PROJECT" ]; then
  echo "Usage: project-context.sh <project-name>"
  exit 1
fi

# Common project locations
LOCATIONS=(
  "$HOME/Documents/Code/$PROJECT"
  "$HOME/Projects/$PROJECT"
  "$HOME/Developer/$PROJECT"
  "$HOME/Code/$PROJECT"
  "$HOME/.openclaw/workspace/$PROJECT"
)

PROJECT_DIR=""
for loc in "${LOCATIONS[@]}"; do
  if [ -d "$loc" ]; then
    PROJECT_DIR="$loc"
    break
  fi
done

if [ -z "$PROJECT_DIR" ]; then
  echo "❌ Project '$PROJECT' not found in common locations"
  exit 1
fi

echo "📁 Project: $PROJECT"
echo "📂 Location: $PROJECT_DIR"
echo ""

# README
if [ -f "$PROJECT_DIR/README.md" ]; then
  echo "=== README.md ==="
  head -50 "$PROJECT_DIR/README.md"
  echo ""
fi

# Recent commits
if [ -d "$PROJECT_DIR/.git" ]; then
  echo "=== Recent Commits (last 5) ==="
  cd "$PROJECT_DIR"
  git log --oneline -5 2>/dev/null || echo "(no git history)"
  echo ""
fi

# TODOs
if [ -f "$PROJECT_DIR/TODO.md" ]; then
  echo "=== TODO.md ==="
  cat "$PROJECT_DIR/TODO.md"
  echo ""
fi

# Package.json (for Node projects)
if [ -f "$PROJECT_DIR/package.json" ]; then
  echo "=== package.json (name, version, scripts) ==="
  jq '{name, version, scripts}' "$PROJECT_DIR/package.json" 2>/dev/null || echo "(parse error)"
  echo ""
fi
