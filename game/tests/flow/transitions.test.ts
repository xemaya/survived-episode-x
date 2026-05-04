import { describe, expect, it } from 'vitest';
import type { SceneState } from '../../src/flow/scene-state';
import { isLegalTransition } from '../../src/flow/transitions';

const mainMenu: SceneState = { kind: 'main_menu' };
const day1: SceneState = { kind: 'action_day', day: 1, phase: 'morning' };
const day1Pause: SceneState = { kind: 'pause', resumeTo: day1 };
const mainMenuPause: SceneState = { kind: 'pause', resumeTo: mainMenu };

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
