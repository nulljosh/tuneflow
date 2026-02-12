# ZKML File Format Documentation

## Overview

`.zkml` files are proprietary label files used by **CINEPRO** label printers. This document describes the reverse-engineered binary format.

## File Structure

```
┌─────────────────────────────────────────┐
│ Header (0x000-0x140)                    │  Magic number, metadata, dimensions
├─────────────────────────────────────────┤
│ Printer Info (0x17C-0x27C)              │  "CINEPRO"
├─────────────────────────────────────────┤
│ Font Reference 1 (0x280-0x380)          │  Path to .otf font file
├─────────────────────────────────────────┤
│ Configuration (0x380-0x8EC)             │  Layout settings, fixed values
├─────────────────────────────────────────┤
│ Label Text (0x8EC-0x9EC)                │  The actual text to print
├─────────────────────────────────────────┤
│ Font Reference 2 (0x9F0-0xAF0)          │  Repeated font path
├─────────────────────────────────────────┤
│ Padding (0xAF0-end)                     │  Zeros to pad file to ~95KB
└─────────────────────────────────────────┘
```

## Header Format (First 256 bytes)

| Offset | Size | Type    | Description                           |
|--------|------|---------|---------------------------------------|
| 0x00   | 2    | uint16  | Magic number: `0x2022`                |
| 0x08   | 4    | uint32  | Unknown (2026 in samples)             |
| 0x10   | 4    | uint32  | Year                                  |
| 0x14   | 4    | uint32  | Version                               |
| 0x18   | 4    | uint32  | Parameter 1 (7 in samples)            |
| 0x1C   | 4    | uint32  | Parameter 2 (9 in samples)            |
| 0x20   | 4    | uint32  | Parameter 3 (17 in samples)           |
| 0x24   | 4    | uint32  | Parameter 4 (39 in samples)           |
| 0x28   | 16   | -       | Repeated values from 0x08-0x17        |
| 0x40   | 256  | string  | Original filename (null-terminated)   |

## String Format

All strings are:
- **Null-terminated** (C-style)
- **Fixed-size fields** padded with zeros
- **UTF-8 encoded** (ASCII compatible)

## Key Offsets

| Offset | Field                  | Example Value                |
|--------|------------------------|------------------------------|
| 0x040  | Original filename      | `New_0001.zkml`              |
| 0x17C  | Printer model          | `CINEPRO`                    |
| 0x280  | Font path #1           | `0:/Montserrat-Regular.otf`  |
| 0x8EC  | Label text content     | `ANDREW WUZ HERE`            |
| 0x9F0  | Font path #2 (repeat)  | `0:/Montserrat-Regular.otf`  |

## Configuration Values

Several fixed values appear in working files:

```
0x148: 02 00 00 00
0x154: F2 04 00 00
0x15C: F2 04 00 00
0x164: 01 00 00 00
0x168: 03 00 00 00
0x16C: E2 FF
```

These may control:
- Label dimensions (width/height)
- Print resolution
- Text alignment
- Font size

## Creating Compatible Labels

### Using the Python Tool

```bash
# Decode existing label
python3 zkml_tool.py decode input.zkml

# Create new label
python3 zkml_tool.py create "My Label Text" output.zkml

# Edit existing label
python3 zkml_tool.py edit input.zkml "Updated Text"
```

### Manual Creation

1. **Start with 95,552 bytes** of zeros
2. **Write header:**
   - Magic: `0x2022` at offset 0x00
   - Year, version, parameters as needed
3. **Write strings:**
   - Filename at 0x40
   - Printer name at 0x17C
   - Font path at 0x280
   - Label text at 0x8EC
   - Font path again at 0x9F0
4. **Copy configuration values** from a working file (0x148-0x16C)

## Limitations & Unknowns

### Known
- Text content location and format
- Basic file structure
- String encoding

### Unknown
- Exact meaning of header parameters
- Support for multiple text fields
- Image/barcode embedding format
- Precise layout/positioning control
- Color information (if supported)
- Advanced formatting (bold, italic, etc.)

## Font References

The format expects fonts at paths like:
```
0:/Montserrat-Regular.otf
```

This suggests:
- Drive/volume identifier (`0:`)
- Absolute path on printer's filesystem
- Fonts may need to be installed on the printer

## File Size

All observed `.zkml` files are exactly **95,552 bytes** (93.3 KB):
- Actual content: ~4-6 KB
- Padding: ~90 KB of zeros

The padding may be:
- Fixed buffer size in printer firmware
- Memory alignment requirement
- Artifact of the creation tool

## Tools Provided

### `zkml_analyzer.py`
Hex dump analyzer - shows raw file structure

### `zkml_tool.py`
Full encoder/decoder - create and edit labels

## Testing

To verify compatibility:
1. Decode an existing working label
2. Create a new label with the tool
3. Test print on the actual printer
4. Adjust parameters if needed

## License & Disclaimer

This documentation is based on reverse engineering for interoperability purposes. 
- Use only with printers you own
- No warranty on compatibility
- Format may vary between printer models/firmware versions

---

**Status:** Working decoder, functional encoder (untested on hardware)  
**Last Updated:** 2026-02-07  
**Printer Model:** CINEPRO (exact model unknown)
