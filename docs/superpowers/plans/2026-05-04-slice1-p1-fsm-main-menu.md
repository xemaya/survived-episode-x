# Slice 1 / Phase 1 — FSM + Main Menu + Workstation Scene + Stub Pause

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire up the scene-state machine (Red Line 4 single-dispatcher) and the first three FSM states (`main_menu` / `action_day` / `pause`). Exit criterion: launch the `.app`, see a Preact main menu with a 「开始」 button, click → workstation scene appears with 4 static prop sprites (mug / monitor / sticky / calendar) on a 640×360 canvas, press Esc → pause overlay appears, click 「继续」 → return to workstation. No game logic yet — AP / KPI / cards come at P2.

**Architecture:** Discriminated-union `SceneState` carries payload with each state. A single `FlowDispatcher` instance (the only `flow` export) owns scene-state emission and enforces re-entrancy guards + transition legality (Red Line 4 made runtime-strict). PixiJS renders in-game scenes (workstation), Preact renders overlay menus (main / pause). Both subscribe to `flow` state changes via `mountSceneFor(state, ctx)` in `render/stage.ts`. `render/stage.ts` is the only file allowed to flip `overlayLayer.visible = true` (Red Line 3 lock).

**Tech Stack:** TypeScript 5 strict, PixiJS v8 (existing), Preact 10 + `@preact/preset-vite` (NEW), Vitest (existing). All assets already in `assets/sprites/hud/` from the parallel art-gen session.

**Spec reference:** `docs/superpowers/specs/2026-05-03-engine-switch-design.md` — §3 module split, §5.2 scene graph, §5.3 DOM-vs-Pixi split, §6 game loop + FSM, §9.2 P1 row.

**Prior tag:** `v0.1.0-p0` — toolchain proven, one sprite renders. P1 builds on top.

---

## File Structure

After P1:

```
game/
├── package.json                              (modify; add @preact/preset-vite, deps adjustments)
├── vite.config.ts                            (modify; register preact() plugin)
├── tsconfig.json                             (modify; jsxImportSource: 'preact')
├── index.html                                (unchanged from P0)
├── src/
│   ├── main.ts                               (REWRITE — boot flow.subscribe + initial state)
│   ├── flow/                                 (NEW directory)
│   │   ├── scene-state.ts                    (CREATE — discriminated union types)
│   │   ├── dispatcher.ts                     (CREATE — FlowDispatcher + flow singleton)
│   │   └── transitions.ts                    (CREATE — isLegalTransition + ALLOWED set)
│   ├── render/
│   │   ├── pixi-app.ts                       (unchanged from P0)
│   │   ├── stage.ts                          (CREATE — mountSceneFor + assertOverlayAllowed)
│   │   ├── ui-overlay.tsx                    (CREATE — Preact root + state-driven swap)
│   │   ├── scene/
│   │   │   └── workstation.ts                (CREATE — 4 prop sprites)
│   │   └── menu/
│   │       ├── main-menu.tsx                 (CREATE — Preact main menu)
│   │       └── pause-menu.tsx                (CREATE — Preact pause stub)
│   └── input/
│       └── keyboard.ts                       (CREATE — global Esc handler)
└── tests/
    └── flow/
        ├── transitions.test.ts               (CREATE — legality matrix)
        └── dispatcher.test.ts                (CREATE — emission, re-entrancy guard, illegal-throws)
```

Files **deleted** in P1: none. P0 sprite-mount logic in `main.ts` is replaced wholesale (sprite no longer mounts directly — only when `flow.state.kind === 'action_day'` does `mountSceneFor` build the workstation).

---

## Task 1: Build the `flow/` module (types + dispatcher + transitions, TDD)

**Why first:** every other P1 task subscribes to `flow`. Build it standalone with full test coverage before any consumer exists, so the API contract is locked in.

**Files:**
- Create: `game/src/flow/scene-state.ts`
- Create: `game/src/flow/transitions.ts`
- Create: `game/src/flow/dispatcher.ts`
- Create: `game/tests/flow/transitions.test.ts`
- Create: `game/tests/flow/dispatcher.test.ts`

- [ ] **Step 1.1: Create `game/src/flow/scene-state.ts`** (types only, no behavior)

```ts
// Discriminated union of all FSM scene states.
// Each variant carries the payload it needs at runtime — the type system
// guarantees you can't transition to e.g. `action_day` without a `day` number.
//
// P1 only implements main_menu / action_day / pause.
// Future variants (event_active, weekend, recap, kpi_review, settings, gameover)
// are added when their owning phase lands. Don't pre-declare them.

export type DayPhase = 'morning' | 'midday' | 'afternoon' | 'evening';

export type SceneState =
  | { kind: 'main_menu' }
  | { kind: 'action_day'; day: number; phase: DayPhase }
  | { kind: 'pause'; resumeTo: SceneState };

export function describe(s: SceneState): string {
  switch (s.kind) {
    case 'main_menu':
      return 'main_menu';
    case 'action_day':
      return `action_day(day=${s.day}, phase=${s.phase})`;
    case 'pause':
      return `pause(resumeTo=${describe(s.resumeTo)})`;
  }
}
```

