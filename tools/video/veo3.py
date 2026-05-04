"""DeerAPI Veo3 client + opening-video shot definitions.

Each Veo3 clip is exactly 8 seconds and accepts a single reference image
plus a natural-language prompt. The opening video uses 7 generated clips
(56s) plus a 4s ffmpeg tpad of the final clip's last frame to land on 60s.

Pipeline:
  1. ``render_first_frames()`` builds composite reference PNGs in ``output/composed_frames/``
  2. ``render_all_clips()`` submits one Veo3 task per shot, polls, downloads to ``output/clips/<id>.mp4``
  3. ``ffmpeg_compose`` stitches them with title overlays

State is tracked per-clip in ``output/.video_runs/<id>.json`` so reruns
skip completed shots.
"""
from __future__ import annotations

import argparse
import base64
import json
import os
import time
from dataclasses import dataclass, field
from pathlib import Path

import requests
from PIL import Image

from tools.video import composer

REPO = Path(__file__).resolve().parents[2]
SPRITES = REPO / "assets" / "sprites"
OUT_CLIPS = REPO / "output" / "clips"
OUT_FRAMES = REPO / "output" / "composed_frames"
STATE_DIR = REPO / "output" / ".video_runs"

API_BASE = "https://api.deerapi.com/v1"
DEFAULT_MODEL = "veo3-fast"  # veo3 / veo3-fast / veo3-pro / veo3.1 / veo3.1-pro
SIZE = "16x9"
POLL_INTERVAL_S = 15
POLL_TIMEOUT_S = 1200


# ---------- API client ----------

class Veo3Error(RuntimeError):
    pass


def _api_key() -> str:
    key = os.environ.get("DEERAPI_KEY")
    if not key:
        raise Veo3Error("DEERAPI_KEY not set in env")
    return key


def submit(*, prompt: str, ref_path: Path, model: str = DEFAULT_MODEL,
           size: str = SIZE) -> str:
    """POST /v1/videos with multipart form. Returns task_id."""
    headers = {"Authorization": f"Bearer {_api_key()}"}
    with open(ref_path, "rb") as fh:
        files = {"input_reference": (ref_path.name, fh, "image/png")}
        data = {"prompt": prompt, "model": model, "size": size}
        r = requests.post(f"{API_BASE}/videos", headers=headers,
                          files=files, data=data, timeout=120)
    if r.status_code >= 400:
        raise Veo3Error(f"submit {r.status_code}: {r.text[:500]}")
    j = r.json()
    tid = j.get("id")
    if not tid:
        raise Veo3Error(f"no id in response: {j}")
    return tid


def query(task_id: str) -> dict:
    headers = {"Authorization": f"Bearer {_api_key()}"}
    r = requests.get(f"{API_BASE}/videos/{task_id}", headers=headers, timeout=30)
    if r.status_code >= 400:
        raise Veo3Error(f"query {r.status_code}: {r.text[:300]}")
    return r.json()


def poll_until_done(task_id: str, *, label: str = "") -> str:
    """Poll until status == 'completed'. Returns video_url. Raises on failure / timeout."""
    deadline = time.time() + POLL_TIMEOUT_S
    last_status = ""
    while time.time() < deadline:
        try:
            j = query(task_id)
        except Veo3Error as e:
            # Transient SSL or 5xx — retry after a short wait.
            print(f"  [{label}] query error: {e}; retrying ...")
            time.sleep(POLL_INTERVAL_S)
            continue
        status = j.get("status", "?")
        progress = j.get("progress", "")
        if status != last_status:
            print(f"  [{label}] status={status} progress={progress}")
            last_status = status
        if status == "completed":
            url = j.get("video_url")
            if not url:
                raise Veo3Error(f"completed without video_url: {j}")
            return url
        if status in ("failed", "error"):
            raise Veo3Error(f"task failed: {j}")
        time.sleep(POLL_INTERVAL_S)
    raise Veo3Error(f"poll timeout after {POLL_TIMEOUT_S}s")


def download(url: str, dest: Path, *, max_retries: int = 3) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    last_err = None
    for attempt in range(max_retries):
        try:
            with requests.get(url, timeout=300, stream=True) as r:
                r.raise_for_status()
                with dest.open("wb") as fh:
                    for chunk in r.iter_content(1 << 16):
                        fh.write(chunk)
            return
        except Exception as e:  # noqa: BLE001 — surface network flakes
            last_err = e
            print(f"  download attempt {attempt + 1} failed: {e}")
            time.sleep(5)
    raise Veo3Error(f"download exhausted retries: {last_err}")


