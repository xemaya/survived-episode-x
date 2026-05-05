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

**Status**: ⏳ open — needs designer pass over `episode-1/2/3/4.ink` to add `-> divert` at the end of every choice block flagged by `loose end` warnings. This is **NOT a T10a regression** — the bug is in ink content authored Round 1; speech-bubble work just exposed it because the user was clicking through more choices to verify the bubble.

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

**Status**: ⏳ open — single-line content fix.

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

**Status**: ⏳ open — designer call on (A) vs (B).

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

**Status**: ⏳ open — discussion.

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

**Status**: ⚙️ partial (prop axis only) — `feat(p5-T05-mini+T03-prop)`: `propRegistry` now translates `# prop:` and `# diegetic_prop:` tag values into Pixi sprite swaps via `PropEntity` instances. Workstation registers `fruit_bowl` (apple/strawberry/empty) and `phone` (face_down/face_up/with_badge). Existing P0–P4 binding-driven props (mug/monitor/calendar) keep their direct subscriptions for now; migration to the registry can happen incrementally once ink emits `# prop: mug_*` etc. `# scene:` / `# npc:` interceptors still no-op and need their own batch (T04 scene registry + T05/T06 NPC sprite slots).

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
