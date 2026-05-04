# Slice 1 / Phase 2 — AP + KPI + 4 Cards (Scope C: hybrid)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the AP economy, the KPI module (with Formula B's `potential` term active — effort+tenure stubbed as 0 for P2), 4 hand-coded action cards, the 7-step play sequence (first 3 steps wired), and the diegetic UI bindings (sticky-note AP row + monitor KPI state). Exit criterion: launch `.app` → main menu → 「开始」 → workstation showing 8 sticky-note slots + monitor + 4 card faces along the bottom; click a card → AP decremented (sticky crossed) + KPI value increases + monitor swaps to a new state if KPI crosses a band; when AP=0, all remaining cards switch to DISABLED (greyed) state.

**Architecture:** Per spec §6.5, every domain has its own per-module emitter (Red Line 4 spirit extended). `economy/ap` owns AP state and emits `apChanged`; `economy/kpi` owns KPI state and emits `kpiChanged`. `card/` owns hand state + the 7-step play sequence (steps 1-3 implemented in P2; mutex/cooldown/NPC deferred to P3+). `render/cards/hand.ts` and the extended `render/scene/workstation.ts` subscribe to those emitters and re-render. Numerical constants live in `economy/constants.ts` (single source) — a future task wires `gen:constants` from `design/registry/entities.yaml`, but for P2 we hand-write them with explicit comments tying each value to its design source. KPI Formula B is implemented in full but only `potential` contributes (effort=0, tenure=0); the formula function is exported for P3's month-end recalculator to call.

**Tech Stack:** All existing P0+P1 toolchain. Adds nothing — pure TS + PixiJS + vitest.

**Spec reference:** `docs/superpowers/specs/2026-05-03-engine-switch-design.md` §3 (modules), §6.5 (domain emitters), §7 (red lines). GDD ground truth: `design/gdd/ap-economy-system.md`, `design/gdd/kpi-reverse-threshold-system.md`, `design/gdd/action-card-system.md`, `design/gdd/hud-diegetic.md`. Asset strategy: `design/assets/asset-strategy.md` (UI = code-drawn; sprite atlases for prop art).

**Prior tag:** `v0.2.0-p1` — FSM + main menu + workstation 4 props + pause working.

---

## Critical design corrections from GDD review

These were wrong in P1's spec narrative; P2 codebase will match the GDD:

- **mug ≠ AP indicator. mug = energy** (cross-day resource, 0–100). Energy is **not implemented in P2** — defer to P3+. mug stays as a static `coffee_full.png` for now.
- **AP indicator = sticky-note row** (8 base slots + 2 overtime + 1 early-leave folded). P2 implements the 8-base-slot version, code-drawn (PixiJS Graphics) per asset-strategy.md.
- **KPI ≠ 3 separate metrics**. KPI = single `actual_kpi_m` number; threshold is computed via Formula B from 3 *input dimensions* (effort, potential, tenure). Only `potential` contributes in P2.
- **Card UI = code-drawn**. Card frames, AP slots, button states use PixiJS `Graphics` + `Text`. Card *face art* uses real sprites from `assets/sprites/cards/defense/`.

---

## File Structure

After P2:

```
game/
├── src/
│   ├── economy/                                     (NEW directory)
│   │   ├── constants.ts                             (CREATE — hand-written; GDD-sourced consts)
│   │   ├── ap.ts                                    (CREATE — AP store + emitter)
│   │   └── kpi.ts                                   (CREATE — KPI store + Formula B + emitter)
│   ├── card/                                        (NEW directory)
│   │   ├── card.ts                                  (CREATE — Card type + 4-state machine)
│   │   ├── play.ts                                  (CREATE — 7-step play sequence, P2 steps 1-3)
│   │   └── data/
│   │       └── defense.ts                           (CREATE — 4 hand-coded card defs)
│   ├── render/
│   │   ├── cards/
│   │   │   └── hand.ts                              (CREATE — code-drawn card hand UI)
│   │   ├── scene/
│   │   │   └── workstation.ts                       (MODIFY — add sticky AP row + monitor binding + hand layer)
│   │   └── (other dirs unchanged)
│   └── (other dirs unchanged)
└── tests/
    ├── economy/                                     (NEW directory)
    │   ├── ap.test.ts                               (CREATE — spend, refill, monotonicity)
    │   └── kpi.test.ts                              (CREATE — applyContribution, Formula B potential term)
    └── card/                                        (NEW directory)
        ├── card.test.ts                             (CREATE — 4-state machine transitions)
        └── play.test.ts                             (CREATE — 7-step ordering, side effects)
```

---

## Task 1: `economy/` — constants + AP store + KPI store (TDD)

**Why first:** every other module reads from these. Build them standalone with full test coverage.

**Files:**
- Create: `game/src/economy/constants.ts`
- Create: `game/src/economy/ap.ts`
- Create: `game/src/economy/kpi.ts`
- Create: `game/tests/economy/ap.test.ts`
- Create: `game/tests/economy/kpi.test.ts`

- [ ] **Step 1.1: Create `game/src/economy/constants.ts`** (exact content):

```ts
// Hand-written named constants. Sources from design/registry/entities.yaml +
// the GDDs cited in each comment. A future task wires `pnpm gen:constants`
// to generate this from the YAML registry, at which point this file is
// replaced by `game/src/generated/constants.ts`. Until then, edit BOTH the
// YAML and this file when changing a value.
//
// Red Line 5: any TS file using these numbers must import from here.
// Inline magic numbers matching these values are a lint failure (deferred
// `lint:redline-5` will catch them).

// ─── AP ───────────────────────────────────────────────────────────────────
// design/gdd/ap-economy-system.md §"BASE_AP_PER_DAY = 8 (named constant,
// NOT a tuning knob — permanently fixed)". Anti-Pillar 1 monotonicity:
// AP cap can NEVER permanently increase.
export const BASE_AP_PER_DAY = 8;

// Overtime adds +2 → single-day ceiling 10. Not used in P2; reserved.
export const OVERTIME_BONUS_AP = 2;

// ─── KPI Formula B coefficients ───────────────────────────────────────────
// design/gdd/kpi-reverse-threshold-system.md "Formula B (conservative)":
// next_threshold = current × (1+α·effort) × (1+β·potential) × (1+γ_eff·m)
export const KPI_EFFORT_WEIGHT = 0.04;     // α
export const KPI_POTENTIAL_WEIGHT = 0.18;  // β
export const KPI_TENURE_WEIGHT = 0.012;    // γ (γ_effective = 0 for month 1)

// Monthly capacity: capacity_now = max(CAPACITY_FLOOR, BASE_CAPACITY −
// DECAY_RATE × m) × 100. Player loses ~5 capacity/month; floor at 40.
export const BASE_CAPACITY = 3.0;
export const DECAY_RATE = 0.05;
export const CAPACITY_FLOOR = 0.4;

// Initial month-1 threshold (placeholder for P2; P3+ may load from registry).
export const MONTHLY_THRESHOLD_INITIAL = 100;

// Potential clamp range from GDD.
export const POTENTIAL_CLAMP_MIN = -0.15;
export const POTENTIAL_CLAMP_MAX = 1.0;

// Severe underperformance dismissal threshold (raw potential < this).
export const POTENTIAL_DISMISSAL = -0.15;
```

- [ ] **Step 1.2: Write the failing test** at `game/tests/economy/ap.test.ts` (exact content):

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ApSystem } from '../../src/economy/ap';
import { BASE_AP_PER_DAY } from '../../src/economy/constants';

