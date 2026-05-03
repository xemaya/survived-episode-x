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