- [ ] **Step 1.2: Write the failing test for `transitions.ts`**

Create `game/tests/flow/transitions.test.ts`:

```ts
import { describe, expect, it } from 'vitest';
import type { SceneState } from '../../src/flow/scene-state';
import { isLegalTransition } from '../../src/flow/transitions';

const mainMenu: SceneState = { kind: 'main_menu' };
const day1: SceneState = { kind: 'action_day', day: 1, phase: 'morning' };
const day1Pause: SceneState = { kind: 'pause', resumeTo: day1 };
const mainMenuPause: SceneState = { kind: 'pause', resumeTo: mainMenu };

describe('isLegalTransition (P1 subset)', () => {
  it('main_menu → action_day is legal (game start)', () => {
    expect(isLegalTransition(mainMenu, day1)).toBe(true);
  });

  it('action_day → pause is legal (Esc pressed)', () => {
    expect(isLegalTransition(day1, day1Pause)).toBe(true);
  });

  it('pause → resumeTo (action_day) is legal (continue clicked)', () => {
    expect(isLegalTransition(day1Pause, day1)).toBe(true);
  });

  it('main_menu → pause is illegal (no game running to pause)', () => {
    expect(isLegalTransition(mainMenu, mainMenuPause)).toBe(false);
  });

  it('pause → pause is illegal (no nested pause)', () => {
    expect(isLegalTransition(day1Pause, day1Pause)).toBe(false);
  });

  it('action_day → action_day with different day is legal (day++ at end of recap, deferred)', () => {
    const day2: SceneState = { kind: 'action_day', day: 2, phase: 'morning' };
    expect(isLegalTransition(day1, day2)).toBe(true);
  });

  it('action_day → main_menu is legal (quit to menu)', () => {
    expect(isLegalTransition(day1, mainMenu)).toBe(true);
  });

  it('pause → main_menu is legal (quit from pause)', () => {
    expect(isLegalTransition(day1Pause, mainMenu)).toBe(true);
  });
});
```

- [ ] **Step 1.3: Run the test — expect FAIL ("Failed to resolve import")**

```bash
cd game
pnpm vitest run tests/flow/transitions.test.ts
```

Expected: FAIL with `Failed to resolve import "../../src/flow/transitions"`. Confirms RED.

- [ ] **Step 1.4: Implement `game/src/flow/transitions.ts`**

```ts
import type { SceneState } from './scene-state';

// Hard-coded transition matrix. Readability beats DRY here — anyone
// debugging an "illegal transition" error should be able to grep this
// file and see the full universe of allowed moves.
//
// P1 wires only main_menu / action_day / pause. New variants extend
// this when their owning phase lands.

export function isLegalTransition(from: SceneState, to: SceneState): boolean {
  // pause: enterable from action_day only (P1); disallow nested
  if (to.kind === 'pause') {
    return from.kind === 'action_day';
  }

  // main_menu: enterable from any non-pause-from-non-action state
  // (P1: action_day → main_menu = quit, pause → main_menu = quit-from-pause)
  if (to.kind === 'main_menu') {
    return from.kind === 'action_day' || from.kind === 'pause';
  }

  // action_day: enterable from main_menu (start), from pause (resume), or
  // from another action_day (day-advance — used at recap end, P3+).
  if (to.kind === 'action_day') {
    return (
      from.kind === 'main_menu' ||
      from.kind === 'pause' ||
      from.kind === 'action_day'
    );
  }

  // exhaustive — TS will warn here if a new variant is added without handling
  const _exhaustive: never = to;
  return _exhaustive;
}
```

- [ ] **Step 1.5: Run the test — expect 8 PASS**

```bash
pnpm vitest run tests/flow/transitions.test.ts
```

Expected: 8 passed. If any fail, fix `transitions.ts` until green.

- [ ] **Step 1.6: Write the failing test for `dispatcher.ts`**

Create `game/tests/flow/dispatcher.test.ts`:

```ts
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
```

- [ ] **Step 1.7: Run the test — expect FAIL (module not found)**

```bash
pnpm vitest run tests/flow/dispatcher.test.ts
```

Expected: FAIL with module-not-found.

- [ ] **Step 1.8: Implement `game/src/flow/dispatcher.ts`**

