import { beforeEach, describe, expect, it } from 'vitest';
import { ApSystem } from '../../src/economy/ap';
import { MONTH_DAYS } from '../../src/economy/constants';
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
  let calendar: CalendarSystem;
  let flow: FlowDispatcher;
  let controller: DayCycleController;
  let playedThisDay: Set<string>;
  let mockSave: SaveSystem;

  beforeEach(() => {
    ap = new ApSystem();
    kpi = new KpiSystem();
    calendar = new CalendarSystem();
    flow = new FlowDispatcher();
    playedThisDay = new Set(['placeholder_card']);
    mockSave = new SaveSystem(new MemoryFs());
    controller = new DayCycleController({ ap, kpi, calendar, flow, playedThisDay, save: mockSave });
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

  it('confirmKpiReview() with KPI severely below threshold → gameover (dismissal_severe)', async () => {
    // Per GDD: raw potential = (50-100)/100 = -0.5 < POTENTIAL_DISMISSAL (-0.15)
    // → severe underperformance → fired immediately.
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(50);
    ap.spend(8); // → kpi_review
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');
    expect((flow.state as { reason: string }).reason).toBe('dismissal_severe');
  });

  it('confirmKpiReview() with KPI exactly at -0.15 boundary → passes (strict less-than)', async () => {
    // raw potential = (85-100)/100 = -0.15 exactly; NOT < -0.15 so no dismissal.
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(85);
    ap.spend(8);
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');
  });

  it('confirmKpiReview() with KPI exactly at threshold → passes + advances month', async () => {
    // potential = 0; threshold unchanged after recalc; capacity 300 > 100 → pass.
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    kpi.applyContribution(100);
    ap.spend(8);
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('action_day');
    expect(calendar.currentDay).toBe(1);
    expect(calendar.monthIndex).toBe(2);
  });

  it('confirmKpiReview() with threshold > capacity (after recalc) → gameover (kpi_exceeds_capacity)', async () => {
    // Force scenario: advance both calendar AND kpi to month 51 so capacity
    // floors at 40. Initial threshold 100 > 40 → capacity exceeded after recalc.
    // Note kpi.advanceMonth() must mirror calendar.advanceMonth() so kpi.capacityNow
    // reflects the true game month — they're separate counters that callers keep in sync.
    for (let i = 0; i < 50; i++) {
      calendar.advanceMonth();
      kpi.advanceMonth();
    }
    // Both now at month 51. capacityNow = max(40, (3.0 - 0.05*50)*100) = 40.
    // threshold still 100 > 40 → game over.
    // KPI contribution must keep raw potential ≥ -0.15 to skip the dismissal gate
    // (otherwise we hit dismissal_severe instead). actualKpi=85 → raw=-0.15 (boundary, passes).
    kpi.applyContribution(85);
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    flow.request({ kind: 'action_day', day: calendar.currentDay, phase: 'morning' });
    ap.spend(8);
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
    await controller.confirmKpiReview();
    expect(flow.state.kind).toBe('gameover');
    const meta = await mockSave.loadMeta();
    expect(meta.archive.length).toBe(1);
    expect(meta.archive[0]?.reason).toBe('dismissal_severe');
    expect(meta.nextRunId).toBe(2);
  });
});
