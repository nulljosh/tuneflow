# Per-Contact Memory System

Each phone number gets its own memory directory.

## Structure

```
memory/
├── contacts/
│   ├── +17788462726/          # Joshua (main)
│   │   ├── MEMORY.md
│   │   ├── tasks.md
│   │   └── 2026-02-07.md
│   ├── +17788407755/          # Stranger (zkml guy)
│   │   ├── MEMORY.md
│   │   └── 2026-02-07.md
│   └── +16042408966/          # Mom
│       └── MEMORY.md
```

## Usage Rules

1. **Main memory (MEMORY.md)** - Only for Joshua (+17788462726)
2. **Contact-specific memory** - Stored in `memory/contacts/{phone}/`
3. **Access control** - Check USER.md allowlist before reading

## Implementation

When receiving a message:
1. Extract phone number from session
2. Check if `memory/contacts/{phone}/` exists
3. If not, create it (first contact)
4. Read `memory/contacts/{phone}/MEMORY.md` (if allowed)
5. Write session notes to `memory/contacts/{phone}/YYYY-MM-DD.md`

## Security

- Main MEMORY.md: Joshua only
- Contact memory: Isolated per number
- Strangers: Can have memory BUT it's sandboxed to their own directory
- No cross-contamination
