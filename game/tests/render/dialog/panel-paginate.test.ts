import { describe, expect, it } from 'vitest';
import {
  PANEL_TEXT_BUDGET,
  paginateAtSentenceBoundary,
} from '../../../src/render/dialog/panel-paginate';

describe('paginateAtSentenceBoundary (Q-V / Bug #34)', () => {
  it('returns text unchanged when within budget', () => {
    const text = '你 9:14 走到工位区。';
    const result = paginateAtSentenceBoundary(text, 50);
    expect(result.head).toBe(text);
    expect(result.tail).toBe('');
  });

  it('splits at the latest sentence terminator within budget', () => {
    const text = '你刷工牌过门禁。前台 Vivian 抬头。"嗨，来啦。"';
    // budget 14 → "你刷工牌过门禁。" at idx 7 (8 chars). After that is "前台 Vivian..."
    const result = paginateAtSentenceBoundary(text, 14);
    expect(result.head.endsWith('。')).toBe(true);
    expect(result.head.length).toBeLessThanOrEqual(14);
    expect(result.head + result.tail).toBe(text);
  });

  it('prefers Chinese full-width terminators 。？！', () => {
    const text = '什么意思？我不懂。再说一遍！';
    const result = paginateAtSentenceBoundary(text, 8);
    // Cut at "什么意思？" (5 chars) — first terminator within budget.
    expect(result.head).toBe('什么意思？');
    expect(result.tail).toBe('我不懂。再说一遍！');
  });

  it('falls back to ASCII ?! when CJK terminators absent', () => {
    const result = paginateAtSentenceBoundary('one. two? three!', 12);
    expect(result.head.endsWith('?')).toBe(true);
    expect(result.tail).toBe(' three!');
  });

  it('falls back to newline boundary when no sentence terminator in window', () => {
    const text = 'aaaaaaaaaa\nbbbbbbbbbb\ncccccccccc';
    const result = paginateAtSentenceBoundary(text, 15);
    // Expected cut at first newline within budget.
    expect(result.head).toBe('aaaaaaaaaa');
    expect(result.tail).toBe('bbbbbbbbbb\ncccccccccc');
  });

  it('forces a cut at budget when no boundary exists', () => {
    const text = 'a'.repeat(50);
    const result = paginateAtSentenceBoundary(text, 20);
    expect(result.head).toBe('a'.repeat(20));
    expect(result.tail).toBe('a'.repeat(30));
  });

  it('trims leading whitespace from tail on forced cut', () => {
    const text = `${'a'.repeat(20)}   bbbb`;
    const result = paginateAtSentenceBoundary(text, 20);
    expect(result.head).toBe('a'.repeat(20));
    expect(result.tail).toBe('bbbb');
  });

  it('does not split before the 40% floor — short head would feel weird', () => {
    // Sentence terminator at idx 2 (within budget 20 but in first 40% =
    // idx 8). Helper should NOT split there; should look further or
    // fall back. With only one terminator, falls through to forced cut.
    const text = 'a。bbbbbbbbbbbbbbbbbb';
    const result = paginateAtSentenceBoundary(text, 20);
    // No newline; forced cut at budget=20.
    expect(result.head.length).toBe(20);
    expect(result.tail).toBe('');
  });

  it('uses default budget when omitted', () => {
    const text = 'short text.';
    expect(paginateAtSentenceBoundary(text)).toEqual({ head: text, tail: '' });
    expect(PANEL_TEXT_BUDGET).toBeGreaterThan(50);
  });

  it('round-trips: head + tail reconstructs original (sentence-cut)', () => {
    const text = '你刷工牌过门禁。前台 Vivian 抬头。"嗨，来啦。"';
    const r = paginateAtSentenceBoundary(text, 14);
    expect(r.head + r.tail).toBe(text);
  });

  it('round-trips: forced cut also reconstructs (no whitespace)', () => {
    const text = 'abcdefghijklmnopqrstuvwxyz';
    const r = paginateAtSentenceBoundary(text, 10);
    expect(r.head + r.tail).toBe(text);
  });
});
