# Slice 1 / Phase 0 — Hello Pixi in Tauri

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the TS + Vite + PixiJS + Tauri toolchain end-to-end. Exit criterion: `pnpm tauri build` produces a `.dmg` that, when installed, opens a 1920×1080 native macOS window displaying one pixel sprite from `assets/sprites/character/`.

**Architecture:** Brand-new `game/` subdirectory holding all source. PixiJS renders into a 640×360 logical canvas, scaled 3× to fill 1920×1080. Tauri 2 wraps the Vite-built bundle into a signed-but-unsigned `.app`. No game logic yet — this phase exists solely to prove the full chain (pnpm install → vite build → tauri bundle → dmg install → window open) works without surprises.

**Tech Stack:** TypeScript 5 (strict + noUncheckedIndexedAccess), Vite 6, PixiJS v8, Tauri 2.x, pnpm, Biome, lefthook. Python 3 (Pillow + PyYAML, already used by `tools/cut_sprites.py`).

**Spec reference:** `docs/superpowers/specs/2026-05-03-engine-switch-design.md` — §1 (repo layout), §2 (stack), §4.7 (asset pipeline), §5.1 (resolution), §8.1 (Tauri config), §9.3 (P0 step list).

---

## File Structure

After P0 the repo looks like:

```
survived-episode-x/
├── .gitignore                                   (modify; widen Tauri target)
├── architecture/ stories/ design/ tools/        (untouched)
├── assets/sprites/                              (untouched, source of truth for art)
├── README.md HANDOFF.md CLAUDE.md               (untouched)
├── docs/superpowers/specs/                      (untouched)
├── docs/superpowers/plans/                      (this plan)
└── game/                                        (NEW — entire TS app)
    ├── .gitignore                               (CREATE — game-specific ignore)
    ├── package.json                             (CREATE)
    ├── pnpm-lock.yaml                           (CREATE — generated)
    ├── tsconfig.json                            (CREATE)
    ├── vite.config.ts                           (CREATE)
    ├── biome.json                               (CREATE)
    ├── lefthook.yml                             (CREATE)
    ├── index.html                               (CREATE)
    ├── README.md                                (CREATE — quick start for fresh checkouts)
    ├── public/
    │   └── sprites/                             (synced from ../assets/sprites/, gitignored)
    ├── scripts/
    │   └── sync-sprites.mjs                     (CREATE — ~40 lines, copy assets to public)
    ├── src/
    │   ├── main.ts                              (CREATE — boot Pixi, mount one sprite)
    │   └── render/
    │       └── pixi-app.ts                      (CREATE — PIXI.Application factory)
    ├── tests/
    │   └── sync-sprites.test.ts                 (CREATE — vitest for sync logic)
    └── src-tauri/                               (CREATED by `tauri init`)
        ├── Cargo.toml
        ├── tauri.conf.json                      (modify after init for window + bundle)
        ├── build.rs
        ├── icons/                               (Tauri default icons; replaced in P5, not P0)
        └── src/
            └── main.rs / lib.rs                 (default; do not edit in P0)
```

Files **deleted** in Task 1 (Godot leftovers; already gitignored, removed from working tree for cleanliness):

- `src/`, `tests/`, `addons/`, `project.godot`, `.godot/`
- `assets/data/`, `assets/shaders/`
- `assets/sprites/**/*.import`, `assets/sprites/**/*.uid`
- `design/research/`

---

## Task 1: Physical cleanup of abandoned Godot tree

**Why first:** every later task assumes a clean slate. Leaving 18.6k lines of broken GDScript and `.tres` files around will confuse the next coding agent who reads the tree before checking spec.

**Files:**
- Delete: `src/`, `tests/`, `addons/`, `project.godot`, `.godot/`, `assets/data/`, `assets/shaders/`, `design/research/`
- Delete (glob): `assets/sprites/**/*.import`, `assets/sprites/**/*.uid`
- Verify: `assets/sprites/test_outputs/` retains all 11 PNG + 11 prompt.txt files

- [ ] **Step 1.1: Verify the abandoned dirs are still gitignored (no risk of accidental tracking)**

Run:
```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git check-ignore -v src/ tests/ addons/ project.godot .godot/ assets/data/ assets/shaders/ design/research/ 2>&1 | head
```

Expected: each path appears in the output prefixed by `.gitignore:<lineno>:<pattern>` (already configured in initial commit `64073f3`). If any path is missing, stop and add it to `.gitignore` before proceeding.

- [ ] **Step 1.2: Delete the abandoned directories and files**

Run:
```bash
rm -rf src/ tests/ addons/ project.godot .godot/
rm -rf assets/data/ assets/shaders/ design/research/
find assets/sprites -type f \( -name '*.import' -o -name '*.uid' \) -delete
```

- [ ] **Step 1.3: Confirm retained sprites are intact (65 PNGs)**

Run: `find assets/sprites -name '*.png' | wc -l`
Expected: `65`

Run: `find assets/sprites -type f \( -name '*.import' -o -name '*.uid' -o -name '*.tres' -o -name '*.gd' \) | wc -l`
Expected: `0`

- [ ] **Step 1.4: Confirm git status is clean**

Run: `git status --short`
Expected: empty output (everything deleted was gitignored, so nothing shows up as a change).

- [ ] **Step 1.5: Commit a no-op marker so the cleanup intent is in history**

