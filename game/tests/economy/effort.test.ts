import { beforeEach, describe, expect, it } from 'vitest';
import { EffortSystem } from '../../src/economy/effort';
import { computeEffortNorm } from '../../src/economy/kpi';

describe('EffortSystem (Bug #27 — replaces ApSystem effort half)', () => {
  let effort: EffortSystem;

  beforeEach(() => {
    effort = new EffortSystem();
  });

  it('starts with all effort counters at 0', () => {
    expect(effort.effortOvertime).toBe(0);
    expect(effort.effortHero).toBe(0);
    expect(effort.effortOverage).toBe(0);
  });

  it('reportOvertime increments effortOvertime by 1', () => {
    effort.reportOvertime();
    effort.reportOvertime();
    expect(effort.effortOvertime).toBe(2);
    expect(effort.effortHero).toBe(0);
    expect(effort.effortOverage).toBe(0);
  });

  it('reportHeroCardPlayed increments effortHero by 1', () => {
    effort.reportHeroCardPlayed();
    expect(effort.effortHero).toBe(1);
    expect(effort.effortOvertime).toBe(0);
    expect(effort.effortOverage).toBe(0);
  });

  it('reportOverage increments effortOverage by 1', () => {
    effort.reportOverage();
    effort.reportOverage();
    effort.reportOverage();
    expect(effort.effortOverage).toBe(3);
    expect(effort.effortOvertime).toBe(0);
    expect(effort.effortHero).toBe(0);
  });

  it('resetEffortCounters zeros all three counters', () => {
    effort.reportOvertime();
    effort.reportHeroCardPlayed();
    effort.reportOverage();
    effort.resetEffortCounters();
    expect(effort.effortOvertime).toBe(0);
    expect(effort.effortHero).toBe(0);
    expect(effort.effortOverage).toBe(0);
  });

  it('setEffortForRestore sets all three counters', () => {
    effort.setEffortForRestore(5, 3, 7);
    expect(effort.effortOvertime).toBe(5);
    expect(effort.effortHero).toBe(3);
    expect(effort.effortOverage).toBe(7);
  });
});

describe('computeEffortNorm', () => {
  it('all zeros → 0', () => {
    expect(computeEffortNorm(0, 0, 0)).toBe(0);
  });

  it('max values → 0.95 (sum of weights: 0.45+0.20+0.30)', () => {
    // overtime=20, hero=10, overage=10 → each norm=1.0 → 0.45+0.20+0.30=0.95
    expect(computeEffortNorm(20, 10, 10)).toBeCloseTo(0.95, 10);
  });

  it('clamps overtime independently — overtime beyond cap still gives max otNorm', () => {
    expect(computeEffortNorm(40, 0, 0)).toBeCloseTo(0.45, 10);
  });

  it('clamps hero independently', () => {
    expect(computeEffortNorm(0, 100, 0)).toBeCloseTo(0.2, 10);
  });

  it('clamps overage independently', () => {
    expect(computeEffortNorm(0, 0, 100)).toBeCloseTo(0.3, 10);
  });

  it('partial values: overtime=10/20, hero=5/10 → expected weighted sum', () => {
    expect(computeEffortNorm(10, 5, 0)).toBeCloseTo(0.325, 10);
  });

  it('result is capped at 0.95 even with inputs summing past it', () => {
    expect(computeEffortNorm(20, 10, 10)).toBeLessThanOrEqual(0.95);
  });

  it('overtime-only contribution is proportional', () => {
    expect(computeEffortNorm(10, 0, 0)).toBeCloseTo(0.225, 10);
  });
});