# ---------- per-shot state ----------

@dataclass
class ShotState:
    shot_id: str
    model: str
    prompt: str
    status: str = "pending"  # pending | submitted | polling | completed | failed
    task_id: str | None = None
    video_url: str | None = None
    download_path: str | None = None
    last_error: str | None = None
    created_at: float = field(default_factory=time.time)
    updated_at: float = field(default_factory=time.time)

    @classmethod
    def load_or_new(cls, shot_id: str, *, model: str, prompt: str) -> "ShotState":
        path = STATE_DIR / f"{shot_id}.json"
        if path.exists():
            data = json.loads(path.read_text())
            return cls(**data)
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        s = cls(shot_id=shot_id, model=model, prompt=prompt)
        s._persist()
        return s

    def _persist(self) -> None:
        self.updated_at = time.time()
        path = STATE_DIR / f"{self.shot_id}.json"
        path.write_text(json.dumps(self.__dict__, indent=2, ensure_ascii=False))


# ---------- shot driver ----------

def run_shot(shot_id: str, *, prompt: str, ref_path: Path,
             model: str = DEFAULT_MODEL) -> Path:
    """Idempotent: skip if completed and file exists."""
    OUT_CLIPS.mkdir(parents=True, exist_ok=True)
    state = ShotState.load_or_new(shot_id, model=model, prompt=prompt)
    out = OUT_CLIPS / f"{shot_id}.mp4"

    if state.status == "completed" and out.exists():
        print(f"[{shot_id}] already done -> {out}")
        return out

    # Submit (or reuse existing task_id if mid-flight)
    if not state.task_id:
        print(f"[{shot_id}] submitting ...")
        try:
            tid = submit(prompt=prompt, ref_path=ref_path, model=model)
        except Exception as e:
            state.status = "failed"
            state.last_error = f"submit: {e}"
            state._persist()
            raise
        state.task_id = tid
        state.status = "submitted"
        state._persist()

    # Poll
    state.status = "polling"
    state._persist()
    try:
        url = poll_until_done(state.task_id, label=shot_id)
    except Exception as e:
        state.status = "failed"
        state.last_error = f"poll: {e}"
        state._persist()
        raise
    state.video_url = url

    # Download
    print(f"[{shot_id}] downloading ...")
    try:
        download(url, out)
    except Exception as e:
        state.status = "failed"
        state.last_error = f"download: {e}"
        state._persist()
        raise
    state.download_path = str(out)
    state.status = "completed"
    state._persist()
    print(f"[{shot_id}] done -> {out}")
    return out


# ---------- first-frame composers ----------

def _strip_label(img: Image.Image, ratio: float = 0.20) -> Image.Image:
    w, h = img.size
    return img.crop((0, 0, w, int(h * (1 - ratio))))


