#!/usr/bin/env python3
"""
tools/make_icon.py
Generates assets/icon/app_icon.png from assets/images/logo_full.png
by extracting the emblem, clearing background/speech bubble/text,
and placing it centered on a 1024x1024 white canvas.
"""

import os
from collections import deque
from PIL import Image

def make_app_icon():
    input_path = os.path.join("assets", "images", "logo_full.png")
    output_dir = os.path.join("assets", "icon")
    output_path = os.path.join(output_dir, "app_icon.png")

    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Source logo not found at {input_path}")

    # 1. Open assets/images/logo_full.png as RGBA
    im = Image.open(input_path).convert("RGBA")

    # 2. Crop ONLY the emblem box
    # The emblem is roughly inside x: 395-650, y: 100-360; text starts below y 345
    crop_box = (395, 100, 650, 355)
    cropped = im.crop(crop_box)
    cw, ch = cropped.size

    # Remove the speech bubble icon in bottom-right (y >= 344 and x >= 580 in orig image)
    for y in range(ch):
        orig_y = y + crop_box[1]
        for x in range(cw):
            orig_x = x + crop_box[0]
            if orig_y >= 344 and orig_x >= 580:
                cropped.putpixel((x, y), (255, 255, 255, 255))

    # Auto-trim to bounding box of non-white emblem pixels
    non_white = []
    for y in range(ch):
        for x in range(cw):
            r, g, b, a = cropped.getpixel((x, y))
            if r < 242 or g < 242 or b < 242:
                non_white.append((x, y))

    if not non_white:
        raise ValueError("Could not detect emblem pixels in crop region.")

    min_x = min(x for x, y in non_white)
    max_x = max(x for x, y in non_white)
    min_y = min(y for x, y in non_white)
    max_y = max(y for x, y in non_white)

    emblem = cropped.crop((min_x, min_y, max_x + 1, max_y + 1))
    ew, eh = emblem.size

    # Flood-fill outer background pixels to transparent so there are no faint edge seams
    visited = set()
    q = deque()
    for x in range(ew):
        for y in [0, eh - 1]:
            r, g, b, a = emblem.getpixel((x, y))
            if min(r, g, b) >= 230:
                q.append((x, y))
                visited.add((x, y))
    for y in range(eh):
        for x in [0, ew - 1]:
            if (x, y) not in visited:
                r, g, b, a = emblem.getpixel((x, y))
                if min(r, g, b) >= 230:
                    q.append((x, y))
                    visited.add((x, y))

    while q:
        cx, cy = q.popleft()
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < ew and 0 <= ny < eh and (nx, ny) not in visited:
                r, g, b, a = emblem.getpixel((nx, ny))
                if min(r, g, b) >= 238:
                    visited.add((nx, ny))
                    q.append((nx, ny))

    clean_emblem = emblem.copy()
    for (x, y) in visited:
        clean_emblem.putpixel((x, y), (255, 255, 255, 0))

    # 3. Create a square 1024x1024 canvas with WHITE background
    canvas = Image.new("RGBA", (1024, 1024), (255, 255, 255, 255))

    # 4. Resize emblem proportionally to fit inside central 70% of canvas (~15% padding)
    target_max_size = int(1024 * 0.70)
    scale = min(target_max_size / ew, target_max_size / eh)
    new_w = int(round(ew * scale))
    new_h = int(round(eh * scale))

    resized = clean_emblem.resize((new_w, new_h), Image.Resampling.LANCZOS)
    paste_x = (1024 - new_w) // 2
    paste_y = (1024 - new_h) // 2
    canvas.alpha_composite(resized, (paste_x, paste_y))

    # 5. Save to assets/icon/app_icon.png
    os.makedirs(output_dir, exist_ok=True)
    canvas.save(output_path, "PNG")
    print(f"Successfully generated {output_path} (emblem size {new_w}x{new_h} centered)")

if __name__ == "__main__":
    make_app_icon()
