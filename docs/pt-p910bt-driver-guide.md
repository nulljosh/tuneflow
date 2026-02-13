# Brother PT-P910BT macOS Driver Modification Guide

## Overview
The PT-P910BT is a Bluetooth label maker that lacks native macOS printer drivers. This guide details how to adapt existing Brother label maker drivers for compatibility.

## Similar Brother Models (with macOS drivers)
- **PT-P900W** - Desktop label maker, similar P-touch series
- **PT-P950NW** - Network-capable, same generation
- **PT-P710BT** - Bluetooth predecessor
- **PT-D610BT** - Older Bluetooth model

## Phase 1: Information Gathering (Day 1 - with device)

### 1.1 Get Device Identifiers
```bash
# Pair device via Bluetooth settings first
# Then extract device info:

system_profiler SPBluetoothDataType | grep -A 20 "PT-P910BT"
# Look for:
# - Bluetooth Address
# - Device Class
# - Vendor ID / Product ID
```

### 1.2 Check USB Mode (if applicable)
```bash
system_profiler SPUSBDataType | grep -A 10 "Brother"
# Record:
# - Vendor ID (usually 0x04f9 for Brother)
# - Product ID (unique to PT-P910BT)
```

### 1.3 Test P-touch Editor Compatibility
- Download P-touch Editor from Brother's site
- Check if PT-P910BT is recognized
- If yes, driver protocol is already supported
- Note: Software paths used

## Phase 2: Driver Extraction

### 2.1 Download Similar Drivers
Priority order:
1. PT-P900W (closest match)
2. PT-P950NW (backup)
3. PT-P710BT (Bluetooth reference)

```bash
# After downloading .pkg/.dmg:
# Extract without installing

pkgutil --expand Brother_PT-P900W.pkg ~/Desktop/p900w_extracted
cd ~/Desktop/p900w_extracted

# Find PPD files (PostScript Printer Description)
find . -name "*.ppd" -or -name "*.gz"

# Find filter/backend binaries
find . -name "*brother*" -or -name "*filter*"
```

### 2.2 Locate Key Files
Typical Brother driver structure:
```
/Library/Printers/Brother/
├── Filters/
│   └── brother_lpdwrapper_*  (communication layer)
├── PDEs/                      (printer dialog extensions)
└── cupswrapper/              (CUPS backend)

/Library/Printers/PPDs/Contents/Resources/
└── Brother_PT_P900W.ppd.gz   (printer definition)
```

## Phase 3: PPD Modification

### 3.1 Decompress and Edit PPD
```bash
cd /Library/Printers/PPDs/Contents/Resources/
cp Brother_PT_P900W.ppd.gz ~/Desktop/
gunzip ~/Desktop/Brother_PT_P900W.ppd.gz

# Edit with text editor
nano ~/Desktop/Brother_PT_P900W.ppd
```

### 3.2 Key PPD Changes
```ppd
*ModelName: "Brother PT-P910BT"
*ShortNickName: "Brother PT-P910BT"
*NickName: "Brother PT-P910BT"
*Product: "(PT-P910BT)"

*% Update device IDs (from Phase 1)
*1284DeviceID: "MFG:Brother;MDL:PT-P910BT;CMD:PT-CBP;"

*% Bluetooth backend (if using BT)
*cupsBluetoothUUID: "00001101-0000-1000-8000-00805f9b34fb"

*% Paper sizes (verify with device specs)
*PageSize 24mm/24mm: ""
*PageSize 36mm/36mm: ""
*% Add PT-P910BT specific tape widths
```

### 3.3 Save and Compress
```bash
gzip ~/Desktop/Brother_PT_P900W.ppd
mv ~/Desktop/Brother_PT_P900W.ppd.gz ~/Desktop/Brother_PT_P910BT.ppd.gz
```

## Phase 4: Driver Installation

### 4.1 Install Modified PPD
```bash
sudo cp ~/Desktop/Brother_PT_P910BT.ppd.gz \
  /Library/Printers/PPDs/Contents/Resources/

sudo chmod 644 /Library/Printers/PPDs/Contents/Resources/Brother_PT_P910BT.ppd.gz
```

