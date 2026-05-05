# P5 Phase 2 · Engine Dev Progress Log

> Status: append-only log of engine batches handed off from Phase 1 closure.
> Author: Engine clone(s) — see commit messages for batch authorship.
> Format per handoff §8 of `p5-phase2-engine-handoff.md`.

---

## 2026-05-05 · batch 1 — T10a speech bubble

- **T10a** speech bubble: ✓ done
  - `game/src/render/dialog/speech-bubble.ts` (~95 lines) — PixiJS Container/Graphics/Text composition; mounts a rounded bubble at the NPC anchor with a downward tail, auto-fits to wrapped text.
  - `game/src/render/dialog/speech-bubble-layout.ts` (~95 lines) — pure layout math (clamp to canvas margins, tail base position, tip drop). Extracted from speech-bubble.ts so vitest can exercise it without loading pixi.js (which needs a canvas).
  - `game/src/render/dialog/npc-anchors.ts` (~65 lines) — screen-anchor registry for 15 known NPCs (5 deep-cast + 5 bit-cast + S2+ slots). Anchors are STUBS until T05/T06 wires real NPC sprite slots; comment notes the migration plan.
  - `game/src/render/dialog/speaker-parser.ts` (~50 lines) — parses `**Name**：dialog` and `Name：dialog` lines; returns null when speaker is not in `npc-anchors` so prop quotes (`桌面便利贴："活到周五"`) and laoxia narration (`你："睡觉"`) keep falling through to the panel renderer.
  - `game/src/render/dialog/ink-dialog.ts` — added speech-bubble routing: when first paragraph of a step is a known NPC speaker line, the dialog body renders as a bubble at that NPC's anchor and the speaker line is stripped from the bottom panel. Remainder paragraphs continue to render in the panel ("先共存" per handoff §11).
  - Visual style honors concept 02 reference: cream `#E8E0CC` bg + cubicle `#5A7080` border + 6px corner radius + 1px stroke + downward tail at NPC mouth.
- **T10a tests**: 18 new vitest cases in `tests/render/dialog/speech-bubble.test.ts`
  - parseSpeaker: bold prefix, plain prefix, prop-quote rejection, laoxia rejection, remainder preservation
  - getNpcAnchor: deep-cast lookup, unknown rejection, whitespace tolerance, registry breadth
  - computeBubbleLayout: text auto-fit, MAX_WIDTH clamp, anchor gap, edge-clamping (left/right canvas margins), tail tip alignment, style constants pinned

**Verify**:
- `pnpm verify` exits 0 — assets:sync ✓, ink:build ✓ (5/5, only pre-existing loose-end warnings), tsc ✓, lint ✓ (1 pre-existing warning in `run-meta/hr-evaluation.ts`, not introduced by this batch), test ✓ 179/179.
- Dev server (`pnpm dev`) HMR confirmed loading the new modules; manual browser walkthrough required to confirm Lisa speech bubble appears at right-cubicle anchor in Day 1 茶水间偶遇 scene.

**Open questions**: none. Anchor positions are intentionally stub coordinates pending T05/T06 NPC sprite layer; once those land, `npc-anchors.ts` becomes a live binding to `npc.sprite.position + headOffset` rather than a hardcoded table.

(next: T10b internal monologue or T11 sticky note choices, depending on whether QA reports any block bugs against the bubble first.)
