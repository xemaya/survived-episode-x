// Pure layout math for the NPC speech bubble. Lives outside
// speech-bubble.ts (which pulls in pixi.js) so vitest can exercise
// clamp/sizing logic without loading a browser canvas.
//
// Style constants are also kept here so other dialog props (T11 sticky
// notes etc.) can match the bubble's palette without duplication.

export interface Point {
  x: number;
  y: number;
}

export interface BubbleRect {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface BubbleLayout {
  bubble: BubbleRect;
  /** Tail polygon: [base-left, base-right, tip] in absolute coords. */
  tail: [Point, Point, Point];
}

export interface ComputeBubbleLayoutOpts {
  anchor: Point;
  textWidth: number;
  textHeight: number;
  padding?: number;
  minWidth?: number;
  maxWidth?: number;
  canvasWidth?: number;
  canvasHeight?: number;
  margin?: number;
  tailWidth?: number;
  tailHeight?: number;
  anchorGap?: number;
}

export const SPEECH_BUBBLE_STYLE = {
  BG_COLOR: 0xe8e0cc, // 白炽灯白 per art-bible §7.1
  BG_ALPHA: 0.96,
  BORDER_COLOR: 0x5a7080, // 格子间灰蓝
  TEXT_COLOR: 0x1a1d22,
  CORNER_RADIUS: 6,
  BORDER_WIDTH: 1,
  TAIL_WIDTH: 10,
  TAIL_HEIGHT: 9,
  ANCHOR_GAP: 4,
  PADDING: 9,
  MIN_WIDTH: 80,
  MAX_WIDTH: 280,
  MARGIN: 8,
  CANVAS_W: 640,
  CANVAS_H: 360,
  FONT_FAMILY: 'PingFang SC, -apple-system, sans-serif',
  FONT_SIZE: 12,
  LINE_HEIGHT: 17,
} as const;

export function computeBubbleLayout(opts: ComputeBubbleLayoutOpts): BubbleLayout {
  const s = SPEECH_BUBBLE_STYLE;
  const {
    anchor,
    textWidth,
    textHeight,
    padding = s.PADDING,
    minWidth = s.MIN_WIDTH,
    maxWidth = s.MAX_WIDTH,
    canvasWidth = s.CANVAS_W,
    canvasHeight = s.CANVAS_H,
    margin = s.MARGIN,
    tailWidth = s.TAIL_WIDTH,
    tailHeight = s.TAIL_HEIGHT,
    anchorGap = s.ANCHOR_GAP,
  } = opts;

  const width = clamp(Math.ceil(textWidth) + 2 * padding, minWidth, maxWidth);
  const height = Math.ceil(textHeight) + 2 * padding;

  // Bubble centered horizontally over anchor; bottom edge above the anchor
  // by tailHeight + anchorGap so the tail fits between bubble and NPC.
  let bx = anchor.x - width / 2;
  let by = anchor.y - tailHeight - anchorGap - height;

  const maxX = Math.max(margin, canvasWidth - margin - width);
  const maxY = Math.max(margin, canvasHeight - margin - height);
  bx = clamp(bx, margin, maxX);
  by = clamp(by, margin, maxY);

  // Tail base on the bubble bottom, near the anchor's column; clamped to
  // [bx + tailWidth, bx + width - tailWidth] so the polygon stays on the
  // bubble even when the anchor is far to one side.
  const tailMinX = bx + tailWidth;
  const tailMaxX = bx + width - tailWidth;
  const tailBaseX = clamp(anchor.x, tailMinX, tailMaxX);
  const tailBaseY = by + height;
  // Tail tip drops to the anchor; ensure it sits below the base so the
  // polygon has positive area even when the anchor was clamped above the
  // bubble (e.g. NPC near the canvas top).
  const tipY = Math.max(anchor.y - anchorGap, tailBaseY + 1);

  return {
    bubble: { x: bx, y: by, width, height },
    tail: [
      { x: tailBaseX - tailWidth / 2, y: tailBaseY },
      { x: tailBaseX + tailWidth / 2, y: tailBaseY },
      { x: anchor.x, y: tipY },
    ],
  };
}

function clamp(v: number, min: number, max: number): number {
  return Math.min(Math.max(v, min), max);
}
