# P5 Phase 2 · QA Bug Reports

> Status: append-only log of QA-found and engineer-found bugs in the
> Phase 1 demo + Phase 2 work in progress.
> Severity: **block** > **major** > **minor**.
> Resolution: each bug is marked ✓ resolved with the commit hash that
> fixed it.

---

## Bug #1 — block — `RUNTIME ERROR: ran out of content` after picking certain Day 1/2 choices

**Reported by**: engineer (T10a verify session, 2026-05-05)
**Severity**: block — story aborts, console shows `StoryException`, dialog panel renders `[runtime error: ran out of content]` instead of next event.
**Repro**: any path that lands on a `* [choice]` block whose last line is a `~ var = …` assignment with no `-> divert_target` and no parent gather. Compile-time `loose end` warnings already flag the offending lines (samples below — full list in `pnpm ink:build` output for `episode-1.ink`):

| .ink line | Stitch / context | Last statement before fall-off |
|---|---|---|
| 699 | day_1 老周凉茶 — `[拿走杯子]` | `~ state = state + 2` |
| 706 | day_1 老周凉茶 — `[拿走杯子，去洗，再放回]` | `~ state = state + 1` |
| 960 | day_1 加班选择 — `[申报加班]` | `~ lisa_score = lisa_score + 2` |
| 964 | day_1 加班选择 — `[按时下班]` | `~ lisa_score = lisa_score + 0` |
| 1235 | day_2 下班选择 — `[申报加班]` | `~ effort_overage = effort_overage + 1` |
| …many more (≈ 8 in episode-1, more in 2/3/4) | | |

**Expected**: each `* [choice]` block ends with `-> next_stitch` (or `-> day_N_after_event_K` style continuation per `season-1-arc.md`). Ink should reach `-> END` only at the natural end of an episode.
**Actual**: ink runtime exception, story state effectively dead-ends. The TS runtime catches it cleanly (`runtime.ts:82-98`) so the game doesn't crash — but the player can't continue.

**Engineer notes (not a fix, just clarity)**:
- Phase 1 closure doc claimed "29 loose-end warnings remain — non-blocking, story flows correctly via fall-through". This is wrong for the cases above. When a choice block has no parent gather (`-`) and no explicit `-> divert`, ink does NOT fall through to the next sibling `*` — it tries to return to the calling knot's continuation, finds none, and throws.
- The fix is content-side: add `-> day_1_event_K_continue` (or whichever stitch continues the day) at the end of every `* [...]` block in episodes 1-4. The Round-2 worker translation pass should catch these — possibly worth a "lint sweep" before Phase 2 ink integrations expand further.
- Engineer side, this is already as resilient as it can be: `step()` wraps each `Continue()` in try/catch and returns an "ended" step on failure, which paintStep handles by showing the error text in the narration panel and rendering a "（剧本结束）" choice. Player can't recover within the dead path, but the engine doesn't actually crash.

**Status**: ✓ resolved (Round 3, 2026-05-06) — content fix on `episode-1.ink:720` adds gather `-` between Event 2.3 choice block and `~ check_state_after_choice() -> day_2_after_work`, so all 3 choice paths converge to the common continuation. Driver picks `[偷喝那杯，再走]` → no console error → ink advances → state mutates correctly. Working-tree edit (uncommitted at time of verify), no commit message naming Bug #1; recommend committing as `fix(qa-bug-1): close episode-1 Day 2 Event 2.3 loose end via gather`. **Sweep needed**: episode-2/3/4/5/6/7/8.ink may still have similar loose ends — engineer's Round 1 note flagged 8+ in episode-1, more in 2/3/4. Run `pnpm ink:build` and grep for "loose end" warnings to enumerate remaining cases.