Since gitignored deletions don't show in `git diff`, write a one-line marker into `HANDOFF.md` (it's already tracked) noting cleanup occurred, then commit.

Append to the very top of `HANDOFF.md`:
```
> **2026-05-03 (post-engine-switch):** Godot tree (`src/`, `tests/`, `addons/`, `project.godot`, `.godot/`, `assets/data/`, `assets/shaders/`, `design/research/`, sprite `.import|.uid` metadata) physically deleted from working tree. New TS+PixiJS+Tauri stack lives in `game/` per `docs/superpowers/specs/2026-05-03-engine-switch-design.md`.
```

Commit:
```bash
git add HANDOFF.md
git commit -m "chore: physically delete abandoned Godot tree (cleanup marker in HANDOFF.md)

Per docs/superpowers/specs/2026-05-03-engine-switch-design.md §1. Files
were already gitignored; this commit records the working-tree cleanup
so future agents don't try to read or fix the abandoned code."
git push
```

---

## Task 2: Bootstrap pnpm + TypeScript skeleton in `game/`

**Why now:** establishes the npm workspace baseline. Everything else hangs off this `package.json`.

**Files:**
- Create: `game/package.json`
- Create: `game/pnpm-lock.yaml` (generated)
- Create: `game/tsconfig.json`
- Create: `game/.gitignore`
- Create: `game/README.md`

- [ ] **Step 2.1: Verify pnpm + node are installed**

Run:
```bash
node -v
pnpm -v
```

Expected: Node `>= 20.0.0`, pnpm `>= 9.0.0`. If either is missing or older:
- Node: `brew install node@20`
- pnpm: `npm install -g pnpm@latest`

- [ ] **Step 2.2: Create `game/` directory and initialize `package.json`**

Run:
```bash
mkdir -p game
cd game
pnpm init
```

Then replace the generated `game/package.json` with:

```json
{
  "name": "survived-episode-x",
  "version": "0.1.0",
  "description": "反向 KPI 办公室生存模拟（像素风、回合制） — TS+PixiJS+Tauri",
  "type": "module",
  "private": true,
  "scripts": {
    "tsc": "tsc --noEmit"
  },
  "devDependencies": {},
  "dependencies": {}
}
```

- [ ] **Step 2.3: Add TypeScript as a dev dependency**

Run:
```bash
cd game
pnpm add -D typescript@~5.6.0
```

Expected output ends with: `Done in <Xs>` and `pnpm-lock.yaml` is created.

- [ ] **Step 2.4: Create `game/tsconfig.json`**

Write `game/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "jsx": "preserve",
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
    "allowJs": false,
    "noEmit": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*", "scripts/**/*", "tests/**/*", "vite.config.ts"],
  "exclude": ["node_modules", "dist", "src-tauri"]
}
```

- [ ] **Step 2.5: Create `game/.gitignore`**

Write `game/.gitignore`:

```gitignore
node_modules/
dist/
.vite/
*.tsbuildinfo
src-tauri/target/
src-tauri/gen/
public/sprites/
src/generated/
.env
.env.local
.env.*.local
coverage/
```

`public/sprites/` is gitignored because sprites live authoritatively in `../assets/sprites/` and are sync-copied at build time (see Task 4).

- [ ] **Step 2.6: Create `game/README.md` quick start**

Write `game/README.md`:

```markdown
# game/ — 《活过第 X 集》(TS + PixiJS + Tauri)

## Quick start

```bash
pnpm install
pnpm tauri dev    # development window, hot reload
pnpm tauri build  # produces .dmg in src-tauri/target/release/bundle/dmg/
```

See `../docs/superpowers/specs/2026-05-03-engine-switch-design.md` for architecture.
```

- [ ] **Step 2.7: Verify TypeScript compiles (no source files yet, but config must parse)**

Run:
```bash
cd game
pnpm tsc
```

Expected: exit code 0, no output. (No `.ts` files exist yet, so nothing to typecheck — but `tsc` must accept the config.)

- [ ] **Step 2.8: Commit**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/.gitignore game/package.json game/pnpm-lock.yaml game/tsconfig.json game/README.md
git commit -m "feat(game): bootstrap pnpm+TypeScript skeleton in game/

Empty TS workspace with strict tsconfig (noUncheckedIndexedAccess,
exactOptionalPropertyTypes, etc.). No source files yet — Task 3 adds
Vite and the first Pixi boot.

Per docs/superpowers/specs/2026-05-03-engine-switch-design.md §2."
git push
```

---

## Task 3: Vite + PixiJS — first canvas in browser

**Why now:** prove the web stack works before introducing Tauri. If `pnpm dev` shows a sprite in Safari/Chrome, Tauri's webview will too.

**Files:**
- Create: `game/index.html`
- Create: `game/vite.config.ts`
- Create: `game/src/main.ts`
- Create: `game/src/render/pixi-app.ts`

- [ ] **Step 3.1: Add Vite + PixiJS + Preact + Howler**

Run:
```bash
cd game
pnpm add -D vite@~6.0.0
pnpm add pixi.js@~8.5.0 howler@~2.2.4 preact@~10.25.0
pnpm add -D @types/howler@~2.2.12
```

- [ ] **Step 3.2: Create `game/index.html`**

Write `game/index.html`:

```html
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>活过第 X 集</title>
    <style>
      html, body {
        margin: 0;
        padding: 0;
        background: #000;
        overflow: hidden;
        height: 100%;
        font-family: -apple-system, "PingFang SC", sans-serif;
        color: #fff;
      }
      #pixi-root {
        position: fixed;
        inset: 0;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      #pixi-root canvas {
        image-rendering: pixelated;
        image-rendering: crisp-edges;
      }
      #ui-overlay {
        position: fixed;
        inset: 0;
        pointer-events: none;
        display: none;
      }
    </style>
  </head>
  <body>
    <div id="pixi-root"></div>
    <div id="ui-overlay"></div>
    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
