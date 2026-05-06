// Generic diegetic prop entity (P5 T05-mini).
//
// Wraps a Pixi.Container hosting one Sprite at a time, swapped between
// named "states" each backed by a sprite asset URL. Used by:
//   - workstation.ts to register tag-driven props (fruit_bowl, phone,
//     sticky_xia_ge_yue_zhouyi, etc.) without re-implementing the
//     load+swap dance per prop.
//   - prop-registry.ts as the value type stored in the name lookup.
//
// Existing P0–P4 binding-driven props (mug ← energy, monitor ← kpi,
// calendar ← currentDay) keep their current implementation in
// workstation.ts — migration to PropEntity can happen incrementally
// once # prop tags arrive from ink for those props too.

import { Assets, type Container, Sprite } from 'pixi.js';

export type PropScope = 'permanent' | 'scene';

export interface PropEntitySpec {
  /** Stable id used by the tag dispatcher to look this prop up. */
  id: string;
  /** Map of stateName → sprite asset URL. */
  states: Readonly<Record<string, string>>;
  /** Initial state — must be a key of `states`. */
  initialState: string;
  /** Center position of the sprite on the parent layer. */
  x: number;
  y: number;
  /** Sprite scale (1.0 = native pixel). */
  scale?: number;
  /** Anchor point (default 0.5/0.5 = centered). */
  anchorX?: number;
  anchorY?: number;
  /** Lifecycle scope (Bug #14 fix).
   * - `permanent` — bound to game state (mug ← energy, monitor ← kpi,
   *   calendar ← currentDay). Always visible. Survives scene changes.
   *   Initial visibility = visible.
   * - `scene` — bound to ink narrative context (phone, fruit_bowl,
   *   sticky_xia_ge_yue_zhouyi, etc.). Hidden by default; becomes
   *   visible the first time `# prop:` tag emits a state for it; gets
   *   hidden again on the next `# scene:` tag value change. Re-shows
   *   via the next prop-tag emission.
   * Default: `'scene'` (most diegetic props are scene-bound). */
  scope?: PropScope;
}

export interface PropEntity {
  readonly id: string;
  /** Lifecycle scope — used by PropRegistry.hideScopedTo() to bulk-
   * hide transient props on scene change. */
  readonly scope: PropScope;
  /** All known states for this prop (sorted, for debug). */
  readonly stateNames: readonly string[];
  /** Currently-active state. */
  readonly currentState: string;
  /** Switch to a new state AND make the prop visible. Calling
   * setState with the current state still re-shows the prop (so a
   * scene-scoped prop hidden by hideScopedTo can be woken up by any
   * subsequent `# prop:` tag, even one whose state matches). */
  setState(state: string): Promise<void>;
  /** Whether `state` is a known key for this prop. */
  hasState(state: string): boolean;
  /** Direct visibility override (used by hideScopedTo). */
  setVisible(visible: boolean): void;
  /** Read current visibility (for tests / debug). */
  readonly visible: boolean;
  destroy(): void;
}

export async function createPropEntity(
  parent: Container,
  spec: PropEntitySpec,
): Promise<PropEntity> {
  const stateNames = Object.keys(spec.states).sort();
  if (!spec.states[spec.initialState]) {
    throw new Error(
      `[prop-entity] ${spec.id}: initialState "${spec.initialState}" is not in states (${stateNames.join('/')})`,
    );
  }

  const initialUrl = spec.states[spec.initialState] as string;
  const tex = await Assets.load(initialUrl);
  tex.source.scaleMode = 'linear';
  const sprite = new Sprite(tex);
  sprite.label = `prop:${spec.id}`;
  sprite.anchor.set(spec.anchorX ?? 0.5, spec.anchorY ?? 0.5);
  sprite.x = spec.x;
  sprite.y = spec.y;
  sprite.scale.set(spec.scale ?? 1.0);
  // Scene-scoped props start invisible — they become visible the first
  // time ink emits a `# prop:` tag for them (Bug #14 fix). Permanent
  // props (game-state-driven mug/monitor/calendar) start visible.
  const scope: PropScope = spec.scope ?? 'scene';
  sprite.visible = scope === 'permanent';
  parent.addChild(sprite);

  let current = spec.initialState;

  const setState = async (state: string): Promise<void> => {
    // Any setState() call wakes the prop. Scene-scoped props that were
    // hidden by hideScopedTo() come back into view on the next prop
    // tag, even when the requested state is the current one (designer
    // can re-emit the SAME `# prop: <id>_<state>` to re-show it).
    sprite.visible = true;
    if (state === current) return;
    const url = spec.states[state];
    if (!url) {
      console.warn(
        `[prop-entity] ${spec.id}: unknown state "${state}" (have ${stateNames.join('/')})`,
      );
      return;
    }
    const newTex = await Assets.load(url);
    newTex.source.scaleMode = 'linear';
    sprite.texture = newTex;
    current = state;
  };

  const setVisible = (visible: boolean): void => {
    sprite.visible = visible;
  };

  return {
    id: spec.id,
    scope,
    stateNames,
    get currentState() {
      return current;
    },
    get visible() {
      return sprite.visible;
    },
    setState,
    hasState(state: string) {
      return state in spec.states;
    },
    setVisible,
    destroy() {
      sprite.destroy();
    },
  };
}
