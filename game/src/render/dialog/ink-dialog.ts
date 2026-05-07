// Q-R PixiJS dialog renderer for ink runtime — 公文报告框 architecture
// (avg-architecture.md §1).
//
// 3 layer composition:
//   1. Panel ("报告格式框"): always visible (except `ended`); a slim
//      header bar at top shows the source label `[ 视角 / 笑天 / Lisa
//      / 王总监 / … ]` (per `source-detector.ts`). Body renders one
//      source's content in upright cream (narration / NPC speech) or
//      italic cool gray (monologue).
//   2. Sticky rack (T11): mounted only on `choice` phase. Panel stays
//      visible alongside (Bug #25 reversed Bug #13 hide).
//   3. ▼ continue affordance: shown when the runtime can advance
//      further on the next step() — either an explicit `# pagebreak`
//      pause or a Q-R virtual pagebreak from source-boundary auto-
//      split.
//
// Stateless paint discipline (§1.7): every paintStep() unconditionally
// tears down all layers, then mounts fresh per phase. No surface
// leaks across paints — that was the root of Bug #18 / #18-regression
// / #19 / #20.
//
// Source detection lives in `source-detector.ts`; the runtime already
// auto-splits steps so by the time paintStep sees a step, `step.text`
// carries one source only and `detectSource` resolves it cleanly.

import { calendar } from '@/flow/calendar';
import { ink } from '@/ink/runtime';
import { tagDispatcher } from '@/ink/tag-interceptors';
import { type StickyNotesHandle, mountStickyNotes } from '@/render/choice/sticky-notes';
import { autosave } from '@/save/autosave';
import { save } from '@/save/system';
import { Container, Graphics, Text } from 'pixi.js';
import { decideDialogPhase } from './dialog-phase';
import { dialogState } from './dialog-state';
import { NARRATION, type Source, detectSource } from './source-detector';

const CANVAS_W = 640;

// Panel geometry per avg-architecture.md §1.3 v3 (Q-DD removed header
// bar, body fills full panel):
// - y=240-336 (96 px tall, bottom-anchored with 24 px gap from canvas
//   bottom so the workstation BG stays visible underneath)
// - 600 px wide, centered
// - 1 px border #2A1F14, BG #5A7080 (cubicle navy) + alpha 0.85
// - body fills full panel rect; source distinction via body color +
//   italic toggle (no header bar / source label).
const PANEL_W = 600;
const PANEL_H = 96;
const PANEL_X = (CANVAS_W - PANEL_W) / 2;
const PANEL_Y = 240;
const PANEL_PADDING_X = 12;
const PANEL_PADDING_Y = 6;
const PANEL_TEXT_LINE_HEIGHT = 16;
const TEXT_FONT = 'PingFang SC, -apple-system, sans-serif';
const PANEL_BG = 0x5a7080;
const PANEL_BG_ALPHA = 0.85;
const PANEL_BORDER = 0x2a1f14;
const BODY_COLOR_NORMAL = 0xe8e0cc; // narration / NPC speech — cream
const BODY_COLOR_MONOLOGUE = 0xa8b0c0; // monologue — cool gray
const TRIANGLE_COLOR = 0xe8e0cc; // ▼ continue tint (was HEADER_LABEL_COLOR)

// ▼ continue affordance — bottom-right of the panel.
const CONTINUE_TRI_W = 8;
const CONTINUE_TRI_H = 6;
const CONTINUE_TRI_OFFSET_X = 18;
const CONTINUE_TRI_OFFSET_Y = 14;

/** Strip ink markdown wrappers PixiJS Text can't render mixed-style.
 * `**bold**` → bold text, `_italic_` → italic body. The italic-paragraph
 * monologue body sets fontStyle=italic on the Text node, so the markers
 * are stripped here without losing the italic visual. */
function stripMarkdown(s: string): string {
  return s.replace(/\*\*(.+?)\*\*/g, '$1').replace(/_(.+?)_/g, '$1');
}

/** Q-BB (Bug #41): keep the calendar widget aligned with the ink
 * narrative by parsing the current stitch path. ink content uses the
 * convention `day_<N>_<event>_<phase>` for episode beats, so the day
 * number can be lifted out of `state.currentPathString` without any
 * tag plumbing. Idempotent — calendar.setDay() is a no-op when day
 * matches current. Tolerant of paths that lack the prefix (e.g.
 * episode entry points like `intro` or `0`). */
const DAY_PATH_RE = /day_(\d+)_/;
function syncCalendarFromInkPath(): void {
  const path = ink.currentPathString;
  if (!path) return;
  const m = path.match(DAY_PATH_RE);
  if (!m) return;
  const day = Number.parseInt(m[1] ?? '', 10);
  if (Number.isFinite(day)) calendar.setDay(day);
}

export interface InkDialogHandles {
  container: Container;
  destroy: () => void;
  refresh: () => void;
  start: () => void;
}