```

- [ ] **Step 3.3: Create `game/vite.config.ts`**

Write `game/vite.config.ts`:

```ts
import { defineConfig } from 'vite';
import { fileURLToPath } from 'node:url';

export default defineConfig({
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

(Port 1420 is Tauri's default expectation; `strictPort: true` makes Vite fail loud if it's taken instead of silently picking another.)

- [ ] **Step 3.4: Create `game/src/render/pixi-app.ts`**

Write `game/src/render/pixi-app.ts`:

```ts
import { Application } from 'pixi.js';

export interface PixiAppHandles {
  app: Application;
  resize: () => void;
}

const LOGICAL_WIDTH = 640;
const LOGICAL_HEIGHT = 360;

export async function createPixiApp(mount: HTMLElement): Promise<PixiAppHandles> {
  const app = new Application();
  await app.init({
    width: LOGICAL_WIDTH,
    height: LOGICAL_HEIGHT,
    backgroundColor: 0x111418,
    antialias: false,
    roundPixels: true,
    autoDensity: false,
    resolution: 1,
  });

  const canvas = app.canvas as HTMLCanvasElement;
  canvas.style.imageRendering = 'pixelated';
  mount.appendChild(canvas);

  const resize = () => {
    const scale = Math.max(
      1,
      Math.min(
        Math.floor(window.innerWidth / LOGICAL_WIDTH),
        Math.floor(window.innerHeight / LOGICAL_HEIGHT),
      ),
    );
    canvas.style.width = `${LOGICAL_WIDTH * scale}px`;
    canvas.style.height = `${LOGICAL_HEIGHT * scale}px`;
  };
  window.addEventListener('resize', resize);
  resize();

  return { app, resize };
}
```

- [ ] **Step 3.5: Create `game/src/main.ts` — black canvas only (no sprite yet, that comes in Task 4)**

Write `game/src/main.ts`:

```ts
import { createPixiApp } from '@/render/pixi-app';

async function main(): Promise<void> {
  const root = document.getElementById('pixi-root');
  if (!root) throw new Error('#pixi-root not found in index.html');
  await createPixiApp(root);
  console.info('[boot] PixiJS application ready');
}

void main();
```

- [ ] **Step 3.6: Smoke — open dev server, verify black 640×360 canvas integer-scaled**

Run:
```bash
cd game
pnpm dev
```

Expected console line: `Local: http://localhost:1420/`. Open that URL in a browser.

Expected in browser:
- A black canvas centered in the page
- DevTools console shows `[boot] PixiJS application ready`
- DevTools "Elements" shows `<canvas>` whose computed `width` is one of `640px / 1280px / 1920px` depending on window size

If the canvas is NOT pixel-snapped (looks blurry when zoomed), inspect `image-rendering` on the canvas — it should be `pixelated`.

Stop the dev server with Ctrl+C.

- [ ] **Step 3.7: Verify TypeScript still compiles**

Run: `pnpm tsc`
Expected: exit 0, no output.

- [ ] **Step 3.8: Commit**

```bash
git add game/index.html game/vite.config.ts game/src/main.ts game/src/render/pixi-app.ts game/package.json game/pnpm-lock.yaml
git commit -m "feat(game): boot PixiJS into 640×360 logical canvas

Vite serves an index.html that mounts a PixiJS Application at logical
640×360, integer-scaled to fit the window (1×/2×/3×). No sprites yet —
just confirms the toolchain renders.

Per spec §5.1 (resolution) + §5.2 (scene graph)."
git push
```

---

## Task 4: Asset sync pipeline + first sprite on screen

**Why now:** without sprites the canvas is just a black box. This task wires `assets/sprites/` → `game/public/sprites/` and gets one character sprite drawn — the visible proof that the pipeline works end-to-end.

**Files:**
- Create: `game/scripts/sync-sprites.mjs`
- Create: `game/tests/sync-sprites.test.ts`
- Modify: `game/package.json` (add scripts)
- Modify: `game/src/main.ts` (load and add sprite)
- Add devDep: `vitest`

- [ ] **Step 4.1: Add Vitest**

Run:
```bash
cd game
pnpm add -D vitest@~2.1.0
```

- [ ] **Step 4.2: Write the failing test for sync-sprites**

Write `game/tests/sync-sprites.test.ts`:

```ts
import { mkdtemp, mkdir, writeFile, readFile, readdir, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { syncSprites } from '../scripts/sync-sprites.mjs';

let workDir: string;

beforeEach(async () => {
  workDir = await mkdtemp(join(tmpdir(), 'sync-sprites-'));
});

afterEach(async () => {
  await rm(workDir, { recursive: true, force: true });
});

describe('syncSprites', () => {
  it('copies PNGs from src categories into dest under the same subpath', async () => {
    const src = join(workDir, 'src');
    const dest = join(workDir, 'dest');
    await mkdir(join(src, 'character'), { recursive: true });
    await mkdir(join(src, 'cards', 'defense'), { recursive: true });
    await writeFile(join(src, 'character', 'idle.png'), Buffer.from([0x89, 0x50, 0x4e, 0x47]));
    await writeFile(join(src, 'cards', 'defense', 'dodge.png'), Buffer.from([0x89, 0x50, 0x4e, 0x47]));

    const count = await syncSprites({
      src,
      dest,
      categories: ['character', 'cards'],
    });

    expect(count).toBe(2);
    const idle = await readFile(join(dest, 'character', 'idle.png'));
    expect(idle.subarray(0, 4)).toEqual(Buffer.from([0x89, 0x50, 0x4e, 0x47]));
    const dodge = await readFile(join(dest, 'cards', 'defense', 'dodge.png'));
    expect(dodge.subarray(0, 4)).toEqual(Buffer.from([0x89, 0x50, 0x4e, 0x47]));
  });

  it('skips non-PNG files (e.g. .import, .uid, .txt prompts)', async () => {
    const src = join(workDir, 'src');
    const dest = join(workDir, 'dest');
    await mkdir(join(src, 'npc'), { recursive: true });
    await writeFile(join(src, 'npc', 'boss.png'), Buffer.from([0x89, 0x50, 0x4e, 0x47]));
    await writeFile(join(src, 'npc', 'boss.png.import'), 'godot junk');
    await writeFile(join(src, 'npc', 'prompt_npc.txt'), 'ai prompt');

    const count = await syncSprites({ src, dest, categories: ['npc'] });

    expect(count).toBe(1);
    const out = await readdir(join(dest, 'npc'));
    expect(out).toEqual(['boss.png']);
  });

  it('throws if src directory does not exist', async () => {
    const src = join(workDir, 'missing');
    const dest = join(workDir, 'dest');
    await expect(
      syncSprites({ src, dest, categories: ['character'] }),
    ).rejects.toThrow(/sprite source not found/i);
  });
});
```

- [ ] **Step 4.3: Run the test — expect FAIL (module not yet implemented)**

Run:
```bash
cd game
pnpm vitest run tests/sync-sprites.test.ts
```

Expected: FAIL with `Failed to resolve import "../scripts/sync-sprites.mjs"`.

- [ ] **Step 4.4: Implement `game/scripts/sync-sprites.mjs`**

Write `game/scripts/sync-sprites.mjs`:

```js
// Copy PNG sprites from `assets/sprites/<category>/` into `game/public/sprites/<category>/`.
// Run automatically before `pnpm dev` and `pnpm build` via package.json `predev` / `prebuild`.

import { copyFile, mkdir, readdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { join } from 'node:path';

const __dirname = new URL('.', import.meta.url).pathname;

const DEFAULT_CATEGORIES = ['character', 'npc', 'cards', 'hud', 'maps', 'ui', 'scenes'];

// Recursively walk srcDir, copying every *.png into destDir, preserving subpath.
// Returns the number of files copied.
async function copyPngTree(srcDir, destDir) {
  let count = 0;
  const entries = await readdir(srcDir, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = join(srcDir, entry.name);
    const destPath = join(destDir, entry.name);
    if (entry.isDirectory()) {
      await mkdir(destPath, { recursive: true });
      count += await copyPngTree(srcPath, destPath);
    } else if (entry.isFile() && entry.name.toLowerCase().endsWith('.png')) {
      await copyFile(srcPath, destPath);
      count += 1;
    }
  }
  return count;
}

export async function syncSprites({ src, dest, categories = DEFAULT_CATEGORIES } = {}) {
  if (!src) throw new Error('syncSprites: `src` is required');
  if (!dest) throw new Error('syncSprites: `dest` is required');
  if (!existsSync(src)) {
    throw new Error(`syncSprites: sprite source not found at ${src}`);
  }
  let total = 0;
  for (const category of categories) {
    const srcCat = join(src, category);
    if (!existsSync(srcCat)) continue;
    const destCat = join(dest, category);
    await mkdir(destCat, { recursive: true });
    total += await copyPngTree(srcCat, destCat);
  }
  return total;
}

// CLI mode: invoked as `node scripts/sync-sprites.mjs` → sync from
// the repo's assets/sprites/ to game/public/sprites/.
if (import.meta.url === `file://${process.argv[1]}`) {
  const repoRoot = join(__dirname, '..', '..');
  const src = join(repoRoot, 'assets', 'sprites');
  const dest = join(__dirname, '..', 'public', 'sprites');
  const count = await syncSprites({ src, dest });
  console.log(`[sync-sprites] copied ${count} PNG file(s) from ${src} to ${dest}`);
}
```

- [ ] **Step 4.5: Run the test — expect PASS**

Run: `pnpm vitest run tests/sync-sprites.test.ts`
Expected: 3 passed.

- [ ] **Step 4.6: Wire `predev` / `prebuild` / `assets:sync` scripts in `package.json`**

Edit `game/package.json` `scripts`:

```json
"scripts": {
  "tsc": "tsc --noEmit",
  "test": "vitest run",
  "test:watch": "vitest",
  "assets:sync": "node scripts/sync-sprites.mjs",
  "predev": "pnpm assets:sync",
  "prebuild": "pnpm assets:sync",
  "dev": "vite",
  "build": "vite build"
}
```

- [ ] **Step 4.7: Smoke — run `assets:sync` against the real repo and confirm copy count**

Run:
```bash
cd game
pnpm assets:sync
```

Expected output (one line):
`[sync-sprites] copied 70 PNG file(s) from /Users/huanghaibin/Workspace/games/survived-episode-x/assets/sprites to /Users/huanghaibin/Workspace/games/survived-episode-x/game/public/sprites`

Breakdown of the 70: 22 `character/` + 18 `cards/` (defense + offense) + 16 `hud/` (mug/sticky/monitor/chair/desk states) + 9 `npc/` + 3 `scenes/` + 1 `ui/` + 1 `maps/`. The 12 `test_outputs/` PNGs are AI-gen reference sheets (not in-game art) and are intentionally excluded from `DEFAULT_CATEGORIES`. Confirm with `find game/public/sprites -name '*.png' | wc -l` → 70.

- [ ] **Step 4.8: Update `src/main.ts` to display the player idle sprite**

Replace `game/src/main.ts` content with:

```ts
import { Assets, Sprite } from 'pixi.js';
import { createPixiApp } from '@/render/pixi-app';

const PLAYER_IDLE_URL = '/sprites/character/player_idle_anchor.png';

async function main(): Promise<void> {
  const root = document.getElementById('pixi-root');
  if (!root) throw new Error('#pixi-root not found in index.html');
  const { app } = await createPixiApp(root);

  const texture = await Assets.load(PLAYER_IDLE_URL);
  texture.source.scaleMode = 'nearest';
  const sprite = new Sprite(texture);
  sprite.anchor.set(0.5);
  sprite.x = app.screen.width / 2;
  sprite.y = app.screen.height / 2;
  // Scale large source PNG (1024×1024) down to a reasonable on-canvas size.
  // The art is reference-resolution; pixel-perfect downscale to ~128 px tall.
  const targetHeight = 200;
  sprite.scale.set(targetHeight / texture.height);
  app.stage.addChild(sprite);

  console.info('[boot] sprite mounted:', PLAYER_IDLE_URL);
}

void main();
```

- [ ] **Step 4.9: Smoke — open dev server, verify sprite appears**

Run: `pnpm dev`
Open `http://localhost:1420/` in browser.

Expected:
- The 640×360 canvas is no longer black — a pixel-art character sprite is centered
- DevTools console shows: `[boot] PixiJS application ready` followed by `[boot] sprite mounted: /sprites/character/player_idle_anchor.png`
- Image is crisp (pixelated rendering, no smoothing)

If the sprite shows a blurry, antialiased version, inspect the canvas's `image-rendering` style and `texture.source.scaleMode`. Both should be `pixelated` / `nearest`.

Stop dev server.

- [ ] **Step 4.10: Verify everything still typechecks + tests pass**

Run:
```bash
pnpm tsc
pnpm test
```

Expected: both exit 0; vitest reports 3 passed.

- [ ] **Step 4.11: Commit**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/scripts/sync-sprites.mjs game/tests/sync-sprites.test.ts \
        game/src/main.ts game/package.json game/pnpm-lock.yaml
git commit -m "feat(game): sprite sync pipeline + first character on canvas

scripts/sync-sprites.mjs copies PNGs from ../assets/sprites/<category>/
into game/public/sprites/<category>/ before dev and build. Wired into
predev/prebuild hooks. main.ts loads player_idle_anchor.png and centers
it on the 640×360 stage with NEAREST scaling.

Vitest suite: 3 tests covering happy path, non-PNG filter, missing src.

Per spec §4.7 (asset pipeline) + §9.3 step 4."
git push
```

---

## Task 5: Tauri integration — open in a native macOS window

**Why now:** Vite-served sprite proves the web stack. Wrapping in Tauri proves the desktop chain that we'll actually ship.

**Files:**
- Create (via init): `game/src-tauri/Cargo.toml`, `tauri.conf.json`, `build.rs`, `src/main.rs`, `src/lib.rs`, `icons/`, `capabilities/`
- Modify: `game/src-tauri/tauri.conf.json` (window + bundle config)
- Modify: `game/package.json` (add `tauri` script)

- [ ] **Step 5.1: Verify Rust toolchain is installed (Tauri builds Rust shim)**

Run:
```bash
rustc --version
cargo --version
```

Expected: both output a version (rustc `>= 1.75.0`). If missing:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
source "$HOME/.cargo/env"
```

Then re-run `rustc --version` to confirm.

- [ ] **Step 5.2: Add Tauri CLI as a dev dependency**

Run:
```bash
cd game
pnpm add -D @tauri-apps/cli@~2.1.0 @tauri-apps/api@~2.1.0
```

- [ ] **Step 5.3: Initialize Tauri (CI mode, no interactive prompts)**

Run from `game/`:
```bash
pnpm tauri init --ci \
  --app-name "活过第 X 集" \
  --window-title "活过第 X 集" \
  --frontend-dist ../dist \
  --dev-url http://localhost:1420 \
  --identifier com.huanghaibin.survived-episode-x
```

(`--frontend-dist ../dist` is relative to `src-tauri/`, so it points back to `game/dist/` produced by `vite build`.)

Expected:
- `game/src-tauri/` directory created with `Cargo.toml`, `tauri.conf.json`, `build.rs`, `src/main.rs`, `src/lib.rs`, `icons/` (default Tauri logo), `capabilities/`
- `game/package.json` `scripts.tauri` is added by the init: `"tauri": "tauri"`

If the script wasn't auto-added, add it manually under `scripts`:
```json
"tauri": "tauri"
```

- [ ] **Step 5.4: Edit `game/src-tauri/tauri.conf.json` to match spec §8.1**

Open `game/src-tauri/tauri.conf.json` (created by init) and replace the contents with:

```json
{
  "$schema": "https://schema.tauri.app/config/2",
  "productName": "活过第 X 集",
  "version": "0.1.0",
  "identifier": "com.huanghaibin.survived-episode-x",
  "build": {
    "beforeDevCommand": "pnpm dev",
    "devUrl": "http://localhost:1420",
    "beforeBuildCommand": "pnpm build",
    "frontendDist": "../dist"
  },
  "app": {
    "windows": [
      {
        "label": "main",
        "title": "活过第 X 集",
        "width": 1920,
        "height": 1080,
        "minWidth": 640,
        "minHeight": 360,
        "resizable": true,
        "fullscreen": false,
        "center": true
      }
    ],
    "security": {
      "csp": "default-src 'self'; img-src 'self' data:; font-src 'self'; style-src 'self' 'unsafe-inline'"
    }
  },
  "bundle": {
    "active": true,
    "targets": ["dmg", "app"],
    "icon": [
      "icons/32x32.png",
      "icons/128x128.png",
      "icons/128x128@2x.png",
      "icons/icon.icns",
      "icons/icon.ico"
    ],
    "category": "Game",
    "shortDescription": "反向 KPI 办公室生存模拟",
    "longDescription": "（待 ship 前从 design/gdd/game-concept.md 摘要写入）",
    "macOS": {
      "minimumSystemVersion": "12.0",
      "signingIdentity": null,
      "hardenedRuntime": true
    }
  }
}
```

(The `icons/` defaults from `tauri init` are placeholder Tauri logos; that's fine for P0. P5 replaces with project-specific icons.)

- [ ] **Step 5.5: Smoke — run `pnpm tauri dev` and verify a native window opens**

Run:
```bash
cd game
pnpm tauri dev
```

Expected:
- First run: ~30-90 seconds while Cargo compiles `tauri` and dependencies. Subsequent runs are fast.
- A native macOS window opens, titled `活过第 X 集`, sized 1920×1080
- The window contains the same canvas + character sprite as Task 4
- macOS dock shows the app icon (default Tauri logo for now)
- Console (in terminal) prints both Vite logs and Tauri logs

If the window opens but is white / shows a "Failed to load" error: confirm `pnpm dev` is running on port 1420, and that `devUrl` in `tauri.conf.json` matches.

Stop with Ctrl+C.

- [ ] **Step 5.6: Commit**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src-tauri game/package.json game/pnpm-lock.yaml
git commit -m "feat(game): wrap Vite app in Tauri 2 native window

\`pnpm tauri dev\` opens a 1920×1080 macOS window labelled \"活过第 X 集\"
serving the Vite dev bundle from localhost:1420. tauri.conf.json
configured per spec §8.1 with strict CSP, identifier, and bundle targets
[dmg, app].

Per spec §8.1 (Tauri config) + §9.2 P0."
git push
```

---

## Task 6: Production build → installable `.dmg`

**Why now:** dev mode is not a release; we must prove `pnpm tauri build` produces an artifact that installs and runs without the dev toolchain present.

**Files:** none new; verifies existing config produces a `.dmg`.

- [ ] **Step 6.1: Run the production build**

Run:
```bash
cd game
pnpm tauri build
```

Expected output ends with paths like:
```
Finished `release` profile [optimized] target(s) in <Xs>
Bundling 活过第 X 集.app (...src-tauri/target/release/bundle/macos/活过第 X 集.app)
Bundling 活过第 X 集_0.1.0_aarch64.dmg (...src-tauri/target/release/bundle/dmg/活过第 X 集_0.1.0_aarch64.dmg)
```

The `.dmg` filename suffix depends on host architecture (`aarch64` on Apple Silicon, `x64` on Intel). Either is fine for P0.

If the build fails on Cargo compilation: read the first error in the output, cross-check against `https://tauri.app/start/prerequisites/`. Common cause: outdated Xcode Command Line Tools (`xcode-select --install`).

- [ ] **Step 6.2: Verify the `.dmg` exists**

Run:
```bash
ls -lh game/src-tauri/target/release/bundle/dmg/
```

Expected: a single `.dmg` file, ~20-40 MB depending on architecture.

- [ ] **Step 6.3: Smoke — install and launch the `.app`**

Manual steps (cannot be automated):
1. Open `game/src-tauri/target/release/bundle/dmg/` in Finder
2. Double-click the `.dmg` — Finder mounts it and shows the `.app` next to an Applications shortcut
3. Drag `活过第 X 集.app` into `/Applications`
4. Open `/Applications/活过第 X 集.app` (right-click → Open the first time, since unsigned; click "Open" in the Gatekeeper dialog)
5. Confirm the same window from Task 5 appears with the character sprite

Note the macOS warning text — it's the expected Gatekeeper prompt for unsigned apps. Per spec §8.3 we deliberately skipped signing for P0; this confirms the "unsigned distribution" path works.

- [ ] **Step 6.4: Optional clean-room verification — quit dev tools, re-launch the .app**

Quit `pnpm tauri dev` and `pnpm dev` if running. Quit and re-open the installed `.app`. It must still display the sprite — this proves the bundled app is self-contained (does not depend on the dev server or pnpm being up).

- [ ] **Step 6.5: Commit a marker**

There are no source changes from this task — only artifacts under `target/` (gitignored). Record success by appending a one-line note to `game/README.md`:

Append after the existing `## Quick start` block in `game/README.md`:

```markdown
## Status

- **2026-05-03 / Slice 1 P0 complete:** `pnpm tauri build` produces an installable `.dmg`; double-click → drag to Applications → opens a 1920×1080 native window with one sprite. Unsigned (Gatekeeper warning expected on first open).
```

Commit:
```bash
git add game/README.md
git commit -m "docs(game): mark Slice 1 P0 complete — installable .dmg verified

\`pnpm tauri build\` produces a working .dmg on macOS (Apple Silicon).
Manual install + launch confirmed: sprite renders in self-contained
.app, no dev server required."
git push
```

---

## Task 7: Lefthook + Biome — pre-commit guardrails

**Why now:** before P1+ adds significant code, install the typecheck + format gate so future commits don't introduce easy-to-catch mistakes.

**Files:**
- Create: `game/biome.json`
- Create: `game/lefthook.yml`
- Modify: `game/package.json` (add lint script)

- [ ] **Step 7.1: Add Biome**

Run:
```bash
cd game
pnpm add -D @biomejs/biome@~1.9.0
```

- [ ] **Step 7.2: Create `game/biome.json`**

Write `game/biome.json`:

```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "vcs": { "enabled": true, "clientKind": "git", "useIgnoreFile": true },
  "files": {
    "ignore": ["node_modules", "dist", "src-tauri/target", "public/sprites", "src/generated"]
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "style": {
        "useImportType": "error",
        "noNonNullAssertion": "warn"
      },
      "correctness": {
        "noUnusedImports": "error",
        "noUnusedVariables": "error"
      }
    }
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "trailingCommas": "all",
      "semicolons": "always"
    }
  }
}
```

- [ ] **Step 7.3: Add lint scripts to `package.json`**

Edit `game/package.json` `scripts` to add:

```json
"lint": "biome check .",
"lint:fix": "biome check --write .",
"verify": "pnpm assets:sync && pnpm tsc && pnpm lint && pnpm test"
```

The full `scripts` block now looks like:

```json
"scripts": {
  "tsc": "tsc --noEmit",
  "test": "vitest run",
  "test:watch": "vitest",
  "lint": "biome check .",
  "lint:fix": "biome check --write .",
  "assets:sync": "node scripts/sync-sprites.mjs",
  "predev": "pnpm assets:sync",
  "prebuild": "pnpm assets:sync",
  "dev": "vite",
  "build": "vite build",
  "tauri": "tauri",
  "verify": "pnpm assets:sync && pnpm tsc && pnpm lint && pnpm test"
}
```

- [ ] **Step 7.4: Auto-fix existing files to Biome's preferred style**

Run:
```bash
cd game
pnpm lint:fix
```

Expected: Biome reports a small number of fixed files (mostly trailing comma / quote style adjustments to `src/main.ts`, `src/render/pixi-app.ts`, `vite.config.ts`, `scripts/sync-sprites.mjs`, `tests/sync-sprites.test.ts`).

Verify:
```bash
pnpm lint
```
Expected: `Checked X file(s) ... No fixes applied.` (exit 0).

- [ ] **Step 7.5: Install lefthook (single Go binary)**

Run:
```bash
brew install lefthook
lefthook version
```

Expected: e.g. `1.7.x`.

- [ ] **Step 7.6: Create `game/lefthook.yml`**

Write `game/lefthook.yml`:

```yaml
pre-commit:
  parallel: true
  commands:
    typecheck:
      glob: '*.{ts,tsx}'
      run: pnpm --dir game tsc
    biome:
      glob: '*.{ts,tsx,js,mjs,cjs,json}'
      run: pnpm --dir game biome check --staged --no-errors-on-unmatched
    vitest:
      glob: 'game/{src,scripts,tests}/**/*.{ts,mjs}'
      run: pnpm --dir game vitest run --changed --passWithNoTests
```

(`--dir game` lets lefthook be installed at the repo root while the npm scripts live under `game/`.)

- [ ] **Step 7.7: Install lefthook git hooks into `.git/hooks/`**

Lefthook lives at the repo root, so install it from there:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
ln -sf game/lefthook.yml lefthook.yml    # let lefthook find the config
lefthook install
```

Expected: `sync hooks: ✔️ (pre-commit)` and `.git/hooks/pre-commit` becomes a lefthook-managed script.

- [ ] **Step 7.8: Smoke — verify hook blocks a deliberately-broken commit**

Introduce a TS error:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
echo 'const x: number = "this is a string";' >> game/src/main.ts
git add game/src/main.ts
git commit -m "intentionally broken; should be blocked"
```

Expected: lefthook runs typecheck which fails with `TS2322: Type 'string' is not assignable to type 'number'`. The commit is **rejected** (non-zero exit).

Revert the bad change:
```bash
git restore --staged game/src/main.ts
git restore game/src/main.ts
```

Confirm `git status` is clean.

- [ ] **Step 7.9: Verify a clean commit passes the hook**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git status   # should show: lefthook.yml symlink, game/biome.json, game/lefthook.yml, game/package.json, game/pnpm-lock.yaml, plus any biome auto-fixes from Step 7.4
```

Stage everything and commit:

```bash
git add lefthook.yml game/biome.json game/lefthook.yml game/package.json game/pnpm-lock.yaml \
        game/src/ game/scripts/ game/tests/ game/vite.config.ts game/index.html
git commit -m "chore(game): add Biome + lefthook pre-commit guardrails

Biome handles lint+format with strict noUnusedImports/Variables and
useImportType. Lefthook installs a parallel pre-commit hook running
tsc, biome check --staged, and vitest --changed. \`pnpm verify\` runs
the same chain manually.

Per spec §7.4."
git push
```

---

## Task 8: P0 exit verification

**Why:** confirm the toolchain is end-to-end reproducible from a fresh checkout — what we'll demand of every future contributor (or future AI agent).

- [ ] **Step 8.1: Run the full `verify` chain**

```bash
cd game
pnpm verify
```

Expected: assets sync (65 files), tsc (no output), biome (No fixes applied), vitest (3 passed).

- [ ] **Step 8.2: Re-run the production build to confirm reproducibility**

```bash
pnpm tauri build
```

Expected: same `.dmg` file produced under `src-tauri/target/release/bundle/dmg/` (size ±a few hundred bytes).

- [ ] **Step 8.3: Final smoke install**

Manually re-install the new `.dmg` (per Task 6.3) and confirm the window opens with sprite.

- [ ] **Step 8.4: Tag the commit `v0.1.0-p0`**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git tag -a v0.1.0-p0 -m "Slice 1 / Phase 0 complete: Hello Pixi in Tauri

Toolchain verified end-to-end:
- pnpm install → fresh deps
- pnpm verify → tsc + biome + vitest all green
- pnpm tauri build → installable .dmg
- Manual install → 1920x1080 macOS window with character sprite

Per docs/superpowers/plans/2026-05-03-slice1-p0-hello-pixi-tauri.md."
git push --tags
```

- [ ] **Step 8.5: Update `docs/superpowers/specs/2026-05-03-engine-switch-design.md` §9.2 P0 row to mark complete**

In the §9.2 table, change the P0 row's "出口" cell from:

```
`game/` 骨架（vite/tsc/biome/pnpm/tauri 全部能跑）；`pnpm tauri dev` 打开窗口看到一个 `assets/sprites/character/pose_idle.png` 静态精灵；`pnpm tauri build` 产出能双击的 `.app`
```

to:

```
✅ DONE 2026-05-03 (tag `v0.1.0-p0`). All exit criteria met.
```

Commit:
```bash
git add docs/superpowers/specs/2026-05-03-engine-switch-design.md
git commit -m "docs: mark Slice 1 P0 complete in design spec"
git push
```

---

## Self-review checklist for the engineer reading this plan

After completing all tasks, confirm:

- [ ] `pnpm verify` from `game/` is green
- [ ] `pnpm tauri build` produces a `.dmg`
- [ ] Installed `.app` opens to a 1920×1080 window with a centered pixel character
- [ ] Commit `v0.1.0-p0` is tagged and pushed to `xemaya/survived-episode-x`
- [ ] No abandoned Godot files remain in working tree (`find . -name '*.gd' -o -name '*.tres' -o -name '*.gdshader' -o -name 'project.godot' | grep -v .git` returns empty)
- [ ] Lefthook pre-commit hook runs and blocks broken commits

## What is **not** in P0 (waiting for P1+)

- Game state machine (`flow/`) — P1
- AP / KPI / cards systems — P2
- Save / load — P4
- Real game logic in `src/main.ts` (currently it just mounts one sprite — replace at P1 with `flow.subscribe + mountSceneFor`)
- 5 red line lints (only `gen:constants` infra; lint scripts come at Slice 2)
- Audio (Howler is installed but not used)
- Preact UI overlays (preact is installed but not used)
- Custom app icon (uses Tauri default; replace at P5)
- Code signing / notarization (deferred per spec §8.3)

P1 plan will be written after P0 is verified complete.

---

## Notes for Claude when executing this plan

- **Run `pnpm tauri dev` and `pnpm dev` from `game/`, not the repo root.** The npm scripts live in `game/package.json`.
- **If a step's "expected output" doesn't match,** stop and report the actual output instead of pushing through. Toolchain bring-up is exactly when surprises hide.
- **Don't add to or modify `tools/cut_sprites.py`.** Per spec §4.7, it's authoritative as-is. P0 only consumes its outputs.
- **Don't add an icon, splash, or game logic in P0.** Resist scope creep. P0's sole purpose is proving the chain.
- **Tauri's first `cargo build` takes 30-90 seconds** on fresh dependencies. Don't kill it.
- **Sprite chosen for the smoke (`player_idle_anchor.png`) is a 1024×1024 reference**, not in-game art. P1 swaps for a properly-sized in-game sprite as part of constructing the workstation scene.
