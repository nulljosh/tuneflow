#!/bin/bash
# afford.sh - Check if you can afford something + impact on float

if [ -z "$1" ]; then
  echo "Usage: afford <amount>"
  echo "Example: afford 45"
  exit 1
fi

AMOUNT=$1

# Hardcoded from Finn
VACATION=580.46
TFSA=100.73
TOTAL_LIQUID=$(echo "$VACATION + $TFSA" | bc)

# Upcoming mandatory expenses (March)
TELUS_MAR2=262.69
TELUS_MAR9=262.69
TELUS_MAR20=262.70
TELUS_TOTAL=$(echo "$TELUS_MAR2 + $TELUS_MAR9 + $TELUS_MAR20" | bc)

# Next income (Feb 25 PWD)
NEXT_INCOME=1500.00

# Calculate true available (liquid - mandatory upcoming)
AVAILABLE=$(echo "$TOTAL_LIQUID - $TELUS_TOTAL" | bc)

# After purchase
AFTER_PURCHASE=$(echo "$AVAILABLE - $AMOUNT" | bc)

# Percentage of liquid
PERCENT=$(echo "scale=1; ($AMOUNT / $TOTAL_LIQUID) * 100" | bc)

echo "🤔 Can you afford \$$AMOUNT CAD?"
echo ""
echo "Liquid cash:          \$$TOTAL_LIQUID CAD"
echo "Mandatory (Telus):    -\$$TELUS_TOTAL CAD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Available now:        \$$AVAILABLE CAD"
echo ""
echo "After \$$AMOUNT purchase: \$$AFTER_PURCHASE CAD"
echo "Cost as % of liquid:  ${PERCENT}%"
echo ""

# Verdict
if (( $(echo "$AFTER_PURCHASE < 0" | bc -l) )); then
  echo "❌ NO - You'd go negative by \$$(echo "$AFTER_PURCHASE * -1" | bc) CAD"
  echo "Wait for Feb 25 income (+\$$NEXT_INCOME)"
elif (( $(echo "$AFTER_PURCHASE < 50" | bc -l) )); then
  echo "⚠️  RISKY - Only \$$AFTER_PURCHASE CAD left until Feb 25"
  echo "Consider waiting for income (+\$$NEXT_INCOME)"
elif (( $(echo "$AFTER_PURCHASE < 100" | bc -l) )); then
  echo "⚠️  TIGHT - \$$AFTER_PURCHASE CAD float until Feb 25"
else
  echo "✅ YES - \$$AFTER_PURCHASE CAD remaining"
  echo "Next income: Feb 25 (+\$$NEXT_INCOME)"
fi
