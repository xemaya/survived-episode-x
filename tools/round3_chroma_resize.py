#!/usr/bin/env python3
"""W5 round-3 post-processing: white BG → alpha, bbox crop, resize to 64×96 + 32×48.

Reads from design/concepts/p5-assets/round3_<id>.png (1024×1024 source from gpt-image-2).
Outputs:
  - assets/sprites/test_outputs/round3_<id>_portrait.png   (64×96, tagged with round3_ prefix for staging)
  - assets/sprites/test_outputs/round3_<id>_sprite.png     (32×48 LOD 0)
  - assets/sprites/npc/<id>.png                            (64×96 production)
  - assets/sprites/npc/<id>_sprite.png                     (32×48 production LOD 0)

Run from project root: python3 tools/round3_chroma_resize.py
"""
import sys
from pathlib import Path
from PIL import Image
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "design/concepts/p5-assets"
TEST_OUT = ROOT / "assets/sprites/test_outputs"
NPC_OUT = ROOT / "assets/sprites/npc"

# 9 NPC ids per round-3 handoff
NPC_IDS = [
    "lisa", "david", "wang_director", "vivian", "zoe",
    "lao_zhou", "li_ayi", "mama", "it_xiaoma",
]

# White-threshold for chroma-keying. Pixels with min(R,G,B) >= THRESHOLD become alpha=0.
# 245 leaves room for gpt-image-2 noise (BG isn't always exactly #FFFFFF) while
# preserving white-ish character details (e.g. badge highlights, paper accents).
WHITE_THRESHOLD = 245

# Padding in source pixels around bbox before resizing — gives a tiny breathing room.
BBOX_PAD = 20


def chroma_key_white(img: Image.Image) -> Image.Image:
    """Convert near-white pixels to transparent alpha. Returns RGBA image."""
    rgba = img.convert("RGBA")
    arr = np.array(rgba)
    rgb_min = arr[..., :3].min(axis=2)
    is_bg = rgb_min >= WHITE_THRESHOLD
    arr[is_bg, 3] = 0
    return Image.fromarray(arr, mode="RGBA")


def crop_to_content(img: Image.Image, pad: int = BBOX_PAD) -> Image.Image:
    """Crop image to alpha bbox + padding. Returns cropped RGBA image."""
    arr = np.array(img)
    alpha = arr[..., 3]
    rows = np.any(alpha > 0, axis=1)
    cols = np.any(alpha > 0, axis=0)
    if not rows.any() or not cols.any():
        return img
    y0, y1 = np.where(rows)[0][[0, -1]]
    x0, x1 = np.where(cols)[0][[0, -1]]
    h, w = arr.shape[:2]
    y0 = max(0, y0 - pad)
    y1 = min(h - 1, y1 + pad)
    x0 = max(0, x0 - pad)
    x1 = min(w - 1, x1 + pad)
    return img.crop((x0, y0, x1 + 1, y1 + 1))


def fit_to_canvas(img: Image.Image, target_w: int, target_h: int) -> Image.Image:
    """Fit content into target canvas, preserving aspect ratio. Letterbox with alpha."""
    src_w, src_h = img.size
    src_ratio = src_w / src_h
    tgt_ratio = target_w / target_h
    if src_ratio > tgt_ratio:
        # Source wider than target — fit by width
        new_w = target_w
        new_h = max(1, int(round(target_w / src_ratio)))
    else:
        # Source taller than target — fit by height
        new_h = target_h
        new_w = max(1, int(round(target_h * src_ratio)))
    resized = img.resize((new_w, new_h), Image.LANCZOS)
    canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    paste_x = (target_w - new_w) // 2
    paste_y = (target_h - new_h) // 2
    canvas.paste(resized, (paste_x, paste_y), resized)
    return canvas


def process_one(npc_id: str) -> bool:
    src_path = SRC / f"round3_{npc_id}.png"
    if not src_path.exists():
        print(f"  ⚠ source missing: {src_path.relative_to(ROOT)}")
        return False
    img = Image.open(src_path)
    keyed = chroma_key_white(img)
    cropped = crop_to_content(keyed)

    portrait = fit_to_canvas(cropped, 64, 96)
    sprite = fit_to_canvas(cropped, 32, 48)

    TEST_OUT.mkdir(parents=True, exist_ok=True)
    NPC_OUT.mkdir(parents=True, exist_ok=True)

    # Test outputs (staging)
    portrait.save(TEST_OUT / f"round3_{npc_id}_portrait.png")
    sprite.save(TEST_OUT / f"round3_{npc_id}_sprite.png")

    # Production paths
    portrait.save(NPC_OUT / f"{npc_id}.png")
    sprite.save(NPC_OUT / f"{npc_id}_sprite.png")

    print(f"  ✓ {npc_id}: portrait {portrait.size}, sprite {sprite.size} (cropped {cropped.size} from 1024)")
    return True


def main() -> int:
    ok = 0
    for npc_id in NPC_IDS:
        if process_one(npc_id):
            ok += 1
    print(f"\n=== {ok}/{len(NPC_IDS)} NPCs processed ===")
    return 0 if ok == len(NPC_IDS) else 1


if __name__ == "__main__":
    sys.exit(main())
