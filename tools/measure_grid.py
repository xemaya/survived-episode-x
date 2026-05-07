#!/usr/bin/env python3
"""Measure banner + per-cell label heights for grid sprite sheets.

Outputs recommended (crop_top, row_top_skip, label_band) per sheet by analyzing
where dark text rows fall relative to the expected grid.

Usage:
    python3 tools/measure_grid.py <sheet.png> <rows> <cols>
    python3 tools/measure_grid.py --all          # measure all known grid sheets from cuts.yaml
"""
import argparse
import sys
from pathlib import Path

import numpy as np
import yaml
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent


def measure(path: Path, rows: int, cols: int) -> dict:
    """Return measured banner_h, label_h, recommended params."""
    img = Image.open(path).convert("RGB")
    arr = np.array(img)
    H, W = arr.shape[:2]

    # Detect "has dark text" per row: count of dark pixels (R+G+B < 300 i.e. very dark)
    is_dark = (arr.sum(axis=2) < 300)
    dark_per_row = is_dark.sum(axis=1)
    # A row is "label-ish" if it has a visible amount of dark text (heuristic)
    is_text = dark_per_row > 25

    # Cluster contiguous text rows
    clusters: list[tuple[int, int]] = []
    in_cluster = False
    start = 0
    for i, t in enumerate(is_text):
        if t and not in_cluster:
            start = i
            in_cluster = True
        elif not t and in_cluster:
            clusters.append((start, i - 1))
            in_cluster = False
    if in_cluster:
        clusters.append((start, H - 1))

    if not clusters:
        return {"error": "no text clusters detected"}

    # Banner = first cluster (title at top)
    banner_top, banner_bot = clusters[0]
    banner_height = banner_bot - banner_top + 1

    # For each row, expected center is at (r + 0.5) / rows * H_below_banner + banner_bot
    # The label of row r should sit just before the bottom of that row.
    # Cell row boundaries (estimated): y_top_r = banner_bot + 1 + r * row_h
    # row_h = (H - banner_bot - 1) / rows
    row_h_est = (H - banner_bot - 1) / rows

    # For each row, find the LAST text cluster whose center falls within that row's vertical span.
    # That cluster is presumably the cell label.
    label_heights: list[int] = []
    for r in range(rows):
        y_top = banner_bot + 1 + r * row_h_est
        y_bot = banner_bot + 1 + (r + 1) * row_h_est
        in_row = [(s, e) for (s, e) in clusters[1:] if y_top <= (s + e) / 2 < y_bot]
        if not in_row:
            continue
        # Combine adjacent label clusters in lower half of row (Chinese line + English line)
        lower_half = [(s, e) for (s, e) in in_row if (s + e) / 2 > y_top + row_h_est * 0.55]
        if lower_half:
            top = min(s for s, _ in lower_half)
            bot = max(e for _, e in lower_half)
            label_heights.append(bot - top + 1)

    label_h = max(label_heights) if label_heights else 0

    # Recommendations:
    # crop_top: snap below banner with small buffer
    crop_top = max(0, banner_bot - 8)  # keep 8px before, the slicer divides remaining by rows
    # label_band: enough to chop the cell label + small buffer below it
    label_band = label_h + 16  # buffer
    # row_top_skip: small buffer to absorb prior-cell label leak (shouldn't be needed if label_band right)
    row_top_skip = 12

    return {
        "H": H,
        "W": W,
        "rows": rows,
        "cols": cols,
        "banner_top": banner_top,
        "banner_bot": banner_bot,
        "banner_height": banner_height,
        "row_height_est": int(row_h_est),
        "label_heights": label_heights,
        "label_h_max": label_h,
        "rec_crop_top": crop_top,
        "rec_label_band": label_band,
        "rec_row_top_skip": row_top_skip,
        "rec_sprite_height": int(row_h_est) - label_band - row_top_skip,
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("sheet", nargs="?")
    ap.add_argument("rows", nargs="?", type=int)
    ap.add_argument("cols", nargs="?", type=int)
    ap.add_argument("--all", action="store_true", help="measure all grid entries from cuts.yaml")
    args = ap.parse_args()

    if args.all:
        cuts = yaml.safe_load((ROOT / "tools/cuts.yaml").read_text())
        for entry in cuts:
            if entry.get("mode") != "grid":
                continue
            src = ROOT / "assets/sprites/test_outputs" / entry["source"]
            if not src.exists():
                print(f"!! missing {src.name}")
                continue
            r = measure(src, entry["rows"], entry["cols"])
            print(
                f"{src.name:45s}  {entry['rows']}x{entry['cols']}  "
                f"banner={r.get('banner_height'):>3}  "
                f"row_h={r.get('row_height_est'):>3}  "
                f"label_h={r.get('label_h_max'):>3}  "
                f"→ crop_top={r.get('rec_crop_top'):>3} "
                f"row_top_skip={r.get('rec_row_top_skip'):>3} "
                f"label_band={r.get('rec_label_band'):>3} "
                f"sprite_h={r.get('rec_sprite_height'):>3}"
            )
    elif args.sheet and args.rows and args.cols:
        path = Path(args.sheet)
        if not path.is_absolute():
            path = ROOT / "assets/sprites/test_outputs" / path
        r = measure(path, args.rows, args.cols)
        for k, v in r.items():
            print(f"  {k}: {v}")
    else:
        ap.print_help()
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
