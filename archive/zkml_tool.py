#!/usr/bin/env python3
"""
ZKML Label File Tool
Create and modify .zkml files for CINEPRO label printers

Based on reverse engineering of the format:
- Binary format with fixed-size header
- Contains metadata, font references, and label text
- Heavily padded with zeros to ~95KB
"""

import struct
import sys
from pathlib import Path

class ZKMLFile:
    MAGIC = b'\x22\x20'  # Raw bytes, not an integer
    DEFAULT_SIZE = 95552  # Padded file size
    
    def __init__(self):
        self.filename = "New_0001.zkml"
        self.printer = "CINEPRO"
        self.font = "0:/Montserrat-Regular.otf"
        self.text = ""
        self.year = 2026
        self.version = 2
        self.param1 = 7
        self.param2 = 9
        self.param3 = 17
        self.param4 = 39
        
    def from_file(self, filepath):
        """Load an existing .zkml file"""
        with open(filepath, 'rb') as f:
            data = f.read()
        
        # Parse header
        magic = data[0:2]
        if magic != self.MAGIC:
            print(f"Warning: Unknown magic bytes {magic.hex()}")
        
        self.year = struct.unpack('<I', data[0x10:0x14])[0]
        self.version = struct.unpack('<I', data[0x14:0x18])[0]
        self.param1 = struct.unpack('<I', data[0x18:0x1C])[0]
        self.param2 = struct.unpack('<I', data[0x1C:0x20])[0]
        
        # Extract strings
        self.filename = self._extract_string(data, 0x40)
        self.printer = self._extract_string(data, 0x17C)
        
        # Find font references (there are typically 2)
        font_offset = data.find(b'0:/', 0x280)
        if font_offset != -1:
            self.font = self._extract_string(data, font_offset)
        
        # Find text content (appears after first font reference)
        text_search_start = 0x800
        for i in range(text_search_start, len(data) - 100):
            # Look for printable text sequences
            if data[i] >= 32 and data[i] <= 126:
                potential_text = self._extract_string(data, i)
                if len(potential_text) > 3 and potential_text not in [self.filename, self.printer, self.font]:
                    self.text = potential_text
                    break
        
        return self
    
    def _extract_string(self, data, offset):
        """Extract null-terminated string"""
        end = data.find(b'\x00', offset)
        if end == -1:
            return ""
        return data[offset:end].decode('utf-8', errors='ignore')
    
    def _write_string(self, s, max_len=256):
        """Convert string to null-terminated bytes with padding"""
        b = s.encode('utf-8')
        if len(b) > max_len - 1:
            b = b[:max_len-1]
        return b + b'\x00' + (b'\x00' * (max_len - len(b) - 1))
    
    def to_bytes(self):
        """Generate .zkml file contents"""
        # Start with a buffer of zeros
        data = bytearray(self.DEFAULT_SIZE)
        
        # Write header (magic bytes)
        data[0:2] = self.MAGIC
        struct.pack_into('<I', data, 0x08, 2026)  # Not sure what this is
        struct.pack_into('<I', data, 0x10, self.year)
        struct.pack_into('<I', data, 0x14, self.version)
        struct.pack_into('<I', data, 0x18, self.param1)
        struct.pack_into('<I', data, 0x1C, self.param2)
        struct.pack_into('<I', data, 0x20, self.param3)
        struct.pack_into('<I', data, 0x24, self.param4)
        
        # Repeat some params
        struct.pack_into('<I', data, 0x28, 2026)
        struct.pack_into('<I', data, 0x2C, self.version)
        struct.pack_into('<I', data, 0x30, self.param1)
        struct.pack_into('<I', data, 0x34, self.param2)
        struct.pack_into('<I', data, 0x38, self.param3)
        struct.pack_into('<I', data, 0x3C, self.param4 + 1)
        
        # Write strings
        data[0x40:0x140] = self._write_string(self.filename, 256)
        
        # Write some fixed values observed in original
        struct.pack_into('<I', data, 0x148, 2)
        struct.pack_into('<I', data, 0x154, 0x04F2)
        struct.pack_into('<I', data, 0x15C, 0x04F2)
        struct.pack_into('<I', data, 0x164, 1)
        struct.pack_into('<I', data, 0x168, 3)
        struct.pack_into('<H', data, 0x16C, 0xFFE2)
        
        # Printer name
        data[0x17C:0x27C] = self._write_string(self.printer, 256)
        
        # Font path
        data[0x280:0x380] = self._write_string(self.font, 256)
        
        # More fixed values
        struct.pack_into('<I', data, 0x2B8, 0xF8)
        struct.pack_into('<I', data, 0x2BC, 0xF8)
        struct.pack_into('<I', data, 0x2C4, 1)
        struct.pack_into('<I', data, 0x2CC, 1)
        
        # Label text content (offset varies, using 0x8EC from sample)
        if self.text:
            data[0x8EC:0x9EC] = self._write_string(self.text, 256)
            
            # Font reference appears again after text
            data[0x9F0:0xAF0] = self._write_string(self.font, 256)
        
        return bytes(data)
    
    def save(self, filepath):
        """Save to .zkml file"""
        data = self.to_bytes()
        with open(filepath, 'wb') as f:
            f.write(data)
        print(f"Saved: {filepath} ({len(data)} bytes)")

def main():
    if len(sys.argv) < 2:
        print("ZKML Label File Tool")
        print("\nUsage:")
        print("  zkml_tool.py decode <file.zkml>          - Show contents")
        print("  zkml_tool.py create <text> <output.zkml> - Create new label")
        print("  zkml_tool.py edit <file.zkml> <new_text> - Edit existing label")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "decode":
        if len(sys.argv) < 3:
            print("Usage: zkml_tool.py decode <file.zkml>")
            sys.exit(1)
        
        zkml = ZKMLFile().from_file(sys.argv[2])
        print(f"\n=== ZKML File Contents ===")
        print(f"Filename: {zkml.filename}")
        print(f"Printer:  {zkml.printer}")
        print(f"Font:     {zkml.font}")
        print(f"Year:     {zkml.year}")
        print(f"Version:  {zkml.version}")
        print(f"\nLabel Text:")
        print(f"  \"{zkml.text}\"")
    
    elif command == "create":
        if len(sys.argv) < 4:
            print("Usage: zkml_tool.py create <text> <output.zkml>")
            sys.exit(1)
        
        zkml = ZKMLFile()
        zkml.text = sys.argv[2]
        zkml.save(sys.argv[3])
        print(f"\nCreated label with text: \"{zkml.text}\"")
    
    elif command == "edit":
        if len(sys.argv) < 4:
            print("Usage: zkml_tool.py edit <file.zkml> <new_text>")
            sys.exit(1)
        
        zkml = ZKMLFile().from_file(sys.argv[2])
        zkml.text = sys.argv[3]
        zkml.save(sys.argv[2])
        print(f"\nUpdated label text to: \"{zkml.text}\"")
    
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()
