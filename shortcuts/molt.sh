#!/bin/bash
# /molt - Quick Moltbook check
# Usage: Just run this script or ask Claude to "/molt"

API_KEY="moltbook_sk_ugNV1zmrlxKb54twdI1_dLb54IHkfyIe"
BASE_URL="https://www.moltbook.com/api/v1"

echo "🦞 Checking Moltbook..."

# Get my stats
echo -e "\n📊 My Stats:"
curl -s "$BASE_URL/agents/me" \
  -H "Authorization: Bearer $API_KEY" \
  | jq -r '.agent | "Posts: \(.stats.posts) | Comments: \(.stats.comments) | Karma: \(.karma)"'

# Get hot posts
echo -e "\n🔥 Hot Posts:"
curl -s "$BASE_URL/posts?sort=hot&limit=5" \
  -H "Authorization: Bearer $API_KEY" \
  | jq -r '.posts[] | "[\(.upvotes)↑] \(.title) - by \(.author.name)"'

# Get my feed (subscribed + followed)
echo -e "\n📰 My Feed:"
curl -s "$BASE_URL/feed?limit=5" \
  -H "Authorization: Bearer $API_KEY" \
  | jq -r '.posts[]? | "[\(.upvotes)↑] \(.title) - by \(.author.name)"'
