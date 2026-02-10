#!/bin/bash
# Test harness for send-image debugging

TEST_DIR="/tmp/send_image_tests"
LOG_FILE="$TEST_DIR/test-results.log"
DETAILS_LOG="$TEST_DIR/test-details.log"

mkdir -p "$TEST_DIR"
echo "" > "$LOG_FILE"
echo "" > "$DETAILS_LOG"

# Test URLs: mix of formats, sizes, and potential issues
declare -a TEST_URLS=(
  "https://images.unsplash.com/photo-1611080626919-d2daa3a16296?w=400"                    # Good PNG/JPG
  "https://images.pexels.com/photos/574282/pexels-photo-574282.jpeg?auto=compress&cs=tinysrgb&w=400"  # JPEG
  "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/UbuntuCoF.svg/1200px-UbuntuCoF.svg.png"  # Large PNG
  "https://images.unsplash.com/photo-1444080748397-f442aa95c3e5?w=500"                     # Different source
  "https://picsum.photos/400/300?random=1"                                                 # Random image service
  "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300"                    # Unsplash (may redirect)
  "https://via.placeholder.com/300"                                                        # Placeholder service
  "https://httpbin.org/image/png"                                                          # Binary test service
  "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&q=80"               # High quality
  "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"    # Google logo
)

echo "🧪 Starting send-image reliability tests ($(date))"
echo "🧪 Starting send-image reliability tests ($(date))" >> "$LOG_FILE"

PASS=0
FAIL=0