```ts
import { describe, type SceneState } from './scene-state';
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
        `Re-entrant dispatch — Red Line 4: only flow owns transitions. Use queueMicrotask if you must chain.`,
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
}

// Singleton — every production import goes through this instance.
// Do NOT construct FlowDispatcher elsewhere (lint-redline-4 enforces).
export const flow = new FlowDispatcher();
```

- [ ] **Step 1.9: Run the dispatcher test — expect 7 PASS**

```bash
pnpm vitest run tests/flow/dispatcher.test.ts
```

Expected: 7 passed. Total flow tests: 8 + 7 = 15.

- [ ] **Step 1.10: Verify whole suite + typecheck**

```bash
pnpm tsc
pnpm test
```

Expected: tsc exit 0, vitest reports `4 + 8 + 7 = 19 passed` (the 4 sync-sprites + 8 transitions + 7 dispatcher).

- [ ] **Step 1.11: Commit**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/flow game/tests/flow
git commit -m "feat(game): flow/ FSM module — single-dispatcher, re-entrancy-guarded

P1 introduces the scene-state machine (Red Line 4 made runtime-strict):
- scene-state.ts: discriminated SceneState union (P1 variants:
  main_menu, action_day, pause). Payload travels with state — TS
  prevents transitioning to action_day without a day number.
- transitions.ts: hard-coded ALLOWED matrix. Readable over DRY.
- dispatcher.ts: FlowDispatcher class (testable) + flow singleton
  (production import). request() throws on illegal target AND on
  re-entrant calls from inside listeners. Guard releases on throw
  so a permanent lock is impossible.

Vitest suite: +15 cases (8 transitions + 7 dispatcher) covering legal
moves, illegal throws, re-entrancy guard, unsub idempotency, and
recovery after illegal-transition throws.

Per spec §6.1-§6.3 + plan Task 1.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 2: `render/stage.ts` + main.ts rewrite — wire flow into Pixi

**Why now:** with `flow` ready, replace P0's hard-coded sprite mount with state-driven rendering. After this task, the app boots into `main_menu` (empty Pixi canvas) — main-menu UI comes in Task 3.

**Files:**
- Create: `game/src/render/stage.ts`
- Modify: `game/src/main.ts`

- [ ] **Step 2.1: Create `game/src/render/stage.ts`**

```ts
import { Container, type Application } from 'pixi.js';
import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';

// Scene names where overlay (Preact menu) is allowed to be visible.
// Red Line 3: anywhere else, overlayLayer.visible MUST be false.
const OVERLAY_ALLOWED: ReadonlySet<SceneState['kind']> = new Set([
  'main_menu',
  'pause',
  // future: 'kpi_review', 'gameover', 'settings'
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
  // action_day mounter wired in Task 4 (workstation scene)
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
```

- [ ] **Step 2.2: Rewrite `game/src/main.ts`**

```ts
import { Container } from 'pixi.js';
import { createPixiApp } from '@/render/pixi-app';
import { bindStageToFlow } from '@/render/stage';

async function main(): Promise<void> {
  const root = document.getElementById('pixi-root');
  if (!root) throw new Error('#pixi-root not found in index.html');
  const { app } = await createPixiApp(root);

  // Single world-layer container. Scene mounters add/remove children here.
  const worldLayer = new Container();
  worldLayer.label = 'world';
  app.stage.addChild(worldLayer);

  bindStageToFlow({ app, worldLayer });

  console.info('[boot] flow bound to stage; initial state:', 'main_menu');
}

void main();
```

- [ ] **Step 2.3: Smoke — boot the app, expect empty canvas (no error)**

```bash
cd game
pnpm dev > /tmp/vite-dev-task2.log 2>&1 &
DEV_PID=$!
sleep 5
echo "--- HTML 200 check ---"
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
echo "--- vite log tail ---"
tail -10 /tmp/vite-dev-task2.log
kill $DEV_PID 2>/dev/null
wait 2>/dev/null
pgrep vite || echo "no vite leftover"
```

Expected: HTTP 200, vite log shows server up. No JS errors in startup log. (Visual check: dark canvas, no sprite, no console error — controller verifies after.)

- [ ] **Step 2.4: Verify tests + typecheck still green**

```bash
pnpm tsc
pnpm test
```

Expected: exit 0, 19 passed.

- [ ] **Step 2.5: Commit**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/render/stage.ts game/src/main.ts
git commit -m "feat(game): render/stage.ts wires flow → Pixi scene mounting

main.ts no longer hard-codes the sprite. Instead it boots Pixi, adds
a worldLayer Container to app.stage, and calls bindStageToFlow which
subscribes to the FSM. SCENE_MOUNTERS dispatches per state.kind:
main_menu mounter clears worldLayer (overlay handles UI in Task 3).
action_day mounter is registered in Task 4 (workstation).

