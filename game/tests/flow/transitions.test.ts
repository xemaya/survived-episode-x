import { describe, expect, it } from 'vitest';
import type { SceneState } from '../../src/flow/scene-state';
import { isLegalTransition } from '../../src/flow/transitions';

const mainMenu: SceneState = { kind: 'main_menu' };
const morningBriefing1: SceneState = { kind: 'morning_briefing', day: 1 };
const morningBriefing2: SceneState = { kind: 'morning_briefing', day: 2 };
const day1: SceneState = { kind: 'action_day', day: 1, phase: 'morning' };
const day7: SceneState = { kind: 'action_day', day: 7, phase: 'morning' };
const day1Pause: SceneState = { kind: 'pause', resumeTo: day1 };
const mainMenuPause: SceneState = { kind: 'pause', resumeTo: mainMenu };
const afterWork1: SceneState = { kind: 'after_work', day: 1 };
const afterWork7: SceneState = { kind: 'after_work', day: 7 };
const actionOvertime1: SceneState = { kind: 'action_overtime', day: 1 };
const overtimePause: SceneState = { kind: 'pause', resumeTo: actionOvertime1 };
const dailyRecap: SceneState = { kind: 'recap', recapKind: 'daily', day: 1 };
const weeklyRecap: SceneState = { kind: 'recap', recapKind: 'weekly', day: 5 };
const kpiReview: SceneState = { kind: 'kpi_review', monthIndex: 1 };
const gameOverCap: SceneState = { kind: 'gameover', reason: 'kpi_exceeds_capacity', monthIndex: 1 };
const gameOverDis: SceneState = { kind: 'gameover', reason: 'dismissal_severe', monthIndex: 1 };
const archiveList: SceneState = { kind: 'archive_list' };
const saveCorrupt: SceneState = { kind: 'save_corrupt', errorMessage: 'test error' };

describe('isLegalTransition (P1 subset)', () => {
  it('action_day → pause is legal (Esc pressed)', () => {
    expect(isLegalTransition(day1, day1Pause)).toBe(true);
  });

  it('pause → resumeTo (action_day) is legal (continue clicked)', () => {
    expect(isLegalTransition(day1Pause, day1)).toBe(true);
  });

  it('main_menu → pause is illegal (no game running to pause)', () => {
    expect(isLegalTransition(mainMenu, mainMenuPause)).toBe(false);
  });

  it('pause → pause is illegal (no nested pause)', () => {
    expect(isLegalTransition(day1Pause, day1Pause)).toBe(false);
  });

  it('action_day → action_day with different day is legal (day++ at end of recap, deferred)', () => {
    const day2: SceneState = { kind: 'action_day', day: 2, phase: 'morning' };
    expect(isLegalTransition(day1, day2)).toBe(true);
  });

  it('action_day → main_menu is legal (quit to menu)', () => {
    expect(isLegalTransition(day1, mainMenu)).toBe(true);
  });

  it('pause → main_menu is legal (quit from pause)', () => {
    expect(isLegalTransition(day1Pause, mainMenu)).toBe(true);
  });
});

describe('isLegalTransition (P3: day-cycle, kpi_review, gameover)', () => {
  // NOTE: action_day → recap is NOW ILLEGAL (must go via after_work).
  it('action_day → recap (daily) is NO LONGER LEGAL (must route via after_work)', () => {
    expect(isLegalTransition(day1, dailyRecap)).toBe(false);
  });

  it('action_day → recap (weekly) is NO LONGER LEGAL (must route via after_work)', () => {
    expect(isLegalTransition({ kind: 'action_day', day: 5, phase: 'morning' }, weeklyRecap)).toBe(
      false,
    );
  });

  // QA Bug #23 (2026-05-06): morning_briefing card removed from
  // day-cycle. recap and kpi_review now legalize the direct transit
  // to action_day; the morning_briefing intermediate is gone. The
  // morning_briefing FSM state itself remains in the enum for
  // back-compat with old saves but is no longer reachable.
  it('recap → action_day is legal (was illegal pre-Bug-#23)', () => {
    expect(isLegalTransition(dailyRecap, day1)).toBe(true);
  });

  it('recap → recap is illegal (no nested recap)', () => {
    expect(isLegalTransition(dailyRecap, dailyRecap)).toBe(false);
  });

  // NOTE: action_day → kpi_review is NOW ILLEGAL (must go via after_work).
  it('action_day → kpi_review is NO LONGER LEGAL (must route via after_work)', () => {
    expect(isLegalTransition(day7, kpiReview)).toBe(false);
  });

  it('kpi_review → action_day is legal (was illegal pre-Bug-#23)', () => {
    expect(isLegalTransition(kpiReview, day1)).toBe(true);
  });

  it('kpi_review → gameover (capacity) is legal', () => {
    expect(isLegalTransition(kpiReview, gameOverCap)).toBe(true);
  });

  it('kpi_review → gameover (dismissal) is legal', () => {
    expect(isLegalTransition(kpiReview, gameOverDis)).toBe(true);
  });

  it('gameover → main_menu is legal (player click after death)', () => {
    expect(isLegalTransition(gameOverCap, mainMenu)).toBe(true);
    expect(isLegalTransition(gameOverDis, mainMenu)).toBe(true);
  });

  it('gameover → action_day is illegal (no resume from death)', () => {
    expect(isLegalTransition(gameOverCap, day1)).toBe(false);
  });

  it('gameover → kpi_review is illegal (no resurrect)', () => {
    expect(isLegalTransition(gameOverCap, kpiReview)).toBe(false);
  });

  it('action_day → gameover is illegal in P3 (mid-month dismissal deferred)', () => {
    expect(isLegalTransition(day1, gameOverDis)).toBe(false);
  });

  it('main_menu → recap is illegal (no recap without a day)', () => {
    expect(isLegalTransition(mainMenu, dailyRecap)).toBe(false);
  });

  it('main_menu → kpi_review is illegal (no review without a month)', () => {
    expect(isLegalTransition(mainMenu, kpiReview)).toBe(false);
  });

  it('main_menu → gameover is illegal (no death without a game)', () => {
    expect(isLegalTransition(mainMenu, gameOverCap)).toBe(false);
  });

  it('pause still only allowed from action_day or action_overtime with matching resumeTo', () => {
    expect(isLegalTransition(day1, day1Pause)).toBe(true);
    expect(isLegalTransition(mainMenu, mainMenuPause)).toBe(false);
  });
});

