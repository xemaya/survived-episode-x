import {
  BaseDirectory,
  exists,
  mkdir,
  readTextFile,
  remove,
  rename,
  writeTextFile,
} from '@tauri-apps/plugin-fs';

// Thin abstraction over Tauri 2's fs plugin. All paths are relative to
// AppData base directory (auto-namespaced by tauri.conf.json identifier).
// Tests inject an alternative implementation via dependency injection
// in SaveSystem.
export interface SaveFs {
  exists(path: string): Promise<boolean>;
  read(path: string): Promise<string>;
  // Atomic write: writes to {path}.tmp, then renames over path.
  writeAtomic(path: string, content: string): Promise<void>;
  delete(path: string): Promise<void>;
  ensureDir(path: string): Promise<void>;
}

const BASE = { baseDir: BaseDirectory.AppData };

export const tauriFs: SaveFs = {
  async exists(path) {
    return exists(path, BASE);
  },
  async read(path) {
    return readTextFile(path, BASE);
  },
  async writeAtomic(path, content) {
    const tmp = `${path}.tmp`;
    await writeTextFile(tmp, content, BASE);
    // Tauri 2 rename overwrites destination atomically on the same volume.
    await rename(tmp, path, { ...BASE, newPathBaseDir: BaseDirectory.AppData });
  },
  async delete(path) {
    await remove(path, BASE);
  },
  async ensureDir(path) {
    if (!(await exists(path, BASE))) {
      await mkdir(path, { ...BASE, recursive: true });
    }
  },
};
