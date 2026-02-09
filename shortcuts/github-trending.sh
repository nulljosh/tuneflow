#!/bin/bash
# GitHub trending repos - daily summary

echo "🔥 GitHub Trending (Most Starred This Week)"
echo ""

# Use GitHub API to find recently popular repos
TODAY=$(date -u +%Y-%m-%d)
WEEK_AGO=$(date -u -v-7d +%Y-%m-%d 2>/dev/null || date -u -d "7 days ago" +%Y-%m-%d)

gh api "/search/repositories?q=created:>$WEEK_AGO&sort=stars&order=desc&per_page=10" \
  --jq '.items[] | "[\(.stargazers_count)⭐] \(.full_name) - \(.description // "No description")"' \
  | head -10

echo ""
echo "Your recent activity:"
gh api "/users/nulljosh/events/public?per_page=5" \
  --jq '.[] | select(.type == "PushEvent") | "  Pushed to \(.repo.name)"' \
  | head -5
