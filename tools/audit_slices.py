#!/usr/bin/env python3
"""Inspect every sliced sprite for top/bottom label-residue patterns.

A label residue typically looks like: a band of dark-text rows at the very top
or very bottom of the sprite, immediately followed/preceded by mostly-cream rows
(the natural gap before the actual sprite content).

Outputs a sorted list of suspicious sprites with their detected leakage type
(top/bottom) and severity (count of dark text rows in the top/bottom band).
"""
import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SPRITES = ROOT / "assets/sprites"

CHECK_BAND = 22  # px from top/bottom to check
DARK_ROW_MIN = 30  # row counts as "has text" if this many dark px
SUSPICIOUS_DARK_ROWS = 3  # band has this many text rows → suspicious


def audit_sprite(path: Path) -> dict:
    arr = np.array(Image.open(path).convert("RGB"))
    H, W = arr.shape[:2]
    if H < 40 or W < 40:
        return {"skip": "too_small"}
    is_dark = arr.sum(axis=2) < 300
    dark_per_row = is_dark.sum(axis=1)

    top_band = dark_per_row[:CHECK_BAND]
    bot_band = dark_per_row[H - CHECK_BAND:]

    top_text_rows = int((top_band >= DARK_ROW_MIN).sum())
    bot_text_rows = int((bot_band >= DARK_ROW_MIN).sum())

    # Heuristic: if top band has many text rows AND there's a clear cream
    # transition just below the top band, label residue is likely.
    # Sample rows CHECK_BAND..CHECK_BAND+10 — should be relatively cream
    near_top = dark_per_row[CHECK_BAND:CHECK_BAND + 10]
    near_bot = dark_per_row[H - CHECK_BAND - 10:H - CHECK_BAND]

    top_followed_by_cream = (near_top < 10).sum() >= 5 if len(near_top) > 0 else False
    bot_preceded_by_cream = (near_bot < 10).sum() >= 5 if len(near_bot) > 0 else False

    issues = []
    if top_text_rows >= SUSPICIOUS_DARK_ROWS and top_followed_by_cream:
        issues.append(("top_label", top_text_rows))
    if bot_text_rows >= SUSPICIOUS_DARK_ROWS and bot_preceded_by_cream:
        issues.append(("bot_label", bot_text_rows))
    return {"issues": issues, "h": H, "w": W}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int, default=0, help="show top N suspicious only")
    args = ap.parse_args()

    rows: list[tuple[int, str, str]] = []
    skipped = 0
    total = 0
    for path in sorted(SPRITES.rglob("*.png")):
        # Skip the source sheets (1024x1024) and pre-existing test_outputs
        rel = path.relative_to(SPRITES)
        if rel.parts[0] == "test_outputs":
            continue
        total += 1
        r = audit_sprite(path)
        if r.get("skip"):
            skipped += 1
            continue
        for itype, severity in r.get("issues", []):
            rows.append((severity, itype, str(rel)))

    rows.sort(key=lambda x: -x[0])
    if args.limit:
        rows = rows[: args.limit]

    print(f"=== audit: {total} sliced sprites checked, {skipped} skipped ===")
    print(f"{len(rows)} suspicious entries\n")
    by_dir: dict[str, int] = {}
    for sev, itype, p in rows:
        d = str(Path(p).parent)
        by_dir[d] = by_dir.get(d, 0) + 1
    print("Suspicious-count per directory:")
    for d in sorted(by_dir, key=lambda x: -by_dir[x]):
        print(f"  {by_dir[d]:>3}  {d}")
    print()
    print("Detail (severity = dark-text rows found in top/bottom 22px band):")
    for sev, itype, p in rows:
        print(f"  {sev:>3}  {itype:9s}  {p}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
