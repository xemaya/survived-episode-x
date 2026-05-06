// Dialog-state singleton — Bug #11 (T16 follow-up).
//
// Captures the last *visible* narration text so that:
//   1. Save snapshots can persist it alongside the ink runtime state.
//   2. On reload, the dialog can pre-fill its panel with the prior
//      content instead of rendering a `...` placeholder when ink's
//      `Continue()` has nothing to drain (because the text was
//      already consumed pre-save).
//
// Lives outside ink-dialog.ts (mount-time closure) so the save layer
// can read it without coupling to the renderer.

class DialogState {
  private _lastNarrationText = '';

  /** Latest panel narration the player has seen. Empty string when no
   * narration has rendered yet (boot before first paint). */
  get lastNarrationText(): string {
    return this._lastNarrationText;
  }

  /** Called by ink-dialog.paintStep after it sets `text.text` to a
   * real (non-placeholder) string. Pass an empty string to clear. */
  setLastNarrationText(text: string): void {
    this._lastNarrationText = text;
  }

  /** Test cleanup. Production code uses `setLastNarrationText('')`. */
  reset(): void {
    this._lastNarrationText = '';
  }
}

export const dialogState = new DialogState();