**QA confirmation (Round 1, 2026-05-05)**: Reproduced via Playwright driver. Crash fires on Day 2 Event 2.3 `[偷喝那杯，再走]` (line 699). Driver path was: `[新游戏]` → `[开始今日]` → intro 1/2/3 → Day 1 Event 1.1 (auto) → 1.2 `[让 Lisa 先]` → 1.3 `[还行，你呢]` → fall through 1.4/1.5/1.6 → after_work `[按时下班]` → fall-through Day 1 recap + Day 2 morning + Day 2 Event 2.1 `[一起]` → Day 2 Event 2.2 (David, see Bug #2 below) → Day 2 Event 2.3 `[偷喝那杯，再走]` ✗.

---

## Bug #2 — block — `**David**：` line at line-start parsed as depth-2 ink choice (Day 2 Event 2.2)

**Reported by**: QA (Round 1, 2026-05-05)
**Severity**: block — Day 2 Event 2.2 (David PPT setup, designed as a no-choice Chekhov-gun setup) instead presents a single spurious choice button labeled with the entire David WeChat dialog: `David**："兄弟，下周我有个对接 X 部门的方案要写，到时候帮我看看 PPT 模板？5 分钟的事。"`. Player cannot advance without clicking that "button". Once clicked, ink does eventually reach Event 2.3 (where Bug #1 then crashes), so this isn't the crash cause — it's a separate parse error.

**Repro**:
1. boot → `[新游戏]` → `[开始今日]` → intro 1/2/3 → Day 1 → after_work `[按时下班]` → Day 2 Event 2.1 (Lisa milk tea), pick any → Day 2 Event 2.2
2. **Spurious choice button** appears with full David dialog as label
3. Picking it → advances (incorrectly) to Event 2.3

**Expected** (per design comment lines 633-634, 653-654 of episode-1.ink): Event 2.2 has zero choices — it's a setup event. David's WeChat line should appear in the narration panel, then auto-fall-through to Event 2.3.

**Actual**: line 643 `**David**："…"` at line-start is parsed by Ink as `* * David**：…` (depth-2 choice marker). The whole line + following narrative becomes the choice body. The choice body's `-> day_2_event_3_lao_zhou_tea_steal` makes the divert work, so it's not a hard crash — just a wrong UI affordance.

**Files involved**: `design/vertical-slice/episode-1.ink:643`

**Fix**: change line 643 from `**David**："…"` to `David："…"` (drop the `**` bold). Same fix already applied to episode-2/3/4 per `p5-closure.md` T01 — episode-1 was missed in that sweep.

**Status**: ✓ resolved (Round 3, 2026-05-06) — content fix applied: `episode-1.ink:643` now reads `David："…"` without `**` markers. Driver verifies: Day 2 Event 2.2 no longer presents spurious choice; step blob continues through to Event 2.3's correct 3-choice sticky-note rack. Working-tree edit, recommend committing as `fix(qa-bug-2): drop **David** bold prefix to avoid depth-2 choice parse`.

---

## Bug #3 — major — daily_recap blobs into next-day morning_briefing (no choice gate between days)

**Reported by**: QA (Round 1, 2026-05-05)
**Severity**: major — every day-end → day-start transition collapses Day-N recap stats AND Day-N+1 morning content into one panel paint, then a single `[开始今日]` button.

**Repro**:
1. Day 1 → after_work → pick `[按时下班]`
2. Single text panel paints: end of `day_1_after_work` ("Lisa：'明天见啊'…") + `_今日 KPI: +100 (累积 100/200)_` + Day 2 morning_briefing content (闹钟 / 通勤 / 工位)
3. Single button at bottom: `[开始今日]` (which is Day 2's button)

**Expected**: separate AVG beats. Day 1 recap on its own panel (player reads recap + dismisses), then transition to Day 2 morning_briefing.

**Actual**: ink `Continue()` only stops at choice points. Stitches `day_1_after_work` post-choice → `day_1_daily_recap` → `day_2_morning_briefing` are separated only by `-> divert`s (no choice or DONE), so `step()` drains them all into one paint.

**Files involved**: every `day_N_daily_recap` stitch. Sample: `design/vertical-slice/episode-1.ink:535` ends with `-> day_2_morning_briefing` (no choice gate). Same pattern at Day 2/3/4/5/6/7 recap → next morning.

**Fix options**:
- (A) ink-side: add a `* [明天见]` (or similar 2-3 char) choice at the end of every `day_N_daily_recap` to gate the transition. Lowest risk, content-only.
- (B) renderer-side: have `# diegetic_ui: phone_show_daily_recap` tag trigger a "page-break" — dialog forces a continue-button before resuming step().

Either works. (A) is faster; (B) is cleaner if recap is meant to be a phone overlay scene per art-bible §7.1.

**Status**: ✓ resolved — `feat(p5-pagebreak)+fix(qa-bug-3)` (`fb3b4df`). Option B as `# pagebreak` tag per Q-2 GM reply. `runtime.ts step()` now stashes the post-pagebreak chunk on `pendingChunk` and returns `paused=true`; ink-dialog mounts a ▼ continue affordance + clickable panel hit-rect; the next click drains the stash and resumes Continue() until the next break or choice. Designer annotates beat boundaries with a standalone `# pagebreak` line between the last beat text and the divert to the next stitch — full tagging policy in `p5-phase2-engine-questions.md` Q-2.

---

## Bug #4 — major — ink-dialog 130 px text panel can't fit multi-paragraph events; text overflows panel boundary

**Reported by**: QA (Round 1, 2026-05-05) — placeholder dialog limitation, but worth filing
**Severity**: major — text legibility broken at almost every event, not just edge cases.

**Repro**:
1. Day 1 morning_briefing → click `[开始今日]`
2. Resulting paint concatenates `day_1_event_1_vivian` + `day_1_event_2_caishuijian` (~400+ Chinese chars across many paragraphs)
3. PixiJS Text wraps but doesn't clip — text lines extend below the 130 px panel BG, painted directly onto the workstation BG with no panel BG behind them.

**Expected**: text fits or scrolls / paginates.

**Actual**: text overflows; lower lines render on top of the workstation canvas without panel BG.

**Files involved**: `game/src/render/dialog/ink-dialog.ts:22-25` (`PANEL_H = 130` constant), `:56-69` (Text node mounted with wordWrap but no clipping or scroll).

**Note**: per `p5-closure.md` Phase 2 priorities, this dialog is a placeholder pending T10 speech-bubble + T11 sticky-note choice props. Filing now so it doesn't get lost in the visual-polish queue. Aggravated by Bug #3 (multi-day blob paints).

**Status**: ✓ resolved (visual triage) — `f???` `fix(qa-bug-4)`: panel grew 130 → 156 px, line-height 18 → 16, and a `Pixi.Graphics` rect mask now clips the narration `Text` to the inner padding box so over-long content gets truncated cleanly instead of bleeding onto the workstation BG. Real pagination still gated on Q-2 / Bug #3.

---

## Bug #5 — major — ink runtime state not persisted; `[继续]` restores FSM but resets ink to `intro`

**Reported by**: QA (Round 1, 2026-05-05) — known scope gap per closure doc, but `[继续]` UX is misleading.
**Severity**: major — `[继续]` button enabled + clickable, but doesn't restore ink position.

**Repro**:
1. Boot → 新游戏 → progress to e.g. Day 2 Event 2.1
2. Refresh browser
3. main_menu shows with `[继续]` enabled (because P0–P4 save still works for FSM/KPI/Effort/Energy)
4. Click `[继续]` → FSM jumps back to `action_day(day=N)`, but the ink dialog re-paints **intro** ("你好。我陈笑天…")

**Expected**: `[继续]` resumes both FSM AND ink at saved position.

**Actual**: `ink.divertTo('intro')` runs unconditionally on every boot (`game/src/main.ts:48-50`). Save schema has no `ink_state_json` field (per `p5-closure.md` T16: "Skipped").

**Files involved**: `game/src/main.ts:46-54`, `game/src/save/system.ts`.

**Suggested triage**: until T16 lands, either (a) hide `[继续]` button, OR (b) on `[继续]` click restore ink-state-json if present (will need schema bump). Not blocking demo loop, but blocks any "save → reload mid-episode" QA path.

**Status**: ✓ resolved — `fix(qa-bug-5,9)+feat(p5-T16)`: `runStateSchema` gained `inkStateJson: z.string().optional()` field; `snapshotCurrentRunState()` calls `ink.serializeState()` when a story is loaded; `main.ts` boot path calls `ink.loadState(restored.inkStateJson)` after `loadEpisode()` resolves, falling back to `divertTo('intro')` only when no save or no ink field is present. Pre-T16 saves parse fine (field is optional). Round-trip + legacy-shape tests added in `tests/save/system.test.ts`.

---

## Bug #6 — discussion — choice text exceeds tone-bible 6-char limit (after_work + several events)

**Reported by**: QA (Round 1, 2026-05-05)
**Severity**: discussion (designer call — UX trade-off)

**Examples logged via driver**:
- day_1_after_work: `[申报加班 -10 状态 +2 AP 等价]` (15 chars), `[提前下班 (你没用满 8 AP)]` (12 chars)
- day_2_event_3 (老周凉茶): `[拿走杯子，去洗，再放回]` (11 chars), `[主动跟老周说"对不起，您那杯茶我喝了"]` (17+ chars)
- intro screen 3: `[我懂了, 开始第 1 天]` (9 chars)
- day_1_event_2_caishuijian: `[不说话，先接你的]` (7 chars)

**Per `tone-bible.md` v2.1**: option text ≤ 6 chars, exception only for "专用职场梗 phrase". Mechanism numbers like `-10 状态 +2 AP` and full sentences are NOT 职场梗 — they're tooltips inlined into the button.

**Files involved**: `design/vertical-slice/episode-1.ink:303,309,315, 343,348,353, 490,496,501, 604,611,616, 692,702,708, 855,860,865, 1106,1110,1116, 1195,1201,1205, 1231,1237,1241, 1396,1409,1414, 1485,1491,1495, 1613,1624,1629, 1733, 1783,1788,1793, 1898,1902,1906`

**Open question for designer**: is 6-char a hard limit or a "default with leeway"? If hard, after_work options need separate UI treatment (tooltip on hover, not in label). If soft, mark `wontfix`.

**Status**: ⚙️ engine-side ✓ resolved (`feat(p5-T11-fit)+fix(qa-bug-6)`). Per Q-3 GM reply, "≤ 6 char" is "default with leeway" — sticky notes now enforce 2 lines max with ellipsis truncation when label content exceeds the visual budget; long mechanism-disclosure labels (`[申报加班 -10 状态 +2 AP 等价]`) render as `[申报加班 -10 状态…]`. Content-side P6 backlog item — designer-driven sweep over the 60+ daily-choices + 4 episodes + S2 4 episodes — tracked separately and NOT engine scope. The mechanism-disclosure pattern itself violates Pillar-3 (subject inversion) so the sweep is design-correctness, not just length.

---

## Bug #7 — discussion — `[提前下班]` exists only as ink choice; Preact `after_work` overlay only renders 2 buttons

**Reported by**: QA (Round 1, 2026-05-05)
**Severity**: discussion (handoff QA spec ↔ Phase 1 closure doc divergence)

**Observed**:
- `p5-qa-handoff.md` §3 P0 step 5 expects 3 after_work buttons: 申报加班 / 按时下班 / **提前下班**
- `game/src/render/menu/after-work.tsx` renders only 2 (申报加班 + 按时下班)
- The 3rd option (`[提前下班 …]`) appears as an in-ink choice inside `day_N_after_work` stitch — handled by ink runtime, not the Preact overlay

**Note**: in current Phase 1 build, the Preact `after_work` overlay isn't reached at all because `dayCycle` only fires the action_day → after_work transition when AP=0 (`game/src/flow/day-cycle.ts:51-60`), but ink doesn't decrement AP (per `p5-closure.md` T13: "Skipped"). Day flow currently runs entirely inside the ink dialog. So the 2 vs 3 button discrepancy is moot until AP-gating is wired.

**Files involved**: `game/src/render/menu/after-work.tsx`, `game/src/render/scene/workstation.ts:15` (`SHOW_LEGACY_HUD = false`), `game/src/flow/day-cycle.ts:51-60`.

**Status**: ⏳ open — discussion (which after_work UI is canonical).

---

## Bug #8 — minor — `# scene` / `# npc` / `# prop` / `# diegetic_prop` tags emitted but no listeners (Phase 2 known gap)

**Reported by**: QA (Round 1, 2026-05-05) — filing for visibility
**Severity**: minor

**Observed**: driving ink through Day 1 logs tags `scene: reception`, `npc: vivian_smiling`, `prop: fruit_bowl_apple`, `prop: green_plant_dripped`, `diegetic_prop: mug_full`, etc — but the workstation BG never changes from static `workstation_closeup.png`, no NPC立绘, no fruit bowl prop swap.

**Expected** (per `art-bible.md` §7.1 + `p5-engine-architecture.md` §13 T03/T05/T06/T08): tag dispatcher routes tags to PixiJS prop swappers.

**Actual**: `tagDispatcher.dispatchAll(...)` runs in `ink-dialog.ts:130/165/179` but no handlers are registered for any of these keys. Tags parsed and discarded.

**Note**: explicitly Phase 2 per closure doc. No new info; filing so it doesn't fall through cracks of "the demo plays text" success metric.

**Status**: ✓ resolved — prop axis live in `feat(p5-T05-mini+T03-prop)` (`6fb3445`); `# scene` / `# npc` / `# time` / `# weather` / `# speaker` axes live in `feat(p5-T03-scene-mirror+speaker-tag)` via `scene/scene-state-mirror.ts`. All five tag streams now have at least one engine-side consumer:
- `# prop:` / `# diegetic_prop:` → `propRegistry.setStateFromTag()` → sprite swap.
- `# scene:` → `sceneState.scene` (warns on unknown ids; full transition gated on T04).
- `# npc:` → `sceneState.npc` (full sprite slot wiring gated on T05/T06).
- `# time:` / `# weather:` → mirrored for time-of-day filter / BG swap (gated on T04 visual layer).
- `# speaker:` → `sceneState.speaker` → consumed by ink-dialog as the preferred NPC anchor source (Q-1 contract). Legacy `parseSpeaker` regex retained as fallback until episode-1/2/3/4 finish migration via `tools/ink-speaker-migrate.mjs`.

---

## Round 1 tooling notes (not bugs)

- **N1 — QA hook**: dev-only `window.__qa = { ink, flow, save, app }` added in `game/src/main.ts` (gated by `import.meta.env.DEV`) for runtime inspection from Playwright. Strip after Phase 2 closes.
- **N2 — Playwright config**: `game/playwright.config.ts` + `game/qa/p5-demo.spec.ts` driver. `game/vitest.config.ts` excludes `qa/**` so vitest doesn't pick up the spec file.
- **N3 — Dev deps added**: `@playwright/test 1.59.1` + `npx playwright install chromium`. Total ~+45MB on disk (Chromium binary).
- **N4 — Stale screenshots**: PixiJS canvas dialog does NOT auto-repaint when ink advances via `__qa.ink.selectChoice` (driver bypasses pointer event handler). Round 1 screenshots 03/06/07/08/09/10 all show stale intro screen 1. Content-level assertions (text + VARs) verified via runtime singletons — visual screenshots aren't representative. Round 2 should drive via canvas mouse clicks at computed coords (canvas is logical 640×360 displayed at 1280×720 viewport-fit).
- **N5 — Smoke baseline**: `pnpm test` = 179/179 passing before any QA changes. Re-confirm after dev fixes.

---

## How to re-run QA driver

```bash
# Terminal A:
cd game && pnpm dev

# Terminal B:
cd game && npx playwright test
# Output → qa/output/*.png + console log
```

To remove Playwright entirely after Phase 2 closes: `pnpm remove @playwright/test` + delete `game/qa/`, `game/playwright.config.ts`, `game/vitest.config.ts`, and the `__qa` hook block at the bottom of `game/src/main.ts`.

---

## Round 2 — real canvas-click driving (`qa/p5-demo-r2.spec.ts`, 5 tests, all pass)

Round 2 driver uses `page.mouse.click(canvasRect, …)` instead of `__qa.ink.selectChoice` so screenshots and stage tree reflect what the player actually sees. Replays Day 1 with alternate paths + Bug #5 verify.

### Round 1 findings re-verified

- **Bug #1 (engineer-filed crash)**: still open — Day 2 Event 2.3 `[偷喝那杯，再走]` reproducer holds.
- **Bug #2 (`**David**：` malformed choice)**: still open at `episode-1.ink:643`.
- **Bug #4 (panel overflow)**: visually confirmed — see `qa/output/r2-04-day1-morning.png`. Day 1 morning_briefing's full text (闹钟 / polo 衣柜 / 通勤 / 9:14 打卡 / 工位 / 第 12 周) renders past the 130 px panel BG; lower lines are painted directly on the workstation BG with no panel underneath.
- **Bug #6 (>6-char choices)**: visually confirmed — Day 1 Event 1.2 buttons in `qa/output/r2-05-…png` and `r2-06-…png` show "让 Lisa 先" / "你先" / "不说话，先接你的" (≤7 chars; mostly within rule but one breaks).
- **Bug #8 (no tag listeners)**: stage tree dump at Event 1.1 (Vivian) confirms only static props — `world / workstation-bg / sticky / monitor / Sprite / calendar / Sprite / mug / Sprite / ink-dialog / Graphics / choices / choice-0 / choice-1 / choice-2 / Graphics`. Zero NPC/scene sprites mounted by tags. No listener registered for `# scene` / `# npc` / `# prop` / `# diegetic_prop`. (Same conclusion as Round 1 — but now with concrete evidence.)

### Things confirmed NOT bugs

- **Handoff §5 example bug ("click choice → panel empty")**: does NOT reproduce. Driver clicked `[然后呢]` → panel correctly painted intro screen 2 text + new choice `[听懂了]`. Same for screen 2→3. The race condition described in the handoff was already fixed in `ink-dialog.ts:124-132` (uses `paintStep(nextStep)` instead of `refresh()` post-click).
- **Markdown strip**: `**陈笑天**` source → "陈笑天" rendered (no literal `**`). `_笑天下众生..._` source → italic markers stripped. Verified via `readDialogText` walk over PixiJS Text nodes — no `**` or `_` in display text.
- **Choice-side-effect VAR mutation**: ink choice bodies' `~ var = …` assignments DO fire and are observable from the `__qa` hook. `[让 Lisa 先]` → `lisa_score = 1`, `[你先]` → `lisa_score = 0` (initial), `[不说话，先接你的]` → `lisa_score = -2`. All match `episode-1.ink:303/309/315` lines.

### New bugs found in Round 2

---

## Bug #9 — major — autosave never fires in Phase 1 demo, so `[继续]` stays disabled

**Reported by**: QA (Round 2, 2026-05-05)
**Severity**: major — consequence: any browser refresh = full progress loss; AND Bug #5 cannot trigger in current demo because it requires a save to exist first.

**Repro**:
1. Boot → 新游戏 → 开始今日 → click through intro 1/2/3 → enter Day 1 morning_briefing
2. Refresh browser (`Cmd-R`)
3. Boot returns to main_menu — but `[继续]` button is **disabled** (greyed out, opacity 0.4, "not-allowed" cursor)
4. `localStorage.length === 0` confirmed via Playwright

**Expected**: at least 1 autosave should have fired by the time the player has chosen a path through intro and started Day 1.

**Actual**: autosave only fires inside `dayCycle.confirmRecap()` (end of day) and `dayCycle.confirmKpiReview()` (end of month) — see `game/src/flow/day-cycle.ts:148, 222`. Since current Phase 1 demo:
- Has no AP-depletion mechanism in ink (per `p5-closure.md` T13: "Skipped"), and
- After_work / recap is reached only via AP=0 transition (`day-cycle.ts:51-60`)

→ **the recap path is never reached**, so autosave never fires, so `[继续]` is permanently disabled.

**Files involved**: `game/src/flow/day-cycle.ts:148, 222` (autosave call sites), `game/src/flow/day-cycle.ts:51-60` (AP=0 trigger).

**Suggested triage**: (a) trigger autosave on `morning_briefing → action_day` transition (after every `confirmMorningBriefing()`), OR (b) trigger on every ink choice via a new `dayCycle.onInkChoice()` hook + tag listener. Either path needs save schema extension for `ink_state_json` (Bug #5 / closure T16) to actually be useful.

**Status**: ✓ resolved — `fix(qa-bug-5,9)+feat(p5-T16)`: option (b) implemented. `ink-dialog.ts advanceChoice()` is now the single funnel for both the legacy choice button and the T11 sticky-note `onSelect` handler, and it calls `void autosave()` after every `ink.selectChoice()`. Combined with the T16 schema extension, `[继续]` now resumes mid-episode at the last choice the player made (verified via vitest + manual `pnpm dev` walkthrough recommended).

**Related**: Bug #5 was dormant because of #9 — both fixed in the same batch.

---

## Bug #10 — minor — `text` and `choices` paint may visually desync 1 frame on canvas after rapid pointertap

**Reported by**: QA (Round 2, 2026-05-05)
**Severity**: minor (probably not player-visible at human click cadence; only manifests in headless screenshot timing)

**Observed**: `qa/output/r2-05-event-1-2-pick-你先.png` shows Day 1 Event 1.2's choice buttons (`让 Lisa 先 / 你先 / 不说话，先接你的`) overlaid above text body that is already Day 1 Event 1.3's content (`11:42。你想去 16 楼上厕所…`). Mixed-state frame: text from new step, buttons from old step.

**Likely cause**: `paintStep()` is scheduled via `queueMicrotask()` in the `pointertap` handler (`ink-dialog.ts:131`). The microtask runs after the current task. Playwright's `page.screenshot()` (CDP `Page.captureScreenshot`) may capture during the gap between `text.text = …` (synchronous part of paintStep) and the children-tree mutation in `clearChoices()/renderChoiceStack()`. WebGL backbuffer may also lag one swap.

**Files involved**: `game/src/render/dialog/ink-dialog.ts:124-132, 152-167`.

**Severity rationale**: a real player clicking once and looking at the panel won't see this — the next animation frame will sync. Filing for record because it confused QA Round 2 screenshot interpretation.

**Status**: ⏳ open (low priority — investigate only if visible at real-time framerates).

---

## Round 2 tooling notes

- **N6 — Real canvas click works**: `page.mouse.click(canvas.x + lx*scale, canvas.y + ly*scale)` against PixiJS canvas at logical (640×360 → 1280×720 viewport-fit) successfully fires `pointertap` on choice buttons. Verified via VAR mutation post-click for `[不说话，先接你的]` → `lisa_score = -2`. Round 2 driver lives at `game/qa/p5-demo-r2.spec.ts`.
- **N7 — Stage tree dump approach**: `__qa.app.stage.children` walk yields stable labels (`world` / `workstation-bg` / `monitor` / `calendar` / `mug` / `ink-dialog` / `choices` / `choice-N`). Useful for asserting "no NPC sprite was mounted" without screenshot OCR.
- **N8 — Round 1 + Round 2 baseline (no dev fixes yet)**: latest commit on main is `f5a33b1 feat(p5-T10a): NPC-anchored speech bubble + dialog routing` — predates Round 1 QA. No `fix(qa-bug-N)` commits seen yet. Will re-run reproducers when they land.

---

## Round 3 — verify dev fixes (`qa/p5-demo-r3.spec.ts`, 6 tests, 5 pass + 1 reveals new minor bug)

Round 3 ran against post-fix tree (3 new commits on main, plus uncommitted ink content sweep on `episode-1.ink`). Smoke tests now 233/233 (was 179 — engineer added 54 new tests covering speech-bubble / monologue / scene-state-mirror / prop-registry / ink-save-schema).

Driver enhancements: walks stage tree to find `sticky-N` / `choice-N` buttons (T11 sticky-notes anchor to desk surface, not to old `PANEL_Y - 16` position). Single helper `clickChoiceByIndex(page, idx)` works regardless of layout.

### Round 1 / 2 bugs verified RESOLVED in Round 3

- ✓ **Bug #1 (engineer-filed crash)** — RESOLVED via **uncommitted ink content sweep** on `episode-1.ink:720` (gather `-` added between Event 2.3 choice block and `~ check_state_after_choice() -> day_2_after_work`). Driver picks `[偷喝那杯，再走]` → no `RUNTIME ERROR: ran out of content` console error → `state` mutates to 88 (was 80 + 6 from prior Day 1 path) → FSM stays at `action_day`.
  - **Note**: this fix was applied to `episode-1.ink` directly (working-tree edit, no commit message naming Bug #1). Ditto for episodes 2/3/4 — should sweep all 4 to confirm.
- ✓ **Bug #2 (`**David**：` malformed choice)** — RESOLVED via **uncommitted ink content sweep** on `episode-1.ink:643` (line now reads `David："…"` without `**`). Driver progresses through Day 2 Event 2.1 → blob through 2.2 → presents Event 2.3 sticky-notes (`[偷喝那杯，再走 / 拿走杯子，去洗，再放回 / 主动跟老周说"…"]`). No spurious David choice. Working-tree edit, no commit message.
- ✓ **Bug #4 (panel overflow)** — RESOLVED in `dedb258`. `mountInkDialog` panel grew 130 → 156 px, line-height 18 → 16. `text.mask = textMask` (Pixi Graphics rect at panel inner box) attached. Driver verifies: `dialog.children.text.mask != null` + `graphicsCount >= 2`. Visual screenshot `qa/output/r3-01-day1-morning-after-fix.png` shows long text clipped cleanly at panel edge instead of bleeding onto BG.
- ✓ **Bug #5 (ink resets to intro on continue)** — RESOLVED in `dedb258` (T16). `runStateSchema.inkStateJson?` field added; `snapshotCurrentRunState` calls `ink.serializeState()`; `main.ts` boot path calls `ink.loadState(restored.inkStateJson)` when present, else falls back to `divertTo('intro')`. Driver verifies: progress to intro screen 3 → reload → `__qa.flow.state.kind === 'action_day'` (boot skips main_menu since save exists, existing P4 behavior) → ink dialog does NOT show intro screen 1 marker `数咖啡杯`.
  - **Caveat — see Bug #11 below**: post-reload panel shows literal `...` placeholder text instead of intro-3 narration. Choice button still renders (`[我懂了, 开始第 1 天]`), so player can recover by clicking — but the panel is visually empty.
- ✓ **Bug #8 (no tag listeners)** — RESOLVED in `6fb3445` (prop registry) + `7f62762` (scene state mirror). Driver verifies: at Day 1 Event 1.1 (Vivian) blob, `__qa.sceneState.snapshot` shows `scene: 'break_room'` (overwritten — see Bug #12), `npc: 'it_xiaoma_back_at_machine'`, `time: '9:14'`. Stage tree at Event 1.1 now contains `prop:fruit_bowl` AND `prop:phone` sprite labels (was 0 in Round 1/2).
- ✓ **Bug #9 (autosave never fires)** — RESOLVED in `dedb258`. `ink-dialog.ts advanceChoice()` is the single funnel for both legacy and T11 choices, calls `void autosave()` after every `ink.selectChoice()`. Driver verifies: after 1 choice click, `localStorage` has `survived:fs:saves/current_run.save` containing `inkStateJson` field with ink callstack/flags blobs.

### Still OPEN from Round 1 / 2

- ⏳ Bug #3 (daily_recap blob into next-day morning_briefing) — needs designer call on (A) ink-side gate vs (B) renderer-side page-break.
- ⏳ Bug #6 (>6-char choices) — designer call.
- ⏳ Bug #7 (提前下班 in Preact vs ink) — design choice.
- ⏳ Bug #10 (1-frame paint desync) — minor; not investigated this round.

### NEW bugs found in Round 3

---

## Bug #11 — minor — restored ink state shows `...` placeholder text after reload (T16 follow-up)

**Reported by**: QA (Round 3, 2026-05-06)
**Severity**: minor — choice button still renders so player can recover, but panel is visually empty / disorienting on resume.

**Repro**:
1. Boot → 新游戏 → 开始今日 → click `[然后呢]` → click `[听懂了]` (now at intro screen 3, panel showing "游戏从 2026 年 5 月开始 / 52 周 / 我妈不知道", choice `[我懂了, 开始第 1 天]`)
2. Refresh browser
3. Save loads, FSM → `action_day`, ink restored to intro screen 3 position
4. Workstation scene mounts; `mountInkDialog().start()` runs `refresh() → step()` → `step()` returns `text: '', choices: [{0, '我懂了, 开始第 1 天'}]` (because `Continue()` has nothing to drain — content was already drained pre-save)
5. **`paintStep`** sets `text.text = stripMarkdown(step.text.trim() || '...')` → renders `...` in panel

**Expected**: re-paint the last-shown narration text (e.g. intro screen 3's "游戏从 2026 年 5 月…" content)

**Actual**: panel shows `...` (placeholder) but choice button is correct.

**Files involved**: `game/src/render/dialog/ink-dialog.ts:198-201` (the `text.text = ... || '...'` fallback). The save schema doesn't store the last-rendered narration text — only ink state. ink Continue() at restored position has no text to emit.

**Suggested triage**: store the most-recently-rendered `step.text` in the save (alongside `inkStateJson`) so paintStep can pre-fill on restore. OR re-divert to a sub-stitch boundary that re-emits the text — but most events can't be re-entered without repeating side effects.

**Status**: ✓ resolved — `fix(qa-bug-11)` (batch 13 W1 pickup, 2026-05-06). "Store last-rendered text" approach.

- `dialog-state.ts` (NEW): singleton `dialogState` tracking `lastNarrationText`. `ink-dialog.ts setPanelText()` helper + header-band path publish to it whenever real (non-`...`) panel content renders. `snapshot.ts` reads it; `runStateSchema.lastNarrationText: z.string().optional()` persists it; `main.ts` boot path calls `dialogState.setLastNarrationText(restored.lastNarrationText)` after `ink.loadState`.
- ink-dialog tracks `firstPaintAfterMount` flag. On the FIRST paintStep after a fresh mount, when `decideDialogPhase()` returns `'choices-only'` (empty text + choices) AND `dialogState.lastNarrationText` is non-empty, the renderer treats it as a synthetic `'deferred-choices'`: panel + ▼ with the saved narration. Click ▼ flushes panel + mounts sticky rack (existing `advanceContinue` case 1 path). Flag flips false after the first paint so subsequent `'choices-only'` paints fall through to sticky-alone normally.
- Tests: 6 new vitest cases in `tests/render/dialog/dialog-state.test.ts` (set/get/reset/overwrite/CJK/empty) + 2 new save round-trip cases. Total 293/293.

Player-side validation: refresh mid-flow → reload restores last narration in panel + ▼ (no more `...`) → click ▼ reveals the still-pending choices.

---

## Bug #12 — minor — sceneState mirror only retains LAST tag value when step() blobs multiple events

**Reported by**: QA (Round 3, 2026-05-06)
**Severity**: minor — visual identity of "current event" drifts to whatever event ends the blob, not what the player should see.

**Repro**:
1. At Day 1 morning_briefing → click `[开始今日]`
2. ink `step()` drains through `day_1_event_1_vivian` (no choices) → `day_1_event_2_caishuijian` (3 choices)
3. Tags fired during the drain (in order):
   - Event 1.1: `# scene: reception` / `# npc: vivian_smiling` / `# prop: fruit_bowl_apple`
   - Event 1.2: `# scene: break_room` / `# npc: lisa_holding_milk_tea_cup` / `# npc: lao_li_mopping_background` / `# npc: it_xiaoma_back_at_machine` / `# prop: coffee_machine_broken_sign`
4. Driver reads `__qa.sceneState.snapshot`:
   - `scene: 'break_room'` (Event 1.2's value — Event 1.1's `reception` was overwritten)
   - `npc: 'it_xiaoma_back_at_machine'` (last npc tag — Vivian / Lisa / 李阿姨 all overwritten)

**Expected**: a "currently visible NPC set" not "single NPC value", so all 4 NPCs (Vivian + Lisa + 李阿姨 + IT 小马) can be displayed simultaneously per art-bible §7.1.

**Actual**: single-slot mirror reduces to last value.

**Files involved**: `game/src/scene/scene-state-mirror.ts:81-91` (the `set()` method overwrites `cache[key]`).

**Severity rationale**: this is intrinsically tied to Bug #3 (multi-event step blob). If Bug #3 is fixed (Option A: ink-side choice gate per event, OR Option B: renderer-side page break), then each event renders alone and the single-slot mirror is correct. Until then, the mirror is "best effort" and downstream UI may not reflect the player's mental model of "who's in this scene".

**Status**: ✓ resolved (by gating dependency) — Bug #3 was resolved via Q-2 Option B (`# pagebreak` tag, see `feat(p5-pagebreak)+fix(qa-bug-3)` `fb3b4df`). With `# pagebreak` between events, each `step()` contains at most one event's worth of `# scene:` / `# npc:` / `# prop:` tags, so the mirror's single-slot value reflects the "current event" correctly. No engine change needed — single-slot is the right abstraction once content respects the pagebreak boundary.

**Caveat — designer-side ongoing concern**: the resolution depends on `# pagebreak` coverage in `episode-1/2/3/4.ink` per the GM tagging policy table in `p5-phase2-engine-questions.md` Q-2:

| 场景 | 加 `# pagebreak`? |
|---|---|
| `day_N_after_work` 选项后 → daily_recap 之间 | ✅ |
| `day_N_daily_recap` 末 → next morning_briefing 之间 | ✅ |
| 周五 daily_recap → weekly_recap → next 周一 morning 之间 | ✅ × 2 |
| 长 internal monologue 块 (≥ 4 段) 后 → 下一 NPC 出场前 | ✅ |
| KPI Review screen 触发前 | ✅ (if ink-internal) |
| episode finale → cliffhanger 前 | ✅ |

If a designer sweep misses an event boundary, the single-slot mirror will still drift through that boundary's blob. The fix in those cases is content-side (add the missing pagebreak), NOT engine-side. Engine has done its part.

**Engineering note**: a "multi-slot" mirror was considered (e.g. `npc: Set<string>` instead of `npc: string`) but rejected — it pushes the "which NPC is currently visible" question to the consumer, who would need policy logic ("show last", "show all", "show speakers") that varies per layer (sprite slot vs. dialog vs. recap). Single-slot + designer pagebreak coverage gives a clean contract: "the latest tag wins, designer ensures one event per step". Re-evaluate if a future use case actually needs multi-NPC concurrency within one step.

---

## Round 3 tooling notes

- **N9 — `__qa` hook extended**: now exposes `sceneState` + `propRegistry` singletons in addition to ink/flow/save/app. Used by Round 3 driver to read scene state mirror snapshot and stage prop labels.
- **N10 — `localStorage.clear()` initScript breaks reload tests**: changed beforeEach to `goto('about:blank') → evaluate(localStorage.clear) → goto('/')` instead of `addInitScript` (which fires on every reload). Otherwise refresh tests can't see the saved data they just wrote.
- **N11 — Stage tree at Event 1.1 (post-fix)**: `world / workstation-bg / sticky / monitor / Sprite / calendar / Sprite / mug / Sprite / prop:fruit_bowl / prop:phone / ink-dialog / Graphics / Graphics / choices / internal-monologue / sticky-notes / sticky-0 / Graphics / Graphics / sticky-1 / Graphics / Graphics / sticky-2 / Graphics / Graphics`. Concrete evidence Bug #8 fix lands.
- **N12 — Smoke tests baseline post-fix**: `pnpm test` = 233/233 passing (was 179). Engineer added 54 new tests covering speech-bubble (T10a), internal monologue (T10b), sticky-notes (T11), scene state mirror, prop registry, ink save schema. No regressions.
- **N13 — Latest dev commits seen**: `7f62762` (T03 scene mirror), `6fb3445` (T05 + T03 prop), `dedb258` (fix qa-bug-4,5,9 + T16). Plus uncommitted ink content sweep on `episode-1.ink:643/720` closing Bug #1 + #2 silently.

---

## Bug #13 — major UX — sticky-note choices vertically overlap dialog narration text

**Reported by**: GM playtest (2026-05-06, Day 1 茶水间 + Day 2 老周凉茶 sessions)
**Severity**: major UX — sticky cards mounted at desk-surface Y (~265) collide with bottom-anchored narration panel (y=180-336, height 156). Players see choice cards covering 2-3 lines of narration body.

**Repro**:
1. New game → 开始今日 → Day 1 Event 1.2 (茶水间 Lisa) — narration paints with "工位旁边的水果盘今天是…茶水间…她手里的不是保温杯…茶水间另一头, 李阿姨在拖地…" then 3 sticky choices (`让 Lisa 先 / 你先 / 不说话, 先接你的`) appear in the middle 1/3 of the panel area, hiding the bottom 3 lines of narration.
2. Same pattern repeats at Day 2 Event 2.3 老周凉茶 — choices `[偷喝那杯, 再走 / 拿走杯子, 去洗, 再放回 / 主动跟老周说"对不起..."]` cover "你站在他工位侧后. 他低头看 Excel..." narration lines.

**Expected** (per art-bible §7.1 + sticky-note design intent):
- Either: narration shows in panel, then `# pagebreak` click → hide panel + show choices alone at desk surface
- OR: panel shrinks to top 1/3 of bottom area (~y=180-240), sticky-notes occupy bottom 1/3 (~y=240-336)

**Actual**: panel + sticky overlap, both Y-overlap in the same 156px region.

**Files involved**: `game/src/render/dialog/ink-dialog.ts` (panel position/size), `game/src/render/choice/sticky-notes.ts` (sticky Y constant).

**Suggested fix path**:
- **Option A (smallest)**: bump sticky-notes `STICKY_CENTER_Y` from ~265 → ~310 (last 50px row), shrink panel to `PANEL_H = 100` (only top 100px of bottom area). Risk: 100px is tight for daily_recap text.
- **Option B (cleaner per art-bible)**: when `step.choices.length > 0`, hide narration panel entirely; choices render alone at desk surface y=240-336. Force player to use pagebreak `▼` continuation to read narration before choices appear. Requires new flow: text→pagebreak→text→...→text→choices.

**GM recommendation**: Option B. Aligns with "sticky-note choices on desk = main interaction, narration panel = transient flavor between beats" art-bible intent.

**GM decision (2026-05-06, post-playtest)**: ✅ **Option B confirmed**.

W1 implementation spec:
1. When `step.choices.length > 0` AND `step.text` non-empty: paint narration into panel only, do NOT mount sticky-notes yet. Mount the existing pagebreak `▼` continuation affordance.
2. Player click ▼ → drain narration panel (clear `text.text`) → call `step()` again to either reveal more narration (if pagebreak split it) OR fall through to choice presentation.
3. When `step.text` is empty AND `step.choices.length > 0`: mount sticky-notes alone at desk surface (current y=265 OK once panel is gone).
4. Edge: if `step.text` only contains 1-2 short lines + choices (Decision Moment style — no `# pagebreak` separator before choices), render narration in a smaller header band ABOVE the sticky rack (not bottom panel). Keeps short prompts together with their choices, removes need for ▼ click.

`step` shape today: `{ text: string, choices: Array, paused: boolean, tags: ... }`. The "text + choices same step" case is what currently collides — Option B splits it into two paint phases gated by ▼.

W1 may add a heuristic: if `step.text.length < 60` (~3 line short prompt) AND no `# pagebreak` tag was seen before the choices, skip the ▼ gate and use header-band layout. Tunable.

**Status**: ✓ resolved — `fix(qa-bug-13)` (batch 9 W1 pickup, 2026-05-06). Pure phase-decision helper `dialog-phase.ts` (`decideDialogPhase()` returns one of 7 phases: `ended` / `paged` / `deferred-choices` / `header-band` / `choices-only` / `narration-only` / `empty`). `ink-dialog.ts paintStep` switches on phase:
- **deferred-choices** (text length ≥ `SHORT_PROMPT_THRESHOLD = 60`): panel + ▼; click → flush panel → mount sticky rack alone (no ink advance, same step's choices).
- **header-band** (text length < threshold): no panel, narration as small Text node centered at `y=200` (above the sticky rack), rack mounts simultaneously. Decision-Moment style.
- **choices-only**: empty narration → rack alone at desk surface (existing behavior).
- All other phases (`ended`/`paged`/`narration-only`/`empty`) preserve their prior render path.

`advanceContinue()` extended: handles two cases — flushing the deferred-choices step (no ink advance, just transition phase A → phase B) AND the existing pagebreak resume.

Tests: 12 new vitest cases in `tests/render/dialog/dialog-phase.test.ts` covering all 7 phases + boundary at threshold + pagebreak override + custom threshold + reproducer + Decision-Moment short prompt. 266/266 total.

---

## Bug #14 — major — phone (and other) prop persists across scenes; covers daily_recap text

**Reported by**: GM playtest (2026-05-06, Day 1 daily_recap)
**Severity**: major — daily_recap KPI/钱/状态/关键时刻 text rendered, but phone sprite (face_up state, mounted via earlier `# prop: phone_*` tag) is positioned in the middle of the screen, covering the recap body text. Mug + fruit bowl correctly stay at desk left/right edges, but phone has no off-desk parking position.

**Repro**:
1. Day 1 morning_briefing → progress through Day 1 events. At some point ink emits `# prop: phone_face_up` (or similar — daily intro / Lisa text setup).
2. End of day → after_work `[按时下班]` → daily_recap paints in narration panel.
3. Phone sprite stays mounted at its desk-mid position (which on the 640×360 canvas is the same area where recap text renders).
4. Visual collision: phone body intersects recap text "今日 钱: 5502 (起始 5500)" + "今日 状态: 82/100".

**Expected**: scene transition (morning_briefing → recap) should either (a) unmount transient props, OR (b) move recap text to a non-prop-occupied region.

**Actual**: PropRegistry tracks props by id but doesn't unmount on scene change. T04 (scene registry + transitions) not yet done.

**Files involved**: `game/src/render/diegetic/prop-registry.ts`, `game/src/render/scene/workstation.ts` (mounts phone with no teardown trigger).

**Suggested fix path**:
- Short-term: when ink emits `# scene: <new>`, PropRegistry destroys non-permanent props. Permanent (mug/monitor/calendar) are bg-bound; transient (phone/fruit_bowl) are scene-bound.
- Or: dedicated daily_recap scene with its own BG that hides desk surface.

**Status**: ✓ resolved — `fix(qa-bug-14)` (batch 11 W1 pickup, 2026-05-06). PropEntity gains `scope: 'permanent' | 'scene'` (default `'scene'`). Scene-scoped props start invisible at mount; `setState()` always sets `visible=true` (any `# prop:` tag wakes the prop, even when the state matches the current one). PropRegistry adds `hideScopedTo(scope)` that bulk-hides all matching entities. workstation.ts wires `sceneState.on('scene', () => propRegistry.hideScopedTo('scene'))` so transient props auto-hide on `# scene:` tag value change. Re-show on the next `# prop:` tag.

For the recap reproducer: phone starts hidden at mount → never visible until ink emits a phone tag (which currently happens at Day 2 Event 2.2 only) → during Day 1 daily_recap (`# scene: home_phone_screen`), phone is hidden, no collision with recap text. fruit_bowl follows the same lifecycle: hidden until `# prop: fruit_bowl_apple` fires (Day 1 Event 1.1 Vivian), hidden again at next scene change, re-shown at next prop tag.

Permanent props (mug, monitor, calendar — currently bound directly to game state singletons, NOT via the registry yet) are NOT in this lifecycle and stay visible. When they migrate to the registry (post-T05/T06), they'll register with `scope: 'permanent'`.

Tests: 6 new vitest cases in `prop-registry.test.ts`. Total 272/272.

---

## Bug #15 — minor → major (per visibility) — sprite sheet label leakage visible at runtime

**Reported by**: GM playtest (2026-05-06)
**Severity**: was minor in W5 round-1 self-check (assumed sprite scale ≥0.1 hides it); actual scale at runtime makes it visible — promote to major visual.

**Visible labels**:
- `fruit_bowl_apple.png`: top-right "Front" text + bottom-right "9:00" timestamp visible in all screenshots
- `xiaotian_polo` expression sub-sprites: similar (W5 round-2 audit confirmed cuts.yaml mapping is correct, but labels leak through)

**Files involved**: `assets/sprites/test_outputs/fruit_bowl_3frame_sheet.png` source — labels are baked into the sheet at the cell-edge boundaries, cuts.yaml `label_band=60` doesn't fully strip them.

**Suggested fix path**:
- **Option A**: re-cut with bigger `label_band` value (try 80 or 100), re-sync. Cheap.
- **Option B**: re-prompt the sheet without label band entirely (W5 round 3, ~$0.13 per asset). Slow but clean.
- **Option C**: PixiJS Sprite-side crop mask removes top-right + bottom-right N pixels after Assets.load. W1 task.

**GM recommendation**: Option A first (15 min). If still visible, fall back to C.

**Status**: ✓ resolved via Option C — `fix(qa-bug-15)` (batch 16 W1 pickup, 2026-05-06). W5 hadn't acted in R6/R7/R8/R9 and GM marked the bug "promote priority — visible in every screenshot", so W1 implemented the Pixi-side crop. See the duplicate-mention block lower in this file for full implementation notes; W5 can still do Option A (cleaner source) and drop the `cropEdges` spec from `workstation.ts` when ready.

---

## Bug #16 — major — speech bubble anchored to wrong screen position; floats over no NPC

**Reported by**: GM playtest (2026-05-06, Day 2 老周凉茶)
**Severity**: major — bubble "你喝什么?" appears at top-right of canvas (~x=560, y=60) with downward tail pointing to empty wall texture. No NPC sprite there. The line is 老周's, but his stub anchor position doesn't match where he should visually be.

**Repro**:
1. Day 2 morning → after_work events → reach Day 2 Event 2.3 老周凉茶
2. 老周's line "你喝什么?" mounts as bubble at npc-anchors.ts stub coords for `lao_zhou` (likely top-right per default registry order).
3. Visually: speech bubble floats high-right, but the narration says "你站在他工位侧后" — he's behind/right of the player. Bubble position doesn't match narrative geometry.

**Expected**: bubble appears at NPC's actual on-screen position OR at narrative-consistent position (老周 = right-side workstation).

**Actual**: stub anchors are placeholder coords pending T05/T06 sprite slot wiring. They don't reflect NPC position.

**Files involved**: `game/src/render/dialog/npc-anchors.ts` (stub coords table). `T05/T06` will replace with sprite-anchored positions, but until then stub coords are visible.

**Suggested fix path**:
- Quick fix: re-tune stub coords in `npc-anchors.ts` to plausible workstation-context positions (老周=right-mid, Lisa=right-near, David=mid-left, 王总监=mid-top, etc) so bubbles at least don't float in absurd locations.
- Real fix: T05/T06 NPC sprite slots — bubble anchors to sprite.position + headOffset.

**GM recommendation**: stub-tune NOW (~30min of W1 time), real T05/T06 lands next batch.

**Status**: ✓ resolved (interim) — `fix(qa-bug-16)` (batch 8 W1 pickup, 2026-05-06). `npc-anchors.ts` re-tuned: 老周 → x=540 y=160 (right-mid, further right than Lisa), David → x=180 y=160 (mid-left), Vivian → x=440 y=80 (reception top-right), 王总监 → x=320 y=80 (mid-top projector), Lisa → x=480 y=130 (right-near), 李阿姨 → x=120 y=250 (bottom-left cleaning), IT 小马 → x=140 y=210 (coffee machine), Zoe → x=260 y=80 (HR top-mid-left), 林姐 → x=200 y=130 (cross-team mid-left), 妈妈 → x=320 y=180 (phone scene mid). Bubbles now lock to narratively-plausible positions; real fix still lands at T05/T06 NPC sprite slot wiring (these stubs go away then). Both `NPC_ANCHORS` (Chinese name table, legacy fallback) and `NPC_ANCHORS_BY_ID` (Q-1 id table, primary path) updated together.

---

## Bug #17 — minor — narration text appears to render outside panel BG bounds

**Reported by**: GM playtest (2026-05-06)
**Severity**: minor — possibly a visual artifact of panel transparency + text antialiasing, hard to confirm from screenshots. Some narration text lines appear partially behind sticky-notes (which is Bug #13 root cause).

**Suggested action**: investigate after Bug #13 fix lands. Likely auto-resolves if Option B (hide panel when choices show) is implemented.

**Status**: ✓ resolved (likely) — `fix(qa-bug-13)` (batch 9): panel is now hidden when sticky rack is up (deferred-choices phase 2 + choices-only + header-band). Re-verify on next QA round; if any text is still visible outside panel bounds in narration-only / paged phases, file a follow-up bug.

---

## Round 4 — verify Bug #3 + Bug #6 dev fixes (`qa/p5-demo-r4.spec.ts`, 3 tests, all pass)

W2 QA Round 4 (2026-05-06). Verifies the two `fix(qa-bug-N)` commits that landed since Round 3:
- `fb3b4df feat(p5-pagebreak)+fix(qa-bug-3)`
- `3b91ff1 feat(p5-T11-fit)+fix(qa-bug-6)`

Driver gained `advanceToChoices(page)` + `pickChoiceAndAdvance(page, idx)` helpers that handle the new pagebreak gates by tap-to-continue clicking the panel until next choice surfaces.

### Verifies

- ✓ **Bug #3 (daily_recap blob)** — RESOLVED. Driver picks `[按时下班]` on Day 1 → immediate paint has 0 sticky/choice buttons (gate active) + panel text contains end of `day_1_after_work` ("Lisa: 明天见啊…") but NOT yet `day_2_morning` markers. After ≥ 1 tap-to-continue, lands at Day 2 `[开始今日]` with panel "早上你出门时下小雨" (Day 2 morning's opening). Each day-end → next-day-start now properly gated. Pagebreak count seen Day 1 → Day 2: 2 taps (matches `# pagebreak` placement at episode-1.ink:517 + :544).
- ✓ **Bug #6 (sticky-note ellipsis)** — RESOLVED. Day 2 Event 2.3's longest choice `[主动跟老周说"对不起，您那杯茶我喝了"]` (17+ chars source) renders as `主动跟老周说"对不起，您…` (13 chars + `…`) — proves 2-line + ellipsis truncation per Q-3 spec. Medium choices (`让 Lisa 先`, `不说话，先接你的`) render fully. Intro screen 3 single-choice `[我懂了, 开始第 1 天]` (9 chars) renders fully (within 2-line budget).

### Round 4 tooling notes

- **N14 — Pagebreak interaction in driver chains**: clicking a sticky-note often does NOT immediately reveal the next choice — pagebreak gates intervene. Driver helpers `advanceToChoices(page, maxTaps=8)` + `pickChoiceAndAdvance(page, idx)` make chains resilient. Going forward all R5+ drivers should use these.
- **N15 — Smoke tests post-fix**: 253/253 (was 233 in R3, 179 baseline). 20 new tests added covering pagebreak + sticky-fit. No regressions.
- **N16 — Day 1 → Day 2 path now playable end-to-end**: from boot to Day 2 Event 2.3 picks all work without console errors. Bug #1 (engineer-filed runtime crash) confirmed silent on this path again. Day 3+ untested in R4 but next round.

### Next round target (R5)

Verify GM-filed Bug #13 (sticky overlay/narration overlap) + Bug #14 (phone prop persists across scenes) + Bug #15 (sprite sheet label leak) + Bug #16 (speech bubble anchor) + Bug #17 (narration outside panel BG) — all from 2026-05-06 GM playtest. Plus extend driver to Day 3-7 paths since Day 1+2 stable.

---

## Round 5 — verify Bug #16 + visual checks #13/#14/#15 (`qa/p5-demo-r5.spec.ts`, 5 tests, 4 pass + 1 reveals new Bug #18)

W2 QA Round 5 (2026-05-06). Latest commits seen:
- `cfcc902 fix(qa-bug-16): re-tune NPC anchor stubs to narrative geometry`
- `7ded1bd fix(qa-bug-1,2): commit episode-1.ink content fixes verified by QA Round 3`

Working tree has uncommitted batch-9 Bug #13 fix (`game/src/render/dialog/dialog-phase.ts` + `ink-dialog.ts` panel-hide-when-sticky logic).

### Verifies

- ✓ **Bug #13 (sticky overlap narration)** — RESOLVED visually. Driver at Event 1.2 (3 sticky choices) sees: dialog text node with empty content (`text=""`), 4 sticky labels (sticky-notes container + 3 sticky-N children), no panel overlap. The deferred-choices phase shows panel + ▼ first; after tap the panel clears and sticky rack appears alone. Header-band/choices-only phases also kick in correctly. No regressions in the narration-only phase.
- ✓ **Bug #16 anchor table** — VERIFIED (via code read). `npc-anchors.ts` has 老周=(540,160), Lisa=(480,130), David=(180,160), 王总监=(320,80), Vivian=(440,80), 李阿姨=(120,250), IT 小马=(140,210), Zoe=(260,80), 林姐=(200,130), 妈妈=(320,180) — both `NPC_ANCHORS` (Chinese name fallback) and `NPC_ANCHORS_BY_ID` (Q-1 id primary) updated. Lisa's bubble visually anchors at right-near top (matches new (480,130) coords). Bug #16 itself is closed; Round 5 surfaced a SEPARATE stale-bubble issue (see Bug #18 below).
- ✓ **Bug #14 still open** (visual confirmation) — phone prop label persists in stage tree at Day 1 daily_recap pagebreak AND Day 2 morning. `prop:phone` mounted alongside `prop:fruit_bowl` across scene boundaries. Matches GM playtest report.
- ✓ **Bug #15 still open** (visual screenshot captured) — `qa/output/r5-04-day1-morning-fruit-phone.png` shows the fruit_bowl + phone props on the workstation BG. Sprite-sheet label leakage requires manual visual review (small text artifacts at sprite cell edges) — file inspection rather than driver assertion.
- ✓ **Bug #3 + Bug #6 no regressions**: Day 2 Event 2.3 long-sentence choice still renders as `主动跟老周说"对不起，您…` (truncated + ellipsis). Pagebreak still gates Day 1 → Day 2.

### NEW bug found in Round 5

---

## Bug #18 — major — speech bubble persists across step-blob event boundaries; stale bubble from earlier event shows during later event

**Reported by**: QA (Round 5, 2026-05-06)
**Severity**: major UX — when a step blob crosses multiple events (e.g. Day 2 Event 2.1 → 2.2 → 2.3), a speech bubble mounted for an earlier event's speaker remains on screen during the later event where the speaker isn't present.

**Repro**:
1. New game → 开始今日 → intro 1/2/3 → Day 1 events → after_work `[按时下班]` → Day 2 morning → Day 2 Event 2.1 (Lisa milk tea), pick `[一起]`
2. `[一起]` choice body emits Lisa narration `Lisa："你喝什么？"` (episode-1.ink:614) → speech bubble mounts for Lisa at her tuned anchor (x=480, y=130)
3. ink continues through Event 2.2 (David PPT setup, no choices, narration but no Lisa speech) → Event 2.3 (老周凉茶, presents 3 choices)
4. **Visual at Event 2.3 choice phase**: Lisa's "你喝什么?" bubble is STILL ON SCREEN at her right-near anchor, alongside Event 2.3's narration "你站在他工位侧后方…" and 3 老周 sticky choices

**Expected**: speech bubble lifecycle is bounded to the speaker's narration moment. When step advances past the line that mounted the bubble, the bubble unmounts.

**Actual**: bubble persists across step-internal event boundaries until the NEXT bubble mounts (which only happens if a new speaker emits a `**X**：` line). At Event 2.3 nobody speaks (all narration is description), so Lisa's bubble lingers indefinitely.

**Files involved**: `game/src/render/dialog/ink-dialog.ts` (speech-bubble lifecycle), `game/src/render/dialog/speech-bubble.ts` (mount/destroy).

**Suggested fix path**:
- (A) Tear down speech bubble at start of every paintStep cycle (forces bubble to re-mount only if current step has speaker text). Aligns with prop-registry future scene-bound destroy.
- (B) Track speaker tag changes via sceneState mirror — when `speaker` changes, destroy old bubble. Won't work for parseSpeaker fallback path though.
- (C) Listen for `# scene:` change → tear down all transient overlays (bubbles + non-permanent props). Cleanest but couples to T04 scene transitions.

**GM call needed**: which lifecycle policy? My read: (A) is shortest-path fix — bubble shows ONLY for the step whose narration mounted it.

**Severity rationale**: not visually disorienting in isolation but compounds with Bug #14 (phone prop persists). Same root pattern: stage objects don't unmount on event boundaries within a step blob.

**Status**: ✓ resolved — `fix(qa-bug-18)` (batch 10 W1 pickup, 2026-05-06). `advanceContinue()` case 1 (deferred-choices flush) now also calls `clearBubble()` + `clearMonologue()` + `clearHeaderBand()` before mounting the sticky rack. Narration-bound overlays (bubble = "who is speaking", monologue = "internal voice") were tied to the panel narration that gets dismissed; they unmount alongside it. Pagebreak resume (case 2) doesn't need this fix because `paintStep` starts with the same three clears.

Fix is option (A) per the suggested-fix table: tear bubble down at the dismiss boundary. Doesn't help when the SAME step's first paragraph is by Lisa and a later paragraph is by 老周 — that's a multi-speaker-blob issue separate from this fix. With Bug #3 ✓ resolved (each event gated by `# pagebreak`), each paint cycle should now contain at most one speaker, so the multi-speaker case no longer occurs in episodes where designer applied the policy table.

### Round 5 tooling notes

- **N17 — `npx playwright` triggered fresh install**: in this round `npx playwright test` warned `package not found and will be installed: playwright@1.59.1` then failed with "two different versions of @playwright/test". Fix: use `pnpm exec playwright test` instead of `npx`. Updated muscle memory; future rounds use pnpm exec.
- **N18 — Stage tree dump still useful**: at Event 1.2 sticky phase, full label list = `world / workstation-bg / sticky / monitor / Sprite / calendar / Sprite / mug / Sprite / prop:fruit_bowl / prop:phone / ink-dialog / Graphics / Graphics / choices / internal-monologue / sticky-notes / sticky-0 / Graphics / Graphics / sticky-1 / Graphics / Graphics / sticky-2 / Graphics / Graphics`. Note `internal-monologue` label persists empty-ish; not yet investigated.
- **N19 — Smoke tests post-fix**: 266/266 pass per dev's batch 9 description (12 new dialog-phase tests). Re-confirmed via `pnpm test`.

### Next round target (R6)

Verify Bug #18 fix when it lands. Verify Bug #14 (phone unmount on scene change) when fix lands. Verify Bug #15 (sprite label leak) Option A or C fix when it lands. Extend driver to Day 3-7 paths now that Day 1-2 are clean.

---

## Round 6 — verify Bug #18 fix + Bug #13 commit (`qa/p5-demo-r6.spec.ts`, 3 tests, all pass)

W2 QA Round 6 (2026-05-06). Latest commits:
- `a576f7a fix(qa-bug-18): tear down speech bubble + monologue on deferred-choices flush`
- `63931dc fix(qa-bug-13): defer sticky rack behind ▼ click; header band for short prompts`

### Verifies

- ✓ **Bug #18 (stale speech bubble)** — RESOLVED in `a576f7a`. Driver path: Day 2 Event 2.1 `[一起]` (mounts Lisa "你喝什么?" bubble) → ink advances through Event 2.2 (David, no choices) → Event 2.3 (老周凉茶, 3 sticky choices). At Event 2.3 sticky phase: `speech-bubble` label count = 0 (was 1 stale in R5), `readSpeechBubbleText()` returns `[]` (no "你喝什么" content). Bubble torn down at the deferred-choices flush boundary, so it doesn't bleed into the next event's sticky-rack phase.
- ✓ **Bug #13 commit** — VERIFIED (was working tree only in R5, now formally committed as `63931dc`). Driver verifies the 2-paint cycle: after `[开始今日]` (which leads to long Event 1.1+1.2 narration > 60-char threshold), labels list immediately = `[]` (deferred-choices phase: panel + ▼ visible, no sticky yet). After 1 panel-tap to flush: labels list = `[sticky-0=让 Lisa 先, sticky-1=你先, sticky-2=不说话，先接你的]` (sticky rack mounted alone). No overlap.
- ✓ **No regressions on #1/#3/#6**: Day 2 Event 2.3 long sticky still rendered with ellipsis (`主动跟老周说"对不起，您…`). Picking `[偷喝那杯，再走]` → no `pageerror`, no console error. Pagebreak gating still works.

### Round 6 tooling notes

- **N20 — Bug #18 reproducer dropped on dev's lap clean**: my Round 5 filing matched the engineer's understanding of the issue (per `a576f7a` commit message: "Step blob contained Lisa's line at Event 2.1 + narration through 2.2 + choices at 2.3 — paintStep mounted Lisa's bubble for the first paragraph"). Engineer fix was tear-down at deferred-choices flush boundary — clean.
- **N21 — Smoke tests baseline post-fix**: `pnpm test` = 266/266 still passing (no new tests added in this batch; Bug #18 fix is rendering-side and tested via R6 driver).
- **N22 — Day 2 path stable now**: after R5 → R6, the entire Day 1 + Day 2 path through Event 2.3 picks all work without any console errors or visual artifacts.

### Next round target (R7)

Bug #14 (phone prop persistence across scenes) + Bug #15 (sprite-sheet label leakage) still open per W1 backlog. Will verify when fixes land. Meanwhile R7 should extend driver into Day 3-7 paths (sticky-rack 3-choice variants, 申报加班 path, 提前下班 path, KPI weekly recap, weekend regen).

---

## Round 7 — verify Bug #14 fix (`qa/p5-demo-r7.spec.ts`, 2 tests, all pass)

W2 QA Round 7 (2026-05-06). Latest commit: `bcd2fb0 fix(qa-bug-14): PropEntity scope + scene-aware hide/show`. Smoke 272/272 (was 266 — 6 new tests for Bug #14 fix).

### Verifies

- ✓ **Bug #14 (phone prop persistence)** — RESOLVED in `bcd2fb0`. Approach: "hide-not-destroy" with scene-aware bulk-hide. Driver verifies: at Day 1 daily_recap pagebreak (where Bug #14 was reported), `prop:phone visible=false` (was `visible=true` covering recap text in R5 GM playtest). Fix applies cleanly: both `prop:fruit_bowl` and `prop:phone` are scene-scoped — when ink emits a `# scene:` change, all scene-scoped props bulk-hide. Then the next `# prop:` tag re-shows the specific prop. Effect: at any given beat, only the prop tags from the CURRENT/most-recent scene block are visible.
- ✓ **Re-verify #6 / #13 / #18 (no regressions)** — Day 2 Event 2.3 long sticky still ellipsised, deferred-choices flush still works (panel + ▼ → sticky alone), no stale Lisa bubble at 老周 scene.
- ✓ **No `pageerror` / console errors** during full Day 1 → Day 2 walkthrough.

### Round 7 observation

- **Visibility-vs-correctness**: my Round 5 reproducer was specifically about phone covering recap text. The fix is broader — hides ALL scene-scoped props during scene transitions, including ones that should logically still be there (e.g. fruit_bowl during a quick visit to the break_room). For the demo this is fine since props re-emit on each scene's first beat. Worth noting in case future events expect props to "stick" across short scene blips.

### Round 7 tooling notes

- **N23 — Smoke tests post-fix**: 272/272 (was 266). 6 new tests for PropEntity scope + scene-aware hide/show.

### Next round target (R8)

Bug #15 (sprite-sheet label leakage) still open. Either Option A (re-cut with bigger label_band) or Option C (PixiJS Sprite-side crop mask) — neither in commit log yet. Will verify when fix lands. Meanwhile R8 should attempt Day 3-7 driver coverage (申报加班 path needs energy-sufficient state, 提前下班 path tests AP-leftover behavior, weekly recap at Day 7).

---

## Round 8 — Day 3 reach + cross-day smoke + path-interceptor sanity (`qa/p5-demo-r8.spec.ts`, 2 tests, all pass)

W2 QA Round 8 (2026-05-06). Latest commit: `f900968 feat(p5-path-interceptor): close Q-4 — checkpoint-tag-based finale branching`. Smoke 285/285 (was 272 — 13 new tests for path-interceptor). Not a `fix(qa-bug-N)` so this round = regression smoke + extend coverage.

### Verifies

- ✓ **No regressions** on R6 + R7 — both run clean against new tree (5/5 pass).
- ✓ **Day 3 reach**: driver successfully drives boot → intro → Day 1 (4 choice points) → Day 2 (2 choice points) → Day 3 first choice (Event 3.2 Lisa after meeting: `[看大家吧 / 我不去 / 我也不知道]`). All pagebreaks work. Final VAR snapshot at Day 3 first choice phase: `lisa_score=4, lao_zhou_score=0, state=88, money=5491`.
- ✓ **Path interceptor sanity** — Day 1 walkthrough fires zero checkpoint tags (none exist in episode-1 Day 1-2; checkpoint mechanism is for E8/E12 finale per Q-4 spec). No `pageerror` from unrelated path-interceptor module load.

### NEW finding: Day 2 after_work + Day 2 daily_recap are STUBS in episode-1.ink

**Severity**: discussion (content gap, not a code bug)

`design/vertical-slice/episode-1.ink:738-746` — both `day_2_after_work` and `day_2_daily_recap` are 1-line comment placeholders with `# pagebreak` + divert, no narration content + no 申报加班/按时下班/提前下班 3-choice rack.

```ink
= day_2_after_work
// 同 Day 1 模板 - 申报加班 / 按时下班 / 提前下班 三选 1
// (省略以避免重复 - 分身写时按 day_1_after_work 模板, 文案微调)
~ check_state_after_choice()
# pagebreak
-> day_2_daily_recap

= day_2_daily_recap
// 同 Day 1 模板 - 关键时刻 today
# pagebreak
-> day_3_morning_briefing
```

**Effect**: after picking any Day 2 Event 2.3 choice, player taps through 2 empty pagebreaks and lands at Day 3 morning briefing. No way to choose 申报加班 / 按时下班 / 提前下班 on Day 2; no Day 2 recap stats visible. Day 3-7 have full content per `grep '= day_N_after_work / = day_N_daily_recap'` (lines 959, 996, 1237, 1273, 1488, 1533, 1715, 1955).

**Suggested action**: designer fills in Day 2 stubs (comments mark them as "分身写时按 day_1_after_work 模板, 文案微调" — flagged as designer/clone task). Not a bug per se but worth surfacing.

### Round 8 tooling notes

- **N24 — Smoke baseline**: `pnpm test` = 285/285 (was 272). 13 new tests for path-interceptor module.
- **N25 — Day 3 first event = Event 3.2 (Lisa after meeting)**: not Event 3.1 (晨会 fakeout) since 3.1 has no choices and folds into the same step blob as 3.2's choices. Per `grep '* \[' episode-1.ink` Day 3 has choices at: 3.2 (3 choices), 3.4 (none), day_3_after_work (3 choices: 申报加班/按时下班/提前下班 — line 955-967).

### Next round target (R9)

Bug #15 still open. Will verify when fix lands. Otherwise R9 extends to Day 3-7 full traversal: pick all 3 day_3_after_work options across separate test runs to verify branching, reach Day 7 cliffhanger ("周一晨会王总监会问 KPI 吧?" line 1898).

---

## Round 9 — verify Bug #11 fix (`qa/p5-demo-r9.spec.ts`, 2 tests, all pass)

W2 QA Round 9 (2026-05-06). Latest commit: `a81da37 fix(qa-bug-11): persist last narration text across reload (T16 follow-up)`. Smoke 293/293 (was 285 — 8 new tests for `dialog-state.ts` + paintStep fallback).

### Verifies

- ✓ **Bug #11 (placeholder `...` on reload)** — RESOLVED in `a81da37`. Driver path: progress past intro screen 1 + 2 + 3 (panel painted with "游戏从 2026 年 5 月开始 / 52 周") → reload → panel shows intro screen 2 content ("我每天有 8 个时间槽 / 不可能三角 / 钱多事少离家近"), NOT `...` or empty. Fallback chain works: post-reload, ink at intro 3's choice point with no text to drain → paintStep falls back to `dialogState.lastNarrationText` (captured by autosave at the previous step boundary) → panel renders meaningful content.
- ✓ **Re-verify R6/R7/R8 path no regressions**: deferred-choices flush still works (Bug #13), no stale Lisa bubble at Event 2.3 (Bug #18), props hidden during scene transitions (Bug #14, both `prop:fruit_bowl` + `prop:phone` visible=false at Event 2.3 sticky phase), long sticky still ellipsised (Bug #6).

### Round 9 observation: lastNarrationText capture is one step behind

Autosave fires AFTER `ink.selectChoice()` returns, so save captures the panel content from the PREVIOUS step (e.g. saving after 听懂了 click captures intro 2 text, not intro 3 — even though player visually saw intro 3 before clicking). After reload, panel shows intro 2 instead of intro 3. Player can still recover via the choice button (1 click 我懂了 → Day 1 morning) but the panel state is one beat behind their last visual.

**Severity**: minor (cosmetic inconsistency). Not filing as a separate bug — the fix delivers on the primary intent ("no more `...` placeholder"). A future polish could capture lastNarrationText on EVERY paintStep (not just save-time).

### Round 9 tooling notes

- **N26 — Smoke baseline**: `pnpm test` = 293/293 (was 285).
- **N27 — Driver pattern**: for testing post-reload panel state, use raw `clickChoiceByIndex` (no `advanceToChoices`) on the LAST click before reload — captures the intermediate deferred-choices state so the panel hasn't been flushed by ▼.

### Next round target (R10)

Bug #15 (sprite-sheet label leakage) still open. R10 will check for fix; otherwise extend Day 4-7 driver coverage (Day 4 weekly_report 3-choice, Day 5 events, Day 6 weekend lisa wechat, Day 7 cliffhanger).

---

## GM playtest 2026-05-06 (post-R9) — 5 screenshots filed by GM

GM ran a manual playtest after R9 closure and surfaced 4 distinct visual issues.

---

## Bug #19 — major UX — internal monologue overlay (`_..._`) Z-overlaps narration panel + sticky rack

**Reported by**: GM playtest (2026-05-06, screenshots 1, 2, 5)
**Severity**: major UX — both text streams visible on same screen area, both unreadable.

**Repro**:
- Day 3 lunch (老周吃面 + Lisa 回工位 + 茶水间咖啡机 callback) — narration panel at bottom shows "12:30。你买了便当回工位吃。 经过老周工位——他在吃面…" while italic monologue "她回工位了。 这是入职 12 周的人的想法。 3 周后再写'本周内'" renders ON TOP of the narration panel area.
- Day 7 妈妈视频 — same overlap: narration "屏幕里是妈妈。 视频背景是老家厨房——油烟机 + 挂在墙上的菜谱…" with italic "她头发花白, 刚没染过 / 她说的可能是隔壁单元李阿姨家的…" overlapped.
- Day 4 weekly_report at 16:50 — same pattern.

**Expected** (per art-bible §7.1): internal monologue is the protagonist's silent thought — distinguished spatially + stylistically from narration. Two text streams should not Z-overlap.

**Actual**: `mountInternalMonologue()` mounts at a fixed-Y region (likely middle of canvas) and the bottom narration panel overlaps that Y range. Both render simultaneously when ink emits a paragraph mixing narration + `_..._` segments.

**Files involved**: `game/src/render/dialog/internal-monologue.ts` (Y position), `game/src/render/dialog/ink-dialog.ts` (paint sequencing).

**Suggested fix path**:
- (A) Move monologue to TOP of screen (y=20-80) so it never collides with bottom panel.
- (B) Hide narration panel when monologue overlay is up; tap-to-continue between them.
- (C) Combine into one panel: monologue rendered as italic lines INSIDE the narration panel.

**GM call needed**: which of A/B/C?

**GM decision (2026-05-06)**: ✅ **Option A + style tune (combined fix for Bug #19 + #20)**.

- **Position**: monologue Text node moves to **TOP region** (y=20-80, full width centered)，永远不与 bottom narration panel + desk-surface sticky rack collide
- **Style**: 区分 narration vs monologue 视觉权重——
  - narration: 现有 panel font (12pt, white #FFFFFF, `Inter` or system, full opacity)
  - monologue: 字号 **10pt**, italic, **#A8B0C0**（cool gray，dimmer 60% opacity 等价的 desaturate）, line-height 14
- **Layout**: 长 monologue 段（>3 行）允许 wrap to 多行，max 4 lines。超过 truncate `…` 同 sticky 同 pattern
- **Lifecycle**: monologue overlay 跟 narration panel 同 bound——下个 step / pagebreak / scene-change 都 clear。具体跟 Bug #18-regression fix 同 paintStep 顶部 teardown 序

这个 fix 同时解 Bug #20——"narration = 主线剧情, monologue = 主角内心提示" 现在 visually 不同位置 + 不同字号 + 不同颜色，玩家眼睛能立刻区分。

**Status**: ✓ resolved — `fix(qa-bug-19,18-regression)` (batch 15 W1 pickup, 2026-05-06).

- **internal-monologue.ts**: `PROTAGONIST_HEAD_ANCHOR` moves from `(320, 240)` (mid-panel) → `(320, 26)` (top region, well above panel y=180-336 + sticky rack). Style retune per GM spec — `FONT_SIZE: 11 → 10`, `LINE_HEIGHT: 16 → 14`, `TEXT_COLOR: 0xe8e0cc cream → 0xa8b0c0 cool-gray`, `TEXT_ALPHA: 0.6 → 1.0` (dim is intrinsic to the color now, no alpha needed). New `MAX_LINES: 4` + `ELLIPSIS: '…'` constants; the `repaint` loop iteratively trims a char before the ellipsis until measured `Pixi.Text.height ≤ MAX_LINES * LINE_HEIGHT`. Same pattern as the sticky-notes fit helper.
- Lifecycle: existing `clearMonologue()` at `paintStep` top + the Bug #18 deferred-flush teardown both hold; no new wiring needed.
- Bug #20 ✓ closes as side-effect — narration (12pt cream upright) and monologue (10pt cool-gray italic, top of canvas) are now visually distinct on three axes (position + size + color).
- Tests: 2 prior pin tests rewritten to the new spec + 2 new pins added. Total 295/295.

---

## Bug #18-regression — major — speech bubble "好，下次哈." persists into Day 4 16:50 weekly_report

**Reported by**: GM playtest (2026-05-06, screenshot 4)
**Severity**: major — Bug #18 fix only torn down on deferred-choices flush; some code paths bypass that and leave the bubble lingering.

**Repro**:
1. Drive to Day 4 Event around line 1441 (Lisa lunch invite, `[一起 / 今天有事 / 我吃便当]`)
2. Pick `[今天有事]` → choice body emits `Lisa："好，下次哈."` (episode-1.ink:1441) → speech bubble mounts for Lisa at her tuned anchor
3. ink advances through subsequent events (Day 4 weekly_report at 16:50) — none trigger a deferred-choices flush
4. **Visual at 16:50 weekly_report**: bubble "好，下次哈." STILL on screen while panel renders weekly_report "16:50. HR 系统弹出周报浮层…"

**Expected**: bubble lifecycle bounded to its event. When ink advances past Lisa's line, bubble unmounts regardless of which subsequent paint phase fires.

**Actual**: per Bug #18 fix (`a576f7a`), bubble teardown only fires on deferred-choices flush. Day 4 path between `[今天有事]` and weekly_report doesn't go through that branch.

**Files involved**: `game/src/render/dialog/ink-dialog.ts` (paintStep — needs teardown at start of every paint, not just on flush).

**Suggested fix**: extend Bug #18 teardown to fire at the top of `paintStep()` whenever a new step is painted that doesn't itself emit a `**Speaker**：` line (or whenever `sceneState.speaker` changes). Not only the deferred-flush path.

**Status**: ✓ resolved — `fix(qa-bug-19,18-regression)` (batch 15 W1 pickup, 2026-05-06).

Different fix path than the QA suggestion: bubble teardown was already at `paintStep` top via `clearBubble()`. The actual issue was that the SAME step's text starts with Lisa's `Lisa："好，下次哈"` and continues through the next event's narration — `parseSpeaker()` matches the first paragraph and mounts the bubble for it, then the bubble lingers next to multi-paragraph narration that's no longer about Lisa.

Fix: new constant `BUBBLE_REMAINDER_THRESHOLD = 30` chars. Bubble only mounts when `parsed.remainder.trim().length <= 30` (speaker line is the *dominant* content of the step). For multi-paragraph blobs, the speaker line stays inline in the panel as `Lisa："好，下次哈"` (markdown-stripped) without a hovering bubble.

This means short Decision-Moment style steps (`Lisa："你看下这个行不行……"` + 3 choices) keep their bubble (parsed.remainder is empty). Long narrative blobs that span events skip the bubble. Threshold is tunable; 30 chars covers "1-2 line continuation" without mis-firing.

Tests: existing bubble tests still green; behavior change is exercised end-to-end by the ink-dialog phase suite + manual re-verify on next QA round.

---

## Bug #15 — STILL OPEN — sprite-sheet label "Front" visible at runtime on fruit_bowl prop

**GM playtest 2026-05-06 update**: screenshot 3 captures it precisely — fruit_bowl sprite shows "Front" text label in upper-right corner. No fix in commit log yet (R7 + R8 + R9 didn't touch). GM recommendation from earlier was Option A (re-cut with bigger `label_band`, ~15 min) or Option C (PixiJS Sprite-side crop mask). Still pending W5/W1 pickup.

**Status**: ✓ resolved (Option C) — `fix(qa-bug-15)` (batch 16 W1 pickup, 2026-05-06). PixiJS-side crop applied to fruit_bowl after W5 didn't act in R6/R7/R8/R9.

- `prop-entity.ts`: new `PropCropEdges` type (`{ top?, right?, bottom?, left? }`) on `PropEntitySpec`. New `computeCropFrame(sourceW, sourceH, edges)` pure helper returns the inner frame rect or null when no crop. New `applyCropEdges(base, edges)` builds a `Texture` sharing `base.source` with a narrowed `Rectangle` frame (cheap — only metadata changes; bitmap is shared). State-swap path also re-applies the crop on every state's loaded texture so all three frames (apple/strawberry/empty) get the same trim.
- `workstation.ts`: fruit_bowl mounts with `cropEdges: { top: 80, bottom: 80 }` (matches the 341×844 source — symmetric trim hides "Front" label at top + "9:00" timestamp at bottom without shifting visible content's vertical center relative to the sprite's anchor 0.5/0.5).
- W5 / Option A migration plan: when the source PNGs get re-cut without baked labels, drop the `cropEdges` spec from `workstation.ts` (one-line revert). The crop helper stays — useful for future leakage incidents.

Tests: 7 new vitest cases in `prop-registry.test.ts` for `computeCropFrame` (null on undefined / all-zero / empty / partial; crop math for top+bottom, all-four, asymmetric, degenerate clamp). Total 302/302.

---

## Bug #20 — design observation — narration vs internal-monologue distinction breaks down when both emitted in same step

**Reported by**: GM playtest (2026-05-06, screenshot 5 caption: "明显把需要展现的剧情, 和不需要展现的, 只是用来提示的脚本拢在一起了")
**Severity**: design call — partly fixed by Bug #19 above, but underlying authoring split is also at issue.

**Observation**: many events have a single paragraph blob containing both narration ("妈妈戴着老花眼镜…") and internal-monologue ("_她头发花白, 刚没染过_"). When `extractInternalMonologue()` separates them, both streams render at the same time. GM expectation: one of them (likely monologue) is "background hint, dimmer, less prominent" while narration is "story being told". Currently both have similar visual weight.

**Suggested action**: tone-bible / art-bible decision needed. Either:
- Monologue is dimmer / smaller / background-positioned (fixed by Bug #19's positional fix + style tune)
- OR ink authoring discipline: separate narration paragraphs and monologue paragraphs with a `# pagebreak` between them so they NEVER render simultaneously

**Status**: ⏳ open — discussion, gated on Bug #19 fix approach.

---

## Open bug backlog after GM playtest

| Bug | Severity | Status | Blocker? |
|-----|----------|--------|----------|
| #19 | major UX | open | yes — every screenshot has it |
| #18-regression | major | open | yes — visible in every Day 4+ session |
| #15 | major (per visibility) | open since R5 | yes — visible in every prop frame |
| #20 | discussion | open | no (gated on #19) |
| #6 (content sweep) | discussion | open | no |
| #7 (after_work UI) | discussion | open | no |
| #10 (paint frame desync) | minor | open | no |

R10 will verify fixes for #15 + #18-regression + #19 when they land.

---

## Round 10 — verify Bug #12 close-out (`qa/p5-demo-r10.spec.ts`, 2 tests, all pass)

W2 QA Round 10 (2026-05-06). Latest commit: `f98577d fix(qa-bug-12): close by Bug #3 resolution dependency (no engine change)`. Smoke 293/293 (no new tests; docs-only commit).

### Verifies

- ✓ **Bug #12 close** — sceneState reflects current day's scene, not stale intro. At intro phase scene='intro' time='pre_game'; after Day 1 morning_briefing scene='office_workstation' time='9:14'.
- ✓ **Re-verify Bug #11 + #14** — no regressions. Post-reload panel still shows narration content, props still hide on scene change.

### Caveat: intra-day event blobs still single-slot

Bug #12 close rationale only fully holds **cross-day**. Intra-day events without `# pagebreak` still blob — at Event 1.2 sticky phase, `scene: 'break_room'` (1.2's last tag) overwrites 1.1's `reception`. Practical impact: future "multi-NPC in one event" features would still drop earlier NPCs. Not a reopener, just noting closure scope.

### Round 10 outstanding (no fixes since R9)

- Bug #19 (monologue overlay Z-collision) — top GM-filed, no fix yet
- Bug #18-regression (stale Lisa bubble at Day 4 weekly_report) — no fix yet
- Bug #15 (sprite-sheet "Front" label leak) — no fix yet (open since R5)

### Next round target (R11)

Verify #19 / #18-regression / #15 fixes when they land. Otherwise extend driver to Day 5-7.

---

## Round 11 — verify Bug #19 + Bug #18-regression (`qa/p5-demo-r11.spec.ts`, 4 tests, all pass)

W2 QA Round 11 (2026-05-06). Latest commit: `fafa078 fix(qa-bug-19,18-regression): monologue top-region retune + bubble dominance heuristic`. Smoke 295/295 (was 293 — 2 new tests).

### Verifies

- ✓ **Bug #19 (monologue Z-overlap)** — RESOLVED via Option A. Driver verifies: post-flush states (Day 1 morning + Event 1.2 sticky phase) show NO monologue overlay visible, no Z-collision with sticky rack or panel. Visual screenshots `r11-01`, `r11-02` show clean separation. Fix moved `PROTAGONIST_HEAD_ANCHOR` to (320, 26) — top region well above panel y=180-336.
- ✓ **Bug #18-regression (bubble dominance heuristic)** — RESOLVED. Driver picks `[让 Lisa 先]` at Event 1.2 (mounts Lisa "谢谢哈." bubble) → advances through Event 1.3 (David, picks `[还行你呢]`) → 1.4 王总监 → 1.5/1.6/day_1_after_work. At each subsequent paint, `readSpeechBubbleText` returns `[]` — no stale bubbles persist.
- ✓ **Re-verify #6 / #11 / #14**: no regressions.

### Round 11 tooling note

- **N28 — Smoke 295/295** (was 293).
- **N29** — monologue position assertion only verifies "not visible at post-flush" since test paths landed on sticky-rack states. Not adversarial — fix is position-pinned via constant change, code-readable.

### Round 11 outstanding

- Bug #15 (sprite-sheet "Front" label leak) — STILL OPEN since R5.

### Next round target (R12)

Bug #15 fix verification when it lands. Otherwise R12 extends driver to Day 4-7.
