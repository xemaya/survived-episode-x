// T-2 (W1 P1): NPC sprite slot registry.
//
// Replaces the speech-bubble-era npc-anchors.ts (deleted by Q-R). The
// new contract: when ink emits `# npc: <id>_<state_descriptor>`, parse
// the leading NPC id, mount that NPC's sprite at a designated
// workstation position, and keep it mounted until the scene changes
// (`# scene: <new>` fires `clearAll()`). One sprite per NPC; descriptor
// suffixes (`_holding_milk_tea_cup`, `_typing_facing_screen`) are
// ignored — W5 ships one canonical sprite per NPC, and the state
// descriptor is narrative-only flavor for now.
//
// Multi-NPC scenes accumulate: each new id mounts an additional
// sprite. Re-emitting the same id is a no-op (the sprite stays where
// it is). `clearAll()` is wired to scene-change in workstation.ts.
//
// Anchors borrow the geometry from the deleted npc-anchors.ts but are
// re-purposed: they're now the SPRITE bottom-center coordinate (the
// NPC "stands at" anchor.{x,y}) with sprite anchor (0.5, 1).
//
// W5 sprite assets used (all under public/sprites/npc/):
//   lisa_sprite / david_sprite / vivian_sprite / wang_director_sprite
//   / lao_zhou_sprite / zoe_sprite / li_ayi_sprite / mama_sprite
//   / it_xiaoma_sprite / lin_jie / cafeteria_auntie

import { Assets, type Container, Sprite } from 'pixi.js';

interface NpcConfig {
  spriteUrl: string;
  /** Bottom-center sprite position (sprite anchor 0.5, 1). */
  x: number;
  y: number;
  /** Native asset → display scale. Tuned per-sprite if W5 assets vary. */
  scale: number;
}

// Q-Z (Bug #39, 2026-05-07): scale bumped 0.3 → 0.6 across the board
// (T-2 initial sprites rendered ~30 px tall on a 256×96 source — too
// small to read). Positions re-tuned per workstation visual logic so
// no NPC sprite overlaps the panel (y=240-336) or sticky band
// (y=170-240). Sprite anchor (0.5, 1) so config.y = bottom of sprite
// (i.e. where the NPC "stands"). Coordinates derived from the scene
// description in series-structure.md (cubicle layout: protagonist
// center, Lisa adjacent right, David mid-left, 老周 far right, etc.).
export const NPC_TABLE: Readonly<Record<string, NpcConfig>> = {
  lisa: { spriteUrl: 'sprites/npc/lisa_sprite.png', x: 520, y: 200, scale: 0.6 },
  david: { spriteUrl: 'sprites/npc/david_sprite.png', x: 160, y: 200, scale: 0.6 },
  vivian: { spriteUrl: 'sprites/npc/vivian_sprite.png', x: 560, y: 130, scale: 0.6 },
  wang_director: {
    spriteUrl: 'sprites/npc/wang_director_sprite.png',
    x: 320,
    y: 120,
    scale: 0.6,
  },
  lao_zhou: { spriteUrl: 'sprites/npc/lao_zhou_sprite.png', x: 580, y: 200, scale: 0.6 },
  zoe: { spriteUrl: 'sprites/npc/zoe_sprite.png', x: 260, y: 130, scale: 0.6 },
  li_ayi: { spriteUrl: 'sprites/npc/li_ayi_sprite.png', x: 80, y: 270, scale: 0.6 },
  mama: { spriteUrl: 'sprites/npc/mama_sprite.png', x: 320, y: 180, scale: 0.6 },
  lin_jie: { spriteUrl: 'sprites/npc/lin_jie.png', x: 200, y: 130, scale: 0.6 },
  it_xiaoma: { spriteUrl: 'sprites/npc/it_xiaoma_sprite.png', x: 140, y: 200, scale: 0.6 },
  cafeteria_auntie: {
    spriteUrl: 'sprites/npc/cafeteria_auntie.png',
    x: 320,
    y: 270,
    scale: 0.6,
  },
};

/** Tag-value aliases that resolve to a canonical NPC id. */
export const NPC_ALIASES: Readonly<Record<string, string>> = {
  food_court_auntie: 'cafeteria_auntie',
  // Some episodes refer to 李阿姨 as `lao_li`; treat as alias of li_ayi.
  lao_li: 'li_ayi',
};

const NPC_PREFIX_LOOKUP: ReadonlyArray<string> = [
  ...Object.keys(NPC_TABLE),
  ...Object.keys(NPC_ALIASES),
].sort((a, b) => b.length - a.length);

/** Parse a tag value like `lisa_holding_milk_tea_cup` into the
 * canonical NPC id (`lisa`). Aliases (`food_court_auntie`,
 * `lao_li`) are normalized. Returns null if no known id matches.
 *
 * Pure — exposed for unit tests. */
export function parseNpcId(tagValue: string): string | null {
  const trimmed = tagValue.trim().toLowerCase();
  if (trimmed.length === 0) return null;
  for (const id of NPC_PREFIX_LOOKUP) {
    // Match either exact id OR id followed by `_<state-descriptor>`.
    if (trimmed === id || trimmed.startsWith(`${id}_`)) {
      return NPC_ALIASES[id] ?? id;
    }
  }
  return null;
}

class NpcRegistry {
  private parent: Container | null = null;
  private mounted = new Map<string, Sprite>();

  attach(parent: Container): void {
    this.parent = parent;
  }

  /** Mount the NPC sprite for this tag value if it isn't already mounted.
   * Idempotent — repeat tag emissions for the same NPC are no-ops. */
  async handleTag(tagValue: string): Promise<void> {
    if (!this.parent) return;
    const id = parseNpcId(tagValue);
    if (!id) {
      console.warn('[npc-registry] no NPC matches tag value:', tagValue);
      return;
    }
    if (this.mounted.has(id)) return;
    const config = NPC_TABLE[id];
    if (!config) return;
    try {
      const tex = await Assets.load(config.spriteUrl);
      tex.source.scaleMode = 'linear';
      const sprite = new Sprite(tex);
      sprite.label = `npc:${id}`;
      sprite.anchor.set(0.5, 1);
      sprite.x = config.x;
      sprite.y = config.y;
      sprite.scale.set(config.scale);
      this.parent.addChild(sprite);
      this.mounted.set(id, sprite);
    } catch (err) {
      console.warn(`[npc-registry] failed to mount ${id}:`, err);
    }
  }

  /** Bug #14 mirror: scene change → all transient NPCs unmount.
   * They re-mount on the next `# npc:` tag in the new scene. */
  clearAll(): void {
    for (const sprite of this.mounted.values()) {
      sprite.destroy();
    }
    this.mounted.clear();
  }

  detach(): void {
    this.clearAll();
    this.parent = null;
  }

  /** Test/debug introspection. */
  mountedIds(): ReadonlyArray<string> {
    return Array.from(this.mounted.keys()).sort();
  }
}

export const npcRegistry = new NpcRegistry();
