import json
from pathlib import Path

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
