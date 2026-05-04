import type { CardId } from '@/card/card';
import type { ApSystem } from '@/economy/ap';
import {
  BASE_CAPACITY,
  CAPACITY_FLOOR,
  DECAY_RATE,
  POTENTIAL_CLAMP_MAX,
  POTENTIAL_CLAMP_MIN,
  POTENTIAL_DISMISSAL,
} from '@/economy/constants';
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

    // Compute potential and clamp to the Formula B range before any check.
    // Clamping mirrors what applyMonthlyRecalc does internally, so both
    // the dismissal gate and the recalc use the same effective value.
    const rawPotential = (kpi.actualKpi - kpi.monthlyThreshold) / kpi.monthlyThreshold;
    const clampedPotential = Math.max(
      POTENTIAL_CLAMP_MIN,
      Math.min(POTENTIAL_CLAMP_MAX, rawPotential),
    );

    // Step 1: severe dismissal check (clamped potential).
    // POTENTIAL_DISMISSAL === POTENTIAL_CLAMP_MIN (-0.15), so the boundary
    // case (clamped = -0.15) is NOT dismissed (strict less-than).
    if (clampedPotential < POTENTIAL_DISMISSAL) {
      flow.request({
        kind: 'gameover',
        reason: 'dismissal_severe',
        monthIndex: calendar.monthIndex,
      });
      return;
    }

    // Step 2: apply Formula B recalc (effort_norm = 0 in P3).
    kpi.applyMonthlyRecalc(0);

    // Step 3: capacity-exceeded check (post-recalc).
    // Capacity is computed from calendar.monthIndex so it stays in sync
    // even when the calendar was advanced independently (e.g. forced test
    // scenarios that skip many months without going through confirmKpiReview).
    const capacityNow =
      Math.max(CAPACITY_FLOOR, BASE_CAPACITY - DECAY_RATE * (calendar.monthIndex - 1)) * 100;
    if (kpi.monthlyThreshold > capacityNow) {
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
