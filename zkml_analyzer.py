#!/usr/bin/env python3
"""
ZKML File Format Analyzer
Analyzes proprietary .zkml label printer files
"""

import struct
import sys

def parse_zkml(filename):
    with open(filename, 'rb') as f:
        data = f.read()
    
    print(f"File size: {len(data)} bytes\n")
    
    # Parse header
    print("=== HEADER ANALYSIS ===")
    print(f"Bytes 0x00-0x01: {data[0:2].hex()} = {struct.unpack('<H', data[0:2])[0]}")
    print(f"Bytes 0x08-0x0B: {struct.unpack('<I', data[0x08:0x0C])[0]} (possibly width?)")
    print(f"Bytes 0x0C-0x0F: {struct.unpack('<I', data[0x0C:0x10])[0]}")
    print(f"Bytes 0x10-0x13: {struct.unpack('<I', data[0x10:0x14])[0]}")
    print(f"Bytes 0x14-0x17: {struct.unpack('<I', data[0x14:0x18])[0]}")
    print(f"Bytes 0x18-0x1B: {struct.unpack('<I', data[0x18:0x1C])[0]}")
    print(f"Bytes 0x1C-0x1F: {struct.unpack('<I', data[0x1C:0x20])[0]}")
    
    # Find strings
    print("\n=== STRING DATA ===")
    
    # Original filename at 0x40
    filename_start = 0x40
    filename_end = data.find(b'\x00', filename_start)
    original_name = data[filename_start:filename_end].decode('utf-8', errors='ignore')
    print(f"Original filename (0x{filename_start:04x}): {original_name}")
    
    # Find all null-terminated strings
    print("\n=== ALL STRINGS IN FILE ===")
    strings = []
    i = 0
    current_string = bytearray()
    
    for i in range(len(data)):
        byte = data[i]
        if 32 <= byte <= 126:  # Printable ASCII
            current_string.append(byte)
        elif byte == 0 and len(current_string) > 3:
            s = current_string.decode('utf-8', errors='ignore')
            strings.append((i - len(current_string), s))
            current_string = bytearray()
        else:
            current_string = bytearray()
    
    for offset, s in strings:
        print(f"  0x{offset:04x}: {s}")
    
    # Check for common label elements
    print("\n=== POTENTIAL DATA SECTIONS ===")
    
    # Look for repeating patterns or structured data
    for offset in [0x150, 0x200, 0x300, 0x400, 0x500]:
        if offset < len(data):
            chunk = data[offset:offset+16]
            print(f"  0x{offset:04x}: {chunk.hex()}")
    
    # Find where actual content ends (last non-zero byte)
    last_nonzero = len(data) - 1
    while last_nonzero > 0 and data[last_nonzero] == 0:
        last_nonzero -= 1
    
    print(f"\nLast non-zero byte at: 0x{last_nonzero:04x} ({last_nonzero})")
    print(f"Trailing zeros: {len(data) - last_nonzero - 1} bytes")
    
    return data, strings

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: zkml_analyzer.py <file.zkml>")
        sys.exit(1)
    
    parse_zkml(sys.argv[1])
