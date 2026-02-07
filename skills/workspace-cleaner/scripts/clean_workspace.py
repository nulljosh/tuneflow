#!/usr/bin/env python3
"""
Workspace cleaner - Organize Downloads, Desktop, and other common clutter folders
"""
import os
import sys
import shutil
import argparse
from pathlib import Path
from datetime import datetime
import json


# File type categories
FILE_CATEGORIES = {
    'Documents': ['.pdf', '.doc', '.docx', '.txt', '.rtf', '.pages', '.odt'],
    'Images': ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg', '.webp', '.heic'],
    'Videos': ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v'],
    'Audio': ['.mp3', '.wav', '.aac', '.m4a', '.flac', '.ogg'],
    'Archives': ['.zip', '.tar', '.gz', '.rar', '.7z', '.bz2'],
    'Code': ['.py', '.js', '.ts', '.html', '.css', '.java', '.cpp', '.c', '.go', '.rs', '.swift'],
    'Spreadsheets': ['.xls', '.xlsx', '.csv', '.numbers'],
    'Presentations': ['.ppt', '.pptx', '.key'],
    'Installers': ['.dmg', '.pkg', '.app'],
}


def categorize_file(filepath):
    """Determine category for a file based on extension"""
    ext = filepath.suffix.lower()
    
    for category, extensions in FILE_CATEGORIES.items():
        if ext in extensions:
            return category
    
    return 'Other'


def analyze_directory(directory, show_large=False, size_threshold_mb=10):
    """Analyze directory contents and show statistics"""
    dir_path = Path(directory).expanduser()
    
    if not dir_path.exists():
        print(f"Error: Directory {dir_path} does not exist", file=sys.stderr)
        sys.exit(1)
    
    # Collect statistics
    stats = {}
    large_files = []
    total_size = 0
    
    for item in dir_path.iterdir():
        if not item.is_file():
            continue
        
        size = item.stat().st_size
        total_size += size
        
        category = categorize_file(item)
        
        if category not in stats:
            stats[category] = {'count': 0, 'size': 0}
        
        stats[category]['count'] += 1
        stats[category]['size'] += size
        
        # Track large files
        if show_large and size > size_threshold_mb * 1024 * 1024:
            large_files.append((item.name, size / (1024 * 1024)))
    
    # Print statistics
    print(f"\nDirectory: {dir_path}")
    print(f"Total size: {total_size / (1024 * 1024):.1f} MB\n")
    
    print("By category:")
    for category in sorted(stats.keys(), key=lambda x: stats[x]['size'], reverse=True):
        count = stats[category]['count']
        size_mb = stats[category]['size'] / (1024 * 1024)
        print(f"  {category:15} {count:4} files | {size_mb:8.1f} MB")
    
    if show_large and large_files:
        print(f"\nLarge files (>{size_threshold_mb}MB):")
        for name, size_mb in sorted(large_files, key=lambda x: x[1], reverse=True):
            print(f"  {name:50} {size_mb:8.1f} MB")


def organize_directory(source_dir, dest_dir, dry_run=False, skip_recent_days=None):
    """Organize files into categorized folders"""
    source = Path(source_dir).expanduser()
    dest = Path(dest_dir).expanduser()
    
    if not source.exists():
        print(f"Error: Source directory {source} does not exist", file=sys.stderr)
        sys.exit(1)
    
    now = datetime.now()
    moved_count = 0
    
    for item in source.iterdir():
        if not item.is_file():
            continue
        
        # Skip recent files if requested
        if skip_recent_days:
            mtime = datetime.fromtimestamp(item.stat().st_mtime)
            age_days = (now - mtime).days
            if age_days < skip_recent_days:
                continue
        
        category = categorize_file(item)
        target_dir = dest / category
        
        if not dry_run:
            target_dir.mkdir(parents=True, exist_ok=True)
            target_path = target_dir / item.name
            
            # Handle duplicates
            counter = 1
            while target_path.exists():
                stem = item.stem
                suffix = item.suffix
                target_path = target_dir / f"{stem}_{counter}{suffix}"
                counter += 1
            
            shutil.move(str(item), str(target_path))
            print(f"Moved: {item.name} → {category}/")
        else:
            print(f"Would move: {item.name} → {category}/")
        
        moved_count += 1
    
    if moved_count == 0:
        print("No files to organize")
    else:
        action = "Would move" if dry_run else "Moved"
        print(f"\n{action} {moved_count} files")


def clean_old_files(directory, days_old, dry_run=False):
    """Move files older than N days to Trash"""
    dir_path = Path(directory).expanduser()
    
    if not dir_path.exists():
        print(f"Error: Directory {dir_path} does not exist", file=sys.stderr)
        sys.exit(1)
    
    now = datetime.now()
    removed_count = 0
    
    for item in dir_path.iterdir():
        if not item.is_file():
            continue
        
        mtime = datetime.fromtimestamp(item.stat().st_mtime)
        age_days = (now - mtime).days
        
        if age_days >= days_old:
            if not dry_run:
                # Move to trash using macOS trash command
                os.system(f'trash "{item}"')
                print(f"Trashed: {item.name} (age: {age_days} days)")
            else:
                print(f"Would trash: {item.name} (age: {age_days} days)")
            
            removed_count += 1
    
    if removed_count == 0:
        print(f"No files older than {days_old} days")
    else:
        action = "Would trash" if dry_run else "Trashed"
        print(f"\n{action} {removed_count} files")


def main():
    parser = argparse.ArgumentParser(description='Workspace cleaner for macOS')
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    # Analyze command
    analyze_parser = subparsers.add_parser('analyze', help='Analyze directory contents')
    analyze_parser.add_argument('directory', help='Directory to analyze')
    analyze_parser.add_argument('--large', action='store_true', help='Show large files')
    analyze_parser.add_argument('--threshold', type=int, default=10, help='Size threshold in MB (default: 10)')
    
    # Organize command
    org_parser = subparsers.add_parser('organize', help='Organize files by type')
    org_parser.add_argument('source', help='Source directory (e.g., ~/Downloads)')
    org_parser.add_argument('dest', help='Destination directory (e.g., ~/Documents/Organized)')
    org_parser.add_argument('--dry-run', action='store_true', help='Show what would be done')
    org_parser.add_argument('--skip-recent', type=int, help='Skip files modified in last N days')
    
    # Clean command
    clean_parser = subparsers.add_parser('clean', help='Move old files to Trash')
    clean_parser.add_argument('directory', help='Directory to clean')
    clean_parser.add_argument('--days', type=int, default=30, help='Move files older than N days (default: 30)')
    clean_parser.add_argument('--dry-run', action='store_true', help='Show what would be done')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    if args.command == 'analyze':
        analyze_directory(args.directory, args.large, args.threshold)
    elif args.command == 'organize':
        organize_directory(args.source, args.dest, args.dry_run, args.skip_recent)
    elif args.command == 'clean':
        clean_old_files(args.directory, args.days, args.dry_run)


if __name__ == '__main__':
    main()
