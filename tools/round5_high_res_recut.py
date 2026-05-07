#!/usr/bin/env python3
"""W5 round-5 post-processing: re-cut 1024 source → 256×384 portrait (large AVG size).

Reads from design/concepts/p5-assets/round3_<id>.png (1024 source).
Writes to assets/sprites/npc/<id>.png OVERWRITING the previous 64×96 output.

Reason: 64×96 portrait is too small for AVG-standard 立绘 zoom. 256×384 is the
new size (about 4x linear). engine npc-registry will use scale ~0.6-0.7 to land
at ~150-180 px tall on the 360-tall canvas (about half-height, AVG standard).

Includes lin_jie + cafeteria_auntie which round-3 didn't re-cut.
"""
import sys
from pathlib import Path
from PIL import Image
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "design/concepts/p5-assets"
NPC_OUT = ROOT / "assets/sprites/npc"

# 9 NPCs from round-3
NPC_IDS = [
    "lisa", "david", "wang_director", "vivian", "zoe",
    "lao_zhou", "li_ayi", "mama", "it_xiaoma",
]

# round-1 sources (lin_jie + cafeteria_auntie) — different filename
EXTRA_NPCS = {
    "lin_jie": "p5_asset_08_lin_jie.png",
    "cafeteria_auntie": "p5_asset_09_cafeteria_auntie.png",
}

WHITE_THRESHOLD = 245
BBOX_PAD = 20
TARGET_W = 256
TARGET_H = 384


def chroma_key_white(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    arr = np.array(rgba)
    r, g, b, a = arr[..., 0], arr[..., 1], arr[..., 2], arr[..., 3]
    mask = (r >= WHITE_THRESHOLD) & (g >= WHITE_THRESHOLD) & (b >= WHITE_THRESHOLD)
    arr[mask, 3] = 0
    return Image.fromarray(arr)


def fit_to_canvas(img: Image.Image, target_w: int, target_h: int) -> Image.Image:
    """Crop to bbox of non-transparent + pad + resize fit-to with aspect preservation,
    pad alpha 0 to fill target."""
    bbox = img.getbbox()
    if bbox is None:
        # All transparent — just resize blank
        return img.resize((target_w, target_h), Image.NEAREST)
    l, t, r, b = bbox
    pad = BBOX_PAD
    l = max(0, l - pad)
    t = max(0, t - pad)
    r = min(img.width, r + pad)
    b = min(img.height, b + pad)
    crop = img.crop((l, t, r, b))
    cw, ch = crop.size
    # Fit-to: scale to fit target, preserve aspect
    sx = target_w / cw
    sy = target_h / ch
    s = min(sx, sy)
    new_w, new_h = int(cw * s), int(ch * s)
    resized = crop.resize((new_w, new_h), Image.LANCZOS)
    # Center on transparent canvas
    canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    cx = (target_w - new_w) // 2
    cy = target_h - new_h  # bottom-align
    canvas.paste(resized, (cx, cy), resized)
    return canvas


def process_npc(src_path: Path, out_path: Path):
    print(f"  {src_path.name} → {out_path.name}")
    src = Image.open(src_path).convert("RGBA")
    keyed = chroma_key_white(src)
    fitted = fit_to_canvas(keyed, TARGET_W, TARGET_H)
    fitted.save(out_path, optimize=True)


def main():
    # Process round-3 NPCs
    for npc_id in NPC_IDS:
        src = SRC / f"round3_{npc_id}.png"
        if not src.exists():
            print(f"  ! missing {src}", file=sys.stderr)
            continue
        out = NPC_OUT / f"{npc_id}.png"
        process_npc(src, out)

    # Process round-1 extras (lin_jie + cafeteria_auntie)
    for npc_id, src_name in EXTRA_NPCS.items():
        src = SRC / src_name
        if not src.exists():
            print(f"  ! missing {src}", file=sys.stderr)
            continue
        out = NPC_OUT / f"{npc_id}.png"
        process_npc(src, out)

    print("Done — overwrote 11 NPC portraits at 256×384")


if __name__ == "__main__":
    main()