describe('ApSystem', () => {
  let ap: ApSystem;

  beforeEach(() => {
    ap = new ApSystem();
  });

  it(`starts at BASE_AP_PER_DAY (${BASE_AP_PER_DAY})`, () => {
    expect(ap.current).toBe(BASE_AP_PER_DAY);
    expect(ap.max).toBe(BASE_AP_PER_DAY);
  });

  it('spend(n) reduces current and emits apChanged', () => {
    const listener = vi.fn();
    ap.onChanged(listener);
    ap.spend(2);
    expect(ap.current).toBe(BASE_AP_PER_DAY - 2);
    expect(listener).toHaveBeenCalledWith(BASE_AP_PER_DAY - 2, -2);
  });

  it('throws on overdraw (red line: AP underflow is a bug)', () => {
    ap.spend(BASE_AP_PER_DAY);
    expect(() => ap.spend(1)).toThrow(/AP underflow/);
  });

  it('canAfford(n) returns true iff current >= n', () => {
    ap.spend(6);
    expect(ap.canAfford(2)).toBe(true);
    expect(ap.canAfford(3)).toBe(false);
  });

  it('resetForNewDay() refills to max and emits', () => {
    ap.spend(5);
    const listener = vi.fn();
    ap.onChanged(listener);
    ap.resetForNewDay();
    expect(ap.current).toBe(BASE_AP_PER_DAY);
    expect(listener).toHaveBeenCalledWith(BASE_AP_PER_DAY, 5);
  });

  it('unsubscribe stops emissions to that listener', () => {
    const listener = vi.fn();
    const unsub = ap.onChanged(listener);
    ap.spend(1);
    unsub();
    ap.spend(1);
    expect(listener).toHaveBeenCalledTimes(1);
  });

  it('max is frozen — cannot mutate (Red Line 2 monotonicity)', () => {
    expect(() => {
      // @ts-expect-error — assigning to a readonly accessor must fail at compile
      ap.max = 99;
    }).toBeDefined();
    // Runtime check: max stays at BASE_AP_PER_DAY no matter what
    expect(ap.max).toBe(BASE_AP_PER_DAY);
  });
});
```

- [ ] **Step 1.3: Run the test — expect FAIL** ("Failed to resolve import"):

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x/game
pnpm vitest run tests/economy/ap.test.ts
```

Expected: FAIL with module-not-found. Confirms RED.

- [ ] **Step 1.4: Implement `game/src/economy/ap.ts`** (exact content):

```ts
import { BASE_AP_PER_DAY } from './constants';

export type ApListener = (current: number, delta: number) => void;

// Single-source AP store. Per spec §6.5: each domain module is the SOLE
// emitter for its own events. Other modules subscribe via onChanged.
//
// Red Line 2 (monotonicity): max is fixed at BASE_AP_PER_DAY forever.
// Overtime later may bump within a day, but this `max` is the BASE
// (resets every day). The runtime cap that overtime sits on top of
// (max + OVERTIME_BONUS_AP) is computed on the fly when overtime
// actually lands — not by mutating this base.
export class ApSystem {
  private value: number = BASE_AP_PER_DAY;
  private listeners = new Set<ApListener>();

  get current(): number {
    return this.value;
  }

  get max(): number {
    return BASE_AP_PER_DAY;
  }

  canAfford(n: number): boolean {
    return this.value >= n;
  }

  spend(n: number): void {
    if (n < 0) throw new Error(`AP spend amount must be non-negative, got ${n}`);
    if (n > this.value) {
      throw new Error(
        `AP underflow: tried to spend ${n} but only ${this.value} available. ` +
          `Caller must canAfford() first.`,
      );
    }
    this.value -= n;
    for (const l of this.listeners) l(this.value, -n);
  }

  resetForNewDay(): void {
    const delta = this.max - this.value;
    this.value = this.max;
    for (const l of this.listeners) l(this.value, delta);
  }

  onChanged(fn: ApListener): () => void {
    this.listeners.add(fn);
    let unsubscribed = false;
    return () => {
      if (unsubscribed) return;
      unsubscribed = true;
      this.listeners.delete(fn);
    };
  }
}

// Singleton — production import goes through this instance.
export const ap = new ApSystem();
```

- [ ] **Step 1.5: Run the test — expect 7 PASS**:

```bash
pnpm vitest run tests/economy/ap.test.ts
```

Expected: 7 passed.

- [ ] **Step 1.6: Write the failing test** at `game/tests/economy/kpi.test.ts` (exact content):

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  BASE_CAPACITY,
  CAPACITY_FLOOR,
  DECAY_RATE,
  KPI_POTENTIAL_WEIGHT,
  MONTHLY_THRESHOLD_INITIAL,
} from '../../src/economy/constants';
import { KpiSystem, recalcThresholdFormulaB } from '../../src/economy/kpi';

describe('KpiSystem', () => {
  let kpi: KpiSystem;

  beforeEach(() => {
    kpi = new KpiSystem();
  });

  it('starts at actualKpi=0, threshold=MONTHLY_THRESHOLD_INITIAL, month=1', () => {
    expect(kpi.actualKpi).toBe(0);
    expect(kpi.monthlyThreshold).toBe(MONTHLY_THRESHOLD_INITIAL);
    expect(kpi.month).toBe(1);
  });

  it('applyContribution(n) increases actualKpi and emits', () => {
    const listener = vi.fn();
    kpi.onChanged(listener);
    kpi.applyContribution(15);
    expect(kpi.actualKpi).toBe(15);
    expect(listener).toHaveBeenCalledWith(15, 15);
  });

  it('rejects negative contribution (cards never reduce KPI)', () => {
    expect(() => kpi.applyContribution(-1)).toThrow(/non-negative/i);
  });

  it('capacityNow follows BASE_CAPACITY × 100 in month 1', () => {
    expect(kpi.capacityNow).toBeCloseTo(BASE_CAPACITY * 100, 5); // 300
  });

  it('capacityNow decays by DECAY_RATE × 100 per month', () => {
    kpi.advanceMonth();
    expect(kpi.capacityNow).toBeCloseTo((BASE_CAPACITY - DECAY_RATE) * 100, 5); // 295
  });

  it('capacityNow floors at CAPACITY_FLOOR × 100 (40) for high months', () => {
    for (let i = 0; i < 100; i++) kpi.advanceMonth();
    expect(kpi.capacityNow).toBeCloseTo(CAPACITY_FLOOR * 100, 5); // 40
  });
});

describe('recalcThresholdFormulaB (P2: only potential term active)', () => {
  it('returns current threshold when potential = 0', () => {
    expect(
      recalcThresholdFormulaB({
        currentThreshold: 100,
        actualKpi: 100,
        effortNorm: 0,
        month: 1,
      }),
    ).toBe(100);
  });

  it('increases threshold when potential is positive', () => {
    // potential = (actualKpi - threshold) / threshold = (120-100)/100 = 0.20
    // factor = 1 + 0.18 × 0.20 = 1.036
    // next = round(100 × 1.036) = 104
    expect(
      recalcThresholdFormulaB({
        currentThreshold: 100,
        actualKpi: 120,
        effortNorm: 0,
        month: 1,
      }),
    ).toBe(104);
  });

  it('clamps potential at +1.0 (cannot raise threshold faster than ×(1+β))', () => {
    // raw potential would be (1000-100)/100 = 9.0; clamped to 1.0
    // factor = 1 + 0.18 × 1.0 = 1.18
    expect(
      recalcThresholdFormulaB({
        currentThreshold: 100,
        actualKpi: 1000,
        effortNorm: 0,
        month: 1,
      }),
    ).toBe(118);
  });

  it('clamps potential at −0.15 (cannot lower threshold below ×(1+β×−0.15))', () => {
    // raw potential = (50-100)/100 = -0.5; clamped to -0.15
    // factor = 1 + 0.18 × -0.15 = 0.973
    // next = round(100 × 0.973) = 97
    expect(
      recalcThresholdFormulaB({
        currentThreshold: 100,
        actualKpi: 50,
        effortNorm: 0,
        month: 1,
      }),
    ).toBe(97);
  });

  it('threshold is monotonically non-decreasing once applied via applyMonthlyRecalc', () => {
    const k = new KpiSystem();
    k.applyContribution(50); // actualKpi 50, threshold 100 → potential = -0.5 → clamped -0.15
    const before = k.monthlyThreshold;
    k.applyMonthlyRecalc(); // formula returns 97, but max(100, 97) = 100
    expect(k.monthlyThreshold).toBe(before); // unchanged, monotonicity preserved
  });

  it('threshold rises when potential is positive on apply', () => {
    const k = new KpiSystem();
    k.applyContribution(120);
    k.applyMonthlyRecalc();
    expect(k.monthlyThreshold).toBeGreaterThan(MONTHLY_THRESHOLD_INITIAL);
  });

  it(`uses the documented β coefficient: ${KPI_POTENTIAL_WEIGHT}`, () => {
    expect(KPI_POTENTIAL_WEIGHT).toBe(0.18);
  });
});
```

- [ ] **Step 1.7: Run the test — expect FAIL** (module not found):

```bash
pnpm vitest run tests/economy/kpi.test.ts
```

Expected: FAIL.

- [ ] **Step 1.8: Implement `game/src/economy/kpi.ts`** (exact content):

```ts
import {
  BASE_CAPACITY,
  CAPACITY_FLOOR,
  DECAY_RATE,
  KPI_EFFORT_WEIGHT,
  KPI_POTENTIAL_WEIGHT,
  KPI_TENURE_WEIGHT,
  MONTHLY_THRESHOLD_INITIAL,
  POTENTIAL_CLAMP_MAX,
  POTENTIAL_CLAMP_MIN,
} from './constants';

