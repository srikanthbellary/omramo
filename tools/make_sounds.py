#!/usr/bin/env python3
"""Makes Omramo's two optional reader sounds. Python 3, standard library only.

    python3 tools/make_sounds.py

Writes `App/Resources/Sounds/page-turn.wav` and `card-open.wav` (mono, 16-bit, 44.1 kHz).
Both are synthesised here from plain arithmetic: no recording and no sample from anywhere
else is used. They are deliberately short and quiet; the app plays them only when sounds are
switched on in the "Aa" panel (off by default), in the `.ambient` audio session category.

The noise uses a fixed seed, so running the script again gives the same files byte for byte.
"""

import math
import os
import random
import struct
import wave

RATE = 44100
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "App", "Resources", "Sounds"))


def write(name, samples):
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name)
    peak = max(1e-9, max(abs(s) for s in samples))
    # Never clip; the level itself is set by each sound's own gain.
    scale = min(1.0, 0.98 / peak)
    with wave.open(path, "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        handle.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767)) for s in samples))
    return path


def page_turn():
    """A soft paper-like swish: low-passed noise whose brightness rises and falls, 0.22 s."""
    rng = random.Random(4)
    count = int(RATE * 0.22)
    samples = []
    low = 0.0
    lower = 0.0
    for i in range(count):
        t = i / count
        # A gentle swell: quick in, slow out.
        envelope = math.sin(math.pi / 2 * t / 0.35) if t < 0.35 else math.cos((t - 0.35) / 0.65 * math.pi / 2) ** 2
        # The filter opens toward the middle of the swish, then closes.
        cutoff = 0.05 + 0.2 * math.sin(math.pi * t) ** 2
        noise = rng.uniform(-1, 1)
        low += cutoff * (noise - low)
        lower += cutoff * (low - lower)
        samples.append(lower * envelope * 0.5)
    return samples


def card_open():
    """Two soft bell-like notes a major third apart (A5 then C#6), 0.42 s, slow decay."""
    count = int(RATE * 0.42)
    notes = ((880.0, 0.0, 0.22), (1108.73, 0.07, 0.18))
    samples = []
    for i in range(count):
        t = i / RATE
        value = 0.0
        for frequency, start, gain in notes:
            if t < start:
                continue
            local = t - start
            attack = min(1.0, local / 0.012)
            decay = math.exp(-local * 9.0)
            tone = math.sin(2 * math.pi * frequency * local) + 0.22 * math.sin(2 * math.pi * frequency * 2 * local) * math.exp(-local * 14.0)
            value += tone * attack * decay * gain
        # Fade the very end to silence, so nothing clicks.
        tail = min(1.0, (count - i) / (RATE * 0.03))
        samples.append(value * tail)
    return samples


def main():
    for name, samples in (("page-turn.wav", page_turn()), ("card-open.wav", card_open())):
        path = write(name, samples)
        print("%s  %d bytes  %.2f s" % (os.path.relpath(path, os.path.join(HERE, "..")), os.path.getsize(path), len(samples) / RATE))


if __name__ == "__main__":
    main()
