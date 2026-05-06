import { describe, expect, it } from 'vitest';
import { type ParsedTag, parseTag } from '../../../src/ink/runtime';
import {
  MONOLOGUE,
  NARRATION,
  detectSource,
  sourceLabel,
  sourcesEqual,
} from '../../../src/render/dialog/source-detector';

const tagsFrom = (...raws: string[]): ParsedTag[] => raws.map((r) => parseTag(r));

describe('detectSource — # speaker tag (primary)', () => {
  it('protagonist tag → monologue source', () => {
    expect(detectSource('我还能做什么。', tagsFrom('speaker: protagonist'))).toEqual(MONOLOGUE);
  });

  it('lisa tag → npc source with display name "Lisa"', () => {
    expect(detectSource('你看下这个行不行。', tagsFrom('speaker: lisa'))).toEqual({
      kind: 'npc',
      name: 'Lisa',
    });
  });

  it('wang_director tag → npc source "王总监"', () => {
    expect(detectSource('开会。', tagsFrom('speaker: wang_director'))).toEqual({
      kind: 'npc',
      name: '王总监',
    });
  });

  it('food_court_auntie tag → npc source "食堂阿姨"', () => {
    expect(detectSource('番茄炒蛋', tagsFrom('speaker: food_court_auntie'))).toEqual({
      kind: 'npc',
      name: '食堂阿姨',
    });
  });

  it('unknown speaker id → falls through to narration', () => {
    expect(detectSource('hello', tagsFrom('speaker: nobody_here'))).toEqual(NARRATION);
  });

  it('speaker tag wins over legacy "Lisa：" prefix', () => {
    expect(detectSource('David：嗯。', tagsFrom('speaker: lisa'))).toEqual({
      kind: 'npc',
      name: 'Lisa',
    });
  });
});

describe('detectSource — legacy Name：prefix fallback', () => {
  it('plain "Lisa：dialog" → npc Lisa', () => {
    expect(detectSource('Lisa：你看下这个。', [])).toEqual({ kind: 'npc', name: 'Lisa' });
  });

  it('bold "**David**：dialog" → npc David', () => {
    expect(detectSource('**David**：嗯，我看看。', [])).toEqual({ kind: 'npc', name: 'David' });
  });

  it('alias "大伟：" normalizes to David', () => {
    expect(detectSource('大伟：嗯。', [])).toEqual({ kind: 'npc', name: 'David' });
  });

  it('alias "周哥：" normalizes to 老周', () => {
    expect(detectSource('周哥：你也加班啊。', [])).toEqual({ kind: 'npc', name: '老周' });
  });

  it('"IT 小马：" with full-width space → npc IT 小马', () => {
    expect(detectSource('IT 小马：你重启一下。', [])).toEqual({ kind: 'npc', name: 'IT 小马' });
  });

  it('non-NPC quote like "桌面便利贴：…" → narration (no false positive)', () => {
    expect(detectSource('桌面便利贴："活到周五"', [])).toEqual(NARRATION);
  });

  it('protagonist quote "你：" → narration (no false positive)', () => {
    expect(detectSource('你："睡觉。"', [])).toEqual(NARRATION);
  });
});

describe('detectSource — whole-italic monologue', () => {
  it('"_她还相信。_" → monologue', () => {
    expect(detectSource('_她还相信。_', [])).toEqual(MONOLOGUE);
  });

  it('multi-line whole-italic paragraph → monologue', () => {
    expect(detectSource('_他不会发现的。\n或者他发现了，他不会说什么。_', [])).toEqual(MONOLOGUE);
  });

  it('partial italic in middle of sentence → narration (NOT monologue)', () => {
    expect(detectSource('你看着她的_新发型_，不说话。', [])).toEqual(NARRATION);
  });
});

describe('detectSource — defaults', () => {
  it('plain narration text → narration', () => {
    expect(detectSource('你 9:14 走到工位区。', [])).toEqual(NARRATION);
  });

  it('empty text + no tags → narration', () => {
    expect(detectSource('', [])).toEqual(NARRATION);
  });

  it('whitespace-only text → narration', () => {
    expect(detectSource('   \n  ', [])).toEqual(NARRATION);
  });
});

describe('sourcesEqual', () => {
  it('two narrations equal', () => {
    expect(sourcesEqual(NARRATION, NARRATION)).toBe(true);
  });

  it('two monologues equal', () => {
    expect(sourcesEqual(MONOLOGUE, MONOLOGUE)).toBe(true);
  });

  it('two npcs with same name equal', () => {
    expect(sourcesEqual({ kind: 'npc', name: 'Lisa' }, { kind: 'npc', name: 'Lisa' })).toBe(true);
  });

  it('two npcs with different names NOT equal', () => {
    expect(sourcesEqual({ kind: 'npc', name: 'Lisa' }, { kind: 'npc', name: 'David' })).toBe(false);
  });

  it('narration vs monologue NOT equal', () => {
    expect(sourcesEqual(NARRATION, MONOLOGUE)).toBe(false);
  });

  it('narration vs npc NOT equal', () => {
    expect(sourcesEqual(NARRATION, { kind: 'npc', name: 'Lisa' })).toBe(false);
  });
});

describe('sourceLabel', () => {
  it('narration → "视角"', () => {
    expect(sourceLabel(NARRATION)).toBe('视角');
  });

  it('monologue → "笑天"', () => {
    expect(sourceLabel(MONOLOGUE)).toBe('笑天');
  });

  it('npc Lisa → "Lisa"', () => {
    expect(sourceLabel({ kind: 'npc', name: 'Lisa' })).toBe('Lisa');
  });

  it('npc 王总监 → "王总监"', () => {
    expect(sourceLabel({ kind: 'npc', name: '王总监' })).toBe('王总监');
  });
});
