# 开场视频实施计划 — 《活过第 X 集》

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate a 60-second pixel-art opening video (`output/opening_v01.mp4`) by orchestrating 10 MiniMax Hailuo-2.3 image-to-video clips and stitching them with locally-rendered Chinese title overlays via ffmpeg.

**Architecture:** Three layers — (1) a thin MiniMax client with idempotent JSON state tracking under `output/.video_runs/`, (2) PIL helpers that compose first-frame inputs and render Chinese title PNGs (titles never go through the video model — too unstable), (3) an ffmpeg compose step that concatenates clips with overlay timings driven by a Python config dict.

**Tech Stack:** Python 3.12, `requests`, `Pillow`, ffmpeg 7.1, MiniMax `MiniMax-Hailuo-2.3` model, system font `/System/Library/Fonts/Hiragino Sans GB.ttc` for Chinese rendering.

**Spec:** `docs/superpowers/specs/2026-05-03-opening-video-design.md`

**Critical reference:** `assets/sprites/STYLE_GUIDE.md` § 1.1, 1.2 — every prompt must inject the SFC/16-bit + palette anchors verbatim or MiniMax will smooth the pixel art.

---

## File Structure

```
tools/video/
  __init__.py
  state.py              # JSON-backed RunState tracker per clip
  client.py             # MiniMax client: submit + poll + download (idempotent)
  composer.py           # PIL: first-frame composites + title PNGs + strikethrough sequence
  ffmpeg_compose.py     # Build & invoke the final ffmpeg compose command
  generate_all.py       # Orchestrator driver
  prompts/
    A1_aerial.txt
    A2_fake_smile.txt
    B1_alarm.txt
    B2_monitor.txt
    B3_boss_pass.txt
    B4_npc_pan.txt
    B5_hr_pass.txt
    B6_coffee_decay.txt
    B7_floor_lights_off.txt
    C1_static.txt

tests/video/
  test_state.py
  test_ffmpeg_compose.py

output/                 # gitignored
  composed_frames/      # PIL-built first-frames (A1, B2, B6, C1)
  clips/                # MiniMax downloads
  titles/               # PIL-rendered title PNGs
  opening_v01.mp4       # final
output/.video_runs/     # gitignored, per-clip state JSON
```

---

### Task 1: Scaffolding

**Files:**
- Create: `tools/video/__init__.py` (empty)
- Create: `tests/video/__init__.py` (empty)
- Create: `tools/video/requirements.txt`
- Modify: `.gitignore` — append `output/` block

- [ ] **Step 1: Create directory tree**

```bash
mkdir -p tools/video/prompts tests/video output/clips output/composed_frames output/titles output/.video_runs
```

- [ ] **Step 2: Write requirements file**

Path: `tools/video/requirements.txt`

```
requests>=2.32
Pillow>=10.0
```

- [ ] **Step 3: Append to `.gitignore`**

Append at end of `/Users/huanghaibin/Workspace/games/survived-episode-x/.gitignore`:

```
# === Opening video pipeline (tools/video) ===
/output/
```

- [ ] **Step 4: Verify deps installed**

Run: `python3 -c "import requests, PIL; print('ok')"`
Expected: `ok`

If missing, run: `pip3 install -r tools/video/requirements.txt`

- [ ] **Step 5: Commit**

```bash
git add tools/video/__init__.py tools/video/requirements.txt tests/video/__init__.py .gitignore
git commit -m "scaffold: tools/video pipeline dirs and deps"
```

---

### Task 2: RunState tracker (TDD)

**Files:**
- Create: `tools/video/state.py`
- Test: `tests/video/test_state.py`

The tracker is a JSON file per clip at `output/.video_runs/<clip_id>.json` storing fields: `clip_id`, `status` (`pending|submitted|polling|completed|failed`), `task_id`, `file_id`, `download_path`, `prompt`, `model`, `resolution`, `duration`, `cost_cny`, `attempts`, `last_error`, `created_at`, `updated_at`.

- [ ] **Step 1: Write failing tests**

Path: `tests/video/test_state.py`

```python
import json
from pathlib import Path

import pytest

from tools.video.state import RunState


def test_new_state_creates_file(tmp_path: Path):
    s = RunState.create(tmp_path, "A1", model="MiniMax-Hailuo-2.3", duration=6, resolution="1080P")
    assert s.status == "pending"
    assert (tmp_path / "A1.json").exists()
    data = json.loads((tmp_path / "A1.json").read_text())
    assert data["clip_id"] == "A1"
    assert data["attempts"] == 0


def test_load_existing(tmp_path: Path):
    RunState.create(tmp_path, "A1", model="m", duration=6, resolution="1080P")
    loaded = RunState.load(tmp_path, "A1")
    assert loaded.clip_id == "A1"


def test_mark_submitted_increments_attempts(tmp_path: Path):
    s = RunState.create(tmp_path, "A1", model="m", duration=6, resolution="1080P")
    s.mark_submitted("task-123", prompt="hi")
    assert s.status == "submitted"
    assert s.task_id == "task-123"
    assert s.attempts == 1
    reloaded = RunState.load(tmp_path, "A1")
    assert reloaded.task_id == "task-123"


def test_mark_completed(tmp_path: Path):
    s = RunState.create(tmp_path, "A1", model="m", duration=6, resolution="1080P")
    s.mark_submitted("t", prompt="p")
    s.mark_completed(file_id="f", download_path="output/clips/A1.mp4", cost_cny=4.5)
    assert s.status == "completed"
    assert s.cost_cny == 4.5


def test_is_completed_short_circuit(tmp_path: Path):
    s = RunState.create(tmp_path, "A1", model="m", duration=6, resolution="1080P")
    s.mark_submitted("t", prompt="p")
    s.mark_completed(file_id="f", download_path="x", cost_cny=4.5)
    assert RunState.load(tmp_path, "A1").is_completed()


def test_mark_failed(tmp_path: Path):
    s = RunState.create(tmp_path, "A1", model="m", duration=6, resolution="1080P")
    s.mark_submitted("t", prompt="p")
    s.mark_failed("api error 500")
    assert s.status == "failed"
    assert s.last_error == "api error 500"
```

- [ ] **Step 2: Run tests, expect import-error failures**

Run: `python3 -m pytest tests/video/test_state.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'tools.video.state'` or import error.

- [ ] **Step 3: Implement `tools/video/state.py`**

