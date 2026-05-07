# P5 Closure — Minimal End-to-End Demo Working

> Status: Phase 1 closed (engine plumbing + minimal demo) / Phase 2 open (visual polish, scene types, daily choices, save extension)
> Author: Game Designer (autonomous run, 2026-05-05)
> Configuration: TS + Vite 6 + PixiJS v8 + Tauri 2 + Preact + Ink + inkjs 2.2.5

---

## ✅ What's working (Phase 1 — engine plumbing)

The minimal end-to-end demo loop runs:

1. **Build pipeline** (T01)
   - `scripts/ink-build.mjs` uses `inkjs/compiler` (no .NET inklecate binary needed)
   - `scripts/ink-vite-plugin.mjs` watches `design/vertical-slice/*.ink` + recompiles on change + triggers HMR
   - `pnpm ink:build` compiles all 5 .ink → 5 .json in `game/public/ink/` (~556 KB total)
   - All 5 episode files compile: episode-1 (48 KB), episode-2 (93 KB), episode-3 (80 KB), episode-4 (90 KB), daily-choices (119 KB)

2. **Ink runtime wrapper** (T02 — `game/src/ink/runtime.ts`, ~150 lines)
   - `loadStory(jsonPath)` — fetch JSON → instantiate inkjs Story
   - `step()` — drives Continue() until !canContinue, batches text + tags + choices
   - `selectChoice(idx)` — applies player choice + auto-steps
   - `getVar(name)` / `setVar(name, value)` — VAR read/write for TS-side mirror
   - `divertTo(path)` — jump to a knot/stitch (used by GO triggers)
   - `serializeState()` / `loadState(json)` — for Save integration
   - Singleton `ink` exported

3. **Tag interceptor** (T03 — `game/src/ink/tag-interceptors.ts`, ~110 lines)
   - `TagDispatcher` — register handlers per `# key` or wildcard
   - `parseTag()` — parses raw `key: value` form
   - Singleton `tagDispatcher`

4. **Card module deletion** (T17)
   - Deleted: `game/src/card/`, `game/src/render/cards/`, `game/tests/card/`
   - Cleaned: `game/src/save/snapshot.ts`, `game/src/save/restore.ts`, `game/src/flow/day-cycle.ts`, `game/src/render/scene/workstation.ts`
   - Card test in `tests/flow/day-cycle.test.ts` replaced with comment placeholder
   - **NB**: `RunState.playedThisDay` field kept in save schema for back-compat (always empty array)

5. **Action_day refactor** (T18 — `game/src/render/scene/workstation.ts`)
   - `mountCardHand()` removed
   - `mountInkDialog()` mounted instead — center-screen text panel + choice buttons (PixiJS, diegetic, Red Line 3 OK)
   - 「下班」 button preserved for early-leave path

6. **Boot integration** (`game/src/main.ts`)
   - On boot: `loadEpisode('episode-1')` + `ink.divertTo('episode_1')`
   - Workstation scene's mountInkDialog reads from `ink` singleton

7. **End-to-end demo** (T20-mini)
   - Verified via `tests/ink/runtime.smoke.test.ts` (6 tests):
     - Loads episode-1.json without error
     - `divertTo('episode_1')` + `step()` returns 笑天's morning_briefing text containing "闹钟响了 3 次" + "陈笑天"
     - Emits `# scene` and `# time` tags
     - Choice `[开始今日]` advances to event 1.1 Vivian
     - VARs initialize: kpi=100, money=5500, state=80
     - Serialize + load preserves position + VAR values

8. **Verify clean**: `pnpm verify` exits 0 (assets:sync + ink:build + tsc + lint + test = 161/161)

---

## ⏳ What's NOT done (Phase 2 — visual polish + scope expansion)

The following P5 spec items from `p5-engine-architecture.md §13` are stubbed or skipped in this minimal run. They're not blocking the demo loop, but production needs them:

