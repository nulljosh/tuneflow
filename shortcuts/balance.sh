#!/bin/bash
# balance.sh - Show current liquid cash from Finn data

# Hardcoded from Finn (index.html)
VACATION=580.46
TFSA=100.73

TOTAL=$(echo "$VACATION + $TFSA" | bc)
USD=$(echo "scale=2; $TOTAL * 0.73" | bc)  # ~0.73 CAD->USD

echo "💰 Liquid Cash"
echo ""
echo "Vacation (Chequing): \$$VACATION CAD"
echo "TFSA (Cash):         \$$TFSA CAD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total:               \$$TOTAL CAD (~\$$USD USD)"