```python
"""Per-clip run state. JSON-backed, idempotent, safe to re-load."""
from __future__ import annotations

import json
import time
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Optional


@dataclass
class RunState:
    clip_id: str
    model: str
    duration: int
    resolution: str
    status: str = "pending"
    task_id: Optional[str] = None
    file_id: Optional[str] = None
    download_path: Optional[str] = None
    prompt: Optional[str] = None
    cost_cny: float = 0.0
    attempts: int = 0
    last_error: Optional[str] = None
    created_at: float = field(default_factory=time.time)
    updated_at: float = field(default_factory=time.time)

    _state_dir: Path = field(default=Path("."), repr=False)

    @classmethod
    def create(cls, state_dir: Path, clip_id: str, *, model: str, duration: int, resolution: str) -> "RunState":
        state_dir = Path(state_dir)
        state_dir.mkdir(parents=True, exist_ok=True)
        s = cls(clip_id=clip_id, model=model, duration=duration, resolution=resolution)
        s._state_dir = state_dir
        s._persist()
        return s

    @classmethod
    def load(cls, state_dir: Path, clip_id: str) -> "RunState":
        state_dir = Path(state_dir)
        path = state_dir / f"{clip_id}.json"
        data = json.loads(path.read_text())
        s = cls(**data)
        s._state_dir = state_dir
        return s

    @classmethod
    def load_or_create(cls, state_dir: Path, clip_id: str, *, model: str, duration: int, resolution: str) -> "RunState":
        path = Path(state_dir) / f"{clip_id}.json"
        if path.exists():
            return cls.load(state_dir, clip_id)
        return cls.create(state_dir, clip_id, model=model, duration=duration, resolution=resolution)

    def _persist(self) -> None:
        self.updated_at = time.time()
        data = {k: v for k, v in asdict(self).items() if not k.startswith("_")}
        (self._state_dir / f"{self.clip_id}.json").write_text(json.dumps(data, indent=2, ensure_ascii=False))

    def mark_submitted(self, task_id: str, *, prompt: str) -> None:
        self.task_id = task_id
        self.prompt = prompt
        self.status = "submitted"
        self.attempts += 1
        self._persist()

    def mark_polling(self) -> None:
        self.status = "polling"
        self._persist()

    def mark_completed(self, *, file_id: str, download_path: str, cost_cny: float) -> None:
        self.file_id = file_id
        self.download_path = download_path
        self.cost_cny = cost_cny
        self.status = "completed"
        self.last_error = None
        self._persist()

    def mark_failed(self, error: str) -> None:
        self.status = "failed"
        self.last_error = error
        self._persist()

    def is_completed(self) -> bool:
        return self.status == "completed"
```

- [ ] **Step 4: Run tests, expect pass**

Run: `python3 -m pytest tests/video/test_state.py -v`
Expected: 6 passed.

- [ ] **Step 5: Commit**

```bash
git add tools/video/state.py tests/video/test_state.py
git commit -m "feat(video): per-clip RunState tracker with JSON persistence"
```

---

### Task 3: First-frame compositor

Some clips need composite first-frame images that don't exist as single sprites:

| Clip | Composite needed |
|---|---|
| A1 | Use `assets/sprites/test_outputs/C_world_map_v01.png` directly (no compose) |
| A2 | Use `assets/sprites/character/fake_smile.png` directly |
| B1 | Use `assets/sprites/character/drowsy.png` directly |
| B2 | Compose: `hud/monitor_warning.png` as monitor, layered over a workstation backdrop crop from `J_hud_workstation_props_v01.png` |
| B3 | Use `assets/sprites/npc/boss.png` directly |
| B4 | Crop top-row 3-cell strip from `assets/sprites/test_outputs/A_npc_archetypes_v01.png` (rows of 3×3 grid → take the row containing tryhard, slacker, toady) |
| B5 | Compose: `character/pretend_busy.png` + `npc/hr.png` side-by-side |
| B6 | Compose: `hud/coffee_full.png` + `hud/sticky_overtime.png` on a desk surface |
| B7 | Use `assets/sprites/scenes/overtime_night.png` directly |
| C1 | Use `assets/sprites/character/state_overtime.png` centered on a black 1024×576 canvas |

**A_npc_archetypes_v01.png 行布局**: 1024×1024 grid. Spec assumes 3×3 rows of 341 px each. The actual row containing tryhard/slacker/toady will be verified by eye in Task 7's smoke test. If rows differ, adjust the crop in `composer.py`.

**Files:**
- Create: `tools/video/composer.py`

- [ ] **Step 1: Implement `tools/video/composer.py`**

```python
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


# ---------- First-frame composites ----------

def compose_b2_monitor() -> Path:
    """B2: workstation POV, warning monitor inset on a workstation backdrop."""
    _ensure_dirs()
    backdrop_src = SPRITES / "test_outputs" / "J_hud_workstation_props_v01.png"
    monitor_src = SPRITES / "hud" / "monitor_warning.png"
    canvas = Image.new("RGBA", (1024, 576), COLOR_DARK)
    backdrop = Image.open(backdrop_src).convert("RGBA")
    # Take a workstation crop (left half — tends to contain a single workstation in the J grid)
    bw, bh = backdrop.size
    crop = backdrop.crop((0, 0, bw // 2, bh // 2))
    _paste_centered(canvas, crop, (0, 0, 1024, 576))
    monitor = Image.open(monitor_src).convert("RGBA")
    _paste_centered(canvas, monitor, (350, 100, 700, 380))
    out = OUT_FRAMES / "B2_first.png"
    canvas.save(out)
    return out


def compose_b4_npc_strip() -> Path:
    """B4: 3-NPC horizontal strip from A_npc_archetypes_v01.png top row.

    The grid is 3x3 rows of ~341px. Row 0 (top): tryhard, slacker, toady.
    If the row mapping is wrong on visual check, adjust the y0/y1 below.
    """
    _ensure_dirs()
    src = Image.open(SPRITES / "test_outputs" / "A_npc_archetypes_v01.png").convert("RGBA")
    w, h = src.size
    row_h = h // 3
    strip = src.crop((0, 0, w, row_h))  # top row
    # Resize to 1024x576 letterboxed
    canvas = Image.new("RGBA", (1024, 576), COLOR_DARK)
    _paste_centered(canvas, strip, (0, 0, 1024, 576))
    out = OUT_FRAMES / "B4_first.png"
    canvas.save(out)
    return out


def compose_b5_hr_pass() -> Path:
    """B5: pretend_busy player on left, HR silhouette entering from right."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1024, 576), COLOR_BLUEGRAY)
    player = Image.open(SPRITES / "character" / "pretend_busy.png").convert("RGBA")
    hr = Image.open(SPRITES / "npc" / "hr.png").convert("RGBA")
    _paste_centered(canvas, player, (80, 80, 540, 530))
    _paste_centered(canvas, hr, (700, 80, 1000, 530))
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


def compose_c1_static() -> Path:
    """C1: state_overtime player centered on a near-black canvas with title space."""
    _ensure_dirs()
    canvas = Image.new("RGBA", (1024, 576), COLOR_DARK)
    p = Image.open(SPRITES / "character" / "state_overtime.png").convert("RGBA")
    _paste_centered(canvas, p, (320, 100, 700, 480))
    out = OUT_FRAMES / "C1_first.png"
    canvas.save(out)
    return out


def compose_all_first_frames() -> dict:
    """Build every composite that needs PIL. Returns map of clip_id -> first-frame path."""
    return {
        "B2": compose_b2_monitor(),
        "B4": compose_b4_npc_strip(),
        "B5": compose_b5_hr_pass(),
        "B6": compose_b6_coffee_sticky(),
        "C1": compose_c1_static(),
    }


# ---------- Title PNGs (rendered later in Task 7) ----------

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
    Sized to overlay across the fake title text."""
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
```

