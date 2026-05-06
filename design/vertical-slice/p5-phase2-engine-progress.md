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

---

## 2026-05-05 · batch 3 — QA Bug #4 panel clip + T16 ink save (Bugs #5/#9)

- **Bug #4** panel text overflow: ✓ resolved
  - `ink-dialog.ts`: panel grew 130 → 156 px, line-height 18 → 16. Added a `Pixi.Graphics` rect mask over the narration `Text` so any text that still exceeds the inner padding box clips cleanly instead of bleeding onto the workstation BG.
  - This is the visual triage; structural pagination is still gated on Q-2 (Bug #3 fix preference).
- **Bug #5 + #9** ink runtime save (closure-doc T16): ✓ resolved
  - `runStateSchema` gained `inkStateJson: z.string().optional()` (no schemaVersion bump — optional field stays back-compat with pre-T16 saves).
  - `snapshotCurrentRunState()` captures `ink.serializeState()` whenever a story is loaded.
  - `main.ts` boot path: when a save is restored AND has an `inkStateJson`, calls `ink.loadState(...)` after `loadEpisode()` resolves; falls back to `divertTo('intro')` otherwise. Old saves resume cleanly to intro (graceful migration).
  - `ink-dialog.ts` factored choice handling through `advanceChoice(idx)` — single funnel for both the legacy button (`renderChoiceButton`) and the T11 sticky-note `onSelect` handler. After every `ink.selectChoice()` it `void autosave()`s. So `[继续]` now lands the player at the last choice they made (Bug #9 fix dependency).
- **Tests**: 2 new vitest cases in `tests/save/system.test.ts` — round-trip with `inkStateJson` set + parse a legacy shape with the field absent. Total 206/206 green.

**Verify**:
- `pnpm tsc` ✓
- `pnpm test` ✓ 206/206
- `pnpm lint` to be re-run inside lefthook on commit
- `pnpm dev` HMR — not blocked; manual browser walkthrough recommended (refresh mid-Day-1 → click `[继续]` → expect resume at the last choice rather than restart from intro).

**Open questions / asks for GM**: still Q-1/Q-2/Q-3 from batch-2 questions doc — none new from this batch.

(next: pick whichever Q-1/Q-2 reply lands first — if Q-1 ack lands, do `# speaker:` migration sweep + delete `speaker-parser.ts`/`npc-anchors.ts`; if Q-2 ack lands as option B, implement `# pagebreak` step-loop break and resolve Bug #3. Otherwise start T03 `# scene` / `# npc` / `# prop` interceptor wiring against existing workstation props — closes Bug #8.)

---

## 2026-05-05 · batch 4 — T05-mini prop entity + T03 prop tag interceptor (Bug #8 partial)

- **T05-mini** prop entity + registry: ✓ done
  - `game/src/render/diegetic/prop-entity.ts` (~95 lines) — generic PixiJS sprite-swap entity. `createPropEntity(parent, { id, states, initialState, x, y, scale })` returns a handle with `setState(name)`/`hasState`/`destroy`. Sprite asset URLs preloaded via `Assets.load` lazily on each state change.
  - `game/src/render/diegetic/prop-registry.ts` (~95 lines) — `PropRegistry` singleton (`propRegistry`) maps id → entity. `setStateFromTag(value)` parses ink tag values into `{id, state}` via longest-prefix match against registered ids, then dispatches to the entity. Pure helper `parsePropTagValue()` is the unit-tested core.
  - Longest-prefix parsing handles ids that contain underscores (e.g. `sticky_huo_dao_zhouwu` whose state suffix is `fresh` or `curled_edge_1week`).
- **T03-prop** tag interceptor wiring: ✓ done
  - `game/src/render/diegetic/prop-tag-handler.ts` (~25 lines) — `installPropTagHandler()` registers TagDispatcher listeners for both `# prop:` and `# diegetic_prop:` keys; returns a teardown that unregisters them.
  - `workstation.ts` mount: registers `fruit_bowl` (apple/strawberry/empty) at desk-right + `phone` (face_down/face_up/with_badge) at desk-mid, then `installPropTagHandler()`. Teardowns unregister + destroy on scene unmount.
  - Existing P0-P4 binding-driven props (mug ← energy, monitor ← kpi, calendar ← currentDay) keep their direct subscriptions for now. Tag-driven override of those props lands when ink starts emitting `# prop: mug_*` / `# prop: monitor_*` / `# prop: calendar_*`.
- **Tests**: 12 new vitest cases in `tests/render/diegetic/prop-registry.test.ts` — `parsePropTagValue` edge cases (empty / no prefix / overlap / multi-segment state) + `PropRegistry` register/get/setStateFromTag/snapshot/clear. Total 218/218 green.

**QA Bug #8** (`# scene` / `# npc` / `# prop` / `# diegetic_prop` no listeners): ⚙️ partial — `# prop:` and `# diegetic_prop:` axes are live; `# scene:` and `# npc:` still no-op pending T04 scene registry + T05/T06 NPC sprite slots.

**Verify**:
- `pnpm tsc` ✓
- `pnpm test` ✓ 218/218
- `pnpm lint` to be re-run inside lefthook on commit
- `pnpm dev` HMR — workstation now mounts `fruit_bowl` + `phone` sprites by default; ink emitting `# prop: phone_with_badge` (or any registered state) swaps the sprite live.

**Open questions / asks for GM**: still Q-1/Q-2/Q-3 pending. None new from this batch.

(next: T04 scene registry + transitions if Q-1 still pending; or kick off T05 NPC sprite slot work so `npc-anchors.ts` becomes a sprite-position binding once Q-1 ack lands. Will reassess after looking at GM replies.)

---

## 2026-05-05 · batch 5 — scene-state mirror + speaker tag (Q-1 W1) · Bug #8 ✓ closed

GM replied Q-1 ✅ approving `# speaker: <id>` tag convention with an authoritative id mapping table. This batch implements the W1 step: engine accepts `# speaker:` tag as the preferred bubble-anchor source, with legacy `parseSpeaker` regex retained as fallback until episodes 1-4 finish migration.

- **scene-state mirror** (`game/src/scene/scene-state-mirror.ts`, ~95 lines): single-pass cache for the latest `# scene` / `# npc` / `# time` / `# weather` / `# speaker` tag value. `installSceneStateTagHandler()` registers the listeners on the global TagDispatcher; teardown unregisters. Subscribers can `sceneState.on(key, fn)` for change events; `sceneState.get(key)` reads the latest. Warns once on unknown scene ids (workstation/phone/monitor_modal/endgame/intro/home/reception/meeting_room/cafeteria/elevator are all known).
- **NPC anchor id table** (`game/src/render/dialog/npc-anchors.ts`): added parallel id → anchor map per the GM Q-1 reply (lisa / david / vivian / wang_director / lao_zhou / zoe / li_ayi / mama / lin_jie / it_xiaoma / food_court_auntie). `protagonist` deliberately absent so the bubble doesn't render for laoxia internal voice.
- **ink-dialog routing extension**: paint chain now reads `sceneState.get('speaker')` first; if a known id is set (and ≠ protagonist), bubble mounts at `getNpcAnchorById(id)`. Falls back to `parseSpeaker` + `getNpcAnchor(name)` when no tag is present (un-migrated content).
- **Migration tool** (`tools/ink-speaker-migrate.mjs`): node script that walks `design/vertical-slice/*.ink` and prepends `# speaker: <id>` lines before every recognized speaker prefix. Idempotent (re-runs are no-ops). Dry-run by default; `--write` applies in place. Dry-run reports: 208 tags would be added across 9 ink files. Designer/GM owns whether/when to run with `--write`.
- **workstation.ts**: `installSceneStateTagHandler()` is mounted alongside the prop tag handler so `# scene:` / `# npc:` / `# time:` / `# weather:` / `# speaker:` start being recorded the moment workstation comes up.

**QA Bug #8** (no listeners for `# scene` / `# npc` / `# prop` / `# diegetic_prop`): ✓ resolved across all 5 axes (prop in batch 4; scene/npc/time/weather/speaker in this batch). Real visual transitions (T04) and NPC sprite slot wiring (T05/T06) are still future work, but the tags are no longer silently dropped.

**Q-1**: ✓ closed — engine W1 step done. Designer can run the migration script when ready; engine keeps fallback parser working until then.

**Tests**: 15 new vitest cases (10 scene-state mirror + 5 npc id table). Total 233/233.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 233/233. Lint deferred to lefthook on commit.

**Open questions / asks for GM**: Q-2 (Bug #3 fix preference) + Q-3 (Bug #6 sticky label length) still pending. None new from this batch.

(next: Q-2 reply blocks Bug #3 work; Q-3 reply blocks any sticky-note label rewrite. While waiting, picking from: T04 scene registry + transitions, T05/T06 NPC sprite slot scaffolding, or T13 day scheduler. Recommend T04 since `sceneState.scene` is now the natural input — changing scene id triggers transition.)

---

## 2026-05-06 · batch 6 — Q-2 `# pagebreak` + Bug #3 ✓ closed

GM Q-2 reply: ✅ Option B (`# pagebreak` tag). This batch implements the runtime + dialog wiring; designer's job is sprinkling `# pagebreak` lines per the GM tagging policy table (already started — `episode_1` knot in `episode-1.ink` got one between the intro/episode-start tags and the divert to `day_1_morning_briefing`).

- **runtime.ts**: `InkStoryStep` gains `paused: boolean`. `step()` loops `Continue()` until canContinue=false OR a chunk's tags include `pagebreak`. On pagebreak, the chunk + tags are stashed on `pendingChunk` / `pendingTags` (intra-session state) and step returns paused=true with text accumulated *before* the pagebreak. Next `step()` drains the stash first (the `pagebreak` tag itself is filtered out — its job is done) then resumes `Continue()` until next break or choice. `loadStory` / `loadStoryFromJson` / `loadState` / `resetState` clear pending state so save round-trips don't leak stale chunks.
- **ink-dialog.ts**: new `advanceContinue()` (no autosave — saves stay at choice boundaries; pendingChunk is intra-session only). New `renderContinueAffordance()` paints a small `▼` at the panel's bottom-right and an invisible click hit-rect spanning the whole panel rect, so a tap anywhere advances the beat. `paintStep` mounts the affordance instead of stickies when `step.paused`.
- **Idiom**: standalone `# pagebreak` on its own line between the last beat text and `-> next_stitch`. Tag attaches to the next chunk; engine stashes it so the player sees a clean break of the *previous* beat. Inline placement (`text. # pagebreak`) also works (tag attaches to the same chunk).
- **Tests**: 9 new vitest cases in `tests/ink/pagebreak.test.ts` covering inline + standalone idioms, back-to-back pagebreaks, legacy story shape, paused-with-content-ahead semantics, pagebreak-tag stripping on resume, loadState clearing pendingChunk. Smoke tests refactored with `drainFrom()` helper since `episode-1.ink` now contains pagebreaks.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 242/242. Lint via lefthook.

**QA Bug #3** (recap blob): ✓ resolved. Bug #6 still discussion-status pending sticky-fit work.

---

## 2026-05-06 · batch 7 — Q-3 sticky-note 2-line + ellipsis · Bug #6 engine-side ✓ closed

GM Q-3 reply: ✅ Option D (2-line wrap + ellipsis). This batch enforces the cap; content sweep on long labels (mechanism-disclosure violations of Pillar-3) is a P6 designer-driven follow-up.

- **sticky-notes-layout.ts**: 3 new pure helpers — `visualCharWidth(ch)` (CJK + full-width punctuation count 2 half-width units, ASCII counts 1), `visualWidth(text)` (sum), `estimateFitLength(text, maxLines, unitsPerLine)` (longest prefix that fits within `maxLines * unitsPerLine` units leaving room for the ellipsis). Style block grew to expose `MAX_LINES`, `UNITS_PER_LINE`, `ELLIPSIS`.
- **mountSingleSticky** measures actual `Pixi.Text.height` after wrap. If it exceeds `MAX_LINES * LINE_HEIGHT`, the visual-width estimate yields the initial truncation point; if Pixi's measured height still overflows (font-metric drift), the loop trims one char before the ellipsis until it fits. No hover/tap reveal — taps are reserved for choice selection.
- **Tests**: 14 new vitest cases — `visualCharWidth` ASCII / CJK / full-width punctuation, `visualWidth` sums (incl. mixed CJK + ASCII labels like `'申报加班 -10 状态'` = 17 units), `estimateFitLength` boundary cases (full-fit, CJK truncation, single-char doesn't fit, ASCII-heavy labels, empty input). Plus a style-pin test for the new `MAX_LINES` / `UNITS_PER_LINE` / `ELLIPSIS` constants.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 253/253. Lint via lefthook.

**QA Bug #6** (>6-char choice labels): ⚙️ engine-side ✓ resolved (sticky now truncates cleanly with `…`). Content-side sweep (P6) is on the designer backlog — `[申报加班 -10 状态 +2 AP 等价]` should become `[申报加班]` per Pillar-3, NOT just shorter. Engine accommodates either way.

**Open questions / asks for GM**: none — Q-1, Q-2, Q-3 all closed. Next batch picks from the regular P1 backlog.

(next: T04 scene registry + transitions is the natural step — `sceneState.scene` mirror is the input, T04 is the consumer that actually mounts/unmounts a phone / monitor_modal / endgame composer when the tag changes. Or T05/T06 NPC sprite slots so `npc-anchors.ts` becomes a sprite-position binding. Will pick whichever has cleaner blast radius next batch.)

---

## 2026-05-06 · batch 8 — /loop tick 1 — commit Bug #1+#2 + Bug #16 stub-anchor re-tune

W1 (engine) /loop dynamic-paced tick 1. Read `p5-phase2-engine-bug-reports.md` and `p5-phase2-engine-questions.md`, picked unresolved tasks by priority block > major > minor.

- **Bug #1 + #2** (block, content fix) ✓ committed at `7ded1bd` — `fix(qa-bug-1,2): commit episode-1.ink content fixes verified by QA Round 3`. The content edits (gather between Event 2.3 choice block and continuation; drop `**` from David line at 643) were already in the working tree of `episode-1.ink` (file was untracked). QA Round 3 verified both reproducers no longer fire; this commit puts the file under git tracking. NOT included: sweep of episode-2/3/4/5/6/7/8.ink for similar loose-end patterns — designer scope per handoff §5.
- **Bug #16** (major UX, stub anchors) ✓ resolved (interim) at `<batch 8 hash>` — `fix(qa-bug-16): re-tune NPC anchor stubs to narrative geometry`. `npc-anchors.ts` updated for both `NPC_ANCHORS` (Chinese name fallback) and `NPC_ANCHORS_BY_ID` (Q-1 id primary path):
  - 老周 540/160 (right-mid, further right than Lisa)
  - David 180/160 (mid-left across the room)
  - Vivian 440/80 (reception entrance, top-right)
  - 王总监 320/80 (mid-top projector)
  - Lisa 480/130 (right-near adjacent cubicle, was 470/110)
  - 李阿姨 120/250 (bottom-left cleaning)
  - IT 小马 140/210 (coffee machine lower-left)
  - Zoe 260/80, 林姐 200/130, 妈妈 320/180, food_court_auntie 320/200
  - Real fix still lands at T05/T06 NPC sprite slot wiring (these stubs go away then).

**Verify**: `pnpm tsc` ✓, dialog tests 34/34 ✓.

**Open major bugs after this tick**: #13 (sticky/narration overlap, Option B confirmed by GM), #14 (phone prop persists across scenes, T04 sub-task), #15 (sprite sheet label leakage, W5 owns Option A first). #11/#12/#17 are minor.

(next /loop tick: pick up Bug #13 — Option B impl in ink-dialog: when `step.choices.length > 0` AND `step.text` non-empty, show panel only with ▼ continue affordance, no sticky-notes; click ▼ → step() again until `step.text` empty, then mount sticky-notes alone. ~1-2h work, biggest UX impact.)






