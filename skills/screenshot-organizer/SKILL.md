---
name: screenshot-organizer
description: Organize, sort, and extract text from macOS screenshots. Use when user wants to clean up screenshots, sort them by date, extract text content via OCR, or find specific screenshots on their system.
---

# Screenshot Organizer

Automatically organize macOS screenshots and extract text content.

## Quick Reference

**List screenshots in a directory:**
```bash
python3 scripts/organize_screenshots.py list ~/Desktop
```

**List most recent 10 screenshots:**
```bash
python3 scripts/organize_screenshots.py list ~/Desktop --limit 10
```

**Organize screenshots by date (preview):**
```bash
python3 scripts/organize_screenshots.py organize ~/Desktop ~/Pictures/Screenshots --dry-run
```

**Organize screenshots (actually move files):**
```bash
python3 scripts/organize_screenshots.py organize ~/Desktop ~/Pictures/Screenshots
```

**Extract text from a screenshot:**
```bash
python3 scripts/organize_screenshots.py extract-text ~/Desktop/Screen\ Shot\ 2026-02-06.png
```

## Organization Structure

Files are organized into `YYYY/MM/` folders based on modification date:
```
~/Pictures/Screenshots/
├── 2026/
│   ├── 01/
│   │   ├── Screen Shot 2026-01-15 at 2.30.45 PM.png
│   │   └── Screen Shot 2026-01-20 at 9.15.22 AM.png
│   └── 02/
│       └── Screen Shot 2026-02-06 at 11.20.00 AM.png
```

## Text Extraction

Requires tesseract OCR:
```bash
brew install tesseract
```

Extract text from screenshots to search content or save as notes.

## Notes

- Detects macOS screenshot naming patterns automatically
- Handles duplicate filenames by appending counter
- Preview mode (`--dry-run`) shows changes without moving files
- OCR works best on screenshots with clear, readable text
