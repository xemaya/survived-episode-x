import { beforeEach, describe, expect, it } from 'vitest';
import { MONTH_DAYS } from '../../src/economy/constants';
import { EffortSystem } from '../../src/economy/effort';
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

describe('DayCycleController (Bug #27 — AP system removed)', () => {
  let effort: EffortSystem;
  let kpi: KpiSystem;
  let energy: EnergySystem;
  let calendar: CalendarSystem;
  let flow: FlowDispatcher;
  let controller: DayCycleController;
  let mockSave: SaveSystem;

  beforeEach(() => {
    effort = new EffortSystem();
    kpi = new KpiSystem();
    energy = new EnergySystem();
    calendar = new CalendarSystem();
    flow = new FlowDispatcher();
    mockSave = new SaveSystem(new MemoryFs());
    controller = new DayCycleController({
      effort,
      kpi,
      energy,
      calendar,
      flow,
      save: mockSave,
    });
    controller.attach();
    // Boot into action_day. Bug #23: morning_briefing card removed;
    // main_menu → action_day is now a legal direct transit.
    flow.request(day1);
  });

  // ─── endDayEarly → after_work (replaces AP=0 trigger from Bug #27) ────

  it('endDayEarly on non-month-end day → after_work → confirmAfterWork(end_day) → daily recap', async () => {
    expect(calendar.isMonthEnd()).toBe(false);
    controller.endDayEarly();
    expect(flow.state.kind).toBe('after_work');
    await controller.confirmAfterWork('end_day');
    expect(flow.state.kind).toBe('recap');
    expect((flow.state as { recapKind: 'daily' | 'weekly' }).recapKind).toBe('daily');
  });

  it('endDayEarly on Friday → after_work → confirmAfterWork(end_day) → weekly_meter (week_end) → weekly recap', async () => {
    for (let i = 0; i < 4; i++) calendar.advanceDay(); // Fri
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    controller.endDayEarly();
    expect(flow.state.kind).toBe('after_work');
    await controller.confirmAfterWork('end_day');
    // Q-S: Friday non-month-end intercepts with weekly_meter before recap.
    expect(flow.state.kind).toBe('weekly_meter');
    expect((flow.state as { phase: string }).phase).toBe('week_end');
    controller.confirmWeeklyMeter();
    expect(flow.state.kind).toBe('recap');
    expect((flow.state as { recapKind: 'daily' | 'weekly' }).recapKind).toBe('weekly');
  });

  it('endDayEarly on month-end day → after_work → confirmAfterWork(end_day) → kpi_review', async () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    expect(calendar.isMonthEnd()).toBe(true);
    controller.endDayEarly();
    expect(flow.state.kind).toBe('after_work');
    await controller.confirmAfterWork('end_day');
    expect(flow.state.kind).toBe('kpi_review');
  });

  // ─── Overtime branch ──────────────────────────────────────────────────────

  it('after_work → confirmAfterWork(overtime) → action_overtime + energy drained + effort counter +1', async () => {
    controller.endDayEarly();
    expect(flow.state.kind).toBe('after_work');
    const energyBefore = energy.current;
    await controller.confirmAfterWork('overtime');
    expect(flow.state.kind).toBe('action_overtime');
    expect(energy.current).toBe(energyBefore - 15); // ENERGY_OT_BASE
    expect(effort.effortOvertime).toBe(1);
  });

  it('after_work → confirmAfterWork(overtime) with energy too low → throws', async () => {
    energy.change(-70); // 80 - 70 = 10 < ENERGY_OVERTIME_GUARD (15)
    expect(energy.canOvertime()).toBe(false);
    controller.endDayEarly();
    await expect(controller.confirmAfterWork('overtime')).rejects.toThrow(
      'Cannot overtime: energy too low or burnout',
    );
    expect(flow.state.kind).toBe('after_work'); // state unchanged
  });

  it('confirmAfterWork throws if not in after_work state', async () => {
    await expect(controller.confirmAfterWork('end_day')).rejects.toThrow(
      'confirmAfterWork called from non-after_work state: action_day',
    );
  });

  // ─── confirmRecap → action_day (Bug #23: morning_briefing card removed) ──

  it('confirmRecap() advances day → action_day', async () => {
    controller.endDayEarly();
    await controller.confirmAfterWork('end_day'); // → recap
    expect(flow.state.kind).toBe('recap');
    controller.confirmRecap();
    expect(calendar.currentDay).toBe(2);
    expect(flow.state.kind).toBe('action_day');
  });

  it('Q-S: confirmRecap on Sunday→Monday inserts weekly_meter (week_start) before action_day', async () => {
    // Advance to day 7 (Sunday), then end day + recap → confirmRecap
    // brings us to day 8 (Monday) and should trigger week_start.
    for (let i = 0; i < 6; i++) calendar.advanceDay();
    expect(calendar.currentDay).toBe(7);
    expect(calendar.currentWeekday).toBe(7); // Sunday
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    controller.endDayEarly();
    await controller.confirmAfterWork('end_day');
    expect(flow.state.kind).toBe('recap');
    controller.confirmRecap();
    expect(calendar.currentDay).toBe(8);
    expect(calendar.currentWeekday).toBe(1); // Monday
    expect(flow.state.kind).toBe('weekly_meter');
    expect((flow.state as { phase: string }).phase).toBe('week_start');
    controller.confirmWeeklyMeter();
    expect(flow.state.kind).toBe('action_day');
    expect((flow.state as { day: number }).day).toBe(8);
  });

  it('Q-S: confirmWeeklyMeter throws from non-weekly_meter state', () => {
    expect(() => controller.confirmWeeklyMeter()).toThrow(
      'confirmWeeklyMeter called from non-weekly_meter state: action_day',
    );
  });

  // ─── confirmKpiReview → action_day (pass) / gameover (fail) ──────────────

  it('confirmKpiReview() with KPI severely below threshold → gameover (dismissal_severe)', async () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(50);
    controller.endDayEarly();
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');
    expect((flow.state as { reason: string }).reason).toBe('dismissal_severe');
  });

  it('confirmKpiReview() with KPI exactly at -0.15 boundary → passes → action_day', async () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(85);
    controller.endDayEarly();
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');
  });

  it('confirmKpiReview() with KPI exactly at threshold → passes → action_day + month advance', async () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(100);
    controller.endDayEarly();
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');
    expect(calendar.currentDay).toBe(1);
    expect(calendar.monthIndex).toBe(2);
  });

  it('confirmKpiReview() with threshold > capacity → gameover (kpi_exceeds_capacity)', async () => {
    for (let i = 0; i < 50; i++) {
      calendar.advanceMonth();
      kpi.advanceMonth();
    }
    kpi.applyContribution(85);
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    controller.endDayEarly();
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');
    expect((flow.state as { reason: string }).reason).toBe('kpi_exceeds_capacity');
  });

  it('confirmKpiReview() gameover writes archive entry to meta', async () => {
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(50);
    controller.endDayEarly();
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');
    const meta = await mockSave.loadMeta();
    expect(meta.archive.length).toBe(1);
    expect(meta.archive[0]?.reason).toBe('dismissal_severe');
    expect(meta.nextRunId).toBe(2);
  });

  it('confirmKpiReview pass branch resets effort counters', async () => {
    effort.reportOvertime();
    effort.reportHeroCardPlayed();
    effort.reportOverage();
    expect(effort.effortOvertime).toBe(1);
    expect(effort.effortHero).toBe(1);
    expect(effort.effortOverage).toBe(1);

    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(100); // at threshold → pass
    controller.endDayEarly();
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');

    expect(effort.effortOvertime).toBe(0);
    expect(effort.effortHero).toBe(0);
    expect(effort.effortOverage).toBe(0);
  });

  it('confirmKpiReview gameover branch does NOT reset effort counters', async () => {
    effort.reportOvertime();
    effort.reportHeroCardPlayed();

    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(50);
    controller.endDayEarly();
    await controller.confirmAfterWork('end_day');
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');

    // Counters preserved so commitGameOverArchive snapshot captures them.
    expect(effort.effortOvertime).toBe(1);
    expect(effort.effortHero).toBe(1);
  });
});
