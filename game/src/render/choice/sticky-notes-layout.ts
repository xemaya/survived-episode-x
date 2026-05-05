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
