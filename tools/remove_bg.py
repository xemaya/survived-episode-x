#!/usr/bin/env python3
"""Convert cream-background sprites to transparent PNGs.

Strategy:
  1. Find pixels close to cream (#E8E0CC ± tol) → bg_mask.
  2. BFS flood-fill from the 4 corners → "outside" cream pixels.
     (This preserves cream pixels inside the sprite — e.g. shirt highlights — that
     are not connected to the corners.)
  3. Optional dilation absorbs thin 1px border lines and cell-label residue
     dark pixels that hang off the sprite edge.
  4. Optional auto-crop to the visible (non-transparent) bounding box, with
     padding, removes leftover label text floating in the cream margin.
  5. Set alpha=0 on outside pixels; write PNG with alpha channel.

Usage:
  python3 tools/remove_bg.py <input.png> <output.png>
  python3 tools/remove_bg.py --dir <input_dir> --out-dir <output_dir>
"""
import argparse
import sys
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image

CREAM_DEFAULT = (232, 224, 204)


def bfs_flood_from_corners(mask: np.ndarray) -> np.ndarray:
    """4-connectivity BFS flood from all 4 corners on a boolean mask.

    Returns a boolean array of pixels reachable from any corner where mask==True.
    """
    H, W = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    queue: deque = deque()
    for cy, cx in [(0, 0), (0, W - 1), (H - 1, 0), (H - 1, W - 1)]:
        if mask[cy, cx] and not visited[cy, cx]:
            visited[cy, cx] = True
            queue.append((cy, cx))
    while queue:
        y, x = queue.popleft()
        for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < H and 0 <= nx < W and mask[ny, nx] and not visited[ny, nx]:
                visited[ny, nx] = True
                queue.append((ny, nx))
    return visited


def dilate(mask: np.ndarray, iterations: int = 1) -> np.ndarray:
    """Manual binary dilation using 4-connected structuring element."""
    if iterations <= 0:
        return mask
    out = mask.copy()
    for _ in range(iterations):
        nxt = out.copy()
        nxt[1:, :] |= out[:-1, :]
        nxt[:-1, :] |= out[1:, :]
        nxt[:, 1:] |= out[:, :-1]
        nxt[:, :-1] |= out[:, 1:]
        out = nxt
    return out


def label_components(mask: np.ndarray) -> tuple[np.ndarray, int]:
    """Iterative 4-connected labeling without scipy. Returns (labels_2d, n_components).

    Slow but dependency-free. ~256x256 image runs in ~0.5s.
    """
    H, W = mask.shape
    labels = np.zeros((H, W), dtype=np.int32)
    next_id = 0
    for sy in range(H):
        for sx in range(W):
            if mask[sy, sx] and labels[sy, sx] == 0:
                next_id += 1
                stack = [(sy, sx)]
                labels[sy, sx] = next_id
                while stack:
                    y, x = stack.pop()
                    for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                        ny, nx = y + dy, x + dx
                        if 0 <= ny < H and 0 <= nx < W and mask[ny, nx] and labels[ny, nx] == 0:
                            labels[ny, nx] = next_id
                            stack.append((ny, nx))
    return labels, next_id


