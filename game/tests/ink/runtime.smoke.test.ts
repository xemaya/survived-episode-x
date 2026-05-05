// Smoke test: verify InkRuntime can load episode-1.json + step through
// the opening morning_briefing.
//
// This is the closest we can get to "end-to-end demo" in a headless test
// runner — actual PixiJS rendering requires a browser. But this proves the
// ink runtime boot path works.

import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import { InkRuntime, type InkStoryStep } from '../../src/ink/runtime';

const EPISODE_1_JSON = resolve(__dirname, '../../public/ink/episode-1.json');

describe('InkRuntime smoke (episode-1)', () => {
  it('loads episode-1.json without throwing', () => {
    const json = readFileSync(EPISODE_1_JSON, 'utf-8');
    const r = new InkRuntime();
    r.loadStoryFromJson(json);
    expect(r.isLoaded).toBe(true);
  });

  // Helpers — episode-1 now contains `# pagebreak` at scene boundaries
  // so a single step()/selectChoice() may return paused=true with no
  // text. Drain past pauses to reach the next interaction point.
  function startDrain(r: InkRuntime): { text: string; tags: string[] } {
    return drainFrom(r.step(), r);
  }

  function drainFrom(initial: InkStoryStep, r: InkRuntime): { text: string; tags: string[] } {
    let combined = initial.text;
    const allTags: string[] = initial.tags.map((t) => t.key);
    let s = initial;
    while (s.paused) {
      s = r.step();
      combined += s.text;
      for (const t of s.tags) allTags.push(t.key);
    }
    return { text: combined, tags: allTags };
  }

  it('can divert to episode_1 knot and step initial morning_briefing text', () => {
    const json = readFileSync(EPISODE_1_JSON, 'utf-8');
    const r = new InkRuntime();
    r.loadStoryFromJson(json);
    r.divertTo('episode_1');

    const drained = startDrain(r);

    // Initial morning_briefing prints multiple paragraphs of laoxia voice.
    // Verify we got SOMETHING and it includes the signature opening.
    expect(drained.text.length).toBeGreaterThan(50);
    expect(drained.text).toMatch(/闹钟响了 3 次/);
    // Expects the "陈笑天" name introduction line
    expect(drained.text).toMatch(/陈笑天/);
  });

  it('emits scene/time tags between intro and morning_briefing', () => {
    const json = readFileSync(EPISODE_1_JSON, 'utf-8');
    const r = new InkRuntime();
    r.loadStoryFromJson(json);
    r.divertTo('episode_1');
    const drained = startDrain(r);

    expect(drained.tags).toContain('scene');
    expect(drained.tags).toContain('time');
  });

  it('selecting choice [开始今日] advances story to event_1_vivian', () => {
    const json = readFileSync(EPISODE_1_JSON, 'utf-8');
    const r = new InkRuntime();
    r.loadStoryFromJson(json);
    r.divertTo('episode_1');
    startDrain(r); // morning_briefing
    // Sitting on the "[开始今日]" choice now; selectChoice already
    // step()s internally — chain a drain off its return value rather
    // than calling step() again (which would find content drained).
    const initial = r.selectChoice(0);
    const drained = drainFrom(initial, r);

    // Event 1.1: Vivian "嗨～来啦～"
    expect(drained.text).toMatch(/Vivian|嗨/);
  });

  it('VAR kpi/money/state initialize to defaults from episode-1.ink', () => {
    const json = readFileSync(EPISODE_1_JSON, 'utf-8');
    const r = new InkRuntime();
    r.loadStoryFromJson(json);
    expect(r.getVar<number>('kpi')).toBe(100);
    expect(r.getVar<number>('money')).toBe(5500);
    expect(r.getVar<number>('state')).toBe(80);
  });

  it('serialize + load state preserves story position and VAR values', () => {
    const json = readFileSync(EPISODE_1_JSON, 'utf-8');
    const r1 = new InkRuntime();
    r1.loadStoryFromJson(json);
    r1.divertTo('episode_1');
    r1.step();
    r1.setVar('kpi', 142);
    const stateJson = r1.serializeState();

    const r2 = new InkRuntime();
    r2.loadStoryFromJson(json);
    r2.loadState(stateJson);
    expect(r2.getVar<number>('kpi')).toBe(142);
  });
});
