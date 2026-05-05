// Unit tests for sticky-note layout math + style pin. Click handling
// + bob animation are verified manually via `pnpm dev`.

import { describe, expect, it } from 'vitest';
import {
  STICKY_NOTES_STYLE,
  computeStickyLayout,
  estimateFitLength,
  visualCharWidth,
  visualWidth,
} from '../../../src/render/choice/sticky-notes-layout';

describe('computeStickyLayout', () => {
  it('returns empty array when count is zero or negative', () => {
    expect(computeStickyLayout({ count: 0 })).toEqual([]);
    expect(computeStickyLayout({ count: -1 })).toEqual([]);
  });

  it('produces N slots when N <= maxSlots', () => {
    expect(computeStickyLayout({ count: 1 })).toHaveLength(1);
    expect(computeStickyLayout({ count: 2 })).toHaveLength(2);
    expect(computeStickyLayout({ count: 3 })).toHaveLength(3);
  });

  it('caps to maxSlots (default 3) when more choices arrive', () => {
    const slots = computeStickyLayout({ count: 5 });
    expect(slots).toHaveLength(3);
  });

  it('honors a custom maxSlots cap', () => {
    const slots = computeStickyLayout({ count: 10, maxSlots: 4 });
    expect(slots).toHaveLength(4);
  });

  it('centers the rack horizontally around centerX', () => {
    const slots = computeStickyLayout({ count: 3, centerX: 400 });
    // average x ≈ centerX (within rounding)
    const avgX = slots.reduce((sum, s) => sum + s.x, 0) / slots.length;
    expect(Math.abs(avgX - 400)).toBeLessThan(1);
  });

  it('maintains the configured horizontal gap between slots', () => {
    const gap = 20;
    const slots = computeStickyLayout({ count: 3, gap });
    const dx0 = slots[1]!.x - slots[0]!.x;
    const dx1 = slots[2]!.x - slots[1]!.x;
    const expected = STICKY_NOTES_STYLE.WIDTH + gap;
    expect(dx0).toBeCloseTo(expected, 5);
    expect(dx1).toBeCloseTo(expected, 5);
  });

  it('places all slots at centerY', () => {
    const slots = computeStickyLayout({ count: 3, centerY: 250 });
    for (const s of slots) expect(s.y).toBe(250);
  });

  it("alternates tilt sign so notes don't all lean the same way", () => {
    const slots = computeStickyLayout({ count: 3 });
    expect(Math.sign(slots[0]!.tilt)).not.toBe(Math.sign(slots[1]!.tilt));
  });

  it('keeps tilt within the documented range', () => {
    const slots = computeStickyLayout({ count: 3 });
    for (const s of slots) {
      expect(Math.abs(s.tilt)).toBeLessThanOrEqual(STICKY_NOTES_STYLE.TILT_RANGE);
    }
  });

  it("phases bob animation so notes don't move in unison", () => {
    const slots = computeStickyLayout({ count: 3 });
    const phases = slots.map((s) => s.bobPhase);
    expect(new Set(phases).size).toBe(slots.length);
  });
});

describe('sticky-notes style', () => {
  it('uses warm cream palette per art-bible §7.1', () => {
    expect(STICKY_NOTES_STYLE.BG_COLOR).toBe(0xefd9a8);
    expect(STICKY_NOTES_STYLE.TEXT_COLOR).toBe(0x2a2018);
  });

  it('text color contrasts against sticky bg (luminance heuristic)', () => {
    const bg = STICKY_NOTES_STYLE.BG_COLOR;
    const fg = STICKY_NOTES_STYLE.TEXT_COLOR;
    const lum = (c: number) => {
      const r = (c >> 16) & 0xff;
      const g = (c >> 8) & 0xff;
      const b = c & 0xff;
      return 0.299 * r + 0.587 * g + 0.114 * b;
    };
    expect(Math.abs(lum(bg) - lum(fg))).toBeGreaterThan(100);
  });

  it('keeps a usable click target (>= 60×60 px)', () => {
    expect(STICKY_NOTES_STYLE.WIDTH).toBeGreaterThanOrEqual(60);
    expect(STICKY_NOTES_STYLE.HEIGHT).toBeGreaterThanOrEqual(60);
  });

  it("bob amplitude is subtle (≤ 3 px) so it doesn't distract", () => {
    expect(STICKY_NOTES_STYLE.BOB_AMPLITUDE).toBeLessThanOrEqual(3);
  });

  it('exposes Q-3 fit constants (MAX_LINES + UNITS_PER_LINE + ELLIPSIS)', () => {
    expect(STICKY_NOTES_STYLE.MAX_LINES).toBe(2);
    expect(STICKY_NOTES_STYLE.UNITS_PER_LINE).toBeGreaterThan(0);
    expect(STICKY_NOTES_STYLE.ELLIPSIS).toBe('…');
  });
});

