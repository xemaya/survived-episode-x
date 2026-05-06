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

import { type InkStoryStep, ink } from '@/ink/runtime';
import { tagDispatcher } from '@/ink/tag-interceptors';
import { type StickyNotesHandle, mountStickyNotes } from '@/render/choice/sticky-notes';
import { autosave } from '@/save/autosave';
import { save } from '@/save/system';
import { sceneState } from '@/scene/scene-state-mirror';
import { Container, Graphics, Text } from 'pixi.js';
import { decideDialogPhase } from './dialog-phase';
import { dialogState } from './dialog-state';
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
// (Pre-T11 CHOICE_BG / CHOICE_BG_HOVER / CHOICE_BORDER constants removed —
// the legacy renderChoiceButton was the only consumer; T11 sticky-notes
// own their palette in sticky-notes-layout.ts.)

/** Bug #18-regression threshold: when the text after a speaker line
 * (`parsed.remainder`) is longer than this many trimmed chars, the
 * speaker bubble does NOT mount — the step is a multi-paragraph blob
 * and a hovering bubble would linger next to non-speaker narration.
 * The speaker line stays inline in the panel as `Lisa："…"` instead.
 * Tunable; ~30 chars covers "1-2 line continuation" without firing
 * for short Decision-Moment prompts that genuinely belong in a
 * bubble. */
