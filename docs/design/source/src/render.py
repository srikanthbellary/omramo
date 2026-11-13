#!/usr/bin/env python3
"""Render Omramo v2 screens with headless Chrome.

Usage: python3 render.py [name-filter[,name-filter...]] [--framed-only] [--raw-only]

Each screen is generated in the browser by screen.html (which loads lib/*.js and
screens.js) and captured at @3x. Static HTML snapshots are written to src/screens/.
Framed presentation versions are produced by frame.html from the raw PNGs.
"""
import json, os, subprocess, sys

SRC = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(SRC)
PANE_W, PANE_H, HINGE = 432, 720, 28
DUO_W = PANE_W * 2 + HINGE
CHROME = ["google-chrome", "--headless=new", "--no-sandbox", "--disable-gpu", "--hide-scrollbars",
          "--allow-file-access-from-files", "--virtual-time-budget=6000"]

def shot(url, out, w, h, scale):
    subprocess.run(CHROME + [f"--force-device-scale-factor={scale}", f"--window-size={w},{h}",
                             f"--screenshot={out}", url], check=True, capture_output=True)

def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    flags = [a for a in sys.argv[1:] if a.startswith("--")]
    filt = args[0].split(",") if args else None
    manifest = json.load(open(os.path.join(SRC, "manifest.json")))
    os.makedirs(os.path.join(ROOT, "png"), exist_ok=True)
    os.makedirs(os.path.join(ROOT, "png-framed"), exist_ok=True)
    os.makedirs(os.path.join(SRC, "screens"), exist_ok=True)
    for s in manifest:
        name, folded = s["name"], s.get("folded", False)
        if filt and not any(f in name for f in filt):
            continue
        w = PANE_W if folded else DUO_W
        raw = os.path.join(ROOT, "png", name + ".png")
        if "--framed-only" not in flags:
            url = f"file://{SRC}/screen.html?s={name}"
            shot(url, raw, w, PANE_H, 3)
            dom = subprocess.run(CHROME + ["--dump-dom", url], check=True, capture_output=True, text=True).stdout
            # snapshots live one folder deeper than screen.html, so re-point the font URLs
            dom = dom.replace('url("../fonts/', 'url("../../fonts/')
            open(os.path.join(SRC, "screens", name + ".html"), "w").write(dom)
            print("raw   ", name)
        if "--raw-only" not in flags:
            fw, fh = (760, 940) if folded else (1180, 920)
            url = f"file://{SRC}/frame.html?s={name}&folded={1 if folded else 0}"
            shot(url, os.path.join(ROOT, "png-framed", name + ".png"), fw, fh, 2)
            print("framed", name)

if __name__ == "__main__":
    main()
