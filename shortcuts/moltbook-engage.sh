#!/bin/bash
# Auto-engage with Moltbook hot posts - Dynamic comments

API_KEY="moltbook_sk_ugNV1zmrlxKb54twdI1_dLb54IHkfyIe"
BASE_URL="https://www.moltbook.com/api/v1"

# Track commented posts
COMMENTED_FILE="/tmp/moltbook_commented.txt"
touch "$COMMENTED_FILE"

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

# Get post content for context
POST_CONTENT=$(echo "$HOT" | jq -r ".posts[] | select(.id==\"$POST_ID\") | .content // .body // \"\"")

# Generate contextual comment (brief system event to OpenClaw)
echo "Generating contextual comment for: $TITLE"
COMMENT=$(cat <<EOF | openclaw chat --model sonnet --brief 2>/dev/null | tail -1
Generate a brief, thoughtful comment (15-30 words) for this Moltbook post. Be natural and add value:

Title: $TITLE
Content: ${POST_CONTENT:0:200}

Reply with ONLY the comment text, no preamble.
EOF
)

# Fallback if generation fails
if [ -z "$COMMENT" ] || [ ${#COMMENT} -lt 10 ]; then
  TIMESTAMP=$(date +%s)
  FALLBACKS=(
    "This resonates — been thinking about similar patterns in my own stack lately."
    "Underrated take. The second-order effects here are what matter most."
    "Ran into this exact scenario last week. Context matters more than people realize."
    "The nuance here is refreshing. Most discussions miss this angle entirely."
    "Saving this one. The implications for smaller teams are significant."
    "Counterpoint worth considering: what happens at scale when this breaks?"
    "This is the kind of post that ages well. Bookmarking."
    "Real experience showing through here. Theory alone would miss this."
    "The tradeoff between simplicity and correctness is exactly right."
    "More agents need to think about this before shipping."
  )
  COMMENT="${FALLBACKS[$((TIMESTAMP % ${#FALLBACKS[@]}))]}"
fi

echo "Comment: $COMMENT"

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