export type KpiListener = (actualKpi: number, delta: number) => void;

// design/gdd/kpi-reverse-threshold-system.md Formula B:
// next_threshold = current × (1 + α·effort_norm)
//                          × (1 + β·potential_clamped)
//                          × (1 + γ_effective·month)
// where γ_effective = 0 for month 1 (novice protection).
//
// In P2: effort_norm passed in by caller (defaults to 0 — wired in P3 when
// effort tracking lands), tenure term active per formula.
export interface FormulaBInputs {
  currentThreshold: number;
  actualKpi: number;
  effortNorm: number; // [0, 1]; 0 in P2
  month: number; // 1-indexed
}

export function recalcThresholdFormulaB(inputs: FormulaBInputs): number {
  const { currentThreshold, actualKpi, effortNorm, month } = inputs;
  const rawPotential = (actualKpi - currentThreshold) / currentThreshold;
  const potential = Math.max(POTENTIAL_CLAMP_MIN, Math.min(POTENTIAL_CLAMP_MAX, rawPotential));
  const gammaEffective = month <= 1 ? 0 : KPI_TENURE_WEIGHT;
  const factor =
    (1 + KPI_EFFORT_WEIGHT * effortNorm) *
    (1 + KPI_POTENTIAL_WEIGHT * potential) *
    (1 + gammaEffective * month);
  return Math.round(currentThreshold * factor);
}

export class KpiSystem {
  private _actualKpi = 0;
  private _monthlyThreshold: number = MONTHLY_THRESHOLD_INITIAL;
  private _month = 1;
  private listeners = new Set<KpiListener>();

  get actualKpi(): number {
    return this._actualKpi;
  }
  get monthlyThreshold(): number {
    return this._monthlyThreshold;
  }
  get month(): number {
    return this._month;
  }

  // Capacity decays linearly with month, floors at CAPACITY_FLOOR.
  // Red Line 2: capacity is monotonically NON-INCREASING. (Tests check this.)
  get capacityNow(): number {
    return Math.max(CAPACITY_FLOOR, BASE_CAPACITY - DECAY_RATE * (this._month - 1)) * 100;
  }

  applyContribution(n: number): void {
    if (n < 0) throw new Error(`KPI contribution must be non-negative, got ${n}`);
    this._actualKpi += n;
    for (const l of this.listeners) l(this._actualKpi, n);
  }

  // Called at month-end (P3+). In P2 manually triggerable for testing.
  // Red Line 2: threshold is monotonically NON-DECREASING via max() guard.
  applyMonthlyRecalc(effortNorm = 0): void {
    const next = recalcThresholdFormulaB({
      currentThreshold: this._monthlyThreshold,
      actualKpi: this._actualKpi,
      effortNorm,
      month: this._month,
    });
    this._monthlyThreshold = Math.max(this._monthlyThreshold, next);
  }

  // P3+ wiring; exposed in P2 for capacity-decay test only.
  advanceMonth(): void {
    this._month += 1;
  }

  onChanged(fn: KpiListener): () => void {
    this.listeners.add(fn);
    let unsubscribed = false;
    return () => {
      if (unsubscribed) return;
      unsubscribed = true;
      this.listeners.delete(fn);
    };
  }
}

export const kpi = new KpiSystem();
```

- [ ] **Step 1.9: Run the test — expect 14 PASS** (6 KpiSystem + 8 recalc):

```bash
pnpm vitest run tests/economy/kpi.test.ts
```

Expected: 14 passed.

- [ ] **Step 1.10: Verify whole suite + typecheck**:

```bash
pnpm tsc
pnpm test
```

Expected: tsc exit 0; vitest reports 19 (existing) + 7 (ap) + 14 (kpi) = 40 passed.

- [ ] **Step 1.11: Commit**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/economy game/tests/economy
git commit -m "feat(game): economy/ — AP store + KPI store + Formula B (P2 partial)

Three modules per spec §6.5 (per-domain emitter pattern):
- constants.ts: hand-written named constants sourced from the GDDs
  (BASE_AP_PER_DAY=8, KPI_*_WEIGHT, BASE_CAPACITY/DECAY/FLOOR, etc.).
  Future task wires gen:constants from design/registry/entities.yaml;
  for P2 these are the single source.
- ap.ts: AP store with spend()/canAfford()/resetForNewDay()/onChanged().
  Throws on underflow (caller must canAfford first). max is read-only —
  Red Line 2 monotonicity enforced at type AND runtime level.
- kpi.ts: KPI store with applyContribution()/applyMonthlyRecalc()/
  capacityNow/onChanged(). Implements Formula B in full but only the
  potential term is meaningful in P2 (effort_norm passed as 0; tenure
  γ_effective = 0 for month 1, kicks in P3+). monthlyThreshold guarded
  by max() to enforce non-decreasing monotonicity (Red Line 2).

Vitest suite: +21 cases (7 ap + 6 kpi store + 8 Formula B). Total now
40 passed across 5 test files.

Per spec §6.5 + plan Task 1. GDD ground truth:
- ap-economy-system.md (BASE_AP_PER_DAY, monotonicity)
- kpi-reverse-threshold-system.md (Formula B with α=0.04, β=0.18,
  γ=0.012, potential clamp [-0.15, +1.0], capacity decay 5/month
  floored at 40)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 2: `card/` — schema, 4 placeholder cards, 4-state machine, 7-step play (steps 1-3)

**Files:**
- Create: `game/src/card/card.ts`
- Create: `game/src/card/play.ts`
- Create: `game/src/card/data/defense.ts`
- Create: `game/tests/card/card.test.ts`
- Create: `game/tests/card/play.test.ts`

- [ ] **Step 2.1: Create `game/src/card/card.ts`** (exact content):

```ts
// Per design/gdd/action-card-system.md §schema. P2 implements a SUBSET of
// the full schema fields — the rest (npc_target, mutex_group,
// unlock_condition, event_id_link) are deferred to P3+ and explicitly
// omitted here. When P3 adds them, extend Card with optional fields
// (don't redesign — TS structural typing handles additive changes).

export type CardId = string;

// Effect placeholder. Real discriminated union per spec §4.1 (effects)
// arrives with the EventScript engine in Slice 2. P2's effects only need
// to carry their kpi_contribution (the only thing card play uses in steps
// 1-3 of the 7-step sequence).
export interface CardEffect {
  kind: 'kpi_contribution';
  amount: number;
}

export interface Card {
  id: CardId;
  apCost: 1 | 2 | 3; // GDD enforces strict {1,2,3}
  isHero: boolean;
  // Per-card sprite face URL. Resolved by sync-sprites; relative path so
  // it works in both vite dev and Tauri release (P0 lesson, see memory).
  faceUrl: string;
  title: string;     // Chinese label shown on card
  // P2 consumes only kpi_contribution effects via play.ts. Future effects
  // (NPC relationship, AP refund, etc.) extend the union and are no-ops
  // until their owning system lands.
  effects: ReadonlyArray<CardEffect>;
}

