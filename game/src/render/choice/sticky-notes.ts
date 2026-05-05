// Sticky-note choice rack for workstation scene (T11).
//
// Replaces the centered button stack from Phase 1 ink-dialog.ts. Up
// to 3 sticky-note shapes float on the desk surface; clicking one
// invokes the click handler with the underlying ink choice index.
// Subtle bob animation is driven by Pixi.Ticker.shared so notes
// don't sit perfectly still.
//
// Visual reference: design/concepts/p5-ui/p5_ui_02_event_lisa_ppt.png
// — 3 paper-coloured stickies float above the keyboard, slightly
// tilted, each carrying handwritten Chinese.
//
// Falls back to a vertical stack at the bottom of the canvas when
// the ink step has more than `MAX_SLOTS` choices, so daily-choice
// stitches with 4-5 options don't drop the extras silently.

import { Container, Graphics, Text, Ticker } from 'pixi.js';
import { STICKY_NOTES_STYLE, computeStickyLayout } from './sticky-notes-layout';

export type {
  StickySlot,
  ComputeStickyLayoutOpts,
} from './sticky-notes-layout';
export { STICKY_NOTES_STYLE, computeStickyLayout } from './sticky-notes-layout';

export interface StickyChoice {
  index: number;
  text: string;
}

export interface MountStickyNotesOpts {
  choices: ReadonlyArray<StickyChoice>;
  onSelect: (index: number) => void;
  /** Override default desk centroid (workstation canvas). */
  centerX?: number;
  centerY?: number;
  /** Override the 3-slot cap (e.g. for wider screens later). */
  maxSlots?: number;
}

export interface StickyNotesHandle {
  container: Container;
  destroy(): void;
}

const FALLBACK_GAP = 26;

export function mountStickyNotes(parent: Container, opts: MountStickyNotesOpts): StickyNotesHandle {
  const container = new Container();
  container.label = 'sticky-notes';
  parent.addChild(container);

  const cleanups: Array<() => void> = [];

  if (opts.choices.length === 0) {
    return {
      container,
      destroy() {
        for (const c of cleanups) c();
        container.destroy({ children: true });
      },
    };
  }

  const layoutOpts: Parameters<typeof computeStickyLayout>[0] = {
    count: opts.choices.length,
  };
  if (opts.centerX !== undefined) layoutOpts.centerX = opts.centerX;
  if (opts.centerY !== undefined) layoutOpts.centerY = opts.centerY;
  if (opts.maxSlots !== undefined) layoutOpts.maxSlots = opts.maxSlots;
  const slots = computeStickyLayout(layoutOpts);

  // Render the first up-to-N choices as desk stickies.
  const t0 = performance.now();
  for (let i = 0; i < slots.length; i++) {
    const slot = slots[i]!;
    const choice = opts.choices[i]!;
    const handle = mountSingleSticky(container, choice, slot, opts.onSelect, t0);
    cleanups.push(handle.destroy);
  }

  // Spill any extras into a vertical fallback above the desk so daily
  // choices with 4-5 options don't drop content silently.
  if (opts.choices.length > slots.length) {
    const overflow = opts.choices.slice(slots.length);
    const startY = (opts.centerY ?? 248) - STICKY_NOTES_STYLE.HEIGHT / 2 - FALLBACK_GAP;
    overflow.forEach((c, j) => {
      const fallbackY = startY - j * FALLBACK_GAP;
      const handle = mountFallbackChoice(
        container,
        c,
        opts.centerX ?? 320,
        fallbackY,
        opts.onSelect,
      );
      cleanups.push(handle.destroy);
    });
  }

  return {
    container,
    destroy() {
      for (const c of cleanups) c();
      container.destroy({ children: true });
    },
  };
}

interface SingleStickyHandle {
  destroy(): void;
}

