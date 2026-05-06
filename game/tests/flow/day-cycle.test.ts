import { beforeEach, describe, expect, it } from 'vitest';
import { ApSystem } from '../../src/economy/ap';
import { MONTH_DAYS, OVERTIME_BONUS_AP } from '../../src/economy/constants';
import { EnergySystem } from '../../src/economy/energy';
import { KpiSystem } from '../../src/economy/kpi';
import { CalendarSystem } from '../../src/flow/calendar';
import { DayCycleController } from '../../src/flow/day-cycle';
import { FlowDispatcher } from '../../src/flow/dispatcher';
import type { SceneState } from '../../src/flow/scene-state';
import { SaveSystem } from '../../src/save/system';
import type { SaveFs } from '../../src/save/tauri-fs';

const day1: SceneState = { kind: 'action_day', day: 1, phase: 'morning' };

// In-memory mock fs — same pattern as system.test.ts
class MemoryFs implements SaveFs {
  files = new Map<string, string>();
  dirs = new Set<string>(['']);
  async exists(path: string): Promise<boolean> {
    return this.files.has(path) || this.dirs.has(path);
  }
  async read(path: string): Promise<string> {
    const v = this.files.get(path);
    if (v === undefined) throw new Error(`ENOENT: ${path}`);
    return v;
  }
  async writeAtomic(path: string, content: string): Promise<void> {
    this.files.set(path, content);
  }
  async delete(path: string): Promise<void> {
    this.files.delete(path);
  }
  async ensureDir(path: string): Promise<void> {
    this.dirs.add(path);
  }
}

