// Per design/gdd/action-card-system.md §schema. P2 implements a SUBSET of
// the full schema fields — the rest (npc_target, mutex_group,
// unlock_condition, event_id_link) are deferred to P3+ and explicitly
// omitted here. When P3 adds them, extend Card with optional fields
// (don't redesign — TS structural typing handles additive changes).

export type CardId = string;

// Effect placeholder. Real discriminated union per spec §4.1 (effects)
// arrives with the EventScript engine in Slice 2. P2's effects only need
// to carry their kpi_contribution (the only thing card play uses in steps
// 1-3 of the 7-step sequence).
export interface CardEffect {
  kind: 'kpi_contribution';
  amount: number;
}

export interface Card {
  id: CardId;
  apCost: 1 | 2 | 3; // GDD enforces strict {1,2,3}
  isHero: boolean;
  // Per-card sprite face URL. Resolved by sync-sprites; relative path so
  // it works in both vite dev and Tauri release (P0 lesson, see memory).
  faceUrl: string;
  title: string; // Chinese label shown on card
  // P2 consumes only kpi_contribution effects via play.ts. Future effects
  // (NPC relationship, AP refund, etc.) extend the union and are no-ops
  // until their owning system lands.
  effects: ReadonlyArray<CardEffect>;
}

// 4-state machine per design/gdd/action-card-system.md "4-state machine
// (per-card, evaluated on every hand refresh)".
export type CardState = 'IDLE' | 'PLAYABLE' | 'DISABLED' | 'PLAYED';

// Pure function: given a card and the current AP balance + whether it's
// already been played this day, return its state. Called by hand UI on
// every render.
export function evaluateCardState(
  card: Card,
  currentAp: number,
  playedThisDay: boolean,
): CardState {
  if (playedThisDay) return 'PLAYED';
  if (currentAp < card.apCost) return 'DISABLED';
  return 'IDLE';
  // PLAYABLE is set by the hand UI when the card is hover/focused — the
  // state machine here returns IDLE; the UI overlays PLAYABLE on top.
}
