// PixiJS dialog router for ink runtime (P5 Phase 2).
//
// Two render modes coexist while the diegetic UI is being upgraded:
//   - NPC-anchored speech bubble (T10a) for lines that begin with a
//     known speaker, e.g. `**Lisa**："…"` or `Vivian："…"`.
//   - Bottom narration panel (P5 Phase 1 placeholder) for everything
//     else — internal monologue, set-piece description, prop quotes.
//
// Choice rendering is unchanged here; T11 replaces it with sticky-note
// props anchored to the desk surface.
//
// Markdown handling: PixiJS Text can't render mixed inline styles, so
// `**bold**` / `_italic_` markers are stripped before render. Semantic
// loss is acceptable until T10b adds an internal-monologue renderer
// that paints `_…_` blocks in italic on its own pass.

import { ink } from '@/ink/runtime';
import { tagDispatcher } from '@/ink/tag-interceptors';
import { Container, Graphics, Text } from 'pixi.js';
import { getNpcAnchor } from './npc-anchors';
import { parseSpeaker } from './speaker-parser';
import { type SpeechBubbleHandle, mountSpeechBubble } from './speech-bubble';

const CANVAS_W = 640;
const CANVAS_H = 360;
const PANEL_W = 600;
const PANEL_H = 130; // bottom strip
const PANEL_X = (CANVAS_W - PANEL_W) / 2;
const PANEL_Y = CANVAS_H - PANEL_H - 8;
const PANEL_PADDING = 10;
const TEXT_FONT = 'PingFang SC, -apple-system, sans-serif';
const TEXT_COLOR = 0xe8e0cc;
const PANEL_BG = 0x000000;
const PANEL_BG_ALPHA = 0.78;
const PANEL_BORDER = 0x5a7080;
const CHOICE_BG = 0x2c4a6e;
const CHOICE_BG_HOVER = 0x4a6a8e;
const CHOICE_BORDER = 0xc8a85a;

/** Strip ink markdown (`**X**` → `X`, `_X_` → `X`) since PixiJS Text can't render mixed styles. */
function stripMarkdown(s: string): string {
  return s.replace(/\*\*(.+?)\*\*/g, '$1').replace(/_(.+?)_/g, '$1');
}

export interface InkDialogHandles {
  container: Container;
  destroy: () => void;
  refresh: () => void;
  start: () => void;
}

