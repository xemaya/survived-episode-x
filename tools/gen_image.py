#!/usr/bin/env python3
"""Generate a single image via DeerAPI gpt-image-2.

Usage:
    python3 tools/gen_image.py <prompt_file> <output_png> [--quality low|high] [--size 1024x1024]

Reads DEERAPI_KEY from env. Quality low ~$0.03, high ~$0.10.
Saves prompt-side metadata (.meta.json) next to the output for traceability.
"""
import argparse
import base64
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

API_URL = "https://api.deerapi.com/v1/images/generations"
MODEL = "gpt-image-2"
TIMEOUT_SEC = 240


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("prompt_file", type=Path)
    ap.add_argument("output_png", type=Path)
    ap.add_argument("--quality", choices=["low", "high"], default="low")
    ap.add_argument("--size", default="1024x1024")
    args = ap.parse_args()

    key = os.environ.get("DEERAPI_KEY")
    if not key:
        print("ERR: DEERAPI_KEY not set in env", file=sys.stderr)
        return 1
    if not args.prompt_file.exists():
        print(f"ERR: prompt file missing: {args.prompt_file}", file=sys.stderr)
        return 1

    prompt = args.prompt_file.read_text(encoding="utf-8").strip()
    body = {
        "model": MODEL,
        "prompt": prompt,
        "n": 1,
        "size": args.size,
        "quality": args.quality,
        "output_format": "png",
    }

    print(f"→ {MODEL} quality={args.quality} size={args.size} prompt_chars={len(prompt)}")
    t0 = time.time()
    req = urllib.request.Request(
        API_URL,
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT_SEC) as resp:
            payload = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body_txt = e.read().decode("utf-8", errors="replace")
        print(f"ERR HTTP {e.code}: {body_txt[:500]}", file=sys.stderr)
        return 2

    elapsed = time.time() - t0
    if "data" not in payload or not payload["data"]:
        print(f"ERR: no data in response: {json.dumps(payload)[:400]}", file=sys.stderr)
        return 3

    b64 = payload["data"][0].get("b64_json")
    if not b64:
        print(f"ERR: no b64_json in first datum: {json.dumps(payload['data'][0])[:400]}", file=sys.stderr)
        return 3

    args.output_png.parent.mkdir(parents=True, exist_ok=True)
    args.output_png.write_bytes(base64.b64decode(b64))
    size_kb = args.output_png.stat().st_size / 1024
    print(f"✓ {args.output_png}  {size_kb:.0f} KB  in {elapsed:.1f}s")

    meta_path = args.output_png.with_suffix(args.output_png.suffix + ".meta.json")
    meta = {
        "model": MODEL,
        "quality": args.quality,
        "size": args.size,
        "prompt_file": str(args.prompt_file),
        "prompt_chars": len(prompt),
        "elapsed_sec": round(elapsed, 1),
        "ts": time.strftime("%Y-%m-%d %H:%M:%S"),
        "usage": payload.get("usage"),
    }
    meta_path.write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
