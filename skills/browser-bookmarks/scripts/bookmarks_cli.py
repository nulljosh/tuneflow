#!/usr/bin/env python3
"""
Browser bookmarks manager for Safari and Chrome on macOS
"""
import os
import sys
import json
import argparse
from pathlib import Path
from datetime import datetime
import plistlib
import shutil


def get_safari_bookmarks():
    """Read Safari bookmarks from plist"""
    bookmarks_path = Path.home() / "Library/Safari/Bookmarks.plist"
    
    if not bookmarks_path.exists():
        print("Error: Safari bookmarks file not found", file=sys.stderr)
        sys.exit(1)
    
    with open(bookmarks_path, 'rb') as f:
        plist = plistlib.load(f)
    
    bookmarks = []
    
    def extract_bookmarks(item, folder=""):
        """Recursively extract bookmarks from plist structure"""
        if isinstance(item, dict):
            if item.get('WebBookmarkType') == 'WebBookmarkTypeLeaf':
                # This is a bookmark
                url = item.get('URLString', '')
                title = item.get('URIDictionary', {}).get('title', 'Untitled')
                bookmarks.append({
                    'title': title,
                    'url': url,
                    'folder': folder
                })
            elif 'Children' in item:
                # This is a folder
                folder_name = item.get('Title', '')
                new_folder = f"{folder}/{folder_name}" if folder else folder_name
                for child in item['Children']:
                    extract_bookmarks(child, new_folder)
        elif isinstance(item, list):
            for child in item:
                extract_bookmarks(child, folder)
    
    if 'Children' in plist:
        for child in plist['Children']:
            extract_bookmarks(child)
    
    return bookmarks


def get_chrome_bookmarks():
    """Read Chrome bookmarks from JSON"""
    bookmarks_path = Path.home() / "Library/Application Support/Google/Chrome/Default/Bookmarks"
    
    if not bookmarks_path.exists():
        print("Error: Chrome bookmarks file not found", file=sys.stderr)
        sys.exit(1)
    
    with open(bookmarks_path, 'r') as f:
        data = json.load(f)
    
    bookmarks = []
    
    def extract_bookmarks(item, folder=""):
        """Recursively extract bookmarks from Chrome JSON"""
        if item.get('type') == 'url':
            bookmarks.append({
                'title': item.get('name', 'Untitled'),
                'url': item.get('url', ''),
                'folder': folder,
                'date_added': item.get('date_added')
            })
        elif item.get('type') == 'folder':
            folder_name = item.get('name', '')
            new_folder = f"{folder}/{folder_name}" if folder else folder_name
            for child in item.get('children', []):
                extract_bookmarks(child, new_folder)
    
    # Extract from bookmark bar and other folders
    roots = data.get('roots', {})
    for root_name, root_data in roots.items():
        if root_name in ['bookmark_bar', 'other']:
            extract_bookmarks(root_data)
    
    return bookmarks


def list_bookmarks(browser='safari', search=None, folder=None):
    """List bookmarks with optional filtering"""
    if browser == 'safari':
        bookmarks = get_safari_bookmarks()
    elif browser == 'chrome':
        bookmarks = get_chrome_bookmarks()
    else:
        print(f"Error: Unknown browser '{browser}'", file=sys.stderr)
        sys.exit(1)
    
    # Apply filters
    if search:
        search_lower = search.lower()
        bookmarks = [b for b in bookmarks 
                    if search_lower in b['title'].lower() or search_lower in b['url'].lower()]
    
    if folder:
        bookmarks = [b for b in bookmarks if folder.lower() in b['folder'].lower()]
    
    # Print results
    if not bookmarks:
        print("No bookmarks found")
        return
    
    for bookmark in bookmarks:
        folder_display = f" [{bookmark['folder']}]" if bookmark['folder'] else ""
        print(f"{bookmark['title']}{folder_display}")
        print(f"  {bookmark['url']}")


