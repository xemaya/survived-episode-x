import { POTENTIAL_DISMISSAL } from '@/economy/constants';
import type { EffortSystem } from '@/economy/effort';
import type { EnergySystem } from '@/economy/energy';
import { type KpiSystem, computeEffortNorm } from '@/economy/kpi';
import { appendToArchive, buildRunSummary } from '@/run-meta/archive';
import { autosave } from '@/save/autosave';
import { snapshotCurrentRunState } from '@/save/snapshot';
import { save as defaultSave } from '@/save/system';
import type { SaveSystem } from '@/save/system';
import type { CalendarSystem } from './calendar';
import type { FlowDispatcher } from './dispatcher';
import type { GameOverReason } from './scene-state';

export interface DayCycleDeps {
  effort: EffortSystem;
  kpi: KpiSystem;
  energy: EnergySystem; // needed by confirmAfterWork to gate overtime on canOvertime()
  calendar: CalendarSystem;
  flow: FlowDispatcher;
  // Optional: allows tests to inject a mock save. Defaults to production singleton.
  save?: SaveSystem;
}

// Orchestrates day/month transitions. Subscribes to ap (depletion = day end)
// and exposes confirmMorningBriefing() / confirmAfterWork() / confirmRecap() /
// confirmKpiReview() for UI to call as the player advances through each screen.
//
// Full day chain (GDD scene-day-flow-controller.md Section A):
//   morning_briefing → action_day → after_work →
//     action_overtime → after_work (loop)
//     recap (non-month-end) → morning_briefing (next day)
//     kpi_review (month-end) → morning_briefing (next month) | gameover
//
// Per spec §6.5 (domain emitters): this controller is the single owner of
// the "day ends now" decision. The workstation scene used to do this in
// P2 (click-to-advance hack); P3 moves the logic here so the FSM is in
// charge, not the renderer.
export class DayCycleController {
  private deps: DayCycleDeps;
  private unsubscribers: Array<() => void> = [];
  private attached = false;

  constructor(deps: DayCycleDeps) {
    this.deps = deps;
  }

  attach(): void {
    if (this.attached) return;
    this.attached = true;
    // Bug #27 (2026-05-06): AP system deleted. The old AP=0 listener
    // was the only auto-trigger for `→ after_work`; now the after_work
    // transition fires only via `endDayEarly()` (legacy 下班 button)
    // or programmatically from ink narrative tags (future). The
    // controller still exposes the public surface; just no auto-listen.
  }

  detach(): void {
    for (const u of this.unsubscribers) u();
    this.unsubscribers = [];
    this.attached = false;
  }

  // Public early-leave path (GDD: day ends when AP=0 OR player chooses to
  // leave early). Workstation 「下班」 button calls this. No-op if not in
  // action_day or action_overtime (e.g. user double-clicked during transition).
  endDayEarly(): void {
    if (
      this.deps.flow.state.kind === 'action_day' ||
      this.deps.flow.state.kind === 'action_overtime'
    ) {
      this.handleDayEnd();
    }
  }

  // Routes to after_work regardless of month-end or weekly-recap day.
  // The player makes the 加班 vs 按时下班 decision in after_work.
  private handleDayEnd(): void {
    const { calendar, flow } = this.deps;
    flow.request({ kind: 'after_work', day: calendar.currentDay });
  }

  // Called by morning_briefing UI when the player acknowledges the briefing.
  // Transitions to action_day (morning phase) for the current day.
  async confirmMorningBriefing(): Promise<void> {
    const { calendar, flow } = this.deps;
    if (flow.state.kind !== 'morning_briefing') {
      throw new Error(
        `confirmMorningBriefing called from non-morning_briefing state: ${flow.state.kind}`,
      );
    }
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
  }

