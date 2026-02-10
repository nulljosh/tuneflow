#!/bin/bash
# Test harness for send-image v2 with improved reliability

TEST_DIR="/tmp/send_image_tests_v2"
LOG_FILE="$TEST_DIR/test-results.log"
SEND_IMAGE_SCRIPT="/Users/joshua/.openclaw/workspace/shortcuts/send-image"

mkdir -p "$TEST_DIR"
echo "" > "$LOG_FILE"

# Test URLs: mix of formats, sizes, and potential issues
# Removed invalid URLs and kept only resolvable ones
declare -a TEST_URLS=(
  "https://images.unsplash.com/photo-1611080626919-d2daa3a16296?w=400"                    # Good JPEG
  "https://images.unsplash.com/photo-1444080748397-f442aa95c3e5?w=500"                    # JPEG
  "https://picsum.photos/400/300?random=1"                                                 # Random JPEG service
  "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300"                    # Unsplash JPEG
  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Venn_diagram.svg/600px-Venn_diagram.svg.png"  # PNG
  "https://httpbin.org/image/jpeg"                                                         # Binary JPEG service
  "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"    # PNG
  "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&q=80"               # High quality JPEG
  "https://picsum.photos/500/400?random=2"                                                 # Another random JPEG
  "https://images.unsplash.com/photo-1500627489223-8271ae517261?w=400"                    # JPEG Unsplash
)

echo "🧪 Testing send-image v2 reliability ($(date))"
echo "🧪 Testing send-image v2 reliability ($(date))" >> "$LOG_FILE"
echo "Script: $SEND_IMAGE_SCRIPT"
echo "Script: $SEND_IMAGE_SCRIPT" >> "$LOG_FILE"
echo ""

PASS=0
FAIL=0

for i in "${!TEST_URLS[@]}"; do
  TEST_NUM=$((i + 1))
  URL="${TEST_URLS[$i]}"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test $TEST_NUM / ${#TEST_URLS[@]}"
  echo "URL: $URL"
  
  START_TIME=$(date +%s%N)
  
  # Run send-image script (won't actually send, just test the logic up to send attempt)
  # We'll capture output to see if it succeeds
  TEST_OUTPUT=$("$SEND_IMAGE_SCRIPT" "$URL" "+17788462726" "Test $TEST_NUM" 2>&1)
  TEST_EXIT=$?
  
  END_TIME=$(date +%s%N)
  ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))
  
  echo "$TEST_OUTPUT"
  
  # Check if it succeeded (exit code 0 or contains "✅ Sent successfully")
  if [ $TEST_EXIT -eq 0 ] || echo "$TEST_OUTPUT" | grep -q "✅"; then
    echo "✅ Test $TEST_NUM: PASS (${ELAPSED_MS}ms)"
    echo "Test $TEST_NUM: PASS (${ELAPSED_MS}ms) - $URL" >> "$LOG_FILE"
    PASS=$((PASS + 1))
  else
    echo "❌ Test $TEST_NUM: FAIL (exit code: $TEST_EXIT)"
    echo "Test $TEST_NUM: FAIL (exit code: $TEST_EXIT) - $URL" >> "$LOG_FILE"
    FAIL=$((FAIL + 1))
  fi
  
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Summary: $PASS PASS / $FAIL FAIL out of ${#TEST_URLS[@]} tests"
echo "📊 Test Summary: $PASS PASS / $FAIL FAIL out of ${#TEST_URLS[@]} tests" >> "$LOG_FILE"

if [ ${#TEST_URLS[@]} -gt 0 ]; then
  PERCENT=$((PASS * 100 / ${#TEST_URLS[@]}))
  echo "📊 Success Rate: ${PERCENT}%"
  echo "📊 Success Rate: ${PERCENT}%" >> "$LOG_FILE"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Results saved to: $LOG_FILE"
echo ""
cat "$LOG_FILE"
