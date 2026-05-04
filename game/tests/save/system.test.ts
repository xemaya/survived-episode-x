import { beforeEach, describe, expect, it } from 'vitest';
import { type MetaState, defaultMetaState, defaultRunState } from '../../src/save/schema';
import { SaveSystem } from '../../src/save/system';
import type { SaveFs } from '../../src/save/tauri-fs';

// In-memory mock fs for tests
class MemoryFs implements SaveFs {
  files = new Map<string, string>();
  dirs = new Set<string>(['']);

  async exists(path: string): Promise<boolean> {
    return this.files.has(path) || this.dirs.has(path);
  }
  async read(path: string): Promise<string> {
    const v = this.files.get(path);
    if (v === undefined) throw new Error(`ENOENT: ${path}`);
    return v;
  }
  async writeAtomic(path: string, content: string): Promise<void> {
    this.files.set(path, content);
  }
  async delete(path: string): Promise<void> {
    this.files.delete(path);
  }
  async ensureDir(path: string): Promise<void> {
    this.dirs.add(path);
  }
}

describe('SaveSystem', () => {
  let fs: MemoryFs;
  let save: SaveSystem;

  beforeEach(() => {
    fs = new MemoryFs();
    save = new SaveSystem(fs);
  });

  describe('current_run.save', () => {
    it('returns null when no save exists', async () => {
      expect(await save.loadCurrentRun()).toBeNull();
    });

    it('round-trips a RunState', async () => {
      const state = defaultRunState();
      state.apCurrent = 5;
      state.kpiActual = 42;
      await save.writeCurrentRun(state);
      const loaded = await save.loadCurrentRun();
      expect(loaded).not.toBeNull();
      expect(loaded?.apCurrent).toBe(5);
      expect(loaded?.kpiActual).toBe(42);
    });

    it('returns null + reports corrupt on schemaVersion mismatch', async () => {
      const bad = { ...defaultRunState(), schemaVersion: 99 };
      await fs.writeAtomic('saves/current_run.save', JSON.stringify(bad));
      const result = await save.loadCurrentRun();
      expect(result).toBeNull();
      expect(save.lastLoadError).toMatch(/schema|version/i);
    });

    it('returns null + reports corrupt on malformed JSON', async () => {
      await fs.writeAtomic('saves/current_run.save', '{not json');
      expect(await save.loadCurrentRun()).toBeNull();
      expect(save.lastLoadError).toMatch(/parse|json/i);
    });

    it('hasCurrentRun() reports true after write', async () => {
      expect(await save.hasCurrentRun()).toBe(false);
      await save.writeCurrentRun(defaultRunState());
      expect(await save.hasCurrentRun()).toBe(true);
    });

    it('clearCurrentRun() removes the file', async () => {
      await save.writeCurrentRun(defaultRunState());
      await save.clearCurrentRun();
      expect(await save.hasCurrentRun()).toBe(false);
    });
  });

  describe('meta.save', () => {
    it('returns defaultMetaState when no meta exists', async () => {
      const meta = await save.loadMeta();
      expect(meta).toEqual(defaultMetaState());
    });

    it('round-trips meta with archive entries', async () => {
      const meta: MetaState = {
        ...defaultMetaState(),
        nextRunId: 5,
        hrWordLibrary: ['HR_EVAL_BURNOUT_FATIGUE'],
      };
      await save.writeMeta(meta);
      const loaded = await save.loadMeta();
      expect(loaded.nextRunId).toBe(5);
      expect(loaded.hrWordLibrary).toEqual(['HR_EVAL_BURNOUT_FATIGUE']);
    });
  });

  describe('archive', () => {
    it('writes and reads back per-run archive file', async () => {
      const state = defaultRunState();
      await save.writeArchiveSnapshot(7, state);
      const loaded = await save.loadArchiveSnapshot(7);
      expect(loaded?.apCurrent).toBe(state.apCurrent);
    });
  });
});
