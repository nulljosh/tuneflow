---
name: browser-bookmarks
description: Manage Safari and Chrome bookmarks via CLI. Use when user wants to list, search, export, or find duplicate bookmarks. Supports reading from Safari and Chrome bookmark storage, searching by title/URL, exporting to JSON/HTML, and detecting duplicates.
---

# Browser Bookmarks Manager

Read, search, and manage bookmarks from Safari and Chrome on macOS.

## Quick Reference

**List all Safari bookmarks:**
```bash
python3 scripts/bookmarks_cli.py list --browser safari
```

**List Chrome bookmarks:**
```bash
python3 scripts/bookmarks_cli.py list --browser chrome
```

**Search bookmarks:**
```bash
python3 scripts/bookmarks_cli.py list --browser safari --search "github"
```

**Filter by folder:**
```bash
python3 scripts/bookmarks_cli.py list --browser safari --folder "Work"
```

**Export to JSON:**
```bash
python3 scripts/bookmarks_cli.py export --browser safari --output bookmarks.json
```

**Export to HTML (standard bookmark format):**
```bash
python3 scripts/bookmarks_cli.py export --browser safari --output bookmarks.html
```

**Find duplicate bookmarks:**
```bash
python3 scripts/bookmarks_cli.py duplicates --browser safari
```

## Supported Browsers

- **Safari** - Reads from `~/Library/Safari/Bookmarks.plist`
- **Chrome** - Reads from `~/Library/Application Support/Google/Chrome/Default/Bookmarks`

## Common Use Cases

**Search across all bookmarks:**
```bash
python3 scripts/bookmarks_cli.py list --search "react"
```

**Backup bookmarks:**
```bash
python3 scripts/bookmarks_cli.py export --output ~/Documents/bookmarks_backup.json
```

**Find and clean duplicates:**
1. Run `duplicates` command to see what's duplicated
2. Manually clean in browser or use export/import workflow

**Export for migration:**
HTML export format works with most browsers for importing.

## Notes

- Read-only access (doesn't modify browser bookmarks)
- Safari bookmarks use binary plist format
- Chrome bookmarks use JSON format
- Export to HTML creates standard Netscape bookmark format
- Duplicate detection matches by exact URL
