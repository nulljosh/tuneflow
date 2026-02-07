#!/usr/bin/env python3
import struct

def read_int32(data, offset):
    return struct.unpack('<I', data[offset:offset+4])[0]

def compare_fields(file1, file2, label):
    with open(file1, 'rb') as f1, open(file2, 'rb') as f2:
        data1 = f1.read()
        data2 = f2.read()
    
    print(f"\n=== {label} ===")
    print("Offset  | Original | Moved   | Diff  | Description")
    print("--------|----------|---------|-------|-------------")
    
    # CINEPRO field offsets
    offsets = {
        0x148: "Unknown 1",
        0x150: "Value A (was 1266)",
        0x154: "Zero pad",
        0x158: "Value B (was 1266)", 
        0x15C: "Zero pad",
        0x160: "Spacing? (was 1)",
        0x164: "Value C (was 3)",
        0x168: "Value D (-30)",
    }
    
    for offset, desc in offsets.items():
        if offset + 4 <= len(data1):
            val1 = read_int32(data1, offset)
            val2 = read_int32(data2, offset)
            diff = val2 - val1
            sign = "+" if diff > 0 else ""
            print(f"0x{offset:04x}  | {val1:8d} | {val2:8d} | {sign}{diff:5d} | {desc}")

compare_fields(
    "/Users/joshua/Library/Messages/Attachments/a8/08/4E12786C-2E34-43F8-8C81-9DC63EFCE0C6/root.zkml",
    "/Users/joshua/.openclaw/workspace/root_moved.zkml",
    "CINEPRO field comparison (moved right)"
)
