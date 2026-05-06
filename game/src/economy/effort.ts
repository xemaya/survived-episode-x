// Effort counter system — overtime / hero / overage tallies that feed
// the monthly KPI Review recap. Replaces the effort half of the
// pre-pivot AP module (Bug #27 — design pivot deleted the AP system
// itself but kept these counters as KPI Review inputs).
//
// Per GDD ap-economy-system.md §effort-tracking: counters reset
// monthly at month-end AFTER applyMonthlyRecalc + game-over checks
// (so the gameover snapshot path captures them). Counters do NOT emit
// any change events — they're a separate reporting channel from the
// AP/KPI/energy domain emitters.

export class EffortSystem {
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

  /** Called when the player declares overtime for the day. */
  reportOvertime(): void {
    this._effortOvertime += 1;
  }

  /** Called when a card with isHero=true is played (P0–P4 card era —
   * may be re-purposed for ink-side `# hero_card` tag in P6). */
  reportHeroCardPlayed(): void {
    this._effortHero += 1;
  }

  /** Called when a card causes a KPI overage. Exposed for API
   * completeness; no callers yet in the AVG flow. */
  reportOverage(): void {
    this._effortOverage += 1;
  }

  /** Reset all three counters. Called at month-end pass branch AFTER
   * recalc + game-over checks (gameover branch must snapshot first). */
  resetEffortCounters(): void {
    this._effortOvertime = 0;
    this._effortHero = 0;
    this._effortOverage = 0;
  }

  /** Used by restore.ts to reinstate saved effort state on boot. */
  setEffortForRestore(overtime: number, hero: number, overage: number): void {
    this._effortOvertime = overtime;
    this._effortHero = hero;
    this._effortOverage = overage;
  }
}

/** Singleton — production import goes through this instance. */
export const effort = new EffortSystem();