def export_bookmarks(browser='safari', output_file=None):
    """Export bookmarks to JSON or HTML"""
    if browser == 'safari':
        bookmarks = get_safari_bookmarks()
    elif browser == 'chrome':
        bookmarks = get_chrome_bookmarks()
    else:
        print(f"Error: Unknown browser '{browser}'", file=sys.stderr)
        sys.exit(1)
    
    if not output_file:
        output_file = f"{browser}_bookmarks_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    
    output_path = Path(output_file)
    
    if output_path.suffix == '.json':
        # Export as JSON
        with open(output_path, 'w') as f:
            json.dump(bookmarks, f, indent=2)
        print(f"Exported {len(bookmarks)} bookmarks to {output_path}")
    elif output_path.suffix == '.html':
        # Export as HTML bookmarks file
        html = ['<!DOCTYPE NETSCAPE-Bookmark-file-1>',
                '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">',
                '<TITLE>Bookmarks</TITLE>',
                '<H1>Bookmarks</H1>',
                '<DL><p>']
        
        current_folder = None
        for bookmark in bookmarks:
            # Handle folder changes
            if bookmark['folder'] != current_folder:
                if current_folder is not None:
                    html.append('    </DL><p>')
                if bookmark['folder']:
                    html.append(f'    <DT><H3>{bookmark["folder"]}</H3>')
                    html.append('    <DL><p>')
                current_folder = bookmark['folder']
            
            html.append(f'        <DT><A HREF="{bookmark["url"]}">{bookmark["title"]}</A>')
        
        if current_folder:
            html.append('    </DL><p>')
        html.append('</DL><p>')
        
        with open(output_path, 'w') as f:
            f.write('\n'.join(html))
        print(f"Exported {len(bookmarks)} bookmarks to {output_path}")
    else:
        print("Error: Output file must be .json or .html", file=sys.stderr)
        sys.exit(1)


def search_duplicates(browser='safari'):
    """Find duplicate bookmarks (same URL)"""
    if browser == 'safari':
        bookmarks = get_safari_bookmarks()
    elif browser == 'chrome':
        bookmarks = get_chrome_bookmarks()
    else:
        print(f"Error: Unknown browser '{browser}'", file=sys.stderr)
        sys.exit(1)
    
    # Group by URL
    url_map = {}
    for bookmark in bookmarks:
        url = bookmark['url']
        if url not in url_map:
            url_map[url] = []
        url_map[url].append(bookmark)
    
    # Find duplicates
    duplicates = {url: items for url, items in url_map.items() if len(items) > 1}
    
    if not duplicates:
        print("No duplicate bookmarks found")
        return
    
    print(f"Found {len(duplicates)} duplicate URLs:\n")
    for url, items in duplicates.items():
        print(f"{url}")
        for item in items:
            folder_display = f" [{item['folder']}]" if item['folder'] else ""
            print(f"  - {item['title']}{folder_display}")
        print()


def main():
    parser = argparse.ArgumentParser(description='Browser bookmarks manager for macOS')
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    # List command
    list_parser = subparsers.add_parser('list', help='List bookmarks')
    list_parser.add_argument('--browser', choices=['safari', 'chrome'], default='safari', help='Browser to read from')
    list_parser.add_argument('--search', help='Search bookmarks by title or URL')
    list_parser.add_argument('--folder', help='Filter by folder name')
    
    # Export command
    export_parser = subparsers.add_parser('export', help='Export bookmarks')
    export_parser.add_argument('--browser', choices=['safari', 'chrome'], default='safari', help='Browser to read from')
    export_parser.add_argument('--output', help='Output file (.json or .html)')
    
    # Duplicates command
    dup_parser = subparsers.add_parser('duplicates', help='Find duplicate bookmarks')
    dup_parser.add_argument('--browser', choices=['safari', 'chrome'], default='safari', help='Browser to read from')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    if args.command == 'list':
        list_bookmarks(args.browser, args.search, args.folder)
    elif args.command == 'export':
        export_bookmarks(args.browser, args.output)
    elif args.command == 'duplicates':
        search_duplicates(args.browser)


if __name__ == '__main__':
    main()
