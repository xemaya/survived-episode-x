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

---

## 2026-05-06 · batch 9 — /loop tick 2 — Bug #13 deferred-choices flow + Bug #17 likely-resolves

W1 (engine) /loop dynamic-paced tick 2. Picked Bug #13 (major UX, GM-confirmed Option B).

- **dialog-phase.ts** (~95 lines, NEW): pure helper. `decideDialogPhase()` returns one of 7 phases (`ended`/`paged`/`deferred-choices`/`header-band`/`choices-only`/`narration-only`/`empty`) based on `{ remainingTextTrimmed, step, shortPromptThreshold }`. `SHORT_PROMPT_THRESHOLD = 60` chars (tunable). Pure function — vitest-able without Pixi.
- **ink-dialog.ts paintStep** refactor: layer 3 (panel + rack + ▼) replaced with `switch (phase)` on the helper's output:
  - `deferred-choices` (text ≥ 60 chars + choices): park step on `deferredChoicesStep`, render panel + ▼; click flushes panel and mounts sticky rack alone.
  - `header-band` (short text + choices): no panel, narration as centered Text at `y=200` above the sticky rack, rack mounts simultaneously. No ▼ gate. Decision-Moment style.
  - `choices-only`, `narration-only`, `paged`, `ended`, `empty`: existing render paths preserved.
- **ink-dialog.ts advanceContinue** extended with two cases: (1) flush deferred-choices (transition phase A→B in same step, no ink advance), (2) pagebreak resume (existing — drives `ink.step()`).
- **headerBand Text node**: bottom-anchored at `(CANVAS_W/2, 200)`, max width 480 px, font 12 / lineHeight 16, center-aligned. Sits just above sticky rack center y=248.

QA Bug #13 ✓ resolved. QA Bug #17 (narration outside panel bounds) ✓ likely resolved as a side-effect (panel hidden whenever rack is up). Re-verify next QA round.

Tests: 12 new vitest cases in `tests/render/dialog/dialog-phase.test.ts` covering all 7 phases + boundary at threshold + pagebreak override + custom threshold + Day 1 Event 1.2 reproducer + Decision-Moment short prompt. Total 266/266.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 266/266.

**Open major bugs after this tick**: #14 (phone prop persists across scenes — T04 sub-task or PropRegistry teardown trigger), #15 (sprite sheet label leakage — W5 owns Option A first, W1 fallback Option C). Plus Q-4 path interceptor (not blocking until E8/E12 finale paths are exercised).

