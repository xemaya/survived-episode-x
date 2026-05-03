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
COST_CNY_PER_CLIP = {
    ("MiniMax-Hailuo-2.3", "1080P", 6): 5.0,
    ("MiniMax-Hailuo-2.3", "1080P", 10): 8.0,
    ("MiniMax-Hailuo-2.3", "768P", 6): 2.5,
    ("MiniMax-Hailuo-2.3", "768P", 10): 4.0,
}


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
        raise MiniMaxError(f"submit failed {r.status_code}: {r.text[:1000]}")
    data = r.json()
    task_id = data.get("task_id")
    if not task_id:
        raise MiniMaxError(f"no task_id in response (status_code={r.status_code}): {data}")
    return task_id


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
