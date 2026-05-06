// Q-4 / T20 prep — path-interceptor unit tests + a runtime integration
// test using inline-compiled ink.

import { Compiler } from 'inkjs/compiler/Compiler';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { PathInterceptor, pathInterceptor } from '../../src/ink/path-interceptor';
import { InkRuntime } from '../../src/ink/runtime';

afterEach(() => {
  pathInterceptor.clear();
});

function compileInline(source: string): string {
  return new Compiler(source).Compile().ToJson() ?? '';
}

const FAKE_CTX = {
  vars: new Map<string, unknown>(),
  getVar<T = unknown>(name: string): T | null {
    return (this.vars.get(name) ?? null) as T | null;
  },
};

describe('PathInterceptor (pure helper)', () => {
  it('returns null when no rules are registered', () => {
    const i = new PathInterceptor();
    expect(i.shouldRedirect('day_56_event_3', FAKE_CTX)).toBeNull();
  });

  it('returns target when stitch + condition both match', () => {
    const i = new PathInterceptor();
    i.register({
      beforeStitch: 'day_56_event_3',
      condition: () => true,
      target: 'day_56_path_d_unread',
    });
    expect(i.shouldRedirect('day_56_event_3', FAKE_CTX)).toBe('day_56_path_d_unread');
  });

  it('returns null when condition fails', () => {
    const i = new PathInterceptor();
    i.register({
      beforeStitch: 'day_56_event_3',
      condition: () => false,
      target: 'never_taken',
    });
    expect(i.shouldRedirect('day_56_event_3', FAKE_CTX)).toBeNull();
  });

  it('matches by exact stitch name (no prefix games)', () => {
    const i = new PathInterceptor();
    i.register({
      beforeStitch: 'day_56_event_3',
      condition: () => true,
      target: 'day_56_path_d_unread',
    });
    expect(i.shouldRedirect('day_56_event_3', FAKE_CTX)).toBe('day_56_path_d_unread');
    expect(i.shouldRedirect('day_56_event_30', FAKE_CTX)).toBeNull();
    expect(i.shouldRedirect('day_56_event_3.0', FAKE_CTX)).toBeNull();
  });

  it('reads vars via the ctx.getVar surface', () => {
    const i = new PathInterceptor();
    const ctx = {
      vars: new Map<string, unknown>([['sick_count', 4]]),
      getVar<T = unknown>(name: string): T | null {
        return (this.vars.get(name) ?? null) as T | null;
      },
    };
    i.register({
      beforeStitch: 'day_56_event_3',
      condition: (c) => (c.getVar<number>('sick_count') ?? 0) >= 4,
      target: 'day_56_path_d_unread',
    });
    expect(i.shouldRedirect('day_56_event_3', ctx)).toBe('day_56_path_d_unread');
    ctx.vars.set('sick_count', 0);
    expect(i.shouldRedirect('day_56_event_3', ctx)).toBeNull();
  });

  it('returns the FIRST matching rule when multiple apply', () => {
    const i = new PathInterceptor();
    i.register({
      beforeStitch: 'day_56_event_3',
      condition: () => true,
      target: 'first_target',
    });
    i.register({
      beforeStitch: 'day_56_event_3',
      condition: () => true,
      target: 'second_target',
    });
    expect(i.shouldRedirect('day_56_event_3', FAKE_CTX)).toBe('first_target');
  });

  it('register() returns an unregister fn that removes the rule', () => {
    const i = new PathInterceptor();
    const unregister = i.register({
      beforeStitch: 'day_56_event_3',
      condition: () => true,
      target: 'day_56_path_d_unread',
    });
    expect(i.list()).toHaveLength(1);
    unregister();
    expect(i.list()).toHaveLength(0);
    expect(i.shouldRedirect('day_56_event_3', FAKE_CTX)).toBeNull();
  });

  it('clear() drops every registered rule', () => {
    const i = new PathInterceptor();
    i.register({ beforeStitch: 'a', condition: () => true, target: 't' });
    i.register({ beforeStitch: 'b', condition: () => true, target: 't' });
    i.clear();
    expect(i.list()).toHaveLength(0);
  });
});

describe('PathInterceptor + InkRuntime integration (checkpoint tag hook)', () => {
  it('redirects ink to target stitch when checkpoint + condition match', () => {
    // Designer marks the interceptable stitch with `# checkpoint:`.
    // The chunk that emits the checkpoint tag is discarded so the
    // default-path text never reaches the player.
    const source = `
VAR sick_count = 4
-> day_56_event_3

=== day_56_event_3 ===
# checkpoint: day_56_event_3
default text — would render if not redirected.
-> END

=== day_56_path_d_unread ===
unread message text.
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    pathInterceptor.register({
      beforeStitch: 'day_56_event_3',
      condition: (ink) => (ink.getVar<number>('sick_count') ?? 0) >= 4,
      target: 'day_56_path_d_unread',
    });

    const step = r.step();
    expect(step.text).toMatch(/unread message/);
    expect(step.text).not.toMatch(/default text/);
  });

  it('does NOT redirect when condition fails (story takes default path)', () => {
    const source = `
VAR sick_count = 0
-> day_56_event_3

=== day_56_event_3 ===
# checkpoint: day_56_event_3
default text — would render if not redirected.
-> END

=== day_56_path_d_unread ===
unread message text.
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    pathInterceptor.register({
      beforeStitch: 'day_56_event_3',
      condition: (ink) => (ink.getVar<number>('sick_count') ?? 0) >= 4,
      target: 'day_56_path_d_unread',
    });

    const step = r.step();
    expect(step.text).toMatch(/default text/);
    expect(step.text).not.toMatch(/unread message/);
  });

  it('does NOT redirect when no rule is registered for the checkpoint tag', () => {
    const source = `
# checkpoint: unknown_stitch
hello world
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    const step = r.step();
    expect(step.text).toMatch(/hello world/);
  });

  it('chains multiple checkpoint redirects (each rule fires independently)', () => {
    // Path through: start → event_3 (cond met → redirect to inter)
    //   → inter (cond met → redirect to final).
    const source = `
VAR sick_count = 4
VAR hero_count = 6
-> day_56_event_3

=== day_56_event_3 ===
# checkpoint: day_56_event_3
default A.
-> END

=== day_56_inter ===
# checkpoint: day_56_inter
default B.
-> END

=== day_56_final ===
final text.
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);

    pathInterceptor.register({
      beforeStitch: 'day_56_event_3',
      condition: (ink) => (ink.getVar<number>('sick_count') ?? 0) >= 4,
      target: 'day_56_inter',
    });
    pathInterceptor.register({
      beforeStitch: 'day_56_inter',
      condition: (ink) => (ink.getVar<number>('hero_count') ?? 0) >= 5,
      target: 'day_56_final',
    });

    const step = r.step();
    expect(step.text).toMatch(/final text/);
    expect(step.text).not.toMatch(/default A/);
    expect(step.text).not.toMatch(/default B/);
  });

  it('non-fatal when story is plain (no checkpoint tags, no rules)', () => {
    const source = `
hello world
-> END
`;
    const json = compileInline(source);
    const r = new InkRuntime();
    r.loadStoryFromJson(json);
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    const step = r.step();
    expect(step.text).toMatch(/hello world/);
    warn.mockRestore();
  });
});
