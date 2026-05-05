// NPC-anchored speech bubble (workstation scene).
//
// Visual reference: design/concepts/p5-ui/p5_ui_02_event_lisa_ppt.png
// — cream incandescent fill on cubicle gray-blue border, rounded corners,
// small downward tail pointing at the NPC.
//
// Layout math lives in speech-bubble-layout.ts (pure, tested) so this
// file only handles PixiJS Container / Graphics / Text composition.

import { Container, Graphics, Text } from 'pixi.js';
import { type Point, SPEECH_BUBBLE_STYLE, computeBubbleLayout } from './speech-bubble-layout';

export type { Point, BubbleLayout, BubbleRect } from './speech-bubble-layout';
export { SPEECH_BUBBLE_STYLE, computeBubbleLayout } from './speech-bubble-layout';

export interface SpeechBubbleOpts {
  anchor: Point;
  text: string;
  maxWidth?: number;
  canvasWidth?: number;
  canvasHeight?: number;
}

export interface SpeechBubbleHandle {
  container: Container;
  setText(text: string): void;
  destroy(): void;
}

export function mountSpeechBubble(parent: Container, opts: SpeechBubbleOpts): SpeechBubbleHandle {
  const s = SPEECH_BUBBLE_STYLE;
  const container = new Container();
  container.label = 'speech-bubble';
  parent.addChild(container);

  const bg = new Graphics();
  container.addChild(bg);
  const tail = new Graphics();
  container.addChild(tail);

  const wrapWidth = (opts.maxWidth ?? s.MAX_WIDTH) - 2 * s.PADDING;
  const txt = new Text({
    text: opts.text,
    style: {
      fontFamily: s.FONT_FAMILY,
      fontSize: s.FONT_SIZE,
      fill: s.TEXT_COLOR,
      lineHeight: s.LINE_HEIGHT,
      wordWrap: true,
      wordWrapWidth: wrapWidth,
      breakWords: true,
    },
  });
  container.addChild(txt);

  const repaint = (text: string) => {
    txt.text = text;
    const layoutOpts: Parameters<typeof computeBubbleLayout>[0] = {
      anchor: opts.anchor,
      textWidth: txt.width,
      textHeight: txt.height,
    };
    if (opts.maxWidth !== undefined) layoutOpts.maxWidth = opts.maxWidth;
    if (opts.canvasWidth !== undefined) layoutOpts.canvasWidth = opts.canvasWidth;
    if (opts.canvasHeight !== undefined) layoutOpts.canvasHeight = opts.canvasHeight;
    const layout = computeBubbleLayout(layoutOpts);

    bg.clear();
    bg.roundRect(
      layout.bubble.x,
      layout.bubble.y,
      layout.bubble.width,
      layout.bubble.height,
      s.CORNER_RADIUS,
    );
    bg.fill({ color: s.BG_COLOR, alpha: s.BG_ALPHA });
    bg.stroke({ color: s.BORDER_COLOR, width: s.BORDER_WIDTH });

    tail.clear();
    tail.poly([
      layout.tail[0].x,
      layout.tail[0].y,
      layout.tail[1].x,
      layout.tail[1].y,
      layout.tail[2].x,
      layout.tail[2].y,
    ]);
    tail.fill({ color: s.BG_COLOR, alpha: s.BG_ALPHA });
    tail.stroke({ color: s.BORDER_COLOR, width: s.BORDER_WIDTH });

    txt.x = layout.bubble.x + s.PADDING;
    txt.y = layout.bubble.y + s.PADDING;
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