- [ ] **Step 2: Run as a script — verify all outputs land**

Run: `python3 -m tools.video.composer`
Expected: prints 5 composed_frames paths + 4 titles paths, all files exist.

Verify: `ls output/composed_frames output/titles`

- [ ] **Step 3: Eyeball the outputs**

Open `output/composed_frames/B2_first.png`, `B4_first.png`, `B5_first.png`, `B6_first.png`, `C1_first.png` and `output/titles/title_fake.png`, `title_real.png`, `subtitle.png`. Stop if anything is broken (wrong row crop, missing alpha, font not rendering Chinese).

If `B4_first.png` shows the wrong NPC row, adjust the crop in `compose_b4_npc_strip()` and re-run.

- [ ] **Step 4: Commit**

```bash
git add tools/video/composer.py
git commit -m "feat(video): PIL composer for first-frames and title PNGs"
```

---

### Task 4: MiniMax client (smoke-tested)

**Files:**
- Create: `tools/video/client.py`

The client takes a local image path, base64-encodes it as a data URI, submits an image-to-video task, polls, and downloads. State writes happen via `RunState`. **Cost is hard-coded at 5.0 CNY per 1080P 6s clip** for budget tracking — actual billing is via MiniMax dashboard, this is just for our local guardrail.

**Image input mechanism**: The MiniMax docs show `first_frame_image` accepting a public URL. Per their API reference, this field also accepts a **data URI** (`data:image/png;base64,...`). Step 4 of this task is a smoke test that confirms data-URI input is accepted; if it fails with an HTTP 4xx, fall back to the documented Files API upload path (see Step 5 fallback).

- [ ] **Step 1: Implement `tools/video/client.py`**

```python
"""MiniMax Hailuo-2.3 image-to-video client."""
from __future__ import annotations

import base64
import os
import time
from pathlib import Path
from typing import Optional

import requests

from tools.video.state import RunState

API_BASE = "https://api.minimaxi.com/v1"
DEFAULT_MODEL = "MiniMax-Hailuo-2.3"
COST_CNY_PER_CLIP = {("MiniMax-Hailuo-2.3", "1080P", 6): 5.0,
                     ("MiniMax-Hailuo-2.3", "1080P", 10): 8.0,
                     ("MiniMax-Hailuo-2.3", "768P", 6): 2.5}


class MiniMaxError(RuntimeError):
    pass


def _api_key() -> str:
    key = os.environ.get("MINIMAX_API_KEY")
    if not key:
        raise MiniMaxError("MINIMAX_API_KEY not set in env")
    return key


def _headers() -> dict:
    return {"Authorization": f"Bearer {_api_key()}", "Content-Type": "application/json"}


def _image_to_data_uri(path: Path) -> str:
    suffix = path.suffix.lower().lstrip(".")
    mime = {"png": "image/png", "jpg": "image/jpeg", "jpeg": "image/jpeg"}.get(suffix, "image/png")
    b64 = base64.b64encode(path.read_bytes()).decode("ascii")
    return f"data:{mime};base64,{b64}"


def submit_i2v(*, prompt: str, first_frame_path: Path, model: str, duration: int, resolution: str) -> str:
    payload = {
        "prompt": prompt,
        "first_frame_image": _image_to_data_uri(Path(first_frame_path)),
        "model": model,
        "duration": duration,
        "resolution": resolution,
    }
    r = requests.post(f"{API_BASE}/video_generation", headers=_headers(), json=payload, timeout=60)
    if r.status_code >= 400:
        raise MiniMaxError(f"submit failed {r.status_code}: {r.text[:500]}")
    data = r.json()
    if "task_id" not in data:
        raise MiniMaxError(f"no task_id in response: {data}")
    return data["task_id"]


def poll_until_done(task_id: str, *, timeout_s: int = 1200, interval_s: int = 10) -> str:
    """Poll until task succeeds. Returns file_id. Raises MiniMaxError on Fail or timeout."""
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        time.sleep(interval_s)
        r = requests.get(f"{API_BASE}/query/video_generation",
                         headers=_headers(), params={"task_id": task_id}, timeout=30)
        if r.status_code >= 400:
            raise MiniMaxError(f"poll failed {r.status_code}: {r.text[:300]}")
        data = r.json()
        status = data.get("status")
        print(f"  [poll] task {task_id} status={status}")
        if status == "Success":
            return data["file_id"]
        if status == "Fail":
            raise MiniMaxError(f"task failed: {data.get('error_message') or data}")
    raise MiniMaxError(f"poll timeout after {timeout_s}s")


def download_file(file_id: str, dest: Path) -> None:
    r = requests.get(f"{API_BASE}/files/retrieve", headers=_headers(),
                     params={"file_id": file_id}, timeout=30)
    if r.status_code >= 400:
        raise MiniMaxError(f"retrieve failed {r.status_code}: {r.text[:300]}")
    download_url = r.json()["file"]["download_url"]
    dest.parent.mkdir(parents=True, exist_ok=True)
    with requests.get(download_url, timeout=300, stream=True) as dl:
        dl.raise_for_status()
        with dest.open("wb") as fh:
            for chunk in dl.iter_content(1 << 16):
                fh.write(chunk)


def generate_clip(state: RunState, *, prompt: str, first_frame_path: Path,
                  output_dir: Path, max_attempts: int = 2) -> Optional[Path]:
    """Idempotent. If state is completed and the file exists on disk, returns its path.
    Otherwise submits, polls, and downloads. Bumps attempts on each submit."""
    output_dir = Path(output_dir)
    if state.is_completed() and state.download_path and Path(state.download_path).exists():
        print(f"[{state.clip_id}] already completed -> {state.download_path}")
        return Path(state.download_path)

    if state.attempts >= max_attempts:
        raise MiniMaxError(f"[{state.clip_id}] attempts ({state.attempts}) >= max ({max_attempts}); manual intervention needed")

    print(f"[{state.clip_id}] submitting (attempt {state.attempts + 1}/{max_attempts}) ...")
    try:
        task_id = submit_i2v(prompt=prompt, first_frame_path=first_frame_path,
                             model=state.model, duration=state.duration, resolution=state.resolution)
    except Exception as e:
        state.mark_failed(f"submit error: {e}")
        raise
    state.mark_submitted(task_id, prompt=prompt)
    state.mark_polling()
    try:
        file_id = poll_until_done(task_id)
    except Exception as e:
        state.mark_failed(f"poll error: {e}")
        raise

    dest = output_dir / f"{state.clip_id}.mp4"
    print(f"[{state.clip_id}] downloading file {file_id} -> {dest}")
    try:
        download_file(file_id, dest)
    except Exception as e:
        state.mark_failed(f"download error: {e}")
        raise

    cost = COST_CNY_PER_CLIP.get((state.model, state.resolution, state.duration), 5.0)
    state.mark_completed(file_id=file_id, download_path=str(dest), cost_cny=cost)
    print(f"[{state.clip_id}] done. cost ≈ ¥{cost}")
    return dest
```

