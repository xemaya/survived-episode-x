// Speaker detection for ink-emitted text blocks.
//
// Ink content writes NPC dialog as either `**Name**："..."` (bold marker)
// or `Name："..."` on a line. parseSpeaker() extracts the speaker name
// from the FIRST paragraph and returns the dialog body — but only when
// the speaker is in the NPC anchor registry, so prop-quotes like
// `桌面便利贴："活到周五"` don't get rendered as a speech bubble.
//
// The remainder of the block (paragraphs after the speaker line) is
// returned so the dialog renderer can keep showing it as narration.

import { isKnownNpc } from './npc-anchors';

export interface SpeakerParseResult {
  speaker: string;
  /** Dialog body (already stripped of leading speaker prefix + outer quotes). */
  dialog: string;
  /** Remaining paragraphs after the speaker line (joined with `\n`, may be ''). */
  remainder: string;
}

// Matches:
//   **Name**：rest        — bold-wrapped speaker
//   Name：rest            — plain speaker
// Name allows ASCII / CJK / spaces but no `*` or `：`.
const SPEAKER_RE = /^(?:\*\*([^*：]+?)\*\*|([^：\s][^：]*?))[：](.+)$/;

// Outer Chinese / ASCII quotes wrapping the dialog.
const OUTER_QUOTES_RE = /^[“"]+|[”"]+$/g;

export function parseSpeaker(text: string): SpeakerParseResult | null {
  if (!text) return null;
  const lines = text.split('\n');
  const firstLine = lines[0]?.trim() ?? '';
  const m = firstLine.match(SPEAKER_RE);
  if (!m) return null;

  const speaker = (m[1] ?? m[2] ?? '').trim();
  if (!isKnownNpc(speaker)) return null;

  const dialogRaw = (m[3] ?? '').trim();
  const dialog = dialogRaw.replace(OUTER_QUOTES_RE, '').trim();
  const remainder = lines.slice(1).join('\n').trim();

  return { speaker, dialog, remainder };
}
