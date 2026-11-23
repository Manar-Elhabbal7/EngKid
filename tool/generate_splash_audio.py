#!/usr/bin/env python3
"""Kid-safe Halloween lullaby for the EngKids splash screen."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

RATE = 44100
DURATION = 8.0
N = int(RATE * DURATION)


def clamp(sample: float) -> int:
    return max(-32767, min(32767, int(sample * 32767)))


def envelope(t: float, length: float, attack: float = 0.02, release: float = 0.35) -> float:
    if t < 0 or t > length:
        return 0.0
    a = min(1.0, t / attack) if attack > 0 else 1.0
    tail = length - t
    r = min(1.0, tail / release) if release > 0 else 1.0
    return a * r


def music_box(freq: float, t: float) -> float:
    # Soft inharmonic partials like a tiny glockenspiel.
    return (
        0.62 * math.sin(2 * math.pi * freq * t)
        + 0.22 * math.sin(2 * math.pi * freq * 2.003 * t)
        + 0.10 * math.sin(2 * math.pi * freq * 3.01 * t)
        + 0.06 * math.sin(2 * math.pi * freq * 4.04 * t)
    )


def note_freq(name: str) -> float:
    # A4 = 440
    scale = {
        "E4": 329.63,
        "G4": 392.00,
        "A4": 440.00,
        "B4": 493.88,
        "C5": 523.25,
        "D5": 587.33,
        "E5": 659.25,
        "G5": 783.99,
        "A5": 880.00,
        "B5": 987.77,
        "C6": 1046.50,
    }
    return scale[name]


# Gentle haunted-lullaby motif (A minor pentatonic), not scary.
MELODY = [
    ("E5", 0.00, 0.55),
    ("G5", 0.50, 0.55),
    ("A5", 1.00, 0.80),
    ("G5", 1.70, 0.45),
    ("E5", 2.15, 0.70),
    ("D5", 2.85, 0.55),
    ("C5", 3.35, 0.70),
    ("A4", 4.05, 0.90),
    ("E5", 4.90, 0.45),
    ("G5", 5.35, 0.45),
    ("E5", 5.80, 0.90),
    ("C5", 6.70, 1.10),
]


def synth() -> tuple[list[float], list[float]]:
    left = [0.0] * N
    right = [0.0] * N
    rng = random.Random(26)

    # Warm night wind (smoothed noise).
    wind = 0.0
    for i in range(N):
        wind = wind * 0.993 + (rng.random() * 2 - 1) * 0.007
        t = i / RATE
        breeze = wind * (0.55 + 0.45 * math.sin(2 * math.pi * 0.12 * t))
        fade = min(1.0, t / 0.4, (DURATION - t) / 0.5)
        left[i] += breeze * 0.18 * fade
        right[i] += breeze * 0.16 * fade

    # Distant soft owl-ish whoo (very gentle, not jump-scare).
    for start, freq in ((1.6, 280.0), (5.4, 250.0)):
        length = 1.15
        for i in range(int(start * RATE), min(N, int((start + length) * RATE))):
            t = i / RATE - start
            env = envelope(t, length, attack=0.25, release=0.5)
            wobble = 1.0 + 0.03 * math.sin(2 * math.pi * 4.5 * t)
            sig = math.sin(2 * math.pi * freq * wobble * t) * env * 0.07
            left[i] += sig
            right[i] += sig * 0.85

    # Music-box melody + stereo sparkle delay.
    delay = int(0.09 * RATE)
    for name, start, length in MELODY:
        freq = note_freq(name)
        for i in range(int(start * RATE), min(N, int((start + length) * RATE))):
            t = i / RATE - start
            env = envelope(t, length, attack=0.01, release=0.42)
            # Extra sparkle decay
            env *= math.exp(-2.4 * t)
            sig = music_box(freq, t) * env * 0.22
            left[i] += sig
            j = i + delay
            if j < N:
                right[j] += sig * 0.72
            else:
                right[i] += sig * 0.55
            right[i] += sig * 0.28

    # Tiny star chimes as "progress" ticks.
    for start, freq in ((0.9, 1568.0), (2.4, 2093.0), (4.1, 1760.0), (6.2, 2349.0)):
        length = 0.28
        for i in range(int(start * RATE), min(N, int((start + length) * RATE))):
            t = i / RATE - start
            env = envelope(t, length, attack=0.004, release=0.22) * math.exp(-8 * t)
            sig = math.sin(2 * math.pi * freq * t) * env * 0.09
            left[i] += sig
            right[i] += sig * 0.8

    # Soft limiter
    peak = max(max(abs(s) for s in left), max(abs(s) for s in right), 1e-6)
    gain = 0.92 / peak if peak > 0.92 else 1.0
    if gain != 1.0:
        left = [s * gain for s in left]
        right = [s * gain for s in right]
    return left, right


def write_wav(path: Path, left: list[float], right: list[float]) -> None:
    with wave.open(str(path), "w") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        frames = bytearray()
        for l, r in zip(left, right):
            frames += struct.pack("<hh", clamp(l), clamp(r))
        wav.writeframes(frames)


def main() -> None:
    out_dir = Path(__file__).resolve().parents[1] / "assets" / "audio"
    out_dir.mkdir(parents=True, exist_ok=True)
    wav_path = out_dir / "halloween_splash.wav"
    left, right = synth()
    write_wav(wav_path, left, right)
    print(f"wrote {wav_path}")


if __name__ == "__main__":
    main()
