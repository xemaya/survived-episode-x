from pathlib import Path

from tools.video.ffmpeg_compose import build_compose_args, SEGMENTS


def test_build_compose_args_includes_all_inputs(tmp_path: Path):
    clips = {seg[0]: tmp_path / f"{seg[0]}.mp4" for seg in SEGMENTS}
    titles = {
        "fake": tmp_path / "title_fake.png",
        "real": tmp_path / "title_real.png",
        "subtitle": tmp_path / "subtitle.png",
    }
    out = tmp_path / "out.mp4"
    args = build_compose_args(clips=clips, titles=titles, output=out)

    for p in clips.values():
        assert str(p) in args
    for p in titles.values():
        assert str(p) in args
    assert args[-1] == str(out)
    assert "libx264" in args
    assert "30" in args


def test_segments_total_60s():
    total = sum(end - start for (_cid, start, end, _ts, _te) in SEGMENTS)
    assert total == 60.0


def test_segments_no_gaps_or_overlaps():
    prev_end = 0.0
    for (_cid, start, end, _ts, _te) in SEGMENTS:
        assert start == prev_end
        prev_end = end
    assert prev_end == 60.0
