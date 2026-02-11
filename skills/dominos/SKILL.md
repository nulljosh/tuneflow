---
name: dominos
description: Order Dominos Pizza, track deliveries, and browse menus via OpenClaw
homepage: https://github.com/nulljosh/dominos
---

# Dominos Pizza Integration

Order pizza, track deliveries, and browse menus directly through OpenClaw.

## Quick Start

**Order pizza:**
```
"Order a large pepperoni pizza for delivery"
"Order 2 medium pizzas with extra cheese"
```

**Track order:**
```
"Track my Dominos order"
"Where's my pizza?"
```

**Find stores:**
```
"Find nearby Dominos stores"
"What's the closest Dominos?"
```

## Commands

### dominos order
Create and place an order:
```bash
dominos order \
  --address "20690 40 Ave, Langley, BC" \
  --pizza "14SCREEN" \
  --coupon "9193" \
  --name "Joshua" \
  --phone "6045342277"
```

### dominos track
Track order status:
```bash
dominos track --phone "6045342277"
dominos track --store 8396 --order ABC123
```

### dominos stores
Find nearby stores:
```bash
dominos stores "20690 40 Ave, Langley, BC"
dominos stores --postal "V3A2X7"
```

### dominos menu
Browse menu:
```bash
dominos menu --store 8396
dominos menu --search "pepperoni"
```

## Configuration

Set default address in `~/.openclaw/workspace/skills/dominos/config.json`:
```json
{
  "defaultAddress": "20690 40 Ave, Langley, BC V3A2X7",
  "defaultPhone": "6045342277",
  "defaultName": "Joshua",
  "region": "ca"
}
```

## Order Flow

1. **Find stores** → Select closest delivery store
2. **Browse menu** → Pick products (pizza, sides, drinks)
3. **Add coupons** → Apply discounts
4. **Validate** → Check order is correct
5. **Price** → See total cost
6. **Place** → Submit order (requires payment)
7. **Track** → Monitor status until delivered

## Payment

Orders require payment info:
```javascript
{
  type: "CreditCard",
  number: "4111111111111111", // test card
  expiration: "1225",
  cvv: "123",
  postalCode: "V3A2X7"
}
```

**Note:** Never store payment info in config. OpenClaw will prompt when needed.

## Integration

The skill uses the Dominos API from `~/Documents/Code/dominos/dominos.js`.

Auto-updates when you modify the API code.

## Examples

**Simple order:**
> "Order a large pepperoni pizza"
→ Finds nearest store, adds 14SCREEN, applies best coupon, shows price

**Track delivery:**
> "Where's my pizza?"
→ Checks tracker, replies: "Out for delivery, ETA 15 mins"

**Menu search:**
> "What chicken items does Dominos have?"
→ Lists all chicken products with codes

## Status Tracking

Order stages:
- Order Placed
- Prep
- Bake
- Quality Check
- Out for Delivery
- Delivered

OpenClaw can send notifications at each stage.
