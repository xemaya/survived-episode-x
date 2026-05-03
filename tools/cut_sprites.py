#!/usr/bin/env python3
"""Slice large reference sheets into individual sprites per cuts.yaml.

Run from project root:
    python3 tools/cut_sprites.py
"""
import sys
from pathlib import Path
import yaml
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "assets/sprites/test_outputs"
OUT_BASE = ROOT / "assets/sprites"
CONFIG = ROOT / "tools/cuts.yaml"


def slice_grid(img, rows, cols, crop_top=0, crop_bottom=0,
               crop_left=0, crop_right=0, label_band=0):
    W, H = img.size
    inner_w = W - crop_left - crop_right
    inner_h = H - crop_top - crop_bottom
    cw = inner_w // cols
    ch = inner_h // rows
    out = []
    for r in range(rows):
        row = []
        for c in range(cols):
            x0 = crop_left + c * cw
            y0 = crop_top + r * ch
            x1 = x0 + cw
            y1 = y0 + ch - label_band
            row.append(img.crop((x0, y0, x1, y1)))
        out.append(row)
    return out


def slice_rows_unequal(img, rows_cfg, crop_top=0, crop_bottom=0,
                       crop_left=0, crop_right=0):
    W, H = img.size
    inner_w = W - crop_left - crop_right
    inner_h = H - crop_top - crop_bottom
    n_rows = len(rows_cfg)
    rh = inner_h // n_rows
    out = {}
    for r, row in enumerate(rows_cfg):
        cols = row["cols"]
        names = row["names"]
        lb = row.get("label_band", 0)
        ts = row.get("row_top_skip", 0)  # skip per-row sub-banner
        cw = inner_w // cols
        for c in range(cols):
            x0 = crop_left + c * cw
            y0 = crop_top + r * rh + ts
            x1 = x0 + cw
            y1 = y0 + rh - lb - ts
            out[names[c]] = img.crop((x0, y0, x1, y1))
    return out


def process(entry):
    src = SRC_DIR / entry["source"]
    if not src.exists():
        print(f"  ⚠ source missing: {src}")
        return 0
    img = Image.open(src)
    mode = entry["mode"]
    n = 0

    if mode == "single":
        dst = OUT_BASE / entry["output"]
        dst.parent.mkdir(parents=True, exist_ok=True)
        img.save(dst)
        print(f"  → {dst.relative_to(OUT_BASE)}")
        return 1

    if mode == "grid":
        out_dir = OUT_BASE / entry["output_dir"]
        out_dir.mkdir(parents=True, exist_ok=True)
        cells = slice_grid(
            img,
            rows=entry["rows"],
            cols=entry["cols"],
            crop_top=entry.get("crop_top", 0),
            crop_bottom=entry.get("crop_bottom", 0),
            crop_left=entry.get("crop_left", 0),
            crop_right=entry.get("crop_right", 0),
            label_band=entry.get("label_band", 0),
        )
        for r, row_names in enumerate(entry["names"]):
            for c, name in enumerate(row_names):
                p = out_dir / f"{name}.png"
                cells[r][c].save(p)
                n += 1
        print(f"  → {out_dir.relative_to(OUT_BASE)}/ ({n} cells)")
        return n

    if mode == "rows_unequal":
        out_dir = OUT_BASE / entry["output_dir"]
        out_dir.mkdir(parents=True, exist_ok=True)
        cells = slice_rows_unequal(
            img,
            entry["rows"],
            crop_top=entry.get("crop_top", 0),
            crop_bottom=entry.get("crop_bottom", 0),
            crop_left=entry.get("crop_left", 0),
            crop_right=entry.get("crop_right", 0),
        )
        for name, cell in cells.items():
            p = out_dir / f"{name}.png"
            cell.save(p)
            n += 1
        print(f"  → {out_dir.relative_to(OUT_BASE)}/ ({n} cells)")
        return n

    print(f"  ⚠ unknown mode: {mode}")
    return 0


def main():
    config = yaml.safe_load(CONFIG.read_text())
    total = 0
    for entry in config:
        print(f"[{entry['source']}] mode={entry['mode']}")
        total += process(entry)
    print(f"\n=== {total} sprites generated under {OUT_BASE.relative_to(ROOT)} ===")


if __name__ == "__main__":
    sys.exit(main())
