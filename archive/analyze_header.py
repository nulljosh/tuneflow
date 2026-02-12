#!/usr/bin/env python3
import struct

with open("/Users/joshua/Library/Messages/Attachments/a8/08/4E12786C-2E34-43F8-8C81-9DC63EFCE0C6/root.zkml", 'rb') as f:
    data = f.read(256)

print("=== Header Analysis ===\n")
print("Offset  | Value (LE) | Possible meaning")
print("--------|------------|------------------")

for offset in range(0, 128, 4):
    val = struct.unpack('<I', data[offset:offset+4])[0]
    if val > 0 and val < 100000:  # Filter for reasonable values
        # Check if it could be related to 200mm canvas
        if val > 500 and val < 3000:
            ratio = val / 200 if 200 != 0 else 0
            print(f"0x{offset:04x}  | {val:10d} | Could be {val}px or {val/ratio:.1f}mm @ {ratio:.1f}x scale")
        else:
            print(f"0x{offset:04x}  | {val:10d} |")

print("\n=== Looking for 200mm-related values ===")
print("If canvas is 200mm and scaling is ~5x (based on 248→1266):")
print(f"  Expected value: {200 * 5} to {200 * 6}")
