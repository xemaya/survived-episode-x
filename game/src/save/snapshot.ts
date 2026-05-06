import { effort } from '@/economy/effort';
import { energy } from '@/economy/energy';
import { kpi } from '@/economy/kpi';
import { calendar } from '@/flow/calendar';
import { flow } from '@/flow/dispatcher';
import { ink } from '@/ink/runtime';
import { dialogState } from '@/render/dialog/dialog-state';
import { type RunState, SCHEMA_VERSION } from './schema';

// Snapshots all singleton state into a RunState. Called by autosave hooks
// and by gameover transaction. Inverse of restore.ts.
export function snapshotCurrentRunState(): RunState {
  const base: RunState = {
    schemaVersion: SCHEMA_VERSION,
    energyCurrent: energy.current,
    energyBurnoutFlag: energy.burnoutFlag,
    kpiActual: kpi.actualKpi,
    monthlyThreshold: kpi.monthlyThreshold,
    monthIndex: kpi.month,
    effortOvertime: effort.effortOvertime,
    effortHero: effort.effortHero,
    effortOverage: effort.effortOverage,
    currentDay: calendar.currentDay,
    currentWeekday: calendar.currentWeekday,
    playedThisDay: [], // P5: cards removed; field preserved for save schema back-compat
    sceneState: flow.state as RunState['sceneState'],
  };
  // P5 T16: capture ink runtime position when a story is loaded.
  // Pre-T16 saves simply omit the field and resume re-runs `intro`.
  if (ink.isLoaded) {
    try {
      base.inkStateJson = ink.serializeState();
    } catch (e) {
      console.warn('[snapshot] ink.serializeState failed:', (e as Error).message);
    }
  }
  // QA Bug #11 (T16 follow-up): persist last visible narration so the
  // panel doesn't render `...` on reload when ink has nothing left to
  // drain. Empty string is the no-op fallback (`?? ''` in restore).
  const lastNarration = dialogState.lastNarrationText;
  if (lastNarration.length > 0) {
    base.lastNarrationText = lastNarration;
  }
  return base;
}
