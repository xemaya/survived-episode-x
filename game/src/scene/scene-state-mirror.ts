// Scene-state mirror — TS-side cache of the latest values seen on
// `# scene:` / `# npc:` / `# time:` / `# weather:` ink tags.
//
// This is a stop-gap before T04 (full scene registry + transitions)
// and T05/T06 (NPC sprite slots) land. It at least makes those tag
// streams visible to the rest of the engine instead of being parsed-
// then-dropped (QA Bug #8 root cause).
//
// API surface is read-mostly: subscribers register a callback per key
// and receive the new value when it changes. Tag handler updates the
// mirror, which dispatches to subscribers.
//
// When T04 lands the scene-id field becomes the input to a transition
// machine; for now it just logs unknown scenes and stores the value.

import { tagDispatcher } from '@/ink/tag-interceptors';

export type SceneStateKey = 'scene' | 'npc' | 'time' | 'weather' | 'speaker';

export interface SceneStateSnapshot {
  scene: string | null;
  npc: string | null;
  time: string | null;
  weather: string | null;
  /** Latest `# speaker: <id>` value per Q-1 contract (id → NPC sprite slot).
   * `null` until first tag fires. After Q-R, source detection lives in
   * `source-detector.ts`; this field is kept for future NPC-sprite-slot
   * (T05/T06) mounting since the dialog renderer no longer reads it. */
  speaker: string | null;
}

const KNOWN_SCENES = new Set([
  'workstation',
  'phone',
  'monitor_modal',
  'endgame',
  'modal_overlay',
  // Pre-game / story-only scene labels — accepted as-is, no mount yet.
  'intro',
  'home',
  'reception',
  'meeting_room',
  'cafeteria',
  'elevator',
]);

type Listener = (value: string) => void;

class SceneStateMirror {
  private cache: SceneStateSnapshot = {
    scene: null,
    npc: null,
    time: null,
    weather: null,
    speaker: null,
  };
  private listeners: Record<SceneStateKey, Set<Listener>> = {
    scene: new Set(),
    npc: new Set(),
    time: new Set(),
    weather: new Set(),
    speaker: new Set(),
  };

  get snapshot(): Readonly<SceneStateSnapshot> {
    return this.cache;
  }

  /** Latest value observed for a given key (null until first tag). */
  get<K extends SceneStateKey>(key: K): SceneStateSnapshot[K] {
    return this.cache[key];
  }

  /** Subscribe to changes; returns unsubscribe. */
  on(key: SceneStateKey, fn: Listener): () => void {
    this.listeners[key].add(fn);
    return () => {
      this.listeners[key].delete(fn);
    };
  }

  /** Apply a tag value (used by tag handler — also exposed for tests). */
  set(key: SceneStateKey, value: string): void {
    if (this.cache[key] === value) return;
    this.cache[key] = value;
    if (key === 'scene' && !KNOWN_SCENES.has(value)) {
      console.warn(
        `[scene-state] unknown scene id "${value}" — engine will continue using current scene; add to KNOWN_SCENES or ship T04 scene composer.`,
      );
    }
    for (const fn of this.listeners[key]) fn(value);
  }

  /** Drop all listeners + cache (test cleanup). */
  reset(): void {
    this.cache = { scene: null, npc: null, time: null, weather: null, speaker: null };
    for (const k of Object.keys(this.listeners) as SceneStateKey[]) {
      this.listeners[k].clear();
    }
  }
}

export const sceneState = new SceneStateMirror();

/** Register all four passthrough listeners on the global tagDispatcher.
 * Returns a teardown that removes them. Idempotent: calling twice
 * registers two sets, so callers must hang onto the teardown. */
export function installSceneStateTagHandler(): () => void {
  const offs: Array<() => void> = [
    tagDispatcher.on('scene', (t) => sceneState.set('scene', t.value)),
    tagDispatcher.on('npc', (t) => sceneState.set('npc', t.value)),
    tagDispatcher.on('time', (t) => sceneState.set('time', t.value)),
    tagDispatcher.on('weather', (t) => sceneState.set('weather', t.value)),
    tagDispatcher.on('speaker', (t) => sceneState.set('speaker', t.value)),
  ];
  return () => {
    for (const off of offs) off();
  };
}