def remove_bg(in_path: Path, out_path: Path, *,
              cream: tuple[int, int, int] = CREAM_DEFAULT,
              tol: int = 35,
              dilate_px: int = 2,
              auto_crop: bool = True,
              crop_padding: int = 4,
              mode: str = "flood",      # "flood" | "aggressive" | "main_subject"
              dark_thresh: int = 350) -> dict:
    """Remove cream background, optionally isolate main subject.

    mode:
      "flood"        — only cream connected to corners is removed (preserves
                        cream inside sprite, e.g. shirt highlights).
      "aggressive"   — ALL cream pixels are removed regardless of connectivity.
                        Use when sprite has internal frame/border that traps
                        cream (e.g. event-CG portrait frames).
      "main_subject" — Aggressive cream removal + crop to bbox of largest
                        dark-connected-component. Filters away cell-label
                        residue floating in the cream margin.
    """
    img = Image.open(in_path).convert("RGBA")
    arr = np.array(img)
    H, W = arr.shape[:2]
    rgb = arr[:, :, :3].astype(int)
    diff = np.abs(rgb - np.array(cream)).sum(axis=2)
    cream_mask = diff < tol

    if mode == "flood":
        bg_mask = bfs_flood_from_corners(cream_mask)
    else:  # aggressive or main_subject
        bg_mask = cream_mask.copy()

    if dilate_px > 0:
        bg_mask = dilate(bg_mask, dilate_px)

    arr[bg_mask, 3] = 0

    crop_box = None
    if mode == "main_subject":
        # Find largest dark connected component (the NPC body) and crop to it,
        # ignoring smaller dark blobs (cell label residue).
        is_dark = arr[:, :, :3].sum(axis=2) < dark_thresh
        # only consider opaque pixels
        is_dark &= arr[:, :, 3] > 0
        labels, n = label_components(is_dark)
        if n > 0:
            sizes = np.bincount(labels.ravel())
            sizes[0] = 0  # background
            biggest = int(np.argmax(sizes))
            biggest_mask = (labels == biggest)
            ys, xs = np.where(biggest_mask)
            if len(ys) > 0:
                y0, y1 = ys.min(), ys.max()
                x0, x1 = xs.min(), xs.max()
                # zero alpha on everything outside this bbox (kills label residue)
                outside = np.ones((H, W), dtype=bool)
                outside[y0:y1+1, x0:x1+1] = False
                arr[outside, 3] = 0
                crop_box = (
                    max(0, x0 - crop_padding),
                    max(0, y0 - crop_padding),
                    min(W, x1 + 1 + crop_padding),
                    min(H, y1 + 1 + crop_padding),
                )

    out_img = Image.fromarray(arr)

    cropped = False
    if crop_box is not None:
        out_img = out_img.crop(crop_box)
        cropped = True
    elif auto_crop:
        bbox = out_img.getbbox()
        if bbox is not None:
            x0, y0, x1, y1 = bbox
            x0 = max(0, x0 - crop_padding)
            y0 = max(0, y0 - crop_padding)
            x1 = min(W, x1 + crop_padding)
            y1 = min(H, y1 + crop_padding)
            out_img = out_img.crop((x0, y0, x1, y1))
            cropped = True

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_img.save(out_path)
    return {
        "in_size": (W, H),
        "out_size": out_img.size,
        "bg_pixels": int(bg_mask.sum()),
        "cropped": cropped,
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("input", nargs="?", help="single input PNG (use --dir for batch)")
    ap.add_argument("output", nargs="?", help="single output PNG")
    ap.add_argument("--dir", help="batch: directory of PNGs to process")
    ap.add_argument("--out-dir", help="batch: output directory (mirrors structure)")
    ap.add_argument("--in-place", action="store_true", help="batch: overwrite input dir")
    ap.add_argument("--tol", type=int, default=35, help="cream color tolerance")
    ap.add_argument("--dilate", type=int, default=2, help="post-flood dilation px")
    ap.add_argument("--no-crop", action="store_true", help="skip auto-crop to bbox")
    ap.add_argument("--padding", type=int, default=4, help="bbox crop padding px")
    ap.add_argument("--mode", choices=["flood", "aggressive", "main_subject"],
                    default="flood",
                    help="flood=corner-connected only; aggressive=all cream; "
                         "main_subject=aggressive + crop to largest dark blob")
    args = ap.parse_args()

    if args.dir:
        in_dir = Path(args.dir)
        if args.in_place:
            out_dir = in_dir
        elif args.out_dir:
            out_dir = Path(args.out_dir)
        else:
            print("ERR: --dir requires --out-dir or --in-place", file=sys.stderr)
            return 2
        files = sorted(in_dir.rglob("*.png"))
        # Skip README.md or non-image leftovers (rglob already filters to .png)
        n_done, n_total_bg = 0, 0
        for f in files:
            rel = f.relative_to(in_dir)
            o = out_dir / rel
            r = remove_bg(f, o, tol=args.tol, dilate_px=args.dilate,
                          auto_crop=not args.no_crop, crop_padding=args.padding,
                          mode=args.mode)
            print(f"  {rel}  {r['in_size']} → {r['out_size']}  bg={r['bg_pixels']}")
            n_done += 1
            n_total_bg += r["bg_pixels"]
        print(f"\n=== {n_done} sprites processed, {n_total_bg:,} bg pixels removed ===")
        return 0

    if not args.input or not args.output:
        ap.print_help()
        return 2
    r = remove_bg(Path(args.input), Path(args.output),
                  tol=args.tol, dilate_px=args.dilate,
                  auto_crop=not args.no_crop, crop_padding=args.padding,
                  mode=args.mode)
    print(f"in={r['in_size']} out={r['out_size']} bg_removed={r['bg_pixels']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
