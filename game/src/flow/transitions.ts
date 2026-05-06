import type { SceneState } from './scene-state';

// Hard-coded transition matrix. Readability beats DRY here — anyone
// debugging an "illegal transition" error should be able to grep this
// file and see the full universe of allowed moves.
//
// P3 adds: recap (daily/weekly), kpi_review (month-end), gameover (terminal).
// P4 Task 5 adds: morning_briefing, after_work, action_overtime.
// The canonical day chain is now:
//   morning_briefing → action_day → after_work →
//     action_overtime → after_work (loop)
//     recap (non-month-end)
//     kpi_review (month-end) → morning_briefing (next month) | gameover
//   recap → morning_briefing (next day)

export function isLegalTransition(from: SceneState, to: SceneState): boolean {
  // pause: enterable from action_day OR action_overtime (can pause during
  // overtime); resumeTo must deep-equal the current state.
  if (to.kind === 'pause') {
    return (
      (from.kind === 'action_day' || from.kind === 'action_overtime') &&
      JSON.stringify(to.resumeTo) === JSON.stringify(from)
    );
  }

  // archive_list: enterable from main_menu (player clicks 档案 button)
  // or from gameover (auto-shown after death). Exits to main_menu only.
  if (to.kind === 'archive_list') {
    return from.kind === 'main_menu' || from.kind === 'gameover';
  }

  // save_corrupt: unreachable via request (only set programmatically at boot
  // via setInitialState). Exits to main_menu only.
  if (to.kind === 'save_corrupt') {
    return false;
  }

  // main_menu: enterable from action_day (quit), pause (quit-from-pause),
  // gameover (player click after death), archive_list (back button), or
  // save_corrupt (player dismisses corrupt-save dialog).
  if (to.kind === 'main_menu') {
    return (
      from.kind === 'action_day' ||
      from.kind === 'pause' ||
      from.kind === 'gameover' ||
      from.kind === 'archive_list' ||
      from.kind === 'save_corrupt'
    );
  }

  // morning_briefing: entry point for every new day. Reachable from:
  //   main_menu (game start), recap (next day), kpi_review (next month pass).
  if (to.kind === 'morning_briefing') {
    return from.kind === 'main_menu' || from.kind === 'recap' || from.kind === 'kpi_review';
  }

  // action_day: enterable from morning_briefing (normal start), pause (resume),
  // after_work (overtime declined OR returned from overtime), or another
  // action_day (rare day-skip; allowed for tests).
  // NOTE: recap → action_day and kpi_review → action_day are NO LONGER LEGAL.
  //       Both now go via morning_briefing first.
  if (to.kind === 'action_day') {
    return (
      from.kind === 'morning_briefing' ||
      from.kind === 'pause' ||
      from.kind === 'after_work' ||
      from.kind === 'action_day' ||
      // QA Bug #23 fix (2026-05-06): morning_briefing card was removed
      // from the day-cycle flow — recap / kpi_review now transit
      // directly to action_day for the next day. main_menu → action_day
      // is the new-game entry point (was main_menu → morning_briefing).
      from.kind === 'recap' ||
      from.kind === 'kpi_review' ||
      from.kind === 'main_menu'
    );
  }

  // after_work: enterable from action_day (AP=0 or early-leave) or
  // action_overtime (overtime AP=0 or overtime early-leave).
  if (to.kind === 'after_work') {
    return from.kind === 'action_day' || from.kind === 'action_overtime';
  }

  // action_overtime: enterable from after_work (player chose 加班).
  if (to.kind === 'action_overtime') {
    return from.kind === 'after_work';
  }

  // recap: enterable from after_work (normal day end, non-month-end day).
  // Previously reachable from action_day directly — that path is now illegal.
  if (to.kind === 'recap') {
    return from.kind === 'after_work';
  }

  // kpi_review: enterable from after_work on a month-end day.
  // Previously reachable from action_day directly — that path is now illegal.
  if (to.kind === 'kpi_review') {
    return from.kind === 'after_work';
  }

  // gameover: enterable only from kpi_review (after Formula B recalc +
  // game-over condition triggered). Mid-month dismissal path deferred to P4+.
  if (to.kind === 'gameover') {
    return from.kind === 'kpi_review';
  }

  // exhaustive — TS will warn here if a new variant is added without handling
  const _exhaustive: never = to;
  return _exhaustive;
}
