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

  describe('T16 ink state field', () => {
    it('round-trips a runState with inkStateJson set', async () => {
      const state = defaultRunState();
      state.inkStateJson = '{"flows":{"DEFAULT_FLOW":{"callstack":[]}}}';
      await save.writeCurrentRun(state);
      const loaded = await save.loadCurrentRun();
      expect(loaded?.inkStateJson).toBe(state.inkStateJson);
    });

    it('parses pre-T16 saves (no inkStateJson field) without error', async () => {
      // Simulate an older save that predates the T16 schema field.
      const legacy = { ...defaultRunState() };
      // biome-ignore lint/performance/noDelete: deliberate legacy shape
      delete (legacy as Partial<typeof legacy>).inkStateJson;
      await fs.writeAtomic('saves/current_run.save', JSON.stringify(legacy));
      const loaded = await save.loadCurrentRun();
      expect(loaded).not.toBeNull();
      expect(loaded?.inkStateJson).toBeUndefined();
    });

    it('round-trips the lastNarrationText field (Bug #11 / T16 follow-up)', async () => {
      const state = defaultRunState();
      state.lastNarrationText =
        '游戏从 2026 年 5 月开始。\n\n活过这一年(52 周)就赢——是"熬过去"那种赢。';
      await save.writeCurrentRun(state);
      const loaded = await save.loadCurrentRun();
      expect(loaded?.lastNarrationText).toBe(state.lastNarrationText);
    });

    it('parses saves missing lastNarrationText (older T16 saves stay valid)', async () => {
      const partial = { ...defaultRunState() };
      // biome-ignore lint/performance/noDelete: simulate older T16 save
      delete (partial as Partial<typeof partial>).lastNarrationText;
      await fs.writeAtomic('saves/current_run.save', JSON.stringify(partial));
      const loaded = await save.loadCurrentRun();
      expect(loaded).not.toBeNull();
      expect(loaded?.lastNarrationText).toBeUndefined();
    });
  });
});
