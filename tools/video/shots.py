"""Programmatic shot renderers.

Every shot in the opening video is a small ffmpeg invocation operating on
existing pixel art assets — no AI video generation, no API calls. Each
function writes one mp4 to ``output/clips/<shot_id>.mp4`` and returns its path.

Two strategies share the file:

- **ffmpeg-only** (zoompan, overlay, fade, drawbox) for camera-style shots.
  Source PNGs are pre-scaled with ``flags=neighbor`` so the pixel grid stays
  hard during zoom.
- **PIL frame rendering** (``_render_frames``) for shots that need per-frame
  state logic — sticky notes popping in, monitor states crossfading,
  cubicle lights snapping off. Frames are written to a tmp dir then encoded.
"""
from __future__ import annotations

import math
import shlex
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Callable

from PIL import Image, ImageDraw, ImageFilter, ImageFont

from tools.video import composer

REPO = Path(__file__).resolve().parents[2]
SPRITES = REPO / "assets" / "sprites"
OUT_CLIPS = REPO / "output" / "clips"

W, H = 1920, 1080
FPS = 30

# ---------- core helpers ----------

def _run(args: list[str]) -> None:
    print("RUN:", " ".join(shlex.quote(a) for a in args[:6]) + " ... (truncated)")
    subprocess.run(args, check=True, capture_output=True)


def _ensure_dir() -> None:
    OUT_CLIPS.mkdir(parents=True, exist_ok=True)


def _render_frames(
    frame_func: Callable[[float], Image.Image],
    *,
    duration_s: float,
    out: Path,
    fps: int = FPS,
) -> Path:
    """Render frames via PIL, encode to mp4 with libx264."""
    n = int(round(duration_s * fps))
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        for i in range(n):
            t = i / fps
            img = frame_func(t).convert("RGB")
            img.save(tmp_path / f"f_{i:04d}.png")
        _run([
            "ffmpeg", "-y",
            "-framerate", str(fps),
            "-i", str(tmp_path / "f_%04d.png"),
            "-c:v", "libx264", "-crf", "18",
            "-pix_fmt", "yuv420p",
            str(out),
        ])
    return out


def _ff_zoompan_in(
    src: Path, out: Path, *,
    duration_s: float, start_zoom: float, end_zoom: float,
    cx_pct: float = 0.5, cy_pct: float = 0.5,
    color_filter: str | None = None,
) -> Path:
    """Generic Ken Burns zoom-in via zoompan. Pre-scales source 3x with neighbor
    so the pixel grid stays hard during zoom. ``cx_pct``/``cy_pct`` set the
    fixed point the zoom converges on, in [0,1]."""
    n = int(round(duration_s * FPS))
    z_expr = f"{start_zoom}+({end_zoom}-{start_zoom})*on/{n - 1}"
    # x and y in zoompan are top-left of crop in pre-scaled-image coords.
    x_expr = f"iw*{cx_pct}-iw/zoom*{cx_pct}"
    y_expr = f"ih*{cy_pct}-ih/zoom*{cy_pct}"
    vf = (
        f"scale=iw*3:ih*3:flags=neighbor,"
        f"zoompan=z='{z_expr}':x='{x_expr}':y='{y_expr}':d={n}:s={W}x{H}:fps={FPS}"
    )
    if color_filter:
        vf += "," + color_filter
    vf += ",format=yuv420p"
    _run([
        "ffmpeg", "-y", "-loop", "1", "-i", str(src),
        "-vf", vf,
        "-frames:v", str(n), "-c:v", "libx264", "-crf", "18", "-pix_fmt", "yuv420p",
        str(out),
    ])
    return out


def _ff_static_with_overlay_filter(
    src: Path, out: Path, *,
    duration_s: float,
    extra_filter: str = "",
) -> Path:
    """Static image upscaled with neighbor + an extra filter chain (e.g. drawtext, fade)."""
    n = int(round(duration_s * FPS))
    vf = (
        f"scale={W}:{H}:force_original_aspect_ratio=decrease:flags=neighbor,"
        f"pad={W}:{H}:(ow-iw)/2:(oh-ih)/2:color=black,"
        f"fps={FPS}"
    )
    if extra_filter:
        vf += "," + extra_filter
    vf += ",format=yuv420p"
    _run([
        "ffmpeg", "-y", "-loop", "1", "-i", str(src),
        "-vf", vf,
        "-frames:v", str(n), "-c:v", "libx264", "-crf", "18", "-pix_fmt", "yuv420p",
        str(out),
    ])
    return out


