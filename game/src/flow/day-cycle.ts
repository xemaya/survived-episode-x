import type { CardId } from '@/card/card';
import type { ApSystem } from '@/economy/ap';
import { POTENTIAL_DISMISSAL } from '@/economy/constants';
import type { KpiSystem } from '@/economy/kpi';
import type { CalendarSystem } from './calendar';
import type { FlowDispatcher } from './dispatcher';

export interface DayCycleDeps {
  ap: ApSystem;
  kpi: KpiSystem;
  calendar: CalendarSystem;
  flow: FlowDispatcher;
  playedThisDay: Set<CardId>;
}

// Orchestrates day/month transitions. Subscribes to ap (depletion = day end)
// and exposes confirmRecap()/confirmKpiReview() for UI to call when player
// dismisses those screens.
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
        if (current === 0 && this.deps.flow.state.kind === 'action_day') {
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

  private handleDayEnd(): void {
    const { calendar, flow } = this.deps;
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

  // Called by the recap UI when the player dismisses the recap screen.
  confirmRecap(): void {
    const { ap, calendar, flow, playedThisDay } = this.deps;
    if (flow.state.kind !== 'recap') {
      throw new Error(`confirmRecap called from non-recap state: ${flow.state.kind}`);
    }
    calendar.advanceDay();
    ap.resetForNewDay();
    playedThisDay.clear();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
  }

  // Called by the kpi_review UI when the player confirms. Runs the monthly
  // recalc, evaluates game-over conditions, then either advances to the
  // next month or transitions to gameover.
  confirmKpiReview(): void {
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
      flow.request({
        kind: 'gameover',
        reason: 'dismissal_severe',
        monthIndex: calendar.monthIndex,
      });
      return;
    }

    // Step 2: apply Formula B recalc (effort_norm = 0 in P3). The recalc
    // internally clamps potential to [POTENTIAL_CLAMP_MIN, POTENTIAL_CLAMP_MAX].
    kpi.applyMonthlyRecalc(0);

    // Step 3: capacity-exceeded check (post-recalc). Use kpi.capacityNow
    // — the KpiSystem owns its own month counter and computes capacity
    // from it. Callers (production: this controller; tests: explicit
    // setup) must keep kpi.month in sync with calendar.monthIndex via
    // the kpi.advanceMonth() call in Step 4.
    if (kpi.monthlyThreshold > kpi.capacityNow) {
      flow.request({
        kind: 'gameover',
        reason: 'kpi_exceeds_capacity',
        monthIndex: calendar.monthIndex,
      });
      return;
    }

    // Step 4: pass — advance month, reset day-state, return to action_day.
    calendar.advanceMonth();
    kpi.advanceMonth();
    ap.resetForNewDay();
    playedThisDay.clear();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
  }
}

import { playedThisDay as defaultPlayedThisDay } from '@/card/play';
import { ap as defaultAp } from '@/economy/ap';
import { kpi as defaultKpi } from '@/economy/kpi';
import { calendar as defaultCalendar } from './calendar';
import { flow as defaultFlow } from './dispatcher';

// Singleton — production import goes through this.
// Tests construct their own DayCycleController with custom deps.
export const dayCycle = new DayCycleController({
  ap: defaultAp,
  kpi: defaultKpi,
  calendar: defaultCalendar,
  flow: defaultFlow,
  playedThisDay: defaultPlayedThisDay,
});
