// Episode loader: fetch compiled .ink → .json files from /ink/ public path
// (built by scripts/ink-build.mjs).

import { ink } from './runtime';

export type EpisodeId = 'episode-1' | 'episode-2' | 'episode-3' | 'episode-4' | 'daily-choices';

const EPISODE_PATHS: Record<EpisodeId, string> = {
  'episode-1': '/ink/episode-1.json',
  'episode-2': '/ink/episode-2.json',
  'episode-3': '/ink/episode-3.json',
  'episode-4': '/ink/episode-4.json',
  'daily-choices': '/ink/daily-choices.json',
};

/** Load an episode story into the singleton InkRuntime. */
export async function loadEpisode(id: EpisodeId): Promise<void> {
  await ink.loadStory(EPISODE_PATHS[id]);
}
