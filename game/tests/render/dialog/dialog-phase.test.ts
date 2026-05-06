// Unit tests for the QA Bug #13 phase-decision helper.
// Pure function — no Pixi instantiation needed.

import { describe, expect, it } from 'vitest';
import { SHORT_PROMPT_THRESHOLD, decideDialogPhase } from '../../../src/render/dialog/dialog-phase';

function step(over: Partial<Parameters<typeof decideDialogPhase>[0]['step']>) {
  return {
    text: '',
    choices: [],
    canContinue: false,
    ended: false,
    paused: false,
    ...over,
  };
}

describe('decideDialogPhase (QA Bug #13)', () => {
  it('returns "ended" when step.ended (overrides text + choice signals)', () => {
    expect(
      decideDialogPhase({
        remainingTextTrimmed: 'long enough text after layer 2',
        step: step({ ended: true }),
      }),
    ).toBe('ended');
  });

  it('returns "paged" when step.paused (overrides choices)', () => {
    expect(
      decideDialogPhase({
        remainingTextTrimmed: 'pagebreak text',
        step: step({ paused: true, choices: [{}, {}] }),
      }),
    ).toBe('paged');
  });

  it('returns "deferred-choices" for long narration + choices', () => {
    const longText = '一'.repeat(40); // 40 CJK chars > 60-char threshold? actually len=40
    // Use ASCII to ensure length-in-chars > threshold
    const text = 'a'.repeat(SHORT_PROMPT_THRESHOLD + 10);
    expect(
      decideDialogPhase({
        remainingTextTrimmed: text,
        step: step({ text, choices: [{}, {}, {}] }),
      }),
    ).toBe('deferred-choices');
    void longText;
  });

  it('returns "header-band" for short narration + choices', () => {
    const text = 'a'.repeat(SHORT_PROMPT_THRESHOLD - 10);
    expect(
      decideDialogPhase({
        remainingTextTrimmed: text,
        step: step({ text, choices: [{}, {}] }),
      }),
    ).toBe('header-band');
  });

  it('boundary: text length === threshold uses deferred (>= rule)', () => {
    const text = 'a'.repeat(SHORT_PROMPT_THRESHOLD);
    expect(
      decideDialogPhase({
        remainingTextTrimmed: text,
        step: step({ text, choices: [{}] }),
      }),
    ).toBe('deferred-choices');
  });

  it('returns "choices-only" for empty narration + choices', () => {
    expect(
      decideDialogPhase({
        remainingTextTrimmed: '',
        step: step({ text: '', choices: [{}, {}] }),
      }),
    ).toBe('choices-only');
  });

  it('returns "narration-only" for text without choices, not paused', () => {
    expect(
      decideDialogPhase({
        remainingTextTrimmed: 'just narration',
        step: step({ text: 'just narration', canContinue: false }),
      }),
    ).toBe('narration-only');
  });

  it('returns "empty" when nothing remains for layer 3', () => {
    expect(
      decideDialogPhase({
        remainingTextTrimmed: '',
        step: step({ text: '' }),
      }),
    ).toBe('empty');
  });

  it('honors a custom shortPromptThreshold override', () => {
    const text = 'a'.repeat(30);
    expect(
      decideDialogPhase({
        remainingTextTrimmed: text,
        step: step({ text, choices: [{}] }),
        shortPromptThreshold: 100,
      }),
    ).toBe('header-band');
    expect(
      decideDialogPhase({
        remainingTextTrimmed: text,
        step: step({ text, choices: [{}] }),
        shortPromptThreshold: 10,
      }),
    ).toBe('deferred-choices');
  });

  it('"paged" wins over "deferred-choices" when both apply (pagebreak inside text+choices)', () => {
    const text = 'a'.repeat(SHORT_PROMPT_THRESHOLD + 10);
    expect(
      decideDialogPhase({
        remainingTextTrimmed: text,
        step: step({ text, paused: true, choices: [{}] }),
      }),
    ).toBe('paged');
  });

  it('models the QA Bug #13 reproducer (Day 1 Event 1.2 茶水间, full narration block)', () => {
    // The actual narration block before Event 1.2 choices is >100 chars
    // — multi-paragraph rendering of Vivian setup + cafeteria scene
    // description per `episode-1.ink`. Far over threshold → defer.
    const text =
      '你刷工牌过门禁，前台 Vivian 抬头。"嗨～来啦～" 她拖长了音。眼睛已经飘向门口下一个。' +
      '工位旁边的水果盘今天是苹果。茶水间。她手里的不是保温杯。' +
      '茶水间另一头, 李阿姨在拖地。她抬头看了你一眼，没说话。';
    expect(text.length).toBeGreaterThan(SHORT_PROMPT_THRESHOLD);
    expect(
      decideDialogPhase({
        remainingTextTrimmed: text,
        step: step({ text, choices: [{}, {}, {}] }),
      }),
    ).toBe('deferred-choices');
  });

  it('models a Decision-Moment short prompt ("你看着 Lisa：")', () => {
    const text = '你看着 Lisa：';
    expect(
      decideDialogPhase({
        remainingTextTrimmed: text,
        step: step({ text, choices: [{}, {}] }),
      }),
    ).toBe('header-band');
  });
});

describe('SHORT_PROMPT_THRESHOLD constant', () => {
  it('is a sane default for ~3 lines of CJK', () => {
    expect(SHORT_PROMPT_THRESHOLD).toBeGreaterThan(20);
    expect(SHORT_PROMPT_THRESHOLD).toBeLessThan(200);
  });
});
