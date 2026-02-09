#!/bin/bash
# Enhanced morning briefing v2

echo "☀️ **Morning Brief - $(date '+%A, %B %d')**"
echo ""

# Weather
echo "🌤️ **Weather (Langley, BC):**"
curl -s "wttr.in/Langley+BC?format=%C+%t" 2>/dev/null || echo "(unavailable)"
echo ""
echo ""

# GitHub Trending
echo "🔥 **GitHub Trending:**"
bash "$HOME/.openclaw/workspace/shortcuts/github-trending.sh" 2>/dev/null | grep "⭐" | head -3
echo ""

# Moltbook Hot
echo "🦞 **Moltbook Hot:**"
bash "$HOME/.openclaw/workspace/shortcuts/molt.sh" 2>/dev/null | grep "↑\]" | head -3
echo ""

# Your Code Activity (today's projects)
echo "💻 **Your Recent Work:**"
cd "$HOME/Documents/Code" 2>/dev/null
for project in */; do
  if [ -d "$project/.git" ]; then
    last_commit=$(cd "$project" && git log -1 --format="%ar: %s" 2>/dev/null)
    if [ -n "$last_commit" ]; then
      echo "  $(basename "$project"): $last_commit"
    fi
  fi
done | head -5
echo ""

# Tasks
echo "📝 **Your Tasks:**"
if [ -f "$HOME/.openclaw/workspace/memory/tasks-and-reminders.md" ]; then
  grep -E "^\- \[ \]" "$HOME/.openclaw/workspace/memory/tasks-and-reminders.md" | head -5
else
  echo "(no tasks)"
fi
echo ""

# Calendar (next 24h)
echo "📅 **Next 24 Hours:**"
osascript -e 'tell application "Calendar" to get {summary, start date} of (every event whose start date > (current date) and start date < (current date) + 1 * days)' 2>/dev/null | sed 's/, date /\n  /g' | head -5 || echo "(no events)"
