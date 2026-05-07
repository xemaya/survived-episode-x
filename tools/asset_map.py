#!/usr/bin/env python3
"""Reconcile asset-manifest.md spec against sprite_mapping.yaml + actual files.

Reads:
  - design/assets/asset-manifest.md   (172 ASSET-NNN entries — spec)
  - design/assets/sprite_mapping.yaml (mappings: id -> files + status)
  - assets/sprites/                   (actual filesystem)

Outputs a status table. Run with --list <status> to print IDs in a category.
"""
import argparse
import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "design/assets/asset-manifest.md"
MAPPING = ROOT / "design/assets/sprite_mapping.yaml"
SPRITES = ROOT / "assets/sprites"

# ASSET-NNN ranges that are uniformly audio (not visual)
AUDIO_RANGE = range(125, 173)  # ASSET-125 .. ASSET-172 inclusive

ASSET_RE = re.compile(r"^\| (ASSET-\d{3}) \| ([^|]+?) \| ([^|]+?) \| ([^|]+?) \|", re.MULTILINE)


def parse_manifest() -> dict[str, dict]:
    """Extract all ASSET-NNN rows from the manifest's per-system tables.

    Returns {asset_id: {name, category, status_specced, line}}.
    """
    text = MANIFEST.read_text(encoding="utf-8")
    out: dict[str, dict] = {}
    for m in ASSET_RE.finditer(text):
        aid, name, category, status_specced = (s.strip() for s in m.groups())
        if aid in out:
            continue  # first occurrence wins (cross-target reuse table)
        out[aid] = {
            "name": name,
            "category": category,
            "status_specced": status_specced,
        }
    return out


def load_mapping() -> dict[str, dict]:
    raw = yaml.safe_load(MAPPING.read_text(encoding="utf-8"))
    return raw.get("mappings", {}) if raw else {}


def verify_files(entry: dict) -> tuple[int, int, list[str]]:
    """Return (existing_count, total_count, missing_list)."""
    files = entry.get("files", []) or []
    if isinstance(files, str):
        files = [files]
    total = len(files)
    missing = []
    existing = 0
    for f in files:
        path = SPRITES / f
        # If file is a directory reference (e.g. "cards/offense"), treat as
        # done if directory exists and contains PNGs.
        if path.is_dir():
            pngs = list(path.glob("*.png"))
            if pngs:
                existing += 1
            else:
                missing.append(f)
        elif path.is_file():
            existing += 1
        else:
            missing.append(f)
    return existing, total, missing


def reconcile() -> dict[str, dict]:
    """Build per-asset reconciled record."""
    spec = parse_manifest()
    mapping = load_mapping()
    out: dict[str, dict] = {}

    for aid, info in spec.items():
        n = int(aid.split("-")[1])
        rec = {
            "id": aid,
            "name": info["name"],
            "category": info["category"],
            "status": "unknown",
            "files_existing": 0,
            "files_total": 0,
            "missing": [],
            "notes": "",
        }

        # Audio range — uniform classification
        if n in AUDIO_RANGE:
            rec["status"] = "audio_skip"
            out[aid] = rec
            continue

        m = mapping.get(aid)
        if m is None:
            # No explicit mapping. Default behavior:
            #  - "Configuration" / "Shader" / "LUT" / "Tool" categories → not_visual
            #  - everything else → pending
            cat = (info["category"] or "").lower()
            if any(k in cat for k in ("configuration", "shader", "tool")):
                rec["status"] = "not_visual"
            else:
                rec["status"] = "pending"
            out[aid] = rec
            continue

        # Have explicit mapping
        declared = m.get("status", "pending")
        rec["notes"] = m.get("notes", "")
        if declared in ("not_visual", "deferred", "cross_ref", "program_drawn", "reference"):
            rec["status"] = declared
            if declared == "cross_ref":
                rec["notes"] = f"→ {m.get('ref', '?')}; {rec['notes']}".strip("; ")
            out[aid] = rec
            continue

        existing, total, missing = verify_files(m)
        rec["files_existing"] = existing
        rec["files_total"] = total
        rec["missing"] = missing

        if total == 0:
            rec["status"] = declared  # trust mapping for entries with no file list
        elif existing == total:
            # all files present — promote to done unless mapping declared partial
            rec["status"] = "done" if declared in ("done", "pending") else declared
        elif existing == 0:
            rec["status"] = "pending"  # mapping said done but files missing
        else:
            rec["status"] = "partial"

        out[aid] = rec
    return out


def summarize(records: dict[str, dict]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for rec in records.values():
        counts[rec["status"]] = counts.get(rec["status"], 0) + 1
    return counts


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--list", help="print IDs with this status (e.g. pending, partial, done)")
    ap.add_argument("--missing", action="store_true", help="print mapped files that don't exist on disk")
    args = ap.parse_args()

    records = reconcile()
    counts = summarize(records)

    print(f"=== Asset reconciliation ({len(records)} ASSET-NNN entries) ===\n")
    order = ["done", "partial", "pending", "cross_ref", "program_drawn", "deferred", "reference", "not_visual", "audio_skip", "unknown"]
    for status in order:
        if status in counts:
            print(f"  {status:14s}  {counts[status]:>3d}")
    other = [s for s in counts if s not in order]
    for status in sorted(other):
        print(f"  {status:14s}  {counts[status]:>3d}")
    print()

    visual_total = sum(counts.get(s, 0) for s in ("done", "partial", "pending", "cross_ref", "deferred", "program_drawn"))
    visual_done_or_partial = counts.get("done", 0) + counts.get("partial", 0) + counts.get("program_drawn", 0)
    if visual_total:
        pct = visual_done_or_partial / visual_total * 100
        print(f"Visual coverage: {visual_done_or_partial}/{visual_total} ({pct:.0f}%) done or partial")

    if args.list:
        target = args.list
        print(f"\n--- {target} ---")
        for aid in sorted(records, key=lambda x: int(x.split("-")[1])):
            rec = records[aid]
            if rec["status"] == target:
                detail = f" ({rec['files_existing']}/{rec['files_total']})" if rec["files_total"] else ""
                notes = f"  // {rec['notes']}" if rec["notes"] else ""
                print(f"  {aid:10s}  {rec['name']:50s}{detail}{notes}")

    if args.missing:
        print("\n--- missing files (mapped but absent on disk) ---")
        any_missing = False
        for aid in sorted(records, key=lambda x: int(x.split("-")[1])):
            rec = records[aid]
            if rec["missing"]:
                any_missing = True
                print(f"  {aid}  {rec['name']}")
                for f in rec["missing"]:
                    print(f"      - {f}")
        if not any_missing:
            print("  (none)")

    return 0


if __name__ == "__main__":
    sys.exit(main())