assertOverlayAllowed enforces Red Line 3 at runtime — only main_menu /
pause / kpi_review / gameover / settings may flip overlay visible.

Per spec §5.2 (scene graph) + §6.4 (game loop) + plan Task 2.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 3: Preact setup + main-menu overlay

**Why now:** main_menu is the boot state. Without an overlay UI, the app launches into a black canvas with no way to start the game.

**Files:**
- Modify: `game/package.json` (add `@preact/preset-vite`)
- Modify: `game/vite.config.ts` (register preact plugin)
- Modify: `game/tsconfig.json` (jsxImportSource: 'preact')
- Create: `game/src/render/ui-overlay.tsx`
- Create: `game/src/render/menu/main-menu.tsx`
- Modify: `game/src/main.ts` (mount Preact root)

- [ ] **Step 3.1: Install Preact's Vite preset**

```bash
cd game
pnpm add -D @preact/preset-vite@~2.10.0
```

- [ ] **Step 3.2: Update `game/vite.config.ts`**

Replace the file with:

```ts
import preact from '@preact/preset-vite';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [preact()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    port: 1420,
    strictPort: true,
  },
  clearScreen: false,
  build: {
    target: 'safari15',
    sourcemap: true,
    minify: 'esbuild',
    chunkSizeWarningLimit: 2000,
  },
});
```

- [ ] **Step 3.3: Update `game/tsconfig.json` for Preact JSX**

Change `"jsx": "preserve"` to `"jsx": "react-jsx"` and add `"jsxImportSource": "preact"`. The compilerOptions block becomes:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "jsxImportSource": "preact",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true,
    "isolatedModules": true,
    "verbatimModuleSyntax": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "allowJs": true,
    "checkJs": false,
    "noEmit": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*", "scripts/**/*.d.ts", "tests/**/*", "vite.config.ts"],
  "exclude": ["node_modules", "dist", "src-tauri"]
}
```

- [ ] **Step 3.4: Create `game/src/render/menu/main-menu.tsx`**

```tsx
import { flow } from '@/flow/dispatcher';

export function MainMenu(): preact.JSX.Element {
  const startGame = (): void => {
    flow.request({ kind: 'action_day', day: 1, phase: 'morning' });
  };

  return (
    <div class="menu-root menu-root--main">
      <h1 class="menu-title">活过第 X 集</h1>
      <p class="menu-subtitle">一个反向 KPI 办公室生存模拟</p>
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={startGame}>
          开始
        </button>
        {/* 「继续」 (load save) and 「设置」 deferred to P4+ */}
      </div>
    </div>
  );
}
```

- [ ] **Step 3.5: Create `game/src/render/ui-overlay.tsx`**

```tsx
import { useEffect, useState } from 'preact/hooks';
import { render } from 'preact';
import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import { assertOverlayAllowed } from './stage';
import { MainMenu } from './menu/main-menu';

// Pause menu lives in Task 5; for now this stub avoids an import error.
function PauseMenu(): preact.JSX.Element {
  return <div class="menu-root menu-root--pause">已暂停（P1 stub — pause UI in Task 5）</div>;
}

function OverlayRouter(): preact.JSX.Element | null {
  const [state, setState] = useState<SceneState>(flow.state);
  useEffect(() => {
    const unsub = flow.subscribe((next) => {
      setState(next);
    });
    return unsub;
  }, []);

  switch (state.kind) {
    case 'main_menu':
      assertOverlayAllowed(state);
      return <MainMenu />;
    case 'pause':
      assertOverlayAllowed(state);
      return <PauseMenu />;
    case 'action_day':
      // Diegetic-only state; no overlay
      return null;
  }
}

export function mountOverlay(host: HTMLElement): void {
  // Show the overlay container (CSS hides it by default until Preact mounts)
  host.style.display = 'block';
  host.style.pointerEvents = 'auto';
  render(<OverlayRouter />, host);
}
```

- [ ] **Step 3.6: Add menu CSS to `game/index.html`** (extend existing `<style>` block)

Find the existing `<style>` block in `game/index.html` and append (just before `</style>`):

```css
#ui-overlay {
  /* Switched to flex below by mountOverlay; default hidden via display:none */
  align-items: center;
  justify-content: center;
  background: rgba(8, 10, 14, 0.85);
  z-index: 10;
}
.menu-root {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  padding: 48px;
  background: #1a1d22;
  border: 2px solid #3a3d42;
  color: #e8e0cc;
  text-align: center;
  box-shadow: 0 0 0 1px #000, 8px 8px 0 #000;
  font-family: -apple-system, "PingFang SC", sans-serif;
}
.menu-title {
  font-size: 48px;
  margin: 0;
  letter-spacing: 4px;
  color: #c8a85a;
}
.menu-subtitle {
  font-size: 16px;
  margin: 0;
  color: #7a8088;
}
.menu-buttons {
  display: flex;
  gap: 12px;
}
.menu-button {
  font-size: 20px;
  padding: 12px 32px;
  background: #2c4a6e;
  color: #e8e0cc;
  border: 2px solid #5a7080;
  cursor: pointer;
  font-family: inherit;
  letter-spacing: 2px;
}
.menu-button:hover {
  background: #3a5a82;
}
.menu-button--primary {
  background: #c8a85a;
  color: #1a1d22;
  border-color: #e0b050;
}
.menu-button--primary:hover {
  background: #e0b050;
}
```

Also change the `#ui-overlay` rule's `display: none` to `display: flex; display: none;` (the second wins until JS overrides). Actually replace its existing block with:

