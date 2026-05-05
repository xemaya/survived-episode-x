// PixiJS dialog router for ink runtime (P5 Phase 2).
//
// Three render layers compose each step:
//   1. NPC-anchored speech bubble (T10a) — first paragraph that
//      starts with a known speaker prefix (`**Lisa**：`, `Vivian：`).
//   2. Internal monologue overlay (T10b) — paragraphs wholly wrapped
//      in `_…_` lift to a centered italic semi-transparent text near
//      the protagonist's position.
//   3. Bottom narration panel (Phase 1 placeholder) — anything that
//      didn't go to (1) or (2).
//
// Choice rendering is unchanged; T11 replaces it with sticky-note
// props anchored to the desk surface.
//
// Markdown handling: PixiJS Text can't render mixed inline styles, so
// `**bold**` / `_italic_` markers are stripped before render. Whole-
// paragraph italic is handled structurally by the monologue split;
// inline italic markers inside narration paragraphs lose their visual
// distinction (acceptable until a richer text renderer lands).

import { ink } from '@/ink/runtime';
import { tagDispatcher } from '@/ink/tag-interceptors';
import { type StickyNotesHandle, mountStickyNotes } from '@/render/choice/sticky-notes';
import { autosave } from '@/save/autosave';
import { sceneState } from '@/scene/scene-state-mirror';
import { Container, Graphics, Text } from 'pixi.js';
import { type InternalMonologueHandle, mountInternalMonologue } from './internal-monologue';
import { extractInternalMonologue } from './internal-monologue-parser';
import { getNpcAnchor, getNpcAnchorById } from './npc-anchors';
import { parseSpeaker } from './speaker-parser';
import { type SpeechBubbleHandle, mountSpeechBubble } from './speech-bubble';