### 4.2 Copy Supporting Files (if not using P900W files)
```bash
# If P-touch Editor works, use its backend:
ls -la /Library/Printers/Brother/

# Otherwise copy from P900W driver extraction
sudo cp -R ~/Desktop/p900w_extracted/Printers/Brother/* \
  /Library/Printers/Brother/
```

### 4.3 Add Printer via CUPS
```bash
# Restart CUPS
sudo launchctl stop org.cups.cupsd
sudo launchctl start org.cups.cupsd

# Add printer
# Via GUI: System Settings > Printers & Scanners > Add Printer
# Select PT-P910BT from Bluetooth devices
# Choose "Brother PT-P910BT" from driver list

# Or via command line:
lpadmin -p PT-P910BT \
  -E \
  -v bluetooth://[BLUETOOTH_ADDRESS] \
  -P /Library/Printers/PPDs/Contents/Resources/Brother_PT_P910BT.ppd.gz \
  -D "Brother PT-P910BT" \
  -L "Bluetooth"
```

## Phase 5: Testing & Debugging

### 5.1 Test Print
```bash
# Send test job
echo "Test Label" | lp -d PT-P910BT

# Check CUPS logs
tail -f /var/log/cups/error_log
```

### 5.2 Common Issues

**Issue: Device not found**
- Check Bluetooth pairing: `blueutil --paired`
- Verify device is on and in range
- Try USB cable if available

**Issue: Print job stalls**
- Check filter chain: `lpstat -t`
- Verify backend communication: `sudo /usr/libexec/cups/backend/bluetooth`
- Test with P-touch Editor to confirm device works

**Issue: Wrong paper size**
- Edit PPD, adjust `*PageSize` definitions
- Match tape widths supported by PT-P910BT (6mm, 9mm, 12mm, 18mm, 24mm, 36mm)

**Issue: Garbled output**
- Command protocol mismatch
- May need to sniff USB/BT traffic with Wireshark
- Compare with working P-touch Editor commands

### 5.3 Traffic Sniffing (advanced)
```bash
# Install Wireshark
brew install wireshark

# Capture Bluetooth traffic while P-touch Editor prints
# Analyze command structure
# Update filter binary if needed (advanced C programming)
```

## Phase 6: Packaging (optional)

### 6.1 Create Installer Package
```bash
# Build proper .pkg for distribution
pkgbuild --root /tmp/driver_files \
  --identifier com.brother.pkg.ptp910bt \
  --version 1.0 \
  --install-location / \
  Brother_PT-P910BT_Driver.pkg
```

## Quick Reference: Tomorrow's Checklist

**With device on hand:**
1. [ ] Pair via Bluetooth
2. [ ] Extract device IDs: `system_profiler SPBluetoothDataType`
3. [ ] Download PT-P900W driver
4. [ ] Extract PPD: `pkgutil --expand`
5. [ ] Modify PPD with PT-P910BT IDs
6. [ ] Install modified PPD to `/Library/Printers/PPDs/`
7. [ ] Add printer via System Settings
8. [ ] Test print
9. [ ] Debug with CUPS logs if needed

## Resources
- CUPS PPD documentation: `/usr/share/cups/ppd/`
- Brother P-touch Editor: Check if it auto-supports PT-P910BT
- CUPS backends: `/usr/libexec/cups/backend/`
- Brother support: https://support.brother.com

## Notes
- PT-P910BT likely uses same ESC/P command set as PT-P900W
- Bluetooth SPP profile (Serial Port Profile) standard
- Brother's lpdwrapper handles most protocol conversion
- May "just work" if P-touch Editor already supports it

## Fallback: P-touch Editor Workflow
If driver modification fails:
- Use P-touch Editor for label design
- Print via app's Bluetooth connection
- Not ideal but functional

---
**Estimated time:** 30-60 minutes with device present
**Difficulty:** Intermediate (PPD editing) to Advanced (if protocol sniffing needed)