```css
#ui-overlay {
  position: fixed;
  inset: 0;
  display: none; /* mountOverlay sets to flex */
  pointer-events: none;
}
```

(Keep `display: none` initial; `mountOverlay` sets to `block` which then layout-flows the centered child. Adjust to `display: flex` if not centering — see ?: actually with the new CSS rule above, we want flex for centering. Update mountOverlay above to set `display: 'flex'` instead of `'block'`.)

Update `mountOverlay` in `ui-overlay.tsx` (Step 3.5) to set `host.style.display = 'flex'`.

- [ ] **Step 3.7: Wire `mountOverlay` into `main.ts`**

Update `game/src/main.ts`:

```ts
import { Container } from 'pixi.js';
import { createPixiApp } from '@/render/pixi-app';
import { bindStageToFlow } from '@/render/stage';
import { mountOverlay } from '@/render/ui-overlay';

async function main(): Promise<void> {
  const pixiRoot = document.getElementById('pixi-root');
  const overlayRoot = document.getElementById('ui-overlay');
  if (!pixiRoot || !overlayRoot) {
    throw new Error('Required DOM nodes (#pixi-root, #ui-overlay) not found in index.html');
  }
  const { app } = await createPixiApp(pixiRoot);

  const worldLayer = new Container();
  worldLayer.label = 'world';
  app.stage.addChild(worldLayer);

  bindStageToFlow({ app, worldLayer });
  mountOverlay(overlayRoot);

  console.info('[boot] flow bound; overlay mounted; initial state:', 'main_menu');
}

void main();
```

- [ ] **Step 3.8: Smoke — boot dev, expect main menu visible**

```bash
cd game
pnpm dev > /tmp/vite-dev-task3.log 2>&1 &
DEV_PID=$!
sleep 5
echo "--- HTML 200 check ---"
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
echo "--- vite log tail ---"
tail -10 /tmp/vite-dev-task3.log
kill $DEV_PID 2>/dev/null
wait 2>/dev/null
```

Expected: HTTP 200, vite log clean. Visual smoke (controller does manually):
- Window opens with dim overlay
- Title 「活过第 X 集」 in gold
- 「开始」 button visible
- Click 「开始」 → overlay disappears, canvas remains (workstation scene comes in Task 4)
- DevTools console: `[boot] flow bound; overlay mounted; initial state: main_menu`

- [ ] **Step 3.9: Verify tests + typecheck**

```bash
pnpm tsc
pnpm test
```

Expected: exit 0, 19 passed (existing tests untouched).

- [ ] **Step 3.10: Commit**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/package.json game/pnpm-lock.yaml game/vite.config.ts game/tsconfig.json \
        game/index.html game/src/render/ui-overlay.tsx game/src/render/menu \
        game/src/main.ts
git commit -m "feat(game): Preact main menu overlay; click 「开始」 → action_day

@preact/preset-vite plugin added; tsconfig switched to react-jsx with
preact as jsxImportSource. ui-overlay.tsx mounts a Preact tree into
#ui-overlay div, subscribes to flow, and renders MainMenu when state
is main_menu. Click 「开始」 calls flow.request(action_day, day=1).

CSS palette pulled from STYLE_GUIDE.md: 打工人黄 #c8a85a as title,
屏幕蓝 #2c4a6e as standard button, 老板金 #e0b050 as primary CTA, all
on a 格子间灰蓝 #5a7080 / 档案室棕 dark backdrop. Pixel-grid feel via
flat colors, hard 2px borders, hard offset shadow (no antialias).

PauseMenu is a stub here — Task 5 implements the real pause UI.

Per spec §5.3 (DOM-vs-Pixi split) + plan Task 3.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 4: Workstation scene — 4 prop sprites

**Why now:** clicking 「开始」 currently lands in `action_day` with an empty canvas. Mount the workstation props so there's something to look at.

