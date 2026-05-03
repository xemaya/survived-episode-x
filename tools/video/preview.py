"""Preview compose: A1 + A2 + B1 + a 5s static C1 placeholder + title reversal beat.

Used when only the first 3 clips have been generated (e.g. ran out of MiniMax
balance partway through). Demonstrates the full title-reversal animation in 21s.
"""
from __future__ import annotations

import shlex
import subprocess
from pathlib import Path

W, H = 1920, 1080
FPS = 30

REPO = Path(__file__).resolve().parents[2]
CLIPS = REPO / "output" / "clips"
TITLES = REPO / "output" / "titles"
FRAMES = REPO / "output" / "composed_frames"
OUT = REPO / "output" / "opening_preview.mp4"


# Preview timeline (seconds):
#   0.0  - 5.0   A1 (trim 0-5 of 6s)
#   5.0  - 10.0  A2 (trim 0-5 of 6s)
#   10.0 - 16.0  B1 (full 6s)
#   16.0 - 21.0  C1 placeholder static frame
#
# Title timeline (compressed reversal at 16-21):
#   0.0  - 1.0   title_fake fade in (top-right)
#   1.0  - 8.0   hold
#   8.0  - 10.0  fade out
#   16.0 - 18.0  reappears center
#   17.0 - 18.0  strikethrough sweep
#   18.0 - 21.0  title_real fades in
#   19.0 - 21.0  subtitle fades in


def build_args() -> list[str]:
    args: list[str] = ["ffmpeg", "-y"]
    # 0:A1 1:A2 2:B1 3:C1png 4:fake 5:real 6:subtitle
    # Title PNGs need -loop 1 -t 21 so they produce video frames whose PTS
    # advances with the main timeline; otherwise fade stays stuck at alpha=0.
    args += ["-i", str(CLIPS / "A1.mp4")]
    args += ["-i", str(CLIPS / "A2.mp4")]
    args += ["-i", str(CLIPS / "B1.mp4")]
    args += ["-loop", "1", "-t", "5", "-i", str(FRAMES / "C1_first.png")]
    args += ["-loop", "1", "-t", "21", "-i", str(TITLES / "title_fake.png")]
    args += ["-loop", "1", "-t", "21", "-i", str(TITLES / "title_real.png")]
    args += ["-loop", "1", "-t", "21", "-i", str(TITLES / "subtitle.png")]

    parts: list[str] = []
    parts.append(f"[0:v]trim=0:5,setpts=PTS-STARTPTS,fps={FPS},format=yuv420p[v0]")
    parts.append(f"[1:v]trim=0:5,setpts=PTS-STARTPTS,fps={FPS},format=yuv420p[v1]")
    parts.append(f"[2:v]trim=0:6,setpts=PTS-STARTPTS,fps={FPS},format=yuv420p[v2]")
    parts.append(
        f"[3:v]scale={W}:{H}:force_original_aspect_ratio=decrease,"
        f"pad={W}:{H}:(ow-iw)/2:(oh-ih)/2:color=black,fps={FPS},format=yuv420p[v3]"
    )
    parts.append("[v0][v1][v2][v3]concat=n=4:v=1:a=0[base]")

    # Split fake title PNG so we can use it twice (top-right band + center reveal).
    parts.append("[4:v]split=2[fake_for_top][fake_for_center]")

    # Fake title top-right: visible 0-10s, with fade-in 0-1s and fade-out 8-10s.
    parts.append(
        "[fake_for_top]format=rgba,fade=t=in:st=0:d=1:alpha=1,"
        "fade=t=out:st=8:d=2:alpha=1[fake_top]"
    )
    parts.append(
        "[base][fake_top]overlay=x=W-w-60:y=40:enable='between(t,0,10)':format=auto[v_after_fake_top]"
    )

    # Fake title center: visible 16-18s, fade-in starting at 16s.
    # The fade is on the PNG's own timeline, so we need fade=st=16 to align with main timeline.
    parts.append(
        "[fake_for_center]format=rgba,fade=t=in:st=16:d=0.5:alpha=1[fake_center]"
    )
    parts.append(
        "[v_after_fake_top][fake_center]overlay=x=(W-w)/2:y=(H-h)/2-100:"
        "enable='between(t,16,18)':format=auto[v_after_fake_center]"
    )

    # drawbox doesn't support W/H — use literal pixel coords for 1920x1080.
    parts.append(
        "[v_after_fake_center]drawbox=x=360:y=450:"
        "w='if(between(t\\,17\\,18)\\, (t-17)*1200\\, 0)':h=14:color=red@0.95:t=fill"
        ":enable='between(t,17,18.2)'[v_after_strike]"
    )

    # Real title: visible 18-21s, fade-in starting at 18s.
    parts.append("[5:v]format=rgba,fade=t=in:st=18:d=1:alpha=1[real_in]")
    parts.append(
        "[v_after_strike][real_in]overlay=x=(W-w)/2:y=(H-h)/2-50:"
        "enable='between(t,18,21)':format=auto[v_after_real]"
    )

    # Subtitle: visible 19-21s, fade-in starting at 19s.
    parts.append("[6:v]format=rgba,fade=t=in:st=19:d=1:alpha=1[sub_in]")
    parts.append(
        "[v_after_real][sub_in]overlay=x=(W-w)/2:y=(H-h)/2+100:"
        "enable='between(t,19,21)':format=auto[vout]"
    )

    args += ["-filter_complex", ";".join(parts), "-map", "[vout]"]
    args += ["-r", str(FPS), "-c:v", "libx264", "-pix_fmt", "yuv420p",
             "-preset", "medium", "-crf", "18", "-an"]
    args.append(str(OUT))
    return args


def main():
    for p in [CLIPS / "A1.mp4", CLIPS / "A2.mp4", CLIPS / "B1.mp4",
              FRAMES / "C1_first.png", TITLES / "title_fake.png",
              TITLES / "title_real.png", TITLES / "subtitle.png"]:
        if not p.exists():
            raise SystemExit(f"missing input: {p}")
    args = build_args()
    print("RUN:", " ".join(shlex.quote(a) for a in args))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(args, check=True)
    print(f"\nWrote {OUT}")


if __name__ == "__main__":
    main()
