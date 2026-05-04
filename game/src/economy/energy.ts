import {
  ENERGY_INITIAL,
  ENERGY_MAX,
  ENERGY_OT_BASE,
  ENERGY_OVERTIME_GUARD,
  ENERGY_REGEN_PER_DAY,
} from './constants';

export type EnergyListener = (current: number, delta: number) => void;

// design/gdd/ap-economy-system.md energy section. Cross-day [0,100],
// drained by overtime, restored by early-leave + weekend rest.
// burnoutFlag persists across recovery — prevents overtime spam after
// hitting 0 once. Cleared explicitly (e.g. on month-end if design wants
// — TBD per GDD; P4 keeps it persistent until manual clearBurnout()).
export class EnergySystem {
  private value: number = ENERGY_INITIAL;
  private burnout = false;
  private listeners = new Set<EnergyListener>();

  get current(): number {
    return this.value;
  }
  get max(): number {
    return ENERGY_MAX;
  }
  get burnoutFlag(): boolean {
    return this.burnout;
  }

  canOvertime(): boolean {
    return !this.burnout && this.value >= ENERGY_OVERTIME_GUARD;
  }

  change(delta: number): void {
    const next = Math.max(0, Math.min(ENERGY_MAX, this.value + delta));
    const actualDelta = next - this.value;
    this.value = next;
    if (next === 0) this.burnout = true;
    for (const l of this.listeners) l(this.value, actualDelta);
  }

  regenForRestDay(): void {
    this.change(ENERGY_REGEN_PER_DAY);
  }

  reportOvertime(): void {
    this.change(-ENERGY_OT_BASE);
  }

  clearBurnout(): void {
    this.burnout = false;
  }

  // Used by save/restore; bypasses change() so the burnout flag is
  // restored independently of value (player could be at energy=50 with
  // burnoutFlag=true if they recovered after a previous burnout).
  setForRestore(value: number, burnout: boolean): void {
    this.value = Math.max(0, Math.min(ENERGY_MAX, value));
    this.burnout = burnout;
  }

  onChanged(fn: EnergyListener): () => void {
    this.listeners.add(fn);
    let unsubscribed = false;
    return () => {
      if (unsubscribed) return;
      unsubscribed = true;
      this.listeners.delete(fn);
    };
  }
}

export const energy = new EnergySystem();