**Files:**
- Create: `game/src/render/scene/workstation.ts`
- Modify: `game/src/render/stage.ts` (register workstation mounter)

- [ ] **Step 4.1: Create `game/src/render/scene/workstation.ts`**

```ts
import { Assets, Sprite, type Container } from 'pixi.js';
import type { SceneState } from '@/flow/scene-state';
import type { StageContext } from '../stage';

// Static layout for P1 — these sprites just sit there. P2 binds them
// to AP / KPI / day so they actually mean something visually.
//
// Logical canvas is 640×360. Coordinates assume a desk surface
// roughly the bottom 2/3 of the canvas, props clustered around it.

interface PropSpec {
  url: string;
  x: number;
  y: number;
  scale: number;
  label: string;
}

const PROPS: ReadonlyArray<PropSpec> = [
  // Calendar — top-left wall mount
  { url: 'sprites/hud/calendar_month_day_1.png', x: 50, y: 50, scale: 0.12, label: 'calendar' },
  // Monitor — center, on desk
  { url: 'sprites/hud/monitor_idle.png', x: 320, y: 160, scale: 0.18, label: 'monitor' },
  // Sticky note — to the right of monitor
  { url: 'sprites/hud/sticky_blank.png', x: 470, y: 200, scale: 0.1, label: 'sticky' },
  // Mug — bottom-left of desk
  { url: 'sprites/hud/coffee_full.png', x: 130, y: 260, scale: 0.1, label: 'mug' },
];

export async function mountWorkstation(_state: SceneState, ctx: StageContext): Promise<() => void> {
  const sprites: Sprite[] = [];
  for (const spec of PROPS) {
    const tex = await Assets.load(spec.url);
    tex.source.scaleMode = 'nearest';
    const sprite = new Sprite(tex);
    sprite.label = spec.label;
    sprite.anchor.set(0.5);
    sprite.x = spec.x;
    sprite.y = spec.y;
    sprite.scale.set(spec.scale);
    ctx.worldLayer.addChild(sprite);
    sprites.push(sprite);
  }
  return () => {
    for (const sprite of sprites) {
      sprite.destroy();
    }
  };
}
```

- [ ] **Step 4.2: Register the mounter in `render/stage.ts`**

Edit `game/src/render/stage.ts`. Inside the `SCENE_MOUNTERS` const, change `action_day` from being absent to:

```ts
// (snippet — added inside SCENE_MOUNTERS object)
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
```

Add the import at top of `stage.ts`:

```ts
import { mountWorkstation } from './scene/workstation';
```

- [ ] **Step 4.3: Smoke — start dev, click 开始, expect 4 sprites visible**

```bash
cd game
pnpm dev > /tmp/vite-dev-task4.log 2>&1 &
DEV_PID=$!
sleep 5
curl -sS http://localhost:1420/sprites/hud/monitor_idle.png -o /dev/null -w "monitor HTTP %{http_code}\n"
curl -sS http://localhost:1420/sprites/hud/coffee_full.png -o /dev/null -w "mug HTTP %{http_code}\n"
curl -sS http://localhost:1420/sprites/hud/sticky_blank.png -o /dev/null -w "sticky HTTP %{http_code}\n"
curl -sS http://localhost:1420/sprites/hud/calendar_month_day_1.png -o /dev/null -w "calendar HTTP %{http_code}\n"
kill $DEV_PID 2>/dev/null
wait 2>/dev/null
```

Expected: all 4 sprites HTTP 200. Visual smoke (controller does manually): click 开始 → 4 prop sprites appear on dark canvas.

- [ ] **Step 4.4: Verify tests + typecheck**

```bash
pnpm tsc
pnpm test
```

Expected: exit 0, 19 passed.

- [ ] **Step 4.5: Commit**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/render/scene game/src/render/stage.ts
git commit -m "feat(game): workstation scene with 4 static prop sprites

action_day mounter loads calendar / monitor / sticky / mug from
assets/sprites/hud/ and places them at hard-coded positions on the
640×360 logical canvas. Pure visual stub — P2 wires AP/KPI to mug
fill level / monitor state, P3 binds calendar to day counter.

mountWorkstation is async (Assets.load); the SCENE_MOUNTERS entry
returns a synchronous teardown that awaits the promise internally.
Re-entry while still loading is handled by the disposed flag.

Per spec §5.2 + plan Task 4.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 5: Esc → pause overlay → 「继续」 → resume

**Why now:** with main menu and workstation working, hook up the only remaining P1 transition: `action_day → pause → action_day`. This proves the FSM's `resumeTo` pattern (the last unique idea in the FSM design).