- [ ] **Step 2: Smoke-test image input mechanism with one cheap clip**

Path: `tools/video/_smoke.py`

```python
"""Smoke test: submit one 768P 6s clip using a tiny PIL-generated image as
first_frame, just to verify data-URI image input is accepted."""
from pathlib import Path

from PIL import Image

from tools.video.client import generate_clip
from tools.video.state import RunState

REPO = Path(__file__).resolve().parents[2]


def main():
    # Tiny solid pixel art-ish frame
    img = Image.new("RGB", (768, 432), (90, 112, 128))
    out = REPO / "output" / "composed_frames" / "_smoke_first.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    state_dir = REPO / "output" / ".video_runs"
    state = RunState.load_or_create(state_dir, "_smoke",
                                    model="MiniMax-Hailuo-2.3", duration=6, resolution="768P")
    generate_clip(state, prompt="A static empty office cubicle, soft camera push-in, 16-bit pixel art, no anti-aliasing.",
                  first_frame_path=out, output_dir=REPO / "output" / "clips")


if __name__ == "__main__":
    main()
```

Run: `python3 -m tools.video._smoke`
Expected: completes in 5-15 minutes, prints `[_smoke] done. cost ≈ ¥2.5`, file `output/clips/_smoke.mp4` exists.

If it fails with HTTP 400 / "invalid first_frame_image", proceed to Step 3 fallback. Otherwise skip Step 3.

- [ ] **Step 3: (Fallback only — skip if smoke passed)** Switch to MiniMax Files API for image upload

If data-URI input is rejected, replace `_image_to_data_uri` usage in `submit_i2v` with a Files API upload that returns an `image_url`. Add this helper above `submit_i2v`:

```python
def upload_image(path: Path) -> str:
    files = {"file": open(path, "rb")}
    data = {"purpose": "video_generation"}
    r = requests.post(f"{API_BASE}/files/upload",
                      headers={"Authorization": f"Bearer {_api_key()}"},
                      files=files, data=data, timeout=120)
    if r.status_code >= 400:
        raise MiniMaxError(f"upload failed {r.status_code}: {r.text[:500]}")
    return r.json()["file"]["download_url"]
```

And change `submit_i2v` to call `"first_frame_image": upload_image(Path(first_frame_path))`. Re-run `_smoke`.

- [ ] **Step 4: Verify smoke clip is a valid mp4**

Run: `ffprobe -v error -show_entries stream=codec_type,width,height,duration -of default=nw=1 output/clips/_smoke.mp4`
Expected: codec_type=video, width=1280 or similar, duration around 6.0.

- [ ] **Step 5: Commit**

```bash
git add tools/video/client.py tools/video/_smoke.py
git commit -m "feat(video): MiniMax Hailuo-2.3 image-to-video client + smoke test"
```

---

### Task 5: Write 10 prompt files

Each prompt enforces the SFC/16-bit pixel-art lock and constrains motion to suit the clip's "route" from the spec (semi-cinematic for A1/A2, hard pixel-preserve for B1-B7, static-with-zoom for C1).

**Files:**
- Create: `tools/video/prompts/A1_aerial.txt`
- Create: `tools/video/prompts/A2_fake_smile.txt`
- Create: `tools/video/prompts/B1_alarm.txt`
- Create: `tools/video/prompts/B2_monitor.txt`
- Create: `tools/video/prompts/B3_boss_pass.txt`
- Create: `tools/video/prompts/B4_npc_pan.txt`
- Create: `tools/video/prompts/B5_hr_pass.txt`
- Create: `tools/video/prompts/B6_coffee_decay.txt`
- Create: `tools/video/prompts/B7_floor_lights_off.txt`
- Create: `tools/video/prompts/C1_static.txt`

- [ ] **Step 1: Write A1_aerial.txt**

```
Animate this top-down pixel art office floorplan with a slow, smooth cinematic camera push-in.

CAMERA: Begin wide on the entire floor map; over 6 seconds, push smoothly inward and downward toward a single central cubicle. End on a medium-tight framing of that one cubicle.

LIGHTING: Add a warm golden bloom from above, as if a heavenly spotlight is descending on the chosen cubicle. The bloom intensifies as the camera pushes in. Other cubicles remain dimmer.

MOTION: Camera move only. Do not animate any character or object inside the floorplan.

STYLE LOCK:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- Limited 16-color palette dominated by 格子间灰蓝 #5A7080 with 老板金 #E0B050 accent
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add new text, characters, or props
```

- [ ] **Step 2: Write A2_fake_smile.txt**

```
Animate this pixel art office worker with a polished, promo-video feel.

CAMERA: Start tight on the worker's face. Over 6 seconds, slowly pull out (dolly back) to reveal the empty wall behind him.

CHARACTER MOTION: A subtle, unwavering forced smile. One single eye-blink at around frame 70. No other body motion.

LIGHTING: Warm fluorescent key light on the face. As the camera pulls out, the light reveals the wall is empty — no awards, no certificates, just a blank cubicle wall.

STYLE LOCK:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- Limited 16-color palette: 打工人黄 #C8A85A skin, 格子间灰蓝 #5A7080 wall, 白炽灯白 #E8E0CC light pool
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add new characters, props, awards, or text
```

