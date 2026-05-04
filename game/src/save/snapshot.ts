import { playedThisDay } from '@/card/play';
import { ap } from '@/economy/ap';
import { energy } from '@/economy/energy';
import { kpi } from '@/economy/kpi';
import { calendar } from '@/flow/calendar';
import { flow } from '@/flow/dispatcher';
import { type RunState, SCHEMA_VERSION } from './schema';

// Snapshots all singleton state into a RunState. Called by autosave hooks
// and by gameover transaction. Inverse of restore.ts.
export function snapshotCurrentRunState(): RunState {
  return {
    schemaVersion: SCHEMA_VERSION,
    apCurrent: ap.current,
    energyCurrent: energy.current,
    energyBurnoutFlag: energy.burnoutFlag,
    kpiActual: kpi.actualKpi,
    monthlyThreshold: kpi.monthlyThreshold,
    monthIndex: kpi.month,
    effortOvertime: ap.effortOvertime, // Task 4 adds real wiring
    effortHero: ap.effortHero,
    effortOverage: ap.effortOverage,
    currentDay: calendar.currentDay,
    currentWeekday: calendar.currentWeekday,
    playedThisDay: [...playedThisDay],
    sceneState: flow.state as RunState['sceneState'],
  };
}
