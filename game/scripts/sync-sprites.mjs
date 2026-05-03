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