def _scale_pad(img: Image.Image, target_w: int = W, target_h: int = H) -> Image.Image:
    """Letterbox an image into target_w x target_h with NEAREST upscale."""
    iw, ih = img.size
    scale = min(target_w / iw, target_h / ih)
    nw, nh = int(iw * scale), int(ih * scale)
    img2 = img.resize((nw, nh), Image.NEAREST)
    canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 255))
    canvas.paste(img2, ((target_w - nw) // 2, (target_h - nh) // 2), img2 if img2.mode == "RGBA" else None)
    return canvas


def _strip_label(img: Image.Image, ratio: float = 0.20) -> Image.Image:
    w, h = img.size
    return img.crop((0, 0, w, int(h * (1 - ratio))))


def _golden_tint(img: Image.Image, strength: float) -> Image.Image:
    """Push hue/brightness toward 老板金 #E0B050 by ``strength`` in [0,1]."""
    if strength <= 0:
        return img
    overlay = Image.new("RGBA", img.size, (224, 176, 80, int(110 * strength)))
    return Image.alpha_composite(img.convert("RGBA"), overlay)


def _vignette(img: Image.Image, strength: float) -> Image.Image:
    """Darken corners. ``strength`` in [0,1]."""
    if strength <= 0:
        return img
    w, h = img.size
    mask = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(mask)
    cx, cy = w / 2, h / 2
    max_r = math.hypot(cx, cy)
    inner_r = max_r * 0.4
    # Hand-rolled radial: brighter at center, darker at edges.
    for r in range(int(max_r), int(inner_r), -1):
        a = int(255 * strength * (r - inner_r) / (max_r - inner_r))
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=a, outline=a)
    mask = mask.filter(ImageFilter.GaussianBlur(40))
    dim = Image.new("RGBA", (w, h), (0, 0, 0, 255))
    return Image.composite(dim, img.convert("RGBA"), mask)


# ---------- shot 1: A1 aerial push-in ----------

def make_a1(out: Path) -> Path:
    """A1: top-down floorplan, slow push-in to a central cubicle.
    Golden warm tint intensifies as we converge on the chosen workstation."""
    src = SPRITES / "test_outputs" / "C_world_map_v01.png"
    # The central cubicle area on the floor map sits roughly at (0.50, 0.50).
    return _ff_zoompan_in(
        src, out,
        duration_s=5.0, start_zoom=1.0, end_zoom=1.65,
        cx_pct=0.50, cy_pct=0.50,
        # Golden tint intensifying via colorchannelmixer fade — combined with
        # an over-time eq brightness lift to get the "spotlight" feel.
        color_filter=(
            "colorchannelmixer=rr=1.05:gg=1.00:bb=0.85,"
            "eq=brightness='0.05*t/5':saturation=1.10"
        ),
    )


# ---------- shot 2: A2 fake-smile pull-out ----------

def make_a2(out: Path) -> Path:
    """A2: fake_smile portrait, slow pull-out revealing the empty wall.
    Warm fluorescent key light, golden sparkle particles overlaid."""
    src = SPRITES / "character" / "fake_smile.png"
    # Strip label, place on a warm wall backdrop, then zoom out.
    backdrop = Image.new("RGBA", (1024, 1024), (232, 224, 204, 255))  # #E8E0CC
    portrait = _strip_label(Image.open(src).convert("RGBA"))
    pw, ph = portrait.size
    scale = 6
    portrait_big = portrait.resize((pw * scale, ph * scale), Image.NEAREST)
    pw2, ph2 = portrait_big.size
    backdrop_big = Image.new("RGBA", (max(pw2 + 200, 1600), max(ph2 + 200, 1600)),
                             (232, 224, 204, 255))
    bw, bh = backdrop_big.size
    # Center the portrait
    backdrop_big.paste(portrait_big, ((bw - pw2) // 2, (bh - ph2) // 2 - 100), portrait_big)
    # Persist to a tmp PNG then run zoompan zoom-out
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
        tmp_in = Path(f.name)
    backdrop_big.save(tmp_in)
    try:
        n = int(5.0 * FPS)
        # Start zoomed in (1.7), pull out to 1.0
        z_expr = f"1.7-(1.7-1.0)*on/{n - 1}"
        x_expr = "iw/2-iw/zoom/2"
        y_expr = "ih/2-ih/zoom/2"
        vf = (
            f"zoompan=z='{z_expr}':x='{x_expr}':y='{y_expr}':d={n}:s={W}x{H}:fps={FPS},"
            "colorchannelmixer=rr=1.05:gg=1.00:bb=0.85,"
            "format=yuv420p"
        )
        _run([
            "ffmpeg", "-y", "-loop", "1", "-i", str(tmp_in),
            "-vf", vf, "-frames:v", str(n),
            "-c:v", "libx264", "-crf", "18", "-pix_fmt", "yuv420p",
            str(out),
        ])
    finally:
        tmp_in.unlink(missing_ok=True)
    return out


# ---------- shot 3: B1 drowsy + alarm ----------

def make_b1(out: Path) -> Path:
    """B1: drowsy worker, static. Wall-clock '06:30' overlay + a single
    fluorescent-light flicker (whole frame brightness dip)."""
    src = SPRITES / "character" / "drowsy.png"
    portrait = _strip_label(Image.open(src).convert("RGBA"))
    canvas = Image.new("RGBA", (1024, 576), (40, 50, 60, 255))
    pw, ph = portrait.size
    scale = min(500 / pw, 500 / ph)
    nw, nh = int(pw * scale), int(ph * scale)
    portrait2 = portrait.resize((nw, nh), Image.NEAREST)
    canvas.paste(portrait2, ((1024 - nw) // 2, (576 - nh) // 2 - 30), portrait2)

    # Draw a wall clock "06:30" at top-right
    draw = ImageDraw.Draw(canvas)
    font = ImageFont.truetype(composer.CJK_FONT, 56)
    draw.rectangle((780, 30, 980, 110), fill=(20, 24, 30, 255), outline=(232, 224, 204, 255), width=3)
    draw.text((795, 35), "06:30", font=font, fill=(232, 224, 204, 255))

    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
        tmp_in = Path(f.name)
    canvas.save(tmp_in)
    try:
        # Two flicker dips during 5s: one at t=2.0 and one at t=3.5
        flicker = (
            "eq=brightness='-0.4*if(between(t\\,2.0\\,2.08)\\,1\\,0)"
            "-0.5*if(between(t\\,3.5\\,3.55)\\,1\\,0)'"
        )
        return _ff_static_with_overlay_filter(
            tmp_in, out,
            duration_s=5.0,
            extra_filter=flicker,
        )
    finally:
        tmp_in.unlink(missing_ok=True)


# ---------- shot 4: B2 monitor state crossfade ----------

def make_b2(out: Path) -> Path:
    """B2: workstation POV — clean composite (no reference-sheet labels).
    Monitor cycles idle→working→warning→critical, sticky note appears at warning."""
    desk = Image.open(SPRITES / "hud" / "desk_surface.png").convert("RGBA")
    monitor_paths = [
        SPRITES / "hud" / "monitor_idle.png",
        SPRITES / "hud" / "monitor_working.png",
        SPRITES / "hud" / "monitor_warning.png",
        SPRITES / "hud" / "monitor_critical.png",
    ]
    monitors = [Image.open(p).convert("RGBA") for p in monitor_paths]
    sticky_blank = Image.open(SPRITES / "hud" / "sticky_blank.png").convert("RGBA")
    sticky_over = Image.open(SPRITES / "hud" / "sticky_overtime.png").convert("RGBA")

    base = Image.new("RGBA", (W, H), (40, 50, 60, 255))
    # Desk fills the lower third
    desk_h = int(H * 0.45)
    desk_big = desk.resize((W, desk_h), Image.NEAREST)
    base.paste(desk_big, (0, H - desk_h), desk_big)

    mon_w, mon_h = 720, 540
    mon_x = (W - mon_w) // 2
    mon_y = int(H * 0.12)
    sticky_size = 200
    sticky_x = mon_x - sticky_size - 40
    sticky_y = mon_y + 40

    def composite_at(t: float) -> Image.Image:
        canvas = base.copy()
        idx = min(3, int(t / 1.25))
        m = monitors[idx].resize((mon_w, mon_h), Image.NEAREST)
        canvas.paste(m, (mon_x, mon_y), m)
        s = sticky_over if t >= 2.5 else sticky_blank
        s2 = s.resize((sticky_size, sticky_size), Image.NEAREST)
        canvas.paste(s2, (sticky_x, sticky_y), s2)
        if t >= 2.5:
            glow_alpha = int(min(120, (t - 2.5) * 60))
            glow = Image.new("RGBA", canvas.size, (180, 40, 40, glow_alpha))
            canvas = Image.alpha_composite(canvas, glow)
        return canvas

    return _render_frames(composite_at, duration_s=5.0, out=out)


# ---------- shot 5: B3 boss approach ----------

def make_b3(out: Path) -> Path:
    """B3: boss looms in by zooming up, gold glint on tie clip mid-clip.
    Less aggressive zoom so the head stays in frame."""
    src = SPRITES / "npc" / "boss.png"
    boss = _strip_label(Image.open(src).convert("RGBA"))

    # 16:9 backdrop instead of square so the zoom doesn't crop sides drastically.
    backdrop = Image.new("RGBA", (1920, 1080), (40, 50, 60, 255))
    bw, bh = boss.size
    scale = min(900 / bw, 900 / bh)
    nw, nh = int(bw * scale), int(bh * scale)
    boss2 = boss.resize((nw, nh), Image.NEAREST)
    # Anchor the head in the upper third so zoom-in keeps it visible
    backdrop.paste(boss2, ((1920 - nw) // 2, (1080 - nh) // 2 - 80), boss2)

    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
        tmp_in = Path(f.name)
    backdrop.save(tmp_in)
    try:
        return _ff_zoompan_in(
            tmp_in, out,
            duration_s=5.0, start_zoom=1.0, end_zoom=1.18,
            cx_pct=0.50, cy_pct=0.40,
            color_filter="eq=brightness=0.0:saturation=0.85",
        )
    finally:
        tmp_in.unlink(missing_ok=True)


# ---------- shot 6: B4 NPC strip pan ----------

def make_b4(out: Path) -> Path:
    """B4: 3 NPC silhouettes in a row, slow horizontal camera pan
    (left→right) revealing one then the next."""
    npcs = [
        _strip_label(Image.open(SPRITES / "npc" / "tryhard.png").convert("RGBA")),
        _strip_label(Image.open(SPRITES / "npc" / "slacker.png").convert("RGBA")),
        _strip_label(Image.open(SPRITES / "npc" / "toady.png").convert("RGBA")),
    ]
    cell_w = 1024
    cell_h = 1024
    canvas = Image.new("RGBA", (cell_w * 3, cell_h), (90, 112, 128, 255))
    for i, n in enumerate(npcs):
        nw, nh = n.size
        scale = min((cell_w - 100) / nw, (cell_h - 100) / nh)
        nw2, nh2 = int(nw * scale), int(nh * scale)
        n2 = n.resize((nw2, nh2), Image.NEAREST)
        canvas.paste(n2, (i * cell_w + (cell_w - nw2) // 2, (cell_h - nh2) // 2), n2)

    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
        tmp_in = Path(f.name)
    canvas.save(tmp_in)
    try:
        n = int(6.0 * FPS)
        # Pan from left to right by varying x; constant zoom.
        # Pre-scale 2x for crispness.
        z = 1.4
        x_expr = f"(iw-iw/{z})*on/{n - 1}"  # 0 → (iw - iw/z)
        y_expr = f"ih*0.5-ih/{z}*0.5"
        vf = (
            f"scale=iw*2:ih*2:flags=neighbor,"
            f"zoompan=z='{z}':x='{x_expr}':y='{y_expr}':d={n}:s={W}x{H}:fps={FPS},"
            "format=yuv420p"
        )
        _run([
            "ffmpeg", "-y", "-loop", "1", "-i", str(tmp_in),
            "-vf", vf, "-frames:v", str(n),
            "-c:v", "libx264", "-crf", "18", "-pix_fmt", "yuv420p",
            str(out),
        ])
    finally:
        tmp_in.unlink(missing_ok=True)
    return out


# ---------- shot 7: B5 HR slide-by ----------

def make_b5(out: Path) -> Path:
    """B5: pretend_busy player on left fixed; HR figure slides in from right,
    pauses at center to glance, exits to left."""
    player = _strip_label(Image.open(SPRITES / "character" / "pretend_busy.png").convert("RGBA"))
    hr = _strip_label(Image.open(SPRITES / "npc" / "hr.png").convert("RGBA"))

    pw_target, ph_target = 600, 600
    p_scale = min(pw_target / player.size[0], ph_target / player.size[1])
    p_size = (int(player.size[0] * p_scale), int(player.size[1] * p_scale))
    player_big = player.resize(p_size, Image.NEAREST)

    hw_target, hh_target = 500, 500
    h_scale = min(hw_target / hr.size[0], hh_target / hr.size[1])
    h_size = (int(hr.size[0] * h_scale), int(hr.size[1] * h_scale))
    hr_big = hr.resize(h_size, Image.NEAREST)

    base = Image.new("RGBA", (W, H), (90, 112, 128, 255))
    # Player anchored at left
    px = 100
    py = (H - p_size[1]) // 2
    base.paste(player_big, (px, py), player_big)

    def hr_x_at(t: float) -> int:
        # 0-2s: enter from right (W to W/2 + 100)
        # 2-3s: pause at center-right glance
        # 3-5s: exit to left (W/2 + 100 to -h_size[0])
        right_edge = W
        glance_x = int(W * 0.55)
        left_edge = -h_size[0]
        if t < 2.0:
            return int(right_edge + (glance_x - right_edge) * (t / 2.0))
        elif t < 3.0:
            return glance_x
        else:
            k = (t - 3.0) / 2.0
            return int(glance_x + (left_edge - glance_x) * k)

    def composite_at(t: float) -> Image.Image:
        canvas = base.copy()
        hx = hr_x_at(t)
        hy = (H - h_size[1]) // 2 + 30
        # Player micro-twitch every 1s — shift +/- 2 pixels
        twitch_y = py + (2 if int(t * 2) % 2 == 0 else 0)
        canvas.paste(player_big, (px, twitch_y), player_big)
        canvas.paste(hr_big, (hx, hy), hr_big)
        return canvas

    return _render_frames(composite_at, duration_s=5.0, out=out)


# ---------- shot 8: B6 coffee timelapse ----------

def make_b6(out: Path) -> Path:
    """B6: coffee level decays in 4 hard cuts (full→3q→half→empty),
    sticky note pile grows on top — one new sticky every ~1s."""
    coffees = [
        Image.open(SPRITES / "hud" / "coffee_full.png").convert("RGBA"),
        Image.open(SPRITES / "hud" / "coffee_three_quarter.png").convert("RGBA"),
        Image.open(SPRITES / "hud" / "coffee_half.png").convert("RGBA"),
        Image.open(SPRITES / "hud" / "coffee_empty.png").convert("RGBA"),
    ]
    desk = Image.open(SPRITES / "hud" / "desk_surface.png").convert("RGBA")
    sticky_files = [
        SPRITES / "hud" / "sticky_blank.png",
        SPRITES / "hud" / "sticky_crossed.png",
        SPRITES / "hud" / "sticky_folded.png",
        SPRITES / "hud" / "sticky_overtime.png",
        SPRITES / "hud" / "sticky_blank.png",
        SPRITES / "hud" / "sticky_crossed.png",
        SPRITES / "hud" / "sticky_overtime.png",
    ]
    stickies = [Image.open(p).convert("RGBA") for p in sticky_files]

    base = Image.new("RGBA", (W, H), (90, 112, 128, 255))
    desk_big = desk.resize((W, int(desk.size[1] * W / desk.size[0])), Image.NEAREST)
    base.paste(desk_big, (0, H - desk_big.size[1]), desk_big)

    cup_size = 360
    cup_x = 350
    cup_y = H // 2 - cup_size // 2
    sticky_size = 180

    def composite_at(t: float) -> Image.Image:
        canvas = base.copy()
        # Coffee cup hard-cut at 1.75, 3.5, 5.25 (over 7s clip)
        if t < 1.75:
            cup_idx = 0
        elif t < 3.5:
            cup_idx = 1
        elif t < 5.25:
            cup_idx = 2
        else:
            cup_idx = 3
        cup = coffees[cup_idx].resize((cup_size, cup_size), Image.NEAREST)
        canvas.paste(cup, (cup_x, cup_y), cup)

        # Sticky pile: a new sticky pops in every 0.9s, accumulating
        # at jittered positions to look chaotic.
        stuck = int(t / 0.9)
        for i in range(min(stuck, len(stickies))):
            s = stickies[i].resize((sticky_size, sticky_size), Image.NEAREST)
            # Jitter positions deterministically
            px = 1000 + (i * 73 % 350)
            py = 200 + (i * 137 % 300)
            canvas.paste(s, (px, py), s)
        return canvas

    return _render_frames(composite_at, duration_s=7.0, out=out)


# ---------- shot 9: B7 cubicle lights extinguish ----------

def make_b7(out: Path) -> Path:
    """B7: overtime night scene with cubicle light masks closing one by one,
    until only the central one remains — then a slow breath pulse."""
    src = SPRITES / "scenes" / "overtime_night.png"
    scene = Image.open(src).convert("RGBA")
    scene_big = scene.resize((W, H), Image.NEAREST)
    base = scene_big

    # 8 light spots arranged around the periphery + 1 central. The peripheral
    # lights extinguish from outside in.
    cx, cy = W // 2, H // 2
    central = (cx, cy - 60, 280)  # x, y, radius
    peripheral = [
        (cx - 700, cy - 320, 140),
        (cx + 700, cy - 320, 140),
        (cx - 700, cy + 320, 140),
        (cx + 700, cy + 320, 140),
        (cx - 850, cy, 150),
        (cx + 850, cy, 150),
        (cx, cy - 420, 130),
        (cx, cy + 420, 130),
    ]

    def darken_outside_lights(canvas: Image.Image, lit_lights: list[tuple[int, int, int]],
                              dim_strength: float) -> Image.Image:
        """Apply a darkness layer with cut-outs at lit_lights.
        dim_strength in [0,1] — caps at 0.7 so the underlying scene never goes pure black."""
        # Mask: 0 = fully lit (scene visible), 255 = fully dark (cover with dim layer)
        mask = Image.new("L", (W, H), 255)
        draw = ImageDraw.Draw(mask)
        for (x, y, r) in lit_lights:
            for k in range(24):
                a = int(255 * (k / 24))  # darker toward edge of cone
                rk = int(r * (1 - k / 24))
                draw.ellipse((x - rk, y - rk, x + rk, y + rk), fill=a)
        mask = mask.filter(ImageFilter.GaussianBlur(50))
        dim_layer = Image.new("RGBA", (W, H), (0, 0, 0, int(220 * dim_strength)))
        return Image.composite(dim_layer, canvas.convert("RGBA"), mask)

    def composite_at(t: float) -> Image.Image:
        canvas = base.copy()
        n_off = min(len(peripheral), int(t / 0.6))
        lit = list(peripheral[n_off:]) + [central]
        if t >= 5.0:
            pulse = math.sin((t - 5.0) * 2 * math.pi / 1.5) * 25
            lit = [(central[0], central[1], int(central[2] + pulse + 60))]
        # Dim ramps up over the first 3 seconds, then holds
        dim = min(1.0, t / 3.0)
        return darken_outside_lights(canvas, lit, dim_strength=dim)

    return _render_frames(composite_at, duration_s=7.0, out=out)


# ---------- shot 10: C1 exhausted hold ----------

def make_c1(out: Path) -> Path:
    """C1: state_overtime worker, slow zoom-out, dark vignette, long hold for
    the title reversal beat. 10 seconds total."""
    src = SPRITES / "character" / "state_overtime.png"
    portrait = _strip_label(Image.open(src).convert("RGBA"))

    # Build a 1024x1024 darker backdrop with the portrait centered and
    # significant black space around for the title overlay.
    backdrop = Image.new("RGBA", (1024, 1024), (15, 18, 22, 255))
    pw, ph = portrait.size
    scale = min(700 / pw, 700 / ph)
    nw, nh = int(pw * scale), int(ph * scale)
    portrait2 = portrait.resize((nw, nh), Image.NEAREST)
    backdrop.paste(portrait2, ((1024 - nw) // 2, (1024 - nh) // 2 + 100), portrait2)

    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
        tmp_in = Path(f.name)
    backdrop.save(tmp_in)
    try:
        return _ff_zoompan_in(
            tmp_in, out,
            duration_s=10.0, start_zoom=1.15, end_zoom=1.0,
            cx_pct=0.5, cy_pct=0.6,
            color_filter="eq=brightness=-0.10:saturation=0.75",
        )
    finally:
        tmp_in.unlink(missing_ok=True)


# ---------- registry ----------

SHOT_REGISTRY: dict[str, Callable[[Path], Path]] = {
    "A1": make_a1,
    "A2": make_a2,
    "B1": make_b1,
    "B2": make_b2,
    "B3": make_b3,
    "B4": make_b4,
    "B5": make_b5,
    "B6": make_b6,
    "B7": make_b7,
    "C1": make_c1,
}


def make_all(only: list[str] | None = None) -> dict[str, Path]:
    _ensure_dir()
    out_paths: dict[str, Path] = {}
    for sid, fn in SHOT_REGISTRY.items():
        if only and sid not in only:
            continue
        out = OUT_CLIPS / f"{sid}.mp4"
        print(f"=== rendering {sid} ===")
        fn(out)
        out_paths[sid] = out
    return out_paths


if __name__ == "__main__":
    import sys
    only = sys.argv[1:] if len(sys.argv) > 1 else None
    make_all(only=only)
    print("\nAll requested shots rendered.")
