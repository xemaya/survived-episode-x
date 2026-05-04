import {
  type MetaState,
  type RunState,
  defaultMetaState,
  metaStateSchema,
  runStateSchema,
} from './schema';
import { type SaveFs, tauriFs as productionFs } from './tauri-fs';

const SAVES_DIR = 'saves';
const CURRENT_RUN_PATH = `${SAVES_DIR}/current_run.save`;
const META_PATH = `${SAVES_DIR}/meta.save`;
const ARCHIVE_PATH = (runId: number) => `${SAVES_DIR}/archive/${runId}.save`;

export class SaveSystem {
  private fs: SaveFs;
  // Last error message from a failed load — UI dialog reads this.
  lastLoadError: string | null = null;

  constructor(fs: SaveFs = productionFs) {
    this.fs = fs;
  }

  async hasCurrentRun(): Promise<boolean> {
    return this.fs.exists(CURRENT_RUN_PATH);
  }

  async loadCurrentRun(): Promise<RunState | null> {
    this.lastLoadError = null;
    if (!(await this.fs.exists(CURRENT_RUN_PATH))) return null;
    let raw: string;
    try {
      raw = await this.fs.read(CURRENT_RUN_PATH);
    } catch (e) {
      this.lastLoadError = `read failed: ${(e as Error).message}`;
      return null;
    }
    let parsed: unknown;
    try {
      parsed = JSON.parse(raw);
    } catch (e) {
      this.lastLoadError = `JSON parse failed: ${(e as Error).message}`;
      return null;
    }
    const result = runStateSchema.safeParse(parsed);
    if (!result.success) {
      this.lastLoadError = `schema validation failed: ${result.error.message}`;
      return null;
    }
    return result.data;
  }

  async writeCurrentRun(state: RunState): Promise<void> {
    await this.fs.ensureDir(SAVES_DIR);
    await this.fs.writeAtomic(CURRENT_RUN_PATH, JSON.stringify(state, null, 2));
  }

  async clearCurrentRun(): Promise<void> {
    if (await this.fs.exists(CURRENT_RUN_PATH)) {
      await this.fs.delete(CURRENT_RUN_PATH);
    }
  }

  async loadMeta(): Promise<MetaState> {
    if (!(await this.fs.exists(META_PATH))) return defaultMetaState();
    try {
      const raw = await this.fs.read(META_PATH);
      const parsed = JSON.parse(raw);
      const result = metaStateSchema.safeParse(parsed);
      if (!result.success) {
        // Corrupt meta — start fresh. (Real impl backs up the old file; P4 stubs.)
        this.lastLoadError = `meta corrupt: ${result.error.message}`;
        return defaultMetaState();
      }
      return result.data;
    } catch {
      return defaultMetaState();
    }
  }

  async writeMeta(meta: MetaState): Promise<void> {
    await this.fs.ensureDir(SAVES_DIR);
    await this.fs.writeAtomic(META_PATH, JSON.stringify(meta, null, 2));
  }

  async writeArchiveSnapshot(runId: number, state: RunState): Promise<void> {
    await this.fs.ensureDir(`${SAVES_DIR}/archive`);
    await this.fs.writeAtomic(ARCHIVE_PATH(runId), JSON.stringify(state, null, 2));
  }

  async loadArchiveSnapshot(runId: number): Promise<RunState | null> {
    if (!(await this.fs.exists(ARCHIVE_PATH(runId)))) return null;
    try {
      const raw = await this.fs.read(ARCHIVE_PATH(runId));
      const parsed = JSON.parse(raw);
      const result = runStateSchema.safeParse(parsed);
      return result.success ? result.data : null;
    } catch {
      return null;
    }
  }
}

// Singleton — production code uses this; tests construct their own.
export const save = new SaveSystem();
