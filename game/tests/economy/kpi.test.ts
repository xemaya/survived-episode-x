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