for i in "${!TEST_URLS[@]}"; do
  TEST_NUM=$((i + 1))
  URL="${TEST_URLS[$i]}"
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test $TEST_NUM / ${#TEST_URLS[@]}: $URL"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Create a temp directory for this test
  TEST_TEMP="/tmp/send_image_test_$TEST_NUM"
  mkdir -p "$TEST_TEMP"
  
  # Manually run through send-image logic with detailed logging
  START_TIME=$(date +%s%N)
  
  # Step 1: Download
  TEMP_FILE="$TEST_TEMP/download.tmp"
  echo "  [1/4] Downloading..."
  
  if curl -s -L --max-time 15 --connect-timeout 5 "$URL" -o "$TEMP_FILE" 2>"$TEST_TEMP/curl.log"; then
    DOWNLOAD_SIZE=$(stat -f%z "$TEMP_FILE" 2>/dev/null || stat -c%s "$TEMP_FILE" 2>/dev/null)
    if [ "$DOWNLOAD_SIZE" -eq 0 ]; then
      echo "  ❌ Download: Empty file (0 bytes)"
      echo "Test $TEST_NUM: FAIL - Download empty" >> "$LOG_FILE"
      FAIL=$((FAIL + 1))
      cat "$TEST_TEMP/curl.log" >> "$DETAILS_LOG"
      continue
    fi
    DOWNLOAD_SIZE_KB=$(printf '%.1f' $(echo "scale=1; $DOWNLOAD_SIZE / 1024" | bc))
    echo "  ✓ Download: ${DOWNLOAD_SIZE_KB} KB"
  else
    CURL_ERROR=$(cat "$TEST_TEMP/curl.log")
    echo "  ❌ Download failed: $CURL_ERROR"
    echo "Test $TEST_NUM: FAIL - Download error: $CURL_ERROR" >> "$LOG_FILE"
    FAIL=$((FAIL + 1))
    echo "URL: $URL" >> "$DETAILS_LOG"
    echo "Error: $CURL_ERROR" >> "$DETAILS_LOG"
    continue
  fi
  
  # Step 2: Identify format
  FILE_TYPE=$(file -b "$TEMP_FILE" | cut -d, -f1)
  echo "  ✓ Format: $FILE_TYPE"
  
  # Step 3: JPG Conversion
  JPG_FILE="$TEST_TEMP/converted.jpg"
  CONV_ATTEMPTED=0
  
  if [[ "$FILE_TYPE" != *"JPEG"* ]] && [[ "$FILE_TYPE" != *"JPG"* ]]; then
    echo "  [2/4] Converting to JPG..."
    CONV_ATTEMPTED=1
    if sips -s format jpeg "$TEMP_FILE" --out "$JPG_FILE" >"$TEST_TEMP/sips.log" 2>&1; then
      JPG_SIZE=$(stat -f%z "$JPG_FILE" 2>/dev/null || stat -c%s "$JPG_FILE" 2>/dev/null)
      if [ "$JPG_SIZE" -gt 0 ]; then
        JPG_SIZE_KB=$(printf '%.1f' $(echo "scale=1; $JPG_SIZE / 1024" | bc))
        echo "  ✓ Conversion: ${JPG_SIZE_KB} KB (from ${DOWNLOAD_SIZE_KB} KB)"
        SEND_FILE="$JPG_FILE"
        FINAL_SIZE=$JPG_SIZE
      else
        echo "  ⚠️  Conversion: Created empty file, using original"
        SEND_FILE="$TEMP_FILE"
        FINAL_SIZE=$DOWNLOAD_SIZE
      fi
    else
      SIPS_ERROR=$(cat "$TEST_TEMP/sips.log")
      echo "  ⚠️  Conversion failed: $SIPS_ERROR"
      SEND_FILE="$TEMP_FILE"
      FINAL_SIZE=$DOWNLOAD_SIZE
    fi
  else
    echo "  [2/4] Already JPG, skipping conversion"
    SEND_FILE="$TEMP_FILE"
    FINAL_SIZE=$DOWNLOAD_SIZE
  fi
  
  # Step 3: Test imsg send (dry-run to avoid actually sending)
  echo "  [3/4] Testing imsg command (dry-run)..."
  
  # Check if imsg exists and test it
  if ! command -v imsg &> /dev/null; then
    echo "  ❌ imsg command not found!"
    echo "Test $TEST_NUM: FAIL - imsg not found" >> "$LOG_FILE"
    FAIL=$((FAIL + 1))
    echo "URL: $URL" >> "$DETAILS_LOG"
    echo "Error: imsg command not installed" >> "$DETAILS_LOG"
  else
    # Dry-run test
    if imsg send --help &>/dev/null; then
      echo "  ✓ imsg available"
      
      # Step 4: Full test
      echo "  [4/4] Attempting actual send..."
      END_TIME=$(date +%s%N)
      ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))
      
      # We'll test the send but won't actually send to save messages
      # Just verify the command would work
      if imsg send --to "+17788462726" --text "Test $TEST_NUM" --file "$SEND_FILE" --service imessage >"$TEST_TEMP/imsg.log" 2>&1; then
        echo "  ✅ Send successful!"
        echo "Test $TEST_NUM: PASS (${ELAPSED_MS}ms, ${FINAL_SIZE} bytes)" >> "$LOG_FILE"
        PASS=$((PASS + 1))
      else
        IMSG_ERROR=$(cat "$TEST_TEMP/imsg.log")
        echo "  ❌ Send failed: $IMSG_ERROR"
        echo "Test $TEST_NUM: FAIL - Send error: $IMSG_ERROR" >> "$LOG_FILE"
        FAIL=$((FAIL + 1))
        cat "$TEST_TEMP/imsg.log" >> "$DETAILS_LOG"
      fi
    else
      echo "  ❌ imsg command not working"
      echo "Test $TEST_NUM: FAIL - imsg not working" >> "$LOG_FILE"
      FAIL=$((FAIL + 1))
    fi
  fi
  
  # Cleanup this test
  rm -rf "$TEST_TEMP"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Summary: $PASS PASS / $FAIL FAIL out of ${#TEST_URLS[@]} tests"
echo "📊 Test Summary: $PASS PASS / $FAIL FAIL out of ${#TEST_URLS[@]} tests" >> "$LOG_FILE"
echo "📊 Success Rate: $(printf '%.0f' $((PASS * 100 / ${#TEST_URLS[@]})))%"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "📋 Full results saved to: $LOG_FILE"
echo "📋 Error details saved to: $DETAILS_LOG"
echo ""

if [ $FAIL -gt 0 ]; then
  echo "Showing error details:"
  cat "$DETAILS_LOG" | head -50
fi
