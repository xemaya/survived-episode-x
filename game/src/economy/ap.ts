import { BASE_AP_PER_DAY, OVERTIME_BONUS_AP } from './constants';

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

  // Effort accumulators — per GDD ap-economy-system.md §effort-tracking.
  // Reset monthly at month-end AFTER applyMonthlyRecalc (so the gameover
  // snapshot path captures them). Counters do NOT emit apChanged; they are
  // a separate reporting channel.
  private _effortOvertime = 0;
  private _effortHero = 0;
  private _effortOverage = 0;

  get effortOvertime(): number {
    return this._effortOvertime;
  }
  get effortHero(): number {
    return this._effortHero;
  }
  get effortOverage(): number {
    return this._effortOverage;
  }

  // Called when player declares overtime for the day.
  reportOvertime(): void {
    this._effortOvertime += 1;
  }

  // Called when a card with isHero=true is played.
  reportHeroCardPlayed(): void {
    this._effortHero += 1;
  }

  // Called when a card causes a KPI overage (Task 6+).
  // Exposed now for API completeness; no callers yet.
  reportOverage(): void {
    this._effortOverage += 1;
  }

  // Resets all three counters to 0. Called at month-end AFTER recalc + game-
  // over checks (pass branch only — gameover branch must snapshot them first).
  resetEffortCounters(): void {
    this._effortOvertime = 0;
    this._effortHero = 0;
    this._effortOverage = 0;
  }

  // Used by restore.ts to reinstate saved effort state on boot.
  setEffortForRestore(overtime: number, hero: number, overage: number): void {
    this._effortOvertime = overtime;
    this._effortHero = hero;
    this._effortOverage = overage;
  }

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
        `AP underflow: tried to spend ${n} but only ${this.value} available. Caller must canAfford() first.`,
      );
    }
    this.value -= n;
    for (const l of this.listeners) l(this.value, -n);
  }

  // GDD ap-economy-system Rule 4: overtime is the ONE exception to the
  // spend-only invariant within a day. Grants up to OVERTIME_BONUS_AP extra
  // AP on top of the base, capped at BASE_AP_PER_DAY + OVERTIME_BONUS_AP = 10.
  // This must NEVER be called outside the overtime grant path (confirmAfterWork).
  grantOvertime(extraAp: number): void {
    if (extraAp <= 0) return;
    this.value = Math.min(BASE_AP_PER_DAY + OVERTIME_BONUS_AP, this.value + extraAp);
    for (const l of this.listeners) l(this.value, extraAp);
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
