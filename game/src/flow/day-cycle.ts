import type { CardId } from '@/card/card';
import type { ApSystem } from '@/economy/ap';
import { OVERTIME_BONUS_AP, POTENTIAL_DISMISSAL } from '@/economy/constants';
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
  ap: ApSystem;
  kpi: KpiSystem;
  energy: EnergySystem; // needed by confirmAfterWork to gate overtime on canOvertime()
  calendar: CalendarSystem;
  flow: FlowDispatcher;
  playedThisDay: Set<CardId>;
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
    this.unsubscribers.push(
      this.deps.ap.onChanged((current) => {
        // AP=0 in action_day OR action_overtime both trigger day end (→ after_work).
        if (
          current === 0 &&
          (this.deps.flow.state.kind === 'action_day' ||
            this.deps.flow.state.kind === 'action_overtime')
        ) {
          this.handleDayEnd();
        }
      }),
    );
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
  //   'overtime'  → 加班: spend energy, grant +2 AP, transition to action_overtime.
  //   'end_day'   → 按时下班: route to recap (non-month-end) or kpi_review (month-end).
  async confirmAfterWork(decision: 'overtime' | 'end_day'): Promise<void> {
    const { ap, energy, calendar, flow } = this.deps;
    if (flow.state.kind !== 'after_work') {
      throw new Error(`confirmAfterWork called from non-after_work state: ${flow.state.kind}`);
    }
    if (decision === 'overtime') {
      if (!energy.canOvertime()) {
        throw new Error('Cannot overtime: energy too low or burnout');
      }
      energy.reportOvertime();
      ap.grantOvertime(OVERTIME_BONUS_AP); // +2 AP, capped at 10; see GDD Rule 4 comment in ap.ts
      ap.reportOvertime(); // increment monthly effort counter
      flow.request({ kind: 'action_overtime', day: calendar.currentDay });
    } else {
      // end_day: route to recap or kpi_review depending on month-end.
      if (calendar.isMonthEnd()) {
        flow.request({ kind: 'kpi_review', monthIndex: calendar.monthIndex });
      } else {
        flow.request({
          kind: 'recap',
          recapKind: calendar.isWeeklyRecapDay() ? 'weekly' : 'daily',
          day: calendar.currentDay,
        });
      }
    }
  }

  // Called by the recap UI when the player dismisses the recap screen.
  // Transitions to morning_briefing for the next day (instead of action_day
  // directly) so the full GDD sub-mode chain is preserved.
  confirmRecap(): void {
    const { ap, calendar, flow, playedThisDay } = this.deps;
    if (flow.state.kind !== 'recap') {
      throw new Error(`confirmRecap called from non-recap state: ${flow.state.kind}`);
    }
    calendar.advanceDay();
    ap.resetForNewDay();
    playedThisDay.clear();
    flow.request({ kind: 'morning_briefing', day: calendar.currentDay });
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
    const { ap, kpi, calendar, flow, playedThisDay } = this.deps;
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

    // Step 2: apply Formula B recalc with real effort_norm from ap counters.
    // Counters are reset AFTER game-over checks so that the gameover snapshot
    // path (commitGameOverArchive → snapshotCurrentRunState) captures them.
    const effortNorm = computeEffortNorm(ap.effortOvertime, ap.effortHero, ap.effortOverage);
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

    // Step 4: pass — advance month, reset day-state, go to morning_briefing.
    // Effort counters reset AFTER recalc + game-over checks (per GDD order).
    calendar.advanceMonth();
    kpi.advanceMonth();
    ap.resetForNewDay();
    ap.resetEffortCounters();
    playedThisDay.clear();
    flow.request({ kind: 'morning_briefing', day: calendar.currentDay });
    void autosave();
  }
}

import { playedThisDay as defaultPlayedThisDay } from '@/card/play';
import { ap as defaultAp } from '@/economy/ap';
import { energy as defaultEnergy } from '@/economy/energy';
import { kpi as defaultKpi } from '@/economy/kpi';
import { calendar as defaultCalendar } from './calendar';
import { flow as defaultFlow } from './dispatcher';

// Singleton — production import goes through this.
// Tests construct their own DayCycleController with custom deps.
export const dayCycle = new DayCycleController({
  ap: defaultAp,
  kpi: defaultKpi,
  energy: defaultEnergy,
  calendar: defaultCalendar,
  flow: defaultFlow,
  playedThisDay: defaultPlayedThisDay,
});
