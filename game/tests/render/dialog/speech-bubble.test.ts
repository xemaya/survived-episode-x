// Unit tests for speech bubble layout math + speaker parsing + NPC
// anchor lookup. PixiJS rendering itself is verified manually via
// `pnpm dev` (canvas-dependent), but layout / parser / registry are
// pure functions and fully unit-testable headlessly.

import { describe, expect, it } from 'vitest';
import { getNpcAnchor, isKnownNpc, listKnownNpcs } from '../../../src/render/dialog/npc-anchors';
import { parseSpeaker } from '../../../src/render/dialog/speaker-parser';
import {
  SPEECH_BUBBLE_STYLE,
  computeBubbleLayout,
} from '../../../src/render/dialog/speech-bubble-layout';

describe('npc-anchors registry', () => {
  it('returns a positive screen anchor for known NPCs (Lisa/David/Vivian/王总监)', () => {
    for (const name of ['Lisa', 'David', 'Vivian', '王总监']) {
      const a = getNpcAnchor(name);
      expect(a).not.toBeNull();
      expect(a?.x).toBeGreaterThan(0);
      expect(a?.y).toBeGreaterThan(0);
    }
  });

  it('returns null for unknown speakers (e.g. props quoted in narration)', () => {
    expect(getNpcAnchor('桌面便利贴')).toBeNull();
    expect(getNpcAnchor('咖啡机')).toBeNull();
    expect(getNpcAnchor('你')).toBeNull();
  });

  it('isKnownNpc trims whitespace before lookup', () => {
    expect(isKnownNpc('  Lisa ')).toBe(true);
    expect(isKnownNpc('Unknown')).toBe(false);
  });

  it('listKnownNpcs returns at least the deep-cast 5', () => {
    const all = listKnownNpcs();
    for (const name of ['Lisa', 'David', 'Vivian', '王总监', '李阿姨']) {
      expect(all).toContain(name);
    }
  });
});

describe('parseSpeaker', () => {
  it('parses bold-prefixed NPC dialog (**David**：…)', () => {
    const r = parseSpeaker('**David**："兄弟，下周我有个对接 X 部门的方案要写。"');
    expect(r).not.toBeNull();
    expect(r?.speaker).toBe('David');
    expect(r?.dialog).toContain('兄弟');
    expect(r?.remainder).toBe('');
  });

  it('parses plain-prefixed NPC dialog (Lisa："…")', () => {
    const r = parseSpeaker('Lisa："谢谢哈。"');
    expect(r?.speaker).toBe('Lisa');
    expect(r?.dialog).toBe('谢谢哈。');
  });

  it('returns null for prop quotes (桌面便利贴："活到周五"——你自己写的)', () => {
    const r = parseSpeaker('桌面便利贴："活到周五"——你自己写的，过了一周还在。');
    expect(r).toBeNull();
  });

  it('returns null when there is no speaker prefix at all', () => {
    expect(parseSpeaker('闹钟响了 3 次。')).toBeNull();
    expect(parseSpeaker('_她又来了。_')).toBeNull();
  });

  it('preserves remainder paragraphs after the speaker line', () => {
    const text = 'Lisa："好啊。"\n她拿起包就站起来。\n_你跟在后面。_';
    const r = parseSpeaker(text);
    expect(r?.speaker).toBe('Lisa');
    expect(r?.dialog).toBe('好啊。');
    expect(r?.remainder).toBe('她拿起包就站起来。\n_你跟在后面。_');
  });

  it('does not match laoxia narration prefixed with 你 (protagonist is not in registry)', () => {
    expect(parseSpeaker('你："睡觉。"')).toBeNull();
  });
});

describe('computeBubbleLayout', () => {
  const anchor = { x: 470, y: 110 }; // Lisa anchor

  it('produces a bubble sized to text + padding (within min/max)', () => {
    const layout = computeBubbleLayout({
      anchor,
      textWidth: 100,
      textHeight: 18,
    });
    expect(layout.bubble.width).toBeGreaterThanOrEqual(80); // MIN_WIDTH
    expect(layout.bubble.width).toBeLessThanOrEqual(280); // MAX_WIDTH
    expect(layout.bubble.height).toBeGreaterThan(18); // text + padding
  });

  it('clamps long text to MAX_WIDTH', () => {
    const layout = computeBubbleLayout({
      anchor,
      textWidth: 500,
      textHeight: 40,
    });
    expect(layout.bubble.width).toBe(280);
  });

  it('places the bubble above the anchor with a tail gap', () => {
    const layout = computeBubbleLayout({
      anchor,
      textWidth: 100,
      textHeight: 18,
    });
    // bubble.bottom = bubble.y + bubble.height
    const bubbleBottom = layout.bubble.y + layout.bubble.height;
    expect(bubbleBottom).toBeLessThan(anchor.y);
  });

  it('keeps bubble inside canvas margin when anchor is near right edge', () => {
    const layout = computeBubbleLayout({
      anchor: { x: 630, y: 110 },
      textWidth: 200,
      textHeight: 18,
    });
    const margin = 8;
    expect(layout.bubble.x).toBeGreaterThanOrEqual(margin);
    expect(layout.bubble.x + layout.bubble.width).toBeLessThanOrEqual(640 - margin);
  });

  it('keeps bubble inside canvas margin when anchor is near left edge', () => {
    const layout = computeBubbleLayout({
      anchor: { x: 10, y: 110 },
      textWidth: 200,
      textHeight: 18,
    });
    expect(layout.bubble.x).toBeGreaterThanOrEqual(8);
  });

  it('places tail tip at the anchor x', () => {
    const layout = computeBubbleLayout({
      anchor,
      textWidth: 120,
      textHeight: 18,
    });
    const tip = layout.tail[2];
    expect(tip.x).toBe(anchor.x);
  });

  it('keeps tail base on the bubble bottom edge', () => {
    const layout = computeBubbleLayout({
      anchor,
      textWidth: 120,
      textHeight: 18,
    });
    const bubbleBottom = layout.bubble.y + layout.bubble.height;
    expect(layout.tail[0].y).toBe(bubbleBottom);
    expect(layout.tail[1].y).toBe(bubbleBottom);
  });

  it('honors the visual style: cream bg + cubicle gray-blue border are exposed for reuse', () => {
    // Style constants are exported so other dialog props (T11 sticky
    // notes) can match without duplicating; this test pins them.
    expect(SPEECH_BUBBLE_STYLE.BG_COLOR).toBe(0xe8e0cc);
    expect(SPEECH_BUBBLE_STYLE.BORDER_COLOR).toBe(0x5a7080);
  });
});
