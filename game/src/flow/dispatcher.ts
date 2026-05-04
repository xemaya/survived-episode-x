import { type SceneState, describe } from './scene-state';
import { isLegalTransition } from './transitions';

export type FlowListener = (next: SceneState, prev: SceneState) => void;

// Single-dispatch FSM. Only this class is allowed to mutate scene state;
// every consumer reads via `state` and reacts via `subscribe`. The class
// is exported for testing — production code should use the `flow` singleton.
//
// Re-entrancy guard: a listener cannot call `request()` synchronously.
// Use `queueMicrotask(() => flow.request(...))` if you must chain.
export class FlowDispatcher {
  private current: SceneState = { kind: 'main_menu' };
  private listeners = new Set<FlowListener>();
  private inDispatch = false;

  get state(): Readonly<SceneState> {
    return this.current;
  }

  subscribe(fn: FlowListener): () => void {
    this.listeners.add(fn);
    let unsubscribed = false;
    return () => {
      if (unsubscribed) return;
      unsubscribed = true;
      this.listeners.delete(fn);
    };
  }

  request(target: SceneState): void {
    if (this.inDispatch) {
      throw new Error(
        'Re-entrant dispatch — Red Line 4: only flow owns transitions. Use queueMicrotask if you must chain.',
      );
    }
    if (!isLegalTransition(this.current, target)) {
      throw new Error(`Illegal transition ${describe(this.current)} → ${describe(target)}`);
    }
    this.inDispatch = true;
    try {
      const prev = this.current;
      this.current = target;
      for (const l of this.listeners) l(target, prev);
    } finally {
      this.inDispatch = false;
    }
  }

  // One-time boot-state override. Bypasses the legality matrix because
  // the initial state is set programmatically (e.g. resumed from save,
  // or save_corrupt dialog). Must be called BEFORE any subscriber.
  setInitialState(state: SceneState): void {
    this.current = state;
  }
}

// Singleton — every production import goes through this instance.
// Do NOT construct FlowDispatcher elsewhere (lint-redline-4 enforces).
export const flow = new FlowDispatcher();