  // Called by the after_work overlay. The player decides:
  //   'overtime'  → 加班: drain energy + bump effort counter, → action_overtime.
  //   'end_day'   → 按时下班: route to recap (non-month-end) or kpi_review (month-end).
  // Bug #27: AP grant removed (AP system deleted). Effort counter still
  // bumps via the `effort` module so KPI Review's α factor still sees it.
  async confirmAfterWork(decision: 'overtime' | 'end_day'): Promise<void> {
    const { effort, energy, calendar, flow } = this.deps;
    if (flow.state.kind !== 'after_work') {
      throw new Error(`confirmAfterWork called from non-after_work state: ${flow.state.kind}`);
    }
    if (decision === 'overtime') {
      if (!energy.canOvertime()) {
        throw new Error('Cannot overtime: energy too low or burnout');
      }
      energy.reportOvertime();
      effort.reportOvertime();
      flow.request({ kind: 'action_overtime', day: calendar.currentDay });
    } else {
      // end_day: route to recap or kpi_review depending on month-end.
      // Q-S: on Friday non-month-end, intercept with the week_end
      // weekly_meter (resumeTo = the recap that would have fired).
      if (calendar.isMonthEnd()) {
        flow.request({ kind: 'kpi_review', monthIndex: calendar.monthIndex });
      } else {
        const recapTarget = {
          kind: 'recap' as const,
          recapKind: calendar.isWeeklyRecapDay() ? ('weekly' as const) : ('daily' as const),
          day: calendar.currentDay,
        };
        if (calendar.currentWeekday === 5) {
          flow.request({
            kind: 'weekly_meter',
            phase: 'week_end',
            resumeTo: recapTarget,
          });
        } else {
          flow.request(recapTarget);
        }
      }
    }
  }

  // Q-S: dismiss the weekly meter modal — transit to the resumeTo
  // target captured when the meter was triggered (next action_day for
  // week_start, the deferred recap for week_end).
  confirmWeeklyMeter(): void {
    const { flow } = this.deps;
    if (flow.state.kind !== 'weekly_meter') {
      throw new Error(`confirmWeeklyMeter called from non-weekly_meter state: ${flow.state.kind}`);
    }
    flow.request(flow.state.resumeTo);
  }

  // Called by the recap UI when the player dismisses the recap screen.
  // QA Bug #23 fix (2026-05-06): transit DIRECTLY to action_day —
  // morning_briefing's Preact card was a P0-P4 holdover; AVG-driven
  // P5 has the day intro inline in ink narrative ("闹钟响了 3 次..."),
  // so the card was a redundant interruption. The morning_briefing
  // FSM state remains in `scene-state.ts` for back-compat with old
  // saves but is no longer reachable from the day-cycle flow.
  confirmRecap(): void {
    const { energy, calendar, flow } = this.deps;
    if (flow.state.kind !== 'recap') {
      throw new Error(`confirmRecap called from non-recap state: ${flow.state.kind}`);
    }
    calendar.advanceDay();
    // GDD weekend regen: entering a weekend day (Sat=6 or Sun=7) restores
    // +30 energy. advanceDay() has already updated currentWeekday.
    if (calendar.currentWeekday >= 6) {
      energy.regenForRestDay();
    }
    // Bug #27: ap.resetForNewDay() removed (AP system deleted).
    // P5: card hand removed; no per-day card-played reset needed.
    // Q-S: if the new day is a Monday (weekday=1), insert the
    // week_start meter ahead of action_day. resumeTo captures the
    // action_day target so confirmWeeklyMeter advances cleanly.
    const actionDayTarget = {
      kind: 'action_day' as const,
      day: calendar.currentDay,
      phase: 'morning' as const,
    };
    if (calendar.currentWeekday === 1) {
      flow.request({
        kind: 'weekly_meter',
        phase: 'week_start',
        resumeTo: actionDayTarget,
      });
    } else {
      flow.request(actionDayTarget);
    }
    void autosave();
  }

