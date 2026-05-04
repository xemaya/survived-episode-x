import { describe, expect, it } from 'vitest';
import { type Card, evaluateCardState } from '../../src/card/card';

const c1: Card = {
  id: 'test_1',
  apCost: 1,
  isHero: false,
  faceUrl: 'x.png',
  title: 'A',
  effects: [],
};
const c3: Card = { ...c1, id: 'test_3', apCost: 3 };

describe('evaluateCardState', () => {
  it('returns PLAYED when playedThisDay=true regardless of AP', () => {
    expect(evaluateCardState(c1, 8, true)).toBe('PLAYED');
    expect(evaluateCardState(c1, 0, true)).toBe('PLAYED');
  });

  it('returns DISABLED when currentAp < apCost', () => {
    expect(evaluateCardState(c3, 2, false)).toBe('DISABLED');
    expect(evaluateCardState(c3, 0, false)).toBe('DISABLED');
  });

  it('returns IDLE when affordable and not yet played', () => {
    expect(evaluateCardState(c1, 1, false)).toBe('IDLE');
    expect(evaluateCardState(c3, 8, false)).toBe('IDLE');
  });
});
