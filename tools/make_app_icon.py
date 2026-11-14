#!/usr/bin/env python3
"""Renders Omramo's app icon from its SVG source.

    python3 tools/make_app_icon.py

Reads  docs/brand/app-icon.svg
Writes App/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png  (1024 x 1024, RGB)
       docs/brand/app-icon-1024.png                                        (the same picture)
       docs/brand/app-icon-preview.png                                     (masked, at small sizes)

Needs Google Chrome (headless) and Pillow. The App Store icon must have no alpha channel, so
the screenshot is flattened to RGB. The preview is only for looking at; the app does not use it.
"""

import os
import shutil
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
SVG = os.path.join(ROOT, "docs", "brand", "app-icon.svg")
ICON = os.path.join(ROOT, "App", "Resources", "Assets.xcassets", "AppIcon.appiconset", "AppIcon-1024.png")
COPY = os.path.join(ROOT, "docs", "brand", "app-icon-1024.png")
PREVIEW = os.path.join(ROOT, "docs", "brand", "app-icon-preview.png")
SIDE = 1024


def chrome():
    for name in ("google-chrome", "chromium", "chromium-browser", "chrome"):
        path = shutil.which(name)
        if path:
            return path
    sys.exit("Google Chrome (or Chromium) is needed to render the SVG")


def render(target):
    with tempfile.TemporaryDirectory() as folder:
        page = os.path.join(folder, "icon.html")
        with open(SVG, encoding="utf-8") as handle:
            svg = handle.read()
        svg = svg[svg.index("<svg"):]
        with open(page, "w", encoding="utf-8") as handle:
            handle.write("<!doctype html><html><body style='margin:0;background:#130F36'>" + svg + "</body></html>")
        shot = os.path.join(folder, "shot.png")
        subprocess.run(
            [
                chrome(), "--headless=new", "--no-sandbox", "--disable-gpu", "--hide-scrollbars",
                "--force-device-scale-factor=1", "--window-size=%d,%d" % (SIDE, SIDE),
                "--screenshot=" + shot, "file://" + page,
            ],
            check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        image = Image.open(shot).convert("RGB")
    if image.size != (SIDE, SIDE):
        image = image.crop((0, 0, SIDE, SIDE))
    os.makedirs(os.path.dirname(target), exist_ok=True)
    image.save(target, "PNG", optimize=True)
    return image


def preview(image):
    """The icon as iOS would mask it (an approximation of the rounded shape), at five sizes."""
    sizes = (360, 180, 120, 80, 58)
    gap = 36
    width = sum(sizes) + gap * (len(sizes) + 1)
    sheet = Image.new("RGB", (width, sizes[0] + gap * 2), (244, 242, 255))
    x = gap
    for side in sizes:
        small = image.resize((side, side), Image.LANCZOS)
        mask = Image.new("L", (side * 4, side * 4), 0)
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, side * 4 - 1, side * 4 - 1), radius=int(side * 4 * 0.2237), fill=255)
        mask = mask.resize((side, side), Image.LANCZOS)
        sheet.paste(small, (x, gap + (sizes[0] - side) // 2), mask)
        x += side + gap
    sheet.save(PREVIEW, "PNG", optimize=True)


def main():
    image = render(ICON)
    image.save(COPY, "PNG", optimize=True)
    preview(image)
    for path in (ICON, COPY, PREVIEW):
        print("%s  %s  %s" % (os.path.relpath(path, ROOT), Image.open(path).size, Image.open(path).mode))


if __name__ == "__main__":
    main()
