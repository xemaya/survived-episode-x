// NPC screen-anchor registry — used by speech-bubble.ts to know where the
// tail of a bubble should point when an NPC is speaking.
//
// These positions are STUBS for the workstation scene (640×360 logical
// canvas). They will be refreshed when T05/T06 wires real NPC sprite slots
// — at that point the anchor for each NPC becomes a function of the
// sprite's actual `npc.position + headOffset`. For now they place each
// known NPC roughly where their sprite would land in concept 01/02.
//
// `getNpcAnchor()` returns null for unknown speakers so the dialog router
// can fall back to the narration panel rather than render a bubble at a
// guessed location.

export interface NpcAnchor {
  /** Where the bubble tail tip points (NPC mouth/head). */
  x: number;
  y: number;
}

const NPC_ANCHORS: Readonly<Record<string, NpcAnchor>> = {
  // Deep-cast (5)
  Lisa: { x: 470, y: 110 },
  David: { x: 175, y: 115 },
  大伟: { x: 175, y: 115 },
  Vivian: { x: 320, y: 130 },
  王总监: { x: 220, y: 95 },
  李阿姨: { x: 130, y: 250 },

  // Bit-cast (5)
  'IT 小马': { x: 175, y: 200 },
  老周: { x: 460, y: 130 },
  周哥: { x: 460, y: 130 },
  妈妈: { x: 320, y: 180 },
  林姐: { x: 305, y: 110 },

  // Future NPCs introduced via daily choices / S2+ slots
  Beth: { x: 480, y: 130 },
  Eric: { x: 380, y: 130 },
  Cassie: { x: 220, y: 100 },
  Zoe: { x: 260, y: 90 },
  食堂阿姨: { x: 320, y: 220 },
};

export function getNpcAnchor(name: string): NpcAnchor | null {
  return NPC_ANCHORS[name.trim()] ?? null;
}

export function isKnownNpc(name: string): boolean {
  return name.trim() in NPC_ANCHORS;
}

/** All registered names (for tests / debug overlays). */
export function listKnownNpcs(): string[] {
  return Object.keys(NPC_ANCHORS);
}

// ─────────────────────────────────────────────────────────────────────
// Q-1 (`# speaker:` tag) — id → anchor mapping per GM reply
// (`p5-phase2-engine-questions.md` Q-1 reply, 2026-05-05).
//
// The id namespace is content-stable; engine resolves id → screen
// anchor without reading dialog text. Once T05/T06 NPC sprite slots
// land, this table goes away in favor of `npcSpriteSlot[id].anchor`.
//
// `protagonist` is intentionally absent — speaker tag of `protagonist`
// means "笑天 internal voice": no bubble, route to monologue / panel
// per the existing layered renderer.
// ─────────────────────────────────────────────────────────────────────

const NPC_ANCHORS_BY_ID: Readonly<Record<string, NpcAnchor>> = {
  // Deep-cast (5 visible NPCs)
  lisa: { x: 470, y: 110 },
  david: { x: 175, y: 115 },
  vivian: { x: 320, y: 130 },
  wang_director: { x: 220, y: 95 },
  lao_zhou: { x: 460, y: 130 },
  // Bit-cast / S2+ slots
  zoe: { x: 260, y: 90 },
  li_ayi: { x: 130, y: 250 },
  mama: { x: 320, y: 180 },
  lin_jie: { x: 305, y: 110 },
  it_xiaoma: { x: 175, y: 200 },
  food_court_auntie: { x: 320, y: 220 },
};

export function getNpcAnchorById(id: string): NpcAnchor | null {
  return NPC_ANCHORS_BY_ID[id.trim()] ?? null;
}

export function isKnownNpcId(id: string): boolean {
  return id.trim() in NPC_ANCHORS_BY_ID;
}

export function listKnownNpcIds(): string[] {
  return Object.keys(NPC_ANCHORS_BY_ID);
}