const CANVAS_W = 640;
const CANVAS_H = 360;
const PANEL_W = 600;
// Panel taller (was 130) so most multi-paragraph events fit without
// the QA-bug-#4 overflow. Combined with a clip mask below, any text
// that still exceeds the panel is truncated cleanly instead of
// painting onto the workstation BG. Real fix is paginate via Bug #3
// option B (gated on Q-2 reply); this is the visual triage in
// the meantime.
const PANEL_H = 156;
const PANEL_X = (CANVAS_W - PANEL_W) / 2;
const PANEL_Y = CANVAS_H - PANEL_H - 8;
const PANEL_PADDING = 10;
const PANEL_TEXT_LINE_HEIGHT = 16;
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
      lineHeight: PANEL_TEXT_LINE_HEIGHT,
      wordWrap: true,
      wordWrapWidth: PANEL_W - 2 * PANEL_PADDING,
    },
  });
  text.x = PANEL_X + PANEL_PADDING;
  text.y = PANEL_Y + PANEL_PADDING;
  container.addChild(text);

  // Clip the narration text to the panel rect so over-long step
  // bodies don't bleed onto the workstation BG (QA Bug #4 visual
  // triage). The mask is a Pixi.Graphics rect matching the inner
  // padding box; when text height exceeds the box, lower lines are
  // simply hidden behind the mask edge.
  const textMask = new Graphics();
  textMask.rect(
    PANEL_X + PANEL_PADDING,
    PANEL_Y + PANEL_PADDING,
    PANEL_W - 2 * PANEL_PADDING,
    PANEL_H - 2 * PANEL_PADDING,
  );
  textMask.fill(0xffffff);
  container.addChild(textMask);
  text.mask = textMask;

  const choicesLayer = new Container();
  choicesLayer.label = 'choices';
  container.addChild(choicesLayer);

  let choiceTeardowns: Array<() => void> = [];
  let currentBubble: SpeechBubbleHandle | null = null;
  let currentMonologue: InternalMonologueHandle | null = null;
  let currentStickies: StickyNotesHandle | null = null;
  /** Cleanup for the `# pagebreak` continue affordance (▼ + panel click). */
  let continueTeardown: (() => void) | null = null;

  const clearChoices = () => {
    for (const t of choiceTeardowns) t();
    choiceTeardowns = [];
    choicesLayer.removeChildren();
    if (currentStickies) {
      currentStickies.destroy();
      currentStickies = null;
    }
  };

  const clearBubble = () => {
    if (currentBubble) {
      currentBubble.destroy();
      currentBubble = null;
    }
  };

  const clearMonologue = () => {
    if (currentMonologue) {
      currentMonologue.destroy();
      currentMonologue = null;
    }
  };

  const clearContinue = () => {
    if (continueTeardown) {
      continueTeardown();
      continueTeardown = null;
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
      advanceChoice(idx);
    });

    choicesLayer.addChild(btn);
    return () => btn.destroy({ children: true });
  };

  /** Apply a choice + dispatch its tags + autosave + paint the next step.
   * Called from every choice surface (legacy button + sticky note). T16
   * autosave fires here so a refresh from any mid-episode position will
   * resume to the choice the player just made (Bug #9 fix). */
  const advanceChoice = (idx: number) => {
    if (idx < 0) return;
    const nextStep = ink.selectChoice(idx);
    tagDispatcher.dispatchAll(nextStep.tags);
    void autosave();
    queueMicrotask(() => paintStep(nextStep));
  };

  /** Resume the story past a `# pagebreak` and paint the next chunk.
   * Mirror of advanceChoice but without a choice index — used by the
   * panel's tap-to-continue affordance (Q-2 GM reply: pagebreak is a
   * "wait for click" beat, not a choice). Deliberately does NOT
   * autosave: ink state at this point has already advanced past the
   * post-pagebreak chunk (the chunk is held in InkRuntime.pendingChunk
   * which is intra-session only). Saves are taken at choice
   * boundaries — refreshing mid-pagebreak resumes the player to the
   * previous choice's first chunk, which they replay through. */
  const advanceContinue = () => {
    if (!ink.isLoaded) return;
    const nextStep = ink.step();
    tagDispatcher.dispatchAll(nextStep.tags);
    queueMicrotask(() => paintStep(nextStep));
  };

  /** Mount the ▼ "tap to continue" indicator at the panel's bottom-
   * right corner AND make the panel rect itself a click target so the
   * player doesn't have to hit the small triangle precisely. Returns
   * a teardown that destroys both. Called only when step.paused. */
  const renderContinueAffordance = (): (() => void) => {
    // Triangle indicator (▼) at bottom-right of the panel.
    const indicator = new Graphics();
    const tx = PANEL_X + PANEL_W - 18;
    const ty = PANEL_Y + PANEL_H - 14;
    const w = 8;
    const h = 6;
    indicator.poly([tx - w / 2, ty - h / 2, tx + w / 2, ty - h / 2, tx, ty + h / 2]);
    indicator.fill({ color: TEXT_COLOR, alpha: 0.7 });
    container.addChild(indicator);

    // Invisible click hit-rect spanning the entire panel.
    const hit = new Graphics();
    hit.rect(PANEL_X, PANEL_Y, PANEL_W, PANEL_H);
    hit.fill({ color: 0xffffff, alpha: 0 });
    hit.eventMode = 'static';
    hit.cursor = 'pointer';
    hit.on('pointertap', () => advanceContinue());
    container.addChild(hit);

    return () => {
      indicator.destroy();
      hit.destroy();
    };
  };

  /** Render the workstation sticky-note rack for the current choices. */
  const renderStickyChoices = (choices: Array<{ index: number; text: string }>) => {
    if (choices.length === 0) return;
    const stickyChoices = choices.map((c) => ({
      index: c.index,
      text: stripMarkdown(c.text),
    }));
    currentStickies = mountStickyNotes(container, {
      choices: stickyChoices,
      onSelect: advanceChoice,
    });
  };

  const hidePanel = () => {
    panelBg.clear();
    text.text = '';
  };

  /** Paint a given step (text + choices) into the dialog UI. Pure render. */
  const paintStep = (step: ReturnType<typeof ink.step>) => {
    clearBubble();
    clearMonologue();
    clearContinue();

    // Layer 1: NPC speaker → bubble at the speaker's anchor.
    //
    // Q-1 contract: prefer the `# speaker: <id>` tag when present (id
    // resolves to a stable sprite slot). Fall back to the legacy
    // `parseSpeaker` regex on the dialog text for un-migrated `.ink`
    // content. `protagonist` id deliberately doesn't render a bubble
    // — the line falls through to the panel / monologue layers below.
    const speakerId = sceneState.get('speaker');
    const idAnchor = speakerId && speakerId !== 'protagonist' ? getNpcAnchorById(speakerId) : null;
    const parsed = parseSpeaker(step.text);
    let working = step.text;
    if (idAnchor && parsed) {
      currentBubble = mountSpeechBubble(container, {
        anchor: idAnchor,
        text: stripMarkdown(parsed.dialog),
      });
      working = parsed.remainder;
    } else if (idAnchor) {
      // Tag fired but the dialog body isn't `Name：…` shaped — render
      // the whole step as the bubble body.
      currentBubble = mountSpeechBubble(container, {
        anchor: idAnchor,
        text: stripMarkdown(step.text),
      });
      working = '';
    } else if (parsed) {
      const legacyAnchor = getNpcAnchor(parsed.speaker);
      if (legacyAnchor) {
        currentBubble = mountSpeechBubble(container, {
          anchor: legacyAnchor,
          text: stripMarkdown(parsed.dialog),
        });
        working = parsed.remainder;
      }
    }

    // Layer 2: whole-italic paragraphs → internal monologue overlay.
    const split = extractInternalMonologue(working);
    if (split.monologue.length > 0) {
      currentMonologue = mountInternalMonologue(container, {
        text: split.monologue,
      });
    }

    // Layer 3: everything left → bottom narration panel. Hide if empty
    // when at least one of the higher layers rendered.
    const trimmedPanel = split.remainder.trim();
    if (trimmedPanel.length === 0 && (currentBubble || currentMonologue)) {
      hidePanel();
    } else {
      text.text = stripMarkdown(trimmedPanel || '...');
      drawPanelBg();
    }

    clearChoices();
    if (step.ended) {
      const teardown = renderChoiceButton('（剧本结束）', -1, CANVAS_W / 2, PANEL_Y - 16);
      choiceTeardowns.push(teardown);
    } else if (step.paused) {
      // `# pagebreak` arrived — show the accumulated text and a tap-to-
      // continue affordance. No sticky-notes (this is not a decision).
      continueTeardown = renderContinueAffordance();
    } else if (step.choices.length > 0) {
      renderStickyChoices(step.choices);
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
    clearMonologue();
    clearContinue();
    clearChoices();
    container.destroy({ children: true });
  };

  return { container, destroy, refresh, start };
}

void CANVAS_H; // silence unused — kept for future centering math
