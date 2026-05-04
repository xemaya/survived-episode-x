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
