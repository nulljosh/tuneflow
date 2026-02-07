#!/usr/bin/env python3
"""Deep analysis of ZKML structure with focus on text field positioning"""

import struct
import sys

def analyze_around_offset(data, offset, label, size=64):
    """Show hex and parsed data around a specific offset"""
    start = max(0, offset - size)
    end = min(len(data), offset + size)
    
    print(f"\n=== {label} (around 0x{offset:04x}) ===")
    
    # Show raw hex
    for i in range(start, end, 16):
        hex_part = ' '.join(f'{b:02x}' for b in data[i:i+16])
        ascii_part = ''.join(chr(b) if 32 <= b <= 126 else '.' for b in data[i:i+16])
        print(f"  {i:04x}: {hex_part:<48} {ascii_part}")
    
    # Try to parse as coordinates/dimensions
    if offset >= 8:
        print(f"\n  Preceding bytes as integers:")
        for j in range(max(0, offset-32), offset, 4):
            if j + 4 <= len(data):
                val_le = struct.unpack('<I', data[j:j+4])[0]
                val_be = struct.unpack('>I', data[j:j+4])[0]
                print(f"    0x{j:04x}: {val_le:10d} (LE) / {val_be:10d} (BE) / 0x{val_le:08x}")

def main():
    if len(sys.argv) < 2:
        print("Usage: zkml_deep_analyze.py <file.zkml>")
        sys.exit(1)
    
    with open(sys.argv[1], 'rb') as f:
        data = f.read()
    
    print(f"File size: {len(data)} bytes")
    
    # Find text strings
    text_fields = []
    
    # CINEPRO
    cinepro_offset = data.find(b'CINEPRO\x00')
    if cinepro_offset != -1:
        text_fields.append((cinepro_offset, "CINEPRO"))
    
    # ANDREW WUZ HERE
    andrew_offset = data.find(b'ANDREW WUZ HERE\x00')
    if andrew_offset != -1:
        text_fields.append((andrew_offset, "ANDREW WUZ HERE"))
    
    # Font references
    font_offset = data.find(b'0:/Montserrat')
    if font_offset != -1:
        text_fields.append((font_offset, "Font path (1st)"))
    
    font2_offset = data.find(b'0:/Montserrat', font_offset + 10 if font_offset != -1 else 0)
    if font2_offset != -1:
        text_fields.append((font2_offset, "Font path (2nd)"))
    
    # Analyze around each field
    for offset, label in text_fields:
        analyze_around_offset(data, offset, label)
    
    # Look for patterns between the two text fields
    print("\n\n=== STRUCTURE COMPARISON ===")
    print(f"Field 1 (CINEPRO):       0x{cinepro_offset:04x}")
    print(f"Field 2 (ANDREW):        0x{andrew_offset:04x}")
    print(f"Distance:                {andrew_offset - cinepro_offset} bytes (0x{andrew_offset - cinepro_offset:x})")
    
    # Check if there's a repeating structure
    chunk_size = andrew_offset - cinepro_offset
    print(f"\nChecking for repeated {chunk_size}-byte structure...")

if __name__ == "__main__":
    main()
