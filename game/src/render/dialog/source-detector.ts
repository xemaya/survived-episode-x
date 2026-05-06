// Q-R (avg-architecture.md §1.4): pure helper that classifies an ink
// chunk into one of three sources — narration / monologue / NPC.
//
// Used by:
//   - `runtime.ts step()` for source-boundary auto-split (a chunk
//     whose source ≠ the accumulated source forces a virtual
//     pagebreak so each panel paint carries one source only).
//   - `ink-dialog.ts paintStep()` to pick the panel's header label
//     and body style (italic gray for monologue, upright cream
//     otherwise).
//
// Detection priority (per spec §1.4):
//   1. `# speaker: <id>` tag — primary. `protagonist` → monologue,
//      everything else → NPC with a display-name lookup.
//   2. Legacy fallback: `**Name**：…` or `Name：…` line at the start
//      of the chunk (for ink content authored before the speaker
//      tag convention).
//   3. Whole-italic `_…_` paragraph → monologue.
//   4. Default → narration.

import type { ParsedTag } from '@/ink/runtime';

export type Source = { kind: 'narration' } | { kind: 'monologue' } | { kind: 'npc'; name: string };

export const NARRATION: Source = { kind: 'narration' };
export const MONOLOGUE: Source = { kind: 'monologue' };

// `# speaker: <id>` → display name shown in the panel header bar.
// Synced with the speaker tag values found in design/vertical-slice/
// episode-*.ink (grep'd 2026-05-06: david / food_court_auntie / lisa /
// mama / protagonist / vivian / wang_director / zoe / it_xiaoma /
// li_ayi / lin_jie / lao_zhou).
const SPEAKER_ID_TO_DISPLAY: Readonly<Record<string, string>> = {
  lisa: 'Lisa',
  david: 'David',
  vivian: 'Vivian',
  wang_director: '王总监',
  lao_zhou: '老周',
  zoe: 'Zoe',
  li_ayi: '李阿姨',
  mama: '妈妈',
  lin_jie: '林姐',
  it_xiaoma: 'IT 小马',
  food_court_auntie: '食堂阿姨',
};

// Legacy `Name：dialog` prefix detection. Names mirror SPEAKER_ID_TO_DISPLAY's
// values plus historical aliases (`大伟` for david, `周哥` for lao_zhou).
const LEGACY_NPC_NAMES: ReadonlyArray<string> = [
  'Lisa',
  'David',
  '大伟',
  'Vivian',
  '王总监',
  '李阿姨',
  '老周',
  '周哥',
  '妈妈',
  '林姐',
  'Zoe',
  'IT 小马',
  '食堂阿姨',
];

const LEGACY_ALIAS_NORMALIZE: Readonly<Record<string, string>> = {
  大伟: 'David',
  周哥: '老周',
};

function escapeForRegex(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

const LEGACY_NPC_RE = new RegExp(
  `^\\s*\\*?\\*?(${LEGACY_NPC_NAMES.map(escapeForRegex).join('|')})\\*?\\*?[：]`,
);

// Q-X (Bug #37): strip the leading "Name：" / "**Name**：" prefix from
// an NPC body so the panel header `[ Lisa ]` doesn't read with the
// name appearing twice. Matches any known NPC display name OR alias —
// the source-detector already mapped 大伟 → David / 周哥 → 老周 via
// LEGACY_ALIAS_NORMALIZE; the prefix in the original body is whichever
// the writer used, so we strip whichever matches.
const STRIP_PREFIX_RE = new RegExp(
  `^\\s*\\*?\\*?(${LEGACY_NPC_NAMES.map(escapeForRegex).join('|')})\\*?\\*?[：:]\\s*`,
);

const WHOLE_ITALIC_RE = /^_[\s\S]+_$/;

export function detectSource(text: string, tags: ReadonlyArray<ParsedTag>): Source {
  // 1. Explicit speaker tag wins.
  for (const tag of tags) {
    if (tag.key === 'speaker') {
      const id = tag.value.trim();
      if (id === 'protagonist') return MONOLOGUE;
      const display = SPEAKER_ID_TO_DISPLAY[id];
      if (display) return { kind: 'npc', name: display };
    }
  }

  const trimmed = text.trim();
  if (trimmed.length === 0) return NARRATION;

  // 2. Legacy `Name：…` prefix on the first line.
  const firstLine = trimmed.split('\n')[0] ?? '';
  const m = firstLine.match(LEGACY_NPC_RE);
  if (m) {
    const name = m[1] ?? '';
    return { kind: 'npc', name: LEGACY_ALIAS_NORMALIZE[name] ?? name };
  }

  // 3. Whole-italic paragraph → monologue.
  if (WHOLE_ITALIC_RE.test(trimmed)) return MONOLOGUE;

  // 4. Default.
  return NARRATION;
}

export function sourcesEqual(a: Source, b: Source): boolean {
  if (a.kind !== b.kind) return false;
  if (a.kind === 'npc' && b.kind === 'npc') return a.name === b.name;
  return true;
}

/** Q-X (Bug #37): when the panel header bar already shows the NPC
 * label, the body shouldn't repeat the speaker prefix ("Lisa：…"). Used
 * by ink-dialog's drawPanel for NPC sources only — narration and
 * monologue bodies pass through unchanged. */
export function stripSpeakerPrefix(body: string): string {
  return body.replace(STRIP_PREFIX_RE, '');
}

/** Display label shown in the panel's 8px-style header bar (公文抬头). */
export function sourceLabel(source: Source): string {
  switch (source.kind) {
    case 'narration':
      return '视角';
    case 'monologue':
      return '笑天';
    case 'npc':
      return source.name;
  }
}
