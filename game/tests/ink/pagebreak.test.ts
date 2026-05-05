// Q-2 Option B: # pagebreak step-loop break test.
//
// Compiles inline ink containing `# pagebreak` tags and verifies
// `InkRuntime.step()` stops at the pagebreak, returns the accumulated
// text + paused=true, and that a follow-up step() resumes from after
// the pagebreak.

import { Compiler } from 'inkjs/compiler/Compiler';
import { describe, expect, it } from 'vitest';
import { InkRuntime } from '../../src/ink/runtime';

function compileInline(source: string): string {
  const compiler = new Compiler(source);
  const story = compiler.Compile();
  return story.ToJson() ?? '';
}

describe('InkRuntime # pagebreak', () => {
  // Designer idiom (Q-2 GM reply): place `# pagebreak` on its own
  // line between the LAST text of a beat and the divert to the next
  // stitch. ink attaches the tag to the FOLLOWING chunk, so the
  // runtime stashes that chunk on `pendingChunk` and surfaces it on
  // the next step() — the player sees a clean break with the
  // "previous beat" text on screen, then the post-break content
  // appears after a click.
  it('breaks step() loop on # pagebreak and returns paused=true with prior text', () => {
    const source = `
hello world
# pagebreak
-> beat2

=== beat2 ===
second beat
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const first = r.step();
    expect(first.text).toMatch(/hello world/);
    expect(first.text).not.toMatch(/second beat/);
    expect(first.paused).toBe(true);
    expect(first.ended).toBe(false);
  });

  it('resumes from after the pagebreak on the next step()', () => {
    const source = `
hello world
# pagebreak
-> beat2

=== beat2 ===
second beat
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    r.step(); // paused at pagebreak
    const second = r.step();
    expect(second.text).toMatch(/second beat/);
    expect(second.paused).toBe(false);
    expect(second.ended).toBe(true);
  });

  it('handles back-to-back pagebreaks (3 segments connected by diverts)', () => {
    const source = `
A
# pagebreak
-> b

=== b ===
B
# pagebreak
-> c

=== c ===
C
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const s1 = r.step();
    expect(s1.text).toMatch(/A/);
    expect(s1.paused).toBe(true);

    const s2 = r.step();
    expect(s2.text).toMatch(/B/);
    expect(s2.paused).toBe(true);

    const s3 = r.step();
    expect(s3.text).toMatch(/C/);
    expect(s3.paused).toBe(false);
    expect(s3.ended).toBe(true);
  });

  it('keeps `paused: false` when no pagebreak appears (legacy story shape)', () => {
    const source = `
hello world
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const step = r.step();
    expect(step.text).toMatch(/hello world/);
    expect(step.paused).toBe(false);
    expect(step.ended).toBe(true);
  });

  it('ended remains false when paused=true and more content lies ahead', () => {
    const source = `
hello
# pagebreak
-> tail

=== tail ===
done
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const first = r.step();
    expect(first.paused).toBe(true);
    expect(first.ended).toBe(false);
    // Verify behaviorally that content lies ahead — the next step
    // surfaces it (canContinue may already be false at this point
    // because ink consumed the post-break chunk into pendingChunk).
    const second = r.step();
    expect(second.text).toMatch(/done/);
  });

  it('strips the pagebreak tag itself from the post-resume tag stream', () => {
    const source = `
A
# pagebreak
# scene: kitchen
B
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    r.step(); // paused
    const after = r.step();
    expect(after.text).toMatch(/B/);
    // pagebreak tag should be consumed; other tags (scene) survive.
    expect(after.tags.some((t) => t.key === 'pagebreak')).toBe(false);
    expect(after.tags.some((t) => t.key === 'scene')).toBe(true);
  });

  it('loadState clears any pending pagebreak chunk', () => {
    const source = `
A
# pagebreak
-> b

=== b ===
B
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);
    r.step(); // paused; B is stashed

    // Round-trip via state JSON. After load, the stash should be
    // cleared so the player doesn't get a phantom "B" they never saw.
    const stateJson = r.serializeState();
    const r2 = new InkRuntime();
    r2.loadStoryFromJson(json);
    r2.loadState(stateJson);

    // Whatever the next step() returns, it must NOT reuse a stale
    // pendingChunk from the original runtime.
    const next = r2.step();
    expect(next.text).not.toMatch(/^B$/);
  });

  it('selectChoice returned step also carries paused=false default', () => {
    const source = `
prompt
* [yes] -> done
* [no] -> done
=== done ===
finished
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    r.step(); // drains "prompt" into choices
    const after = r.selectChoice(0);
    expect(after.paused).toBe(false);
    expect(after.text).toMatch(/finished/);
  });

  it('out-of-bounds selectChoice returns shape with paused=false', () => {
    const source = `
prompt
* [yes] -> done
=== done ===
finished
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    r.step(); // surfaces choices
    const bogus = r.selectChoice(99);
    expect(bogus.paused).toBe(false);
    expect(bogus.ended).toBe(true);
  });
});
