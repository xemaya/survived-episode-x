import { playedThisDay } from '@/card/play';
import { ap } from '@/economy/ap';
import { kpi } from '@/economy/kpi';
import { calendar } from '@/flow/calendar';
import type { RunState } from './schema';

// Mutates singletons to match a loaded RunState. Called on boot if a
// save exists. The reverse direction (snapshot singletons → RunState)
// is in snapshot.ts (used for autosave).
export function applyRunState(state: RunState): void {
  // AP: directly set internal value via spend/refill primitives is awkward;
  // since AP is reset-only or spend-only, we expose a setForRestore method
  // on ApSystem (added in Task 4 alongside effort counters). For P4 Task 1
  // we fake it with a fresh refill + spend the difference.
  ap.resetForNewDay();
  if (state.apCurrent < ap.max) {
    ap.spend(ap.max - state.apCurrent);
  }

  // KPI: similar — needs a setForRestore that bypasses the additive guard.
  // For P4 Task 1, only reset to defaults; Task 4 wires real restore.
  // (This is OK because Task 1 just adds the persistence layer; full
  // restore semantics land alongside the energy + effort modules in
  // Task 4 when we have setForRestore methods on every domain singleton.)
  void kpi;

  // Calendar
  while (calendar.currentDay < state.currentDay) calendar.advanceDay();

  // Played this day
  playedThisDay.clear();
  for (const id of state.playedThisDay) playedThisDay.add(id);
}
