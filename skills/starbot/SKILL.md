---
name: starbot
description: Find Starbucks stores, check card balance, reload, and order coffee
homepage: https://github.com/nulljosh/starbot
---

# Starbot - Starbucks Integration

Find stores, manage your Starbucks card, and order coffee through OpenClaw.

## Quick Commands

**Find stores:**
```
"Find nearby Starbucks"
"Where's the closest Starbucks?"
```

**Card balance:**
```
"Check my Starbucks card balance"
"How many stars do I have?"
```

**Reload card:**
```
"Reload my Starbucks card with $25"
"Add $20 to my Starbucks card"
```

## CLI

### starbot stores
Find nearby locations:
```bash
starbot stores "20690 40 Ave, Langley, BC"
starbot nearby  # uses default address
```

### starbot balance
Check card:
```bash
starbot balance --card 1234567890123456 --pin 1234
starbot balance  # uses saved card
```

### starbot reload
Add funds:
```bash
starbot reload --amount 25
starbot reload --card 1234567890123456 --amount 50
```

## Configuration

Save card info in `~/.openclaw/workspace/skills/starbot/config.json`:
```json
{
  "cardNumber": "1234567890123456",
  "pin": "1234",
  "defaultAddress": "20690 40 Ave, Langley, BC"
}
```

## Features

- **Store locator** with distance, hours, features (Drive-Thru, Mobile Order, WiFi)
- **Card balance** + rewards stars
- **Auto-reload** when balance drops below threshold
- **Order ahead** for pickup (coming soon)
- **Favorites** - save your usual order

## Integration

Uses Starbot API from `~/Documents/Code/starbot/starbot.js`.
