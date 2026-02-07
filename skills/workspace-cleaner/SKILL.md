---
name: workspace-cleaner
description: Clean and organize Desktop, Downloads, and common clutter folders by file type. Use when user wants to declutter workspace, organize files by category, analyze disk usage, or clean up old files. Categorizes documents, images, videos, code, and more automatically.
---

# Workspace Cleaner

Automatically organize and clean up Desktop, Downloads, and other workspace folders.

## Quick Reference

**Analyze a directory:**
```bash
python3 scripts/clean_workspace.py analyze ~/Downloads
```

**Show large files (>10MB):**
```bash
python3 scripts/clean_workspace.py analyze ~/Downloads --large
```

**Show files larger than 50MB:**
```bash
python3 scripts/clean_workspace.py analyze ~/Downloads --large --threshold 50
```

**Organize files by type (preview):**
```bash
python3 scripts/clean_workspace.py organize ~/Downloads ~/Documents/Organized --dry-run
```

**Organize files (actually move):**
```bash
python3 scripts/clean_workspace.py organize ~/Downloads ~/Documents/Organized
```

**Organize but skip recent files (last 7 days):**
```bash
python3 scripts/clean_workspace.py organize ~/Downloads ~/Documents/Organized --skip-recent 7
```

**Move old files to Trash (>30 days, preview):**
```bash
python3 scripts/clean_workspace.py clean ~/Downloads --days 30 --dry-run
```

**Actually trash old files:**
```bash
python3 scripts/clean_workspace.py clean ~/Downloads --days 30
```

## File Categories

Files are automatically sorted into:
- **Documents** - PDF, Word, text files, etc.
- **Images** - JPG, PNG, HEIC, etc.
- **Videos** - MP4, MOV, etc.
- **Audio** - MP3, WAV, etc.
- **Archives** - ZIP, TAR, etc.
- **Code** - Python, JavaScript, etc.
- **Spreadsheets** - Excel, CSV, etc.
- **Presentations** - PowerPoint, Keynote, etc.
- **Installers** - DMG, PKG, APP bundles
- **Other** - Everything else

## Common Workflows

**Clean Downloads folder:**
1. Analyze to see what's there
2. Preview organization with `--dry-run`
3. Run actual organization
4. Clean old files if needed

**Organize Desktop:**
```bash
python3 scripts/clean_workspace.py analyze ~/Desktop --large
python3 scripts/clean_workspace.py organize ~/Desktop ~/Documents/Desktop-Organized
```

## Notes

- Always use `--dry-run` first to preview changes
- `--skip-recent` preserves actively-used files
- Trash uses macOS `trash` command (recoverable)
- Duplicate names get `_1`, `_2`, etc. appended
