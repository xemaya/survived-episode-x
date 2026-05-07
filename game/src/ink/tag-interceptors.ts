// Tag interceptor system: dispatch ink # tags from each story step to
// registered handlers. The ink runtime emits raw # tags; this layer
// classifies them by key and routes to renderer/state subsystems.
//
// Tag conventions (per design/vertical-slice/p5-engine-architecture.md §3):
//   # scene: <id>           — switch scene type (workstation / phone / monitor_modal / endgame)
//   # time: <hh:mm>         — current game time
//   # npc: <id>_<state>     — NPC sprite show/hide/animate
//   # prop: <id>_<state>    — diegetic prop state machine update
//   # diegetic_prop: ...    — same as # prop but explicit "treat as UI" emphasis
//   # music: <track>        — audio engine cue
//   # weather: <state>      — BG sprite swap
//
// Daily-choice metadata tags (filter, not render):
//   # category / # season_unlock / # time_filter / # weekday_only / # weekend_only / # both
//   # cooldown_episodes / # frequency_per_series / # npc_focus

import type { ParsedTag } from './runtime';

export type TagHandler = (tag: ParsedTag) => void;

/** Built-in tag categories — used by registerByKey() routing helpers. */
export type TagKey =
  | 'scene'
  | 'time'
  | 'npc'
  | 'prop'
  | 'diegetic_prop'
  | 'music'
  | 'weather'
  | 'category'
  | 'season_unlock'
  | 'time_filter'
  | 'weekday_only'
  | 'weekend_only'
  | 'both'
  | 'cooldown_episodes'
  | 'frequency_per_series'
  | 'npc_focus';

const RENDER_TAG_KEYS = new Set<string>([
  'scene',
  'time',
  'npc',
  'prop',
  'diegetic_prop',
  'music',
  'weather',
]);

export class TagDispatcher {
  private byKey = new Map<string, Set<TagHandler>>();
  private wildcard = new Set<TagHandler>();

  /** Register a handler for a specific tag key (e.g. "scene"). */
  on(key: string, handler: TagHandler): () => void {
    let set = this.byKey.get(key);
    if (!set) {
      set = new Set();
      this.byKey.set(key, set);
    }
    set.add(handler);
    return () => {
      set?.delete(handler);
    };
  }

  /** Register a wildcard handler — receives every tag. Useful for logging. */
  onAny(handler: TagHandler): () => void {
    this.wildcard.add(handler);
    return () => this.wildcard.delete(handler);
  }

  /** Dispatch one tag to all registered handlers (key-specific + wildcard). */
  dispatch(tag: ParsedTag): void {
    const keyHandlers = this.byKey.get(tag.key);
    if (keyHandlers) {
      for (const h of keyHandlers) h(tag);
    }
    for (const h of this.wildcard) h(tag);
  }

  /** Dispatch a batch of tags (typical use: from one story.step()). */
  dispatchAll(tags: ParsedTag[]): void {
    for (const t of tags) this.dispatch(t);
  }

  /** Drop all registered handlers (test cleanup). */
  reset(): void {
    this.byKey.clear();
    this.wildcard.clear();
  }
}

/** Returns true if this tag is a render-side directive (vs metadata-only). */
export function isRenderTag(tag: ParsedTag): boolean {
  return RENDER_TAG_KEYS.has(tag.key);
}

/** Singleton dispatcher — production code routes through this. */
export const tagDispatcher = new TagDispatcher();