export function mountInkDialog(parent: Container): InkDialogHandles {
  const container = new Container();
  container.label = 'ink-dialog';
  parent.addChild(container);

  // Choice popup floats above panel; panel is bottom-anchored.
  const panelBg = new Graphics();
  container.addChild(panelBg);

  const text = new Text({
    text: '',
    style: {
      fontFamily: TEXT_FONT,
      fontSize: 13,
      fill: TEXT_COLOR,
      lineHeight: 18,
      wordWrap: true,
      wordWrapWidth: PANEL_W - 2 * PANEL_PADDING,
    },
  });
  text.x = PANEL_X + PANEL_PADDING;
  text.y = PANEL_Y + PANEL_PADDING;
  container.addChild(text);

  const choicesLayer = new Container();
  choicesLayer.label = 'choices';
  container.addChild(choicesLayer);

  let choiceTeardowns: Array<() => void> = [];
  let currentBubble: SpeechBubbleHandle | null = null;

  const clearChoices = () => {
    for (const t of choiceTeardowns) t();
    choiceTeardowns = [];
    choicesLayer.removeChildren();
  };

  const clearBubble = () => {
    if (currentBubble) {
      currentBubble.destroy();
      currentBubble = null;
    }
  };

  const drawPanelBg = () => {
    panelBg.clear();
    panelBg.rect(PANEL_X, PANEL_Y, PANEL_W, PANEL_H);
    panelBg.fill({ color: PANEL_BG, alpha: PANEL_BG_ALPHA });
    panelBg.stroke({ color: PANEL_BORDER, width: 1 });
  };

  const renderChoiceButton = (label: string, idx: number, x: number, y: number): (() => void) => {
    const btn = new Container();
    btn.label = `choice-${idx}`;
    btn.eventMode = 'static';
    btn.cursor = 'pointer';
    btn.x = x;
    btn.y = y;

    const bg = new Graphics();
    btn.addChild(bg);

    const lbl = new Text({
      text: label,
      style: {
        fontFamily: TEXT_FONT,
        fontSize: 12,
        fill: TEXT_COLOR,
      },
    });
    lbl.anchor.set(0.5);
    btn.addChild(lbl);

    const w = lbl.width + 20;
    const h = 22;
    const repaint = (hover: boolean) => {
      bg.clear();
      bg.rect(-w / 2, -h / 2, w, h);
      bg.fill({ color: hover ? CHOICE_BG_HOVER : CHOICE_BG, alpha: 0.9 });
      bg.stroke({ color: CHOICE_BORDER, width: 1 });
    };
    repaint(false);

    btn.on('pointerover', () => repaint(true));
    btn.on('pointerout', () => repaint(false));
    btn.on('pointertap', () => {
      if (idx < 0) return; // ended-state placeholder
      // selectChoice() already advances the story AND returns the new step
      // with text + tags + next choices. Don't call refresh() (which would
      // step() AGAIN and find the content already drained → empty text).
      const nextStep = ink.selectChoice(idx);
      tagDispatcher.dispatchAll(nextStep.tags);
      queueMicrotask(() => paintStep(nextStep));
    });

    choicesLayer.addChild(btn);
    return () => btn.destroy({ children: true });
  };

  // Show choices ABOVE the dialog panel (centered), as floating buttons.
  // Each choice gets its own row, stacked from bottom up.
  const renderChoiceStack = (choices: Array<{ index: number; text: string }>) => {
    if (choices.length === 0) return;
    const gap = 26;
    const totalH = choices.length * gap;
    const startY = PANEL_Y - 14 - totalH + gap / 2;
    choices.forEach((c, i) => {
      const teardown = renderChoiceButton(
        stripMarkdown(c.text),
        c.index,
        CANVAS_W / 2,
        startY + i * gap,
      );
      choiceTeardowns.push(teardown);
    });
  };

  const hidePanel = () => {
    panelBg.clear();
    text.text = '';
  };

  /** Paint a given step (text + choices) into the dialog UI. Pure render. */
  const paintStep = (step: ReturnType<typeof ink.step>) => {
    clearBubble();

    // Route NPC-prefixed first paragraph to a speech bubble; show any
    // remaining narration text in the bottom panel. If the entire step
    // is one speaker line, the panel is hidden so the bubble stands alone.
    const parsed = parseSpeaker(step.text);
    const anchor = parsed ? getNpcAnchor(parsed.speaker) : null;
    let panelText = step.text;
    if (parsed && anchor) {
      currentBubble = mountSpeechBubble(container, {
        anchor,
        text: stripMarkdown(parsed.dialog),
      });
      panelText = parsed.remainder;
    }

    const trimmedPanel = panelText.trim();
    if (trimmedPanel.length === 0 && currentBubble) {
      hidePanel();
    } else {
      text.text = stripMarkdown(trimmedPanel || '...');
      drawPanelBg();
    }

    clearChoices();
    if (step.ended) {
      const teardown = renderChoiceButton('（剧本结束）', -1, CANVAS_W / 2, PANEL_Y - 16);
      choiceTeardowns.push(teardown);
    } else if (step.choices.length > 0) {
      renderChoiceStack(step.choices);
    } else if (step.canContinue) {
      // Edge case: no text emitted but story can continue. Step + repaint.
      const nextStep = ink.step();
      tagDispatcher.dispatchAll(nextStep.tags);
      queueMicrotask(() => paintStep(nextStep));
    }
  };

  /** Step the story from current position and paint result. */
  const refresh = () => {
    if (!ink.isLoaded) {
      text.text = '(no story loaded)';
      drawPanelBg();
      clearChoices();
      return;
    }
    const step = ink.step();
    tagDispatcher.dispatchAll(step.tags);
    paintStep(step);
  };

  const start = () => refresh();

  const destroy = () => {
    clearBubble();
    clearChoices();
    container.destroy({ children: true });
  };

  return { container, destroy, refresh, start };
}

void CANVAS_H; // silence unused — kept for future centering math
