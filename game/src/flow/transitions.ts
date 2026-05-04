import type { SceneState } from './scene-state';

// Hard-coded transition matrix. Readability beats DRY here — anyone
// debugging an "illegal transition" error should be able to grep this
// file and see the full universe of allowed moves.
//
// P1 wires only main_menu / action_day / pause. New variants extend
// this when their owning phase lands.

export function isLegalTransition(from: SceneState, to: SceneState): boolean {
  // pause: enterable from action_day only (P1); disallow nested.
  // resumeTo must exactly match the current state — you can only pause
  // back to where you are, not manufacture a different resume target.
  if (to.kind === 'pause') {
    return from.kind === 'action_day' && JSON.stringify(to.resumeTo) === JSON.stringify(from);
  }

  // main_menu: enterable from any non-pause-from-non-action state
  // (P1: action_day → main_menu = quit, pause → main_menu = quit-from-pause)
  if (to.kind === 'main_menu') {
    return from.kind === 'action_day' || from.kind === 'pause';
  }

  // action_day: enterable from main_menu (start), from pause (resume), or
  // from another action_day (day-advance — used at recap end, P3+).
  if (to.kind === 'action_day') {
    return from.kind === 'main_menu' || from.kind === 'pause' || from.kind === 'action_day';
  }

  // exhaustive — TS will warn here if a new variant is added without handling
  const _exhaustive: never = to;
  return _exhaustive;
}