describe('isLegalTransition (P4: archive_list)', () => {
  it('main_menu → archive_list is legal (player clicks 档案 button)', () => {
    expect(isLegalTransition(mainMenu, archiveList)).toBe(true);
  });

  it('gameover → archive_list is legal (auto-shown after death)', () => {
    expect(isLegalTransition(gameOverCap, archiveList)).toBe(true);
    expect(isLegalTransition(gameOverDis, archiveList)).toBe(true);
  });

  it('archive_list → main_menu is legal (back button)', () => {
    expect(isLegalTransition(archiveList, mainMenu)).toBe(true);
  });

  it('action_day → archive_list is illegal (no mid-game archive access)', () => {
    expect(isLegalTransition(day1, archiveList)).toBe(false);
  });
});

describe('isLegalTransition (P4 Task 5: morning_briefing, after_work, action_overtime)', () => {
  it('main_menu → morning_briefing is legal (game start goes to briefing)', () => {
    expect(isLegalTransition(mainMenu, morningBriefing1)).toBe(true);
  });

  it('recap → morning_briefing is legal (next day after recap dismissed)', () => {
    expect(isLegalTransition(dailyRecap, morningBriefing2)).toBe(true);
  });

  it('kpi_review → morning_briefing is legal (next month after pass)', () => {
    expect(isLegalTransition(kpiReview, morningBriefing1)).toBe(true);
  });

  it('morning_briefing → action_day is legal (player confirms briefing)', () => {
    expect(isLegalTransition(morningBriefing1, day1)).toBe(true);
  });

  it('action_day → after_work is legal (AP=0 or early-leave)', () => {
    expect(isLegalTransition(day1, afterWork1)).toBe(true);
  });

  it('action_overtime → after_work is legal (overtime AP=0 or overtime early-leave)', () => {
    expect(isLegalTransition(actionOvertime1, afterWork1)).toBe(true);
  });

  it('after_work → action_overtime is legal (player chose 加班)', () => {
    expect(isLegalTransition(afterWork1, actionOvertime1)).toBe(true);
  });

  it('after_work → recap is legal (normal day end, non-month-end)', () => {
    expect(isLegalTransition(afterWork1, dailyRecap)).toBe(true);
  });

  it('after_work → kpi_review is legal (month-end day)', () => {
    expect(isLegalTransition(afterWork7, kpiReview)).toBe(true);
  });

  it('pause from action_overtime is legal (with matching resumeTo)', () => {
    expect(isLegalTransition(actionOvertime1, overtimePause)).toBe(true);
  });

  it('main_menu → after_work is illegal', () => {
    expect(isLegalTransition(mainMenu, afterWork1)).toBe(false);
  });

  it('main_menu → action_overtime is illegal', () => {
    expect(isLegalTransition(mainMenu, actionOvertime1)).toBe(false);
  });
});

describe('isLegalTransition (P4 Task 7: save_corrupt)', () => {
  it('save_corrupt is unreachable via request (set only via setInitialState)', () => {
    expect(isLegalTransition(mainMenu, saveCorrupt)).toBe(false);
  });

  it('save_corrupt → main_menu is legal (player dismisses)', () => {
    expect(isLegalTransition(saveCorrupt, mainMenu)).toBe(true);
  });
});
