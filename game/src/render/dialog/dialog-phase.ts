// Pure helpers for the QA Bug #13 fix (sticky-note / panel collision).
//
// GM-confirmed Option B: when an ink step has BOTH text AND choices,
// defer the sticky rack behind a ▼ click — render only the panel
// first, let the player read, then mount the sticky-notes alone after
// they tap to advance. Short prompts (Decision-Moment style) skip the
// defer gate and use a header-band layout above the rack instead.
//
// This file holds the pure decision logic so it's vitest-testable
// without instantiating PixiJS Text. The render side (ink-dialog.ts)
// branches on `decideDialogPhase()` and mounts the appropriate Pixi
// surfaces.

/**
 * Below this trimmed-text length (in raw chars), a step that has BOTH
 * text and choices renders as "header band above rack" with no
 * intermediate ▼ click. Tunable. Per GM Q-2 reply: ~3-line short
 * prompt ≈ 60 chars works for typical Chinese decision-moment beats.
 */
export const SHORT_PROMPT_THRESHOLD = 60;

export type DialogPhase =
  /** Step has been wholly consumed by speech-bubble + monologue
   * upper layers; nothing left for the panel/rack/▼ region. */
  | 'empty'
  /** Step ended (`-> END`); render the legacy "（剧本结束）" placeholder. */
  | 'ended'
  /** Step paused at `# pagebreak`; show panel text + ▼ continue. */
  | 'paged'
  /** Step has narration text + choices, text long enough to need a
   * separate "read" beat: panel + ▼; click reveals sticky rack. */
  | 'deferred-choices'
  /** Step has narration text + choices, text short enough to fit as a
   * header band above the rack — render both at once, no ▼ gate. */
  | 'header-band'
  /** Step has choices, no remaining narration text — render rack alone. */
  | 'choices-only'
  /** Step has only narration (no choices, not paused) — panel only.
   * Auto-step continues elsewhere if `step.canContinue`. */
  | 'narration-only';

export interface DialogPhaseStepShape {
  text: string;
  choices: ReadonlyArray<unknown>;
  canContinue: boolean;
  ended: boolean;
  paused: boolean;
}

export interface DecideDialogPhaseOpts {
  /** Text remaining after the speech-bubble + monologue layers
   * peeled their share. Caller passes the layer-3 leftover. */
  remainingTextTrimmed: string;
  step: DialogPhaseStepShape;
  /** Override for tuning experiments. Defaults to SHORT_PROMPT_THRESHOLD. */
  shortPromptThreshold?: number;
}

/**
 * Pure dispatch: given the post-layer-2 text + the ink step, return
 * which dialog phase to render. The render layer (ink-dialog.ts)
 * mounts widgets per the returned phase value.
 */
export function decideDialogPhase(opts: DecideDialogPhaseOpts): DialogPhase {
  const { remainingTextTrimmed, step } = opts;
  const threshold = opts.shortPromptThreshold ?? SHORT_PROMPT_THRESHOLD;
  const hasText = remainingTextTrimmed.length > 0;
  const hasChoices = step.choices.length > 0;

  if (step.ended) return 'ended';
  if (step.paused) return 'paged';

  if (hasChoices && hasText) {
    return remainingTextTrimmed.length >= threshold ? 'deferred-choices' : 'header-band';
  }
  if (hasChoices) return 'choices-only';
  if (hasText) return 'narration-only';
  // Empty step (everything consumed by upper layers OR canContinue with
  // no emit) — caller's auto-step path handles it.
  return 'empty';
}
