// NPC screen-anchor registry — used by speech-bubble.ts to know where the
// tail of a bubble should point when an NPC is speaking.
//
// These positions are STUBS for the workstation scene (640×360 logical
// canvas). They will be refreshed when T05/T06 wires real NPC sprite slots
// — at that point the anchor for each NPC becomes a function of the
// sprite's actual `npc.position + headOffset`. Until then the coords are
// hand-tuned to "narratively plausible" positions per GM playtest
// (Bug #16, 2026-05-06):
//
//   - protagonist sits center-bottom; visible cubicles flank left + right
//   - Lisa is the right-adjacent cubicle peer
//   - 老周 sits further right (mid-row)
//   - David occupies the mid-left desk area (across the room)
//   - 王总监 / Zoe enter from the top (meeting / HR room)
//   - 李阿姨 mops along the bottom-left
//   - IT 小马 hangs around the coffee machine (lower-left)
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
  // Deep-cast (5) — narrative geometry per GM Bug #16 re-tune
  Lisa: { x: 480, y: 130 }, // right-near adjacent cubicle
  David: { x: 180, y: 160 }, // mid-left desk, across the room
  大伟: { x: 180, y: 160 },
  Vivian: { x: 440, y: 80 }, // reception / entrance (top-right)
  王总监: { x: 320, y: 80 }, // mid-top — projector / walks past
  李阿姨: { x: 120, y: 250 }, // cleaning, bottom-left

  // Bit-cast (5)
  'IT 小马': { x: 140, y: 210 }, // coffee machine lower-left
  老周: { x: 540, y: 160 }, // right-mid (further right than Lisa)
  周哥: { x: 540, y: 160 },
  妈妈: { x: 320, y: 180 }, // phone scene only — mid-screen
  林姐: { x: 200, y: 130 }, // cross-team lead, mid-left

  // Future NPCs (daily choices / S2+ slots) — placeholder positions
  Beth: { x: 480, y: 130 },
  Eric: { x: 380, y: 130 },
  Cassie: { x: 220, y: 100 },
  Zoe: { x: 260, y: 80 }, // HR room (top-mid-left)
  食堂阿姨: { x: 320, y: 200 }, // cafeteria (mid)
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
  // Deep-cast (5 visible NPCs) — coords mirror the Chinese-name table
  // above; both go away once T05/T06 sprite slots own positioning.
  lisa: { x: 480, y: 130 }, // right-near adjacent cubicle
  david: { x: 180, y: 160 }, // mid-left desk, across the room
  vivian: { x: 440, y: 80 }, // reception / entrance (top-right)
  wang_director: { x: 320, y: 80 }, // mid-top — projector / walks past
  lao_zhou: { x: 540, y: 160 }, // right-mid (further right than Lisa)
  // Bit-cast / S2+ slots
  zoe: { x: 260, y: 80 }, // HR room (top-mid-left)
  li_ayi: { x: 120, y: 250 }, // cleaning, bottom-left
  mama: { x: 320, y: 180 }, // phone scene only — mid-screen
  lin_jie: { x: 200, y: 130 }, // cross-team lead, mid-left
  it_xiaoma: { x: 140, y: 210 }, // coffee machine lower-left
  food_court_auntie: { x: 320, y: 200 }, // cafeteria (mid)
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
