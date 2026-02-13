#!/usr/bin/env python3
"""
Auto-converting image wrapper for OpenClaw
Handles HEIC conversion transparently
"""

import sys
import os
import subprocess
import tempfile
import json
from pathlib import Path

def convert_heic_to_jpeg(heic_path):
    """Convert HEIC to JPEG using sips"""
    with tempfile.NamedTemporaryFile(suffix='.jpg', delete=False) as tmp:
        temp_path = tmp.name
    
    try:
        # Use sips to convert
        result = subprocess.run([
            'sips', '-s', 'format', 'jpeg', 
            heic_path, '--out', temp_path
        ], capture_output=True, text=True)
        
        if result.returncode == 0 and os.path.exists(temp_path):
            return temp_path
        else:
            return None
    except Exception:
        return None

def process_image_request(image_path, prompt=None):
    """Process image with auto-HEIC conversion"""
    
    # Check if file exists
    if not os.path.exists(image_path):
        return {"error": f"File not found: {image_path}"}
    
    # Check if it's a HEIC file
    ext = Path(image_path).suffix.lower()
    analysis_path = image_path
    temp_file = None
    
    if ext in ['.heic', '.heif']:
        print(f"HEIC detected, auto-converting...", file=sys.stderr)
        converted_path = convert_heic_to_jpeg(image_path)
        if converted_path:
            analysis_path = converted_path
            temp_file = converted_path
            print(f"Converted to JPEG", file=sys.stderr)
        else:
            return {"error": "HEIC conversion failed"}
    
    # Now we can analyze the image (JPEG/PNG/etc)
    result = {
        "original_path": image_path,
        "analyzed_path": analysis_path,
        "format": Path(analysis_path).suffix.lower()[1:],
        "prompt": prompt or "What's in this image?"
    }
    
    # Clean up temp file if created
    if temp_file and os.path.exists(temp_file):
        # Keep it for now, OpenClaw will use it
        result["temp_file"] = temp_file
    
    return result

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: image-wrapper.py <image_path> [prompt]"}))
        sys.exit(1)
    
    image_path = sys.argv[1]
    prompt = sys.argv[2] if len(sys.argv) > 2 else None
    
    result = process_image_request(image_path, prompt)
    print(json.dumps(result, indent=2))