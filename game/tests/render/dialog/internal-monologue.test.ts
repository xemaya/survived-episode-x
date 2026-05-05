// Unit tests for internal monologue extraction + style pin.
// PixiJS rendering itself is verified manually via `pnpm dev`.

import { describe, expect, it } from 'vitest';
import {
  INTERNAL_MONOLOGUE_STYLE,
  PROTAGONIST_HEAD_ANCHOR,
} from '../../../src/render/dialog/internal-monologue';
import { extractInternalMonologue } from '../../../src/render/dialog/internal-monologue-parser';

describe('extractInternalMonologue', () => {
  it('returns empty fields for empty input', () => {
    const r = extractInternalMonologue('');
    expect(r.monologue).toBe('');
    expect(r.remainder).toBe('');
  });

  it('lifts a single whole-italic paragraph into monologue, leaves remainder empty', () => {
    const r = extractInternalMonologue('_她又来了。_');
    expect(r.monologue).toBe('她又来了。');
    expect(r.remainder).toBe('');
  });

  it('joins multiple italic paragraphs with newline', () => {
    const text = '_他不会发现的。_\n_或者他发现了，他不会说什么。_';
    const r = extractInternalMonologue(text);
    expect(r.monologue).toBe('他不会发现的。\n或者他发现了，他不会说什么。');
    expect(r.remainder).toBe('');
  });

  it('keeps non-italic paragraphs in remainder', () => {
    const text = '王总监站起来。\n_你心里咯噔一下。_\n他打开投影仪。';
    const r = extractInternalMonologue(text);
    expect(r.monologue).toBe('你心里咯噔一下。');
    expect(r.remainder).toBe('王总监站起来。\n他打开投影仪。');
  });

  it('does NOT lift inline italic (italic in middle of paragraph stays put)', () => {
    const text = '他说"_随便_"——意思是不随便。';
    const r = extractInternalMonologue(text);
    expect(r.monologue).toBe('');
    expect(r.remainder).toBe('他说"_随便_"——意思是不随便。');
  });

  it('handles the Lisa "好的" + monologue mix from real ink', () => {
    const text = '**Lisa**："好的。"\n_她答应了。但她声音很闷。_';
    // Note: speaker line is left for parseSpeaker to handle upstream.
    // This split only sees italic paragraphs, so the speaker line goes
    // to remainder (caller will already have plucked the speaker first
    // in real flow).
    const r = extractInternalMonologue(text);
    expect(r.monologue).toBe('她答应了。但她声音很闷。');
    expect(r.remainder).toBe('**Lisa**："好的。"');
  });

  it('collapses excess blank-line runs left after italic paragraphs lift out', () => {
    const text = '王总监站起来。\n\n_你心里咯噔一下。_\n\n他打开投影仪。';
    const r = extractInternalMonologue(text);
    expect(r.monologue).toBe('你心里咯噔一下。');
    expect(r.remainder).toBe('王总监站起来。\n\n他打开投影仪。');
  });

  it('treats whitespace-only italic as monologue (after trim)', () => {
    const r = extractInternalMonologue('_   只是嗯。   _');
    expect(r.monologue).toBe('只是嗯。');
  });
});

describe('internal-monologue style + anchor', () => {
  it('exposes muted alpha for italic narration (concept 02 reference)', () => {
    expect(INTERNAL_MONOLOGUE_STYLE.TEXT_ALPHA).toBeLessThan(1);
    expect(INTERNAL_MONOLOGUE_STYLE.TEXT_ALPHA).toBeGreaterThan(0);
  });

  it('uses the cream incandescent fill (matches bubble/panel palette)', () => {
    expect(INTERNAL_MONOLOGUE_STYLE.TEXT_COLOR).toBe(0xe8e0cc);
  });

  it('protagonist head anchor sits above the bottom panel area', () => {
    // Panel y starts at 222; monologue should be above that so it
    // doesn't collide with narration panel BG.
    expect(PROTAGONIST_HEAD_ANCHOR.y).toBeLessThan(360);
    expect(PROTAGONIST_HEAD_ANCHOR.x).toBeGreaterThan(0);
  });
});