- [ ] **Step 3: Write B1_alarm.txt**

```
Animate this drowsy pixel art office worker with very restrained motion.

CAMERA: Static. No camera movement.

CHARACTER MOTION:
- The character slowly rubs his eye with one hand once during the 6 seconds.
- His head tilts down by 1-2 pixels then settles back.
- A thin column of steam rises 2 pixels from a thermos cup if visible.

LIGHTING: Cold morning light, dim 格子间灰蓝 #5A7080 ambience. A single dim overhead fluorescent flickers once around frame 50.

STYLE LOCK:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add new characters, props, alarm clocks, or text not present in the source
```

- [ ] **Step 4: Write B2_monitor.txt**

```
Animate this pixel art workstation POV with a tense, escalating screen-state shift.

CAMERA: Very slow push-in toward the monitor over 6 seconds. Total push under 10% zoom.

MOTION:
- The monitor screen begins glowing 屏幕蓝 #2C4A6E.
- At around frame 50, the monitor flickers and shifts to a red warning state.
- A single typing-finger taps a key once during the clip.
- Otherwise the workstation is still.

STYLE LOCK:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- Limited 16-color palette: keep all surfaces in 格子间灰蓝 #5A7080 / 档案室棕 #7A5838 / monitor 屏幕蓝→red shift
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add new characters, props, or text
```

- [ ] **Step 5: Write B3_boss_pass.txt**

```
Animate this pixel art office boss passing behind the player's workstation.

CAMERA: Static. No camera movement.

MOTION: The boss silhouette walks slowly from screen-right to screen-left across the back of the frame, taking the full 6 seconds. As he passes the center of the frame, he pauses for one frame. The boss is rendered slightly darker — a near-silhouette, threatening, in 格子间灰蓝 #5A7080 with a 老板金 #E0B050 tie-clip glint visible for 1 frame as he pauses.

If a player figure is present, the player remains completely still — frozen — throughout the clip.

STYLE LOCK:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- Limited 16-color palette
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add new characters, props, or text
```

- [ ] **Step 6: Write B4_npc_pan.txt**

```
Animate this pixel art horizontal strip of three office NPCs (tryhard, slacker, toady) with a steady left-to-right camera pan.

CAMERA: Slow horizontal pan from left to right across the strip over 6 seconds. End centered on the third NPC (toady).

PER-NPC MICRO-MOTION as the camera passes each one:
- NPC 1 (tryhard, leftmost): types furiously, eye bags pronounced, single mouth-tight grimace
- NPC 2 (slacker, middle): leans back, phone reflection on face flickers once
- NPC 3 (toady, right): hands clasped, head nods agreeably twice

STYLE LOCK:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- Limited 16-color palette
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add new characters, props, or text
```

- [ ] **Step 7: Write B5_hr_pass.txt**

```
Animate this pixel art scene where an HR figure walks past the player's workstation.

CAMERA: Static.

MOTION:
- The HR character (right side) walks slowly leftward across the frame over 5 seconds, exits frame at left.
- Around frame 60, HR pauses briefly, glances toward the player, then resumes walking.
- The player (left, already in pretend-busy posture) does not move at all — a single key-press finger micro-twitch is acceptable.

STYLE LOCK:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- HR's empty-frame glasses (no lenses) silhouette must remain visible
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add new characters, props, or text
```

- [ ] **Step 8: Write B6_coffee_decay.txt**

```
Animate this pixel art desktop scene as a 6-second time-decay collage.

CAMERA: Static, locked-off.

MOTION:
- The coffee cup level drops in three discrete jumps (full → 3/4 → half → empty), each transition is a hard cut at frames 60, 90, 120.
- The single overtime sticky note is joined by additional sticky notes that pop into the frame in stop-motion (one new sticky every ~30 frames, accumulating to a chaotic stack by frame 144).
- Each new sticky lands with no anti-aliasing — a hard pixel pop.

STYLE LOCK:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- Color palette dominated by 档案室棕 #7A5838 desk + 白炽灯白 #E8E0CC paper + 格子间灰蓝 #5A7080
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add characters, hands, or text on stickies (the OCR will fail)
```

- [ ] **Step 9: Write B7_floor_lights_off.txt**

This clip is generated at duration=10 (then ffmpeg trims to 8s).

```
Animate this pixel art overtime night scene as the floor empties around a single remaining worker.

CAMERA: Very slow pull-back / zoom-out over 10 seconds, revealing more cubicles.

MOTION:
- Office overhead fluorescent lights extinguish one by one, in waves, from the periphery inward.
- By frame 200, only ONE cubicle's lamp remains lit — the central one with the worker.
- The remaining lit cubicle pulses faintly at the end (one breath cycle).
- No characters move; only the lights change state.

LIGHTING: Final 屏幕蓝 #2C4A6E night ambience with the single 白炽灯白 #E8E0CC pool from the lone lit lamp.

STYLE LOCK:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add new characters or text
```

- [ ] **Step 10: Write C1_static.txt**

```
Animate this pixel art exhausted office worker with near-zero motion, designed to receive a title overlay during post-processing.

CAMERA: Very slow pull-back zoom-out over 6 seconds. Total pull under 15%.

MOTION:
- The worker breathes once (chest rises and falls) during the clip.
- One single eye-blink at the end.
- No other motion.

LIGHTING: A single dim 白炽灯白 #E8E0CC overhead pool on the worker; everything else fades to near-black 格子间灰蓝 #5A7080. Strong vignette toward the corners — leave the upper-center area dimmer than the worker, since a Chinese title will be overlaid there in post.

STYLE LOCK:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add any text into the frame — title is added in post
- Do NOT add new characters or props
```

- [ ] **Step 11: Commit**

```bash
git add tools/video/prompts/
git commit -m "feat(video): 10 storyboard prompts with style-lock anchors"
```

---

### Task 6: Orchestrator driver

**Files:**
- Create: `tools/video/generate_all.py`

The driver iterates a CLIP_SPECS list, calls `generate_clip` per item, prints a budget summary at the end. Idempotent: re-running skips completed clips. CLI flag `--draft` runs at 768P first, default is 1080P.

- [ ] **Step 1: Implement `tools/video/generate_all.py`**

