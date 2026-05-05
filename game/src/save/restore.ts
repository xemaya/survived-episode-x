import { ap } from '@/economy/ap';
import { kpi } from '@/economy/kpi';
import { calendar } from '@/flow/calendar';
import type { RunState } from './schema';

// Mutates singletons to match a loaded RunState. Called on boot if a
// save exists. The reverse direction (snapshot singletons → RunState)
// is in snapshot.ts (used for autosave).
//
// Note: ink runtime state restoration is NOT done here — it depends on
// the ink story JSON having been loaded first (which happens in
// main.ts after the FSM is set up). main.ts reads `state.inkStateJson`
// directly and calls `ink.loadState()` after `loadEpisode()` resolves.
export function applyRunState(state: RunState): void {
  // AP: restore current value via reset + spend.
  ap.resetForNewDay();
  if (state.apCurrent < ap.max) {
    ap.spend(ap.max - state.apCurrent);
  }

  // Effort counters: restore from saved state.
  ap.setEffortForRestore(state.effortOvertime, state.effortHero, state.effortOverage);

  // KPI: similar — needs a setForRestore that bypasses the additive guard.
  // For P4 Task 1, only reset to defaults; Task 4 wires real restore.
  // (This is OK because Task 1 just adds the persistence layer; full
  // restore semantics land alongside the energy + effort modules in
  // Task 4 when we have setForRestore methods on every domain singleton.)
  void kpi;

  // Calendar
  while (calendar.currentDay < state.currentDay) calendar.advanceDay();

  // P5: Card hand removed; playedThisDay field is no-op (kept in schema for back-compat).
  void state.playedThisDay;
}
