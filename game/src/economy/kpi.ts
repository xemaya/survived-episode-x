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
