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

  // Stub fields for snapshot/restore plumbing; real wiring lands in Task 4.
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
