import { beforeEach, describe, expect, it, vi } from 'vitest';
import { FlowDispatcher } from '../../src/flow/dispatcher';
import type { SceneState } from '../../src/flow/scene-state';

const morningBriefing1: SceneState = { kind: 'morning_briefing', day: 1 };
const day1: SceneState = { kind: 'action_day', day: 1, phase: 'morning' };

describe('FlowDispatcher', () => {
  let flow: FlowDispatcher;

  beforeEach(() => {
    flow = new FlowDispatcher();
  });

  it('starts in main_menu state', () => {
    expect(flow.state).toEqual({ kind: 'main_menu' });
  });

  it('emits to subscribers on legal transition', () => {
    const listener = vi.fn();
    flow.subscribe(listener);
    // main_menu → morning_briefing is the new legal first step
    flow.request(morningBriefing1);
    expect(listener).toHaveBeenCalledTimes(1);
    expect(listener).toHaveBeenCalledWith(morningBriefing1, { kind: 'main_menu' });
    expect(flow.state).toEqual(morningBriefing1);
  });

  it('throws on illegal transition without changing state', () => {
    flow.request(morningBriefing1);
    flow.request(day1); // morning_briefing → action_day is legal
    expect(() => flow.request({ kind: 'pause', resumeTo: { kind: 'main_menu' } })).toThrow(
      /Illegal transition/,
    );
    expect(flow.state).toEqual(day1);
  });

  it('throws on re-entrant request from inside a listener', () => {
    flow.subscribe(() => {
      flow.request({ kind: 'main_menu' });
    });
    // morning_briefing fires the listener which re-entrantly tries main_menu
    expect(() => flow.request(morningBriefing1)).toThrow(/Re-entrant dispatch/);
  });

  it('unsubscribe stops emissions to that listener', () => {
    const listener = vi.fn();
    const unsub = flow.subscribe(listener);
    flow.request(morningBriefing1); // +1
    unsub();
    flow.request(day1); // should NOT fire listener
    expect(listener).toHaveBeenCalledTimes(1);
  });

  it('subscribe returns a function that is safe to call twice', () => {
    const listener = vi.fn();
    const unsub = flow.subscribe(listener);
    expect(() => {
      unsub();
      unsub();
    }).not.toThrow();
  });

  it('re-entrancy guard releases on illegal-transition throw (no permanent lock)', () => {
    expect(() => flow.request({ kind: 'pause', resumeTo: { kind: 'main_menu' } })).toThrow();
    // Recovery: a legal transition still works
    expect(() => flow.request(morningBriefing1)).not.toThrow();
  });
});
