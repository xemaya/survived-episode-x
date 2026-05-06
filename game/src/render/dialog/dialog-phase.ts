// Q-R (avg-architecture.md §1.8): collapsed from the 7-phase
// (panel/bubble/monologue/header-band/etc) layered renderer to the
// 3-phase 公文报告框 architecture. The render layer (ink-dialog.ts)
// always mounts the panel; phase only decides what surfaces sit
// alongside it.

export type DialogPhase =
  /** Story reached `-> END`. Panel shows the final recap text + a
   * single sticky `[新游戏]` for hard-restart. */
  | 'ended'
  /** Step has choices (with or without text). Panel + sticky rack
   * coexist on the same screen — no ▼ defer (Bug #25). */
  | 'choice'
  /** Step has narration text only (or paused at an auto-split /
   * pagebreak boundary). Panel only; ▼ continue affordance shows
   * when more content can be drained on the next step(). */
  | 'narration';

export interface DialogPhaseStepShape {
  text: string;
  choices: ReadonlyArray<unknown>;
  canContinue: boolean;
  ended: boolean;
  paused: boolean;
}

export interface DecideDialogPhaseOpts {
  step: DialogPhaseStepShape;
}

export function decideDialogPhase(opts: DecideDialogPhaseOpts): DialogPhase {
  const { step } = opts;
  if (step.ended) return 'ended';
  if (step.choices.length > 0) return 'choice';
  return 'narration';
}