(next /loop tick: pick up Bug #14 — implement PropRegistry scene-bound teardown so phone/fruit_bowl unmount when `# scene` tag changes. Probably adds `scope: 'scene' | 'permanent'` field to PropEntity + a `sceneState.scene` listener that destroys non-permanent props on change.)

---

## 2026-05-06 · batch 10 — /loop tick 3 — Bug #18 stale-bubble flush

W1 (engine) /loop dynamic-paced tick 3. QA Round 5 surfaced Bug #18: when a step blob spans multiple events (Lisa speaks at Event 2.1 → narration through 2.2 → 老周 choices at 2.3), Lisa's bubble mounts at paintStep start but lingers when the deferred-choices flush dismisses the panel and mounts the 老周 sticky rack.

- **ink-dialog.ts advanceContinue (case 1, deferred-choices flush)**: now also calls `clearBubble()` + `clearMonologue()` + `clearHeaderBand()` before mounting the sticky rack. Narration-bound overlays unmount with the panel they belonged to. One-line fix (3 calls) at the dismiss boundary.
- Pagebreak resume (case 2) didn't need the same fix — `paintStep` already starts with those three clears, so the next paint after a pagebreak naturally rebuilds bubble/monologue from the new step.

QA Bug #18 ✓ resolved. Note: with QA Bug #3 (recap blob) ✓ resolved via `# pagebreak` policy, multi-speaker step blobs should be rare (each pagebreak carves one speaker per paint), so this fix is mostly for residual transitions where pagebreak hasn't been added.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 266/266 (no new tests needed — behavior change is exercised end-to-end by the existing dialog-phase suite + the deferred-flush callsite is dispatch-only).

**Open major bugs after this tick**: #14 (phone prop persists across scenes — meatier than initially scoped; needs PropEntity `scope` field + scene-mirror teardown listener + workstation re-mount semantics, last bit gated on T04 scene registry), #15 (sprite sheet label leakage — W5 owns Option A first).

(next /loop tick: still Bug #14, but scoped down — add `scope: 'scene' | 'permanent'` to PropEntitySpec + a `propRegistry.destroyScopedTo(scope)` method + a `sceneState.on('scene', …)` listener that fires the destroy. Accept the "won't re-mount on return-to-workstation" limitation until T04 lands; designer can use `# prop: phone_face_down` to bring it back if needed.)

---

## 2026-05-06 · batch 11 — /loop tick 4 — Bug #14 prop scope + scene-aware hide/show

W1 (engine) /loop tick 4. Bug #14 (phone prop persists across scene changes; covers Day 1 daily_recap text). Final approach is hide-not-destroy: scene-scoped props start invisible, become visible on any `# prop:` tag, and auto-hide on `# scene:` tag value change. No re-mount semantics needed — the next prop-tag emission handles re-showing.

- **prop-entity.ts**: new `PropScope = 'permanent' | 'scene'` type + optional `spec.scope` field (default `'scene'`). `PropEntity` interface gains `readonly scope`, `readonly visible`, `setVisible(b)`. `setState()` now sets `sprite.visible = true` UNCONDITIONALLY (even when the requested state matches the current one) so designer can re-emit the same tag to wake a hidden prop. Initial sprite.visible = (scope === 'permanent') so scene-scoped props start hidden.
- **prop-registry.ts**: new `hideScopedTo(scope)` method iterates entities and calls `setVisible(false)` on matching ones. Returns count for tests/debug. Entities are NOT unregistered.
- **workstation.ts**: `sceneState.on('scene', () => propRegistry.hideScopedTo('scene'))` listener wired alongside the existing tag handlers. On every `# scene:` value change, all transient props hide.
- **Lifecycle for fruit_bowl + phone**: register with default `scope: 'scene'` → hidden at boot → ink fires e.g. `# prop: fruit_bowl_apple` at Day 1 Event 1.1 → fruit_bowl visible. Subsequent `# scene:` change (e.g. break_room) → fruit_bowl hidden again. Day 1 daily_recap (`# scene: home_phone_screen`) → phone hidden (it was already hidden because the only phone tag in current ink is at Day 2 Event 2.2, AFTER recap).
- **Permanent props (mug/monitor/calendar)**: still bound directly to game state singletons, NOT routed through the registry yet. Their visibility is unaffected by this fix. When migration happens (post-T05/T06), they register with `scope: 'permanent'`.

Tests: 6 new vitest cases in `tests/render/diegetic/prop-registry.test.ts` covering scope defaults, setState auto-wake, hideScopedTo per-scope filtering, post-hide re-show via tag. Total 272/272.

QA Bug #14 ✓ resolved. The recap reproducer no longer collides because phone is hidden by the time recap renders.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 272/272.

**Open major bugs after this tick**: #15 (sprite sheet label leakage — W5 owns Option A first; W1 fallback Option C is a Pixi-side crop mask). Open minors: #7 discussion, #10 paint desync, #11 reload `…` placeholder, #12 sceneState single-slot. Plus Q-4 path interceptor still pending W1 pickup (not blocking until E8/E12 finale).

(next /loop tick: pick from Q-4 path-interceptor.ts (T20 prep, ~30 lines) OR Bug #11 T16 follow-up (persist last-rendered narration text in save). Q-4 cleaner architectural work, Bug #11 smaller. Will pick whichever is most context-fresh on next tick.)

---

## 2026-05-06 · batch 12 — /loop tick 5 — Q-4 path-interceptor (T20 prep)

W1 (engine) /loop tick 5. Picked Q-4 since all W1 majors are now closed (#15 stays W5-first). Implements the registry that lets E8/E12 finale stitches redirect to path-D/path-E branches based on accumulated game state, without the player seeing those branches as `* [...]` choices.

- **path-interceptor.ts** (~95 lines, NEW): `PathInterceptor` class + `pathInterceptor` singleton. `register({ beforeStitch, condition, target, label? })` returns an unregister fn. `shouldRedirect(stitchName, ctx)` is a pure dispatch — first-rule-wins, no prefix matching, exact stitch name equality.
- **runtime.ts** Continue loop: when a chunk's tags include `# checkpoint: <stitch>`, the runtime looks up the redirect; if condition resolves true, calls `story.ChoosePathString(target)` and discards the chunk so default-path text never reaches the player. Continue from new path on next iteration.
- **Pivot from initial spec**: GM ask suggested polling `story.state.currentPathString` at step() top. Empirical trace showed that's an internal program-counter index (`"0"` / `"day_56_event_3.2"`), not the stitch name. Tag-based hook (designer emits `# checkpoint: <stitch_name>`) is reliable and explicit. Updated the Q-4 doc with the new authoring pattern.
- **Tests**: 13 new vitest cases in `tests/ink/path-interceptor.test.ts` — 9 pure helper unit cases (register/unregister, condition true/false, exact match, var read, multiple rules, clear/list) + 4 InkRuntime integration cases (redirect on checkpoint match, no-op on condition fail, no-op on unknown stitch tag, chained redirects). Total 285/285 (was 272 — +13).

Q-4 ✓ closed. Engine API ready for W3 / S3 ink writer to use when they author E8 D56 / E12 finale stitches with `# checkpoint:` markers.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 285/285.

**Open after this tick** — only minors remain:
- Bug #7 discussion (designer scope)
- Bug #10 paint desync (low priority)
- Bug #11 reload `…` placeholder (T16 follow-up)
- Bug #12 sceneState single-slot (was gated on Bug #3, which is now resolved — re-evaluate next tick)
- Bug #15 sprite label leakage (W5 owns Option A first)

(next /loop tick: re-read bugs to see if any new ones land; if not, pick Bug #11 small fix (persist last-rendered narration text in `inkStateJson` companion field) OR Bug #12 status-update (pure doc edit acknowledging Bug #3 fix already addresses it). If still no new majors, output "no task, idle".)

---

## 2026-05-06 · batch 13 — /loop tick 6 — Bug #11 reload narration restore (T16 follow-up)

W1 (engine) /loop tick 6. All majors closed; picking minor Bug #11 (T16 follow-up). Implements the "store last-rendered text" approach so reload doesn't show `...` when ink has nothing left to drain.

- **dialog-state.ts** (~30 lines, NEW): `dialogState` singleton with `lastNarrationText` getter / `setLastNarrationText(text)` / `reset()`. Lives outside ink-dialog's mount closure so the save layer can read it.
- **ink-dialog.ts**: new `setPanelText(raw)` helper that sets `text.text = raw` AND publishes to `dialogState.lastNarrationText` (filtering empty strings + the `'...'` placeholder). All paintStep branches that paint real panel content (`'ended'`, `'paged'`, `'deferred-choices'`, `'narration-only'`) use it. `'header-band'` publishes the header content directly. New `firstPaintAfterMount` closure flag gates the restore-fallback in the `'choices-only'` branch — synthetic `'deferred-choices'` path renders the saved narration + ▼ when present.
- **schema.ts**: `lastNarrationText: z.string().optional()` field. Optional so older T16 saves stay valid.
- **snapshot.ts**: imports `dialogState`, captures `lastNarrationText` when non-empty.
- **main.ts**: after `ink.loadState`, calls `dialogState.setLastNarrationText(restored.lastNarrationText)` so the ink-dialog mount sees it on first paint.

Tests: +8 vitest cases (`dialog-state.test.ts` 6 unit + 2 new save round-trip cases). Total 293/293 (was 285).

QA Bug #11 ✓ resolved. Reload mid-flow now restores the last narration in panel + ▼ instead of `...`. Click ▼ reveals the still-pending choices via the existing `advanceContinue` deferred-flush path.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 293/293.

**Open after this tick**:
- Bug #7 discussion (designer scope)
- Bug #10 paint desync (low priority — only headless screenshot)
- Bug #12 sceneState single-slot (was gated on Bug #3, NOW resolvable as a doc-only status update)
- Bug #15 sprite label leakage (W5 first)

(next /loop tick: pick Bug #12 — pure status update acknowledging Bug #3 fix addresses the multi-event blob root cause. After that, output "no task, idle" unless QA files new bugs.)

---

## 2026-05-06 · batch 14 — /loop tick 7 — Bug #12 close-by-dependency (no engine change)

W1 (engine) /loop tick 7. Picked Bug #12 (sceneState single-slot during multi-event step blob). Per its severity rationale, the bug was gated on Bug #3 — and Bug #3 is now resolved via `# pagebreak`. With pagebreak between events, each `step()` carries at most one event's worth of `# scene:` / `# npc:` / `# prop:` tags, so the single-slot mirror's "latest tag wins" rule reflects "current event" correctly. No engine change needed.

- **p5-qa-bug-reports.md** Bug #12 status updated to ✓ resolved (by gating dependency).
- Documented the GM tagging policy table from Q-2 as the designer-side ongoing concern: if a sweep misses an event boundary in episodes 1-4, the mirror still drifts through that blob — but the fix is content-side, not engine.
- Engineering note: a multi-slot mirror (e.g. `npc: Set<string>`) was considered but rejected — it pushes "which NPC is currently visible" decisions to the consumer with per-layer policy. Single-slot + designer pagebreak coverage gives a clean contract.

No code change. Tests still 293/293.

**Open after this tick**:
- Bug #7 discussion (designer scope)
- Bug #10 paint desync (low priority — only headless screenshot timing)
- Bug #15 sprite label leakage (W5 owns Option A first)

All W1-scope tasks closed. Next /loop tick will likely output "no task, idle" unless QA Round 6+ files new bugs or GM lands new questions.

(next /loop tick: re-read both docs; if no new W1-scope task, output "no task, idle".)

---

## 2026-05-06 · batch 15 — /loop tick 8 — Bug #19 monologue retune + Bug #18-regression dominant-speaker

W1 (engine) /loop tick 8. QA Round 6+ filed two new majors: Bug #19 (monologue Z-overlap with panel + sticky) and Bug #18-regression (bubble persists across multi-paragraph step blobs into Day 4 weekly_report). Both touch the dialog area — bundled into one batch.

**Bug #19 — internal-monologue retune (GM ✅ Option A)**:
- `PROTAGONIST_HEAD_ANCHOR` (320, 240 mid-panel) → (320, 26 top region). Anchored well above panel (y=180-336) and sticky rack.
- Style per GM spec: 11pt → 10pt, lineHeight 16 → 14, color 0xe8e0cc cream → 0xa8b0c0 cool-gray, alpha 0.6 → 1.0 (dim is now intrinsic to the color).
- New `MAX_LINES: 4` + `ELLIPSIS: '…'` constants. `mountInternalMonologue.repaint` now iteratively trims a char before the ellipsis until measured `Pixi.Text.height ≤ MAX_LINES * LINE_HEIGHT`. Same pattern as the sticky-notes fit helper from batch 7.
- Lifecycle unchanged — existing `clearMonologue()` at `paintStep` top + the Bug #18 deferred-flush teardown both hold.
- Bug #20 ✓ closes as side-effect — narration (12pt cream upright bottom panel) and monologue (10pt cool-gray italic top region) are now visually distinct on position + size + color.

**Bug #18-regression — bubble dominance heuristic**:
- Root cause not "missing teardown" — `paintStep` already calls `clearBubble()` at top. The issue: SAME step's text starts with `Lisa："好，下次哈"` and continues through the next event's narration. `parseSpeaker` matches the first paragraph and mounts the bubble; it then hovers over multi-paragraph narration that's no longer about Lisa.
- Fix: new `BUBBLE_REMAINDER_THRESHOLD = 30` chars in `ink-dialog.ts`. Bubble only mounts when `parsed.remainder.trim().length <= 30` (the speaker line is the dominant content). Long blobs skip the bubble — speaker stays inline in the panel as markdown-stripped `Lisa："好，下次哈"`.
- Short Decision-Moment steps (just `Lisa："你看下这个行不行……"` + 3 choices) keep their bubble (remainder empty). Long narrative blobs across events skip the bubble.

Tests: 2 prior monologue style pins rewritten to new spec + 2 new pins (font size 10, MAX_LINES 4 / ELLIPSIS '…'). Total 295/295.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 295/295.

**Open after this tick**:
- Bug #7 discussion (designer scope)
- Bug #10 paint desync (low priority)
- Bug #15 sprite label leakage (W5 owns Option A first, was promoted by GM)

(next /loop tick: re-read; if QA hasn't filed new bugs and Bug #15 still W5-scope, output "no task, idle".)

---

## 2026-05-06 · batch 16 — /loop tick 9 — Bug #15 Option C (Pixi-side crop)

W1 (engine) /loop tick 9. Bug #15 has been "open" since R5 with W5/W1 split — W5 owned Option A (re-cut sheets) but didn't act in R6/R7/R8/R9 and GM "promote priority" because the leaked "Front" + "9:00" labels show in every fruit_bowl frame. Picked up Option C (Pixi-side crop) so the demo isn't visibly broken while waiting for the source-side fix.

- **prop-entity.ts**:
  - New `PropCropEdges = { top?, right?, bottom?, left? }` type on `PropEntitySpec`.
  - New pure helper `computeCropFrame(sourceW, sourceH, edges)` — returns null when no crop applies (undefined / all-zero / empty), otherwise the inner-rect coords clamped to ≥1 px on each axis. Vitest-able without Pixi.
  - New `applyCropEdges(base, edges)` builds a `Texture` sharing `base.source` with a narrowed `Rectangle` frame. Cheap — bitmap reused, only metadata changes.
  - `createPropEntity` calls `applyCropEdges` on initial mount and on every `setState` texture swap so all states of a prop get the same trim.
- **workstation.ts**: fruit_bowl now mounts with `cropEdges: { top: 80, bottom: 80 }`. Source PNGs are 341×844; symmetric trim hides "Front" label at top + "9:00" timestamp at bottom without shifting the visible content's vertical center relative to the sprite anchor (0.5/0.5).
- **W5 migration plan**: when Option A lands (re-cut sheets without baked labels), `workstation.ts` drops the `cropEdges` line — `applyCropEdges` no-ops when the spec is gone. The helper stays in `prop-entity.ts` for future use cases (other props that leak labels).

Tests: 7 new vitest cases in `prop-registry.test.ts` for `computeCropFrame`. Total 302/302.

QA Bug #15 ✓ resolved via Option C.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 302/302.

**Open after this tick**:
- Bug #7 discussion (designer scope)
- Bug #10 paint desync (low priority — only headless screenshot timing)
- Bug #20 design observation (gated on tone-bible / authoring discipline call)

All W1-actionable bugs closed. Remaining items are designer scope or low-priority discussion.

(next /loop tick: re-read; if no new W1-scope task, output "no task, idle".)

---

## 2026-05-06 · batch 17 — /loop tick 10 — Bug #20 close-by-Bug-#19 dependency (no engine change)

W1 (engine) /loop tick 10. Bug #20 was the last open W1-touchable item — discussion-status, gated on Bug #19 fix approach. Bug #19's GM ✅ Option A landed in batch 15 (`fafa078`) and is exactly the "monologue is dimmer / smaller / background-positioned" path Bug #20 listed as one of two acceptable resolutions:

- Position: top region (320, 26) — physically above narration panel + sticky rack
- Size: 10pt vs panel's 12pt
- Color: cool-gray #A8B0C0 vs panel's cream #E8E0CC
- Style: italic
- 4-line cap with ellipsis

Three visual axes + one stylistic axis make narration ↔ monologue distinguishable at a glance.

- **p5-qa-bug-reports.md** Bug #20 status updated to ✓ resolved (engine side).
- Documented the second resolution path (designer authoring discipline: `# pagebreak` between narration and monologue paragraphs) as P6 backlog content-side optimization, NOT engine-blocking.

No code change. 302/302 tests still green.

**Open after this tick**:
- Bug #7 discussion (designer scope: 提前下班 in Preact vs ink — design choice on canonical after_work UI)
- Bug #10 minor (paint desync — only headless screenshot timing, low priority)

Both are non-W1-actionable. **All W1-actionable bugs and questions are now closed.**

(next /loop tick: re-read both docs; if QA hasn't filed new bugs and GM hasn't filed new questions, output "no task, idle".)

---

## 2026-05-06 · batch 18 — /loop tick 11 — Bug #21 + Bug #22 episode-end exit + render fix

W1 (engine) /loop tick 11. Two new block-UX bugs filed (#21 + #22). Both touched `paintStep`'s `'ended'` phase; bundled into one batch.

- **Bug #22 root cause** was twofold:
  1. Episode-end recap text is authored as italic (`_今日 KPI: +0_` etc.). `extractInternalMonologue` lifted those whole-italic paragraphs into the top-region monologue overlay (per Bug #19's y=26 retune), leaving the panel `trimmedPanel` empty → `setPanelText` fell back to `'...'` and `drawPanelBg` was conditionally skipped.
  2. `'ended'` branch mounted a `renderChoiceButton('（剧本结束）', -1, CANVAS_W/2, PANEL_Y - 16)` at `(320, 166)` — pre-T11 mid-canvas position, not post-T11 sticky rack at y=265.
- **Fix**: `paintStep` now skips `extractInternalMonologue` when `step.ended` (recap text stays in panel as written). `'ended'` branch sets panel + draws BG as usual, then mounts a single-slot `mountStickyNotes` with `[新游戏]` at desk surface — same visual idiom as choice racks, no special pseudo-button.
- **Bug #21**: `[新游戏]` click handler `triggerNewGame()` does the brutal-but-reliable hard-restart pattern — `await save.clearCurrentRun()` → `dialogState.reset()` → `window.location.reload()`. Boot then takes the no-save branch in `main.ts` and ink diverts to `intro` cleanly. Smoother "soft restart" UX (no page flash) would need per-singleton reset wiring (energy / kpi / ap / calendar / flow) which is bigger than this batch's scope; punt to P6.

No new test files — behavior change is at dispatch sites; existing dialog-phase + sticky-notes suites cover the surrounding paths. Total still 302/302.

QA Bugs #21 + #22 ✓ resolved.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 302/302.

**Open after this tick**:
- Bug #7 discussion (designer scope)
- Bug #10 minor (paint desync, low priority)

Both non-W1-actionable. **All W1-actionable bugs closed again.**

(next /loop tick: re-read; if no new W1-scope task, output "no task, idle".)

---

## 2026-05-06 · batch 19 — /loop tick 12 — Bug #23 partial (morning_briefing card removed)

W1 (engine) /loop tick 12. QA Round 12+ filed 7 new bugs (#23-#29). Picked Bug #23 — block onboarding, GM ✅ delete morning_briefing card. Tutorial modal (the second half of the spec) punted to a later batch since it needs its own design pass on the explainer text.

- **day-cycle.ts**: `confirmRecap` + `confirmKpiReview` pass-branch transit DIRECTLY to `action_day`, bypassing `morning_briefing`. Comments updated.
- **transitions.ts**: legalizes `recap → action_day`, `kpi_review → action_day`, `main_menu → action_day`. Old transitions to `morning_briefing` stay for back-compat but the live flow never takes them.
- **ui-overlay.tsx**: drops `MorningBriefing` import; `'morning_briefing'` case returns `null`; `hasOverlay` no longer includes it.
- **main-menu.tsx**: 新游戏 click → `action_day, day:1, phase:'morning'`.
- **main.ts**: boot path auto-bridges restored `morning_briefing` saves to `action_day`.
- `morning_briefing` FSM state stays in `scene-state.ts` enum (back-compat).

Tests: 6 day-cycle / transitions cases updated (assertions flipped from `morning_briefing` to `action_day`; legality tests changed `false` → `true`; test setup no longer goes through morning_briefing). Total 302/302.

QA Bug #23 ✓ resolved (card removal half). Tutorial modal half deferred.

**Verify**: `pnpm tsc` ✓, `pnpm test` ✓ 302/302.

**Open after this tick** (QA Round 12+ filed a lot):
- Bug #23 second half — first-time tutorial modal
- Bug #24 (auto-split on speaker line — engine-side runtime change)
- Bug #25 (Bug #13 reverse — panel + sticky coexist; panel 156 → 96)
- Bug #27 (delete AP system — engine cleanup, ~1-2h)
- Bug #29 (Status HUD top-right + effect flash)
- Bug #26, #28, #30 (polish / backlog)
- Bug #7 / #10 (designer / low priority)

(next /loop tick: pick from #25, #24, #27, #29 — major UX or block design. Probably #25 first since it's the smallest and unblocks demo readability.)

---

## 2026-05-06 · batch 20 — Bug #27 (delete AP system, engine cleanup)

Bug #27 was filed as a **design block**: AP (10/day, refilled at recap) is a holdover from the P0-P4 card-driven prototype. The Ink-driven flow consumes time slots inside the .ink narrative itself (no AP gate at the FSM level), and the design pivot retired the "card play has AP cost" abstraction. Keeping AP around was confusing — the HUD slot row, "+2 AP" overtime badge, and "今日还剩 N AP" copy all suggested a system the design no longer has.

**Scope**: surgical removal of AP-the-resource while keeping the **effort counters** (overtime / hero / overage) which still feed KPI Review Formula B.

### Engine changes

- **Deleted** `game/src/economy/ap.ts` (the entire ApSystem singleton).
- **New** `game/src/economy/effort.ts` — `EffortSystem` with the three effort counters + `reportOvertime()` / `reportHeroCardPlayed()` / `reportOverage()` / `resetEffortCounters()` / `setEffortForRestore()`. Singleton exported as `effort`. This is exactly the effort half of the old ApSystem, lifted out and renamed.
- **`game/src/economy/constants.ts`** — removed `BASE_AP_PER_DAY` (8) and `OVERTIME_BONUS_AP` (2). Added one-line comment explaining the field deletions for future readers.
- **`game/src/flow/day-cycle.ts`** — `DayCycleDeps.ap` → `DayCycleDeps.effort`. The `ap.onChanged(... if (current === 0) → after_work)` listener is **gone**; `controller.endDayEarly()` is now the sole path into `after_work` (matches Bug #23 / Q-2 — player-driven exit). `confirmAfterWork('overtime')` no longer grants `+2 AP`; it only spends energy and bumps `effort.effortOvertime`. `confirmRecap()` no longer calls `ap.resetForNewDay()`. `confirmKpiReview()` reads `effort.effortX` and calls `effort.resetEffortCounters()` on the pass branch.
- **`game/src/save/{snapshot,restore,schema}.ts`** — `apCurrent` is now an **optional** schema field (not removed from the schema, so older saves with the field still parse cleanly via forward-compat). Snapshot no longer captures it; restore no longer applies it; `defaultRunState()` no longer sets it.
- **`game/src/render/scene/workstation.ts`** — deleted the `SHOW_LEGACY_HUD` AP slot row Container (and `STICKY_X/Y/SIZE/GAP` constants). The mug 5-frame status sticky is the survivor; the AP row was the last vestige of the legacy HUD.
- **`game/src/render/menu/after-work.tsx`** — removed the "今日还剩 N AP" status row; overtime button now reads `申报加班 (-15 精力)` (no AP bonus). `OVERTIME_BONUS_AP` import removed.
- **`game/src/render/menu/daily-recap.tsx`** — removed the "AP 消耗" recap row. Recap shell + auto-progress + skip hint kept (still useful as a beat between days; AVG flow may repurpose).

### Tests

- **Deleted** `tests/economy/ap.test.ts` and `tests/economy/ap-effort.test.ts`.
- **New** `tests/economy/effort.test.ts` — 14 cases covering the new EffortSystem singleton + the surviving `computeEffortNorm` math (lifted from the old ap-effort.test.ts).
- **`tests/flow/day-cycle.test.ts`** — full rewrite. Trigger into `after_work` is now `controller.endDayEarly()` instead of `ap.spend(8)`. Removed: `confirmMorningBriefing`-throws case, `confirmRecap` `ap.current === 8` assert, `detach() unsubscribes from ap` case (no longer applicable). Updated 14 cases total.
- **`tests/save/schema.test.ts`** — `parses defaultRunState` now asserts `apCurrent` is **undefined**; added a forward-compat case proving older saves with `apCurrent: 5` still parse cleanly; "rejects negative AP" kept (legacy field still validated when present).
- **`tests/save/system.test.ts`** — round-trip witness changed from `apCurrent` to `kpiActual`/`energyCurrent` (since `apCurrent` is no longer set in the default state).

### Verification

- `pnpm tsc` — clean (no errors).
- `pnpm test` — **289/289 passing** (down from 302; net -13 reflects the deleted ap.test.ts and ap-effort.test.ts cases minus the new effort.test.ts cases plus rewritten day-cycle cases).

### What this unblocks

- The HUD is now physically free of the AP slot row → Bug #29 (Status HUD top-right + effect flash) has a clean canvas to land on next tick.
- After-work overlay is one button (申报加班) + one button (按时下班) without the now-confusing "+2 AP" prompt → Bug #7's designer scope ("does 提前下班 stay?" — discussion ongoing) can be answered without backlog cruft.
- Schema is forward-compat: any saves players made during the AP era still load (apCurrent stays optional in the zod schema).

### Open after this tick

- Bug #25 (panel + sticky coexist; panel 156 → 96 reverse of #13)
- Bug #24 (auto-split on speaker line — engine runtime change)
- Bug #29 (Status HUD top-right + effect flash — now unblocked since AP slot row is gone)
- Bug #23 second half — first-time tutorial modal
- Bug #26 (Pixi calendar widget polish)
- Bug #28 (T04/T05/T06 backlog — workstation BG / NPC sprites)
- Bug #30 (gated on tutorial modal)

(next /loop tick: probably Bug #25 — small/local panel-sizing tweak, or Bug #29 since it's now unblocked.)

---

## 2026-05-06 · batch 21 — Bug #25 (panel + sticky coexist, reverse Bug #13)

GM 决定反转 Bug #13 Option B (panel-hides-when-sticky-mounts) → Option A (both visible). Reasoning per the bug report: AVG 标准是 "对话框不动，选项浮上方，选完整对话继续" — defer-on-tap UX is unfriendly when the player wants to glance at narration while reading the choices.

**Approach** (per spec): panel shrinks instead of hides, sticky rack moves up to desk surface so they don't overlap.

### Engine changes

- **`game/src/render/dialog/ink-dialog.ts`** — `PANEL_H: 156 → 96`. Panel now occupies y=256-352 (bottom strip). Comment block updated to walk through the size history (130 → 156 for Bug #4 → 96 for Bug #25).
- **`deferred-choices` phase**: rewritten. Instead of parking the step on `deferredChoicesStep`, drawing panel + ▼, and flushing on click, it now mounts panel + sticky rack **simultaneously** in a single paint. No more ▼ defer for the choice case; the player reads the panel and picks a sticky directly.
- **`choices-only` first-paint restore-narration branch**: same simplification. When ink restores into a choice point with a saved narration string, the panel paints the saved text and the sticky rack mounts alongside (no ▼ tap to reveal).
- **`paged` phase**: untouched. Explicit `# pagebreak` chunks still get the ▼ continue affordance; that's the legitimate pagination path the spec called out ("▼ 翻页机制保留").
- **`renderHeaderBand` y position**: 200 → 170 (bottom-anchored). With the rack moved up, the header needs to sit higher so the last text line baseline tucks just above the rack top edge (~175).
- **`advanceContinue`**: collapsed from a two-case dispatch to a single pagebreak path. The "deferred-choices flush" case 1 was load-bearing for Bug #13 Option B and is now dead; deleted along with the `deferredChoicesStep` parking variable, the now-unused `InkStoryStep` type import, and the resetting `deferredChoicesStep = null` line in paintStep prep.
- **`game/src/render/choice/sticky-notes-layout.ts`** — `DEFAULT_CENTER_Y: 248 → 210`. Rack span now y=175-245, sitting in the desk-surface band per art-bible §7.1 (above the keyboard area, slightly overlapping the desk surface — matches concept 02 reference).
- **`game/src/render/choice/sticky-notes.ts`** — fallback `startY` constant `248 → 210` to match the new default.

### Tests

- No test changes needed. The `decideDialogPhase` pure-helper still returns `'deferred-choices'` for the same input shapes — Bug #25 only changes how the **render layer** consumes that phase value, not the phase decision logic. Sticky-notes layout tests pass centerY explicitly so they're independent of the default.
- Full suite: **289/289 passing** (unchanged from batch 20).

### Verification

- `pnpm tsc` ✓ clean
- `pnpm test` ✓ 289/289

### What this unblocks

- The "panel hides on sticky" friction is gone — Day 1 Event 1.2 (Lisa 茶水间) and Day 2 Event 2.2/2.3 multi-paragraph events read naturally now: full narration in the bottom strip, three sticky options floating on the desk surface, no extra clicks.
- Bug #24 (auto-split on speaker line) becomes the next likely UX target — with panel + sticky coexisting, the residual UX problems are speaker-blob splitting and the Status HUD (Bug #29).

### Open after this tick

- Bug #24 (auto-split on speaker line — engine runtime change)
- Bug #29 (Status HUD top-right + effect flash — unblocked by Bug #27 AP slot deletion)
- Bug #23 second half — first-time tutorial modal
- Bug #26 (Pixi calendar widget polish)
- Bug #28 (T04/T05/T06 backlog — workstation BG / NPC sprites)
- Bug #30 (gated on tutorial modal)

(next /loop tick: probably Bug #29 — Status HUD now has a clean top-right corner thanks to Bug #27, and it's a major UX gap. Bug #24 is the alternative if the speaker-blob mixing keeps showing up in QA.)

---

## 2026-05-06 · batch 22 — Q-R 3-layer 公文报告框 dialog rewrite (architecture reset)

GM 重新校准了 design source-of-truth：`design/vertical-slice/avg-architecture.md` (NEW) 是 AVG 时代 dialog UI + daily pressure 的 canonical spec。Q-R 是按这个 spec 把 5-layer (panel/bubble/monologue/header-band/sticky) 累积架构债重写成 3-layer (panel + sticky + ▼) 公文报告框。Bug #18 / #18-regression / #19 / #20 / #24 当作架构副作用一起 close。

### Engine changes

#### 新文件
- **`game/src/render/dialog/source-detector.ts`** (~110 行 + 29 vitest cases)
  Pure helper that classifies an ink chunk into `Source = narration | monologue | npc{name}` per spec §1.4 priority:
  1. `# speaker: <id>` tag with id mapped via `SPEAKER_ID_TO_DISPLAY` (lisa→Lisa, wang_director→王总监, food_court_auntie→食堂阿姨, etc; `protagonist` → monologue).
  2. Legacy `**Name**：…` / `Name：…` prefix on the first line (with 大伟→David / 周哥→老周 alias normalization).
  3. Whole-italic `_…_` paragraph → monologue.
  4. Default → narration.
  Exports `detectSource()` + `sourcesEqual()` + `sourceLabel()` (returns `视角 / 笑天 / <NPC display name>` for the panel header bar).

#### Runtime auto-split (avg-architecture.md §1.4)
- **`game/src/ink/runtime.ts step()`** — when an accumulating step's already-claimed source ≠ next chunk's source, the chunk is stashed via the existing pendingChunk machinery and step() returns paused=true. The pause shows up to the renderer as the same "▼ continue" affordance as a `# pagebreak`. Whitespace-only chunks pass through (they don't define a source on their own; staying with the accumulated source avoids no-op narration paints). New `tests/ink/source-split.test.ts` covers 7 cases (narration→monologue split, narration→NPC tag split, NPC→NPC split, same-source pass-through, NPC same-name pass-through, blank-line pass-through, explicit `# pagebreak` interaction).

#### Dialog phase simplification (avg-architecture.md §1.8)
- **`game/src/render/dialog/dialog-phase.ts`** — collapsed `empty / ended / paged / deferred-choices / header-band / choices-only / narration-only` (7) → `ended / choice / narration` (3). The render layer always mounts the panel; phase only decides what surfaces sit alongside.
- `SHORT_PROMPT_THRESHOLD` constant deleted (no header-band path anymore).
- `tests/render/dialog/dialog-phase.test.ts` rewritten: 12 cases covering the 3-phase trichotomy + the spec's two reproducer scenarios (Day 2 茶水间 multi-source post-auto-split narration paint, typical decision-moment choice paint).

#### ink-dialog.ts paintStep rewrite
- **stateless paint** (§1.7): every paint top unconditionally tears down sticky rack + ▼; bottom mounts fresh per phase.
- **panel** is always built fresh from `(source, body)` via `drawPanel()` — header bar BG (HEADER_BAR_BG `#3D4A5A` darker than panel BG, 18 px tall) + divider line (`#2A1F14` 1 px) + header label `[ 视角 ]` / `[ 笑天 ]` / `[ Lisa ]` (11pt cream) + body (13pt, cream upright for narration/NPC, cool gray `#A8B0C0` italic for monologue).
- Panel geometry snaps to spec: y=240-336 (96 tall), border `#2A1F14`, BG `#5A7080` cubicle navy + alpha 0.85.
- Phase handlers:
  - `ended`: panel + single sticky `[新游戏]` (hard-restart pattern unchanged).
  - `choice`: panel (with current source body, OR restored last-narration on first-paint-after-mount when step.text empty) + sticky rack. No ▼ defer (Bug #25 already established panel+sticky coexist; Q-R extends it).
  - `narration`: panel only. ▼ continue affordance shows whenever step is `paused` (auto-split or pagebreak) OR `canContinue` with non-empty body. Empty + canContinue auto-advances inline (no stuck `...`).
- File shrunk: 540 lines → 343 lines (-197 LOC after stripping bubble/monologue/header-band machinery).

#### Sticky position snap to spec
- **`sticky-notes-layout.ts`** `DEFAULT_CENTER_Y`: 210 → 205 (rack span y=170-240 — exactly tangent to the new panel top edge at y=240).
- **`sticky-notes.ts`** fallback startY tracked.

#### Scene-state mirror comment touch-up
- Updated speaker-field doc to note that source detection now lives in `source-detector.ts`; the field is kept for future T05/T06 NPC sprite-slot mounting (the renderer no longer reads it).

### 删除的文件
| 文件 | LOC | 替代物 |
|---|---|---|
| `src/render/dialog/speech-bubble.ts` | 106 | inline panel (NPC speech 进 panel + header bar `[Lisa]`) |
| `src/render/dialog/speech-bubble-layout.ts` | 116 | (no replacement — bubble layer 不存在) |
| `src/render/dialog/npc-anchors.ts` | 106 | (anchor 数据回归 T05/T06 NPC sprite slots when those land) |
| `src/render/dialog/speaker-parser.ts` | 46 | `source-detector.ts` (legacy NPC prefix detection now part of detectSource) |
| `src/render/dialog/internal-monologue.ts` | 117 | inline panel italic body + cool gray fill |
| `src/render/dialog/internal-monologue-parser.ts` | 55 | source-detector (whole-italic detection) |
| `tests/render/dialog/speech-bubble.test.ts` | 23 cases | source-detector tests cover speaker detection coverage |
| `tests/render/dialog/internal-monologue.test.ts` | 13 cases | dialog-phase tests cover monologue → panel routing |

总计 ~546 LOC + 36 tests deleted; ~250 LOC + 36 tests added (source-detector + source-split + dialog-phase rewrites). Net: -296 LOC, 0 net tests change.

### Bugs closed (architecture 副作用)

- **Bug #18 / #18-regression** (bubble lingers across step-blob event boundaries) — bubble layer 删了，没有 lingering 可能。
- **Bug #19** (monologue Z-overlap with narration panel) — monologue 现在 inline 在 panel，不存在独立 layer 的 Z 冲突。
- **Bug #20** (narration vs monologue voice 区分模糊) — header bar `[ 笑天 ]` 显式标 + italic + cool gray fill 三重区分。
- **Bug #24** (multi-speaker 对话 + narration 在同 panel 混杂) — runtime auto-split 是新架构 core feature，每 paint 单 source。

### Verification

- `pnpm tsc` ✓ clean
- `pnpm test` ✓ **288/288 passing** (was 289 pre-batch — net -1 from the file-count math: 23 + 13 deleted, 29 + 7 + ... added)
- 所有 lefthook (biome + tsc + vitest) 通过

### What remains open

新 source-of-truth (`avg-architecture.md`) 列出的下一波 P0:
- **Q-Q · Bug #31 KPI Review cinematic** (simulation 心跳)
- **Q-S · Weekly meter modal** (周一/周五 daily pressure carrier)
- **Q-K-2nd · First-time tutorial modal** (Bug #23 second half + Bug #30 close)

P1: T-1 scene registry, T-2 NPC sprite slots, Bug #29 (Status HUD now diegetic-first per §2.4 — 重新评估 priority).
P2: Bug #26 calendar widget polish.

(next /loop tick: 按 queue P0 顺序 → Q-Q 还是 Q-S 看哪个 ink 内容 ready。Q-Q 需要 episode-1 D7 ink 末加 `# kpi_review_path_X` tag，Q-S 单独 modal 不依赖 ink。优先 Q-S 估时短 + unblocks weekly cadence；Q-Q 紧随其后。)

---

## 2026-05-06 · batch 23 — Q-T (Bug #33) + Q-U (Bug #26 calendar Pixi widget)

GM playtest after batch 22 added 2 P0 small post Q-R fixes; both shipped together.

### Q-T (Bug #33) — drop `[视角]` header for narration paints

Per avg-architecture.md §1.3 update: narration is the default旁白; the `[视角]` label was visual noise. `drawPanel()` now branches on `source.kind === 'narration'` and skips the header bar entirely (no BG, no divider, no label). The body region shifts up to fill the full panel rect (`bodyText.y = PANEL_Y + PANEL_PADDING_Y` instead of `PANEL_BODY_Y + PANEL_PADDING_Y`), and the body mask is redrawn per paint to match the dynamic body rect. Monologue + NPC keep their header bar so the disambiguation cue (`[笑天]` / `[Lisa]` / etc) survives.

**File**: `game/src/render/dialog/ink-dialog.ts` (drawPanel only)
**Tests**: 288/288 passing (purely visual; no unit-test surface — pure helpers `decideDialogPhase` / `detectSource` unaffected)
**Closes**: Bug #33

### Q-U (Bug #26) — calendar Pixi Graphics widget

Replaces the legacy 4-frame sprite-based calendar (`calendar_month_day_1.png` / `calendar_mid_week.png` / `calendar_weekend_marked.png` / `calendar_month_end.png`) with a programmatically-drawn `mountCalendarWidget()`. The sprites were low-fidelity and only mapped 4 buckets (`day≤1` / `day≤4` / `day≤6` / `day=7`); they didn't track each day individually and looked rough at 0.25× scale.

**New file**: `game/src/render/diegetic/calendar-widget.ts` (~200 LOC)
- 80 × 80 px desk-calendar visual: paper BG `#EFE6D2` (warm cream) + 1 px border `#2A1F14`
- Top 16 px banner `#8A4A3A` (装订深红) with month label "{N} 月 · {EN}" (e.g. "1 月 · JAN") + 2 binding rings poking up from top edge
- 7-col × 5-row date grid below (covers all 30 days of MONTH_DAYS)
- Color rules per day: past = light gray `#B8A890`; current = red `#C83428` text + red ring outline; weekend cols (Sa=col 5, Su=col 6) = red `#C83428`; weekday future = ink `#2A1F14`
- Self-binds to `calendar.onDateChanged`; gridLayer redraws on every fire (paper + banner are static)
- Returns `{ container, destroy }` — destroy unsubscribes + tears down container

**Workstation refactor**: `game/src/render/scene/workstation.ts` lost ~40 LOC of CALENDAR_FRAMES + pickCalendarFrame + swapCalendarTo + onDateChanged subscription; now just `mountCalendarWidget(ctx.worldLayer, { x: 30, y: 20 })` + push the handle's `destroy` onto teardowns. The legacy `calendar` import from `@/flow/calendar` is no longer needed at workstation level (biome auto-removed).

**Visual position**: top-left of widget at (30, 20) → centered ~(70, 60) matches the prior sprite anchor exactly.

**Tests**: 288/288 passing (no new tests — Pixi rendering can't be vitest-asserted cleanly; pure helpers `monthEnglish` etc are trivial and exercised inline by the widget's refresh path).

**Closes**: Bug #26

### Verification

- `pnpm tsc` ✓ clean (both batches)
- `pnpm test` ✓ 288/288
- All lefthook hooks green

### Open after this tick

P0:
- Q-Q · Bug #31 KPI Review cinematic (4-6h, ink + cinematic together)
- Q-S · Weekly meter modal (2-3h, no ink dependency)
- Q-K-2nd · First-time tutorial modal (1-2h)

P1: T-1 scene registry, T-2 NPC sprite slots, Bug #29 (Status HUD diegetic-first reassessment).

(next /loop tick: Q-S — shortest, no ink dependency, unblocks weekly cadence. Q-Q after.)

---

## 2026-05-07 · batch 24 — post-Q-R UX cleanup sweep + T-2 NPC sprite slots (6 fixes)

GM playtest after batch 22-23 surfaced 5 small/medium UX gaps + reaffirmed T-2 priority since W5 round-3 shipped 11 NPC sprites (under `assets/sprites/npc/`). Working through queue P0 → P1 in order.

### Q-X (`7d3f29c`) — strip "Lisa：" prefix from NPC body (Bug #37)

**Why**: Panel header bar shows `[ Lisa ]` AND body `Lisa："好的。"` → name appears twice. Bodies authored before Q-R speaker-tag convention still carry the legacy prefix.

**Fix**: New `stripSpeakerPrefix(body)` pure helper in `source-detector.ts`. Strips matching known-NPC names AND aliases (大伟 → David / 周哥 → 老周) from leading `Name：` / `**Name**：` (full-width OR ASCII colon). Called by `ink-dialog.drawPanel` ONLY when source.kind === 'npc'. Narration / monologue pass through unchanged. 9 new vitest cases.

### Q-Y (`ed16579`) — pause hamburger button + 回主菜单 hard-restart (Bug #38)

**Why**: No always-visible exit affordance during gameplay. Esc was the only path; player who didn't know couldn't escape mid-run.

**Fix**: 16×16 hamburger button at workstation top-right ((614, 8) initially, then shifted to (516, 8) for Q-N HUD clearance). Click → `flow.request({ kind: 'pause', resumeTo: cur })` — same path as the existing Esc handler.

Also reworked PauseMenu's [回主菜单] handler: per Q-Y spec, performs hard-restart (`save.clearCurrentRun()` + `dialogState.reset()` + `window.location.reload()`) — same brutal-but-reliable pattern as ink-dialog's `triggerNewGame()` (gameover [新游戏]). Label clarified to "回主菜单（清存档）" so destructive intent is explicit.

### Q-N (`93bc3c7`) — always-visible Status HUD top-right (Bug #29 revived)

**Why**: GM playtest 2026-05-06 saw daily_recap blob "今日 KPI: +105 / 今日 钱: 5502 / 今日 状态: 72/100" rendering as a panel monologue. § 2.4 v2 reverses the earlier "diegetic-first only" decision: KPI/钱/状态 belong in a top-right HUD with live updates.

**New file**: `src/render/hud/status-hud.ts` (~180 LOC). 80×72 panel at canvas (540, 16): 3 rows KPI / 钱 / 状态, BG `#1A2A38` + alpha 0.85 + 1 px border `#2A1F14`, cream `#E8E0CC` 10pt body. Reads ink VARs `kpi/money/state` (the design's narrative source of truth). On every refresh: snapshot diff vs prior, queue +N/-N flash badge (打工人黄 positive / 红 negative, 800 ms fade) + ease displayed value toward target via Pixi ticker (TWEEN_EASE 0.18 per frame).

**Wiring**: `mountInkDialog()` now accepts `onAfterAdvance?: () => void`. Fires after every `step()` / `selectChoice()` AND in `start()` initial paint. Workstation passes `statusHud.refresh` as the callback. Hamburger button shifted to (516, 8) so the HUD's (540-620, 16-88) range is clear.

Money formatted with `toLocaleString('en-US')` (¥5,500). KPI shows `/ 200` fallback threshold (real `cap_now` wiring is part of Q-Q KPI Review).

### Q-W (`0cfea3e`) — phone + fruit_bowl off-panel + chroma-key cream BG (Bug #36)

**A. Position + scale**:
- `phone`: (380, 252) scale 0.1 → (580, 130) scale 0.06. Top-right corner, ~40 px below HUD bottom (y=88), well clear of panel (y=240+).
- `fruit_bowl`: (510, 250) scale 0.12 → (60, 220) scale 0.06. Left-mid edge, far left of sticky rack center (x=320).

**B. Chroma-key cream BG**:
- New `src/render/diegetic/chroma-key.ts` (~50 LOC). `loadChromaKeyedTexture(url, { color, tolerance })` projects the URL through canvas2D `getImageData` / `putImageData`, knocks alpha=0 on every pixel within Manhattan-distance `tolerance` of `color`, builds a fresh Texture from the modified canvas. Browser-only (vitest paths gracefully skip).
- `prop-entity.ts` PropEntitySpec adds optional `chromaKey: ChromaKeySpec`. `createPropEntity` + `setState` load via `loadChromaKeyedTexture` when set.
- workstation.ts wires `chromaKey: { color: 0xe8e0cc, tolerance: 8 }` for both phone + fruit_bowl. W5 backup: regenerate sources with explicit transparent_bg.

### Q-V (`f027a6d`) — panel auto-paginate via runtime virtual pagebreak (Bug #34)

**Why**: Panel shrunk to 96 px in Q-L Bug #25 reverse; long narration steps overflow the body mask and get clipped (Day 1 Event 1.2 茶水间 5+ paragraph prose).

**Approach**: Spec sub-option A' — runtime auto-inserts a virtual pagebreak when text exceeds budget. Reuses the existing `pendingChunk` / `paused=true` machinery (same path as explicit `# pagebreak` and Q-R source-split). Renderer's existing ▼ continue affordance handles multi-page reads with no new state.

**New file**: `src/render/dialog/panel-paginate.ts` (~50 LOC). `paginateAtSentenceBoundary(text, budget)` returns `{ head, tail }`: prefers Chinese terminators 。？！ in latter half of budget window, falls back to ASCII `?!`, then newline, then forced cut. Default budget = 130 chars (~4 lines × 32 CJK chars). 11 new vitest cases.

**Runtime wire**: `runtime.ts step()` post-loop check — if `text.length > PANEL_TEXT_BUDGET` AND `!paused`, call `paginateAtSentenceBoundary`, replace `text` with head, stash tail on pendingChunk, set `paused=true`. Tags carried with the head; tail is pure text spillover with empty tags.

**ink-dialog.ts choice case**: when paused=true (paginated head with choices populated), show ▼ first (no sticky); sticky mounts on the last page when paused=false.

### T-2 (`bab24ca`) — NPC sprite slot registry (P1 critical, W5 sprites ready)

**Why now**: W5 round-3 shipped 11 NPC sprites (`assets/sprites/npc/<id>_sprite.png`). Without T-2, ink emits `# npc: lisa_holding_milk_tea_cup` and nothing visible changes — player never sees Lisa / Vivian / etc.

**New file**: `src/render/npc/npc-registry.ts` (~145 LOC). `parseNpcId(tagValue)` matches longest known NPC id prefix (`lao_zhou_drinking_tea` → `lao_zhou`, `wang_director` matched whole, `lao_li_mopping_background` aliased to `li_ayi`, `food_court_auntie_serving_lunch` aliased to `cafeteria_auntie`). NpcRegistry holds a parent Container + a `Map<id, Sprite>` of mounted NPCs. `handleTag(value)` mounts sprite at the configured anchor (sprite anchor 0.5, 1 → bottom-center "stands at" config.{x,y}); idempotent (re-emit is a no-op). `clearAll()` unmounts all on scene change.

**NPC_TABLE** covers all 11: Lisa / David / Vivian / Wang director / Lao zhou / Zoe / Li ayi / Mama / Lin jie / IT xiaoma / Cafeteria auntie. Anchors borrow from the deleted npc-anchors.ts (Q-R) but re-purposed as sprite bottom-center (head was bubble tail tip). Scale 0.3 across the board — tunable per-asset if W5 sprites vary.

**workstation wire**: `npcRegistry.attach(ctx.worldLayer)` + listen on `sceneState.on('npc', value => handleTag)` + `sceneState.on('scene', () => clearAll)`. Mirrors the prop scope='scene' lifecycle.

19 new vitest cases for `parseNpcId` + the NPC_TABLE / NPC_ALIASES schema invariants.

### Verification

- `pnpm tsc` ✓ clean across all 6 commits
- `pnpm test` ✓ 327/327 (was 297 → +9 stripSpeakerPrefix + +11 panel-paginate + +19 npc-registry - 9 dropped from earlier counts, net +30)
- All lefthook hooks green

### Bugs closed

- Bug #29 (Status HUD always-visible top-right)
- Bug #33 (`[视角]` header dropped — already done in batch 23, this batch added stripSpeakerPrefix companion)
- Bug #34 (panel overflow auto-paginate)
- Bug #36 (phone/fruit_bowl position + chroma-key)
- Bug #37 (NPC name prefix duplicate with header)
- Bug #38 (pause hamburger + 回主菜单 hard-restart)

### Open after this tick

P0 (queue):
- Q-Q · Bug #31 KPI Review cinematic (4-6h)
- Q-S · Weekly meter modal (2-3h)
- Q-K-2nd · First-time tutorial modal (1-2h)

P1:
- T-1 · scene registry (3-5h) — `# scene: break_room` etc.

(next /loop tick: Q-S — small + no ink dependency. Q-Q after, depending on whether episode-1.ink D7 is ready with `# kpi_review_path_X` tags.)

---

## 2026-05-07 · batch 25 — post-batch-24 playtest sweep (4 fixes Q-Z / Q-AA / Q-BB / Q-DD)

GM playtest after batch 24 (image 36-37) surfaced 4 visible UX issues + 1 W5-only re-prompt (Q-CC, not in W1 scope). Working through queue order Q-Z → Q-AA → Q-BB → Q-DD.

### Q-Z (`ca90261`) — NPC sprite scale 0.3→0.6 + position retune (Bug #39)

**Why**: T-2 initial NPC_TABLE used scale 0.3 with anchors inherited from the deleted npc-anchors.ts (originally bubble-tail tip coords, NOT sprite stand-points). Result: ~30 px-tall sprites dumped near the panel header area.

**Fix**: NPC_TABLE entries updated:
- All scales: 0.3 → 0.6
- Re-tuned positions per spec workstation visual logic so no NPC sits in panel (y=240+) or sticky band (170-240):
  - lisa (520, 200) — adjacent right cubicle peer
  - david (160, 200) — mid-left desk
  - wang_director (320, 120) — top-mid (push-in)
  - vivian (560, 130) — top-right reception
  - zoe (260, 130) — top-mid-left HR
  - lao_zhou (580, 200) — far-right cubicle
  - li_ayi (80, 270) — bottom-left cleaning
  - mama (320, 180) — phone scene mid
  - lin_jie (200, 130) — top-mid-left other-team
  - it_xiaoma (140, 200) — IT corner
  - cafeteria_auntie (320, 270) — cafeteria mid

Existing test "all NPC_TABLE positions are within the 640x360 canvas" still passes (range check).

### Q-AA (`ec09b42`) — HUD redesign: 3 bars + 3 icons, no numbers (Bug #40)

**Why**: User feedback on image 37 — text-row HUD ("KPI 100/200 / 钱 ¥5,503 / 状态 83/100") read as a "ugly report". Spec: 3 horizontal bars + 3 same-size icons, no numbers, no labels.

**Rebuild**: `src/render/hud/status-hud.ts` rewritten:
- Container: 80×56 at (canvas.W - 84, 16) = (556, 16) (was 80×72 at 540,16)
- 3 rows stacked vertically (3 px gap), each row = `[12×12 icon] [60×12 bar]`
- Icons:
  - KPI: 3 stacked horizontal lines (表格 motif) via Pixi Graphics
  - 钱: ¥ glyph (Text node — Graphics-only at 12 px is awkward, semantic intent is "icon")
  - 状态: heart silhouette (2 lobes via circles + triangle bottom) via Pixi Graphics
- Bar values:
  - KPI ratio = `actualKpi / monthlyThreshold`, clamped 0..1.4 (处刑 zone). Fill `#C8A85A` 打工人黄; flips to red `#C83428` when ratio > 1.0
  - 钱 ratio = `(money - 2000) / 13000`, clamped 0..1. Fill `#E0B050` 老板金
  - 状态 ratio = `state / 100`. Fill `#5A7080` 灰蓝; flips red when < 0.2 (病倒 imminent)
- Bar visualization caps display at 1.0 (60 px wide); over-cap signaled via color flip
- 选择 effect: 300 ms color brighten (40-channel lift) on row whose target changed; per-row tween at 0.18 ease

Workstation HUD position updated to (556, 16) for the smaller container.

### Q-BB (`b949969`) — calendar advance from ink stitch path (Bug #41)

**Why**: Calendar widget stuck at "1 月 · 1日" because the engine had no signal to advance. The ink narrative already organizes content as `day_<N>_<event>_<phase>` stitches, so the day index can be lifted directly.

**Fix**:
1. New `calendar.setDay(day)` API — jumps current day directly, rederives weekday from `(day-1) % 7 + 1` (game starts day 1 = Monday). Out-of-range warning + no-op. Listener fires on actual change. 4 new vitest cases.
2. New `ink.currentPathString` getter on InkRuntime — exposes `story.state.currentPathString` (inkjs program-counter path) so the renderer can poll without reaching into Story internals.
3. New `syncCalendarFromInkPath()` helper in `ink-dialog.ts` — regex matches `day_(\d+)_` against `ink.currentPathString`, calls `calendar.setDay(N)` if found. Idempotent.
4. Hook: called at the top of every `paintStep()` so the calendar widget redraws on each ink advance.

(Month/episode advance is left for a future tick — month boundaries align with episode-N.ink swaps.)

### Q-DD (`0e53b60`) — kill all panel headers (Bug #43)

**Why**: User: 对话栏 inconsistent header (narration 无, monologue/NPC 有) feels uneven. Image 38 reference shows panel with NO header bar regardless of source; NPC quotes inline as part of prose.

**Spec change** (avg-architecture.md §1.3 v3): panel **never** shows source label header bar. Source distinction migrates entirely to body styling.

**Fix in `ink-dialog.ts`**:
- `drawPanel()`: removed conditional `showHeader = source.kind !== 'narration'` branch. Always paints just panel BG + body text. Body region restored to full panel (y=PANEL_Y to y=PANEL_Y+PANEL_H, no longer offset by HEADER_BAR_H).
- Removed `stripSpeakerPrefix` call — NPC body keeps inline `Lisa："…"` prefix per Q-DD spec (revert Q-X strip)
- Body styling:
  - narration: upright cream `#E8E0CC` (default)
  - monologue: italic cool gray `#A8B0C0`
  - NPC: upright cream + inline `Name："…"` prefix kept verbatim
- Deleted: headerBarBg Graphics + headerLabel Text + their state cleanup paths
- Deleted constants: HEADER_BAR_H, PANEL_BODY_Y, PANEL_BODY_H, HEADER_BAR_BG, HEADER_BAR_BG_ALPHA, HEADER_LABEL_COLOR (renamed to TRIANGLE_COLOR for the ▼ indicator's tint)
- Removed unused imports: sourceLabel, stripSpeakerPrefix from source-detector

`stripSpeakerPrefix` and `sourceLabel` remain exported from source-detector (still useful for any future renderer that wants to surface the source). Source detection itself remains in active use for runtime auto-split + body styling.

### Verification

- `pnpm tsc` ✓ clean across all 4 commits
- `pnpm test` ✓ 331/331 (was 327, +4 new calendar.setDay cases)
- All lefthook hooks green

### Bugs closed

- Bug #39 (NPC sprite scale + position)
- Bug #40 (HUD bar/icon redesign)
- Bug #41 (calendar advance from ink path)
- Bug #43 (panel headers killed)

(Bug #42 / Q-CC: W5-only re-prompt of `workstation_closeup.png` to drop the HR mini-monitor. Not in W1 scope.)

### Open after this tick

P0 (queue):
- Q-Q · Bug #31 KPI Review cinematic (4-6h)
- Q-S · Weekly meter modal (2-3h)
- Q-K-2nd · First-time tutorial modal (1-2h)

P1:
- T-1 · scene registry (3-5h)

(next /loop tick: Q-S — short + unblocks weekly cadence. Q-Q after, depends on episode-1 D7 ink readiness.)


