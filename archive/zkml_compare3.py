#!/usr/bin/env python3
import struct

def read_int32(data, offset):
    return struct.unpack('<I', data[offset:offset+4])[0]

def compare_fields(file1, file2, label):
    with open(file1, 'rb') as f1, open(file2, 'rb') as f2:
        data1 = f1.read()
        data2 = f2.read()
    
    print(f"\n=== {label} ===")
    print("Offset  | X moved | Y moved | Diff  | Description")
    print("--------|---------|---------|-------|-------------")
    
    # ANDREW field offsets
    offsets = {
        0x8C0: "Unknown",
        0x8C4: "Unknown",
        0x8C8: "Value A (Size related?)",
        0x8CC: "Value B (Size 242)",
        0x8D0: "Spacing (1)",
        0x8D4: "X position",
        0x8D8: "Value D (249)",
        0x8DC: "Padding?",
    }
    
    for offset, desc in offsets.items():
        if offset + 4 <= len(data1):
            val1 = read_int32(data1, offset)
            val2 = read_int32(data2, offset)
            diff = val2 - val1
            sign = "+" if diff > 0 else ""
            print(f"0x{offset:04x}  | {val1:7d} | {val2:7d} | {sign}{diff:5d} | {desc}")

compare_fields(
    "/Users/joshua/.openclaw/workspace/root_andrew_moved.zkml",
    "/Users/joshua/.openclaw/workspace/root_andrew_y_moved.zkml",
    "ANDREW field: X moved vs Y moved"
)
