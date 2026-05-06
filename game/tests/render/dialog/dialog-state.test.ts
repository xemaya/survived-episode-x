// Unit tests for the dialog-state singleton (Bug #11 / T16 follow-up).

import { afterEach, describe, expect, it } from 'vitest';
import { dialogState } from '../../../src/render/dialog/dialog-state';

afterEach(() => {
  dialogState.reset();
});

describe('dialogState (Bug #11 / T16 follow-up)', () => {
  it('starts with empty lastNarrationText', () => {
    expect(dialogState.lastNarrationText).toBe('');
  });

  it('setLastNarrationText stores the value', () => {
    dialogState.setLastNarrationText('hello world');
    expect(dialogState.lastNarrationText).toBe('hello world');
  });

  it('overwrites prior values (latest wins)', () => {
    dialogState.setLastNarrationText('first');
    dialogState.setLastNarrationText('second');
    expect(dialogState.lastNarrationText).toBe('second');
  });

  it('reset() clears the value', () => {
    dialogState.setLastNarrationText('foo');
    dialogState.reset();
    expect(dialogState.lastNarrationText).toBe('');
  });

  it('accepts CJK + multi-line panel narration verbatim', () => {
    const panel =
      '游戏从 2026 年 5 月开始。\n\n活过这一年（52 周）就赢——不是升职加薪那种赢, 是"熬过去" 那种赢。';
    dialogState.setLastNarrationText(panel);
    expect(dialogState.lastNarrationText).toBe(panel);
  });

  it('accepts an explicit empty string (clears via setter)', () => {
    dialogState.setLastNarrationText('something');
    dialogState.setLastNarrationText('');
    expect(dialogState.lastNarrationText).toBe('');
  });
});