describe('visualCharWidth + visualWidth', () => {
  it('returns 1 for ASCII letters / digits / common punctuation', () => {
    expect(visualCharWidth('a')).toBe(1);
    expect(visualCharWidth('Z')).toBe(1);
    expect(visualCharWidth('5')).toBe(1);
    expect(visualCharWidth(',')).toBe(1);
    expect(visualCharWidth('-')).toBe(1);
    expect(visualCharWidth(' ')).toBe(1);
  });

  it('returns 2 for CJK Unified Ideographs', () => {
    expect(visualCharWidth('你')).toBe(2);
    expect(visualCharWidth('我')).toBe(2);
    expect(visualCharWidth('好')).toBe(2);
  });

  it('returns 2 for full-width / CJK punctuation', () => {
    expect(visualCharWidth('，')).toBe(2);
    expect(visualCharWidth('。')).toBe(2);
    expect(visualCharWidth('：')).toBe(2);
    expect(visualCharWidth('！')).toBe(2);
    expect(visualCharWidth('？')).toBe(2);
  });

  it('visualWidth sums per-char widths correctly', () => {
    expect(visualWidth('')).toBe(0);
    expect(visualWidth('hello')).toBe(5);
    expect(visualWidth('你好')).toBe(4);
    // L i s a + ：(2) + 好啊(2*2=4) = 4 + 2 + 4 = 10
    expect(visualWidth('Lisa：好啊')).toBe(10);
  });

  it('handles mixed CJK + ASCII (typical daily-choice label)', () => {
    // "申报加班 -10 状态" — 4 CJK + space + dash + 2 digits + space + 2 CJK
    // = 8 + 1 + 1 + 2 + 1 + 4 = 17 units
    const label = '申报加班 -10 状态';
    expect(visualWidth(label)).toBe(17);
  });
});

describe('estimateFitLength (Q-3 fit pre-estimate)', () => {
  it('returns full length when text fits within budget', () => {
    expect(estimateFitLength('你好', 2, 13)).toBe(2);
    expect(estimateFitLength('hi', 2, 13)).toBe(2);
  });

  it('truncates when CJK text exceeds budget', () => {
    // budget = 2 lines * 13 units - 1 (ellipsis) = 25 units
    // 13 CJK chars = 26 units → truncate to 12 (24 units)
    const text = '一二三四五六七八九十一二三四五';
    const fit = estimateFitLength(text, 2, 13);
    expect(fit).toBeLessThan(text.length);
    expect(fit).toBe(12);
  });

  it('returns 0 when even the first char does not fit', () => {
    // budget = 1 line * 1 unit - 1 (ellipsis) = 0 → first CJK (2 units) fails
    expect(estimateFitLength('一二三', 1, 1)).toBe(0);
  });

  it('handles ASCII-heavy labels (each char = 1 unit)', () => {
    // budget = 1 * 13 - 1 = 12 → fits 12 ASCII chars
    expect(estimateFitLength('abcdefghijklmnop', 1, 13)).toBe(12);
  });

  it('handles empty input', () => {
    expect(estimateFitLength('', 2, 13)).toBe(0);
  });
});
