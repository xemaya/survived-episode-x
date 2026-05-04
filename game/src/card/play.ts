import { type ApSystem, ap as defaultAp } from '@/economy/ap';
import { type KpiSystem, kpi as defaultKpi } from '@/economy/kpi';
import { autosave } from '@/save/autosave';
import type { Card, CardId } from './card';

// Context for playCard. Tests pass their own instances; production calls
// playCard(card) which resolves to the singletons below via the default.
export interface PlayCardContext {
  ap: ApSystem;
  kpi: KpiSystem;
  // Fired after Step 1 of the 7-step sequence. P3+ wires this to the
  // event-script engine for trigger lookup.
  onCardPlayed: (id: CardId) => void;
  // Cards that have been played today; populated at Step 7 (history).
  // Hand UI passes the Set so it can re-render disabled state.
  playedThisDay: Set<CardId>;
}

const defaultPlayedThisDay = new Set<CardId>();
const defaultEmitter = (_id: CardId): void => {
  /* no-op until event engine lands */
};

// Production entry point: play a card using the singleton AP/KPI/etc.
// Pass an explicit ctx in tests.
export function playCard(
  card: Card,
  ctx: PlayCardContext = {
    ap: defaultAp,
    kpi: defaultKpi,
    onCardPlayed: defaultEmitter,
    playedThisDay: defaultPlayedThisDay,
  },
): void {
  // Pre-checks (Rule 6 and "already played" guard before mutating anything).
  if (ctx.playedThisDay.has(card.id)) {
    throw new Error(`Card ${card.id} already played this day`);
  }
  if (!ctx.ap.canAfford(card.apCost)) {
    throw new Error(
      `Cannot afford card ${card.id}: needs ${card.apCost} AP, have ${ctx.ap.current}`,
    );
  }

  // Commit the play to playedThisDay BEFORE side-effect emitters fire.
  // GDD lists "history" as Step 7 (last), but our `playedThisDay` set
  // doubles as the UI's "is this card now PLAYED" guard — and ap.spend
  // synchronously triggers hand.redraw which calls evaluateCardState.
  // If we waited until Step 7, the hand would re-render seeing the card
  // still NOT in playedThisDay → would render as IDLE/DISABLED instead
  // of PLAYED → user sees no visual feedback until the NEXT click.
  // Committing up-front fixes that without breaking the existing tests
  // (none of the 7 step bodies read playedThisDay; the pre-check above
  // already enforces the "already played" invariant).
  ctx.playedThisDay.add(card.id);

  // Step 0 (pre-emit): spend AP. GDD rule 6 says AP is consumed before the
  // 7-step sequence starts; we keep that ordering so the AP indicator
  // updates immediately when the click registers.
  ctx.ap.spend(card.apCost);

  // Step 1: emit card_played for trigger lookup.
  ctx.onCardPlayed(card.id);

  // Step 2: hero card report — per GDD action-card-system 7-step sequence.
  // reportHeroCardPlayed() increments the monthly hero counter used by
  // Formula B's α term (computeEffortNorm in kpi.ts).
  if (card.isHero) {
    ctx.ap.reportHeroCardPlayed();
  }

  // Step 3: apply kpi_contribution from each effect.
  for (const effect of card.effects) {
    switch (effect.kind) {
      case 'kpi_contribution':
        ctx.kpi.applyContribution(effect.amount);
        break;
    }
  }

  // Steps 4 (NPC), 5 (mutex), 6 (cooldown) deferred to P3+.
  // Step 7 (history) was committed up-front above for UI-render correctness.

  // Autosave: fire-and-forget after every card play so progress survives crashes.
  void autosave();
}

// Test/UI helper: shared mutable set of cards played this day. Reset
// every day-start. UI subscribes via observation (re-evaluating
// evaluateCardState on every render).
export const playedThisDay = defaultPlayedThisDay;

// Reset on new day. Called by the day-advance flow (P2 implementation
// is a button or auto-trigger when AP=0).
export function resetPlayedThisDay(): void {
  defaultPlayedThisDay.clear();
}
