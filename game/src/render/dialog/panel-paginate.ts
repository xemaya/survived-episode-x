// Q-V (Bug #34): pure-text helper that splits a body string at the
// nearest natural break (sentence terminator → newline → forced cut)
// so a long ink step can paginate inside the 96 px panel without
// being clipped by the body mask.
//
// Used by `runtime.ts step()` AFTER the chunk-accumulation loop —
// when the assembled text exceeds the panel budget, the runtime
// stashes the tail on the existing pendingChunk machinery (the same
// pause path used by `# pagebreak` and Q-R source-split). The
// renderer's existing ▼ tap-to-continue affordance then drives
// `step()` again to drain the stash.
//
// Per avg-architecture.md §1.6 the ▼ shows whenever step.paused; with
// the runtime stashing the tail, paused=true here is identical to the
// pagebreak case from the renderer's perspective.

/** Approximate character budget for one panel page. Body region is
 * 78 px tall after the header bar (96 - 18); padding 6 top + 6 bottom
 * = 66 inner; lineHeight 16 → ~4 lines. wordWrapWidth ≈ 576 px;
 * 13 px CJK glyph fits ~32 chars per line; 4 × 32 = 128 chars rough
 * cap. 130 leaves a small safety margin against measurement drift. */
export const PANEL_TEXT_BUDGET = 130;

const SENTENCE_TERMINATORS = ['。', '？', '！', '?', '!'];

/** Split `text` so the head fits within `budget` chars at a sensible
 * boundary (sentence terminator, then newline, then forced cut at
 * exactly `budget`). Returns `{ head, tail: '' }` when no split is
 * needed (text within budget). Pure — no side effects. */
export function paginateAtSentenceBoundary(
  text: string,
  budget: number = PANEL_TEXT_BUDGET,
): { head: string; tail: string } {
  if (text.length <= budget) return { head: text, tail: '' };

  // Look for a sentence terminator in the latter half of the budget
  // window so the page reads as a complete thought, not a stranded
  // sub-clause.
  const minIdx = Math.floor(budget * 0.4);
  for (let i = budget - 1; i >= minIdx; i--) {
    const ch = text[i];
    if (ch !== undefined && SENTENCE_TERMINATORS.includes(ch)) {
      return { head: text.slice(0, i + 1), tail: text.slice(i + 1) };
    }
  }

  // No sentence terminator — try a paragraph (newline) boundary.
  const nlIdx = text.lastIndexOf('\n', budget);
  if (nlIdx >= minIdx) {
    return { head: text.slice(0, nlIdx), tail: text.slice(nlIdx + 1) };
  }

  // Forced cut at exactly `budget` — better a clean break than a
  // clipped overflow. Trims leading whitespace on the tail so the
  // next page doesn't start with an awkward space.
  return { head: text.slice(0, budget), tail: text.slice(budget).replace(/^\s+/, '') };
}
