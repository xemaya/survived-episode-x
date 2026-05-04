# Slice 1 / Phase 3 — Day Cycle + KPI Review + Game Over (Scope B)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the gameplay loop. After P2 the player can spend cards but the day never ends and the month never rolls over. P3 adds: day counter that auto-advances when AP=0, daily recap screen between days (weekly recap variant on Fridays), automatic month-end at day 7 → KPI Review screen with the real Formula B recalculation → GAME OVER if `monthly_threshold > capacity_now` OR `potential < -0.15`, otherwise continue to next month. Player finally experiences the **核心 fantasy** — reverse-KPI death spiral.

**Architecture:**
- **Calendar module** (`flow/calendar.ts`) owns `currentDay` (1..MONTH_DAYS), `currentWeekday` (1..7), `monthIndex` (1..). Single emitter for date changes. Domain-emitter pattern per spec §6.5.
- **Day-cycle controller** (`flow/day-cycle.ts`) subscribes to AP-depleted, decides next FSM state (recap vs kpi_review based on day count), then on recap-confirm advances day + resets AP/playedThisDay + transitions back to action_day.
- **5 new FSM states** added to `SceneState`: `daily_recap` / `weekly_recap` / `kpi_review` / `gameover` / (AFTER_WORK and MORNING_BRIEFING are conceptual transient sub-modes per GDD; collapsed into the day-cycle controller's transition logic for P3 — visible-state implementation deferred to P4+).
- **Overlay screens** (Preact) for recap / kpi_review / gameover. All added to `OVERLAY_ALLOWED` in `render/stage.ts`. Spec §5.3 explicitly allows overlay for kpi_review/gameover; recap is text-heavy info display so we extend the same pattern (note: GDD treats recap as its own scene, but for P3 implementation cost reasons we use Preact overlay; full diegetic rendering is a P4+ refinement).
- **KPI Review** triggers `kpi.applyMonthlyRecalc()` on entry, then evaluates game-over conditions before rendering.
- **Game Over** is a terminal-ish state — click → `flow.request(main_menu)`. Real GDD has it route to Archive (#12 RunMeta), but Archive is deferred to P4 alongside save persistence. P3 just goes back to main_menu.
- **MONTH_DAYS = 7** for P3 (instead of GDD's 30). 30-day months are too slow to playtest the loop. Re-tune in P4 once core loop is verified.

**Tech Stack:** All existing toolchain. Adds nothing — pure TS + PixiJS + Preact + Vitest.

**Spec reference:** `docs/superpowers/specs/2026-05-03-engine-switch-design.md` §3 (modules), §5.3 (overlay-allowed states), §6 (FSM). GDD ground truth: `design/gdd/scene-day-flow-controller.md`, `design/gdd/kpi-review-game-over-ui.md`, `design/gdd/daily-weekly-recap-ui.md`. Plus the P2 KPI Formula B already implemented.

**Prior tag:** `v0.3.0-p2` — AP/KPI/cards/diegetic working, click-to-refill at AP=0.

---

## Critical design corrections from GDD review

These were wrong in P0/P1-era spec narrative; P3 codebase will match GDD:

- **Day end ≠ player click** — day ends when AP hits 0 (or early-leave; P3 only does AP=0 path). Day-cycle controller subscribes to `ap.onChanged` and detects current=0.
- **Month end is automatic** — when `currentDay >= MONTH_DAYS`, ACTION_DAY → KPI_REVIEW directly (skipping AFTER_WORK + DAILY_RECAP).
- **Game Over has 2 reachable paths in P3**: `KPI_EXCEEDS_CAPACITY` (threshold > capacity_now after monthly recalc) and `DISMISSAL_SEVERE` (raw potential < -0.15 — can fire even before month-end if the player hits this in mid-month, but P3 only checks at month-end for simplicity). VOLUNTARY_QUIT and DEMO_END deferred.
- **"恭喜晋升" is the ironic stamp on every Game Over certificate** — it's a corporate-speak joke for "fired" framed as "promoted". Whitelisted exception to the anti-励志 lint (red line 1).
- **Recap is part of P3 MVP** — not "polish for later". Every non-month-end day gets DAILY_RECAP; Fridays get the WEEKLY_RECAP variant of the same screen.
- **Effort tracking** (overtime/hero/overage counts → effort_norm) deferred to P4+. Formula B in P3 still passes effortNorm=0 (only the potential term contributes meaningfully).

---

## File Structure

After P3:

```
game/
├── src/
│   ├── flow/
│   │   ├── scene-state.ts                       (MODIFY — add 4 new SceneState variants)
│   │   ├── transitions.ts                        (MODIFY — extend matrix for new states)
│   │   ├── dispatcher.ts                         (unchanged)
│   │   ├── calendar.ts                           (CREATE — date module: day/weekday/month)
│   │   └── day-cycle.ts                          (CREATE — controller orchestrating day/month transitions)
│   ├── economy/                                  (unchanged from P2)
│   ├── card/
│   │   └── play.ts                               (unchanged from P2; resetPlayedThisDay called by day-cycle)
│   ├── render/
│   │   ├── stage.ts                              (MODIFY — extend OVERLAY_ALLOWED + register recap/review/gameover mounters as no-ops)
│   │   ├── ui-overlay.tsx                        (MODIFY — route to new screens)
│   │   ├── scene/
│   │   │   └── workstation.ts                    (MODIFY — drop the P2 click-to-advance hack; calendar prop now reflects real date)
│   │   └── menu/
│   │       ├── daily-recap.tsx                   (CREATE — Preact: AP used + event count + skip + 90s timer)
│   │       ├── weekly-recap.tsx                  (CREATE — Preact: 7-day summary)
│   │       ├── kpi-review.tsx                    (CREATE — Preact: 3-row breakdown + capacity comparison + confirm)
│   │       └── gameover.tsx                      (CREATE — Preact: certificate + irony stamp + reason text + click → main_menu)
│   └── input/
│       └── keyboard.ts                           (unchanged)
└── tests/
    ├── flow/
    │   ├── calendar.test.ts                      (CREATE — advance day, weekday, month rollover, MONTH_DAYS edge)
    │   ├── day-cycle.test.ts                     (CREATE — ap=0→recap, week-end→weekly-recap variant, month-end→kpi-review, game-over detection)
    │   └── transitions.test.ts                   (MODIFY — +12 cases for new states' legal/illegal transitions)
    └── (other tests unchanged)
```

---

## Task 1: Extend FSM — 4 new SceneState variants + transitions matrix (TDD)

**Why first:** every other module reads from the FSM. Lock the new states + their legal transitions before any consumer is built.

**Files:**
- Modify: `game/src/flow/scene-state.ts`
- Modify: `game/src/flow/transitions.ts`
- Modify: `game/tests/flow/transitions.test.ts`

- [ ] **Step 1.1: Update `game/src/flow/scene-state.ts`** — add 4 new variants to the union and update `describe()`. Full file:

```ts
export type DayPhase = 'morning' | 'midday' | 'afternoon' | 'evening';

export type GameOverReason =
  | 'kpi_exceeds_capacity'  // threshold > capacity_now after month-end recalc
  | 'dismissal_severe';     // raw potential < -0.15

export type RecapKind = 'daily' | 'weekly';

export type SceneState =
  | { kind: 'main_menu' }
  | { kind: 'action_day'; day: number; phase: DayPhase }
  | { kind: 'recap'; recapKind: RecapKind; day: number }
  | { kind: 'kpi_review'; monthIndex: number }
  | { kind: 'gameover'; reason: GameOverReason; monthIndex: number }
  | { kind: 'pause'; resumeTo: SceneState };

export function describe(s: SceneState): string {
  switch (s.kind) {
    case 'main_menu':
      return 'main_menu';
    case 'action_day':
      return `action_day(day=${s.day}, phase=${s.phase})`;
    case 'recap':
      return `recap(${s.recapKind}, day=${s.day})`;
    case 'kpi_review':
      return `kpi_review(month=${s.monthIndex})`;
    case 'gameover':
      return `gameover(reason=${s.reason}, month=${s.monthIndex})`;
    case 'pause':
      return `pause(resumeTo=${describe(s.resumeTo)})`;
  }
}
```

- [ ] **Step 1.2: Update `game/src/flow/transitions.ts`** — extend matrix. Full file:

```ts
import type { SceneState } from './scene-state';

// Hard-coded transition matrix. Readability beats DRY here — anyone
// debugging an "illegal transition" error should be able to grep this
// file and see the full universe of allowed moves.
//
// P3 adds: recap (daily/weekly), kpi_review (month-end), gameover (terminal).
// AFTER_WORK and MORNING_BRIEFING from the GDD are collapsed into transient
// transitions handled by day-cycle.ts (no visible state in P3).

export function isLegalTransition(from: SceneState, to: SceneState): boolean {
  // pause: enterable only from action_day (P1 invariant);
  // resumeTo must deep-equal the current state.
  if (to.kind === 'pause') {
    return from.kind === 'action_day' && JSON.stringify(to.resumeTo) === JSON.stringify(from);
  }

  // main_menu: enterable from action_day (quit), pause (quit-from-pause),
  // or gameover (player click after death).
  if (to.kind === 'main_menu') {
    return from.kind === 'action_day' || from.kind === 'pause' || from.kind === 'gameover';
  }

  // action_day: enterable from main_menu (game start), pause (resume),
  // recap (next day after recap dismissed), kpi_review (next month after
  // confirm), or another action_day (rare day-skip; allowed for tests).
  if (to.kind === 'action_day') {
    return (
      from.kind === 'main_menu' ||
      from.kind === 'pause' ||
      from.kind === 'recap' ||
      from.kind === 'kpi_review' ||
      from.kind === 'action_day'
    );
  }

  // recap: enterable only from action_day (AP=0 day-end on a non-month-end day).
  if (to.kind === 'recap') {
    return from.kind === 'action_day';
  }

  // kpi_review: enterable only from action_day (AP=0 day-end on a month-end day).
  if (to.kind === 'kpi_review') {
    return from.kind === 'action_day';
  }

  // gameover: enterable only from kpi_review (after Formula B recalc + game-over
  // condition triggered). DISMISSAL_SEVERE could theoretically fire from action_day
  // mid-month, but P3 only checks at month-end via kpi_review, so action_day →
  // gameover is NOT in the legal set yet (deferred to P4+ when mid-month dismissal
  // path lands).
  if (to.kind === 'gameover') {
    return from.kind === 'kpi_review';
  }

  // exhaustive — TS will warn here if a new variant is added without handling
  const _exhaustive: never = to;
  return _exhaustive;
}
```

- [ ] **Step 1.3: Extend `game/tests/flow/transitions.test.ts`** — add new cases. Append the new `describe` block at the end (before the final `});`):

```ts
import { describe, expect, it } from 'vitest';
import type { SceneState } from '../../src/flow/scene-state';
import { isLegalTransition } from '../../src/flow/transitions';

const mainMenu: SceneState = { kind: 'main_menu' };
const day1: SceneState = { kind: 'action_day', day: 1, phase: 'morning' };
const day7: SceneState = { kind: 'action_day', day: 7, phase: 'morning' };
const day1Pause: SceneState = { kind: 'pause', resumeTo: day1 };
const mainMenuPause: SceneState = { kind: 'pause', resumeTo: mainMenu };
const dailyRecap: SceneState = { kind: 'recap', recapKind: 'daily', day: 1 };
const weeklyRecap: SceneState = { kind: 'recap', recapKind: 'weekly', day: 5 };
const kpiReview: SceneState = { kind: 'kpi_review', monthIndex: 1 };
const gameOverCap: SceneState = { kind: 'gameover', reason: 'kpi_exceeds_capacity', monthIndex: 1 };
const gameOverDis: SceneState = { kind: 'gameover', reason: 'dismissal_severe', monthIndex: 1 };

describe('isLegalTransition (P1 subset)', () => {
  // ... existing 8 tests unchanged ...
});

describe('isLegalTransition (P3: day-cycle, kpi_review, gameover)', () => {
  it('action_day → recap (daily) is legal (day-end on non-month-end day)', () => {
    expect(isLegalTransition(day1, dailyRecap)).toBe(true);
  });

  it('action_day → recap (weekly) is legal (Friday day-end)', () => {
    expect(isLegalTransition({ kind: 'action_day', day: 5, phase: 'morning' }, weeklyRecap)).toBe(
      true,
    );
  });

  it('recap → action_day is legal (next day after recap dismissed)', () => {
    expect(isLegalTransition(dailyRecap, day1)).toBe(true);
  });

  it('recap → recap is illegal (no nested recap)', () => {
    expect(isLegalTransition(dailyRecap, dailyRecap)).toBe(false);
  });

  it('action_day → kpi_review is legal (month-end day)', () => {
    expect(isLegalTransition(day7, kpiReview)).toBe(true);
  });

  it('kpi_review → action_day is legal (next month after confirm)', () => {
    expect(isLegalTransition(kpiReview, day1)).toBe(true);
  });

  it('kpi_review → gameover (capacity) is legal', () => {
    expect(isLegalTransition(kpiReview, gameOverCap)).toBe(true);
  });

  it('kpi_review → gameover (dismissal) is legal', () => {
    expect(isLegalTransition(kpiReview, gameOverDis)).toBe(true);
  });

  it('gameover → main_menu is legal (player click after death)', () => {
    expect(isLegalTransition(gameOverCap, mainMenu)).toBe(true);
    expect(isLegalTransition(gameOverDis, mainMenu)).toBe(true);
  });

  it('gameover → action_day is illegal (no resume from death)', () => {
    expect(isLegalTransition(gameOverCap, day1)).toBe(false);
  });

  it('gameover → kpi_review is illegal (no resurrect)', () => {
    expect(isLegalTransition(gameOverCap, kpiReview)).toBe(false);
  });

  it('action_day → gameover is illegal in P3 (mid-month dismissal deferred)', () => {
    expect(isLegalTransition(day1, gameOverDis)).toBe(false);
  });

  it('main_menu → recap is illegal (no recap without a day)', () => {
    expect(isLegalTransition(mainMenu, dailyRecap)).toBe(false);
  });

  it('main_menu → kpi_review is illegal (no review without a month)', () => {
    expect(isLegalTransition(mainMenu, kpiReview)).toBe(false);
  });

  it('main_menu → gameover is illegal (no death without a game)', () => {
    expect(isLegalTransition(mainMenu, gameOverCap)).toBe(false);
  });

  it('pause is unchanged: P1 invariant still holds (pause only from action_day with matching resumeTo)', () => {
    expect(isLegalTransition(day1, day1Pause)).toBe(true);
    expect(isLegalTransition(mainMenu, mainMenuPause)).toBe(false);
  });
});
```

- [ ] **Step 1.4: Run the test suite — expect ~24 transitions cases pass** (8 existing + 16 new):

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x/game
pnpm vitest run tests/flow/transitions.test.ts
```

If any fail, the matrix in transitions.ts needs adjustment until green.

- [ ] **Step 1.5: Verify whole suite + typecheck**:

```bash
pnpm tsc
pnpm test
```

Expected: tsc exit 0; vitest reports 50 (P2) + 16 new = 66 passed total. Note: this might show as `58` if other test files run differently — count only matters relative to "everything still passes".

- [ ] **Step 1.6: Commit**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/flow/scene-state.ts game/src/flow/transitions.ts game/tests/flow/transitions.test.ts
git commit -m "feat(game): extend FSM — recap/kpi_review/gameover states + transitions

P3 introduces 4 new SceneState variants:
- recap(recapKind: daily|weekly, day): between non-month-end days
- kpi_review(monthIndex): month-end Formula B recalc + breakdown screen
- gameover(reason, monthIndex): terminal state; click → main_menu

Transition matrix updated:
- action_day → recap (day-end non-month-end)
- action_day → kpi_review (day-end month-end)
- recap → action_day (next day after dismiss)
- kpi_review → action_day (next month after pass) | gameover (failed)
- gameover → main_menu (only exit)

GameOver has 2 reasons in P3:
- kpi_exceeds_capacity: threshold > capacity_now after monthly recalc
- dismissal_severe: raw potential < -0.15 (only checked at month-end in
  P3; mid-month action_day → gameover deferred to P4+)

GDD also defines AFTER_WORK and MORNING_BRIEFING sub-modes; for P3
implementation cost they're collapsed into transient transitions
handled by day-cycle.ts (no visible state). P4+ may break them out.

Vitest: +16 cases covering legal/illegal transitions for all new states.

Per design/gdd/scene-day-flow-controller.md + plan Task 1.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 2: Calendar module + day-cycle controller (TDD)

**Why now:** all the new states need a date source (calendar) and an orchestrator (day-cycle) to drive them. Build standalone with tests before any UI consumes them.

**Files:**
- Create: `game/src/flow/calendar.ts`
- Create: `game/src/flow/day-cycle.ts`
- Create: `game/tests/flow/calendar.test.ts`
- Create: `game/tests/flow/day-cycle.test.ts`
- Modify: `game/src/economy/constants.ts` (add MONTH_DAYS)

- [ ] **Step 2.1: Add `MONTH_DAYS` to `game/src/economy/constants.ts`** — append to the file:

```ts
// ─── Day cycle ────────────────────────────────────────────────────────────
// design/gdd/scene-day-flow-controller.md uses 30 days/month. For P3 we
// shorten to 7 to make the loop playtestable in a single sitting; P4+
// re-tunes to the design value once core loop is verified.
export const MONTH_DAYS = 7;
```

- [ ] **Step 2.2: Write the failing test** at `game/tests/flow/calendar.test.ts`:

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { CalendarSystem } from '../../src/flow/calendar';
import { MONTH_DAYS } from '../../src/economy/constants';

describe('CalendarSystem', () => {
  let calendar: CalendarSystem;

  beforeEach(() => {
    calendar = new CalendarSystem();
  });

  it('starts at day 1, weekday 1 (Monday), month 1', () => {
    expect(calendar.currentDay).toBe(1);
    expect(calendar.currentWeekday).toBe(1);
    expect(calendar.monthIndex).toBe(1);
  });

  it('advanceDay() increments day and weekday, emits dateChanged', () => {
    const listener = vi.fn();
    calendar.onDateChanged(listener);
    calendar.advanceDay();
    expect(calendar.currentDay).toBe(2);
    expect(calendar.currentWeekday).toBe(2);
    expect(listener).toHaveBeenCalledTimes(1);
  });

  it('weekday wraps 1..7 and continues with day', () => {
    for (let i = 0; i < 7; i++) calendar.advanceDay();
    expect(calendar.currentDay).toBe(8); // overshoots MONTH_DAYS=7; advanceMonth must be called separately
    expect(calendar.currentWeekday).toBe(1); // wrapped back to Monday after 7 advances
  });

  it('isMonthEndAfter(currentDay) reports when current day equals MONTH_DAYS', () => {
    expect(calendar.isMonthEnd()).toBe(false); // day 1
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    expect(calendar.currentDay).toBe(MONTH_DAYS);
    expect(calendar.isMonthEnd()).toBe(true); // last day of month
  });

  it('isWeeklyRecapDay() returns true on Friday (weekday=5)', () => {
    // Mon=1, Tue=2, Wed=3, Thu=4, Fri=5
    for (let i = 0; i < 4; i++) calendar.advanceDay();
    expect(calendar.currentWeekday).toBe(5);
    expect(calendar.isWeeklyRecapDay()).toBe(true);
  });

  it('advanceMonth() resets day to 1, increments monthIndex, weekday continues', () => {
    for (let i = 0; i < 3; i++) calendar.advanceDay(); // day=4, weekday=4
    calendar.advanceMonth();
    expect(calendar.currentDay).toBe(1);
    expect(calendar.monthIndex).toBe(2);
    expect(calendar.currentWeekday).toBe(4); // weekday continuous across months
  });

  it('unsubscribe stops emissions', () => {
    const listener = vi.fn();
    const unsub = calendar.onDateChanged(listener);
    calendar.advanceDay();
    unsub();
    calendar.advanceDay();
    expect(listener).toHaveBeenCalledTimes(1);
  });
});
```

- [ ] **Step 2.3: Run — expect FAIL** (module not found).

- [ ] **Step 2.4: Implement `game/src/flow/calendar.ts`**:

```ts
// Calendar / date module. Tracks current_day (1..MONTH_DAYS),
// current_weekday (1..7, Mon..Sun), month_index (1..). Emits dateChanged
// after every advance. Per spec §6.5 domain-emitter pattern.
//
// design/gdd/scene-day-flow-controller.md drives this: ctx payload of
// scene_state_changed includes current_day + current_weekday. P3 derives
// month_index implicitly when calendar.advanceMonth() is called (after
// kpi_review confirm).

export type CalendarListener = () => void;

export class CalendarSystem {
  private _day = 1;
  private _weekday = 1; // Monday
  private _month = 1;
  private listeners = new Set<CalendarListener>();

  get currentDay(): number {
    return this._day;
  }
  get currentWeekday(): number {
    return this._weekday;
  }
  get monthIndex(): number {
    return this._month;
  }

  isMonthEnd(): boolean {
    // True when the CURRENT day is the last day of the month.
    // (Day-cycle controller checks this AFTER ap=0 to decide recap vs review.)
    // MONTH_DAYS imported lazily to avoid cycling with constants; check by literal here.
    return this._day >= MONTH_DAYS;
  }

  isWeeklyRecapDay(): boolean {
    // GDD: Friday (weekday=5) gets WEEKLY_RECAP variant of DAILY_RECAP.
    return this._weekday === 5;
  }

  advanceDay(): void {
    this._day += 1;
    this._weekday = (this._weekday % 7) + 1;
    for (const l of this.listeners) l();
  }

  advanceMonth(): void {
    this._day = 1;
    this._month += 1;
    // Weekday continues from where it was (real-world calendar behavior).
    for (const l of this.listeners) l();
  }

  onDateChanged(fn: CalendarListener): () => void {
    this.listeners.add(fn);
    let unsubscribed = false;
    return () => {
      if (unsubscribed) return;
      unsubscribed = true;
      this.listeners.delete(fn);
    };
  }
}

import { MONTH_DAYS } from '@/economy/constants';

export const calendar = new CalendarSystem();
```

(Note: the `import { MONTH_DAYS }` is at the bottom of the file because the class body references it. Ideally it would be at the top, but biome will reorder during pre-commit. If you want to put it at the top, do so — both are valid.)

- [ ] **Step 2.5: Run calendar test — expect 7 PASS**.

- [ ] **Step 2.6: Write the failing test** at `game/tests/flow/day-cycle.test.ts`:

```ts
import { beforeEach, describe, expect, it } from 'vitest';
import { ApSystem } from '../../src/economy/ap';
import { KpiSystem } from '../../src/economy/kpi';
import { MONTH_DAYS } from '../../src/economy/constants';
import { CalendarSystem } from '../../src/flow/calendar';
import { FlowDispatcher } from '../../src/flow/dispatcher';
import type { SceneState } from '../../src/flow/scene-state';
import { DayCycleController } from '../../src/flow/day-cycle';

const day1: SceneState = { kind: 'action_day', day: 1, phase: 'morning' };

describe('DayCycleController', () => {
  let ap: ApSystem;
  let kpi: KpiSystem;
  let calendar: CalendarSystem;
  let flow: FlowDispatcher;
  let controller: DayCycleController;
  let playedThisDay: Set<string>;

  beforeEach(() => {
    ap = new ApSystem();
    kpi = new KpiSystem();
    calendar = new CalendarSystem();
    flow = new FlowDispatcher();
    playedThisDay = new Set(['placeholder_card']);
    controller = new DayCycleController({ ap, kpi, calendar, flow, playedThisDay });
    controller.attach();
    // Boot into action_day for these tests
    flow.request(day1);
  });

  it('AP=0 on non-month-end day → flow.request(daily recap)', () => {
    expect(calendar.isMonthEnd()).toBe(false);
    ap.spend(8);
    expect(flow.state.kind).toBe('recap');
    expect((flow.state as { recapKind: 'daily' | 'weekly' }).recapKind).toBe('daily');
  });

  it('AP=0 on Friday → flow.request(weekly recap)', () => {
    for (let i = 0; i < 4; i++) calendar.advanceDay(); // Fri
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    ap.spend(8);
    expect(flow.state.kind).toBe('recap');
    expect((flow.state as { recapKind: 'daily' | 'weekly' }).recapKind).toBe('weekly');
  });

  it('AP=0 on month-end day → flow.request(kpi_review), skipping recap', () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    expect(calendar.isMonthEnd()).toBe(true);
    ap.spend(8);
    expect(flow.state.kind).toBe('kpi_review');
  });

  it('confirmRecap() advances day, refills AP, clears playedThisDay, returns to action_day', () => {
    ap.spend(8); // → recap
    expect(flow.state.kind).toBe('recap');
    controller.confirmRecap();
    expect(calendar.currentDay).toBe(2);
    expect(ap.current).toBe(8);
    expect(playedThisDay.size).toBe(0);
    expect(flow.state.kind).toBe('action_day');
  });

  it('confirmKpiReview() with KPI well below threshold → advance month + return to action_day', () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(50); // raw potential = (50-100)/100 = -0.5, clamped to -0.15
    ap.spend(8); // → kpi_review
    controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');
    expect(calendar.currentDay).toBe(1);
    expect(calendar.monthIndex).toBe(2);
  });

  it('confirmKpiReview() with KPI exactly at -0.15 boundary → still passes (not severe dismissal)', () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(85); // potential = -0.15 (boundary)
    ap.spend(8);
    controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');
  });

  it('confirmKpiReview() with KPI > capacity (after recalc) → flow.request(gameover, kpi_exceeds_capacity)', () => {
    // monthlyThreshold starts 100, capacity month 1 = 300. To trigger
    // capacity-exceeded we'd need threshold > 300. Formula B max is
    // ×1.18/month. 100 → 118 → 139 → ... → 300 takes ~6 months. That's
    // too long for a single test. We force the scenario by advancing
    // calendar to a month with low capacity AND priming a high threshold.
    for (let i = 0; i < 50; i++) calendar.advanceMonth();
    // Now monthIndex=51; capacity_now floors at 40. Any threshold > 40
    // triggers the game over.
    // monthlyThreshold is still 100 (initial); 100 > 40 → game over.
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    ap.spend(8);
    controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');
    expect((flow.state as { reason: string }).reason).toBe('kpi_exceeds_capacity');
  });

  it('detach() unsubscribes from ap and stops driving the FSM', () => {
    controller.detach();
    ap.spend(8);
    expect(flow.state.kind).toBe('action_day'); // unchanged
  });
});
```

- [ ] **Step 2.7: Run — expect FAIL** (module not found).

- [ ] **Step 2.8: Implement `game/src/flow/day-cycle.ts`**:

```ts
import type { ApSystem } from '@/economy/ap';
import type { KpiSystem } from '@/economy/kpi';
import { POTENTIAL_DISMISSAL } from '@/economy/constants';
import type { CalendarSystem } from './calendar';
import type { FlowDispatcher } from './dispatcher';
import type { CardId } from '@/card/card';

export interface DayCycleDeps {
  ap: ApSystem;
  kpi: KpiSystem;
  calendar: CalendarSystem;
  flow: FlowDispatcher;
  playedThisDay: Set<CardId>;
}

// Orchestrates day/month transitions. Subscribes to ap (depletion = day end)
// and exposes confirmRecap()/confirmKpiReview() for UI to call when player
// dismisses those screens.
//
// Per spec §6.5 (domain emitters): this controller is the single owner of
// the "day ends now" decision. The workstation scene used to do this in
// P2 (click-to-advance hack); P3 moves the logic here so the FSM is in
// charge, not the renderer.
export class DayCycleController {
  private deps: DayCycleDeps;
  private unsubscribers: Array<() => void> = [];
  private attached = false;

  constructor(deps: DayCycleDeps) {
    this.deps = deps;
  }

  attach(): void {
    if (this.attached) return;
    this.attached = true;
    this.unsubscribers.push(
      this.deps.ap.onChanged((current) => {
        if (current === 0 && this.deps.flow.state.kind === 'action_day') {
          this.handleDayEnd();
        }
      }),
    );
  }

  detach(): void {
    for (const u of this.unsubscribers) u();
    this.unsubscribers = [];
    this.attached = false;
  }

  private handleDayEnd(): void {
    const { calendar, flow } = this.deps;
    if (calendar.isMonthEnd()) {
      flow.request({ kind: 'kpi_review', monthIndex: calendar.monthIndex });
    } else {
      flow.request({
        kind: 'recap',
        recapKind: calendar.isWeeklyRecapDay() ? 'weekly' : 'daily',
        day: calendar.currentDay,
      });
    }
  }

  // Called by the recap UI when the player dismisses the recap screen.
  confirmRecap(): void {
    const { ap, calendar, flow, playedThisDay } = this.deps;
    if (flow.state.kind !== 'recap') {
      throw new Error(`confirmRecap called from non-recap state: ${flow.state.kind}`);
    }
    calendar.advanceDay();
    ap.resetForNewDay();
    playedThisDay.clear();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
  }

  // Called by the kpi_review UI when the player confirms. Runs the monthly
  // recalc, evaluates game-over conditions, then either advances to the
  // next month or transitions to gameover.
  confirmKpiReview(): void {
    const { ap, kpi, calendar, flow, playedThisDay } = this.deps;
    if (flow.state.kind !== 'kpi_review') {
      throw new Error(`confirmKpiReview called from non-kpi_review state: ${flow.state.kind}`);
    }

    // Compute raw potential BEFORE recalc (recalc clamps + applies).
    const rawPotential = (kpi.actualKpi - kpi.monthlyThreshold) / kpi.monthlyThreshold;

    // Step 1: severe dismissal check (raw potential, not clamped).
    if (rawPotential < POTENTIAL_DISMISSAL) {
      flow.request({
        kind: 'gameover',
        reason: 'dismissal_severe',
        monthIndex: calendar.monthIndex,
      });
      return;
    }

    // Step 2: apply Formula B recalc (effort_norm = 0 in P3).
    kpi.applyMonthlyRecalc(0);

    // Step 3: capacity-exceeded check (post-recalc).
    if (kpi.monthlyThreshold > kpi.capacityNow) {
      flow.request({
        kind: 'gameover',
        reason: 'kpi_exceeds_capacity',
        monthIndex: calendar.monthIndex,
      });
      return;
    }

    // Step 4: pass — advance month, reset day-state, return to action_day.
    calendar.advanceMonth();
    kpi.advanceMonth();
    ap.resetForNewDay();
    playedThisDay.clear();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
  }
}
```

- [ ] **Step 2.9: Run day-cycle test — expect 8 PASS**.

- [ ] **Step 2.10: Verify whole suite + typecheck**:

```bash
pnpm tsc
pnpm test
```

Expected: tsc exit 0, vitest 50 + 16 + 7 + 8 = 81 passed total.

- [ ] **Step 2.11: Commit**:

```bash
git add game/src/flow/calendar.ts game/src/flow/day-cycle.ts \
        game/tests/flow/calendar.test.ts game/tests/flow/day-cycle.test.ts \
        game/src/economy/constants.ts
git commit -m "feat(game): calendar module + day-cycle controller (TDD 15 cases)

Two new modules wire the date counter and the day/month FSM transitions:
- calendar.ts: CalendarSystem singleton tracking currentDay (1..MONTH_DAYS),
  currentWeekday (1..7, Mon..Sun), monthIndex (1..). advanceDay/advanceMonth
  with onDateChanged emitter. isMonthEnd() and isWeeklyRecapDay() helpers.
- day-cycle.ts: DayCycleController orchestrates all day/month transitions.
  Subscribes to ap.onChanged; on AP=0 in action_day, decides between
  recap (daily/weekly) or kpi_review (month-end). Exposes confirmRecap()
  and confirmKpiReview() for UI to call. confirmKpiReview() runs Formula B,
  evaluates game-over (severe dismissal raw potential < -0.15, then
  capacity-exceeded after recalc), routes to gameover or next month.

MONTH_DAYS = 7 (P3 abbreviated; design value 30 will be re-tuned in P4).

Vitest: +15 cases (7 calendar + 8 day-cycle) covering month rollover,
weekday wraparound, weekly-recap-day detection, recap/review routing,
both gameover paths, and detach lifecycle.

Per spec §6.5 + design/gdd/scene-day-flow-controller.md + plan Task 2.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 3: Daily / Weekly Recap overlay screens (Preact)

**Why now:** day-cycle controller transitions to `recap` state but no UI renders it yet. Add the Preact overlay.

**Files:**
- Create: `game/src/render/menu/daily-recap.tsx`
- Create: `game/src/render/menu/weekly-recap.tsx`
- Modify: `game/src/render/ui-overlay.tsx` (route recap state to the right component)
- Modify: `game/src/render/stage.ts` (add `recap`, `kpi_review`, `gameover` to `OVERLAY_ALLOWED`)

- [ ] **Step 3.1: Update `game/src/render/stage.ts`** — extend the OVERLAY_ALLOWED set:

```ts
const OVERLAY_ALLOWED: ReadonlySet<SceneState['kind']> = new Set([
  'main_menu',
  'pause',
  'recap',
  'kpi_review',
  'gameover',
  // future: 'settings'
]);
```

(Replace the existing OVERLAY_ALLOWED constant; the rest of stage.ts is unchanged.)

- [ ] **Step 3.2: Create `game/src/render/menu/daily-recap.tsx`**:

```tsx
import { ap } from '@/economy/ap';
import { dayCycle } from '@/flow/day-cycle';
import { useEffect, useState } from 'preact/hooks';

interface Props {
  day: number;
}

// design/gdd/daily-weekly-recap-ui.md: skippable, auto-progress at 90s.
// Content: today's AP used + event count (P3: events not implemented,
// shown as 0) + skip hint. HR-tone copy throughout.

const AUTO_PROGRESS_MS = 90_000;

export function DailyRecap({ day }: Props): preact.JSX.Element {
  const [secondsLeft, setSecondsLeft] = useState(Math.floor(AUTO_PROGRESS_MS / 1000));

  useEffect(() => {
    // Tick every second for the visible countdown
    const tickId = window.setInterval(() => {
      setSecondsLeft((s) => Math.max(0, s - 1));
    }, 1000);
    // Auto-progress at 90s
    const progressId = window.setTimeout(() => dayCycle.confirmRecap(), AUTO_PROGRESS_MS);
    return () => {
      window.clearInterval(tickId);
      window.clearTimeout(progressId);
    };
  }, []);

  // P3: AP used = max - current. Events = 0 placeholder until event engine lands.
  const apUsed = ap.max - ap.current;

  return (
    <div class="menu-root menu-root--recap">
      <h2 class="menu-title menu-title--small">Day {day} — 日报</h2>
      <p class="menu-subtitle">已登记今日工作量</p>
      <div class="recap-rows">
        <div class="recap-row">
          <span class="recap-label">AP 消耗</span>
          <span class="recap-value">{apUsed} / {ap.max}</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">事件登记</span>
          <span class="recap-value">0 项</span>
        </div>
      </div>
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={() => dayCycle.confirmRecap()}>
          下一天
        </button>
      </div>
      <p class="recap-hint">{secondsLeft} 秒后自动进入下一天</p>
    </div>
  );
}
```

- [ ] **Step 3.3: Create `game/src/render/menu/weekly-recap.tsx`** — variant of DailyRecap:

```tsx
import { ap } from '@/economy/ap';
import { kpi } from '@/economy/kpi';
import { dayCycle } from '@/flow/day-cycle';
import { useEffect, useState } from 'preact/hooks';

interface Props {
  day: number;
}

// design/gdd/daily-weekly-recap-ui.md: Friday upgrade. Shows 7-day summary
// + effort 3-dimension stub + KPI hint (待月末结算). Same skip/timer
// mechanics as daily.

const AUTO_PROGRESS_MS = 90_000;

export function WeeklyRecap({ day }: Props): preact.JSX.Element {
  const [secondsLeft, setSecondsLeft] = useState(Math.floor(AUTO_PROGRESS_MS / 1000));

  useEffect(() => {
    const tickId = window.setInterval(() => setSecondsLeft((s) => Math.max(0, s - 1)), 1000);
    const progressId = window.setTimeout(() => dayCycle.confirmRecap(), AUTO_PROGRESS_MS);
    return () => {
      window.clearInterval(tickId);
      window.clearTimeout(progressId);
    };
  }, []);

  return (
    <div class="menu-root menu-root--recap">
      <h2 class="menu-title menu-title--small">Day {day} · Friday — 周报</h2>
      <p class="menu-subtitle">本周三维考核登记</p>
      <div class="recap-rows">
        <div class="recap-row">
          <span class="recap-label">积极性</span>
          <span class="recap-value">已登记</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">超额贡献</span>
          <span class="recap-value">已归档</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">产出记录</span>
          <span class="recap-value">存档</span>
        </div>
        <div class="recap-row recap-row--separator">
          <span class="recap-label">本月 KPI 进度</span>
          <span class="recap-value">{kpi.actualKpi} / {kpi.monthlyThreshold} <em>(待月末结算)</em></span>
        </div>
      </div>
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={() => dayCycle.confirmRecap()}>
          进入周末
        </button>
      </div>
      <p class="recap-hint">{secondsLeft} 秒后自动进入下一天</p>
    </div>
  );
}
```

- [ ] **Step 3.4: Update `game/src/render/ui-overlay.tsx`** — add recap routing:

```tsx
import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import { render } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import { DailyRecap } from './menu/daily-recap';
import { MainMenu } from './menu/main-menu';
import { PauseMenu } from './menu/pause-menu';
import { WeeklyRecap } from './menu/weekly-recap';
import { assertOverlayAllowed } from './stage';

interface RouterProps {
  host: HTMLElement;
}

function OverlayRouter({ host }: RouterProps): preact.JSX.Element | null {
  const [state, setState] = useState<SceneState>(flow.state);
  useEffect(() => {
    const unsub = flow.subscribe((next) => setState(next));
    return unsub;
  }, []);

  useEffect(() => {
    const hasOverlay =
      state.kind === 'main_menu' ||
      state.kind === 'pause' ||
      state.kind === 'recap' ||
      state.kind === 'kpi_review' ||
      state.kind === 'gameover';
    host.style.display = hasOverlay ? 'flex' : 'none';
    host.style.pointerEvents = hasOverlay ? 'auto' : 'none';
  }, [state.kind, host]);

  switch (state.kind) {
    case 'main_menu':
      assertOverlayAllowed(state);
      return <MainMenu />;
    case 'pause':
      assertOverlayAllowed(state);
      return <PauseMenu state={state} />;
    case 'recap':
      assertOverlayAllowed(state);
      return state.recapKind === 'weekly' ? <WeeklyRecap day={state.day} /> : <DailyRecap day={state.day} />;
    case 'action_day':
      return null;
    case 'kpi_review':
      assertOverlayAllowed(state);
      return <div class="menu-root">KPI Review (Task 4 wires this)</div>;
    case 'gameover':
      assertOverlayAllowed(state);
      return <div class="menu-root">Game Over (Task 5 wires this)</div>;
  }
}

export function mountOverlay(host: HTMLElement): void {
  render(<OverlayRouter host={host} />, host);
}
```

- [ ] **Step 3.5: Add CSS for recap rows** — append to `game/index.html` `<style>` block before `</style>`:

```css
.menu-root--recap {
  min-width: 360px;
}
.recap-rows {
  display: flex;
  flex-direction: column;
  gap: 8px;
  width: 100%;
  border-top: 1px solid #3a3d42;
  border-bottom: 1px solid #3a3d42;
  padding: 12px 0;
}
.recap-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  font-size: 14px;
  color: #e8e0cc;
}
.recap-row--separator {
  border-top: 1px dashed #5a7080;
  padding-top: 8px;
  margin-top: 4px;
}
.recap-label {
  color: #7a8088;
  letter-spacing: 1px;
}
.recap-value {
  color: #c8a85a;
  font-weight: 600;
}
.recap-value em {
  color: #7a8088;
  font-weight: 400;
  font-style: normal;
  font-size: 11px;
}
.recap-hint {
  font-size: 11px;
  color: #5a6068;
  margin: 0;
}
```

- [ ] **Step 3.6: Add singleton `dayCycle` export to `flow/day-cycle.ts`** so UI components and main.ts can import it. Append to the bottom of `game/src/flow/day-cycle.ts`:

```ts
import { ap as defaultAp } from '@/economy/ap';
import { kpi as defaultKpi } from '@/economy/kpi';
import { playedThisDay as defaultPlayedThisDay } from '@/card/play';
import { calendar as defaultCalendar } from './calendar';
import { flow as defaultFlow } from './dispatcher';

// Singleton — production import goes through this.
// Tests construct their own DayCycleController with custom deps.
export const dayCycle = new DayCycleController({
  ap: defaultAp,
  kpi: defaultKpi,
  calendar: defaultCalendar,
  flow: defaultFlow,
  playedThisDay: defaultPlayedThisDay,
});
```

- [ ] **Step 3.7: Wire `dayCycle.attach()` in `main.ts`** — Modify `game/src/main.ts`:

```ts
import { dayCycle } from '@/flow/day-cycle';
import { installKeyboardHandler } from '@/input/keyboard';
import { Container } from 'pixi.js';
import { createPixiApp } from '@/render/pixi-app';
import { bindStageToFlow } from '@/render/stage';
import { mountOverlay } from '@/render/ui-overlay';

async function main(): Promise<void> {
  const pixiRoot = document.getElementById('pixi-root');
  const overlayRoot = document.getElementById('ui-overlay');
  if (!pixiRoot || !overlayRoot) {
    throw new Error('Required DOM nodes (#pixi-root, #ui-overlay) not found in index.html');
  }
  const { app } = await createPixiApp(pixiRoot);

  const worldLayer = new Container();
  worldLayer.label = 'world';
  app.stage.addChild(worldLayer);

  // Day-cycle controller subscribes to AP depletion, drives recap/review
  // transitions. Must be attached BEFORE the player can spend cards.
  dayCycle.attach();

  bindStageToFlow({ app, worldLayer });
  mountOverlay(overlayRoot);
  installKeyboardHandler();

  console.info('[boot] flow + dayCycle + overlay + keyboard ready');
}

void main();
```

- [ ] **Step 3.8: Remove the P2 click-to-advance hack from `workstation.ts`** — find the `// ── Day-end auto-advance ────` block (added in P2 Task 5) and DELETE it entirely. Also remove the `import { resetPlayedThisDay } from '@/card/play';` if it becomes unused. Day cycling is now owned by DayCycleController.

- [ ] **Step 3.9: Smoke** — `pnpm dev` and verify no compile errors:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x/game
pnpm dev > /tmp/vite-dev-task3.log 2>&1 &
DEV_PID=$!
sleep 5
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
tail -10 /tmp/vite-dev-task3.log
kill $DEV_PID 2>/dev/null
wait 2>/dev/null
pgrep vite || echo "no vite leftover"
```

Expected: HTTP 200, no compile errors.

- [ ] **Step 3.10: Verify tsc + tests**:

```bash
pnpm tsc
pnpm test
```

Expected: 81 still pass (no test changes in Task 3).

- [ ] **Step 3.11: Commit**:

```bash
git add game/src/render/menu/daily-recap.tsx game/src/render/menu/weekly-recap.tsx \
        game/src/render/ui-overlay.tsx game/src/render/stage.ts \
        game/src/render/scene/workstation.ts game/src/main.ts \
        game/src/flow/day-cycle.ts game/index.html
git commit -m "feat(game): daily + weekly recap overlay screens (Preact)

P3's UI half-step. With day-cycle controller from Task 2, AP=0 transitions
to recap (or kpi_review on month-end). This task renders the recap UI.

- daily-recap.tsx: shows 'Day N — 日报' + AP used (max - current) + events
  (0 placeholder until event engine) + skip button + 90s auto-progress
  countdown.
- weekly-recap.tsx: Friday-only variant. Shows effort 3-dimension stub
  rows (积极性已登记 / 超额贡献已归档 / 产出记录存档) + KPI progress
  with '(待月末结算)' tag.
- ui-overlay.tsx: routes recap state to daily/weekly variant based on
  state.recapKind.
- stage.ts: extends OVERLAY_ALLOWED to include recap/kpi_review/gameover
  per spec §5.3 (overlay allowed in non-action states).
- workstation.ts: P2's click-to-advance hack removed. Day cycle now owned
  by DayCycleController via singleton dayCycle.attach() in main.ts.
- main.ts: wires dayCycle.attach() at boot before user input enabled.
- day-cycle.ts: appends singleton export `dayCycle` for UI imports.
- index.html: adds .menu-root--recap, .recap-rows, .recap-row CSS.

KPI Review and Game Over screens are stub placeholders rendered as
'(Task 4/5 wires this)' divs — wired properly in subsequent tasks.

Per design/gdd/daily-weekly-recap-ui.md + asset-strategy.md (UI
code-drawn) + plan Task 3.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 4: KPI Review screen (Preact, with breakdown rendering)

**Why now:** day-cycle controller transitions to kpi_review on month-end day; we need the actual UI to render it.

**Files:**
- Create: `game/src/render/menu/kpi-review.tsx`
- Modify: `game/src/render/ui-overlay.tsx` (replace placeholder with real component)

- [ ] **Step 4.1: Create `game/src/render/menu/kpi-review.tsx`**:

```tsx
import { kpi } from '@/economy/kpi';
import {
  KPI_EFFORT_WEIGHT,
  KPI_POTENTIAL_WEIGHT,
  KPI_TENURE_WEIGHT,
  POTENTIAL_CLAMP_MAX,
  POTENTIAL_CLAMP_MIN,
} from '@/economy/constants';
import { dayCycle } from '@/flow/day-cycle';

interface Props {
  monthIndex: number;
}

// design/gdd/kpi-review-game-over-ui.md: 3-row HR-tone breakdown of
// next-month threshold contributions (effort / potential / tenure %),
// plus a single capacity-vs-threshold comparison line. Confirm dismiss.
// SFX anchors at 800ms (PUNCH_CLOCK) + 1000ms (RECEIPT_HISS) deferred —
// audio is P4+ scope.

export function KpiReview({ monthIndex }: Props): preact.JSX.Element {
  // P3 only the potential term contributes meaningfully (effort_norm = 0,
  // tenure γ_effective = 0 in month 1). Compute the contribution % each
  // dimension WOULD add to the next threshold.
  const rawPotential = (kpi.actualKpi - kpi.monthlyThreshold) / kpi.monthlyThreshold;
  const potentialClamped = Math.max(POTENTIAL_CLAMP_MIN, Math.min(POTENTIAL_CLAMP_MAX, rawPotential));

  const effortPct = (KPI_EFFORT_WEIGHT * 0 * 100).toFixed(1);             // P3: 0
  const potentialPct = (KPI_POTENTIAL_WEIGHT * potentialClamped * 100).toFixed(1);
  const tenureGammaEff = monthIndex <= 1 ? 0 : KPI_TENURE_WEIGHT;
  const tenurePct = (tenureGammaEff * monthIndex * 100).toFixed(1);

  const tenureDisplay = monthIndex <= 1 ? '— (新人豁免)' : `${tenurePct}%`;

  return (
    <div class="menu-root menu-root--review">
      <h2 class="menu-title menu-title--small">月末考核 · 第 {monthIndex} 月</h2>
      <p class="menu-subtitle">下月 KPI 阈值贡献率</p>
      <div class="recap-rows">
        <div class="recap-row">
          <span class="recap-label">积极性贡献</span>
          <span class="recap-value">{effortPct}%</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">潜力贡献</span>
          <span class="recap-value">{potentialPct}%</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">资历贡献</span>
          <span class="recap-value">{tenureDisplay}</span>
        </div>
        <div class="recap-row recap-row--separator">
          <span class="recap-label">产能余量</span>
          <span class="recap-value">{Math.round(kpi.capacityNow)} → 下月阈值待结算</span>
        </div>
      </div>
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={() => dayCycle.confirmKpiReview()}>
          确认归档
        </button>
      </div>
    </div>
  );
}
```

- [ ] **Step 4.2: Replace placeholder in `ui-overlay.tsx`** — change the kpi_review case to import + render KpiReview:

```tsx
import { KpiReview } from './menu/kpi-review';
// ... in switch:
case 'kpi_review':
  assertOverlayAllowed(state);
  return <KpiReview monthIndex={state.monthIndex} />;
```

- [ ] **Step 4.3: Smoke + verify**:

```bash
pnpm dev > /tmp/vite-dev-task4.log 2>&1 & DEV_PID=$!; sleep 5
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
tail -10 /tmp/vite-dev-task4.log
kill $DEV_PID 2>/dev/null; wait 2>/dev/null
pnpm tsc; pnpm test
```

Expected: HTTP 200, tsc + 81 vitest pass.

- [ ] **Step 4.4: Commit**:

```bash
git add game/src/render/menu/kpi-review.tsx game/src/render/ui-overlay.tsx
git commit -m "feat(game): KPI Review overlay screen (3-row breakdown + confirm dismiss)

Renders when FSM enters kpi_review state (month-end day). Shows:
- Effort contribution % (P3: 0; P4+ wires effort_norm from overtime/hero)
- Potential contribution % (the only meaningful term in P3)
- Tenure contribution % ('— (新人豁免)' for month 1, real value after)
- Capacity vs '下月阈值待结算' summary line

confirm button calls dayCycle.confirmKpiReview() which runs Formula B
recalc + game-over evaluation (capacity-exceeded or severe-dismissal),
then either advances to next month or transitions to gameover.

Audio anchors (PUNCH_CLOCK at 800ms + RECEIPT_HISS at 1000ms per GDD)
deferred — audio is P4+ scope. SFX gating doesn't block UI per GDD.

Per design/gdd/kpi-review-game-over-ui.md + plan Task 4.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 5: Game Over screen + integration

**Why now:** confirmKpiReview() can transition to gameover when conditions are met. Render the certificate.

**Files:**
- Create: `game/src/render/menu/gameover.tsx`
- Modify: `game/src/render/ui-overlay.tsx` (replace placeholder)

- [ ] **Step 5.1: Create `game/src/render/menu/gameover.tsx`**:

```tsx
import { flow } from '@/flow/dispatcher';
import type { GameOverReason } from '@/flow/scene-state';

interface Props {
  reason: GameOverReason;
  monthIndex: number;
}

// design/gdd/kpi-review-game-over-ui.md: ironic dismissal certificate.
// "恭喜晋升" stamp on every variant (anti-励志 lint whitelist). Body
// copy varies by reason. Click anywhere → main_menu (P3 skips Archive
// flow — P4 adds it alongside save persistence).

const REASON_BODY: Record<GameOverReason, string> = {
  kpi_exceeds_capacity: '本月 KPI 阈值已超出承担能力上限。\n经评议，您的产出潜力已饱和。',
  dismissal_severe: '本月绩效大幅低于预期阈值。\n经评议，您的岗位适配度已不达标。',
};

export function GameOver({ reason, monthIndex }: Props): preact.JSX.Element {
  const goToMainMenu = (): void => flow.request({ kind: 'main_menu' });

  return (
    <div class="menu-root menu-root--gameover" onClick={goToMainMenu} style={{ cursor: 'pointer' }}>
      <h2 class="menu-title menu-title--small">解除劳动合同通知</h2>
      <div class="gameover-body">
        <p class="gameover-month">第 {monthIndex} 个工作月</p>
        <p class="gameover-reason">{REASON_BODY[reason]}</p>
        <p class="gameover-stamp">恭喜晋升</p>
      </div>
      <p class="recap-hint">点击任意位置回到主菜单</p>
    </div>
  );
}
```

- [ ] **Step 5.2: Add CSS** — append to `index.html` `<style>`:

```css
.menu-root--gameover {
  min-width: 400px;
  background: #2a1f14;
  border-color: #5a3a18;
}
.gameover-body {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  padding: 24px;
  border: 1px dashed #7a5838;
  background: #1a1206;
  width: 100%;
}
.gameover-month {
  font-size: 14px;
  color: #c8a85a;
  margin: 0;
  letter-spacing: 2px;
}
.gameover-reason {
  font-size: 13px;
  color: #c4b8a0;
  margin: 0;
  white-space: pre-line;
  text-align: center;
  line-height: 1.6;
}
.gameover-stamp {
  font-size: 36px;
  color: #c83428;
  margin: 8px 0 0 0;
  letter-spacing: 6px;
  font-weight: 700;
  border: 3px solid #c83428;
  padding: 8px 24px;
  transform: rotate(-4deg);
  background: rgba(200, 52, 40, 0.05);
}
```

- [ ] **Step 5.3: Replace placeholder in `ui-overlay.tsx`** — wire GameOver:

```tsx
import { GameOver } from './menu/gameover';
// ... in switch:
case 'gameover':
  assertOverlayAllowed(state);
  return <GameOver reason={state.reason} monthIndex={state.monthIndex} />;
```

- [ ] **Step 5.4: Smoke + verify**:

```bash
pnpm dev > /tmp/vite-dev-task5.log 2>&1 & DEV_PID=$!; sleep 5
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
tail -10 /tmp/vite-dev-task5.log
kill $DEV_PID 2>/dev/null; wait 2>/dev/null
pnpm tsc; pnpm test
```

Expected: HTTP 200, tsc + 81 vitest pass.

- [ ] **Step 5.5: Commit**:

```bash
git add game/src/render/menu/gameover.tsx game/src/render/ui-overlay.tsx game/index.html
git commit -m "feat(game): Game Over screen with ironic 「恭喜晋升」 stamp

Two reason copies (kpi_exceeds_capacity / dismissal_severe), shared
ironic stamp. Click anywhere → main_menu. (P4 will route to Archive
list per GDD; P3 skips Archive alongside save persistence deferral.)

CSS palette: dark wood backdrop (#2a1f14 / #5a3a18) for the certificate
frame; '恭喜晋升' stamp uses 屏幕红 #c83428 with rotate(-4deg) so it
reads as a hand-pressed corporate stamp. Anti-励志 lint whitelist
exemption applies to this exact key per GDD.

Per design/gdd/kpi-review-game-over-ui.md + plan Task 5.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 6: Workstation calendar prop wiring + exit verification + tag `v0.4.0-p3`

**Why now:** the workstation's calendar sprite is still showing `calendar_month_day_1.png` regardless of actual day. Wire it to the real calendar so visual state matches game state. Then run the full smoke walk and tag.

**Files:**
- Modify: `game/src/render/scene/workstation.ts` (calendar binding)

- [ ] **Step 6.1: Update calendar prop in `workstation.ts`** — replace the static `calendar_month_day_1.png` load with a state-driven swap subscribed to `calendar.onDateChanged`. Find the `STATIC_PROPS` section. Move the calendar entry OUT of `STATIC_PROPS`. After the static-props loop, add:

```ts
  // ── Calendar (date binding, swappable sprite) ───────────────────────────
  // Subscribes to calendar.onDateChanged. Source sprite filenames follow
  // the pattern calendar_month_day_<n>.png. P3 only has 4 distinct
  // calendar sprites available; map currentDay → nearest available frame.
  const calendarContainer = new Container();
  calendarContainer.label = 'calendar';
  calendarContainer.x = 70;
  calendarContainer.y = 60;
  ctx.worldLayer.addChild(calendarContainer);

  const CALENDAR_FRAMES = [
    'sprites/hud/calendar_month_day_1.png',
    'sprites/hud/calendar_mid_week.png',
    'sprites/hud/calendar_weekend_marked.png',
    'sprites/hud/calendar_month_end.png',
  ];

  function pickCalendarFrame(day: number): string {
    if (day <= 1) return CALENDAR_FRAMES[0]!;
    if (day <= 4) return CALENDAR_FRAMES[1]!;
    if (day <= 6) return CALENDAR_FRAMES[2]!;
    return CALENDAR_FRAMES[3]!; // day 7 = month end
  }

  let currentCalendarSprite: Sprite | null = null;
  const swapCalendarTo = async (url: string) => {
    const tex = await Assets.load(url);
    tex.source.scaleMode = 'linear';
    if (currentCalendarSprite) currentCalendarSprite.destroy();
    const s = new Sprite(tex);
    s.anchor.set(0.5);
    s.scale.set(0.25);
    calendarContainer.addChild(s);
    currentCalendarSprite = s;
  };
  await swapCalendarTo(pickCalendarFrame(calendar.currentDay));
  const unsubCalendar = calendar.onDateChanged(() => {
    void swapCalendarTo(pickCalendarFrame(calendar.currentDay));
  });
  teardowns.push(() => {
    unsubCalendar();
    calendarContainer.destroy({ children: true });
  });
```

Also add the import at top:

```ts
import { calendar } from '@/flow/calendar';
```

- [ ] **Step 6.2: Verify all calendar PNG variants exist** — these were generated by the parallel art-gen agent:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
ls assets/sprites/hud/calendar_*.png
```

Expected output should include `calendar_month_day_1.png`, `calendar_mid_week.png`, `calendar_weekend_marked.png`, `calendar_month_end.png`. If any are missing (the parallel agent may not have produced them), substitute with `calendar_month_day_1.png` for those slots and note as a TODO.

- [ ] **Step 6.3: Run the full verify chain**:

```bash
cd game
pnpm verify
```

Expected: assets sync, tsc clean, biome clean, vitest 81 passed.

- [ ] **Step 6.4: Production build**:

```bash
hdiutil detach "/Volumes/活过第 X 集" 2>&1 | tail -2
pnpm tauri build
```

Expected: cargo incremental, .app + .dmg produced.

- [ ] **Step 6.5: Manual smoke walk** (controller does this):

```bash
killall "活过第 X 集" 2>/dev/null
open "/Users/huanghaibin/Workspace/games/survived-episode-x/game/src-tauri/target/release/bundle/macos/活过第 X 集.app"
```

Walk through:
1. Main menu → 「开始」 → workstation, day 1 (calendar shows day-1 frame)
2. Spend all 4 cards → AP=0 → DAILY_RECAP overlay appears showing AP消耗 8/8, 事件登记 0项, 90s countdown
3. Click 「下一天」 → workstation again, day 2 (calendar swaps to mid-week frame), AP refilled to 8, cards re-enabled
4. Repeat days 2, 3, 4 (all DAILY_RECAP)
5. Day 5 = Friday → after AP=0, WEEKLY_RECAP variant appears (different copy: 积极性已登记 / 超额贡献已归档 / etc.)
6. Click 「进入周末」 → day 6
7. Day 6 → DAILY_RECAP again
8. Day 7 (month-end) → after AP=0, **KPI_REVIEW** appears (skips DAILY_RECAP). Shows 3 contribution rows + capacity. Click 「确认归档」.
9. Outcome depends on KPI: if actualKpi was modest (default play with 4 cards × 7 days × ~10 KPI/day ≈ 280, threshold 100) → potential is +1.0 clamped → next threshold = 100×1.18 = 118 → BELOW capacity 300 → next month begins (day 1, month 2)
10. To trigger Game Over: play very few cards (low KPI) OR play through many months until threshold > capacity (P3 won't naturally reach this in <10 months; harder to test)
11. Easier game-over test: stop spending cards, just click each card once for 1AP, get KPI low, hit month end. potential will be very negative → may trigger DISMISSAL_SEVERE
12. Confirm GameOver: stamp 「恭喜晋升」 visible, reason text matches, click anywhere → main menu

Esc + pause still works during action_day.

- [ ] **Step 6.6: Tag `v0.4.0-p3`**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/render/scene/workstation.ts
git commit -m "feat(game): wire calendar sprite to currentDay (4 frames day 1/mid/weekend/end)

calendar prop in workstation now swaps based on calendar.currentDay.
Frame mapping (P3 4-frame coverage):
- day 1: calendar_month_day_1
- day 2-4: calendar_mid_week
- day 5-6: calendar_weekend_marked
- day 7: calendar_month_end

Subscribes to calendar.onDateChanged for instant update on day advance.

Per plan Task 6.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>" && \
git tag -a v0.4.0-p3 -m "Slice 1 / Phase 3 complete: day cycle + KPI review + game over

End-to-end verified by user smoke walk:
- Day counter advances; calendar sprite swaps with day
- AP=0 → DAILY_RECAP (or WEEKLY_RECAP on Friday) overlay; 「下一天」
  refills AP and increments day
- Day 7 (MONTH_DAYS) → KPI_REVIEW skipping recap; shows 3-row HR-tone
  breakdown + capacity comparison
- KPI Review confirm runs Formula B recalc; threshold updates
  monotonically; if monthly_threshold > capacity_now → GAMEOVER
  (kpi_exceeds_capacity), or if raw potential < -0.15 →
  GAMEOVER (dismissal_severe)
- GAMEOVER shows ironic 「恭喜晋升」 stamp + reason copy; click → main_menu
- Pause + main-menu navigation unchanged

Vitest: 81 cases (50 P2 + 16 transitions + 7 calendar + 8 day-cycle).

KPI Formula B fully exercised in this slice (potential term active;
effort/tenure stubbed). MONTH_DAYS=7 in P3 (P4 retunes to design 30).

P4 picks up: save persistence + Archive list + effort tracking +
energy/mug + audio.

Per docs/superpowers/plans/2026-05-04-slice1-p3-day-cycle-kpi-review-gameover.md."
git push --follow-tags
```

- [ ] **Step 6.7: Update spec §9.2 P3 row**:

Edit `docs/superpowers/specs/2026-05-03-engine-switch-design.md` §9.2 — change P3 row:

```
| **P3 结束今日 → KPI Review → GameOver/下一天** | ✅ 完成 2026-05-?? (tag `v0.4.0-p3`, scope B: GDD MVP) | flow/calendar + day-cycle controller + 5 new states (recap/kpi_review/gameover) + 4 Preact overlay screens (daily/weekly recap + KPI review + game over) + Formula B recalc on month-end + 2 game-over reasons. mug/energy/effort/Archive deferred to P4. Plan: `docs/superpowers/plans/2026-05-04-slice1-p3-day-cycle-kpi-review-gameover.md`. |
```

Commit:
```bash
git add docs/superpowers/specs/2026-05-03-engine-switch-design.md
git commit -m "docs: mark Slice 1 P3 complete in design spec (tag v0.4.0-p3)"
git push
```

---

## Self-review checklist for the engineer reading this plan

After all tasks:
- [ ] `pnpm verify` from `game/` is green (81 vitest cases)
- [ ] `pnpm tauri build` produces a fresh `.dmg`
- [ ] Installed `.app` walks the day → recap → next day loop without console errors
- [ ] Day 7 triggers KPI_REVIEW skipping recap
- [ ] Friday triggers WEEKLY_RECAP
- [ ] Triggering GameOver (capacity-exceeded by playing many months OR dismissal-severe by ignoring all cards) shows the certificate
- [ ] Click on GameOver returns to main menu
- [ ] Commit `v0.4.0-p3` is tagged and pushed

## What is **not** in P3 (P4+ scope)

- **Save persistence** — Tauri fs API + JSON write (P4)
- **Archive list UI** — needs save persistence (P4 alongside)
- **Energy / mug binding** — cross-day resource (P4)
- **Effort tracking** (overtime / hero / overage counts → effort_norm) — needed for full Formula B (P4)
- **Audio** — KPI Review SFX anchors (PUNCH_CLOCK / RECEIPT_HISS) deferred (P4 alongside Howler integration)
- **Mid-month dismissal** — `action_day → gameover` legal transition deferred
- **VOLUNTARY_QUIT / DEMO_END** game-over reasons — UI hooks not built
- **MORNING_BRIEFING / AFTER_WORK** as visible states — collapsed into transient transitions in P3
- **Real MONTH_DAYS=30** — P3 uses 7 for testing speed; P4 retunes
- **NPC system** — entire scope deferred
- **Event script engine** — entire scope deferred to Slice 2

## Notes for Claude when executing

- **DayCycleController is a singleton.** Both production and Preact components import from `@/flow/day-cycle` via the named export `dayCycle`. Tests construct their own DayCycleController with custom deps.
- **Preact components subscribe to flow via the OverlayRouter** — they don't subscribe directly. They get fresh props each render.
- **Don't forget to attach() the controller** in main.ts BEFORE the player can spend cards. If forgotten, AP=0 won't trigger recap and the loop freezes (looks identical to the P2 bug).
- **MONTH_DAYS=7 is intentional.** Changing back to 30 makes the loop untestable in a single sitting. P4 retunes once core loop is verified.
- **Calendar prop has 4 frames available** (day_1 / mid_week / weekend_marked / month_end). If a parallel agent generates more (e.g. day_2.png), the pickCalendarFrame() function can be extended.
- **GAMEOVER → main_menu is the only exit** until Archive lands in P4. Don't add Archive routing now.