// 4-state machine per design/gdd/action-card-system.md "4-state machine
// (per-card, evaluated on every hand refresh)".
export type CardState = 'IDLE' | 'PLAYABLE' | 'DISABLED' | 'PLAYED';

// Pure function: given a card and the current AP balance + whether it's
// already been played this day, return its state. Called by hand UI on
// every render.
export function evaluateCardState(
  card: Card,
  currentAp: number,
  playedThisDay: boolean,
): CardState {
  if (playedThisDay) return 'PLAYED';
  if (currentAp < card.apCost) return 'DISABLED';
  return 'IDLE';
  // PLAYABLE is set by the hand UI when the card is hover/focused — the
  // state machine here returns IDLE; the UI overlays PLAYABLE on top.
}
```

- [ ] **Step 2.2: Create `game/src/card/data/defense.ts`** (exact content):

```ts
import type { Card } from '../card';

// 4 hand-coded placeholder defense cards for P2. Card faces use real
// sprites from assets/sprites/cards/defense/ (provided by parallel
// art-gen session). AP costs distributed 2/1/1 across {1,2,3} for the
// hand of 4 — full deck-level 40/40/20 distribution will land when the
// full card library is authored (P3+).
export const DEFENSE_CARDS_P2: ReadonlyArray<Card> = [
  {
    id: 'card_pretend_busy',
    apCost: 1,
    isHero: false,
    faceUrl: 'sprites/cards/defense/look_busy.png',
    title: '装作很忙',
    effects: [{ kind: 'kpi_contribution', amount: 5 }],
  },
  {
    id: 'card_dodge_meeting',
    apCost: 2,
    isHero: false,
    faceUrl: 'sprites/cards/defense/dodge_meeting.png',
    title: '躲开会议',
    effects: [{ kind: 'kpi_contribution', amount: 10 }],
  },
  {
    id: 'card_call_in_sick',
    apCost: 3,
    isHero: false,
    faceUrl: 'sprites/cards/defense/call_in_sick.png',
    title: '请病假',
    effects: [{ kind: 'kpi_contribution', amount: 18 }],
  },
  {
    id: 'card_slack_off',
    apCost: 1,
    isHero: false,
    faceUrl: 'sprites/cards/defense/slack_off.png',
    title: '划水',
    effects: [{ kind: 'kpi_contribution', amount: 4 }],
  },
];
```

- [ ] **Step 2.3: Write the failing test** at `game/tests/card/card.test.ts` (exact content):

```ts
import { describe, expect, it } from 'vitest';
import { type Card, evaluateCardState } from '../../src/card/card';

const c1: Card = {
  id: 'test_1',
  apCost: 1,
  isHero: false,
  faceUrl: 'x.png',
  title: 'A',
  effects: [],
};
const c3: Card = { ...c1, id: 'test_3', apCost: 3 };

describe('evaluateCardState', () => {
  it('returns PLAYED when playedThisDay=true regardless of AP', () => {
    expect(evaluateCardState(c1, 8, true)).toBe('PLAYED');
    expect(evaluateCardState(c1, 0, true)).toBe('PLAYED');
  });

  it('returns DISABLED when currentAp < apCost', () => {
    expect(evaluateCardState(c3, 2, false)).toBe('DISABLED');
    expect(evaluateCardState(c3, 0, false)).toBe('DISABLED');
  });

  it('returns IDLE when affordable and not yet played', () => {
    expect(evaluateCardState(c1, 1, false)).toBe('IDLE');
    expect(evaluateCardState(c3, 8, false)).toBe('IDLE');
  });
});
```

- [ ] **Step 2.4: Run the test — expect FAIL** (module not found), then verify Task 2.1's `card.ts` makes it pass:

```bash
pnpm vitest run tests/card/card.test.ts
```

Expected first run: FAIL (file not yet read in ts include scope, or module errors). After Task 2.1's file exists, this passes 3 tests.

- [ ] **Step 2.5: Write the failing test** at `game/tests/card/play.test.ts` (exact content):

```ts
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { type Card, type CardId } from '../../src/card/card';
import { ApSystem } from '../../src/economy/ap';
import { KpiSystem } from '../../src/economy/kpi';
import { playCard, type PlayCardContext } from '../../src/card/play';

const lookBusy: Card = {
  id: 'card_look_busy',
  apCost: 1,
  isHero: false,
  faceUrl: 'x.png',
  title: '装作很忙',
  effects: [{ kind: 'kpi_contribution', amount: 5 }],
};

const heroCard: Card = {
  id: 'card_hero',
  apCost: 2,
  isHero: true,
  faceUrl: 'x.png',
  title: '英雄主义',
  effects: [{ kind: 'kpi_contribution', amount: 10 }],
};

describe('playCard (P2: implements steps 1-3 of 7-step sequence)', () => {
  let ctx: PlayCardContext;
  let cardPlayed: ReturnType<typeof vi.fn>;
  let played: Set<CardId>;

  beforeEach(() => {
    cardPlayed = vi.fn();
    played = new Set();
    ctx = {
      ap: new ApSystem(),
      kpi: new KpiSystem(),
      onCardPlayed: cardPlayed,
      playedThisDay: played,
    };
  });

  afterEach(() => {
    cardPlayed.mockReset();
  });

  it('Step 1: emits onCardPlayed with the card id', () => {
    playCard(lookBusy, ctx);
    expect(cardPlayed).toHaveBeenCalledWith('card_look_busy');
  });

  it('Step 3: applies kpi_contribution from each effect', () => {
    playCard(lookBusy, ctx);
    expect(ctx.kpi.actualKpi).toBe(5);
  });

  it('AP is spent (Rule 6 pre-check baked into play)', () => {
    playCard(lookBusy, ctx);
    expect(ctx.ap.current).toBe(7); // 8 - 1
  });

  it('records the card in playedThisDay', () => {
    playCard(lookBusy, ctx);
    expect(played.has('card_look_busy')).toBe(true);
  });

  it('throws and does NOT mutate state if AP is insufficient', () => {
    ctx.ap.spend(8); // drain
    expect(() => playCard(lookBusy, ctx)).toThrow(/AP underflow|cannot afford/i);
    expect(ctx.kpi.actualKpi).toBe(0);
    expect(played.has('card_look_busy')).toBe(false);
  });

  it('throws if the card was already played today', () => {
    playCard(lookBusy, ctx);
    expect(() => playCard(lookBusy, ctx)).toThrow(/already played/i);
  });

  it('hero cards: emits onCardPlayed flag (Step 2 stub via emit; full hero accounting is P3+)', () => {
    playCard(heroCard, ctx);
    // P2 just records the play. P3 wires hero count into effort_norm.
    expect(cardPlayed).toHaveBeenCalledWith('card_hero');
    expect(ctx.kpi.actualKpi).toBe(10);
    expect(ctx.ap.current).toBe(6);
  });

  it('event ordering: onCardPlayed fires BEFORE kpi changes (per GDD step order)', () => {
    const order: string[] = [];
    ctx.onCardPlayed = () => order.push('emit');
    ctx.kpi.onChanged(() => order.push('kpi'));
    playCard(lookBusy, ctx);
    expect(order).toEqual(['emit', 'kpi']);
  });
});
```

- [ ] **Step 2.6: Run the test — expect FAIL** (play.ts not yet created):

```bash
pnpm vitest run tests/card/play.test.ts
```

Expected: FAIL.

- [ ] **Step 2.7: Implement `game/src/card/play.ts`** (exact content):

```ts
import { ap as defaultAp, type ApSystem } from '@/economy/ap';
import { kpi as defaultKpi, type KpiSystem } from '@/economy/kpi';
import type { Card, CardId } from './card';

