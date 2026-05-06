// Q-R: 3-phase architecture (avg-architecture.md §1.8). Tests cover
// the new ended / choice / narration trichotomy.

import { describe, expect, it } from 'vitest';
import { decideDialogPhase } from '../../../src/render/dialog/dialog-phase';

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

describe('decideDialogPhase (Q-R 3-phase)', () => {
  it('returns "ended" when step.ended (overrides text + choice signals)', () => {
    expect(decideDialogPhase({ step: step({ ended: true }) })).toBe('ended');
  });

  it('returns "ended" when step.ended even with choices present', () => {
    expect(decideDialogPhase({ step: step({ ended: true, choices: [{}, {}] }) })).toBe('ended');
  });

  it('returns "choice" when step has choices and is not ended', () => {
    expect(decideDialogPhase({ step: step({ text: 'narration', choices: [{}, {}, {}] }) })).toBe(
      'choice',
    );
  });

  it('returns "choice" when step has choices and empty text', () => {
    expect(decideDialogPhase({ step: step({ text: '', choices: [{}, {}] }) })).toBe('choice');
  });

  it('returns "narration" when step has only text (no choices, not ended)', () => {
    expect(decideDialogPhase({ step: step({ text: 'just narration' }) })).toBe('narration');
  });

  it('returns "narration" for empty text + no choices (the auto-step case)', () => {
    expect(decideDialogPhase({ step: step({ text: '' }) })).toBe('narration');
  });

  it('returns "narration" when paused at # pagebreak (auto-split / pagebreak boundary)', () => {
    expect(decideDialogPhase({ step: step({ text: 'pre-break', paused: true }) })).toBe(
      'narration',
    );
  });

  it('paused + choices → "choice" (sticky still wins; ▼ is panel-only)', () => {
    expect(decideDialogPhase({ step: step({ text: 'p', paused: true, choices: [{}] }) })).toBe(
      'choice',
    );
  });

  it('returns "narration" when canContinue=true (more chunks pending)', () => {
    expect(decideDialogPhase({ step: step({ text: 't', canContinue: true }) })).toBe('narration');
  });

  it('canContinue + choices → "choice"', () => {
    expect(decideDialogPhase({ step: step({ text: 't', canContinue: true, choices: [{}] }) })).toBe(
      'choice',
    );
  });

  it('models the Day 2 Lisa 茶水间 multi-source step (post-auto-split, narration only)', () => {
    // After Q-R auto-split, the runtime emits one source per step.
    // A narration-only paint here.
    const text = '你 9:14 走到工位区。A 区——Lisa 工位斜对角。';
    expect(decideDialogPhase({ step: step({ text }) })).toBe('narration');
  });

  it('models a typical choice point (panel + sticky coexist)', () => {
    const text = '你看着 Lisa：';
    expect(decideDialogPhase({ step: step({ text, choices: [{}, {}, {}] }) })).toBe('choice');
  });
});
