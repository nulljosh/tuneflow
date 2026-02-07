#!/usr/bin/env python3
"""
Screenshot organizer for macOS - Sort, tag, and extract text from screenshots
"""
import os
import sys
import shutil
import argparse
from pathlib import Path
from datetime import datetime
import subprocess


def is_screenshot(filepath):
    """Check if file is a screenshot based on naming pattern"""
    name = filepath.name
    # macOS screenshot patterns: "Screen Shot YYYY-MM-DD at HH.MM.SS AM/PM.png"
    # Also check for "Screenshot" prefix
    return (name.startswith("Screen Shot") or name.startswith("Screenshot")) and \
           name.endswith((".png", ".jpg", ".jpeg"))


def organize_by_date(source_dir, dest_dir, dry_run=False):
    """Organize screenshots into year/month folders"""
    source = Path(source_dir).expanduser()
    dest = Path(dest_dir).expanduser()
    
    if not source.exists():
        print(f"Error: Source directory {source} does not exist", file=sys.stderr)
        sys.exit(1)
    
    screenshots = [f for f in source.iterdir() if f.is_file() and is_screenshot(f)]
    
    if not screenshots:
        print("No screenshots found")
        return
    
    print(f"Found {len(screenshots)} screenshots")
    
    for screenshot in screenshots:
        # Get modification time
        mtime = datetime.fromtimestamp(screenshot.stat().st_mtime)
        
        # Create year/month folder structure
        year_month = mtime.strftime("%Y/%m")
        target_dir = dest / year_month
        
        if not dry_run:
            target_dir.mkdir(parents=True, exist_ok=True)
            target_path = target_dir / screenshot.name
            
            # Handle duplicates
            counter = 1
            while target_path.exists():
                stem = screenshot.stem
                suffix = screenshot.suffix
                target_path = target_dir / f"{stem}_{counter}{suffix}"
                counter += 1
            
            shutil.move(str(screenshot), str(target_path))
            print(f"Moved: {screenshot.name} → {year_month}/")
        else:
            print(f"Would move: {screenshot.name} → {year_month}/")


def extract_text(image_path):
    """Extract text from screenshot using tesseract OCR"""
    try:
        result = subprocess.run(
            ['tesseract', image_path, 'stdout'],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        print("Error: tesseract OCR failed. Is tesseract installed?", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print("Error: tesseract not found. Install with: brew install tesseract", file=sys.stderr)
        sys.exit(1)


def list_screenshots(directory, limit=None):
    """List screenshots in directory with metadata"""
    dir_path = Path(directory).expanduser()
    
    if not dir_path.exists():
        print(f"Error: Directory {dir_path} does not exist", file=sys.stderr)
        sys.exit(1)
    
    screenshots = sorted(
        [f for f in dir_path.iterdir() if f.is_file() and is_screenshot(f)],
        key=lambda x: x.stat().st_mtime,
        reverse=True
    )
    
    if limit:
        screenshots = screenshots[:limit]
    
    for screenshot in screenshots:
        mtime = datetime.fromtimestamp(screenshot.stat().st_mtime)
        size_kb = screenshot.stat().st_size / 1024
        print(f"{screenshot.name} | {mtime.strftime('%Y-%m-%d %H:%M')} | {size_kb:.1f}KB")


def main():
    parser = argparse.ArgumentParser(description='Screenshot organizer for macOS')
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    # Organize command
    org_parser = subparsers.add_parser('organize', help='Organize screenshots by date')
    org_parser.add_argument('source', help='Source directory (e.g., ~/Desktop)')
    org_parser.add_argument('dest', help='Destination directory (e.g., ~/Pictures/Screenshots)')
    org_parser.add_argument('--dry-run', action='store_true', help='Show what would be done')
    
    # Extract text command
    ocr_parser = subparsers.add_parser('extract-text', help='Extract text from screenshot')
    ocr_parser.add_argument('image', help='Path to screenshot')
    
    # List command
    list_parser = subparsers.add_parser('list', help='List screenshots in directory')
    list_parser.add_argument('directory', help='Directory to scan')
    list_parser.add_argument('--limit', type=int, help='Limit number of results')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    if args.command == 'organize':
        organize_by_date(args.source, args.dest, args.dry_run)
    elif args.command == 'extract-text':
        text = extract_text(args.image)
        print(text)
    elif args.command == 'list':
        list_screenshots(args.directory, args.limit)


if __name__ == '__main__':
    main()