export interface MountInkDialogOpts {
  /** Q-N (Bug #29): hook fired after every step()/selectChoice() so
   * the Status HUD can re-read ink VARs (kpi/money/state) and animate
   * the delta. Optional — workstation supplies it; tests omit it. */
  onAfterAdvance?: () => void;
}

export function mountInkDialog(parent: Container, opts: MountInkDialogOpts = {}): InkDialogHandles {
  const container = new Container();
  container.label = 'ink-dialog';
  parent.addChild(container);

  // Panel surfaces: BG + header bar + header label + body text + clip mask.
  const panelBg = new Graphics();
  container.addChild(panelBg);

  const bodyText = new Text({
    text: '',
    style: {
      fontFamily: TEXT_FONT,
      fontSize: 13,
      fill: BODY_COLOR_NORMAL,
      lineHeight: PANEL_TEXT_LINE_HEIGHT,
      wordWrap: true,
      wordWrapWidth: PANEL_W - 2 * PANEL_PADDING_X,
    },
  });
  bodyText.x = PANEL_X + PANEL_PADDING_X;
  bodyText.y = PANEL_Y + PANEL_PADDING_Y;
  container.addChild(bodyText);

  // Clip the body to the body region so over-long text bleeds into a
  // hidden margin instead of painting onto the workstation BG.
  const bodyMask = new Graphics();
  bodyMask.rect(
    PANEL_X + PANEL_PADDING_X,
    PANEL_Y + PANEL_PADDING_Y,
    PANEL_W - 2 * PANEL_PADDING_X,
    PANEL_H - 2 * PANEL_PADDING_Y,
  );
  bodyMask.fill(0xffffff);
  container.addChild(bodyMask);
  bodyText.mask = bodyMask;

  let currentStickies: StickyNotesHandle | null = null;
  /** Cleanup for the ▼ tap-to-continue affordance (triangle + hit rect). */
  let continueTeardown: (() => void) | null = null;
  /** Q-R: lets `choice`-phase paint the saved narration string when the
   * step itself has empty text — a refreshed mid-flow save. After the
   * first paint normal flow takes over (each panel paint updates
   * dialogState.lastNarrationText). */
  let firstPaintAfterMount = true;

  const clearStickies = () => {
    if (currentStickies) {
      currentStickies.destroy();
      currentStickies = null;
    }
  };

  const clearContinue = () => {
    if (continueTeardown) {
      continueTeardown();
      continueTeardown = null;
    }
  };

  /** Paint the panel surfaces (BG + body text) for a given source +
   * body string. Idempotent — overwrites prior content, never appends.
   *
   * Q-DD (Bug #43, 2026-05-07, avg-architecture.md §1.3 v3): the
   * panel never shows a header bar regardless of source. All paints
   * are just panel BG + body text. Source distinction now lives in
   * the body styling alone:
   *   - narration: upright cream (default)
   *   - monologue: italic cool gray `#A8B0C0`
   *   - NPC: upright cream + the body keeps its inline `Name："…"`
   *     prefix (revert Q-X strip per user spec — image 38 reference
   *     reads as a single panel of prose).
   */
  const drawPanel = (source: Source, body: string) => {
    panelBg.clear();
    panelBg.rect(PANEL_X, PANEL_Y, PANEL_W, PANEL_H);
    panelBg.fill({ color: PANEL_BG, alpha: PANEL_BG_ALPHA });
    panelBg.stroke({ color: PANEL_BORDER, width: 1 });

    bodyMask.clear();
    bodyMask.rect(
      PANEL_X + PANEL_PADDING_X,
      PANEL_Y + PANEL_PADDING_Y,
      PANEL_W - 2 * PANEL_PADDING_X,
      PANEL_H - 2 * PANEL_PADDING_Y,
    );
    bodyMask.fill(0xffffff);

    const isMonologue = source.kind === 'monologue';
    bodyText.style.fill = isMonologue ? BODY_COLOR_MONOLOGUE : BODY_COLOR_NORMAL;
    bodyText.style.fontStyle = isMonologue ? 'italic' : 'normal';
    bodyText.text = stripMarkdown(body);

    const trimmed = body.trim();
    if (trimmed.length > 0 && trimmed !== '...') {
      dialogState.setLastNarrationText(body);
    }
  };

  const hidePanel = () => {
    panelBg.clear();
    bodyText.text = '';
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
    queueMicrotask(() => {
      paintStep(nextStep);
      opts.onAfterAdvance?.();
    });
  };

  /** Hard-restart: clear save, reset dialog cache, reload page. Brutal
   * but guarantees clean singletons across all gameplay state without
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

  /** Drive the runtime forward one step — used by the ▼ tap-to-continue
   * affordance for both explicit `# pagebreak` resumes and Q-R virtual
   * pagebreaks (source-boundary auto-split). Does NOT autosave: stash
   * state already advanced past the upcoming chunk; saves are taken at
   * choice boundaries. */
  const advanceContinue = () => {
    if (!ink.isLoaded) return;
    const nextStep = ink.step();
    tagDispatcher.dispatchAll(nextStep.tags);
    queueMicrotask(() => {
      paintStep(nextStep);
      opts.onAfterAdvance?.();
    });
  };

  /** Mount the ▼ indicator at the panel's bottom-right corner AND make
   * the panel rect a click target so the player doesn't have to hit
   * the small triangle precisely. */
  const renderContinueAffordance = (): (() => void) => {
    const indicator = new Graphics();
    const tx = PANEL_X + PANEL_W - CONTINUE_TRI_OFFSET_X;
    const ty = PANEL_Y + PANEL_H - CONTINUE_TRI_OFFSET_Y;
    indicator.poly([
      tx - CONTINUE_TRI_W / 2,
      ty - CONTINUE_TRI_H / 2,
      tx + CONTINUE_TRI_W / 2,
      ty - CONTINUE_TRI_H / 2,
      tx,
      ty + CONTINUE_TRI_H / 2,
    ]);
    indicator.fill({ color: TRIANGLE_COLOR, alpha: 0.7 });
    container.addChild(indicator);

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

  const renderStickyChoices = (choices: ReadonlyArray<{ index: number; text: string }>) => {
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

  /** Stateless paint per avg-architecture.md §1.7. Top of every paint
   * is unconditional teardown of all transient layers; bottom is mount-
   * fresh-by-phase. No surface state leaks across paints. */
  const paintStep = (step: ReturnType<typeof ink.step>) => {
    syncCalendarFromInkPath();
    clearStickies();
    clearContinue();

    const phase = decideDialogPhase({
      step: {
        text: step.text,
        choices: step.choices,
        canContinue: step.canContinue,
        ended: step.ended,
        paused: step.paused,
      },
    });

    const trimmed = step.text.trim();
    const source = detectSource(step.text, step.tags);

    switch (phase) {
      case 'ended': {
        // Final recap line + a single sticky `[新游戏]` for restart.
        const endText = trimmed.length > 0 ? trimmed : '剧本结束。';
        drawPanel(source, endText);
        currentStickies = mountStickyNotes(container, {
          choices: [{ index: 0, text: '新游戏' }],
          onSelect: () => triggerNewGame(),
        });
        break;
      }
      case 'choice': {
        // Step has choices. If text is present, paint it; if not, fall
        // back to the saved narration on first paint after mount (the
        // refresh-mid-flow case where ink resumed at a choice point
        // and the prior chunk was already drained pre-save).
        let displayText = trimmed;
        let displaySource = source;
        if (displayText.length === 0 && firstPaintAfterMount) {
          const restored = dialogState.lastNarrationText.trim();
          if (restored.length > 0) {
            displayText = restored;
            displaySource = NARRATION; // original source is lost
          }
        }
        if (displayText.length > 0) {
          drawPanel(displaySource, displayText);
        } else {
          hidePanel();
        }
        // Q-V (Bug #34): when a long body forces a paginate split, the
        // runtime returns paused=true even though `choices` is still
        // populated. Show the ▼ first so the player reads the head;
        // the sticky rack mounts on the LAST page (paused=false).
        if (step.paused) {
          continueTeardown = renderContinueAffordance();
        } else {
          renderStickyChoices(step.choices);
        }
        break;
      }
      case 'narration': {
        const body = trimmed.length > 0 ? trimmed : '...';
        drawPanel(source, body);
        // ▼ shows when more content is pending — explicit pagebreak
        // (paused), virtual pagebreak (paused on source-split), or
        // canContinue-with-more-chunks. Player taps to drive step()
        // again. Empty text + canContinue auto-advances inline below.
        if (step.paused) {
          continueTeardown = renderContinueAffordance();
        } else if (step.canContinue) {
          if (trimmed.length === 0) {
            // Edge: paused yielded no body (rare). Skip the panel
            // placeholder and step again immediately so the player
            // doesn't see a stuck `...`.
            const nextStep = ink.step();
            tagDispatcher.dispatchAll(nextStep.tags);
            queueMicrotask(() => paintStep(nextStep));
            return;
          }
          continueTeardown = renderContinueAffordance();
        }
        break;
      }
    }

    firstPaintAfterMount = false;
  };

  const refresh = () => {
    if (!ink.isLoaded) {
      drawPanel(NARRATION, '(no story loaded)');
      clearStickies();
      return;
    }
    const step = ink.step();
    tagDispatcher.dispatchAll(step.tags);
    paintStep(step);
    opts.onAfterAdvance?.();
  };

  const start = () => refresh();

  const destroy = () => {
    clearContinue();
    clearStickies();
    container.destroy({ children: true });
  };

  return { container, destroy, refresh, start };
}