const BUBBLE_REMAINDER_THRESHOLD = 30;

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
  /** QA Bug #13 fix: when a step carries text + choices, the rack is
   * mounted *only after* the player taps ▼ to flush the panel. The
   * step is parked here so advanceContinue() knows to re-render the
   * SAME step's choices (no ink advance) instead of calling step()
   * again (which would be a no-op at a choice point). */
  let deferredChoicesStep: InkStoryStep | null = null;
  /** Header-band Text node — short prompts (< SHORT_PROMPT_THRESHOLD)
   * sit ABOVE the sticky rack instead of in the bottom panel, so
   * narration + choices render together without overlap. */
  let headerBand: Text | null = null;
  /** QA Bug #11: only the FIRST paintStep after a fresh mount is
   * eligible to use `dialogState.lastNarrationText` as a fallback
   * when ink emits an empty-text + choices step (i.e. the player
   * just refreshed mid-flow and ink is sitting at a choice point
   * with the prior narration already drained). After that first
   * paint, normal flow takes over and lastNarrationText updates
   * naturally from each panel render. */
  let firstPaintAfterMount = true;

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

  const clearHeaderBand = () => {
    if (headerBand) {
      headerBand.destroy();
      headerBand = null;
    }
  };

  /** Header band Text positioned just above the sticky rack (rack
   * center y=248 per sticky-notes-layout default; sticky height 70 →
   * top edge ~213). Header sits at y=200 (bottom-anchored) so the
   * baseline of the last text line nestles above the rack. */
  const renderHeaderBand = (txt: string) => {
    clearHeaderBand();
    const node = new Text({
      text: txt,
      style: {
        fontFamily: TEXT_FONT,
        fontSize: 12,
        fill: TEXT_COLOR,
        lineHeight: 16,
        align: 'center',
        wordWrap: true,
        wordWrapWidth: 480,
        breakWords: true,
      },
    });
    node.anchor.set(0.5, 1);
    node.x = CANVAS_W / 2;
    node.y = 200;
    container.addChild(node);
    headerBand = node;
  };

  const drawPanelBg = () => {
    panelBg.clear();
    panelBg.rect(PANEL_X, PANEL_Y, PANEL_W, PANEL_H);
    panelBg.fill({ color: PANEL_BG, alpha: PANEL_BG_ALPHA });
    panelBg.stroke({ color: PANEL_BORDER, width: 1 });
  };

  /** Apply a choice + dispatch its tags + autosave + paint the next step.
   * Called from every choice surface (sticky note rack). T16 autosave
   * fires here so a refresh from any mid-episode position will resume
   * to the choice the player just made (Bug #9 fix). */
  const advanceChoice = (idx: number) => {
    if (idx < 0) return;
    const nextStep = ink.selectChoice(idx);
    tagDispatcher.dispatchAll(nextStep.tags);
    void autosave();
    queueMicrotask(() => paintStep(nextStep));
  };

  /** Bug #21 fix: episode-end "新游戏" handler. Hard-restart pattern —
   * clears the save file, resets in-memory dialog cache, and reloads
   * the page. Boot picks up cleanly: no save → ink diverts to intro.
   * The page-reload approach is brutal but guarantees a clean slate
   * across all singletons (energy / kpi / ap / calendar) without
   * having to re-implement individual reset paths for a P5 demo. */
  const triggerNewGame = (): void => {
    void (async () => {
      try {
        await save.clearCurrentRun();
      } catch (e) {
        console.warn('[new-game] clearCurrentRun failed:', (e as Error).message);
      }
      dialogState.reset();
      window.location.reload();
    })();
  };

  /** Resume the story past a `# pagebreak` and paint the next chunk.
   * Mirror of advanceChoice but without a choice index — used by the
   * panel's tap-to-continue affordance.
   *
   * Two cases:
   *   1. Deferred-choices flush (QA Bug #13): step has both text and
   *      choices; first paint shows panel + ▼; this call hides the
   *      panel and mounts the sticky rack for the SAME step (no ink
   *      advance — ink is already at the choice point).
   *   2. Pagebreak resume (Q-2): step paused at `# pagebreak` with
   *      pendingChunk stashed; this call drives ink.step() to drain
   *      the stash and produce the next paint.
   *
   * Deliberately does NOT autosave: ink state in case 2 has already
   * advanced past the post-pagebreak chunk (held intra-session in
   * InkRuntime.pendingChunk). Saves are taken at choice boundaries —
   * refreshing mid-pagebreak resumes the player to the previous
   * choice's first chunk, which they replay through. */
  const advanceContinue = () => {
    // Case 1: flush deferred-choices into the sticky rack.
    if (deferredChoicesStep) {
      const step = deferredChoicesStep;
      deferredChoicesStep = null;
      clearContinue();
      // QA Bug #18: bubble + monologue mounted by paintStep for the
      // SAME step's earlier paragraphs are bound to the narration that
      // is about to disappear. Tear them down alongside the panel so
      // a stale "Lisa: 你喝什么?" doesn't linger over an Event 2.3
      // 老周 sticky rack. (Pagebreak resume in case 2 doesn't need this
      // because paintStep starts with clearBubble/Monologue/HeaderBand.)
      clearBubble();
      clearMonologue();
      clearHeaderBand();
      hidePanel();
      renderStickyChoices(step.choices);
      return;
    }
    // Case 2: pagebreak resume.
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

  /** Set the panel's text node AND publish the visible text to
   * `dialogState.lastNarrationText` so the save layer can persist it
   * (Bug #11). The placeholder `...` and empty strings are filtered
   * — only meaningful narration text reaches dialogState. */
  const setPanelText = (raw: string): void => {
    text.text = raw;
    const trimmed = raw.trim();
    if (trimmed.length > 0 && trimmed !== '...') {
      dialogState.setLastNarrationText(raw);
    }
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
    //
    // Bug #18-regression (2026-05-06): only mount the bubble when the
    // speaker line is the *dominant* content of this step. If the rest
    // (parsed.remainder) is long, we're inside a multi-paragraph blob
    // that spans multiple events — showing the bubble lets it linger
    // visually next to narration that's no longer the speaker's. In
    // that case the speaker line stays inline in the panel as
    // `Lisa："…"` (markdown stripped) and no bubble mounts.
    const speakerId = sceneState.get('speaker');
    const idAnchor = speakerId && speakerId !== 'protagonist' ? getNpcAnchorById(speakerId) : null;
    const parsed = parseSpeaker(step.text);
    const speakerLineDominates =
      parsed !== null && parsed.remainder.trim().length <= BUBBLE_REMAINDER_THRESHOLD;
    let working = step.text;
    if (idAnchor && parsed && speakerLineDominates) {
      currentBubble = mountSpeechBubble(container, {
        anchor: idAnchor,
        text: stripMarkdown(parsed.dialog),
      });
      working = parsed.remainder;
    } else if (idAnchor && !parsed && step.text.trim().length <= BUBBLE_REMAINDER_THRESHOLD) {
      // Tag fired and the body is short — render whole step as bubble
      // body. Long-text path falls through to panel rendering.
      currentBubble = mountSpeechBubble(container, {
        anchor: idAnchor,
        text: stripMarkdown(step.text),
      });
      working = '';
    } else if (parsed && speakerLineDominates) {
      const legacyAnchor = getNpcAnchor(parsed.speaker);
      if (legacyAnchor) {
        currentBubble = mountSpeechBubble(container, {
          anchor: legacyAnchor,
          text: stripMarkdown(parsed.dialog),
        });
        working = parsed.remainder;
      }
    }
    // (else: long multi-paragraph blob — speaker stays inline in panel)

    // Layer 2: whole-italic paragraphs → internal monologue overlay.
    // Bug #22 fix: at ink-end, recap text often appears wrapped in
    // `_..._` (e.g. `_今日 KPI: +0_`). That's NOT internal voice — it's
    // the closing recap and belongs in the panel for visibility. Skip
    // the monologue split when step.ended so the recap stays put.
    const split = step.ended
      ? { monologue: '', remainder: working }
      : extractInternalMonologue(working);
    if (split.monologue.length > 0) {
      currentMonologue = mountInternalMonologue(container, {
        text: split.monologue,
      });
    }

    // Layer 3 (bottom panel + sticky rack + ▼ continue): pick a phase
    // per QA Bug #13 fix and mount the appropriate widgets. The pure
    // helper picks one of: empty / ended / paged / deferred-choices /
    // header-band / choices-only / narration-only.
    const trimmedPanel = split.remainder.trim();
    clearChoices();
    clearHeaderBand();
    deferredChoicesStep = null;

    const phase = decideDialogPhase({
      remainingTextTrimmed: trimmedPanel,
      step: {
        text: step.text,
        choices: step.choices,
        canContinue: step.canContinue,
        ended: step.ended,
        paused: step.paused,
      },
    });

    switch (phase) {
      case 'ended': {
        // Bug #21 + #22 fix: story reached `-> END`. Render the final
        // recap text in the panel as usual, then mount a single
        // sticky `[新游戏]` at desk surface (matches T11 visual idiom)
        // wired to a hard-restart that clears the save and reloads
        // the page so boot starts fresh.
        const endText = trimmedPanel.length > 0 ? trimmedPanel : '剧本结束。';
        setPanelText(stripMarkdown(endText));
        drawPanelBg();
        currentStickies = mountStickyNotes(container, {
          choices: [{ index: 0, text: '新游戏' }],
          onSelect: () => triggerNewGame(),
        });
        break;
      }
      case 'paged': {
        // `# pagebreak` arrived — accumulated text + ▼ tap-to-continue.
        setPanelText(stripMarkdown(trimmedPanel || ''));
        drawPanelBg();
        continueTeardown = renderContinueAffordance();
        break;
      }
      case 'deferred-choices': {
        // QA Bug #13 fix: long narration + choices → show panel only,
        // park the step on `deferredChoicesStep`. Click ▼ flushes panel
        // and mounts sticky rack alone (advanceContinue handles it).
        deferredChoicesStep = step;
        setPanelText(stripMarkdown(trimmedPanel));
        drawPanelBg();
        continueTeardown = renderContinueAffordance();
        break;
      }
      case 'header-band': {
        // Short prompt + choices: narration as header band ABOVE the
        // sticky rack, no bottom panel BG, no ▼ gate. Decision-Moment
        // style — keeps prompt and choices together.
        hidePanel();
        const headerText = stripMarkdown(trimmedPanel);
        renderHeaderBand(headerText);
        // Publish header content to dialogState too so a save mid-
        // header-band restores correctly.
        dialogState.setLastNarrationText(headerText);
        renderStickyChoices(step.choices);
        break;
      }
      case 'choices-only': {
        // QA Bug #11 (T16 follow-up): if this is the FIRST paint after
        // a fresh mount AND we have a saved last-narration string, the
        // player just refreshed mid-flow — ink emitted choices with no
        // text because the prior narration was already drained pre-
        // save. Render the saved narration in the panel + ▼ so the
        // player gets context, then click reveals the sticky rack.
        const restoredNarration = firstPaintAfterMount ? dialogState.lastNarrationText.trim() : '';
        if (restoredNarration.length > 0) {
          deferredChoicesStep = step;
          setPanelText(stripMarkdown(restoredNarration));
          drawPanelBg();
          continueTeardown = renderContinueAffordance();
        } else {
          // Empty narration text → sticky rack alone at desk surface.
          hidePanel();
          renderStickyChoices(step.choices);
        }
        break;
      }
      case 'narration-only': {
        // Just text, no choices, not paused — panel only.
        setPanelText(stripMarkdown(trimmedPanel));
        drawPanelBg();
        break;
      }
      case 'empty': {
        // Step was wholly consumed by upper layers, OR canContinue
        // with no emit; auto-step in the latter case.
        if (currentBubble || currentMonologue) {
          hidePanel();
        } else if (step.canContinue) {
          const nextStep = ink.step();
          tagDispatcher.dispatchAll(nextStep.tags);
          queueMicrotask(() => paintStep(nextStep));
          return;
        } else {
          text.text = '...';
          drawPanelBg();
        }
        break;
      }
    }

    // Flip the first-paint flag now that we've completed one paint
    // cycle. Subsequent paints follow normal flow; the saved-
    // narration fallback in `choices-only` won't fire again.
    firstPaintAfterMount = false;
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
    clearHeaderBand();
    clearChoices();
    container.destroy({ children: true });
  };

  return { container, destroy, refresh, start };
}

void CANVAS_H; // silence unused — kept for future centering math
