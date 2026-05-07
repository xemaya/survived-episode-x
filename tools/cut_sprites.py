#!/usr/bin/env python3
"""Slice large reference sheets into individual sprites per cuts.yaml.

Run from project root:
    python3 tools/cut_sprites.py
"""
import sys
from pathlib import Path
import yaml
import numpy as np
from PIL import Image


CREAM_BG = np.array([232, 224, 204])


def find_row_boundaries(img: Image.Image, n_rows: int, banner_top: int = 0,
                        search_window: int = 60) -> list[int]:
    """Hybrid row boundary detection.

    Strategy:
      1. Estimate uniform row boundaries below banner.
      2. For each estimated internal boundary, search ±search_window for the
         "creamest" row (highest cream-pixel ratio) and snap to it.
      3. Top boundary = banner_top; bottom = H.

    Always returns n_rows+1 boundaries (no failure mode — falls back to
    uniform if no cream pixels found in a window).
    """
    arr = np.array(img.convert("RGB"))
    H = arr.shape[0]
    # A row counts as a "true gap" only if it has essentially zero dark text
    # (cream paper in label regions has dark characters; cell sprite has dark
    # outlines). True inter-cell gaps are sustained for several rows.
    is_dark = arr.sum(axis=2) < 300
    dark_count_per_row = is_dark.sum(axis=1)
    is_clear = dark_count_per_row < 5

    # Find all sustained clear runs (>= 4 rows), globally
    runs: list[tuple[int, int]] = []
    in_run = False
    start = 0
    MIN_RUN = 4
    for y in range(H):
        if is_clear[y] and not in_run:
            start = y
            in_run = True
        elif not is_clear[y] and in_run:
            if y - start >= MIN_RUN:
                runs.append((start, y - 1))
            in_run = False
    if in_run and H - start >= MIN_RUN:
        runs.append((start, H - 1))

    inner_h = H - banner_top
    row_h_est = inner_h / n_rows

    boundaries = [banner_top]
    for r in range(1, n_rows):
        est = banner_top + int(r * row_h_est)
        # Within ±search_window of est, pick the TALLEST sustained run.
        # (Each inter-cell zone has 3 runs: cell-top cream, label inter-line,
        # cell-bottom cream — the last is largest and is the true row gap.)
        best_y = est
        best_h = 0
        for s, e in runs:
            center = (s + e) // 2
            if abs(center - est) > search_window:
                continue
            h = e - s + 1
            if h > best_h or (h == best_h and abs(center - est) < abs(best_y - est)):
                best_h = h
                best_y = center
        boundaries.append(best_y)
    boundaries.append(H)
    return boundaries

ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "assets/sprites/test_outputs"
OUT_BASE = ROOT / "assets/sprites"
CONFIG = ROOT / "tools/cuts.yaml"


def slice_grid(img, rows, cols, crop_top=0, crop_bottom=0,
               crop_left=0, crop_right=0, label_band=0, row_top_skip=0,
               auto_rows=False, row_boundaries=None):
    W, H = img.size
    inner_w = W - crop_left - crop_right
    cw = inner_w // cols

    if row_boundaries is not None:
        boundaries = list(row_boundaries)
        assert len(boundaries) == rows + 1, \
            f"row_boundaries needs {rows + 1} entries, got {len(boundaries)}"
    elif auto_rows:
        boundaries = find_row_boundaries(img, rows, banner_top=crop_top)
    else:
        inner_h = H - crop_top - crop_bottom
        ch = inner_h // rows
        boundaries = [crop_top + r * ch for r in range(rows + 1)]

    out = []
    for r in range(rows):
        row = []
        y_top = boundaries[r]
        y_bot = boundaries[r + 1]
        for c in range(cols):
            x0 = crop_left + c * cw
            y0 = max(0, y_top + row_top_skip)
            x1 = x0 + cw
            y1 = max(y0 + 1, y_bot - label_band)  # clamp to avoid lower<upper
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
            row_top_skip=entry.get("row_top_skip", 0),
            auto_rows=entry.get("auto_rows", False),
            row_boundaries=entry.get("row_boundaries"),
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
