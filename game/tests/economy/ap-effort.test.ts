import { beforeEach, describe, expect, it } from 'vitest';
import { ApSystem } from '../../src/economy/ap';
import { computeEffortNorm } from '../../src/economy/kpi';

describe('ApSystem effort counters', () => {
  let ap: ApSystem;

  beforeEach(() => {
    ap = new ApSystem();
  });

  it('starts with all effort counters at 0', () => {
    expect(ap.effortOvertime).toBe(0);
    expect(ap.effortHero).toBe(0);
    expect(ap.effortOverage).toBe(0);
  });

  it('reportOvertime increments effortOvertime by 1', () => {
    ap.reportOvertime();
    ap.reportOvertime();
    expect(ap.effortOvertime).toBe(2);
    expect(ap.effortHero).toBe(0);
    expect(ap.effortOverage).toBe(0);
  });

  it('reportHeroCardPlayed increments effortHero by 1', () => {
    ap.reportHeroCardPlayed();
    expect(ap.effortHero).toBe(1);
    expect(ap.effortOvertime).toBe(0);
    expect(ap.effortOverage).toBe(0);
  });

  it('reportOverage increments effortOverage by 1', () => {
    ap.reportOverage();
    ap.reportOverage();
    ap.reportOverage();
    expect(ap.effortOverage).toBe(3);
    expect(ap.effortOvertime).toBe(0);
    expect(ap.effortHero).toBe(0);
  });

  it('resetEffortCounters zeros all three counters', () => {
    ap.reportOvertime();
    ap.reportHeroCardPlayed();
    ap.reportOverage();
    ap.resetEffortCounters();
    expect(ap.effortOvertime).toBe(0);
    expect(ap.effortHero).toBe(0);
    expect(ap.effortOverage).toBe(0);
  });

  it('setEffortForRestore sets all three counters', () => {
    ap.setEffortForRestore(5, 3, 7);
    expect(ap.effortOvertime).toBe(5);
    expect(ap.effortHero).toBe(3);
    expect(ap.effortOverage).toBe(7);
  });

  it('effort counters are independent of AP spend/resetForNewDay', () => {
    ap.reportOvertime();
    ap.reportHeroCardPlayed();
    ap.spend(4);
    ap.resetForNewDay();
    // AP reset should not affect effort counters
    expect(ap.effortOvertime).toBe(1);
    expect(ap.effortHero).toBe(1);
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
    // overtime=40 (double cap), hero=0, overage=0 → should give same as overtime=20
    expect(computeEffortNorm(40, 0, 0)).toBeCloseTo(0.45, 10);
  });

  it('clamps hero independently', () => {
    // hero=100 (10x cap) → heroNorm clamped to 1.0 → weight 0.20
    expect(computeEffortNorm(0, 100, 0)).toBeCloseTo(0.2, 10);
  });

  it('clamps overage independently', () => {
    expect(computeEffortNorm(0, 0, 100)).toBeCloseTo(0.3, 10);
  });

  it('partial values: overtime=10/20, hero=5/10 → expected weighted sum', () => {
    // otNorm = 0.5, heroNorm = 0.5, ovNorm = 0
    // 0.45*0.5 + 0.20*0.5 + 0.30*0 = 0.225 + 0.10 = 0.325
    expect(computeEffortNorm(10, 5, 0)).toBeCloseTo(0.325, 10);
  });

  it('result is capped at 0.95 even with inputs summing past it', () => {
    // overtime=20, hero=10, overage=10 → already 0.95; add more still 0.95
    expect(computeEffortNorm(20, 10, 10)).toBeLessThanOrEqual(0.95);
  });

  it('overtime-only contribution is proportional', () => {
    // overtime=10 (half cap) → 0.45 * 0.5 = 0.225
    expect(computeEffortNorm(10, 0, 0)).toBeCloseTo(0.225, 10);
  });
});
