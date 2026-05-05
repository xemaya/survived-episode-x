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
}

export interface PropEntity {
  readonly id: string;
  /** All known states for this prop (sorted, for debug). */
  readonly stateNames: readonly string[];
  /** Currently-active state. */
  readonly currentState: string;
  /** Switch to a new state. Resolves once the texture is loaded + swapped. */
  setState(state: string): Promise<void>;
  /** Whether `state` is a known key for this prop. */
  hasState(state: string): boolean;
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
  parent.addChild(sprite);

  let current = spec.initialState;

  const setState = async (state: string): Promise<void> => {
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

  return {
    id: spec.id,
    stateNames,
    get currentState() {
      return current;
    },
    setState,
    hasState(state: string) {
      return state in spec.states;
    },
    destroy() {
      sprite.destroy();
    },
  };
}
