"""Build and run the final ffmpeg compose command.

Timeline (seconds):
  0.0 - 5.0   A1  (trim 0-5 of 6s clip)
  5.0 - 10.0  A2  (trim 0-5 of 6s clip)
  10.0 - 16.0 B1
  16.0 - 22.0 B2
  22.0 - 28.0 B3
  28.0 - 34.0 B4
  34.0 - 40.0 B5
  40.0 - 46.0 B6
  46.0 - 52.0 B7
  52.0 - 60.0 C1  (6s clip + 2s static-pad of last frame; tpad)

Title overlays (RGBA PNGs, full 1920x1080 canvas alignment via x/y):
  0.0  - 8.0    title_fake fade in/hold (top-right area)
  8.0  - 10.0   title_fake fade out
  54.0 - 57.0   title_fake reappears at center (frozen-frame style)
  56.0 - 57.2   strikethrough sweep across title_fake
  57.0 - 60.0   title_real fades in at center
  58.0 - 60.0   subtitle fades in below title_real

Hard cuts between all clips. No audio.
"""
from __future__ import annotations

import shlex
import subprocess
from pathlib import Path
from typing import Mapping

W, H = 1920, 1080
FPS = 30

# (clip_id, output_start, output_end, source_trim_start, source_trim_end)
SEGMENTS = [
    ("A1",  0.0,  5.0, 0.0, 5.0),
    ("A2",  5.0, 10.0, 0.0, 5.0),
    ("B1", 10.0, 16.0, 0.0, 6.0),
    ("B2", 16.0, 22.0, 0.0, 6.0),
    ("B3", 22.0, 28.0, 0.0, 6.0),
    ("B4", 28.0, 34.0, 0.0, 6.0),
    ("B5", 34.0, 40.0, 0.0, 6.0),
    ("B6", 40.0, 46.0, 0.0, 6.0),
    ("B7", 46.0, 52.0, 0.0, 6.0),
    # C1 is special: source is 6s, presented as 8s via tpad cloning the last frame for 2s.
    ("C1", 52.0, 60.0, 0.0, 6.0),
]
C1_PAD_SECONDS = 2.0


def build_compose_args(*, clips: Mapping[str, Path], titles: Mapping[str, Path],
                       output: Path) -> list[str]:
    """Return the full ffmpeg argv for the final compose."""
    args: list[str] = ["ffmpeg", "-y"]

    clip_order = [seg[0] for seg in SEGMENTS]
    for cid in clip_order:
        args += ["-i", str(clips[cid])]
    args += ["-i", str(titles["fake"])]
    args += ["-i", str(titles["real"])]
    args += ["-i", str(titles["subtitle"])]

    parts: list[str] = []

    # Per-clip: trim, scale to canvas, pad to letterbox, set fps, optional pad for C1
    for idx, (cid, _start, _end, ts, te) in enumerate(SEGMENTS):
        chain = (
            f"[{idx}:v]trim={ts}:{te},setpts=PTS-STARTPTS,"
            f"scale={W}:{H}:force_original_aspect_ratio=decrease,"
            f"pad={W}:{H}:(ow-iw)/2:(oh-ih)/2:color=black,"
            f"fps={FPS}"
        )
        if cid == "C1":
            chain += f",tpad=stop_mode=clone:stop_duration={C1_PAD_SECONDS}"
        chain += f"[v{idx}]"
        parts.append(chain)

    concat_in = "".join(f"[v{i}]" for i in range(len(SEGMENTS)))
    parts.append(f"{concat_in}concat=n={len(SEGMENTS)}:v=1:a=0[base]")

    fake_idx, real_idx, sub_idx = 10, 11, 12

    # Fake title (top-right): fade in 0-1s, hold to 8s, fade out 8-10s.
    parts.append(
        f"[{fake_idx}:v]format=rgba,fade=t=in:st=0:d=1:alpha=1,"
        f"fade=t=out:st=8:d=2:alpha=1[fake_top]"
    )
    parts.append("[base][fake_top]overlay=x=W-w-60:y=40:enable='between(t,0,10)'[v_after_fake_top]")

    # Fake title (center) during the title-reversal beat at 54-57.
    parts.append(
        f"[{fake_idx}:v]format=rgba,fade=t=in:st=0:d=0.5:alpha=1[fake_center]"
    )
    parts.append("[v_after_fake_top][fake_center]overlay=x=(W-w)/2:y=(H-h)/2-100:enable='between(t,54,57)'[v_after_fake_center]")

    # Strikethrough: animated red drawbox sweeping across the fake title text region.
    parts.append(
        "[v_after_fake_center]drawbox=x=(W-1200)/2:y=(H/2)-90:"
        "w='if(between(t,56,57), (t-56)*1200, 0)':h=14:color=red@0.95:t=fill"
        ":enable='between(t,56,57.2)'[v_after_strike]"
    )

    # Real title: fades in 57-58, holds to end.
    parts.append(
        f"[{real_idx}:v]format=rgba,fade=t=in:st=0:d=1:alpha=1[real_in]"
    )
    parts.append("[v_after_strike][real_in]overlay=x=(W-w)/2:y=(H-h)/2-50:enable='between(t,57,60)'[v_after_real]")

    # Subtitle: fades in 58-59, holds to end.
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