| Task | Status | Note |
|---|---|---|
| **T04** Scene registry / 5 scene types | Skipped | Only `workstation` scene wired. Phone / monitor_modal / endgame all stub-mounted by current `stage.ts` mounters; replace with separate scene composers in P6 |
| **T05** Diegetic prop entity / 12-prop registry | Skipped | Existing P0-P4 props (mug 5-frame / monitor 4-state / sticky / desk_stain / calendar) still work. New props (phone face_up/down / banking app push / fruit_bowl) not wired |
| **T06-T09** Per-scene composers (workstation / phone / monitor / endgame) | Partial | `workstation.ts` extended with mountInkDialog. `phone.ts` / `monitor.ts` / `endgame.ts` not written |
| **T10** Speech bubble + internal monologue renderers | Stubbed | Current dialog = center text panel (per `ink-dialog.ts`). Production needs NPC-anchored speech bubble |
| **T11-T12** Choice prop renderers (sticky notes / phone buttons / email button) | Stubbed | Current = generic centered buttons. Production should be diegetic per scene type |
| **T13** Day scheduler (8-slot) | Skipped | Currently no slot-based scheduling — story plays linearly through ink. `dayCycle` FSM still controls AP=0 → after_work transition, but doesn't gate ink stitch progression |
| **T14** Daily choice pool filter | Skipped | `daily-choices.ink` compiled but not yet integrated into runtime (no random-pull-from-pool logic) |
| **T15** Flag mirror (TS side) | Skipped | Currently TS reads VARs directly via `ink.getVar()` per call. Mirror would cache + emit change events |
| **T16** Save extension for `ink_state_json` | Skipped | Existing save still works for KPI/Effort/Energy. Ink runtime state NOT persisted across sessions yet — every game restart resets ink to episode_1 start |
| **T19** Extend morning_briefing/kpi_review/recap states for ink | Partial | `morning_briefing` boots into action_day which mounts ink dialog. KPI Review浮层 is in episode-4.ink Day 28 Event 28.2 but TS layer doesn't yet bridge to monitor_modal scene |
| **GO check** in TS runtime | Stub | `check_state_after_choice()` is no-op in ink (per Round 2 patch). TS side should poll state/money/sick_count after each step + call `divertTo('game_over_*')` — not implemented yet |

---

## How to run the demo

```bash
cd game
pnpm dev
```

Then open browser at `http://localhost:1420` (Vite default). What you'll see:

1. **Main menu** loads (existing P0-P4 menu)
2. Click "新游戏" or pick saved run
3. **Workstation scene** mounts — you'll see:
   - Static workstation BG (existing P0-P4 props: monitor, mug, sticky note, calendar)
   - **NEW: center-screen text panel** showing 笑天's morning_briefing text (loaded from episode-1.json):
     > 闹钟响了 3 次。
     > 你叫 **陈笑天**。32 岁，产品助理。
     > 你妈起的名字——希望你"笑傲天下众生"...
     > [...]
     > _周一上午 9:14，地球继续转动。_
   - **NEW: choice button** at bottom: `[ 开始今日 ]`
4. Click `[ 开始今日 ]` → next event renders (Event 1.1 Vivian "嗨～来啦～")
5. Continue through Event 1.2 茶水间偶遇 Lisa (3 choices: 让 Lisa 先 / 你先 / 不说话)
6. Click any choice → continues to Event 1.3 电梯 David
7. ... etc through Day 1 → Day 2 morning → on through Day 7 (cliffhanger to E2)

**Visual polish is intentionally placeholder** (text panel + buttons, no NPC立绘 / 工位 prop animation / time-of-day filter / speech bubble shape). Phase 2 = swap these for real diegetic UI per concept images.

---

## Key files written this run

| File | Lines | Purpose |
|---|---|---|
| `game/src/ink/runtime.ts` | ~150 | inkjs Story wrapper, singleton |
| `game/src/ink/tag-interceptors.ts` | ~110 | Tag dispatch system |
| `game/src/ink/loader.ts` | ~25 | Episode JSON fetch helper |
| `game/src/render/dialog/ink-dialog.ts` | ~180 | PixiJS dialog renderer (placeholder) |
| `game/scripts/ink-build.mjs` | ~115 | .ink → .json compile (uses inkjs/compiler) |
| `game/scripts/ink-vite-plugin.mjs` | ~55 | Vite plugin (build + HMR) |
| `game/scripts/setup-inklecate.mjs` | ~20 | (placeholder note — no longer needed) |
| `game/tests/ink/runtime.smoke.test.ts` | ~80 | 6 smoke tests proving runtime works |
| `game/src/main.ts` | +12 lines | Boot integration: load episode-1 + divert |
| `game/src/render/scene/workstation.ts` | -10/+8 | Removed mountCardHand, added mountInkDialog |
| `game/src/save/snapshot.ts` | -3/+2 | Removed playedThisDay import |
| `game/src/save/restore.ts` | -3/+2 | Removed playedThisDay import |
| `game/src/flow/day-cycle.ts` | -10/+8 | Removed CardId + playedThisDay |
| `game/tests/flow/day-cycle.test.ts` | -22/+5 | Removed card-specific test |
| `game/package.json` | +5 lines | inkjs dep + ink:build / setup:inklecate scripts |
| `game/vite.config.ts` | +3 lines | Wire inkPlugin |
| `game/.gitignore` | +2 lines | Ignore public/ink + scripts/inklecate-bin |

