"""PIL helpers: first-frame compositors + title PNG renderers."""
from __future__ import annotations

from pathlib import Path
from typing import Tuple

from PIL import Image, ImageDraw, ImageFont

REPO = Path(__file__).resolve().parents[2]
SPRITES = REPO / "assets" / "sprites"
OUT_FRAMES = REPO / "output" / "composed_frames"
OUT_TITLES = REPO / "output" / "titles"

CJK_FONT = "/System/Library/Fonts/Hiragino Sans GB.ttc"

# Palette from STYLE_GUIDE.md §1.2
COLOR_GOLD = (224, 176, 80, 255)        # 老板金 #E0B050
COLOR_WHITE = (232, 224, 204, 255)      # 白炽灯白 #E8E0CC
COLOR_BLUEGRAY = (90, 112, 128, 255)    # 格子间灰蓝 #5A7080
COLOR_DARK = (20, 24, 30, 255)
COLOR_RED = (180, 40, 40, 255)


def _ensure_dirs() -> None:
    OUT_FRAMES.mkdir(parents=True, exist_ok=True)
    OUT_TITLES.mkdir(parents=True, exist_ok=True)


def _paste_centered(canvas: Image.Image, img: Image.Image, box: Tuple[int, int, int, int]) -> None:
    """Paste img centered into the box (x0, y0, x1, y1) on canvas, preserving aspect."""
    bw, bh = box[2] - box[0], box[3] - box[1]
    iw, ih = img.size
    scale = min(bw / iw, bh / ih)
    nw, nh = int(iw * scale), int(ih * scale)
    img2 = img.resize((nw, nh), Image.NEAREST)
    px = box[0] + (bw - nw) // 2
    py = box[1] + (bh - nh) // 2
    canvas.paste(img2, (px, py), img2 if img2.mode == "RGBA" else None)


def _strip_label(img: Image.Image, bottom_ratio: float = 0.20) -> Image.Image:
    """Crop the bottom `bottom_ratio` of an image — used to remove the N.角色名 label band
    baked into character/npc card sprites."""
    w, h = img.size
    return img.crop((0, 0, w, int(h * (1 - bottom_ratio))))


def _load_unlabeled(path: Path, bottom_ratio: float = 0.20) -> Image.Image:
    return _strip_label(Image.open(path).convert("RGBA"), bottom_ratio=bottom_ratio)


# ---------- First-frame composites ----------
#
# Every clip uses a composer (no raw sprite paths) because all character/NPC sprites
# come with a baked-in "N.角色名" label band that would confuse MiniMax. The composers
# crop those bands and place subjects against scene-appropriate backdrops.

def compose_a1_aerial() -> Path:
    """A1: top-down office floorplan, full-bleed."""
    _ensure_dirs()
    src = Image.open(SPRITES / "test_outputs" / "C_world_map_v01.png").convert("RGBA")
    canvas = Image.new("RGBA", (1024, 576), COLOR_DARK)
    _paste_centered(canvas, src, (0, 0, 1024, 576))
    out = OUT_FRAMES / "A1_first.png"
    canvas.save(out)
    return out


def compose_a2_fake_smile() -> Path:
    """A2: fake smile portrait centered, label band stripped."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1024, 576), COLOR_BLUEGRAY)
    p = _load_unlabeled(SPRITES / "character" / "fake_smile.png")
    _paste_centered(canvas, p, (300, 60, 720, 540))
    out = OUT_FRAMES / "A2_first.png"
    canvas.save(out)
    return out


def compose_b1_drowsy() -> Path:
    """B1: drowsy worker portrait centered, label band stripped."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1024, 576), COLOR_DARK)
    p = _load_unlabeled(SPRITES / "character" / "drowsy.png")
    _paste_centered(canvas, p, (300, 60, 720, 540))
    out = OUT_FRAMES / "B1_first.png"
    canvas.save(out)
    return out


