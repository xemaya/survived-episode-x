"""Build and run the final ffmpeg compose command.

Timeline (seconds) — 7 Veo3-generated 8s clips + 4s tpad of S7's last frame:

  0.0  - 8.0    S1  aerial dolly-down to a single cubicle (golden bloom)
  8.0  - 16.0   S2  fake-smile pull-out reveals the empty wall
  16.0 - 24.0   S3  workstation: drowsy worker, monitor goes red
  24.0 - 32.0   S4  boss looms past with tryhard/slacker silhouettes
  32.0 - 40.0   S5  HR walks past pretend-busy player
  40.0 - 48.0   S6  overtime night, lights extinguishing
  48.0 - 60.0   S7  exhausted hold (8s clip + 4s clone-pad of last frame)

Title overlay timeline (overlaid on the concat'd base):
  0.0  - 1.0    title_fake fade in (top-right band)
  1.0  - 8.0    hold
  8.0  - 10.0   fade out
  54.0 - 57.0   title_fake reappears center (frozen-frame style)
  56.0 - 57.2   strikethrough sweep across the fake title
  57.0 - 60.0   title_real fades in at center
  58.0 - 60.0   subtitle fades in below

Hard cuts between shots. No audio (Veo3 includes audio but we strip it via -an).
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
    ("S1",  0.0,  8.0,  0.0, 8.0),
    ("S2",  8.0, 16.0,  0.0, 8.0),
    ("S3", 16.0, 24.0,  0.0, 8.0),
    ("S4", 24.0, 32.0,  0.0, 8.0),
    ("S5", 32.0, 40.0,  0.0, 8.0),
    ("S6", 40.0, 48.0,  0.0, 8.0),
    # S7 is presented as 12 seconds: source trimmed 0-8s + tpad clone of the
    # last frame for an additional 4 seconds, giving the title-reversal beat
    # space to play out over a frozen final frame.
    ("S7", 48.0, 60.0,  0.0, 8.0),
]
S7_PAD_SECONDS = 4.0


def build_compose_args(*, clips: Mapping[str, Path], titles: Mapping[str, Path],
                       output: Path) -> list[str]:
    """Return the full ffmpeg argv for the final compose."""
    args: list[str] = ["ffmpeg", "-y"]

    clip_order = [seg[0] for seg in SEGMENTS]
    for cid in clip_order:
        args += ["-i", str(clips[cid])]
    # Title PNGs need -loop 1 -t 60 so each emitted frame's PTS advances with the
    # main timeline; otherwise the fade filter sees a stuck PTS=0 and alpha stays 0.
    for tk in ("fake", "real", "subtitle"):
        args += ["-loop", "1", "-t", "60", "-i", str(titles[tk])]

    parts: list[str] = []

    # Per-clip: trim, ensure 1920x1080@30, force yuv420p so concat is happy.
    # S7 gets an extra tpad to clone its last frame for S7_PAD_SECONDS.
    for idx, (cid, _start, _end, ts, te) in enumerate(SEGMENTS):
        chain = (
            f"[{idx}:v]trim={ts}:{te},setpts=PTS-STARTPTS,"
            f"scale={W}:{H}:force_original_aspect_ratio=decrease:flags=neighbor,"
            f"pad={W}:{H}:(ow-iw)/2:(oh-ih)/2:color=black,"
            f"fps={FPS}"
        )
        if cid == "S7":
            chain += f",tpad=stop_mode=clone:stop_duration={S7_PAD_SECONDS}"
        chain += f",format=yuv420p[v{idx}]"
        parts.append(chain)

    concat_in = "".join(f"[v{i}]" for i in range(len(SEGMENTS)))
    parts.append(f"{concat_in}concat=n={len(SEGMENTS)}:v=1:a=0[base]")

    fake_idx = len(SEGMENTS)
    real_idx = fake_idx + 1
    sub_idx = fake_idx + 2

    # The fake title PNG is referenced twice (top-right band + center reveal),
    # so it has to be split before any per-use processing.
    parts.append(f"[{fake_idx}:v]split=2[fake_for_top][fake_for_center]")

    # Fake title top-right: fade in 0-1s, hold to 8s, fade out 8-10s.
    parts.append(
        "[fake_for_top]format=rgba,fade=t=in:st=0:d=1:alpha=1,"
        "fade=t=out:st=8:d=2:alpha=1[fake_top]"
    )
    parts.append(
        "[base][fake_top]overlay=x=W-w-60:y=40:enable='between(t,0,10)':format=auto[v_after_fake_top]"
    )

    # Fake title center during the title-reversal beat at 54-57.
    # fade `st` is in PNG-input PTS; with -loop 1 -t 60 the PNG PTS matches main timeline.
    parts.append(
        "[fake_for_center]format=rgba,fade=t=in:st=54:d=0.5:alpha=1[fake_center]"
    )
    parts.append(
        "[v_after_fake_top][fake_center]overlay=x=(W-w)/2:y=(H-h)/2-100:"
        "enable='between(t,54,57)':format=auto[v_after_fake_center]"
    )

    # Strikethrough: animated red drawbox sweeping across the fake title.
    # drawbox doesn't accept W/H expressions — use literal 1920x1080 coords.
    parts.append(
        "[v_after_fake_center]drawbox=x=360:y=450:"
        "w='if(between(t\\,56\\,57)\\, (t-56)*1200\\, 0)':h=14:color=red@0.95:t=fill"
        ":enable='between(t,56,57.2)'[v_after_strike]"
    )

    # Real title: fades in 57-58, holds to end.
    parts.append(f"[{real_idx}:v]format=rgba,fade=t=in:st=57:d=1:alpha=1[real_in]")
    parts.append(
        "[v_after_strike][real_in]overlay=x=(W-w)/2:y=(H-h)/2-50:"
        "enable='between(t,57,60)':format=auto[v_after_real]"
    )

    # Subtitle: fades in 58-59, holds to end.
    parts.append(f"[{sub_idx}:v]format=rgba,fade=t=in:st=58:d=1:alpha=1[sub_in]")
    parts.append(
        "[v_after_real][sub_in]overlay=x=(W-w)/2:y=(H-h)/2+100:"
        "enable='between(t,58,60)':format=auto[vout]"
    )

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
