#!/usr/bin/env python3
"""
Generate 80s-style flying name image
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math

# Create image
width, height = 1920, 1080
img = Image.new('RGB', (width, height), color='black')
draw = ImageDraw.Draw(img)

# Gradient background (purple to pink)
for y in range(height):
    r = int(26 + (128 - 26) * (y / height))
    g = int(0 + (0 - 0) * (y / height))
    b = int(51 + (255 - 51) * (y / height))
    draw.rectangle([(0, y), (width, y+1)], fill=(r, g, b))

# Draw perspective grid in lower half
grid_y_start = height // 2
grid_spacing = 60
for i in range(0, width, grid_spacing):
    # Vertical lines
    x1 = i
    y1 = grid_y_start
    x2 = width // 2 + (i - width // 2) * 1.5
    y2 = height
    draw.line([(x1, y1), (x2, y2)], fill=(255, 0, 255), width=2)

for i in range(grid_y_start, height, grid_spacing):
    # Horizontal lines with perspective
    scale = (i - grid_y_start) / (height - grid_y_start)
    left_offset = int(300 * scale)
    right_offset = int(300 * scale)
    draw.line([(left_offset, i), (width - right_offset, i)], fill=(0, 255, 255), width=2)

# Add stars in upper half
import random
random.seed(42)
for _ in range(150):
    x = random.randint(0, width)
    y = random.randint(0, height // 2)
    size = random.randint(1, 3)
    brightness = random.randint(100, 255)
    draw.ellipse([(x, y), (x + size, y + size)], fill=(brightness, brightness, brightness))

# Name text
name = "JOSHUA"
colors = [
    (255, 0, 128),   # Hot pink
    (255, 0, 0),     # Red
    (255, 128, 0),   # Orange
    (255, 255, 0),   # Yellow
    (0, 255, 0),     # Green
    (0, 255, 255),   # Cyan
    (0, 128, 255),   # Blue
]

# Try to load a bold font, fall back to default
try:
    font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Impact.ttf", 180)
except:
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 180)
    except:
        font = ImageFont.load_default()

# Calculate text position
bbox = draw.textbbox((0, 0), name, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]

# Position text slightly offset to show motion
x_pos = width // 3
y_pos = (height - text_height) // 2 - 50

# Draw each letter in different color with glow
for i, letter in enumerate(name):
    color = colors[i % len(colors)]
    
    # Get letter position
    letter_bbox = draw.textbbox((x_pos, y_pos), name[:i+1], font=font)
    if i > 0:
        prev_bbox = draw.textbbox((x_pos, y_pos), name[:i], font=font)
        letter_x = prev_bbox[2] - bbox[0]
    else:
        letter_x = x_pos
    
    # Draw glow layers
    for offset in [8, 6, 4, 2]:
        glow_alpha = int(30 * (8 - offset) / 8)
        glow_color = tuple([min(255, c + 50) for c in color])
        draw.text((letter_x + offset//2, y_pos + offset//2), letter, font=font, fill=glow_color)
    
    # Draw main letter with shadow
    draw.text((letter_x + 4, y_pos + 4), letter, font=font, fill=(0, 0, 0))  # Shadow
    draw.text((letter_x, y_pos), letter, font=font, fill=color)

# Add motion blur effect
img = img.filter(ImageFilter.GaussianBlur(radius=0.5))

# Add scanlines
scanline_img = Image.new('RGBA', (width, height), color=(0, 0, 0, 0))
scanline_draw = ImageDraw.Draw(scanline_img)
for y in range(0, height, 4):
    scanline_draw.rectangle([(0, y), (width, y+2)], fill=(0, 0, 0, 30))
img.paste(scanline_img, (0, 0), scanline_img)

# Save
output_path = '/Users/joshua/.openclaw/workspace/80s-flying-name.png'
img.save(output_path, 'PNG')
print(f"Saved to: {output_path}")
