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

---

## 2026-05-05 · batch 2 — T10b internal monologue + T11 sticky-note choices + GM questions doc

- **T10b** internal monologue: ✓ done
  - `game/src/render/dialog/internal-monologue.ts` (~85 lines) — italic semi-transparent floating Text near protagonist anchor (no bubble). `PROTAGONIST_HEAD_ANCHOR = (320, 240)` is a stub for T05/T06 sprite binding.
  - `game/src/render/dialog/internal-monologue-parser.ts` (~50 lines) — pure helper `extractInternalMonologue(text)` that lifts whole-italic paragraphs (`_…_`) out of step text and returns `{ monologue, remainder }`.
  - `ink-dialog.ts` paint chain extended: bubble → monologue → panel. Panel hides when both upper layers fired and remainder is empty.
- **T11** sticky-note choices: ✓ done
  - `game/src/render/choice/sticky-notes.ts` (~190 lines) — up-to-3-slot horizontal rack of paper-cream sticky notes on desk surface, click-to-select, drop shadow, hover hi-light. Subtle 1.2 px sine bob driven by `Pixi.Ticker.shared`. Static tilt per slot for handwritten feel.
  - `game/src/render/choice/sticky-notes-layout.ts` (~75 lines) — pure layout math; `computeStickyLayout({count, centerX, centerY, gap, maxSlots})` returns deterministic slot coords + tilt + bob phase. Caps at 3, spills extras to a vertical fallback rack so 4-5-choice daily stitches don't drop content.
  - `ink-dialog.ts` choice rendering swapped from centered-button stack to `mountStickyNotes()` for workstation scene.
- **GM ↔ engine questions doc**: written `design/vertical-slice/p5-phase2-engine-questions.md` with:
  - Q-1: propose `# speaker: <id>` ink tag convention so `speaker-parser.ts` + `npc-anchors.ts` can be deleted once NPC sprite layer lands.
  - Q-2: Bug #3 fix preference — option A (ink-side gate choice) vs B (engine-side `# pagebreak` tag).
  - Q-3: Bug #6 sticky-note label length policy — recommend ship-as-is for v1, sweep later.

**Tests**: 25 new vitest cases (11 monologue parser + 14 sticky-note layout/style). Total 204/204 green.

**Verify**:
- `pnpm tsc` ✓
- `pnpm lint` ✓ (1 pre-existing warning untouched)
- `pnpm test` ✓ 204/204
- `pnpm ink:build` ⚠ **8/9 succeed** — `episode-8.ink` (designer-introduced this session) crashes at lines 1663-1666 with `Expected end of line but saw '}}'` and `Expected closing brace '}' for inline logic`. Engine-untouchable per handoff §5; flagged for designer in commit message + lefthook pre-commit hook (which runs tsc + biome + vitest, NOT ink:build) still passes so this commit isn't gated by it.

**Open questions / asks for GM**: see questions doc Q-1/Q-2/Q-3 above.

**FYI bug for designer**: `episode-8.ink` lines 1663-1666 have `{{` / unclosed `{` syntax — `pnpm ink:build` rejects the file. Episodes 1-7 still compile and load; this is opt-in for whenever designer cares to fix.

(next: address QA Round-1 majors — either Bug #4 panel overflow (in scope of my T10a/T11 area), or move on to T05/T06 NPC sprite slots so `npc-anchors.ts` can become a real binding. Will pick whichever has cleaner blast radius given Q-1/Q-2 design replies.)