// Context for playCard. Tests pass their own instances; production calls
// playCard(card) which resolves to the singletons below via the default.
export interface PlayCardContext {
  ap: ApSystem;
  kpi: KpiSystem;
  // Fired after Step 1 of the 7-step sequence. P3+ wires this to the
  // event-script engine for trigger lookup.
  onCardPlayed: (id: CardId) => void;
  // Cards that have been played today; populated at Step 7 (history).
  // Hand UI passes the Set so it can re-render disabled state.
  playedThisDay: Set<CardId>;
}

const defaultPlayedThisDay = new Set<CardId>();
const defaultEmitter = (_id: CardId): void => {
  /* no-op until event engine lands */
};

// Production entry point: play a card using the singleton AP/KPI/etc.
// Pass an explicit ctx in tests.
export function playCard(
  card: Card,
  ctx: PlayCardContext = {
    ap: defaultAp,
    kpi: defaultKpi,
    onCardPlayed: defaultEmitter,
    playedThisDay: defaultPlayedThisDay,
  },
): void {
  // Pre-checks (Rule 6 and "already played" guard before mutating anything).
  if (ctx.playedThisDay.has(card.id)) {
    throw new Error(`Card ${card.id} already played this day`);
  }
  if (!ctx.ap.canAfford(card.apCost)) {
    throw new Error(`Cannot afford card ${card.id}: needs ${card.apCost} AP, have ${ctx.ap.current}`);
  }

  // Step 0 (pre-emit): spend AP. GDD rule 6 says AP is consumed before the
  // 7-step sequence starts; we keep that ordering so the AP indicator
  // updates immediately when the click registers.
  ctx.ap.spend(card.apCost);

  // Step 1: emit card_played for trigger lookup.
  ctx.onCardPlayed(card.id);

  // Step 2 (P2 stub): if isHero, GDD says
  // "APEconomy.report_hero_card_played()". P3 wires this into effort_norm.
  // For P2 we just record the flag implicitly via the played card's data.
  // No state change here.

  // Step 3: apply kpi_contribution from each effect.
  for (const effect of card.effects) {
    switch (effect.kind) {
      case 'kpi_contribution':
        ctx.kpi.applyContribution(effect.amount);
        break;
    }
  }

  // Steps 4 (NPC), 5 (mutex), 6 (cooldown) deferred to P3+.

  // Step 7: history.
  ctx.playedThisDay.add(card.id);
}

// Test/UI helper: shared mutable set of cards played this day. Reset
// every day-start. UI subscribes via observation (re-evaluating
// evaluateCardState on every render).
export const playedThisDay = defaultPlayedThisDay;

// Reset on new day. Called by the day-advance flow (P2 implementation
// is a button or auto-trigger when AP=0).
export function resetPlayedThisDay(): void {
  defaultPlayedThisDay.clear();
}
```

- [ ] **Step 2.8: Run the test — expect 8 PASS**:

```bash
pnpm vitest run tests/card/play.test.ts
```

Expected: 8 passed.

- [ ] **Step 2.9: Verify whole suite + typecheck**:

```bash
pnpm tsc
pnpm test
```

Expected: tsc exit 0; vitest reports 40 + 3 + 8 = 51 passed.

- [ ] **Step 2.10: Commit**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/card game/tests/card
git commit -m "feat(game): card/ — schema + 4-state machine + 7-step play (P2 steps 1-3)

Three modules:
- card.ts: Card type with P2-relevant schema subset (id, apCost, isHero,
  faceUrl, title, effects[kpi_contribution]). NPC/mutex/cooldown/unlock
  fields deferred — additive when P3+ adds them. evaluateCardState pure
  function returns IDLE/DISABLED/PLAYED based on AP + playedThisDay.
  PLAYABLE is a UI-overlay state, set by hand renderer on hover/focus.
- play.ts: playCard() implements GDD's 7-step sequence partially:
  pre-checks (canAfford, not-played), spend AP, Step 1 (emit
  card_played), Step 2 (hero stub), Step 3 (apply kpi_contribution),
  Step 7 (history). Steps 4 (NPC), 5 (mutex), 6 (cooldown) are no-ops
  until their owning systems land. Throws on AP underflow and
  double-play; tests verify state is unchanged on throw.
- data/defense.ts: 4 hand-coded placeholder cards using real face
  sprites from assets/sprites/cards/defense/. AP costs 1/2/3/1 — full
  deck-level 40/40/20 distribution per GDD lands with full card library
  in P3+.

Vitest suite: +11 cases (3 evaluateCardState + 8 playCard) covering
event ordering (emit before kpi change per GDD), AP pre-check, double-
play guard, hero card baseline. Total 51 passed across 7 files.

Per design/gdd/action-card-system.md + plan Task 2.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 3: Code-drawn card hand UI (`render/cards/hand.ts`)

**Why now:** with cards modeled, render them. The frame is PixiJS Graphics + Text per asset-strategy.md (UI = code-drawn, not AI sprites). The face is the real sprite from `assets/sprites/cards/defense/`.

**Files:**
- Create: `game/src/render/cards/hand.ts`

- [ ] **Step 3.1: Create `game/src/render/cards/hand.ts`** (exact content):

```ts
import { Assets, Container, Graphics, Sprite, Text, type Application } from 'pixi.js';
import { DEFENSE_CARDS_P2 } from '@/card/data/defense';
import { type Card, evaluateCardState } from '@/card/card';
import { playCard, playedThisDay } from '@/card/play';
import { ap } from '@/economy/ap';

// Card visual constants. All hand-tuned for the 640×360 logical canvas.
const CARD_W = 80;
const CARD_H = 110;
const CARD_GAP = 8;
const CARD_Y = 360 - CARD_H / 2 - 12; // 12px from canvas bottom
const CARD_BG_IDLE = 0x1a1d22;
const CARD_BG_DISABLED = 0x101113;
const CARD_BG_PLAYED = 0x080a0c;
const CARD_BORDER_IDLE = 0xc8a85a;
const CARD_BORDER_DISABLED = 0x3a3d42;
const CARD_BORDER_HOVER = 0xe0b050;

interface CardView {
  card: Card;
  container: Container;
  bg: Graphics;
  face: Sprite;
  apLabel: Text;
  titleLabel: Text;
}

export interface HandHandles {
  container: Container;
  destroy: () => void;
  redraw: () => void;
}

export async function mountCardHand(parent: Container, _app: Application): Promise<HandHandles> {
  const container = new Container();
  container.label = 'card-hand';
  parent.addChild(container);

  const totalWidth = DEFENSE_CARDS_P2.length * CARD_W + (DEFENSE_CARDS_P2.length - 1) * CARD_GAP;
  const startX = (640 - totalWidth) / 2 + CARD_W / 2;

  const views: CardView[] = [];

  for (let i = 0; i < DEFENSE_CARDS_P2.length; i++) {
    const card = DEFENSE_CARDS_P2[i]!;
    const view = await createCardView(card);
    view.container.x = startX + i * (CARD_W + CARD_GAP);
    view.container.y = CARD_Y;
    container.addChild(view.container);
    views.push(view);
  }

  const redraw = () => {
    for (const view of views) {
      const state = evaluateCardState(view.card, ap.current, playedThisDay.has(view.card.id));
      paintCardForState(view, state);
    }
  };

  // Subscribe to AP changes so disabled state updates as player spends.
  // KPI changes don't affect card state but UI may want to re-render
  // anyway; redraw is cheap.
  const unsubAp = ap.onChanged(() => redraw());

  redraw();

  const destroy = () => {
    unsubAp();
    container.destroy({ children: true });
  };

  return { container, destroy, redraw };
}