def _paste_centered(canvas: Image.Image, img: Image.Image, box: tuple[int, int, int, int]) -> None:
    bw, bh = box[2] - box[0], box[3] - box[1]
    iw, ih = img.size
    scale = min(bw / iw, bh / ih)
    nw, nh = int(iw * scale), int(ih * scale)
    img2 = img.resize((nw, nh), Image.NEAREST)
    canvas.paste(img2, (box[0] + (bw - nw) // 2, box[1] + (bh - nh) // 2),
                 img2 if img2.mode == "RGBA" else None)


def _save_ref(name: str, img: Image.Image) -> Path:
    OUT_FRAMES.mkdir(parents=True, exist_ok=True)
    out = OUT_FRAMES / f"{name}.png"
    img.convert("RGB").save(out)
    return out


def ref_s1_aerial() -> Path:
    return _save_ref("S1_aerial", Image.open(SPRITES / "test_outputs" / "C_world_map_v01.png").convert("RGBA"))


def ref_s2_fake_smile() -> Path:
    portrait = _strip_label(Image.open(SPRITES / "character" / "fake_smile.png").convert("RGBA"))
    canvas = Image.new("RGBA", (1024, 768), (232, 224, 204, 255))
    _paste_centered(canvas, portrait, (260, 80, 760, 700))
    return _save_ref("S2_fake_smile", canvas)


def ref_s3_workstation() -> Path:
    """Drowsy player at a workstation with a warning monitor."""
    drowsy = _strip_label(Image.open(SPRITES / "character" / "drowsy.png").convert("RGBA"))
    monitor = Image.open(SPRITES / "hud" / "monitor_warning.png").convert("RGBA")
    desk = Image.open(SPRITES / "hud" / "desk_surface.png").convert("RGBA")
    canvas = Image.new("RGBA", (1024, 768), (40, 50, 60, 255))
    desk_h = int(desk.size[1] * 1024 / desk.size[0])
    desk2 = desk.resize((1024, desk_h), Image.NEAREST)
    canvas.paste(desk2, (0, 768 - desk_h), desk2)
    _paste_centered(canvas, monitor, (350, 80, 700, 420))
    _paste_centered(canvas, drowsy, (50, 250, 300, 700))
    return _save_ref("S3_workstation", canvas)


def ref_s4_boss_pass() -> Path:
    """Boss looming behind, with two NPC silhouettes flanking."""
    boss = _strip_label(Image.open(SPRITES / "npc" / "boss.png").convert("RGBA"))
    tryhard = _strip_label(Image.open(SPRITES / "npc" / "tryhard.png").convert("RGBA"))
    slacker = _strip_label(Image.open(SPRITES / "npc" / "slacker.png").convert("RGBA"))
    canvas = Image.new("RGBA", (1024, 768), (40, 50, 60, 255))
    _paste_centered(canvas, tryhard, (40, 200, 320, 700))
    _paste_centered(canvas, boss, (340, 100, 700, 720))
    _paste_centered(canvas, slacker, (720, 200, 1000, 700))
    return _save_ref("S4_boss_pass", canvas)


def ref_s5_hr_pass() -> Path:
    player = _strip_label(Image.open(SPRITES / "character" / "pretend_busy.png").convert("RGBA"))
    hr = _strip_label(Image.open(SPRITES / "npc" / "hr.png").convert("RGBA"))
    canvas = Image.new("RGBA", (1024, 768), (90, 112, 128, 255))
    _paste_centered(canvas, player, (40, 100, 460, 700))
    _paste_centered(canvas, hr, (560, 100, 980, 700))
    return _save_ref("S5_hr_pass", canvas)


def ref_s6_overtime() -> Path:
    # The high-res overtime scene reference lives in test_outputs/ now (the
    # short-form ``scenes/overtime_night.png`` was moved out during a parallel
    # asset reorg).
    return _save_ref("S6_overtime",
                     Image.open(SPRITES / "test_outputs" / "F_overtime_scene_v01.png").convert("RGBA"))


def ref_s7_exhausted() -> Path:
    portrait = _strip_label(Image.open(SPRITES / "character" / "state_overtime.png").convert("RGBA"))
    canvas = Image.new("RGBA", (1024, 768), (15, 18, 22, 255))
    _paste_centered(canvas, portrait, (220, 60, 800, 700))
    return _save_ref("S7_exhausted", canvas)


def render_first_frames() -> dict[str, Path]:
    return {
        "S1": ref_s1_aerial(),
        "S2": ref_s2_fake_smile(),
        "S3": ref_s3_workstation(),
        "S4": ref_s4_boss_pass(),
        "S5": ref_s5_hr_pass(),
        "S6": ref_s6_overtime(),
        "S7": ref_s7_exhausted(),
    }


# ---------- shot prompts ----------

# Every prompt opens with the same style anchor so Veo3 keeps the SFC/16-bit
# pixel-art look across all 7 shots. Camera + motion description follows.
STYLE_ANCHOR = (
    "SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on "
    "outlines, limited 16-color palette in 格子间灰蓝 #5A7080 / 白炽灯白 #E8E0CC / "
    "档案室棕 #7A5838 / 老板金 #E0B050 / 屏幕蓝 #2C4A6E / 打工人黄 #C8A85A. "
    "Indie game cutscene, dark-humor 喜丧美学 (funeral-as-festival) tone."
)


SHOT_PROMPTS = {
    "S1": (
        "Top-down view of a Chinese office floorplan. Slow cinematic camera "
        "dolly-down through 8 seconds: from a high bird's-eye view of the entire "
        "floor, descending toward a single central cubicle where a lone office "
        "worker sits. As the camera approaches, a warm golden bloom intensifies "
        "from above — like a heavenly spotlight on the chosen worker. Other "
        "cubicles dim into shadow. Promo-trailer mood: triumphant, glowing. "
        + STYLE_ANCHOR
    ),
    "S2": (
        "Tight close-up on a weary middle-aged Chinese male office worker in a "
        "navy suit and red tie, holding a steel thermos in his left hand. He is "
        "wearing a forced, unwavering corporate smile. The camera slowly pulls "
        "back over 8 seconds, revealing the cubicle wall behind him is completely "
        "empty — no awards, no certificates, just a blank beige wall. His smile "
        "doesn't waver. The promo-bright golden lighting persists but starts to "
        "feel hollow. " + STYLE_ANCHOR
    ),
    "S3": (
        "Workstation POV. A drowsy office worker slumps at his desk, eyes "
        "half-closed, holding a thermos. Camera holds steady, slowly pushing in "
        "by 5%. The monitor in front of him glows blue at first, then around "
        "the 4-second mark flickers and shifts to a red warning state. A single "
        "fluorescent light flickers once. Cold morning light, dim ambience. "
        + STYLE_ANCHOR
    ),
    "S4": (
        "A Chinese office boss in a navy suit walks slowly past the camera from "
        "right to left over 8 seconds, a near-silhouette looming with hands "
        "clasped behind his back. As he passes the center frame, he pauses for "
        "one beat — a gold tie clip glints. Two coworker silhouettes are visible "
        "in the background — one typing furiously (the tryhard), one slumped back "
        "with a phone (the slacker). Cold overhead fluorescent on the boss's face. "
        + STYLE_ANCHOR
    ),
    "S5": (
        "An office HR worker — middle-aged Chinese woman in business attire with "
        "empty-frame glasses, holding an 'employee handbook' folder — walks "
        "slowly past the player's workstation from right to left over 8 seconds. "
        "The player figure on the left side stays frozen in a pretend-busy "
        "typing posture, not moving. As HR passes, she pauses briefly to glance "
        "at the player, then continues. " + STYLE_ANCHOR
    ),
    "S6": (
        "An overtime night office scene. Pull-back camera over 8 seconds, "
        "revealing more cubicles. Office overhead fluorescent lights extinguish "
        "one by one in waves from the periphery inward. By 6 seconds in, only "
        "ONE cubicle's lamp remains lit — a central one with a lone exhausted "
        "worker hunched over his keyboard. The remaining lit cubicle pulses "
        "faintly. Final ambience: deep blue night, single white light pool, "
        "extreme isolation. " + STYLE_ANCHOR
    ),
    "S7": (
        "Tight medium shot on an exhausted Chinese male office worker, late 30s, "
        "sitting at his desk in a near-empty dark office. Loosened red tie, dark "
        "circles under his eyes, shirt sleeves rolled up. He breathes slowly — "
        "chest rises and falls once during the 8 seconds. Camera holds steady "
        "with a very gentle pull-back zoom. Strong vignette toward the corners; "
        "leave the upper-center area dimmer for a title overlay in post. Mood: "
        "totally drained, no tears, just numb survival. " + STYLE_ANCHOR
    ),
}


SHOT_REFS = {
    "S1": ref_s1_aerial,
    "S2": ref_s2_fake_smile,
    "S3": ref_s3_workstation,
    "S4": ref_s4_boss_pass,
    "S5": ref_s5_hr_pass,
    "S6": ref_s6_overtime,
    "S7": ref_s7_exhausted,
}


def render_all_clips(only: list[str] | None = None,
                     model: str = DEFAULT_MODEL) -> dict[str, Path]:
    out: dict[str, Path] = {}
    for sid, prompt in SHOT_PROMPTS.items():
        if only and sid not in only:
            continue
        ref = SHOT_REFS[sid]()
        out[sid] = run_shot(sid, prompt=prompt, ref_path=ref, model=model)
    return out


# ---------- CLI ----------

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--only", action="append", default=[],
                   help="restrict to these shot ids (repeatable)")
    p.add_argument("--model", default=DEFAULT_MODEL,
                   help="veo3 / veo3-fast / veo3-pro / veo3.1 / veo3.1-pro")
    p.add_argument("--frames-only", action="store_true",
                   help="only render PIL composite reference frames; skip Veo3 calls")
    args = p.parse_args()

    print("rendering reference frames ...")
    render_first_frames()
    if args.frames_only:
        return

    render_all_clips(only=args.only or None, model=args.model)
    print("\nAll requested shots rendered.")


if __name__ == "__main__":
    main()
