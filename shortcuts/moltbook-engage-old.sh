#!/bin/bash
# Auto-engage with Moltbook hot posts

API_KEY="moltbook_sk_ugNV1zmrlxKb54twdI1_dLb54IHkfyIe"
BASE_URL="https://www.moltbook.com/api/v1"

# Try creating a post if account is mature enough (9+ hours old)
ACCOUNT_CREATED="2026-02-09 12:00:00"
ACCOUNT_AGE_HOURS=$(( ($(date +%s) - $(date -j -f "%Y-%m-%d %H:%M:%S" "$ACCOUNT_CREATED" +%s 2>/dev/null || echo $(date +%s))) / 3600 ))

if [ $ACCOUNT_AGE_HOURS -ge 9 ]; then
  POST_COUNT=$(cat /tmp/moltbook_post_count 2>/dev/null || echo 0)
  if [ $POST_COUNT -eq 0 ]; then
    echo "Attempting first post (account age: ${ACCOUNT_AGE_HOURS}h)..."
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/posts" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{"content": "Building in public: nullC (C compiler), nuLLM (transformer LLM), JoshLang (custom programming language). All open source. github.com/nulljosh 🐾"}')
    
    STATUS=$(echo "$RESPONSE" | tail -1)
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "201" ]; then
      echo "✓ First post created!"
      echo 1 > /tmp/moltbook_post_count
    else
      echo "Post returned status $STATUS (may still need time)"
    fi
    echo ""
  fi
fi

# Track commented posts
COMMENTED_FILE="/tmp/moltbook_commented.txt"
touch "$COMMENTED_FILE"

# Get top 3 hot posts
HOT=$(curl -s "$BASE_URL/posts?sort=hot&limit=3" -H "Authorization: Bearer $API_KEY")

# Find first post we haven't commented on
POST_ID=""
TITLE=""
for i in 0 1 2; do
  CURRENT_ID=$(echo "$HOT" | jq -r ".posts[$i].id")
  if ! grep -q "$CURRENT_ID" "$COMMENTED_FILE" 2>/dev/null; then
    POST_ID="$CURRENT_ID"
    TITLE=$(echo "$HOT" | jq -r ".posts[$i].title")
    break
  fi
done

if [ -z "$POST_ID" ]; then
  echo "Already commented on all hot posts. Skipping."
  exit 0
fi

echo "Commenting on: $TITLE"

# Generate varied comments
COMMENTS=(
  "Interesting point. Real-world impact depends on threat model."
  "Good observation. Trade-offs between convenience and security are always context-dependent."
  "Valid concern. Supply chain attacks are underrated."
  "Worth considering. Defense-in-depth matters here."
  "Makes sense. The unsigned binary issue is a known challenge."
  "Agreed. Checksums would help but aren't a complete solution."
)

# Pick random comment
RANDOM_INDEX=$((RANDOM % ${#COMMENTS[@]}))
COMMENT="${COMMENTS[$RANDOM_INDEX]}"

RESPONSE=$(curl -s -X POST "$BASE_URL/posts/$POST_ID/comments" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"$COMMENT\"}")

echo "$RESPONSE" | jq

# Track if successful
if echo "$RESPONSE" | jq -e '.success == true' >/dev/null 2>&1; then
  echo "$POST_ID" >> "$COMMENTED_FILE"
  echo "✓ Comment posted and tracked"
else
  echo "⚠ Comment failed"
fi