  // Writes the run archive atomically at GameOver time.
  // Called BEFORE flow.request(gameover) so that by the time GameOver
  // renders, the save side is already committed.
  private async commitGameOverArchive(reason: GameOverReason): Promise<void> {
    const saveSystem = this.deps.save ?? defaultSave;
    const meta = await saveSystem.loadMeta();
    const runId = meta.nextRunId;
    const snapshot = snapshotCurrentRunState();
    const summary = buildRunSummary(runId, reason, snapshot);
    await saveSystem.writeArchiveSnapshot(runId, snapshot);
    await saveSystem.writeMeta(appendToArchive(meta, summary));
    await saveSystem.clearCurrentRun();
  }

  // Called by the kpi_review UI when the player confirms. Runs the monthly
  // recalc, evaluates game-over conditions, then either advances to the
  // next month (→ morning_briefing) or transitions to gameover.
  // async because gameover path writes archive before transitioning.
  async confirmKpiReview(): Promise<void> {
    const { effort, kpi, calendar, flow } = this.deps;
    if (flow.state.kind !== 'kpi_review') {
      throw new Error(`confirmKpiReview called from non-kpi_review state: ${flow.state.kind}`);
    }

    // Step 1: severe dismissal check uses RAW (unclamped) potential per
    // design/gdd/kpi-reverse-threshold-system.md. POTENTIAL_DISMISSAL
    // (-0.15) is the same as POTENTIAL_CLAMP_MIN, so dismissal triggers
    // when actualKpi falls below ~85% of monthlyThreshold — a hard
    // "fired for severe underperformance" gate. Using clamped here would
    // make this gate unreachable.
    const rawPotential = (kpi.actualKpi - kpi.monthlyThreshold) / kpi.monthlyThreshold;
    if (rawPotential < POTENTIAL_DISMISSAL) {
      await this.commitGameOverArchive('dismissal_severe');
      flow.request({
        kind: 'gameover',
        reason: 'dismissal_severe',
        monthIndex: calendar.monthIndex,
      });
      return;
    }

    // Step 2: apply Formula B recalc with real effort_norm from effort counters.
    // Counters are reset AFTER game-over checks so that the gameover snapshot
    // path (commitGameOverArchive → snapshotCurrentRunState) captures them.
    const effortNorm = computeEffortNorm(
      effort.effortOvertime,
      effort.effortHero,
      effort.effortOverage,
    );
    kpi.applyMonthlyRecalc(effortNorm);

    // Step 3: capacity-exceeded check (post-recalc). Use kpi.capacityNow
    // — the KpiSystem owns its own month counter and computes capacity
    // from it. Callers (production: this controller; tests: explicit
    // setup) must keep kpi.month in sync with calendar.monthIndex via
    // the kpi.advanceMonth() call in Step 4.
    if (kpi.monthlyThreshold > kpi.capacityNow) {
      await this.commitGameOverArchive('kpi_exceeds_capacity');
      flow.request({
        kind: 'gameover',
        reason: 'kpi_exceeds_capacity',
        monthIndex: calendar.monthIndex,
      });
      return;
    }

    // Step 4: pass — advance month, reset day-state, go to action_day.
    // QA Bug #23 fix: morning_briefing card removed; transit straight
    // to action_day for the next month's day 1. Bug #27 fix:
    // ap.resetForNewDay() removed (AP system deleted); only the
    // effort counters reset here.
    // Effort counters reset AFTER recalc + game-over checks (per GDD order).
    calendar.advanceMonth();
    kpi.advanceMonth();
    effort.resetEffortCounters();
    // P5: card hand removed; no per-day card-played reset needed.
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    void autosave();
  }
}

import { effort as defaultEffort } from '@/economy/effort';
import { energy as defaultEnergy } from '@/economy/energy';
import { kpi as defaultKpi } from '@/economy/kpi';
import { calendar as defaultCalendar } from './calendar';
import { flow as defaultFlow } from './dispatcher';

// Singleton — production import goes through this.
// Tests construct their own DayCycleController with custom deps.
export const dayCycle = new DayCycleController({
  effort: defaultEffort,
  kpi: defaultKpi,
  energy: defaultEnergy,
  calendar: defaultCalendar,
  flow: defaultFlow,
});
