"""Smoke test: submit one 768P 6s clip using a tiny PIL-generated image as
first_frame, just to verify data-URI image input is accepted."""
from pathlib import Path

from PIL import Image

from tools.video.client import generate_clip
from tools.video.state import RunState

REPO = Path(__file__).resolve().parents[2]


def main():
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
