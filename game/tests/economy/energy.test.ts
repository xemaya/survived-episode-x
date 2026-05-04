import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  ENERGY_INITIAL,
  ENERGY_MAX,
  ENERGY_OT_BASE,
  ENERGY_OVERTIME_GUARD,
  ENERGY_REGEN_PER_DAY,
} from '../../src/economy/constants';
import { EnergySystem } from '../../src/economy/energy';

describe('EnergySystem', () => {
  let energy: EnergySystem;

  beforeEach(() => {
    energy = new EnergySystem();
  });

  it('starts at ENERGY_INITIAL with no burnout', () => {
    expect(energy.current).toBe(ENERGY_INITIAL);
    expect(energy.burnoutFlag).toBe(false);
  });

  it('change(+n) increases and clamps at ENERGY_MAX', () => {
    energy.change(50);
    expect(energy.current).toBe(ENERGY_MAX);
  });

  it('change(-n) decreases and clamps at 0; sets burnoutFlag at exactly 0', () => {
    energy.change(-ENERGY_INITIAL);
    expect(energy.current).toBe(0);
    expect(energy.burnoutFlag).toBe(true);
  });

  it('emits onChanged with new value and delta', () => {
    const listener = vi.fn();
    energy.onChanged(listener);
    energy.change(-10);
    expect(listener).toHaveBeenCalledWith(ENERGY_INITIAL - 10, -10);
  });

  it('canOvertime() returns false if energy < ENERGY_OVERTIME_GUARD', () => {
    energy.change(-(ENERGY_INITIAL - ENERGY_OVERTIME_GUARD + 1)); // just below guard
    expect(energy.canOvertime()).toBe(false);
    energy.change(1); // back at guard
    expect(energy.canOvertime()).toBe(true);
  });

  it('canOvertime() returns false if burnoutFlag (even if recovered above guard)', () => {
    energy.change(-ENERGY_INITIAL);
    expect(energy.burnoutFlag).toBe(true);
    energy.change(50); // recovered, but flag persists
    expect(energy.canOvertime()).toBe(false);
  });

  it('clearBurnout() resets the flag', () => {
    energy.change(-ENERGY_INITIAL);
    energy.change(50);
    energy.clearBurnout();
    expect(energy.canOvertime()).toBe(true);
  });

  it('regenForRestDay() adds ENERGY_REGEN_PER_DAY (clamped)', () => {
    energy.change(-50); // 80 - 50 = 30
    energy.regenForRestDay();
    expect(energy.current).toBe(30 + ENERGY_REGEN_PER_DAY);
  });

  it('reportOvertime() drains ENERGY_OT_BASE (called by AFTER_WORK)', () => {
    energy.reportOvertime();
    expect(energy.current).toBe(ENERGY_INITIAL - ENERGY_OT_BASE);
  });

  it('setForRestore(value) directly sets value; preserves burnoutFlag separately', () => {
    energy.setForRestore(50, true);
    expect(energy.current).toBe(50);
    expect(energy.burnoutFlag).toBe(true);
  });

  it('unsubscribe stops emissions', () => {
    const listener = vi.fn();
    const unsub = energy.onChanged(listener);
    energy.change(-1);
    unsub();
    energy.change(-1);
    expect(listener).toHaveBeenCalledTimes(1);
  });
});
