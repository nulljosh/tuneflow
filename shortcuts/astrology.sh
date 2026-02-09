#!/bin/bash
# Get daily astrology for Virgo

echo "♍ Virgo Daily Horoscope"
curl -s "https://www.astrology.com/horoscope/daily/virgo.html" | grep -A 5 "horoscope-content" | sed 's/<[^>]*>//g' | head -5 | tr -d '\n' | sed 's/  */ /g'
