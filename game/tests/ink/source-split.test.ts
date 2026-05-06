// Q-R: source-boundary auto-split test (avg-architecture.md §1.4).
//
// Compiles inline ink that mixes narration / monologue / NPC speaker
// chunks within a single beat and verifies `InkRuntime.step()`
// auto-splits at every source boundary so each step carries one
// source only.

import { Compiler } from 'inkjs/compiler/Compiler';
import { describe, expect, it } from 'vitest';
import { InkRuntime } from '../../src/ink/runtime';

function compileInline(source: string): string {
  const compiler = new Compiler(source);
  const story = compiler.Compile();
  return story.ToJson() ?? '';
}

describe('InkRuntime — Q-R source-boundary auto-split', () => {
  it('splits narration → monologue at the italic boundary', () => {
    const source = `
你 9:14 走到工位区。
_她还相信。_
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const first = r.step();
    expect(first.text).toMatch(/9:14/);
    expect(first.text).not.toMatch(/她还相信/);
    expect(first.paused).toBe(true);

    const second = r.step();
    expect(second.text).toMatch(/她还相信/);
    expect(second.ended).toBe(true);
  });

  it('splits narration → NPC at a # speaker tag boundary', () => {
    const source = `
你回头看了她一眼。
新剪的。 # speaker: lisa
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const first = r.step();
    expect(first.text).toMatch(/你回头/);
    expect(first.text).not.toMatch(/新剪的/);
    expect(first.paused).toBe(true);

    const second = r.step();
    expect(second.text).toMatch(/新剪的/);
    expect(second.tags.some((t) => t.key === 'speaker' && t.value === 'lisa')).toBe(true);
    expect(second.ended).toBe(true);
  });

  it('splits between two different NPC speakers in the same beat', () => {
    const source = `
你看下这个。 # speaker: lisa
嗯。 # speaker: david
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const first = r.step();
    expect(first.text).toMatch(/你看下这个/);
    expect(first.text).not.toMatch(/嗯/);
    expect(first.paused).toBe(true);

    const second = r.step();
    expect(second.text.trim()).toMatch(/^嗯/);
    expect(second.ended).toBe(true);
  });

  it('does NOT split when consecutive chunks share the same source', () => {
    const source = `
你 9:14 走到工位区。
A 区——Lisa 工位斜对角。
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const first = r.step();
    expect(first.text).toMatch(/9:14/);
    expect(first.text).toMatch(/A 区/);
    expect(first.paused).toBe(false);
    expect(first.ended).toBe(true);
  });

  it('does NOT split on consecutive same-NPC speaker chunks', () => {
    const source = `
你看下这个。 # speaker: lisa
真的不行吗？ # speaker: lisa
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const first = r.step();
    expect(first.text).toMatch(/你看下这个/);
    expect(first.text).toMatch(/真的不行/);
    expect(first.paused).toBe(false);
    expect(first.ended).toBe(true);
  });

  it('whitespace-only chunks pass through without splitting', () => {
    // Blank ink lines emit empty chunks; they shouldn't force a virtual
    // pagebreak (no source switch — they have no source on their own).
    const source = `
你 9:14 走到工位区。

A 区——Lisa 工位斜对角。
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const first = r.step();
    expect(first.text).toMatch(/9:14/);
    expect(first.text).toMatch(/A 区/);
    expect(first.paused).toBe(false);
    expect(first.ended).toBe(true);
  });

  it('explicit # pagebreak still wins (works alongside source split)', () => {
    const source = `
A.
# pagebreak
B.
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const first = r.step();
    expect(first.text.trim()).toBe('A.');
    expect(first.paused).toBe(true);

    const second = r.step();
    expect(second.text).toMatch(/B/);
    expect(second.ended).toBe(true);
  });
});
