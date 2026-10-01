#!/usr/bin/env python3
"""Slice the ChatGPT panorama into 5 text-free base prints per display type.

The background is a vertical gradient that is horizontally uniform, so every
panel is isolated by repainting the columns outside its own content with the
per-row background colour (kills the neighbour's breakout card / bezel that
would otherwise leak into the crop window). Each crop window is centred on
the phone, scaled so the phone spans from PHONE_TOP to (H - BOTTOM_MARGIN),
padded with the extrapolated gradient where the window leaves the source.

Usage: slice_panorama.py <experiment_dir>
Output: source/base_textfree/<dt>/0N.png  (dt in 67, 65, 55)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

TARGETS = {"67": (1320, 2868), "65": (1242, 2688), "55": (1242, 2208)}
PHONE_TOP_FRAC = 580 / 2868      # headline zone above the phone
BOTTOM_MARGIN_FRAC = 110 / 2868  # background visible under the phone (João, 2026-08-28)
CONTENT_MIN_FRAC = 0.03
BG_DIST = 45
GAP = 6


def content_runs(img: np.ndarray, ref: np.ndarray) -> list[tuple[int, int]]:
    diff = np.abs(img - ref[:, None, :]).sum(axis=2)
    cols = np.where((diff > BG_DIST)[90:840].mean(axis=0) > CONTENT_MIN_FRAC)[0]
    runs, start, prev = [], cols[0], cols[0]
    for c in cols[1:]:
        if c - prev > GAP:
            runs.append((int(start), int(prev)))
            start = c
        prev = c
    runs.append((int(start), int(prev)))
    return runs


def phone_box(img: np.ndarray, x0: int, x1: int) -> tuple[int, int, int, int]:
    dark = (img[..., 0] < 40) & (img[..., 1] < 40) & (img[..., 2] < 32)
    h = img.shape[0]
    band = dark[int(h * 0.87):int(h * 0.93), x0:x1 + 1].mean(axis=0)  # below every breakout card
    xs = np.where(band > 0.85)[0] + x0
    px0, px1 = int(xs.min()), int(xs.max())
    rows = dark[:, px0 + 25:px1 - 25].mean(axis=1)
    ys = np.where(rows > 0.85)[0]
    return px0, px1, int(ys.min()), int(ys.max())


def bg_row(ref: np.ndarray, y: float) -> np.ndarray:
    h = len(ref)
    if y < 0:  # extrapolate the top gradient darker
        return np.clip(ref[0] + (ref[0] - ref[40]) * (-y / 40.0), 0, 255)
    if y >= h:
        return ref[h - 1]
    return ref[int(y)]


def crop_panel(img: np.ndarray, ref: np.ndarray, cx0: int, cx1: int, box: tuple[int, int, int, int],
               tw: int, th: int) -> Image.Image:
    h, w, _ = img.shape
    px0, px1, py0, py1 = box
    clean = img.copy()
    clean[:, :max(cx0 - 2, 0)] = ref[:, None, :]
    clean[:, cx1 + 3:] = ref[:, None, :]
    phone_h = th * (1 - PHONE_TOP_FRAC - BOTTOM_MARGIN_FRAC)
    s = phone_h / (py1 - py0 + 1)
    win_w, win_h = tw / s, th / s
    cx = (px0 + px1) / 2
    wx0, wy0 = cx - win_w / 2, py0 - PHONE_TOP_FRAC * th / s
    # canvas at source scale, filled with gradient, then paste the visible part
    cw, ch = int(round(win_w)), int(round(win_h))
    canvas = np.zeros((ch, cw, 3), dtype=np.float32)
    for r in range(ch):
        canvas[r, :] = bg_row(ref, wy0 + r)
    sx0, sy0 = int(round(wx0)), int(round(wy0))
    vx0, vy0 = max(sx0, 0), max(sy0, 0)
    vx1, vy1 = min(sx0 + cw, w), min(sy0 + ch, h)
    if vx1 > vx0 and vy1 > vy0:
        canvas[vy0 - sy0:vy1 - sy0, vx0 - sx0:vx1 - sx0] = clean[vy0:vy1, vx0:vx1]
    out = Image.fromarray(np.clip(canvas, 0, 255).astype(np.uint8))
    return out.resize((tw, th), Image.LANCZOS)


def main() -> int:
    exp = Path(sys.argv[1]).resolve()
    src = next((exp / "source").glob("panorama_*.png"))
    img = np.array(Image.open(src).convert("RGB")).astype(np.float32)
    h, w, _ = img.shape
    runs = content_runs(img, img[:, 0:6].mean(axis=1))  # first pass with the left edge as bg
    # refine bg reference: widest gap between runs
    gaps = [(runs[i + 1][0] - runs[i][1], runs[i][1] + 1, runs[i + 1][0] - 1) for i in range(len(runs) - 1)]
    _, gx0, gx1 = max(gaps)
    ref = img[:, gx0 + 2:gx1 - 1].mean(axis=1)
    runs = content_runs(img, ref)
    if len(runs) != 5:
        sys.exit(f"expected 5 content runs, got {runs}")
    report = {"source": src.name, "size": [w, h], "bg_ref_columns": [gx0, gx1], "panels": []}
    boxes = [phone_box(img, *r) for r in runs]
    for k, (run, box) in enumerate(zip(runs, boxes), 1):
        report["panels"].append({"panel": k, "content_x": list(run), "phone": list(box)})
        print(f"panel {k}: content x {run[0]}-{run[1]}  phone x {box[0]}-{box[1]} y {box[2]}-{box[3]} "
              f"(w={box[1]-box[0]+1}, h={box[3]-box[2]+1}, ratio={(box[1]-box[0]+1)/(box[3]-box[2]+1):.3f})")
    for dt, (tw, th) in TARGETS.items():
        out_dir = exp / "source" / "base_textfree" / dt
        out_dir.mkdir(parents=True, exist_ok=True)
        for k, (run, box) in enumerate(zip(runs, boxes), 1):
            crop_panel(img, ref, run[0], run[1], box, tw, th).save(out_dir / f"0{k}.png", optimize=False)
        print(f"wrote {dt}: 5 × {tw}x{th}")
    (exp / "source" / "slice_report.json").write_text(json.dumps(report, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
