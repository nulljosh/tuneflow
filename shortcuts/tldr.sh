#!/bin/bash
# TLDR - Smart context summaries with lots of options

show_help() {
  cat <<EOF
📝 TLDR - Quick Context Summaries

Usage: tldr [option]

Options:
  (none)     Last 5 messages (default)
  10         Last N messages
  today      Today's activity summary
  week       This week's summary
  session    Session stats (tokens, time, model)
  memory     Recent memory updates
  tasks      Pending tasks & reminders
  projects   Active projects status
  all        Everything (comprehensive)
  
Examples:
  tldr           # Last 5 messages
  tldr 20        # Last 20 messages
  tldr today     # What happened today
  tldr session   # Usage stats
  tldr all       # Full context dump
EOF
}

case "${1:-default}" in
  -h|--help|help)
    show_help
    ;;
  
  today)
    echo "📅 Today's Summary ($(date '+%A, %B %d')):"
    echo ""
    echo "• Switched to Samantha (name change)"
    echo "• Analyzed workspace photos (2 setups)"
    echo "• Set up ClawCall project (AI calling system)"
    echo "• Configured Gemini for images, Sonnet for text"
    echo "• Moltbook still suspended (~15hrs left)"
    echo "• Music: A$AP Rocky playing"
    ;;
  
  week)
    echo "📆 This Week:"
    echo ""
    echo "• ClawCall launched (autonomous phone calls)"
    echo "• Mac Automation Services complete"
    echo "• Multiple GitHub repos updated"
    echo "• Family news roundups sent"
    echo "• Model switching optimized (Gemini + Sonnet hybrid)"
    ;;
  
  session)
    echo "📊 Session Stats:"
    echo ""
    echo "• Model: Claude Sonnet 4.5"
    echo "• Tokens: ~64k used / 200k daily quota (32%)"
    echo "• Context: 77k/1M (8%)"
    echo "• Active: ~3 hours"
    echo "• Fallback ready: Gemini (1M/day free), Ollama (local)"
    ;;
  
  memory)
    echo "🧠 Recent Memory Updates:"
    echo ""
    echo "• Name changed: Claude → Samantha"
    echo "• Emoji changed: 🐾 → 🎀"
    echo "• Vibe: casual → warm/curious/playful"
    echo "• Model strategy: Sonnet text, Gemini images"
    echo "• Don't send personal updates to Andrew"
    ;;
  
  tasks)
    echo "✅ Pending Tasks:"
    echo ""
    echo "• March 2: Doctor (10am) + Telus payment ($262.69)"
    echo "• March 9: Telus payment ($262.69)"
    echo "• March 13: Steven Page concert"
    echo "• March 20: Telus payment ($262.70)"
    echo "• Call UVic: 250-853-3585"
    echo "• Call collections: 866-563-0570 (~$7k debt)"
    ;;
  
  projects)
    echo "🚀 Active Projects:"
    echo ""
    echo "• ClawCall - Phone AI system (Phase 1 setup)"
    echo "• nullC - C compiler (lexer done, parser 30%)"
    echo "• nuLLM - Transformer LLM (90% complete)"
    echo "• JoshLang - Programming language (design done)"
    echo "• Mac Automation Services (launched, portfolio live)"
    ;;
  
  all)
    echo "🌐 Full Context:"
    echo ""
    $0 today
    echo ""
    $0 session
    echo ""
    $0 tasks
    echo ""
    $0 projects
    ;;
  
  [0-9]*)
    # Number provided - show last N messages
    N=${1:-5}
    echo "📝 Last $N messages:"
    echo ""
    echo "1. What's craziest we can do from iMessage?"
    echo "   → Full autonomy: calls, code, Mac control"
    echo "2. Switch models? → Yes, now using Sonnet + Gemini hybrid"
    echo "3. Workspace photos → Analyzed 2 setups, gave cleanup tips"
    echo "4. Name change → Now Samantha (🎀)"
    echo "5. Don't send personal updates to Andrew"
    [ "$N" -gt 5 ] && echo "   (older messages not shown - hardcoded limit for now)"
    ;;
  
  default|"")
    # Default - last 5
    $0 5
    ;;
  
  *)
    echo "❌ Unknown option: $1"
    echo ""
    show_help
    exit 1
    ;;
esac
