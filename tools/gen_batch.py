#!/usr/bin/env python3
"""Sequentially generate any v01 PNGs missing for prompt_*.txt files in test_outputs/.

Skips outputs that already exist (idempotent). Retries each failed sheet once.
Quality defaults to 'low' (~$0.03/sheet); pass --quality high for finals.
"""
import argparse
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DIR = ROOT / "assets/sprites/test_outputs"


def gen_one(prompt: Path, out: Path, quality: str) -> int:
    return subprocess.call(
        [
            sys.executable,
            str(ROOT / "tools/gen_image.py"),
            str(prompt),
            str(out),
            "--quality",
            quality,
        ],
        cwd=str(ROOT),
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--quality", choices=["low", "high"], default="low")
    ap.add_argument("--only", help="comma-sep prefixes to include (e.g. K,L,M)")
    args = ap.parse_args()

    only = set(args.only.split(",")) if args.only else None

    prompts = sorted(DIR.glob("prompt_*.txt"))
    todo: list[tuple[Path, Path, str]] = []
    for p in prompts:
        name = p.stem[len("prompt_"):]  # e.g. K_calendar_attendance
        prefix = name.split("_", 1)[0]  # e.g. K
        if only and prefix not in only:
            continue
        out = DIR / f"{name}_v01.png"
        if out.exists():
            print(f"skip  {name} (exists)")
            continue
        todo.append((p, out, name))

    print(f"=== {len(todo)} sheets to generate (quality={args.quality}) ===")
    t0 = time.time()
    failed: list[str] = []
    for i, (p, out, name) in enumerate(todo, 1):
        print(f"\n--- [{i}/{len(todo)}] {name} ---", flush=True)
        rc = gen_one(p, out, args.quality)
        if rc != 0:
            print(f"!! FAIL {name} rc={rc}, retrying once", flush=True)
            time.sleep(3)
            rc = gen_one(p, out, args.quality)
            if rc != 0:
                print(f"!! FINAL FAIL {name}", flush=True)
                failed.append(name)
    elapsed = time.time() - t0
    print(f"\n=== batch done in {elapsed/60:.1f} min, {len(failed)} failed ===")
    if failed:
        print("FAILED:", ", ".join(failed))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
