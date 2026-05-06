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

describe('internal-monologue style + anchor (Bug #19 retune)', () => {
  it('uses opaque alpha — dimming is now intrinsic to the cool-gray color', () => {
    // Pre-Bug-#19: alpha=0.6 over cream fill. Post-fix: cool-gray
    // #A8B0C0 carries the visual dim, alpha stays 1.0 for crispness.
    expect(INTERNAL_MONOLOGUE_STYLE.TEXT_ALPHA).toBe(1);
  });

  it('uses the cool-gray fill #A8B0C0 (GM ✅ Bug #19 spec)', () => {
    expect(INTERNAL_MONOLOGUE_STYLE.TEXT_COLOR).toBe(0xa8b0c0);
  });

  it('uses the smaller 10pt font for clear distinction from panel narration (12pt)', () => {
    expect(INTERNAL_MONOLOGUE_STYLE.FONT_SIZE).toBe(10);
  });

  it('caps wrap to 4 lines so a long monologue truncates with ellipsis', () => {
    expect(INTERNAL_MONOLOGUE_STYLE.MAX_LINES).toBe(4);
    expect(INTERNAL_MONOLOGUE_STYLE.ELLIPSIS).toBe('…');
  });

  it('protagonist anchor moves to TOP region (Bug #19 — away from bottom panel y=180-336)', () => {
    expect(PROTAGONIST_HEAD_ANCHOR.y).toBeLessThan(80);
    expect(PROTAGONIST_HEAD_ANCHOR.x).toBeGreaterThan(0);
    // Anchor must NOT overlap the bottom panel range (y=180-336)
    expect(PROTAGONIST_HEAD_ANCHOR.y).toBeLessThan(180);
  });
});