def compose_b2_monitor() -> Path:
    """B2: workstation POV, warning monitor inset on a workstation backdrop."""
    _ensure_dirs()
    backdrop_src = SPRITES / "test_outputs" / "J_hud_workstation_props_v01.png"
    monitor_src = SPRITES / "hud" / "monitor_warning.png"
    canvas = Image.new("RGBA", (1024, 576), COLOR_DARK)
    backdrop = Image.open(backdrop_src).convert("RGBA")
    bw, bh = backdrop.size
    crop = backdrop.crop((0, 0, bw // 2, bh // 2))
    _paste_centered(canvas, crop, (0, 0, 1024, 576))
    monitor = Image.open(monitor_src).convert("RGBA")
    _paste_centered(canvas, monitor, (350, 100, 700, 380))
    out = OUT_FRAMES / "B2_first.png"
    canvas.save(out)
    return out


def compose_b3_boss_pass() -> Path:
    """B3: boss silhouette centered, label band stripped, dim backdrop."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1024, 576), COLOR_DARK)
    boss = _load_unlabeled(SPRITES / "npc" / "boss.png")
    _paste_centered(canvas, boss, (250, 40, 770, 540))
    out = OUT_FRAMES / "B3_first.png"
    canvas.save(out)
    return out


def compose_b4_npc_strip() -> Path:
    """B4: 3-NPC horizontal strip composed from individual sprites (label-stripped).

    Order: tryhard (left), slacker (center), toady (right) — per STYLE_GUIDE.md §1.4.
    """
    _ensure_dirs()
    canvas = Image.new("RGBA", (1024, 576), COLOR_BLUEGRAY)
    npcs = [
        _load_unlabeled(SPRITES / "npc" / "tryhard.png"),
        _load_unlabeled(SPRITES / "npc" / "slacker.png"),
        _load_unlabeled(SPRITES / "npc" / "toady.png"),
    ]
    cell_w = 1024 // 3
    for i, npc in enumerate(npcs):
        _paste_centered(canvas, npc, (i * cell_w + 10, 60, (i + 1) * cell_w - 10, 540))
    out = OUT_FRAMES / "B4_first.png"
    canvas.save(out)
    return out


def compose_b5_hr_pass() -> Path:
    """B5: pretend_busy player on left, HR on right (both label-stripped)."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1024, 576), COLOR_BLUEGRAY)
    player = _load_unlabeled(SPRITES / "character" / "pretend_busy.png")
    hr = _load_unlabeled(SPRITES / "npc" / "hr.png")
    _paste_centered(canvas, player, (60, 80, 460, 530))
    _paste_centered(canvas, hr, (560, 80, 980, 530))
    out = OUT_FRAMES / "B5_first.png"
    canvas.save(out)
    return out


def compose_b6_coffee_sticky() -> Path:
    """B6: full coffee + overtime sticky note on a desk-surface backdrop."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1024, 576), COLOR_BLUEGRAY)
    desk = Image.open(SPRITES / "hud" / "desk_surface.png").convert("RGBA")
    _paste_centered(canvas, desk, (0, 200, 1024, 576))
    coffee = Image.open(SPRITES / "hud" / "coffee_full.png").convert("RGBA")
    _paste_centered(canvas, coffee, (180, 100, 460, 480))
    sticky = Image.open(SPRITES / "hud" / "sticky_overtime.png").convert("RGBA")
    _paste_centered(canvas, sticky, (560, 120, 880, 440))
    out = OUT_FRAMES / "B6_first.png"
    canvas.save(out)
    return out


def compose_b7_overtime() -> Path:
    """B7: overtime night scene, full-bleed."""
    _ensure_dirs()
    src = Image.open(SPRITES / "scenes" / "overtime_night.png").convert("RGBA")
    canvas = Image.new("RGBA", (1024, 576), COLOR_DARK)
    _paste_centered(canvas, src, (0, 0, 1024, 576))
    out = OUT_FRAMES / "B7_first.png"
    canvas.save(out)
    return out


def compose_c1_static() -> Path:
    """C1: state_overtime player centered on a near-black canvas with title space."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1024, 576), COLOR_DARK)
    p = _load_unlabeled(SPRITES / "character" / "state_overtime.png")
    _paste_centered(canvas, p, (320, 100, 700, 480))
    out = OUT_FRAMES / "C1_first.png"
    canvas.save(out)
    return out


def compose_all_first_frames() -> dict:
    return {
        "A1": compose_a1_aerial(),
        "A2": compose_a2_fake_smile(),
        "B1": compose_b1_drowsy(),
        "B2": compose_b2_monitor(),
        "B3": compose_b3_boss_pass(),
        "B4": compose_b4_npc_strip(),
        "B5": compose_b5_hr_pass(),
        "B6": compose_b6_coffee_sticky(),
        "B7": compose_b7_overtime(),
        "C1": compose_c1_static(),
    }


# ---------- Title PNGs ----------

def _stroke_text(draw: ImageDraw.ImageDraw, xy, text: str, font, fill, stroke_fill, stroke_width: int = 4) -> None:
    x, y = xy
    for dx in range(-stroke_width, stroke_width + 1):
        for dy in range(-stroke_width, stroke_width + 1):
            if dx == 0 and dy == 0:
                continue
            draw.text((x + dx, y + dy), text, font=font, fill=stroke_fill)
    draw.text((x, y), text, font=font, fill=fill)


def render_title_fake() -> Path:
    """优秀员工·第 N 集 — golden, fake promo title."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1920, 240), (0, 0, 0, 0))
    font = ImageFont.truetype(CJK_FONT, 96)
    draw = ImageDraw.Draw(canvas)
    text = "优秀员工·第 N 集"
    bbox = font.getbbox(text)
    tx = (canvas.width - (bbox[2] - bbox[0])) // 2
    ty = 60
    _stroke_text(draw, (tx, ty), text, font, COLOR_GOLD, COLOR_DARK, stroke_width=5)
    out = OUT_TITLES / "title_fake.png"
    canvas.save(out)
    return out


def render_title_real() -> Path:
    """活过第 X 集 — real title in white."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1920, 240), (0, 0, 0, 0))
    font = ImageFont.truetype(CJK_FONT, 128)
    draw = ImageDraw.Draw(canvas)
    text = "活过第 X 集"
    bbox = font.getbbox(text)
    tx = (canvas.width - (bbox[2] - bbox[0])) // 2
    ty = 40
    _stroke_text(draw, (tx, ty), text, font, COLOR_WHITE, COLOR_DARK, stroke_width=6)
    out = OUT_TITLES / "title_real.png"
    canvas.save(out)
    return out


def render_subtitle() -> Path:
    """Survive Episode X · 你的 KPI 是不要被开."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1920, 120), (0, 0, 0, 0))
    font = ImageFont.truetype(CJK_FONT, 40)
    draw = ImageDraw.Draw(canvas)
    text = "Survive Episode X  ·  你的 KPI 是不要被开"
    bbox = font.getbbox(text)
    tx = (canvas.width - (bbox[2] - bbox[0])) // 2
    ty = 30
    _stroke_text(draw, (tx, ty), text, font, COLOR_WHITE, COLOR_DARK, stroke_width=3)
    out = OUT_TITLES / "subtitle.png"
    canvas.save(out)
    return out


def render_strikethrough_sequence(frames: int = 12) -> list[Path]:
    """A horizontal red strikethrough that grows from 0% to 100% width over `frames` frames.
    Note: the final ffmpeg compose uses drawbox for the actual animated stroke (cleaner timing
    than overlaying a sequence). This sequence renderer is kept as a fallback."""
    _ensure_dirs()
    paths = []
    width, height = 1200, 240
    line_y = 130
    line_thickness = 12
    for i in range(frames):
        canvas = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        draw = ImageDraw.Draw(canvas)
        progress = (i + 1) / frames
        x_end = int(width * progress)
        draw.rectangle(
            [(0, line_y - line_thickness // 2), (x_end, line_y + line_thickness // 2)],
            fill=COLOR_RED,
        )
        out = OUT_TITLES / f"strike_{i:02d}.png"
        canvas.save(out)
        paths.append(out)
    return paths


def render_all_titles() -> dict:
    return {
        "fake": render_title_fake(),
        "real": render_title_real(),
        "subtitle": render_subtitle(),
        "strike_frames": render_strikethrough_sequence(12),
    }


if __name__ == "__main__":
    frames = compose_all_first_frames()
    titles = render_all_titles()
    print("Composed first-frames:")
    for k, v in frames.items():
        print(f"  {k}: {v}")
    print("Rendered titles:")
    for k, v in titles.items():
        print(f"  {k}: {v}")
