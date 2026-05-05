// Unit tests for sticky-note layout math + style pin. Click handling
// + bob animation are verified manually via `pnpm dev`.

import { describe, expect, it } from 'vitest';
import {
  STICKY_NOTES_STYLE,
  computeStickyLayout,
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
});
