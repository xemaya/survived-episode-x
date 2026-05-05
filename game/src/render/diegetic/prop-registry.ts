// Prop registry (P5 T05-mini + T03-prop).
//
// Holds the set of currently-mounted PropEntity instances by id, and
// translates ink `# prop: <id>_<state>` / `# diegetic_prop: …` tag
// values into setState() calls.
//
// Tag-value parsing strategy: longest-prefix match against registered
// ids. The architecture spec allows ids that themselves contain
// underscores (e.g. `sticky_huo_dao_zhouwu` whose state is `fresh`).
// Splitting on the first underscore would break those — instead we
// scan registered ids longest-first and accept the first that the tag
// value begins with `<id>_`. Pure function so it can be unit-tested.

import type { PropEntity } from './prop-entity';

export interface ParsedPropTag {
  id: string;
  state: string;
}

export class PropRegistry {
  private byId = new Map<string, PropEntity>();

  register(entity: PropEntity): void {
    if (this.byId.has(entity.id)) {
      console.warn(`[prop-registry] re-registering id "${entity.id}"`);
    }
    this.byId.set(entity.id, entity);
  }

  unregister(id: string): void {
    this.byId.delete(id);
  }

  get(id: string): PropEntity | undefined {
    return this.byId.get(id);
  }

  has(id: string): boolean {
    return this.byId.has(id);
  }

  ids(): string[] {
    return Array.from(this.byId.keys());
  }

  /**
   * Apply a tag value (e.g. "fruit_bowl_apple", "phone_face_down")
   * to the matching entity. Returns true on success, false when the
   * value doesn't match any registered id.
   */
  async setStateFromTag(value: string): Promise<boolean> {
    const parsed = parsePropTagValue(value, this.ids());
    if (!parsed) {
      console.warn(`[prop-registry] no entity matches tag value "${value}"`);
      return false;
    }
    const entity = this.byId.get(parsed.id);
    if (!entity) return false;
    await entity.setState(parsed.state);
    return true;
  }

  /** Drop all registrations (typically on scene unmount). */
  clear(): void {
    this.byId.clear();
  }

  /** For debug: snapshot of id → currentState. */
  snapshot(): Record<string, string> {
    const out: Record<string, string> = {};
    for (const [id, entity] of this.byId) out[id] = entity.currentState;
    return out;
  }
}

/**
 * Pure helper: split a `# prop:` tag value into `{id, state}` against
 * a known-ids set. Longest-prefix match — id may contain underscores.
 *
 * Returns null when no registered id is a `<id>_…` prefix of `value`,
 * or when `value` exactly equals an id (no state suffix).
 */
export function parsePropTagValue(
  value: string,
  knownIds: ReadonlyArray<string>,
): ParsedPropTag | null {
  const trimmed = value.trim();
  if (trimmed.length === 0) return null;
  // Sort longest-first so `sticky_huo_dao_zhouwu_fresh` matches the long id
  // before the short `sticky` (if both exist).
  const sortedIds = [...knownIds].sort((a, b) => b.length - a.length);
  for (const id of sortedIds) {
    const prefix = `${id}_`;
    if (trimmed.startsWith(prefix)) {
      const state = trimmed.slice(prefix.length);
      if (state.length === 0) return null;
      return { id, state };
    }
  }
  return null;
}

// Singleton — production code routes through this.
export const propRegistry = new PropRegistry();
