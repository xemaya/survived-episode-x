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

import { Assets, type Container, Rectangle, Sprite, Texture } from 'pixi.js';
import { type ChromaKeySpec, loadChromaKeyedTexture } from './chroma-key';

export type PropScope = 'permanent' | 'scene';

/** Per-side pixel inset for cropping a sprite-sheet / single-frame
 * texture. Used by Bug #15 fix (Option C — Pixi-side crop) to hide
 * label leakage at the corners (e.g. fruit_bowl frames carry "Front"
 * + "9:00" timestamps on the source PNG that the upstream cuts.yaml
 * label_band didn't fully strip). All four sides default to 0. */
export interface PropCropEdges {
  top?: number;
  right?: number;
  bottom?: number;
  left?: number;
}

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
  /** Bug #15 fix (Option C — Pixi-side crop): per-side pixel inset
   * cropping the texture frame so labels baked into the source PNG
   * don't leak into the rendered sprite. Applied uniformly to every
   * state's texture (assumes the source sheets share label
   * placement). All four sides default to 0 — no crop. When W5 lands
   * Option A (re-cut sheets without labels), drop this field. */
  cropEdges?: PropCropEdges;
  /** Q-W (Bug #36 fix B): replace pixels matching `color` (within
   * `tolerance`) with alpha=0 so the prop sprite stops rendering its
   * source-baked cream BG rectangle. Applied uniformly to every
   * state's texture. Backup if W5 re-generates with explicit
   * transparent_bg. */
  chromaKey?: ChromaKeySpec;
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

/** Pure helper: compute the inner frame rectangle for given source
 * dimensions + per-side edges. Returns null when no crop is needed
 * (no edges set, or all four edges zero). Inner dims clamp to 1 px
 * minimum so degenerate edge specs don't produce invalid frames.
 *
 * Exported for unit tests — render path goes through applyCropEdges. */
export function computeCropFrame(
  sourceW: number,
  sourceH: number,
  edges: PropCropEdges | undefined,
): { x: number; y: number; width: number; height: number } | null {
  if (!edges) return null;
  const top = edges.top ?? 0;
  const right = edges.right ?? 0;
  const bottom = edges.bottom ?? 0;
  const left = edges.left ?? 0;
  if (top === 0 && right === 0 && bottom === 0 && left === 0) return null;
  const innerW = Math.max(1, sourceW - left - right);
  const innerH = Math.max(1, sourceH - top - bottom);
  return { x: left, y: top, width: innerW, height: innerH };
}

/** Returns a Texture cropped by the per-side `edges` insets, or the
 * input texture verbatim when no crop is needed. The cropped texture
 * shares the source bitmap with `base` — only the frame rectangle is
 * narrowed — so swapping textures across states with the same crop
 * spec stays cheap. */
export function applyCropEdges(base: Texture, edges: PropCropEdges | undefined): Texture {
  const frame = computeCropFrame(base.source.width, base.source.height, edges);
  if (frame === null) return base;
  return new Texture({
    source: base.source,
    frame: new Rectangle(frame.x, frame.y, frame.width, frame.height),
  });
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
  const baseTex = spec.chromaKey
    ? await loadChromaKeyedTexture(initialUrl, spec.chromaKey)
    : await Assets.load(initialUrl);
  baseTex.source.scaleMode = 'linear';
  const tex = applyCropEdges(baseTex, spec.cropEdges);
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
    const newBase = spec.chromaKey
      ? await loadChromaKeyedTexture(url, spec.chromaKey)
      : await Assets.load(url);
    newBase.source.scaleMode = 'linear';
    sprite.texture = applyCropEdges(newBase, spec.cropEdges);
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
