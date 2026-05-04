import { beforeEach, describe, expect, it } from 'vitest';
import { ApSystem } from '../../src/economy/ap';
import { MONTH_DAYS } from '../../src/economy/constants';
import { KpiSystem } from '../../src/economy/kpi';
import { CalendarSystem } from '../../src/flow/calendar';
import { DayCycleController } from '../../src/flow/day-cycle';
import { FlowDispatcher } from '../../src/flow/dispatcher';
import type { SceneState } from '../../src/flow/scene-state';

const day1: SceneState = { kind: 'action_day', day: 1, phase: 'morning' };

describe('DayCycleController', () => {
  let ap: ApSystem;
  let kpi: KpiSystem;
  let calendar: CalendarSystem;
  let flow: FlowDispatcher;
  let controller: DayCycleController;
  let playedThisDay: Set<string>;

  beforeEach(() => {
    ap = new ApSystem();
    kpi = new KpiSystem();
    calendar = new CalendarSystem();
    flow = new FlowDispatcher();
    playedThisDay = new Set(['placeholder_card']);
    controller = new DayCycleController({ ap, kpi, calendar, flow, playedThisDay });
    controller.attach();
    // Boot into action_day for these tests
    flow.request(day1);
  });

  it('AP=0 on non-month-end day → flow.request(daily recap)', () => {
    expect(calendar.isMonthEnd()).toBe(false);
    ap.spend(8);
    expect(flow.state.kind).toBe('recap');
    expect((flow.state as { recapKind: 'daily' | 'weekly' }).recapKind).toBe('daily');
  });

  it('AP=0 on Friday → flow.request(weekly recap)', () => {
    for (let i = 0; i < 4; i++) calendar.advanceDay(); // Fri
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    ap.spend(8);
    expect(flow.state.kind).toBe('recap');
    expect((flow.state as { recapKind: 'daily' | 'weekly' }).recapKind).toBe('weekly');
  });

  it('AP=0 on month-end day → flow.request(kpi_review), skipping recap', () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    expect(calendar.isMonthEnd()).toBe(true);
    ap.spend(8);
    expect(flow.state.kind).toBe('kpi_review');
  });

  it('confirmRecap() advances day, refills AP, clears playedThisDay, returns to action_day', () => {
    ap.spend(8); // → recap
    expect(flow.state.kind).toBe('recap');
    controller.confirmRecap();
    expect(calendar.currentDay).toBe(2);
    expect(ap.current).toBe(8);
    expect(playedThisDay.size).toBe(0);
    expect(flow.state.kind).toBe('action_day');
  });

  it('confirmKpiReview() with KPI well below threshold → advance month + return to action_day', () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(50); // raw potential = (50-100)/100 = -0.5, clamped to -0.15
    ap.spend(8); // → kpi_review
    controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');
    expect(calendar.currentDay).toBe(1);
    expect(calendar.monthIndex).toBe(2);
  });

  it('confirmKpiReview() with KPI exactly at -0.15 boundary → still passes (not severe dismissal)', () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(85); // potential = -0.15 (boundary)
    ap.spend(8);
    controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');
  });

  it('confirmKpiReview() with KPI > capacity (after recalc) → flow.request(gameover, kpi_exceeds_capacity)', () => {
    // monthlyThreshold starts 100, capacity month 1 = 300. To trigger
    // capacity-exceeded we'd need threshold > 300. Formula B max is
    // ×1.18/month. 100 → 118 → 139 → ... → 300 takes ~6 months. That's
    // too long for a single test. We force the scenario by advancing
    // calendar to a month with low capacity AND priming a high threshold.
    for (let i = 0; i < 50; i++) calendar.advanceMonth();
    // Now monthIndex=51; capacity_now floors at 40. Any threshold > 40
    // triggers the game over.
    // monthlyThreshold is still 100 (initial); 100 > 40 → game over.
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    ap.spend(8);
    controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');
    expect((flow.state as { reason: string }).reason).toBe('kpi_exceeds_capacity');
  });

  it('detach() unsubscribes from ap and stops driving the FSM', () => {
    controller.detach();
    ap.spend(8);
    expect(flow.state.kind).toBe('action_day'); // unchanged
  });
});