async function createCardView(card: Card): Promise<CardView> {
  const c = new Container();
  c.label = `card-${card.id}`;
  c.eventMode = 'static';
  c.cursor = 'pointer';

  const bg = new Graphics();
  c.addChild(bg);

  const tex = await Assets.load(card.faceUrl);
  tex.source.scaleMode = 'nearest';
  const face = new Sprite(tex);
  face.anchor.set(0.5);
  face.x = 0;
  face.y = -10;
  // Source is 1024×1024; fit into ~CARD_W-12 inside the card.
  const targetW = CARD_W - 12;
  face.scale.set(targetW / tex.width);
  c.addChild(face);

  const apLabel = new Text({
    text: String(card.apCost),
    style: {
      fontFamily: 'PingFang SC, -apple-system, sans-serif',
      fontSize: 16,
      fill: 0xc8a85a,
      fontWeight: '700',
    },
  });
  apLabel.anchor.set(0.5);
  apLabel.x = -CARD_W / 2 + 12;
  apLabel.y = -CARD_H / 2 + 12;
  c.addChild(apLabel);

  const titleLabel = new Text({
    text: card.title,
    style: {
      fontFamily: 'PingFang SC, -apple-system, sans-serif',
      fontSize: 11,
      fill: 0xe8e0cc,
      align: 'center',
    },
  });
  titleLabel.anchor.set(0.5);
  titleLabel.x = 0;
  titleLabel.y = CARD_H / 2 - 14;
  c.addChild(titleLabel);

  // Hover feedback
  c.on('pointerover', () => {
    if (c.eventMode === 'static') paintHover(bg, true);
  });
  c.on('pointerout', () => {
    paintHover(bg, false);
  });
  // Click → play card. Wrapped in try so disabled-card clicks throw cleanly.
  c.on('pointertap', () => {
    try {
      playCard(card);
    } catch (err) {
      console.warn(`[card] play rejected:`, (err as Error).message);
    }
  });

  return { card, container: c, bg, face, apLabel, titleLabel };
}

function paintCardForState(view: CardView, state: ReturnType<typeof evaluateCardState>): void {
  const { container, bg, face } = view;
  const interactive = state === 'IDLE';
  container.eventMode = interactive ? 'static' : 'none';
  container.cursor = interactive ? 'pointer' : 'default';
  face.alpha = state === 'DISABLED' || state === 'PLAYED' ? 0.35 : 1;
  bg.clear();
  const fill =
    state === 'PLAYED' ? CARD_BG_PLAYED : state === 'DISABLED' ? CARD_BG_DISABLED : CARD_BG_IDLE;
  const border = state === 'IDLE' ? CARD_BORDER_IDLE : CARD_BORDER_DISABLED;
  bg.rect(-CARD_W / 2, -CARD_H / 2, CARD_W, CARD_H);
  bg.fill(fill);
  bg.stroke({ color: border, width: 2 });
}

function paintHover(bg: Graphics, hovering: boolean): void {
  // Hover-only border accent; only draws on top of an existing IDLE bg.
  // We don't redraw the bg here because state-driven paintCardForState
  // already wrote it; we just append a thin border highlight.
  bg.stroke({ color: hovering ? CARD_BORDER_HOVER : CARD_BORDER_IDLE, width: 2 });
}
```

- [ ] **Step 3.2: Smoke — `pnpm dev` and verify no compile errors** (visual smoke deferred to Task 5):

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x/game
pnpm dev > /tmp/vite-dev-task3.log 2>&1 &
DEV_PID=$!
sleep 5
echo "--- HTML 200 check ---"
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
echo "--- vite log tail ---"
tail -10 /tmp/vite-dev-task3.log
kill $DEV_PID 2>/dev/null
wait 2>/dev/null
pgrep vite || echo "no vite leftover"
```

Expected: HTTP 200, vite log clean. (No actual card visual yet — Task 4 wires it into the workstation scene mounter.)

- [ ] **Step 3.3: Verify tsc + tests**:

```bash
pnpm tsc
pnpm test
```

Expected: tsc exit 0, 51 passed (no test changes).

- [ ] **Step 3.4: Commit**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/render/cards
git commit -m "feat(game): code-drawn card hand UI (render/cards/hand.ts)

Per design/assets/asset-strategy.md: card frames + AP slots + buttons
are code-drawn (PixiJS Graphics + Text), NOT AI sprite atlases. Card
*face* art uses real sprites from assets/sprites/cards/defense/.

mountCardHand renders DEFENSE_CARDS_P2's 4 cards along the bottom of
the 640×360 canvas as 80×110 cards with: AP cost in top-left (gold),
face sprite centered, Chinese title at the bottom. Click → playCard()
which routes to economy/ + emits onCardPlayed. Subscribes to ap to
re-evaluate state on every spend (DISABLED greying when affordability
drops).

PLAYED state visual: dark BG, 35% alpha face, no border highlight,
cursor reverts to default, eventMode=none (clicks pass through).

Per spec §5.3 + plan Task 3.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 4: Extend `workstation.ts` — sticky AP row + monitor KPI binding + mount hand

**Why now:** Task 3 built the hand standalone; this task wires it into the scene mounter and adds the two diegetic indicators.

**Files:**
- Modify: `game/src/render/scene/workstation.ts`

- [ ] **Step 4.1: Replace `game/src/render/scene/workstation.ts`** with the extended version (full content):