describe('DayCycleController', () => {
  let ap: ApSystem;
  let kpi: KpiSystem;
  let energy: EnergySystem;
  let calendar: CalendarSystem;
  let flow: FlowDispatcher;
  let controller: DayCycleController;
  let mockSave: SaveSystem;

  beforeEach(() => {
    ap = new ApSystem();
    kpi = new KpiSystem();
    energy = new EnergySystem();
    calendar = new CalendarSystem();
    flow = new FlowDispatcher();
    mockSave = new SaveSystem(new MemoryFs());
    controller = new DayCycleController({
      ap,
      kpi,
      energy,
      calendar,
      flow,
      save: mockSave,
    });
    controller.attach();
    // Boot into action_day for most tests. Bug #23 (2026-05-06):
    // morning_briefing card removed; main_menu → action_day is now
    // a legal direct transit.
    flow.request(day1);
  });

  // ─── AP=0 → after_work (new intermediate step) ────────────────────────────

  it('AP=0 on non-month-end day → after_work (player decides next)', () => {
    expect(calendar.isMonthEnd()).toBe(false);
    ap.spend(8);
    expect(flow.state.kind).toBe('after_work');
  });

  it('AP=0 on non-month-end day → after_work → confirmAfterWork(end_day) → daily recap', async () => {
    expect(calendar.isMonthEnd()).toBe(false);
    ap.spend(8);
    expect(flow.state.kind).toBe('after_work');
    await controller.confirmAfterWork('end_day');
    expect(flow.state.kind).toBe('recap');
    expect((flow.state as { recapKind: 'daily' | 'weekly' }).recapKind).toBe('daily');
  });

  it('AP=0 on Friday → after_work → confirmAfterWork(end_day) → weekly recap', async () => {
    for (let i = 0; i < 4; i++) calendar.advanceDay(); // Fri
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    ap.spend(8);
    expect(flow.state.kind).toBe('after_work');
    await controller.confirmAfterWork('end_day');
    expect(flow.state.kind).toBe('recap');
    expect((flow.state as { recapKind: 'daily' | 'weekly' }).recapKind).toBe('weekly');
  });

  it('AP=0 on month-end day → after_work → confirmAfterWork(end_day) → kpi_review', async () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    expect(calendar.isMonthEnd()).toBe(true);
    ap.spend(8);
    expect(flow.state.kind).toBe('after_work');
    await controller.confirmAfterWork('end_day');
    expect(flow.state.kind).toBe('kpi_review');
  });

  // ─── Overtime branch ───────────────────────────────────────────────────────

  it('after_work → confirmAfterWork(overtime) → action_overtime + AP=10 + energy drained', async () => {
    ap.spend(8); // → after_work
    expect(flow.state.kind).toBe('after_work');
    const energyBefore = energy.current;
    await controller.confirmAfterWork('overtime');
    expect(flow.state.kind).toBe('action_overtime');
    expect(ap.current).toBe(OVERTIME_BONUS_AP); // granted exactly +2
    expect(energy.current).toBe(energyBefore - 15); // ENERGY_OT_BASE
    expect(ap.effortOvertime).toBe(1); // counter incremented
  });

  it('after_work → confirmAfterWork(overtime) with energy too low → throws', async () => {
    // Drain energy below the overtime guard (15)
    energy.change(-70); // 80 - 70 = 10 < ENERGY_OVERTIME_GUARD (15)
    expect(energy.canOvertime()).toBe(false);
    ap.spend(8); // → after_work
    await expect(controller.confirmAfterWork('overtime')).rejects.toThrow(
      'Cannot overtime: energy too low or burnout',
    );
    expect(flow.state.kind).toBe('after_work'); // state unchanged
  });

  it('action_overtime AP=0 → after_work again (loop-back)', async () => {
    ap.spend(8); // → after_work
    await controller.confirmAfterWork('overtime'); // → action_overtime (+2 AP)
    expect(flow.state.kind).toBe('action_overtime');
    // Spend the 2 overtime AP
    ap.spend(2);
    expect(flow.state.kind).toBe('after_work'); // looped back
  });

  it('confirmAfterWork throws if not in after_work state', async () => {
    // We're in action_day, not after_work
    await expect(controller.confirmAfterWork('end_day')).rejects.toThrow(
      'confirmAfterWork called from non-after_work state: action_day',
    );
  });

  // ─── Morning briefing ──────────────────────────────────────────────────────

  it('confirmMorningBriefing → action_day (morning phase)', async () => {
    // Use a fresh flow so we can go main_menu → morning_briefing legally.
    const freshFlow = new FlowDispatcher();
    const freshController = new DayCycleController({
      ap,
      kpi,
      energy,
      calendar,
      flow: freshFlow,
      save: mockSave,
    });
    freshFlow.request({ kind: 'morning_briefing', day: 1 }); // main_menu → morning_briefing
    await freshController.confirmMorningBriefing();
    expect(freshFlow.state.kind).toBe('action_day');
    expect((freshFlow.state as { phase: string }).phase).toBe('morning');
  });

  it('confirmMorningBriefing throws if not in morning_briefing state', async () => {
    // We're in action_day
    await expect(controller.confirmMorningBriefing()).rejects.toThrow(
      'confirmMorningBriefing called from non-morning_briefing state: action_day',
    );
  });

  // ─── confirmRecap → action_day (Bug #23: morning_briefing card removed) ──

  it('confirmRecap() advances day, refills AP, → action_day', async () => {
    ap.spend(8); // → after_work
    await controller.confirmAfterWork('end_day'); // → recap
    expect(flow.state.kind).toBe('recap');
    controller.confirmRecap();
    expect(calendar.currentDay).toBe(2);
    expect(ap.current).toBe(8);
    expect(flow.state.kind).toBe('action_day');
  });

  // ─── confirmKpiReview → action_day (pass) / gameover (fail) ──────────────

  it('confirmKpiReview() with KPI severely below threshold → gameover (dismissal_severe)', async () => {
    // raw potential = (50-100)/100 = -0.5 < POTENTIAL_DISMISSAL (-0.15)
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(50);
    ap.spend(8); // → after_work
    await controller.confirmAfterWork('end_day'); // → kpi_review
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');
    expect((flow.state as { reason: string }).reason).toBe('dismissal_severe');
  });

  it('confirmKpiReview() with KPI exactly at -0.15 boundary → passes → action_day', async () => {
    // raw potential = (85-100)/100 = -0.15 exactly; NOT < -0.15 so no dismissal.
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(85);
    ap.spend(8);
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');
  });

  it('confirmKpiReview() with KPI exactly at threshold → passes → action_day + month advance', async () => {
    // potential = 0; threshold unchanged after recalc; capacity 300 > 100 → pass.
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(100);
    ap.spend(8);
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');
    expect(calendar.currentDay).toBe(1);
    expect(calendar.monthIndex).toBe(2);
  });

  it('confirmKpiReview() with threshold > capacity (after recalc) → gameover (kpi_exceeds_capacity)', async () => {
    // Force scenario: advance both calendar AND kpi to month 51 so capacity
    // floors at 40. Initial threshold 100 > 40 → capacity exceeded after recalc.
    for (let i = 0; i < 50; i++) {
      calendar.advanceMonth();
      kpi.advanceMonth();
    }
    // Both now at month 51. capacityNow = max(40, (3.0 - 0.05*50)*100) = 40.
    // KPI contribution must keep raw potential ≥ -0.15 to skip the dismissal gate.
    kpi.applyContribution(85);
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    ap.spend(8);
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');
    expect((flow.state as { reason: string }).reason).toBe('kpi_exceeds_capacity');
  });

  it('detach() unsubscribes from ap and stops driving the FSM', () => {
    controller.detach();
    ap.spend(8);
    expect(flow.state.kind).toBe('action_day'); // unchanged
  });

  it('confirmKpiReview() gameover writes archive entry to meta', async () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(50); // below threshold → dismissal_severe
    ap.spend(8);
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');
    const meta = await mockSave.loadMeta();
    expect(meta.archive.length).toBe(1);
    expect(meta.archive[0]?.reason).toBe('dismissal_severe');
    expect(meta.nextRunId).toBe(2);
  });

  it('confirmKpiReview pass branch resets effort counters', async () => {
    // Build up some effort counters before month-end.
    ap.reportOvertime();
    ap.reportHeroCardPlayed();
    ap.reportOverage();
    expect(ap.effortOvertime).toBe(1);
    expect(ap.effortHero).toBe(1);
    expect(ap.effortOverage).toBe(1);

    // Advance to month-end and pass the review.
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(100); // at threshold → pass
    ap.spend(8);
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');

    // All effort counters must be zeroed in the pass branch.
    expect(ap.effortOvertime).toBe(0);
    expect(ap.effortHero).toBe(0);
    expect(ap.effortOverage).toBe(0);
  });

  it('confirmKpiReview gameover branch does NOT reset effort counters', async () => {
    // Effort counters should be preserved so the archive snapshot captures them.
    ap.reportOvertime();
    ap.reportHeroCardPlayed();

    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(50); // below threshold → dismissal_severe
    ap.spend(8);
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');

    // Counters are NOT reset in the gameover path — they were captured in the snapshot.
    expect(ap.effortOvertime).toBe(1);
    expect(ap.effortHero).toBe(1);
  });

  // (P5: 'isHero card play' test removed — card module deleted; effortHero
  //  tracking now happens via ap.reportHeroCardPlayed() called by future
  //  ink runtime when a #hero-tagged choice is selected.)

  it('endDayEarly() works from action_overtime state too', async () => {
    ap.spend(8); // → after_work
    await controller.confirmAfterWork('overtime'); // → action_overtime
    expect(flow.state.kind).toBe('action_overtime');
    controller.endDayEarly(); // manual leave from overtime
    expect(flow.state.kind).toBe('after_work');
  });
});
