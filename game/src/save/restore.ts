import { effort } from '@/economy/effort';
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
  // Bug #27: AP system deleted — `apCurrent` is no longer in the
  // schema, no AP restore needed.

  // Effort counters: restore from saved state.
  effort.setEffortForRestore(state.effortOvertime, state.effortHero, state.effortOverage);

  // KPI: similar — needs a setForRestore that bypasses the additive guard.
  // For P4 Task 1, only reset to defaults; Task 4 wires real restore.
  void kpi;

  // Calendar
  while (calendar.currentDay < state.currentDay) calendar.advanceDay();

  // P5: Card hand removed; playedThisDay field is no-op (kept in schema for back-compat).
  void state.playedThisDay;
}
