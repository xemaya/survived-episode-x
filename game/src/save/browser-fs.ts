// Browser fallback for SaveFs — uses localStorage when running in plain Vite
// dev (no Tauri host). Production = Tauri AppData via tauri-fs.ts.
//
// Detection: tauri injects window.__TAURI_INTERNALS__. If absent, we're in
// a plain browser context and the Tauri fs plugin's invoke() will throw on
// every call. Use this fallback instead.

import type { SaveFs } from './tauri-fs';

const KEY_PREFIX = 'survived:fs:';

export const browserFs: SaveFs = {
  async exists(path) {
    return localStorage.getItem(KEY_PREFIX + path) !== null;
  },
  async read(path) {
    const v = localStorage.getItem(KEY_PREFIX + path);
    if (v === null) throw new Error(`browserFs.read: not found: ${path}`);
    return v;
  },
  async writeAtomic(path, content) {
    // localStorage is synchronous + naturally atomic for a single-page session.
    localStorage.setItem(KEY_PREFIX + path, content);
  },
  async delete(path) {
    localStorage.removeItem(KEY_PREFIX + path);
  },
  async ensureDir(_path) {
    // localStorage has no concept of directories — no-op.
  },
};

// True when running in a Tauri webview (window.__TAURI_INTERNALS__ exists).
export function hasTauriHost(): boolean {
  return (
    typeof window !== 'undefined' &&
    // biome-ignore lint/suspicious/noExplicitAny: Tauri injects globals untyped
    (window as any).__TAURI_INTERNALS__ !== undefined
  );
}
