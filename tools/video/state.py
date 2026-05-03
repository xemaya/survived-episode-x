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
