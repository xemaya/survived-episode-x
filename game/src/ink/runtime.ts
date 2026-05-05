// Inkjs runtime wrapper.
//
// Loads compiled .ink → .json story files (built by scripts/ink-build.mjs),
// drives story.Continue() in chunks, surfaces choices, exposes # tag stream
// to the renderer layer. Single source of truth for narrative state.
//
// Save/load: ink runtime state is serialized via story.state.toJson() and
// stored alongside the rest of the game save (see save/system.ts P5 extension).

import { Story } from 'inkjs';

export interface ParsedTag {
  /** raw tag without leading `#`, e.g. "scene: workstation" */
  raw: string;
  /** key part before colon, e.g. "scene"; if no colon, whole tag */
  key: string;
  /** value part after colon, trimmed; empty string if no colon */
  value: string;
}

export interface InkChoice {
  index: number;
  text: string;
}

export interface InkStoryStep {
  /** Concatenated paragraph text from this Continue() chunk. May be empty. */
  text: string;
  /** All `# tags` emitted between the last chunk and this one. */
  tags: ParsedTag[];
  /** Whether the story can Continue() further. */
  canContinue: boolean;
  /** Choices presented (only populated when !canContinue). */
  choices: InkChoice[];
  /** True when story has reached `-> END` (no more content, no choices). */
  ended: boolean;
  /** True when step() stopped at a `# pagebreak` tag instead of running
   * out of canContinue or hitting a choice. Caller should render
   * accumulated text + a tap-to-continue affordance, then call step()
   * again to resume from where the loop broke. Per Q-2 GM reply. */
  paused: boolean;
}

export class InkRuntime {
  private story: Story | null = null;
  private currentJsonPath: string | null = null;
  // Pagebreak machinery (Q-2): when ink emits a chunk whose tags
  // include `pagebreak`, the chunk is stashed here and the current
  // step() returns with paused=true *before* the chunk is shown. The
  // next step() drains the stash first, so the player sees the
  // post-break content cleanly. State is intra-session only — saves
  // are taken at choice boundaries, where pending is null.
  private pendingChunk: string | null = null;
  private pendingTags: ParsedTag[] | null = null;

  /** Load a compiled story JSON. Replaces any current story. */
  async loadStory(jsonPath: string): Promise<void> {
    const res = await fetch(jsonPath);
    if (!res.ok) {
      throw new Error(`InkRuntime.loadStory: failed to fetch ${jsonPath} (HTTP ${res.status})`);
    }
    const json = await res.text();
    this.story = new Story(json);
    this.currentJsonPath = jsonPath;
    this.pendingChunk = null;
    this.pendingTags = null;
  }

  /** Direct construction from JSON string (for tests and HMR). */
  loadStoryFromJson(json: string, sourceLabel = '<inline>'): void {
    this.story = new Story(json);
    // Surface ink runtime errors via console instead of letting them
    // bubble through React/Pixi event handlers as uncaught exceptions.
    this.story.onError = (msg, type) => {
      console.warn(`[ink runtime ${type}]`, msg);
    };
    this.currentJsonPath = sourceLabel;
    this.pendingChunk = null;
    this.pendingTags = null;
  }

  get isLoaded(): boolean {
    return this.story !== null;
  }

  get sourcePath(): string | null {
    return this.currentJsonPath;
  }

