import { beforeEach, describe, expect, it, vi } from 'vitest';
import { FlowDispatcher } from '../../src/flow/dispatcher';
import type { SceneState } from '../../src/flow/scene-state';

const day1: SceneState = { kind: 'action_day', day: 1, phase: 'morning' };
const day1Pause: SceneState = { kind: 'pause', resumeTo: day1 };

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
    flow.request(day1);
    expect(listener).toHaveBeenCalledTimes(1);
    expect(listener).toHaveBeenCalledWith(day1, { kind: 'main_menu' });
    expect(flow.state).toEqual(day1);
  });

  it('throws on illegal transition without changing state', () => {
    flow.request(day1);
    expect(() => flow.request({ kind: 'pause', resumeTo: { kind: 'main_menu' } })).toThrow(
      /Illegal transition/,
    );
    expect(flow.state).toEqual(day1);
  });

  it('throws on re-entrant request from inside a listener', () => {
    flow.subscribe(() => {
      flow.request({ kind: 'main_menu' });
    });
    expect(() => flow.request(day1)).toThrow(/Re-entrant dispatch/);
  });

  it('unsubscribe stops emissions to that listener', () => {
    const listener = vi.fn();
    const unsub = flow.subscribe(listener);
    flow.request(day1);
    unsub();
    flow.request(day1Pause);
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
    expect(() => flow.request(day1)).not.toThrow();
  });
});
