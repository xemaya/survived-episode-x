// Pure helper: extract whole-italic ink paragraphs into an internal
// monologue stream, separate from narration that stays in the panel.
//
// Ink content marks a line as protagonist's inner thought by wrapping
// it entirely in `_…_` markdown, e.g.:
//   _他不会发现的。_
//   _或者他发现了，他不会说什么。_
//
// Inline italic (a single italic word in the middle of a sentence)
// stays with the surrounding paragraph; only paragraphs whose ENTIRE
// trimmed body is `_X_` get hoisted into the monologue overlay.

const WHOLE_ITALIC_RE = /^_([\s\S]+)_$/;

export interface MonologueSplit {
  /** Italic-paragraph bodies (markers stripped) joined by '\n'. */
  monologue: string;
  /** Non-italic paragraphs preserved verbatim, joined by '\n'. */
  remainder: string;
}

export function extractInternalMonologue(text: string): MonologueSplit {
  if (!text) return { monologue: '', remainder: '' };
  // Ink emits one paragraph per Continue() chunk, concatenated by
  // `\n`; split on every newline so each candidate is one paragraph.
  const lines = text.split('\n');
  const monoParts: string[] = [];
  const restParts: string[] = [];
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.length === 0) {
      // Preserve blank lines on the remainder side so paragraph
      // boundaries survive when the monologue is plucked out.
      restParts.push('');
      continue;
    }
    const m = trimmed.match(WHOLE_ITALIC_RE);
    if (m) {
      monoParts.push(m[1]!.trim());
    } else {
      restParts.push(line);
    }
  }
  // Collapse leading / trailing blank lines and runs of >1 blank
  // line on the remainder so the panel doesn't show an empty band
  // where italic paragraphs were lifted out.
  const cleanedRemainder = restParts
    .join('\n')
    .replace(/\n{3,}/g, '\n\n')
    .replace(/^\s+|\s+$/g, '');
  return {
    monologue: monoParts.join('\n'),
    remainder: cleanedRemainder,
  };
}
