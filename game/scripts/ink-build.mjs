// Compile design/vertical-slice/*.ink → game/public/ink/*.json
//
// Uses the JS compiler bundled with inkjs (no .NET inklecate binary needed).
// All INCLUDE statements resolve from the same directory as the source .ink file.
//
// Standalone CLI: `node scripts/ink-build.mjs` (or `pnpm ink:build`)
// Programmatic API (used by ink-vite-plugin.mjs): { compileInkFile, getInkFiles, INK_DIR, OUT_DIR }
//
// Note: each .ink file compiles standalone — INCLUDE relationships are inlined at compile
// time. So `episode-2.ink` (which `INCLUDE episode-1.ink`) produces episode-2.json containing
// both episodes' stitches + shared VAR declarations. For runtime, load only the JSON of the
// currently-active episode.

import { existsSync, readFileSync } from 'node:fs';
import { mkdir, readdir, writeFile } from 'node:fs/promises';
import { basename, dirname, extname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { Compiler, CompilerOptions } from 'inkjs/compiler/Compiler';

const __dirname = fileURLToPath(new URL('.', import.meta.url));
const REPO_ROOT = resolve(__dirname, '../..');

export const INK_DIR = resolve(REPO_ROOT, 'design/vertical-slice');
export const OUT_DIR = resolve(__dirname, '../public/ink');

// Minimal IFileHandler implementation for Node.
// inkjs Compiler calls these to resolve INCLUDE statements.
class NodeFileHandler {
  constructor(baseDir) {
    this.baseDir = baseDir;
  }
  ResolveInkFilename(includeName) {
    return resolve(this.baseDir, includeName);
  }
  LoadInkFileContents(fullFilename) {
    return readFileSync(fullFilename, 'utf-8');
  }
}

export async function compileInkFile(srcPath, outDir = OUT_DIR) {
  await mkdir(outDir, { recursive: true });
  const baseName = basename(srcPath, '.ink');
  const outPath = join(outDir, `${baseName}.json`);

  const inkSource = readFileSync(srcPath, 'utf-8');
  const errors = [];
  const warnings = [];

  const errorHandler = (message, errorType) => {
    // errorType: 0 = Author, 1 = Warning, 2 = Error
    if (errorType === 2) errors.push(message);
    else if (errorType === 1) warnings.push(message);
  };

  const fileHandler = new NodeFileHandler(dirname(srcPath));
  const options = new CompilerOptions(srcPath, [], false, errorHandler, fileHandler);

  let story;
  try {
    const compiler = new Compiler(inkSource, options);
    story = compiler.Compile();
  } catch (err) {
    throw new Error(`compile crashed for ${baseName}: ${err.message}\n${errors.join('\n')}`);
  }

  if (errors.length > 0) {
    throw new Error(`${baseName}: ${errors.length} error(s):\n${errors.join('\n')}`);
  }
  if (warnings.length > 0) {
    console.warn(`⚠ ${baseName}: ${warnings.length} warning(s)`);
    for (const w of warnings.slice(0, 5)) console.warn(`  ${w}`);
    if (warnings.length > 5) console.warn(`  …${warnings.length - 5} more suppressed`);
  }

  const json = story.ToJson();
  await writeFile(outPath, json, 'utf-8');
  console.log(`✓ ${baseName}.ink → ${baseName}.json (${(json.length / 1024).toFixed(1)} KB)`);
  return outPath;
}

export async function getInkFiles(dir = INK_DIR) {
  const entries = await readdir(dir, { withFileTypes: true });
  return entries
    .filter((e) => e.isFile() && extname(e.name) === '.ink')
    .map((e) => join(dir, e.name))
    .sort();
}

async function main() {
  if (!existsSync(INK_DIR)) {
    console.error(`Ink source dir not found: ${INK_DIR}`);
    process.exit(1);
  }

  const files = await getInkFiles();
  if (files.length === 0) {
    console.warn(`No .ink files found in ${INK_DIR}`);
    return;
  }

  console.log(`Compiling ${files.length} .ink file(s)...`);
  let okCount = 0;
  for (const f of files) {
    try {
      await compileInkFile(f);
      okCount += 1;
    } catch (err) {
      console.error(`✗ ${basename(f)}: ${err.message}`);
    }
  }
  console.log(`\nDone: ${okCount}/${files.length} succeeded → ${OUT_DIR}`);
  if (okCount < files.length) process.exit(1);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}