**Files:**
- Create: `game/src/input/keyboard.ts`
- Modify: `game/src/render/ui-overlay.tsx` (replace PauseMenu stub with real one)
- Create: `game/src/render/menu/pause-menu.tsx`
- Modify: `game/src/main.ts` (init keyboard handler)

- [ ] **Step 5.1: Create `game/src/input/keyboard.ts`**

```ts
import { flow } from '@/flow/dispatcher';

// Single global keyboard handler. P1 only handles Esc; P2+ extends with
// the 12 act_* mappings (input/dual_focus, etc., per spec §3 input system).

export function installKeyboardHandler(): () => void {
  const onKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      e.preventDefault();
      togglePause();
    }
  };
  window.addEventListener('keydown', onKeyDown);
  return () => window.removeEventListener('keydown', onKeyDown);
}

function togglePause(): void {
  const state = flow.state;
  if (state.kind === 'action_day') {
    flow.request({ kind: 'pause', resumeTo: state });
  } else if (state.kind === 'pause') {
    flow.request(state.resumeTo);
  }
  // Esc in main_menu does nothing (no place to go back to)
}
```

- [ ] **Step 5.2: Create `game/src/render/menu/pause-menu.tsx`**

```tsx
import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';

interface Props {
  state: SceneState & { kind: 'pause' };
}

export function PauseMenu({ state }: Props): preact.JSX.Element {
  const resume = (): void => {
    flow.request(state.resumeTo);
  };
  const quitToMenu = (): void => {
    flow.request({ kind: 'main_menu' });
  };

  return (
    <div class="menu-root menu-root--pause">
      <h2 class="menu-title menu-title--small">已暂停</h2>
      <p class="menu-subtitle">按 Esc 或点 「继续」 回去</p>
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={resume}>
          继续
        </button>
        <button type="button" class="menu-button" onClick={quitToMenu}>
          回主菜单
        </button>
      </div>
    </div>
  );
}
```

- [ ] **Step 5.3: Replace the stub PauseMenu in `ui-overlay.tsx`**

Edit `game/src/render/ui-overlay.tsx`. Remove the local `function PauseMenu()` stub and add an import:

```tsx
import { PauseMenu } from './menu/pause-menu';
```

Then update the switch case to pass state:

```tsx
case 'pause':
  assertOverlayAllowed(state);
  return <PauseMenu state={state} />;
```

- [ ] **Step 5.4: Add the small menu-title CSS variant** (extend `index.html` style)

Append before `</style>`:

```css
.menu-title--small {
  font-size: 32px;
  letter-spacing: 2px;
}
```

- [ ] **Step 5.5: Init keyboard handler in `main.ts`**

Edit `game/src/main.ts` to add the import + call:

```ts
import { installKeyboardHandler } from '@/input/keyboard';
```

Inside `main()`, after `mountOverlay(overlayRoot)`:

```ts
installKeyboardHandler();
```

- [ ] **Step 5.6: Smoke — start dev, click 开始 → press Esc → expect pause overlay**

```bash
cd game
pnpm dev > /tmp/vite-dev-task5.log 2>&1 &
DEV_PID=$!
sleep 5
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
tail -10 /tmp/vite-dev-task5.log
kill $DEV_PID 2>/dev/null
wait 2>/dev/null
```

Expected: HTTP 200. Manual smoke (controller does):
- Click 「开始」 → workstation
- Press Esc → 「已暂停」 overlay appears
- Click 「继续」 → back to workstation
- Press Esc, click 「回主菜单」 → back to main menu
- Press Esc in main_menu → no-op (no error)

- [ ] **Step 5.7: Verify tests + typecheck**

```bash
pnpm tsc
pnpm test
```

Expected: 19 passed.

- [ ] **Step 5.8: Commit**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/input game/src/render/menu/pause-menu.tsx \
        game/src/render/ui-overlay.tsx game/src/main.ts game/index.html
git commit -m "feat(game): Esc → pause overlay → 「继续」 → resumeTo

input/keyboard.ts installs a single window keydown handler that maps
Esc to flow toggle: action_day → pause(resumeTo=current),
pause → resumeTo. Esc in main_menu is a no-op.

PauseMenu is a real Preact component now (was a stub in Task 3).
Two buttons: 「继续」 (flow.request(resumeTo)) and 「回主菜单」
(flow.request(main_menu) — uses the action_day→main_menu legality
allowed in transitions.ts).

Per spec §6.6 (resumeTo pattern as data, not stack) + plan Task 5.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 6: P1 exit verification + tag `v0.2.0-p1`

- [ ] **Step 6.1: Run the full verify chain**

```bash
cd game
pnpm verify
```

Expected: assets sync (266+ PNGs), tsc clean, biome clean, vitest 19 passed.

- [ ] **Step 6.2: Production build**