```python
"""Orchestrate generation of all 10 storyboard clips."""
from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

from tools.video import composer
from tools.video.client import generate_clip
from tools.video.state import RunState

REPO = Path(__file__).resolve().parents[2]
SPRITES = REPO / "assets" / "sprites"
PROMPTS = REPO / "tools" / "video" / "prompts"
CLIPS_OUT = REPO / "output" / "clips"
STATE_DIR = REPO / "output" / ".video_runs"


@dataclass
class ClipSpec:
    clip_id: str
    prompt_file: str
    duration: int
    # First-frame: either an absolute path or a callable that returns one.
    first_frame: Callable[[], Path] | Path


def _direct(p: Path) -> Callable[[], Path]:
    return lambda: p


CLIP_SPECS = [
    ClipSpec("A1", "A1_aerial.txt", 6, _direct(SPRITES / "test_outputs" / "C_world_map_v01.png")),
    ClipSpec("A2", "A2_fake_smile.txt", 6, _direct(SPRITES / "character" / "fake_smile.png")),
    ClipSpec("B1", "B1_alarm.txt", 6, _direct(SPRITES / "character" / "drowsy.png")),
    ClipSpec("B2", "B2_monitor.txt", 6, composer.compose_b2_monitor),
    ClipSpec("B3", "B3_boss_pass.txt", 6, _direct(SPRITES / "npc" / "boss.png")),
    ClipSpec("B4", "B4_npc_pan.txt", 6, composer.compose_b4_npc_strip),
    ClipSpec("B5", "B5_hr_pass.txt", 6, composer.compose_b5_hr_pass),
    ClipSpec("B6", "B6_coffee_decay.txt", 6, composer.compose_b6_coffee_sticky),
    ClipSpec("B7", "B7_floor_lights_off.txt", 10, _direct(SPRITES / "scenes" / "overtime_night.png")),
    ClipSpec("C1", "C1_static.txt", 6, composer.compose_c1_static),
]


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--draft", action="store_true", help="generate at 768P (cheap drafts)")
    p.add_argument("--only", action="append", default=[], help="restrict to these clip_ids (repeatable)")
    p.add_argument("--budget-cap", type=float, default=60.0, help="hard cap in CNY; abort if exceeded")
    args = p.parse_args()

    resolution = "768P" if args.draft else "1080P"
    total_cost = 0.0

    for spec in CLIP_SPECS:
        if args.only and spec.clip_id not in args.only:
            continue
        prompt = (PROMPTS / spec.prompt_file).read_text(encoding="utf-8")
        first_frame = spec.first_frame() if callable(spec.first_frame) else spec.first_frame
        if not Path(first_frame).exists():
            raise FileNotFoundError(f"[{spec.clip_id}] missing first frame: {first_frame}")

        state = RunState.load_or_create(STATE_DIR, spec.clip_id,
                                        model="MiniMax-Hailuo-2.3",
                                        duration=spec.duration,
                                        resolution=resolution)
        if state.is_completed() and state.resolution != resolution:
            # Resolution mismatch — caller wants a regen at a new res. Reset state.
            print(f"[{spec.clip_id}] resolution change ({state.resolution} -> {resolution}); resetting state")
            state = RunState.create(STATE_DIR, spec.clip_id,
                                    model="MiniMax-Hailuo-2.3",
                                    duration=spec.duration,
                                    resolution=resolution)

        try:
            generate_clip(state, prompt=prompt, first_frame_path=Path(first_frame),
                          output_dir=CLIPS_OUT)
        except Exception as e:
            print(f"[{spec.clip_id}] FAILED: {e}")
            continue

        total_cost += state.cost_cny
        if total_cost > args.budget_cap:
            raise SystemExit(f"BUDGET CAP HIT at ¥{total_cost:.2f} (cap ¥{args.budget_cap:.2f})")

    print(f"\nTotal cost so far: ¥{total_cost:.2f}")


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Generate first-frame composites**

Run: `python3 -m tools.video.composer`
Expected: 5 PNGs in `output/composed_frames/`, 4+ in `output/titles/`.

- [ ] **Step 3: First draft pass at 768P**

Run: `python3 -m tools.video.generate_all --draft`
Expected: 10 clips in `output/clips/A1.mp4` … `C1.mp4`, total cost printed ≈ ¥25.

If any clip fails, the driver continues to the next. Re-run the same command to retry only failed/non-completed clips (idempotent).

- [ ] **Step 4: Eyeball draft clips**

Open each of the 10 mp4s and judge: composition right? motion sane? pixel grid preserved (especially B1-B7)?

For any that need a fix:
1. Edit the prompt file in `tools/video/prompts/`.
2. Delete its state file: `rm output/.video_runs/<clip_id>.json` and clip: `rm output/clips/<clip_id>.mp4`.
3. Re-run: `python3 -m tools.video.generate_all --draft --only <clip_id>`

Iterate until all 10 drafts are passable. Stop here for user review checkpoint.

- [ ] **Step 5: Promote to 1080P final pass**

Once drafts approved, force regeneration at 1080P:

```bash
rm output/.video_runs/*.json
rm output/clips/*.mp4
python3 -m tools.video.generate_all
```

Or selectively per-clip with `--only`. The driver auto-resets state on resolution change.

Expected: 10 1080P clips, total cost ≈ ¥50.

- [ ] **Step 6: Commit driver + any prompt iterations**

```bash
git add tools/video/generate_all.py tools/video/prompts/
git commit -m "feat(video): orchestrator driver with draft/final modes and budget cap"
```

---

### Task 7: ffmpeg compose pipeline

**Files:**
- Create: `tools/video/ffmpeg_compose.py`
- Test: `tests/video/test_ffmpeg_compose.py`

The compose script:
1. Trims each clip to its target duration (A1/A2 trim to 5s from 6s; B7 trim to 8s from 10s; rest pass through).
2. Inserts a 1-frame white flash between A2 and B1.
3. Concatenates all 10 clips with hard cuts.
4. Overlays `title_fake.png` at 0:00 with fade-in and shake-fade-out per the spec timing table.
5. At 0:54, adds the strike-through animation followed by `title_real.png`.
6. Adds `subtitle.png` at 0:58.
7. Re-encodes to 1920x1080 h264 at 30fps.

**Approach:** Use a single ffmpeg invocation with a `-filter_complex` graph rather than chaining multiple ffmpeg calls — simpler reasoning about timestamps.

We TDD only the **command-builder** (a pure function returning the filter graph + arg list), not the actual ffmpeg run.

- [ ] **Step 1: Write failing test for command-builder**

Path: `tests/video/test_ffmpeg_compose.py`

```python
from pathlib import Path

from tools.video.ffmpeg_compose import build_compose_args


def test_build_compose_args_includes_all_inputs(tmp_path: Path):
    clips = {
        "A1": tmp_path / "A1.mp4", "A2": tmp_path / "A2.mp4",
        "B1": tmp_path / "B1.mp4", "B2": tmp_path / "B2.mp4",
        "B3": tmp_path / "B3.mp4", "B4": tmp_path / "B4.mp4",
        "B5": tmp_path / "B5.mp4", "B6": tmp_path / "B6.mp4",
        "B7": tmp_path / "B7.mp4", "C1": tmp_path / "C1.mp4",
    }
    titles = {
        "fake": tmp_path / "title_fake.png",
        "real": tmp_path / "title_real.png",
        "subtitle": tmp_path / "subtitle.png",
    }
    out = tmp_path / "out.mp4"
    args = build_compose_args(clips=clips, titles=titles, output=out)

    # Every clip path appears as an -i input
    for p in clips.values():
        assert str(p) in args
    for p in titles.values():
        assert str(p) in args

    # Output file at end
    assert args[-1] == str(out)
    # H264 + 30fps
    assert "libx264" in args
    assert "30" in args
```

- [ ] **Step 2: Run test, expect import error**

Run: `python3 -m pytest tests/video/test_ffmpeg_compose.py -v`
Expected: FAIL — `ModuleNotFoundError: tools.video.ffmpeg_compose`

- [ ] **Step 3: Implement `tools/video/ffmpeg_compose.py`**

```python
"""Build and run the final ffmpeg compose command.

Timeline (seconds):
  0.0 - 5.0   A1 (trim 0-5)
  5.0 - 10.0  A2 (trim 0-5)
  10.0 - 16.0 B1
  16.0 - 22.0 B2
  22.0 - 28.0 B3
  28.0 - 34.0 B4
  34.0 - 40.0 B5
  40.0 - 46.0 B6
  46.0 - 54.0 B7 (trim 1-9 from 10s source)
  54.0 - 60.0 C1

Title overlays (RGBA PNGs, full 1920x1080 canvas alignment via x/y):
  0.0  - 8.0    title_fake fade in/hold (top-right area)
  8.0  - 10.0   title_fake shake & fade out
  54.0 - 56.0   title_fake reappears center (frozen frame style)
  56.0 - 57.0   strikethrough sweep across title_fake
  57.0 - 58.0   crossfade title_fake → title_real (center)
  58.0 - 60.0   subtitle fade in below title_real

Hard cuts between all clips. Optional: white flash 1 frame between A2 and B1.
"""
from __future__ import annotations

import shlex
import subprocess
from pathlib import Path
from typing import Mapping, Sequence

W, H = 1920, 1080
FPS = 30

# Per-clip timeline: (start, end, source-trim-start, source-trim-end)
SEGMENTS = [
    ("A1",  0.0,  5.0, 0.0, 5.0),
    ("A2",  5.0, 10.0, 0.0, 5.0),
    ("B1", 10.0, 16.0, 0.0, 6.0),
    ("B2", 16.0, 22.0, 0.0, 6.0),
    ("B3", 22.0, 28.0, 0.0, 6.0),
    ("B4", 28.0, 34.0, 0.0, 6.0),
    ("B5", 34.0, 40.0, 0.0, 6.0),
    ("B6", 40.0, 46.0, 0.0, 6.0),
    ("B7", 46.0, 54.0, 1.0, 9.0),
    ("C1", 54.0, 60.0, 0.0, 6.0),
]


def build_compose_args(*, clips: Mapping[str, Path], titles: Mapping[str, Path],
                       output: Path) -> list[str]:
    """Return the full ffmpeg argv for the final compose."""
    args: list[str] = ["ffmpeg", "-y"]

    # Inputs: clips first (indexes 0..9), then titles (10, 11, 12)
    clip_order = [seg[0] for seg in SEGMENTS]
    for cid in clip_order:
        args += ["-i", str(clips[cid])]
    args += ["-i", str(titles["fake"])]
    args += ["-i", str(titles["real"])]
    args += ["-i", str(titles["subtitle"])]

    # Filter graph
    parts: list[str] = []

    # Trim + scale every clip to 1920x1080@30fps, reset PTS
    for idx, (cid, _start, _end, ts, te) in enumerate(SEGMENTS):
        parts.append(
            f"[{idx}:v]trim={ts}:{te},setpts=PTS-STARTPTS,"
            f"scale={W}:{H}:force_original_aspect_ratio=decrease,"
            f"pad={W}:{H}:(ow-iw)/2:(oh-ih)/2:color=black,"
            f"fps={FPS}[v{idx}]"
        )
    # Concat
    concat_in = "".join(f"[v{i}]" for i in range(len(SEGMENTS)))
    parts.append(f"{concat_in}concat=n={len(SEGMENTS)}:v=1:a=0[base]")

    # Title overlays
    fake_idx, real_idx, sub_idx = 10, 11, 12

    # Fake title: top-right, fade in 0-1s, hold to 8s, fade out 8-10s.
    parts.append(
        f"[{fake_idx}:v]format=rgba,fade=t=in:st=0:d=1:alpha=1,"
        f"fade=t=out:st=8:d=2:alpha=1[fake_top]"
    )
    parts.append("[base][fake_top]overlay=x=W-w-60:y=40:enable='between(t,0,10)'[v_after_fake_top]")

    # Fake title at center, 54-57s (during the title-reversal beat)
    parts.append(
        f"[{fake_idx}:v]format=rgba,fade=t=in:st=0:d=0.5:alpha=1[fake_center]"
    )
    parts.append("[v_after_fake_top][fake_center]overlay=x=(W-w)/2:y=(H-h)/2-100:enable='between(t,54,57)'[v_after_fake_center]")

    # Strikethrough: a hard horizontal red line that grows. Use ffmpeg's drawbox
    # (we don't need PIL frames for this — drawbox + animated width is simpler).
    parts.append(
        "[v_after_fake_center]drawbox=x=(W-1200)/2:y=(H/2)-90:"
        "w='if(between(t,56,57), (t-56)*1200, 0)':h=14:color=red@0.95:t=fill"
        ":enable='between(t,56,57.2)'[v_after_strike]"
    )

    # Real title: center, fades in 57-58, holds to end.
    parts.append(
        f"[{real_idx}:v]format=rgba,fade=t=in:st=0:d=1:alpha=1[real_in]"
    )
    parts.append("[v_after_strike][real_in]overlay=x=(W-w)/2:y=(H-h)/2-50:enable='between(t,57,60)'[v_after_real]")

    # Subtitle: below title_real, fades in 58-59, holds to end.
    parts.append(
        f"[{sub_idx}:v]format=rgba,fade=t=in:st=0:d=1:alpha=1[sub_in]"
    )
    parts.append("[v_after_real][sub_in]overlay=x=(W-w)/2:y=(H-h)/2+100:enable='between(t,58,60)'[vout]")

    args += ["-filter_complex", ";".join(parts), "-map", "[vout]"]
    args += ["-r", str(FPS), "-c:v", "libx264", "-pix_fmt", "yuv420p",
             "-preset", "medium", "-crf", "18", "-an"]
    args.append(str(output))
    return args


def run_compose(*, clips: Mapping[str, Path], titles: Mapping[str, Path], output: Path) -> None:
    args = build_compose_args(clips=clips, titles=titles, output=output)
    print("RUN:", " ".join(shlex.quote(a) for a in args))
    output.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(args, check=True)


def main():
    repo = Path(__file__).resolve().parents[2]
    clips_dir = repo / "output" / "clips"
    titles_dir = repo / "output" / "titles"
    out = repo / "output" / "opening_v01.mp4"

    clips = {seg[0]: clips_dir / f"{seg[0]}.mp4" for seg in SEGMENTS}
    for cid, p in clips.items():
        if not p.exists():
            raise SystemExit(f"missing clip: {p} (run generate_all first)")
    titles = {
        "fake": titles_dir / "title_fake.png",
        "real": titles_dir / "title_real.png",
        "subtitle": titles_dir / "subtitle.png",
    }
    for tk, tp in titles.items():
        if not tp.exists():
            raise SystemExit(f"missing title: {tp} (run composer.render_all_titles first)")

    run_compose(clips=clips, titles=titles, output=out)
    print(f"\nWrote {out}")


if __name__ == "__main__":
    main()
```

- [ ] **Step 4: Run unit test, expect pass**

Run: `python3 -m pytest tests/video/test_ffmpeg_compose.py -v`
Expected: 1 passed.

- [ ] **Step 5: Commit**

```bash
git add tools/video/ffmpeg_compose.py tests/video/test_ffmpeg_compose.py
git commit -m "feat(video): ffmpeg compose pipeline with title overlay timeline"
```

---

### Task 8: Final compose + verify

- [ ] **Step 1: Render titles**

Run: `python3 -c "from tools.video import composer; composer.render_all_titles()"`
Expected: `output/titles/title_fake.png`, `title_real.png`, `subtitle.png` exist.

- [ ] **Step 2: Compose final video**

Run: `python3 -m tools.video.ffmpeg_compose`
Expected: ffmpeg runs (~30s), `output/opening_v01.mp4` exists.

- [ ] **Step 3: Verify mp4 metadata**

Run: `ffprobe -v error -show_entries format=duration:stream=codec_type,width,height,r_frame_rate -of default=nw=1 output/opening_v01.mp4`
Expected:
- duration ≈ 60.0
- width=1920, height=1080
- codec_type=video
- r_frame_rate=30/1

- [ ] **Step 4: Visual verification (manual)**

Open `output/opening_v01.mp4` in QuickTime / mpv. Confirm against the spec verification checklist (§9):
- [ ] 60s total
- [ ] All 10 storyboard beats visible in order
- [ ] "优秀员工·第 N 集" appears top-right at 0:00, fades out by 0:10
- [ ] "活过第 X 集" appears center near 0:57 with strikethrough preceding
- [ ] Subtitle "Survive Episode X · 你的 KPI 是不要被开" appears at 0:58
- [ ] Pixel art is preserved in B1-B7 (no obvious smoothing)
- [ ] Hard cuts between segments

If something is off:
- Title timing: edit `SEGMENTS` constants or overlay `enable='between(t,…,…)'` clauses, re-run compose. No regen needed.
- Bad clip: regenerate per Task 6 Step 4 procedure, then re-run compose.

- [ ] **Step 5: Total cost check**

Run:
```bash
python3 -c "
import json, glob
total = sum(json.load(open(f))['cost_cny'] for f in glob.glob('output/.video_runs/*.json') if 'smoke' not in f)
print(f'Total cost: ¥{total:.2f}')
"
```
Expected: ≤ ¥60. If higher, document in commit message.

- [ ] **Step 6: Final commit**

```bash
git add -A
git commit -m "video: opening_v01 — 60s pixel-art opening with title-reversal beat"
```

Note: `output/` is gitignored, so the commit will only include code/prompt iterations (if any). The mp4 itself stays local.

---

## Self-Review

**Spec coverage check:**
- §2 Three-act arc → Tasks 5+6+7 cover it
- §3 10-shot storyboard → Task 5 (prompts), Task 6 (driver) — every clip ID has a prompt file and a CLIP_SPECS entry ✓
- §4 Prompt template → Task 5 enforces style-lock pattern across all 10 prompts ✓
- §5 Title overlay timing → Task 7 SEGMENTS + filter graph timestamps match spec table ✓
- §6 Failure fallback (768P draft, 2-attempt cap, Ken Burns) → Task 4 (max_attempts), Task 6 (--draft mode). Ken Burns fallback is implicit (post-task-6 manual recourse), not coded — acceptable since the spec marks it as a manual-recourse fallback.
- §7 File structure → Tasks 1-7 lay it down exactly as specified ✓
- §8 Budget cap → Task 6 `--budget-cap` flag ✓
- §9 Verification → Task 8 step-by-step ✓
- §10 Out of scope (no audio) → ffmpeg uses `-an` ✓

**Type/name consistency:**
- `RunState.create / load / load_or_create / mark_submitted / mark_completed / is_completed` — same names used in client.py and generate_all.py ✓
- `compose_b2_monitor / compose_b4_npc_strip / compose_b5_hr_pass / compose_b6_coffee_sticky / compose_c1_static` — all referenced in CLIP_SPECS ✓
- `render_title_fake / render_title_real / render_subtitle / render_strikethrough_sequence / render_all_titles` — render_all_titles called in Task 8 Step 1 ✓
- `build_compose_args / run_compose` — both defined and used ✓
- Title PNG keys (`fake`, `real`, `subtitle`) — same in `render_all_titles` return dict and `ffmpeg_compose.main` ✓

**Placeholder scan:** No "TBD"/"TODO"; all code blocks complete; no "similar to Task N" deferrals. ✓
