import type { SceneState } from './scene-state';

// Hard-coded transition matrix. Readability beats DRY here — anyone
// debugging an "illegal transition" error should be able to grep this
// file and see the full universe of allowed moves.
//
// P3 adds: recap (daily/weekly), kpi_review (month-end), gameover (terminal).
// AFTER_WORK and MORNING_BRIEFING from the GDD are collapsed into transient
// transitions handled by day-cycle.ts (no visible state in P3).

export function isLegalTransition(from: SceneState, to: SceneState): boolean {
  // pause: enterable only from action_day (P1 invariant);
  // resumeTo must deep-equal the current state.
  if (to.kind === 'pause') {
    return from.kind === 'action_day' && JSON.stringify(to.resumeTo) === JSON.stringify(from);
  }

  // archive_list: enterable from main_menu (player clicks 档案 button)
  // or from gameover (auto-shown after death). Exits to main_menu only.
  if (to.kind === 'archive_list') {
    return from.kind === 'main_menu' || from.kind === 'gameover';
  }

  // main_menu: enterable from action_day (quit), pause (quit-from-pause),
  // gameover (player click after death), or archive_list (back button).
  if (to.kind === 'main_menu') {
    return (
      from.kind === 'action_day' ||
      from.kind === 'pause' ||
      from.kind === 'gameover' ||
      from.kind === 'archive_list'
    );
  }

  // action_day: enterable from main_menu (game start), pause (resume),
  // recap (next day after recap dismissed), kpi_review (next month after
  // confirm), or another action_day (rare day-skip; allowed for tests).
  if (to.kind === 'action_day') {
    return (
      from.kind === 'main_menu' ||
      from.kind === 'pause' ||
      from.kind === 'recap' ||
      from.kind === 'kpi_review' ||
      from.kind === 'action_day'
    );
  }

  // recap: enterable only from action_day (AP=0 day-end on a non-month-end day).
  if (to.kind === 'recap') {
    return from.kind === 'action_day';
  }

  // kpi_review: enterable only from action_day (AP=0 day-end on a month-end day).
  if (to.kind === 'kpi_review') {
    return from.kind === 'action_day';
  }

  // gameover: enterable only from kpi_review (after Formula B recalc + game-over
  // condition triggered). DISMISSAL_SEVERE could theoretically fire from action_day
  // mid-month, but P3 only checks at month-end via kpi_review, so action_day →
  // gameover is NOT in the legal set yet (deferred to P4+ when mid-month dismissal
  // path lands).
  if (to.kind === 'gameover') {
    return from.kind === 'kpi_review';
  }

  // exhaustive — TS will warn here if a new variant is added without handling
  const _exhaustive: never = to;
  return _exhaustive;
}
