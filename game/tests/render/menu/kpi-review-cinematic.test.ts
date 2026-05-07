import { describe, expect, it } from 'vitest';
import {
  HR_SPEAK_FALLBACK,
  PRE_REVEAL_MS,
  REVEAL_ROWS,
  REVEAL_ROW_MS,
  inferPathFromKpi,
  kpiReviewCinematic,
} from '../../../src/render/menu/kpi-review-cinematic';

describe('inferPathFromKpi (Q-Q / Bug #31)', () => {
  it('promotion candidate count >= 3 → path d', () => {
    expect(inferPathFromKpi(50, 100, 3)).toBe('d');
    expect(inferPathFromKpi(150, 100, 5)).toBe('d');
  });

  it('ratio < 0.5 → path e (red line)', () => {
    expect(inferPathFromKpi(45, 100, 0)).toBe('e');
  });

  it('ratio in [0.5, 1.0) → path c (below threshold)', () => {
    expect(inferPathFromKpi(75, 100, 0)).toBe('c');
    expect(inferPathFromKpi(99, 100, 0)).toBe('c');
  });

  it('ratio in [1.0, 1.2) → path b (just-passed)', () => {
    expect(inferPathFromKpi(100, 100, 0)).toBe('b');
    expect(inferPathFromKpi(119, 100, 0)).toBe('b');
  });

  it('ratio >= 1.2 → path a (high effort)', () => {
    expect(inferPathFromKpi(120, 100, 0)).toBe('a');
    expect(inferPathFromKpi(200, 100, 0)).toBe('a');
  });

  it('zero threshold defaults to path e (degenerate ratio = 0)', () => {
    expect(inferPathFromKpi(50, 0, 0)).toBe('e');
  });

  it('promotion path d wins over high ratio (5 cumulative months over)', () => {
    expect(inferPathFromKpi(200, 100, 6)).toBe('d');
  });
});

describe('kpiReviewCinematic singleton', () => {
  it('starts with no path captured', () => {
    kpiReviewCinematic.reset();
    expect(kpiReviewCinematic.path).toBeNull();
  });

  it('setPath captures valid keys a/b/c/d/e (case-insensitive)', () => {
    kpiReviewCinematic.reset();
    kpiReviewCinematic.setPath('a');
    expect(kpiReviewCinematic.path).toBe('a');
    kpiReviewCinematic.setPath('B');
    expect(kpiReviewCinematic.path).toBe('b');
    kpiReviewCinematic.setPath('  e  ');
    expect(kpiReviewCinematic.path).toBe('e');
  });

  it('setPath ignores unknown keys (path stays previous value)', () => {
    kpiReviewCinematic.reset();
    kpiReviewCinematic.setPath('a');
    kpiReviewCinematic.setPath('z');
    expect(kpiReviewCinematic.path).toBe('a');
  });

  it('reset clears the captured path', () => {
    kpiReviewCinematic.setPath('a');
    kpiReviewCinematic.reset();
    expect(kpiReviewCinematic.path).toBeNull();
  });

  it('fallback returns prose for each path', () => {
    expect(kpiReviewCinematic.fallback('a')).toBe(HR_SPEAK_FALLBACK.a);
    expect(kpiReviewCinematic.fallback('e')).toBe(HR_SPEAK_FALLBACK.e);
  });
});

describe('cinematic timing constants', () => {
  it('pre-reveal pause is non-zero (anticipation beat per spec §2.5)', () => {
    expect(PRE_REVEAL_MS).toBeGreaterThanOrEqual(1000);
    expect(PRE_REVEAL_MS).toBeLessThanOrEqual(3000);
  });

  it('REVEAL_ROWS matches the 4-row spec (KPI / threshold / ratio / capacity)', () => {
    expect(REVEAL_ROWS).toBe(4);
  });

  it('REVEAL_ROW_MS leaves room for tick-up animation per row', () => {
    expect(REVEAL_ROW_MS).toBeGreaterThanOrEqual(800);
  });
});
