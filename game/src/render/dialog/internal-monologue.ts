// Internal monologue renderer — italic, semi-transparent floating
// text near the protagonist's position, no bubble or panel.
//
// Visual reference: design/concepts/p5-ui/p5_ui_02_event_lisa_ppt.png
// — `她又来了。` floats at canvas bottom in italic. Per
// p5-engine-architecture §9.2, position is "near protagonist's head".
// The current PROTAGONIST_HEAD_ANCHOR is a stub at lower-center;
// when T05/T06 wires the protagonist sprite slot, this becomes a
// `protagonist.position + headOffset` binding.
//
// ink-dialog.ts feeds this with the output of
// `extractInternalMonologue()` — only paragraphs wholly wrapped in
// `_…_` reach this renderer.

import { Container, Text } from 'pixi.js';

const CANVAS_W = 640;
const FONT_FAMILY = 'PingFang SC, -apple-system, sans-serif';
const FONT_SIZE = 11;
const LINE_HEIGHT = 16;
const TEXT_COLOR = 0xe8e0cc;
const TEXT_ALPHA = 0.6;
const MAX_WIDTH = 360;

/** Protagonist head anchor stub — T05/T06 will replace with sprite binding. */
export const PROTAGONIST_HEAD_ANCHOR = { x: CANVAS_W / 2, y: 240 } as const;

export const INTERNAL_MONOLOGUE_STYLE = {
  TEXT_COLOR,
  TEXT_ALPHA,
  FONT_FAMILY,
  FONT_SIZE,
  LINE_HEIGHT,
  MAX_WIDTH,
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
