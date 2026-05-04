import { describe, expect, it } from 'vitest';
import type { SceneState } from '../../src/flow/scene-state';
import { isLegalTransition } from '../../src/flow/transitions';

const mainMenu: SceneState = { kind: 'main_menu' };
const day1: SceneState = { kind: 'action_day', day: 1, phase: 'morning' };
const day7: SceneState = { kind: 'action_day', day: 7, phase: 'morning' };
const day1Pause: SceneState = { kind: 'pause', resumeTo: day1 };
const mainMenuPause: SceneState = { kind: 'pause', resumeTo: mainMenu };
const dailyRecap: SceneState = { kind: 'recap', recapKind: 'daily', day: 1 };
const weeklyRecap: SceneState = { kind: 'recap', recapKind: 'weekly', day: 5 };
const kpiReview: SceneState = { kind: 'kpi_review', monthIndex: 1 };
const gameOverCap: SceneState = { kind: 'gameover', reason: 'kpi_exceeds_capacity', monthIndex: 1 };
const gameOverDis: SceneState = { kind: 'gameover', reason: 'dismissal_severe', monthIndex: 1 };

describe('isLegalTransition (P1 subset)', () => {
  it('main_menu → action_day is legal (game start)', () => {
    expect(isLegalTransition(mainMenu, day1)).toBe(true);
  });

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
  it('action_day → recap (daily) is legal (day-end on non-month-end day)', () => {
    expect(isLegalTransition(day1, dailyRecap)).toBe(true);
  });

  it('action_day → recap (weekly) is legal (Friday day-end)', () => {
    expect(isLegalTransition({ kind: 'action_day', day: 5, phase: 'morning' }, weeklyRecap)).toBe(
      true,
    );
  });

  it('recap → action_day is legal (next day after recap dismissed)', () => {
    expect(isLegalTransition(dailyRecap, day1)).toBe(true);
  });

  it('recap → recap is illegal (no nested recap)', () => {
    expect(isLegalTransition(dailyRecap, dailyRecap)).toBe(false);
  });

  it('action_day → kpi_review is legal (month-end day)', () => {
    expect(isLegalTransition(day7, kpiReview)).toBe(true);
  });

  it('kpi_review → action_day is legal (next month after confirm)', () => {
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

  it('pause is unchanged: P1 invariant still holds (pause only from action_day with matching resumeTo)', () => {
    expect(isLegalTransition(day1, day1Pause)).toBe(true);
    expect(isLegalTransition(mainMenu, mainMenuPause)).toBe(false);
  });
});
