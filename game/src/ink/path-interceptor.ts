// Path interceptor — Q-4 / T20 prep.
//
// Some narrative branches (E8 D56 Lisa finale message, E12 finale
// recap, etc.) need ink to take a specific path BEFORE the player
// would otherwise see a `* [...]` choice — the branch is decided by
// accumulated game state (sick_count, hero_count, lisa_score, etc.)
// rather than a Decision-Moment click. ink's `* [...]` syntax doesn't
// help when path D or E should NEVER be a player-visible option.
//
// Hook: designer marks each interceptable stitch with a
//   `# checkpoint: <stitch_name>`
// tag at the top. The runtime sees this tag in step()'s Continue()
// loop, looks up `pathInterceptor.shouldRedirect(stitch_name, ink)`,
// and — if a registered rule's condition resolves true — calls
// `story.ChoosePathString(target)` to redirect. The chunk that
// emitted the checkpoint tag is discarded so the default-path text
// never reaches the player.
//
// Why tag-based instead of `state.currentPathString` polling:
// inkjs's `currentPathString` is an internal program-counter index
// (e.g. `"0"` at flow start, `"day_56_event_3.2"` mid-paragraph),
// not the stitch name. A pre-pass before Continue() doesn't see the
// stitch the runtime is about to enter. Tag-based matching is
// explicit and reliable.
//
// Conditions read variables via the InkRuntime `getVar` surface, so
// the interceptor stays decoupled from ink-internal types.

export interface PathInterceptorContext {
  /** Read a global ink VAR. Same surface as `InkRuntime.getVar`. */
  getVar<T = unknown>(name: string): T | null;
}

export interface PathRedirect {
  /** Stitch name that the designer marks with
   * `# checkpoint: <beforeStitch>`. Match is by exact string equality
   * against the tag value emitted from inside that stitch. */
  beforeStitch: string;
  /** Pure predicate over the runtime's variable state. Side-effect
   * free — runtime calls this from step()'s checkpoint hook. */
  condition: (ctx: PathInterceptorContext) => boolean;
  /** Path-string to divert to when condition holds. Same syntax as
   * `Story.ChoosePathString(...)`. */
  target: string;
  /** Optional human-readable id (for tests / debug logs). */
  label?: string;
}

export class PathInterceptor {
  private redirects: PathRedirect[] = [];

  /** Register a redirect rule. Returns an unregister function. */
  register(r: PathRedirect): () => void {
    this.redirects.push(r);
    return () => {
      this.redirects = this.redirects.filter((x) => x !== r);
    };
  }

  /** Drop every registered rule. Test cleanup. */
  clear(): void {
    this.redirects = [];
  }

  /** All registered rules (read-only snapshot — for tests / debug). */
  list(): ReadonlyArray<PathRedirect> {
    return [...this.redirects];
  }

  /**
   * Pure dispatch: given the stitch name carried by a
   * `# checkpoint: <stitch>` tag and a variable-read surface, return
   * the first matching redirect's `target` (or null if none apply).
   * Caller fires ChoosePathString and discards the chunk that emitted
   * the checkpoint tag.
   */
  shouldRedirect(stitchName: string, ctx: PathInterceptorContext): string | null {
    for (const r of this.redirects) {
      if (r.beforeStitch === stitchName && r.condition(ctx)) {
        return r.target;
      }
    }
    return null;
  }
}

/** Singleton — production code routes through this. */
export const pathInterceptor = new PathInterceptor();