```bash
pnpm tauri build
```

Expected: cargo build (incremental, ~30 sec) + vite build + bundle = `.app` and `.dmg` produced.

- [ ] **Step 6.3: Manual smoke — install + run + walk the loop**

```bash
killall "活过第 X 集" 2>/dev/null
open "/Users/huanghaibin/Workspace/games/survived-episode-x/game/src-tauri/target/release/bundle/macos/活过第 X 集.app"
```

Walk through:
1. Window opens → main menu visible (gold title, 「开始」 button)
2. Click 「开始」 → workstation scene with 4 prop sprites
3. Press Esc → pause overlay
4. Click 「继续」 → back to workstation, props still there
5. Press Esc → pause again
6. Click 「回主菜单」 → main menu again
7. Click 「开始」 once more → workstation again (proves day=1 fresh start works repeatedly)

- [ ] **Step 6.4: Tag `v0.2.0-p1`**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git tag -a v0.2.0-p1 -m "Slice 1 / Phase 1 complete: FSM + main menu + workstation + pause

End-to-end verified:
- Boot → main menu (Preact overlay, gold title 「活过第 X 集」)
- Click 「开始」 → action_day(day=1, morning) → workstation scene
  with 4 static prop sprites (calendar/monitor/sticky/mug)
- Esc → pause overlay (resumeTo carries action_day state)
- 「继续」 → back to workstation; 「回主菜单」 → main_menu
- Esc in main_menu → no-op (correct)

Vitest: 19 cases (8 transitions + 7 dispatcher + 4 sync-sprites).
Red Line 4 enforced at runtime: re-entrant flow.request throws,
illegal transition throws, FlowDispatcher singleton not constructable
elsewhere.

Per docs/superpowers/plans/2026-05-04-slice1-p1-fsm-main-menu.md."
git push --tags
```

- [ ] **Step 6.5: Update spec §9.2 P1 row**

Edit `docs/superpowers/specs/2026-05-03-engine-switch-design.md` §9.2 — change the P1 row from:

```
| **P1 FSM + 主菜单 + 进 day 1** | 2d | "开始"按钮 → 工位场景（4 道具 sprite 静态）；Esc 进 stub 暂停 |
```

to:

```
| **P1 FSM + 主菜单 + 进 day 1** | ✅ 完成 2026-05-?? (tag `v0.2.0-p1`) | flow/ FSM (Red Line 4 runtime-enforced) + Preact main menu + workstation 4 props + Esc pause overlay. Plan: `docs/superpowers/plans/2026-05-04-slice1-p1-fsm-main-menu.md`. |
```

Commit:

```bash
git add docs/superpowers/specs/2026-05-03-engine-switch-design.md
git commit -m "docs: mark Slice 1 P1 complete in design spec (tag v0.2.0-p1)"
git push
```

---

## Self-review checklist for the engineer reading this plan

After completing all tasks:

- [ ] `pnpm verify` from `game/` is green (vitest 19 passed)
- [ ] `pnpm tauri build` produces a fresh `.dmg`
- [ ] Installed `.app` opens to main menu, walks the full P1 loop without console errors
- [ ] Commit `v0.2.0-p1` is tagged and pushed
- [ ] Pre-commit hook (lefthook) ran on every commit (typecheck + biome auto-passed since both fix-on-save flows kept things clean)

## What is **not** in P1 (waiting for P2+)

- AP / KPI / cards systems (P2)
- Save / load (P4)
- Real game logic on workstation props (sprites are static placeholders)
- Real KPI threshold formula (P2 places stub; P3+ implements real reverse threshold)
- Event system (DSL, triggers, choices, effects) — Slice 2
- NPC system, run meta, tutorial, accessibility, audio — Slice 2

## Notes for Claude when executing this plan

- **Run `pnpm dev` and `pnpm tauri dev` from `game/`, not the repo root.**
- **The parallel art-gen session is still active.** Don't be surprised if `assets/sprites/` grows during a task. `sync-sprites.mjs` auto-discovers categories.
- **Don't introduce new Pixi-side state machines.** `flow` is the only FSM. Domain emitters (when added in P2 for AP/KPI) are per-module pub-sub, not full state machines.
- **JSX is Preact, not React.** `import { useState } from 'preact/hooks'`, not `'react'`. The `tsconfig.json` `jsxImportSource: 'preact'` and `@preact/preset-vite` handle the runtime.
- **If you add new SceneState variants**, also extend the `isLegalTransition` matrix and the `OVERLAY_ALLOWED` set if the new state shows menu UI. Both have exhaustive checks via discriminated union — TS will warn if you forget.
- **Don't re-enable strict CSP yet.** P0 deferred this; P1 is not where it gets fixed.
