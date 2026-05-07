// Episode loader: fetch compiled .ink → .json files from /ink/ public path
// (built by scripts/ink-build.mjs).
//
// Paths are prefixed with `import.meta.env.BASE_URL` (Vite injects this at
// build time) so they work both at root (dev / Tauri = '/') and under a
// sub-path (GitHub Pages = '/survived-episode-x/').

import { ink } from './runtime';

export type EpisodeId = 'episode-1' | 'episode-2' | 'episode-3' | 'episode-4' | 'daily-choices';

const BASE = import.meta.env.BASE_URL.replace(/\/$/, '');

const EPISODE_PATHS: Record<EpisodeId, string> = {
  'episode-1': `${BASE}/ink/episode-1.json`,
  'episode-2': `${BASE}/ink/episode-2.json`,
  'episode-3': `${BASE}/ink/episode-3.json`,
  'episode-4': `${BASE}/ink/episode-4.json`,
  'daily-choices': `${BASE}/ink/daily-choices.json`,
};

/** Load an episode story into the singleton InkRuntime. */
export async function loadEpisode(id: EpisodeId): Promise<void> {
  await ink.loadStory(EPISODE_PATHS[id]);
}
