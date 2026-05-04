import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import type { Application, Container } from 'pixi.js';
import { mountWorkstation } from './scene/workstation';

// Scene names where overlay (Preact menu) is allowed to be visible.
// Red Line 3: anywhere else, overlayLayer.visible MUST be false.
// action_overtime is diegetic (same workstation view as action_day) — NOT in
// this set. morning_briefing and after_work have overlay stubs in ui-overlay.tsx.
const OVERLAY_ALLOWED: ReadonlySet<SceneState['kind']> = new Set([
  'main_menu',
  'pause',
  'morning_briefing',
  'after_work',
  'recap',
  'kpi_review',
  'gameover',
  'archive_list',
  // future: 'settings'
]);

export function assertOverlayAllowed(state: SceneState): void {
  if (!OVERLAY_ALLOWED.has(state.kind)) {
    throw new Error(
      `Red Line 3 violation: overlay attempted in scene state "${state.kind}", ` +
        `which mandates diegetic-only UI. Allowed states: ${[...OVERLAY_ALLOWED].join(', ')}.`,
    );
  }
}

export interface StageContext {
  app: Application;
  worldLayer: Container; // in-game scene (mounted by Pixi)
  // overlayLayer is the DOM #ui-overlay div; managed by Preact (see ui-overlay.tsx)
}

// Mount/unmount handlers per state. Each scene module exports a function
// that takes (state, ctx) and returns a teardown closure. We hold the
// current teardown so the previous scene gets cleaned up when state changes.
type SceneMounter = (state: SceneState, ctx: StageContext) => () => void;

let activeTeardown: (() => void) | null = null;

export function mountSceneFor(state: SceneState, ctx: StageContext): void {
  if (activeTeardown) {
    activeTeardown();
    activeTeardown = null;
  }
  const mounter = SCENE_MOUNTERS[state.kind];
  if (!mounter) {
    // Unknown state — clear world layer; overlay handler covers menu states
    ctx.worldLayer.removeChildren();
    return;
  }
  activeTeardown = mounter(state, ctx);
}

// Lazy-loaded mounters keyed by SceneState.kind.
// Each module's mounter is responsible for adding its display objects to
// ctx.worldLayer and returning a teardown that removes them.
const SCENE_MOUNTERS: Partial<Record<SceneState['kind'], SceneMounter>> = {
  main_menu: (_state, ctx) => {
    // Pure menu state — no Pixi scene. Just clear the world layer.
    ctx.worldLayer.removeChildren();
    return () => {};
  },
  action_day: (state, ctx) => {
    // The mountWorkstation is async (loads sprites). Fire-and-forget; the
    // teardown returned synchronously is a closure that awaits the mount
    // promise then disposes. This keeps mountSceneFor synchronous.
    let disposed = false;
    let asyncTeardown: (() => void) | null = null;
    void mountWorkstation(state, ctx).then((teardown) => {
      if (disposed) {
        teardown();
      } else {
        asyncTeardown = teardown;
      }
    });
    return () => {
      disposed = true;
      if (asyncTeardown) asyncTeardown();
    };
  },
  action_overtime: (state, ctx) => {
    // Same workstation scene as action_day — the difference is only at the UI
    // layer (no overlay; AP can reach up to 10 via overtime grant). The
    // workstation renderer subscribes to ap.onChanged so the AP row updates
    // automatically when the overtime bonus arrives.
    let disposed = false;
    let asyncTeardown: (() => void) | null = null;
    void mountWorkstation(state, ctx).then((teardown) => {
      if (disposed) {
        teardown();
      } else {
        asyncTeardown = teardown;
      }
    });
    return () => {
      disposed = true;
      if (asyncTeardown) asyncTeardown();
    };
  },
  // pause mounter is implicit (overlay only, no Pixi changes)
};

export function registerSceneMounter(kind: SceneState['kind'], mounter: SceneMounter): void {
  SCENE_MOUNTERS[kind] = mounter;
}

// Subscribe stage to flow. Call once at boot.
export function bindStageToFlow(ctx: StageContext): void {
  flow.subscribe((next) => {
    mountSceneFor(next, ctx);
  });
  // Mount the initial state too (subscribe doesn't fire immediately).
  mountSceneFor(flow.state, ctx);
}
