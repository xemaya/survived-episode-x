#!/usr/bin/env node
// Speaker-tag migration tool (Q-1 §2 / GM reply, 2026-05-05).
//
// Walks design/vertical-slice/*.ink and prepends `# speaker: <id>`
// before every line that begins with a known speaker prefix
// (`**Lisa**：`, `Lisa："…"`, `王总监站起来：…` etc.). Skips lines
// that already have an immediate-prior `# speaker:` tag (idempotent).
//
// USAGE:
//   node tools/ink-speaker-migrate.mjs            # dry-run, prints diff
//   node tools/ink-speaker-migrate.mjs --write    # apply in-place
//
// SAFETY:
//   - Idempotent: re-runs are no-ops once tags are in place.
//   - Skips prop-quote lines (e.g. `桌面便利贴：`) — only known speakers
//     in the GM mapping table get a tag.
//   - Pre-write diff is printed for designer review.
//   - DOES NOT touch the trailing dialog line itself; only inserts a
//     tag line before it. The Lisa："好的" body stays exactly as
//     authored so tone/punctuation are preserved.
//
// After designer reviews + applies, the engine still keeps
// `speaker-parser.ts` as a fallback for any beat we missed; once full
// coverage is verified, the parser can be deleted in a follow-up.

import { readFile, readdir, writeFile } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = fileURLToPath(new URL('.', import.meta.url));
const REPO_ROOT = resolve(__dirname, '..');
const INK_DIR = resolve(REPO_ROOT, 'design/vertical-slice');

// GM-authoritative speaker → id table (`p5-phase2-engine-questions.md` Q-1 reply).
// Multiple display names can map to the same id (e.g. 老周 / 周哥 → lao_zhou).
const SPEAKER_TO_ID = new Map([
  ['Lisa', 'lisa'],
  ['David', 'david'],
  ['大伟', 'david'],
  ['Vivian', 'vivian'],
  ['王总监', 'wang_director'],
  ['老周', 'lao_zhou'],
  ['周哥', 'lao_zhou'],
  ['Zoe', 'zoe'],
  ['李阿姨', 'li_ayi'],
  ['妈妈', 'mama'],
  ['林姐', 'lin_jie'],
  ['IT 小马', 'it_xiaoma'],
  ['食堂阿姨', 'food_court_auntie'],
  ['你', 'protagonist'],
]);

// Speaker prefix line: optional `**`-wrapped name, then full-width colon.
// Capture group 1 = bold-wrapped name, group 2 = plain name. Either
// captures the speaker label.
const SPEAKER_LINE_RE =
  /^(?:\*\*([^*：]+?)\*\*|([^：\s][^：]*?))[：](.*)$/;

const WRITE = process.argv.includes('--write');

async function migrateFile(inkPath) {
  const src = await readFile(inkPath, 'utf-8');
  const lines = src.split('\n');
  const out = [];
  let inserted = 0;
  let skipped = 0;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();
    const m = trimmed.match(SPEAKER_LINE_RE);
    if (!m) {
      out.push(line);
      continue;
    }
    const speaker = (m[1] ?? m[2] ?? '').trim();
    const id = SPEAKER_TO_ID.get(speaker);
    if (!id) {
      out.push(line);
      continue;
    }
    // Skip if previous non-empty line is already a `# speaker:` tag for
    // this speaker (idempotency).
    let lookback = i - 1;
    while (lookback >= 0 && lines[lookback].trim() === '') lookback--;
    const prev = lookback >= 0 ? lines[lookback].trim() : '';
    if (prev === `# speaker: ${id}` || prev.startsWith(`# speaker: ${id}`)) {
      out.push(line);
      skipped++;
      continue;
    }
    // Match the leading whitespace of the dialog line so the tag
    // sits at the same indentation (preserves ink's choice nesting).
    const indent = line.match(/^\s*/)[0];
    out.push(`${indent}# speaker: ${id}`);
    out.push(line);
    inserted++;
  }

  return { content: out.join('\n'), inserted, skipped };
}

async function main() {
  const files = (await readdir(INK_DIR))
    .filter((f) => f.endsWith('.ink'))
    .sort();

  let totalInserted = 0;
  let totalSkipped = 0;
  for (const f of files) {
    const inkPath = join(INK_DIR, f);
    const { content, inserted, skipped } = await migrateFile(inkPath);
    totalInserted += inserted;
    totalSkipped += skipped;
    if (inserted === 0) {
      console.log(`= ${f}: no changes (${skipped} already tagged)`);
      continue;
    }
    if (WRITE) {
      await writeFile(inkPath, content, 'utf-8');
      console.log(`✓ ${f}: +${inserted} speaker tags (${skipped} skipped)`);
    } else {
      console.log(`~ ${f}: +${inserted} speaker tags would be added (${skipped} already tagged) — dry run`);
    }
  }

  console.log(
    `\n${WRITE ? 'Wrote' : 'Would write'} ${totalInserted} new # speaker: tags across ${files.length} ink files (${totalSkipped} already tagged).`,
  );
  if (!WRITE) {
    console.log('Re-run with --write to apply.');
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
