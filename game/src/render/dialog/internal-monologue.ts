// Internal monologue renderer — italic, dimmed floating text at the
// TOP region of the canvas, away from the bottom narration panel and
// the desk-surface sticky rack.
//
// Bug #19 (2026-05-06 GM playtest) caught the prior placement at
// y=240 directly inside the panel BG range — both text streams Z-
// overlapped and became unreadable. GM ✅ Option A fix: move monologue
// to TOP region (y=20-80, full-width centered), retune style for
// clear visual distinction (10pt italic cool-gray vs. panel's 12pt
// upright cream), max 4 lines wrap with ellipsis.
//
// ink-dialog.ts feeds this with the output of
// `extractInternalMonologue()` — only paragraphs wholly wrapped in
// `_…_` reach this renderer.

import { Container, Text } from 'pixi.js';

const CANVAS_W = 640;
const FONT_FAMILY = 'PingFang SC, -apple-system, sans-serif';
const FONT_SIZE = 10; // 11 → 10 per Bug #19 GM style spec
const LINE_HEIGHT = 14; // 16 → 14
const TEXT_COLOR = 0xa8b0c0; // cream → cool-gray (#A8B0C0) per GM spec
const TEXT_ALPHA = 1.0; // dim is now intrinsic to the color, not via alpha
const MAX_WIDTH = 480; // wider so 4-line cap is reachable
const MAX_LINES = 4;
const ELLIPSIS = '…';

/** Protagonist monologue anchor — TOP-of-canvas region, far from
 * the bottom panel (y=180-336) and sticky rack (y~213-283). When
 * T05/T06 wires the protagonist sprite slot, this becomes a
 * `protagonist.position + headOffset` binding — but for monologue
 * specifically, designer + GM both prefer top-region anchoring as a
 * "thought bubble cloud" visual idiom. */
export const PROTAGONIST_HEAD_ANCHOR = { x: CANVAS_W / 2, y: 26 } as const;

export const INTERNAL_MONOLOGUE_STYLE = {
  TEXT_COLOR,
  TEXT_ALPHA,
  FONT_FAMILY,
  FONT_SIZE,
  LINE_HEIGHT,
  MAX_WIDTH,
  MAX_LINES,
  ELLIPSIS,
} as const;

export interface InternalMonologueOpts {
  text: string;
  /** Position the centroid of the text node. Defaults to protagonist anchor. */
  anchor?: { x: number; y: number };
  maxWidth?: number;
}

export interface InternalMonologueHandle {
  container: Container;
  setText(text: string): void;
  destroy(): void;
}

export function mountInternalMonologue(
  parent: Container,
  opts: InternalMonologueOpts,
): InternalMonologueHandle {
  const container = new Container();
  container.label = 'internal-monologue';
  container.alpha = TEXT_ALPHA;
  parent.addChild(container);

  const anchor = opts.anchor ?? PROTAGONIST_HEAD_ANCHOR;
  const wrapWidth = opts.maxWidth ?? MAX_WIDTH;

  const txt = new Text({
    text: opts.text,
    style: {
      fontFamily: FONT_FAMILY,
      fontSize: FONT_SIZE,
      fontStyle: 'italic',
      fill: TEXT_COLOR,
      lineHeight: LINE_HEIGHT,
      align: 'center',
      wordWrap: true,
      wordWrapWidth: wrapWidth,
      breakWords: true,
    },
  });
  txt.anchor.set(0.5, 0);
  container.addChild(txt);

  const repaint = (text: string) => {
    txt.text = text;
    container.position.set(anchor.x, anchor.y);
    // Bug #19: enforce MAX_LINES cap. If Pixi's measured height
    // exceeds MAX_LINES * LINE_HEIGHT, iteratively trim a char before
    // the ellipsis until the rendered height fits. Reuses the
    // sticky-notes ellipsis pattern.
    const maxHeight = MAX_LINES * LINE_HEIGHT;
    if (txt.height > maxHeight && text.length > 0) {
      let trimmed = `${text.slice(0, -1)}${ELLIPSIS}`;
      txt.text = trimmed;
      while (txt.height > maxHeight && trimmed.length > ELLIPSIS.length) {
        trimmed = trimmed.slice(0, -1 - ELLIPSIS.length) + ELLIPSIS;
        txt.text = trimmed;
      }
    }
  };
  repaint(opts.text);

  return {
    container,
    setText(text: string) {
      repaint(text);
    },
    destroy() {
      container.destroy({ children: true });
    },
  };
}