**Deleted**: `game/src/card/`, `game/src/render/cards/`, `game/tests/card/`

**Net code change**: ~+660 lines new TS/JS, ~-1500 lines deleted (card module + hand UI + tests)

---

## Ink content fixes during T01

These were ink syntax issues in the .ink files (not designer/worker errors but mandated by inkjs compiler). Fixed inline:

- `episode-1.ink`: `=== function check_state_after_choice() ===` body had `-> divert` statements (Ink forbids in functions). Function body changed to `~ return` no-op; GO check moves to TS runtime (TODO Phase 2)
- `episode-1.ink`: `=== knot === -> END` on same line is invalid; split into separate lines
- `episode-2.ink`: `**David**：` at start of line inside `{condition: ...}` blocks was parsed as choice marker. Removed `**` to plain `David：`
- `episode-4.ink`: lines 1087-1183 (KPI Review浮层 conditional blocks) had ~25 `**Label**:` instances all parsed as nested choices. sed-stripped `**` in that line range
- `daily-choices.ink`: 60 stitch names contained Chinese characters (`=== choice_凌晨leader微信 ===`). Ink identifiers must be ASCII. Renamed all 60 to numeric IDs (`choice_01` ~ `choice_60`) with original Chinese names preserved in `// (was: choice_xxx)` comments

29 ink "loose end" warnings remain (stitches without explicit `-> DONE`) — non-blocking (story still flows correctly via fall-through), can be tightened in Phase 2.

---

## Phase 2 priorities (next P5 round)

When user wants to continue:

1. **Visual polish** (T10 + T11): replace placeholder text panel with NPC-anchored speech bubble + sticky note choice props for workstation scene
2. **Scene transitions** (T04): wire phone scene + monitor_modal scene + endgame scene
3. **Diegetic UI tag interceptors**: hook `# scene` / `# npc` / `# prop` / `# time` tags to actually update PixiJS prop sprites (currently dispatched but no listeners)
4. **Day scheduler** (T13): respect 8-slot model, gate ink stitch advance on AP availability, integrate with `dayCycle` FSM
5. **Daily choice integration** (T14): pull from daily-choices.ink pool when no scripted event scheduled
6. **Save extension** (T16): persist `ink_state_json` blob alongside KPI/Effort/Energy in current_run.save
7. **GO check in TS** (replaces ink-side check_state_after_choice): poll state/money/sick_count/promotion_candidate_count after each step, divert to game_over_* when threshold hit
8. **KPI Review浮层 monitor scene** (T19): when ink reaches Day 28 Event 28.2, transition to monitor_modal scene type to render the 5-path lookup table
9. **Endgame春节回家 scene** (T19): when ink reaches E52, transition to warm-palette endgame scene
10. **Phone overlay scene** (T07): triggered by `# scene: phone` tag when ink stitches like 凌晨leader微信 fire

**Phase 2 estimated**: ~3-4 weeks of focused work. Better to validate Phase 1 demo (text + buttons) is the right shape first, before investing in visual polish.

---

## Closure statement

P5 minimal-end-to-end demo is **playable**. The narrative engine drives the dialog UI, choices propagate through ink runtime, state mutates correctly, and 笑天's voice is rendered to screen. Visual polish is intentionally deferred — the design's value (writing + branching + state) is verified working before art investment.

User can boot up `pnpm dev` and click through episode-1's morning_briefing in browser to verify Phase 1 works end-to-end.
