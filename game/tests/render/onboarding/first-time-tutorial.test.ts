import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import {
  hasSeenTutorial,
  markTutorialSeen,
} from '../../../src/render/onboarding/first-time-tutorial';

// jsdom isn't available; stub a minimal localStorage on the global so
// the helper's `window.localStorage` lookups resolve. tests run in
// node env (default) — globalThis is the same object the helper
// closes over via `window` (defined below).

interface Stub {
  data: Map<string, string>;
}

function makeLocalStorageStub(): { stub: Stub; api: Storage } {
  const stub: Stub = { data: new Map() };
  const api: Storage = {
    get length() {
      return stub.data.size;
    },
    clear: () => stub.data.clear(),
    getItem: (key) => stub.data.get(key) ?? null,
    setItem: (key, value) => {
      stub.data.set(key, value);
    },
    removeItem: (key) => {
      stub.data.delete(key);
    },
    key: (i) => Array.from(stub.data.keys())[i] ?? null,
  };
  return { stub, api };
}

const { api: localStorageStub } = makeLocalStorageStub();

beforeEach(() => {
  // biome-ignore lint/suspicious/noExplicitAny: test-only stub of window
  (globalThis as any).window = { localStorage: localStorageStub };
  localStorageStub.removeItem('survived:tutorial_seen');
});

afterEach(() => {
  localStorageStub.removeItem('survived:tutorial_seen');
});

describe('first-time-tutorial flag helpers (Q-K-2nd / Bug #23 second half)', () => {
  it('hasSeenTutorial returns false on a fresh slate', () => {
    expect(hasSeenTutorial()).toBe(false);
  });

  it('markTutorialSeen → hasSeenTutorial reports true on subsequent reads', () => {
    markTutorialSeen();
    expect(hasSeenTutorial()).toBe(true);
  });

  it('flag persists across multiple reads (idempotent)', () => {
    markTutorialSeen();
    expect(hasSeenTutorial()).toBe(true);
    expect(hasSeenTutorial()).toBe(true);
  });

  it('flag is keyed under the namespaced "survived:tutorial_seen"', () => {
    markTutorialSeen();
    expect(localStorageStub.getItem('survived:tutorial_seen')).toBe('1');
  });
});