function mountSingleSticky(
  parent: Container,
  choice: StickyChoice,
  slot: { x: number; y: number; bobPhase: number; tilt: number },
  onSelect: (index: number) => void,
  t0: number,
): SingleStickyHandle {
  const s = STICKY_NOTES_STYLE;

  const note = new Container();
  note.label = `sticky-${choice.index}`;
  note.eventMode = 'static';
  note.cursor = 'pointer';
  note.position.set(slot.x, slot.y);
  note.rotation = slot.tilt;
  parent.addChild(note);

  const shadow = new Graphics();
  shadow.roundRect(
    -s.WIDTH / 2,
    -s.HEIGHT / 2 + s.SHADOW_OFFSET_Y,
    s.WIDTH,
    s.HEIGHT,
    s.CORNER_RADIUS,
  );
  shadow.fill({ color: 0x000000, alpha: s.SHADOW_ALPHA });
  note.addChild(shadow);

  const bg = new Graphics();
  note.addChild(bg);

  const label = new Text({
    text: choice.text,
    style: {
      fontFamily: s.FONT_FAMILY,
      fontSize: s.FONT_SIZE,
      fill: s.TEXT_COLOR,
      lineHeight: s.LINE_HEIGHT,
      align: 'center',
      wordWrap: true,
      wordWrapWidth: s.WIDTH - 2 * s.PADDING,
      breakWords: true,
    },
  });
  label.anchor.set(0.5);
  note.addChild(label);

  const repaint = (hover: boolean) => {
    bg.clear();
    bg.roundRect(-s.WIDTH / 2, -s.HEIGHT / 2, s.WIDTH, s.HEIGHT, s.CORNER_RADIUS);
    bg.fill({
      color: hover ? s.BG_HOVER_COLOR : s.BG_COLOR,
      alpha: s.BG_ALPHA,
    });
    bg.stroke({
      color: hover ? s.BORDER_HOVER_COLOR : s.BORDER_COLOR,
      width: s.BORDER_WIDTH,
    });
  };
  repaint(false);

  note.on('pointerover', () => repaint(true));
  note.on('pointerout', () => repaint(false));
  note.on('pointertap', () => onSelect(choice.index));

  // Bob animation: gentle vertical drift around slot.y, phase-offset
  // per slot so the rack doesn't move in unison.
  const baseY = slot.y;
  const ticker = (t: { lastTime: number } | typeof Ticker.shared) => {
    const elapsed = ('lastTime' in t ? t.lastTime : performance.now()) - t0;
    const phase = ((elapsed + slot.bobPhase) / s.BOB_PERIOD_MS) * Math.PI * 2;
    note.position.y = baseY + Math.sin(phase) * s.BOB_AMPLITUDE;
  };
  Ticker.shared.add(ticker);

  return {
    destroy() {
      Ticker.shared.remove(ticker);
      note.destroy({ children: true });
    },
  };
}

function mountFallbackChoice(
  parent: Container,
  choice: StickyChoice,
  cx: number,
  cy: number,
  onSelect: (index: number) => void,
): SingleStickyHandle {
  const s = STICKY_NOTES_STYLE;

  const btn = new Container();
  btn.label = `sticky-fallback-${choice.index}`;
  btn.eventMode = 'static';
  btn.cursor = 'pointer';
  btn.position.set(cx, cy);
  parent.addChild(btn);

  const bg = new Graphics();
  btn.addChild(bg);

  const label = new Text({
    text: choice.text,
    style: {
      fontFamily: s.FONT_FAMILY,
      fontSize: s.FONT_SIZE,
      fill: s.TEXT_COLOR,
      breakWords: true,
    },
  });
  label.anchor.set(0.5);
  btn.addChild(label);

  const w = Math.max(120, label.width + 24);
  const h = 22;
  const repaint = (hover: boolean) => {
    bg.clear();
    bg.roundRect(-w / 2, -h / 2, w, h, s.CORNER_RADIUS);
    bg.fill({
      color: hover ? s.BG_HOVER_COLOR : s.BG_COLOR,
      alpha: s.BG_ALPHA,
    });
    bg.stroke({
      color: hover ? s.BORDER_HOVER_COLOR : s.BORDER_COLOR,
      width: s.BORDER_WIDTH,
    });
  };
  repaint(false);

  btn.on('pointerover', () => repaint(true));
  btn.on('pointerout', () => repaint(false));
  btn.on('pointertap', () => onSelect(choice.index));

  return {
    destroy() {
      btn.destroy({ children: true });
    },
  };
}
