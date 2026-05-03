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
PROMPTS = REPO / "tools" / "video" / "prompts"
CLIPS_OUT = REPO / "output" / "clips"
STATE_DIR = REPO / "output" / ".video_runs"


@dataclass
class ClipSpec:
    clip_id: str
    prompt_file: str
    duration: int
    first_frame: Callable[[], Path]


CLIP_SPECS = [
    ClipSpec("A1", "A1_aerial.txt", 6, composer.compose_a1_aerial),
    ClipSpec("A2", "A2_fake_smile.txt", 6, composer.compose_a2_fake_smile),
    ClipSpec("B1", "B1_alarm.txt", 6, composer.compose_b1_drowsy),
    ClipSpec("B2", "B2_monitor.txt", 6, composer.compose_b2_monitor),
    ClipSpec("B3", "B3_boss_pass.txt", 6, composer.compose_b3_boss_pass),
    ClipSpec("B4", "B4_npc_pan.txt", 6, composer.compose_b4_npc_strip),
    ClipSpec("B5", "B5_hr_pass.txt", 6, composer.compose_b5_hr_pass),
    ClipSpec("B6", "B6_coffee_decay.txt", 6, composer.compose_b6_coffee_sticky),
    ClipSpec("B7", "B7_floor_lights_off.txt", 6, composer.compose_b7_overtime),
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
        first_frame = spec.first_frame()
        if not Path(first_frame).exists():
            raise FileNotFoundError(f"[{spec.clip_id}] missing first frame: {first_frame}")

        state = RunState.load_or_create(STATE_DIR, spec.clip_id,
                                        model="MiniMax-Hailuo-2.3",
                                        duration=spec.duration,
                                        resolution=resolution)
        if state.is_completed() and state.resolution != resolution:
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
