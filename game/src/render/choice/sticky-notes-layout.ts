// Pure layout math for the desk-surface sticky-note choice rack.
// Lives outside sticky-notes.ts (which pulls in pixi.js) so vitest
// can verify spacing / fit-clamp without a renderer.
//
// Reference: design/concepts/p5-ui/p5_ui_02_event_lisa_ppt.png — 3
// sticky notes float above the keyboard area, slightly overlapping
// the desk surface, each ≈ 90 px square. Player picks one.

export const STICKY_NOTES_STYLE = {
  /** Per-sticky procedural Graphics geometry (no sprite asset yet). */
  WIDTH: 92,
  HEIGHT: 70,
  CORNER_RADIUS: 4,
  BORDER_WIDTH: 1,
  PADDING: 8,
  /** Cream / warm palette per art-bible §7.1. */
  BG_COLOR: 0xefd9a8,
  BG_HOVER_COLOR: 0xf5e6bd,
  BG_ALPHA: 0.97,
  BORDER_COLOR: 0x8a6f3a,
  BORDER_HOVER_COLOR: 0xc8a85a,
  TEXT_COLOR: 0x2a2018,
  /** Subtle drop shadow under each sticky (black, low alpha). */
  SHADOW_OFFSET_Y: 2,
  SHADOW_ALPHA: 0.18,
  /** Idle bob amplitude (px) and per-sticky period range (ms). */
  BOB_AMPLITUDE: 1.2,
  BOB_PERIOD_MS: 1600,
  FONT_FAMILY: 'PingFang SC, -apple-system, sans-serif',
  FONT_SIZE: 11,
  LINE_HEIGHT: 14,
  /** Rotation tilt range applied per-sticky for handwritten feel (rad). */
  TILT_RANGE: 0.05,
  /** Q-3: 2-line max + ellipsis truncation (per GM reply 2026-05-05).
   * UNITS_PER_LINE is in half-width visual units (CJK chars count 2,
   * ASCII chars count 1). Sticky usable width 76 px / ~5.5 px per
   * half-width glyph at 11 px font ≈ 13 units/line. */
  MAX_LINES: 2,
  UNITS_PER_LINE: 13,
  ELLIPSIS: '…',
} as const;

export interface StickySlot {
  /** Center position on desk surface. */
  x: number;
  y: number;
  /** Phase offset for bob animation so notes don't move in sync. */
  bobPhase: number;
  /** Static tilt rotation applied to the container (rad). */
  tilt: number;
}

export interface ComputeStickyLayoutOpts {
  count: number;
  /** Center of the desk strip (typically canvas centroid). */
  centerX?: number;
  centerY?: number;
  /** Horizontal gap between stickies (px). */
  gap?: number;
  /** Cap on slots — extra choices fall through to a fallback layout. */
  maxSlots?: number;
}

const DEFAULT_CENTER_X = 320;
const DEFAULT_CENTER_Y = 248;
const DEFAULT_GAP = 14;
const DEFAULT_MAX_SLOTS = 3;

/** Approximate "visual width" of a single character in font units.
 * CJK / full-width punctuation count ~2; ASCII / digits / latin
 * punctuation count 1. Used as the cheap pre-fit estimate for the
 * sticky-note 2-line cap (Q-3 GM reply: ellipsis truncation, no
 * hover reveal). PixiJS Text measurement is the authoritative
 * source — this helper just narrows the iterative search. */
export function visualCharWidth(ch: string): number {
  // Heuristic — covers the realistic alphabets for daily-choices.ink:
  // CJK Unified, CJK Compatibility, Hiragana/Katakana, full-width
  // punctuation. Anything else (ASCII, digits, half-width symbols)
  // falls through as 1.
  const code = ch.charCodeAt(0);
  if (
    (code >= 0x3000 && code <= 0x303f) || // CJK punctuation
    (code >= 0x3040 && code <= 0x309f) || // Hiragana
    (code >= 0x30a0 && code <= 0x30ff) || // Katakana
    (code >= 0x4e00 && code <= 0x9fff) || // CJK Unified Ideographs
    (code >= 0xff00 && code <= 0xffef) // Full-width forms
  ) {
    return 2;
  }
  return 1;
}

export function visualWidth(text: string): number {
  let w = 0;
  for (const ch of text) w += visualCharWidth(ch);
  return w;
}

/** Initial estimate of the longest prefix of `text` that fits within
 * `maxLines * unitsPerLine` units of visual width, with room for an
 * ellipsis. Returned length is in characters (not units). The caller
 * still needs to verify with the actual Pixi.Text measurement and
 * trim further if the layout overflows. */
export function estimateFitLength(text: string, maxLines: number, unitsPerLine: number): number {
  const ELLIPSIS_UNITS = 1; // "…" renders as one half-width unit
  const budget = maxLines * unitsPerLine - ELLIPSIS_UNITS;
  let used = 0;
  let len = 0;
  for (const ch of text) {
    const w = visualCharWidth(ch);
    if (used + w > budget) break;
    used += w;
    len++;
  }
  return len;
}

/**
 * Lay out N sticky-note slots horizontally across the desk surface.
 * Tilt + bob phase are deterministic functions of slot index so
 * snapshots are stable.
 */
export function computeStickyLayout(opts: ComputeStickyLayoutOpts): StickySlot[] {
  const {
    count,
    centerX = DEFAULT_CENTER_X,
    centerY = DEFAULT_CENTER_Y,
    gap = DEFAULT_GAP,
    maxSlots = DEFAULT_MAX_SLOTS,
  } = opts;

  if (count <= 0) return [];
  const n = Math.min(count, maxSlots);
  const w = STICKY_NOTES_STYLE.WIDTH;
  const totalWidth = n * w + (n - 1) * gap;
  const startX = centerX - totalWidth / 2 + w / 2;

  const slots: StickySlot[] = [];
  for (let i = 0; i < n; i++) {
    slots.push({
      x: startX + i * (w + gap),
      y: centerY,
      bobPhase: (i * STICKY_NOTES_STYLE.BOB_PERIOD_MS) / Math.max(n, 1) / 2,
      tilt: STICKY_NOTES_STYLE.TILT_RANGE * (i % 2 === 0 ? -1 : 1) * (1 - i * 0.3),
    });
  }
  return slots;
}