  /** Drive Continue() until !canContinue OR a `# pagebreak` tag arrives,
   * batching all output text + tags up to that point. Wraps every
   * Continue() in try/catch so a single bad path returns an "ended"
   * step (rendered as "[runtime error]") instead of crashing the Pixi
   * event handler — caller can recover by diverting elsewhere.
   *
   * Pagebreak semantics (Q-2 GM reply): when a Continue() chunk
   * carries the `pagebreak` tag, the chunk + tags are stashed on the
   * runtime and step() returns paused=true with whatever text was
   * accumulated *before* it. The next step() call drains the stash
   * first so the player sees a clean break — designer's intent is
   * "everything before this beat goes on this page; the new chunk is
   * the start of the next page". Standalone-tag idiom is supported
   * (the conventional placement: `# pagebreak` on its own line
   * between recap text and `-> next_stitch`). */
  step(): InkStoryStep {
    const story = this.requireStory();
    let text = '';
    const tags: ParsedTag[] = [];
    let paused = false;

    // 1. Drain any chunk stashed by a previous pagebreak. The pagebreak
    //    tag itself is intentionally dropped — its job is done.
    if (this.pendingChunk !== null) {
      text += this.pendingChunk;
      const carry = (this.pendingTags ?? []).filter((t) => t.key !== 'pagebreak');
      for (const t of carry) tags.push(t);
      this.pendingChunk = null;
      this.pendingTags = null;
    }

    try {
      while (story.canContinue) {
        const chunk = story.Continue() ?? '';
        const newTags = (story.currentTags ?? []).map((t) => parseTag(t));
        const hasPagebreak = newTags.some((t) => t.key === 'pagebreak');
        if (hasPagebreak) {
          // Stash for next step() — current step ends *before* this
          // chunk is shown so the page break is visible to the player.
          this.pendingChunk = chunk;
          this.pendingTags = newTags;
          paused = true;
          break;
        }
        text += chunk;
        for (const t of newTags) tags.push(t);
      }
    } catch (err) {
      console.error('[ink runtime] step() crashed:', err);
      return {
        text: `${text}\n\n[runtime error: ${(err as Error).message}]`,
        tags,
        canContinue: false,
        choices: [],
        ended: true,
        paused: false,
      };
    }

    const choices: InkChoice[] = (story.currentChoices ?? []).map((c, i) => ({
      index: i,
      text: c.text ?? '',
    }));

    // `ended` only when nothing else can drive the story forward —
    // canContinue is false, no choices, and we're not pending a
    // post-pagebreak resume.
    const ended =
      !story.canContinue && choices.length === 0 && !paused && this.pendingChunk === null;
    return { text, tags, canContinue: story.canContinue, choices, ended, paused };
  }

  /** Select choice by index (0-based) and immediately step the story.
   * Returns an "ended" step on out-of-bounds (so renderer can show error)
   * rather than throwing — keeps the Pixi event handler clean. */
  selectChoice(index: number): InkStoryStep {
    const story = this.requireStory();
    const available = story.currentChoices.length;
    if (index < 0 || index >= available) {
      console.warn(
        `[ink runtime] selectChoice: index ${index} out of bounds (have ${available}); ignoring`,
      );
      return {
        text: '',
        tags: [],
        canContinue: false,
        choices: [],
        ended: true,
        paused: false,
      };
    }
    story.ChooseChoiceIndex(index);
    return this.step();
  }

  /** Read a global VAR (returns null if undefined). */
  getVar<T = unknown>(name: string): T | null {
    const story = this.requireStory();
    const v = story.variablesState[name];
    return (v ?? null) as T | null;
  }

  /** Write a global VAR. Throws if name not declared in story. */
  setVar(name: string, value: unknown): void {
    const story = this.requireStory();
    story.variablesState[name] = value as never;
  }

  /** All declared global VAR names (read-only). */
  listVars(): string[] {
    const story = this.requireStory();
    // variablesState is an InkVariablesState; accessing globalVariables is internal but stable
    // biome-ignore lint/suspicious/noExplicitAny: inkjs API surface is loose
    const vars = (story.variablesState as any)._globalVariables;
    if (!vars) return [];
    return Array.from(vars.keys());
  }

  /** Divert to a named knot/stitch directly (used by GO triggers from TS). */
  divertTo(path: string): void {
    const story = this.requireStory();
    story.ChoosePathString(path);
  }

  /** Serialize current runtime state for Save (returns JSON string). */
  serializeState(): string {
    const story = this.requireStory();
    return story.state.toJson();
  }

  /** Restore runtime state from a previously serialized JSON. */
  loadState(json: string): void {
    const story = this.requireStory();
    story.state.LoadJson(json);
    this.pendingChunk = null;
    this.pendingTags = null;
  }

  /** Reset story to its starting position (re-init state to defaults). */
  resetState(): void {
    const story = this.requireStory();
    story.ResetState();
    this.pendingChunk = null;
    this.pendingTags = null;
  }

  private requireStory(): Story {
    if (!this.story) {
      throw new Error('InkRuntime: no story loaded — call loadStory() first');
    }
    return this.story;
  }
}

/** Parse a raw ink tag string (without leading `#`) into structured form. */
export function parseTag(raw: string): ParsedTag {
  const trimmed = raw.trim();
  const colon = trimmed.indexOf(':');
  if (colon < 0) {
    return { raw: trimmed, key: trimmed, value: '' };
  }
  return {
    raw: trimmed,
    key: trimmed.slice(0, colon).trim(),
    value: trimmed.slice(colon + 1).trim(),
  };
}

// Singleton — every production import goes through this instance.
export const ink = new InkRuntime();