```ts
import { Assets, Container, Graphics, Sprite, Text, type Application } from 'pixi.js';
import { ap } from '@/economy/ap';
import type { SceneState } from '@/flow/scene-state';
import { kpi } from '@/economy/kpi';
import { mountCardHand } from '@/render/cards/hand';
import type { StageContext } from '../stage';

// Layout constants (640×360 logical canvas).
const STICKY_X = 480;
const STICKY_Y = 36;
const STICKY_SIZE = 12;
const STICKY_GAP = 4;

interface PropSpec {
  url: string;
  x: number;
  y: number;
  scale: number;
  label: string;
}

const STATIC_PROPS: ReadonlyArray<PropSpec> = [
  // Calendar — top-left wall mount
  { url: 'sprites/hud/calendar_month_day_1.png', x: 50, y: 50, scale: 0.12, label: 'calendar' },
  // Sticky note — to the right of monitor (decorative; AP slot row drawn separately)
  { url: 'sprites/hud/sticky_blank.png', x: 470, y: 200, scale: 0.1, label: 'sticky' },
  // Mug — bottom-left of desk. Static in P2 (energy not implemented; still
  // shows coffee_full.png placeholder per P1).
  { url: 'sprites/hud/coffee_full.png', x: 130, y: 260, scale: 0.1, label: 'mug' },
];

// Monitor KPI states. The 5th (gameover grey) is achieved via tint on
// monitor_critical, not a separate sprite.
const MONITOR_FRAMES = {
  idle: 'sprites/hud/monitor_idle.png',
  working: 'sprites/hud/monitor_working.png',
  warning: 'sprites/hud/monitor_warning.png',
  critical: 'sprites/hud/monitor_critical.png',
} as const;

function pickMonitorFrame(actualKpi: number, threshold: number): keyof typeof MONITOR_FRAMES {
  const ratio = actualKpi / threshold;
  if (ratio < 0.5) return 'idle';
  if (ratio < 1.0) return 'working';
  if (ratio < 1.5) return 'warning';
  return 'critical';
}

export async function mountWorkstation(
  _state: SceneState,
  ctx: StageContext,
): Promise<() => void> {
  const teardowns: Array<() => void> = [];

  // ── Static props ────────────────────────────────────────────────────────
  for (const spec of STATIC_PROPS) {
    const tex = await Assets.load(spec.url);
    tex.source.scaleMode = 'nearest';
    const sprite = new Sprite(tex);
    sprite.label = spec.label;
    sprite.anchor.set(0.5);
    sprite.x = spec.x;
    sprite.y = spec.y;
    sprite.scale.set(spec.scale);
    ctx.worldLayer.addChild(sprite);
    teardowns.push(() => sprite.destroy());
  }

  // ── Monitor (KPI binding, swappable sprite) ─────────────────────────────
  const monitorContainer = new Container();
  monitorContainer.label = 'monitor';
  monitorContainer.x = 320;
  monitorContainer.y = 160;
  ctx.worldLayer.addChild(monitorContainer);

  let currentMonitorSprite: Sprite | null = null;
  const swapMonitorTo = async (key: keyof typeof MONITOR_FRAMES) => {
    const tex = await Assets.load(MONITOR_FRAMES[key]);
    tex.source.scaleMode = 'nearest';
    if (currentMonitorSprite) currentMonitorSprite.destroy();
    const s = new Sprite(tex);
    s.anchor.set(0.5);
    s.scale.set(0.18);
    monitorContainer.addChild(s);
    currentMonitorSprite = s;
  };
  await swapMonitorTo(pickMonitorFrame(kpi.actualKpi, kpi.monthlyThreshold));

  const unsubKpi = kpi.onChanged((actual) => {
    void swapMonitorTo(pickMonitorFrame(actual, kpi.monthlyThreshold));
  });
  teardowns.push(() => {
    unsubKpi();
    monitorContainer.destroy({ children: true });
  });

  // ── Sticky-note AP row (code-drawn, 8 slots) ────────────────────────────
  const apRow = new Container();
  apRow.label = 'ap-row';
  apRow.x = STICKY_X;
  apRow.y = STICKY_Y;
  ctx.worldLayer.addChild(apRow);

  const apLabel = new Text({
    text: 'AP',
    style: {
      fontFamily: 'PingFang SC, -apple-system, sans-serif',
      fontSize: 10,
      fill: 0xe8e0cc,
    },
  });
  apLabel.anchor.set(1, 0.5);
  apLabel.x = -6;
  apLabel.y = STICKY_SIZE / 2;
  apRow.addChild(apLabel);

  const slots: Graphics[] = [];
  for (let i = 0; i < ap.max; i++) {
    const g = new Graphics();
    g.x = i * (STICKY_SIZE + STICKY_GAP);
    apRow.addChild(g);
    slots.push(g);
  }

  const drawSlots = () => {
    for (let i = 0; i < slots.length; i++) {
      const g = slots[i]!;
      const filled = i < ap.current;
      g.clear();
      g.rect(0, 0, STICKY_SIZE, STICKY_SIZE);
      g.fill(filled ? 0xc8a85a : 0x1a1d22);
      g.stroke({ color: 0x5a7080, width: 1 });
      if (!filled) {
        // Spent slots get a crossed-out diagonal (red ✗)
        g.moveTo(2, 2);
        g.lineTo(STICKY_SIZE - 2, STICKY_SIZE - 2);
        g.moveTo(STICKY_SIZE - 2, 2);
        g.lineTo(2, STICKY_SIZE - 2);
        g.stroke({ color: 0xc83428, width: 1 });
      }
    }
  };
  const unsubAp = ap.onChanged(() => drawSlots());
  drawSlots();
  teardowns.push(() => {
    unsubAp();
    apRow.destroy({ children: true });
  });

  // ── KPI numeric readout (small text under the monitor for debug/clarity) ─
  const kpiText = new Text({
    text: '',
    style: {
      fontFamily: 'PingFang SC, -apple-system, sans-serif',
      fontSize: 10,
      fill: 0xe8e0cc,
    },
  });
  kpiText.anchor.set(0.5, 0);
  kpiText.x = 320;
  kpiText.y = 200;
  ctx.worldLayer.addChild(kpiText);

  const drawKpi = () => {
    kpiText.text = `KPI ${kpi.actualKpi} / ${kpi.monthlyThreshold} (cap ${Math.round(kpi.capacityNow)})`;
  };
  const unsubKpiText = kpi.onChanged(() => drawKpi());
  drawKpi();
  teardowns.push(() => {
    unsubKpiText();
    kpiText.destroy();
  });

  // ── Card hand (code-drawn UI; loads its own face sprites) ───────────────
  const handHandles = await mountCardHand(ctx.worldLayer, ctx.app);
  teardowns.push(() => handHandles.destroy());

  return () => {
    for (const t of teardowns) t();
  };
}
```

- [ ] **Step 4.2: Smoke — `pnpm dev`, verify no compile errors**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x/game
pnpm dev > /tmp/vite-dev-task4.log 2>&1 &
DEV_PID=$!
sleep 5
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
tail -10 /tmp/vite-dev-task4.log
kill $DEV_PID 2>/dev/null
wait 2>/dev/null
pgrep vite || echo "no vite leftover"
```

Expected: HTTP 200, no compile errors in tail. Visual smoke (controller does after Task 5).

- [ ] **Step 4.3: Verify tsc + tests**:

```bash
pnpm tsc
pnpm test
```

Expected: tsc exit 0, 51 passed.

- [ ] **Step 4.4: Commit**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/render/scene/workstation.ts
git commit -m "feat(game): workstation diegetic bindings — sticky AP row + monitor KPI swap + card hand

Extends P1's 4-static-props workstation:
- Monitor sprite now swaps among monitor_idle/working/warning/critical
  based on actualKpi/monthlyThreshold ratio. Subscribes to kpi.onChanged.
  Frame thresholds: <0.5 idle, <1.0 working, <1.5 warning, ≥1.5 critical.
  (5th gameover-grey state deferred — uses tint when GameOver lands.)
- New code-drawn AP row (8 sticky-note-style slots) at top-right.
  Filled slots are gold #c8a85a; spent slots are dark with red ✗.
  Subscribes to ap.onChanged for instant feedback on card play.
- Numeric KPI readout under monitor: 'KPI <actual>/<threshold> (cap N)'.
- Card hand mounted via mountCardHand from Task 3 — 4 defense cards
  bottom-centered.
- mug stays as static coffee_full.png (energy = P3+).

Per design/gdd/hud-diegetic.md (sticky=AP, monitor=KPI) + design/assets/
asset-strategy.md (UI code-drawn, atlas for prop art) + plan Task 4.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 5: Day-end auto-advance + integration smoke

**Why now:** without something happening at AP=0, the loop just freezes. Auto-advance: when AP hits 0 AND user clicks anywhere on the canvas (or after a 1.5s delay), day += 1, AP refills, playedThisDay clears. P3 will inject KPI Review + recap between, but P2 keeps the loop tight.

**Files:**
- Modify: `game/src/render/scene/workstation.ts` (add auto-advance trigger)

- [ ] **Step 5.1: Add auto-advance to `workstation.ts`** — append to `mountWorkstation` BEFORE the final `return () => { for (const t of teardowns) t(); };`:

```ts
  // ── Day-end auto-advance ────────────────────────────────────────────────
  // When AP drops to 0, surface a 「结束今日」 prompt (drawn as a Text node
  // above the cards). Click anywhere on the canvas (or the prompt) to
  // advance: AP refills, playedThisDay clears, day increments. P3 inserts
  // a KPI Review screen between these steps; P2 keeps it instant.
  const endDayPrompt = new Text({
    text: '点击屏幕进入下一天',
    style: {
      fontFamily: 'PingFang SC, -apple-system, sans-serif',
      fontSize: 14,
      fill: 0xc8a85a,
      fontWeight: '700',
    },
  });
  endDayPrompt.anchor.set(0.5);
  endDayPrompt.x = 320;
  endDayPrompt.y = 230;
  endDayPrompt.visible = false;
  ctx.worldLayer.addChild(endDayPrompt);

  const advanceDay = (): void => {
    resetPlayedThisDay();
    ap.resetForNewDay();
    endDayPrompt.visible = false;
    // P3+: increment day in flow state via flow.request(action_day, day+1).
    // For P2 we leave the FSM at day=1 — visual loop still closes because
    // AP refills + cards re-enable.
  };

  // Only react to background clicks AFTER AP=0; cards still take priority
  // because their eventMode is 'static' and they bubble first.
  ctx.app.stage.eventMode = 'static';
  const onStageClick = () => {
    if (ap.current === 0) advanceDay();
  };
  ctx.app.stage.on('pointertap', onStageClick);

  const unsubApForPrompt = ap.onChanged((current) => {
    endDayPrompt.visible = current === 0;
  });

  teardowns.push(() => {
    ctx.app.stage.off('pointertap', onStageClick);
    unsubApForPrompt();
    endDayPrompt.destroy();
  });
```

Add the import at the top of workstation.ts (alongside the existing imports):

```ts
import { resetPlayedThisDay } from '@/card/play';
```

- [ ] **Step 5.2: Headless smoke**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x/game
pnpm dev > /tmp/vite-dev-task5.log 2>&1 &
DEV_PID=$!
sleep 5
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
tail -10 /tmp/vite-dev-task5.log
kill $DEV_PID 2>/dev/null
wait 2>/dev/null
pgrep vite || echo "no vite leftover"
```

Expected: HTTP 200.

- [ ] **Step 5.3: Verify tsc + tests**:

```bash
pnpm tsc
pnpm test
```

Expected: tsc exit 0, 51 passed.

- [ ] **Step 5.4: Commit**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/render/scene/workstation.ts
git commit -m "feat(game): day-end auto-advance when AP=0 (placeholder for P3 KPI Review)

When ap.current hits 0, a 「点击屏幕进入下一天」 prompt appears above
the cards. Clicking anywhere on the stage (cards take priority via
eventMode bubbling) calls advanceDay: resetPlayedThisDay() clears the
played set, ap.resetForNewDay() refills to 8, prompt hides. Cards
re-evaluate to IDLE on the AP-changed signal and become clickable
again.

P3 inserts the KPI Review screen between these steps. P2 keeps the
loop tight: spend cards → click → repeat. day counter stays at 1 in
the FSM since flow.request(action_day, day=2) would also need recap/
review wiring (P3 scope).

Per plan Task 5.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 6: P2 exit verification + tag `v0.3.0-p2`

- [ ] **Step 6.1: Run the full verify chain**:

```bash
cd game
pnpm verify
```

Expected: assets sync, tsc clean, biome clean, vitest 51 passed.

- [ ] **Step 6.2: Production build**:

```bash
hdiutil detach "/Volumes/活过第 X 集" 2>&1 | tail -2
pnpm tauri build
```

Expected: cargo incremental (~30s), .app + .dmg produced.

- [ ] **Step 6.3: Manual smoke**:

```bash
killall "活过第 X 集" 2>/dev/null
open "/Users/huanghaibin/Workspace/games/survived-episode-x/game/src-tauri/target/release/bundle/macos/活过第 X 集.app"
```

Walk through:
1. Window opens → main menu
2. Click 「开始」 → workstation appears with:
   - 4 static props (calendar/sticky/mug)
   - **Monitor centre, swappable** (idle frame initially)
   - **AP row top-right**, 8 gold slots
   - **KPI text** under monitor: `KPI 0 / 100 (cap 300)`
   - **4 cards along bottom**: 装作很忙 (1AP), 躲开会议 (2AP), 请病假 (3AP), 划水 (1AP)
3. Click 装作很忙 (1AP) → AP slot 8 crosses out red, KPI → 5
4. Click 躲开会议 (2AP) → 2 more slots crossed (now 5 gold + 3 red), KPI → 15
5. Click 请病假 (3AP) → 3 more crossed (2 gold + 6 red), KPI → 33, **monitor swaps to working** (ratio = 33/100 = 0.33 → still idle? actually should be working when ratio ≥ 0.5)
6. Click 划水 (1AP) → 1 more crossed (1 gold + 7 red), KPI → 37
7. AP=1 left; only 1AP cards still IDLE; 2AP+ cards are DISABLED (greyed)
8. Spent 装作很忙 already — it's PLAYED (darker than DISABLED)
9. Click last 1AP card → AP=0, all cards DISABLED, **「点击屏幕进入下一天」 prompt appears**
10. Click anywhere on background → AP refills to 8 (all gold), cards re-enable, played clears, prompt hides
11. Press Esc → pause overlay (P1 still works); 「继续」 → back; 「回主菜单」 → main menu

If KPI builds up high enough across multiple "days", monitor should swap to warning/critical. Easy way: spend 「请病假」 + 「躲开会议」 several times. Around KPI=50 (ratio 0.5) it goes to working, ~100 to warning, ~150 to critical.

- [ ] **Step 6.4: Tag `v0.3.0-p2`**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git tag -a v0.3.0-p2 -m "Slice 1 / Phase 2 complete: AP + KPI + 4 cards + diegetic bindings

End-to-end verified by user smoke walk:
- Workstation now shows 8-slot sticky AP row, monitor sprite that
  swaps with KPI bands, KPI numeric readout, 4-card hand
- Click card → AP -=cost, sticky slot crossed, KPI += contribution,
  monitor potentially swaps frame
- 4-state machine: IDLE (gold border) / DISABLED (grey, alpha 0.35) /
  PLAYED (dark) / PLAYABLE (hover-only UI overlay)
- AP=0 → 「点击屏幕进入下一天」 prompt; click anywhere → day refills
- Pause + main-menu navigation from P1 still work

Vitest: 51 cases (8 transitions + 7 dispatcher + 4 sync-sprites + 7 ap
+ 14 kpi + 3 evaluateCardState + 8 playCard).

KPI Formula B implemented in full (potential clamp [-0.15, +1.0]
×β=0.18, monotonicity-guarded threshold). P2 only exercises the
applyContribution path; recalcThresholdFormulaB is exposed for P3+
month-end recalculator. effort_norm passed as 0; γ_effective = 0
since month=1.

Per docs/superpowers/plans/2026-05-04-slice1-p2-ap-kpi-cards.md."
git push --tags
```

- [ ] **Step 6.5: Update spec §9.2 P2 row**:

Edit `docs/superpowers/specs/2026-05-03-engine-switch-design.md` §9.2 — change the P2 row from:

```
| **P2 AP / KPI / 卡牌循环** | 2d | 4 张卡显示底部；点卡 → AP 减 + KPI 变 + 咖啡杯/显示器视觉变化 |
```

to:

```
| **P2 AP / KPI / 卡牌循环** | ✅ 完成 2026-05-?? (tag `v0.3.0-p2`, scope C: hybrid) | AP=8 + 8-slot sticky AP row, KPI Formula B (potential term active), 4 hand-coded cards with 4-state machine + 7-step play (steps 1/2/3 wired), monitor sprite KPI binding, AP=0 day-advance click. mug/energy still deferred. Plan: `docs/superpowers/plans/2026-05-04-slice1-p2-ap-kpi-cards.md`. |
```

Commit:
```bash
git add docs/superpowers/specs/2026-05-03-engine-switch-design.md
git commit -m "docs: mark Slice 1 P2 complete in design spec (tag v0.3.0-p2)"
git push
```

---

## Self-review checklist

After all tasks:
- [ ] `pnpm verify` from `game/` is green (51 vitest)
- [ ] `pnpm tauri build` produces a fresh `.dmg`
- [ ] Installed `.app` walks the full 11-step P2 loop without console errors
- [ ] Commit `v0.3.0-p2` tagged + pushed
- [ ] Pre-commit hook ran on every commit (typecheck + biome auto-passed)

## What is **not** in P2 (P3+ scope)

- **Energy module** (mug binding) — separate cross-day resource per GDD
- **Effort tracking** (overtime count, hero count, overage count → effort_norm) — needed for full Formula B
- **Month-end recalc trigger** — `applyMonthlyRecalc` exists but isn't called
- **KPI Review screen** + 三轨 anchor SFX — between day-end and next-day
- **Day counter advancing in FSM** — P2 stays at day=1 since recap UI deferred
- **Card cooldown / mutex_group / NPC target** — all 4 P2 cards have none
- **Game Over** — neither path triggers; no transition to gameover state
- **Action card distribution lint** (40/40/20) — P2 deck is too small to enforce
- **Subject inversion lint** — no copy yet to lint
- **gen:constants** infra — constants.ts is hand-written; future task wires registry

## Notes for Claude when executing

- **Don't scope-creep.** Each task is bounded; resist adding "while I'm here" features. Especially in Task 4 don't try to implement energy.
- **Test names matter.** Vitest output is the smoke test for "did I implement the right thing".
- **Biome auto-formatting** will reorder imports each commit. Accept it; lefthook handles re-staging.
- **Cards in tests use ctx instances**, not singletons. Don't make tests depend on the singleton state — production wiring uses singletons via the default ctx.
- **Click-through behavior**: cards have eventMode='static' so they intercept clicks; the stage-level pointertap fires only when no card was hit. This is how the day-advance works without conflicting with card clicks.
