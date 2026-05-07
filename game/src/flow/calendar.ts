import { MONTH_DAYS } from '@/economy/constants';

// Calendar / date module. Tracks current_day (1..MONTH_DAYS),
// current_weekday (1..7, Mon..Sun), month_index (1..). Emits dateChanged
// after every advance. Per spec §6.5 domain-emitter pattern.
//
// design/gdd/scene-day-flow-controller.md drives this: ctx payload of
// scene_state_changed includes current_day + current_weekday. P3 derives
// month_index implicitly when calendar.advanceMonth() is called (after
// kpi_review confirm).

export type CalendarListener = () => void;

export class CalendarSystem {
  private _day = 1;
  private _weekday = 1; // Monday
  private _month = 1;
  private listeners = new Set<CalendarListener>();

  get currentDay(): number {
    return this._day;
  }
  get currentWeekday(): number {
    return this._weekday;
  }
  get monthIndex(): number {
    return this._month;
  }

  isMonthEnd(): boolean {
    // True when the CURRENT day is the last day of the month.
    // (Day-cycle controller checks this AFTER ap=0 to decide recap vs review.)
    return this._day >= MONTH_DAYS;
  }

  isWeeklyRecapDay(): boolean {
    // GDD: Friday (weekday=5) gets WEEKLY_RECAP variant of DAILY_RECAP.
    return this._weekday === 5;
  }

  advanceDay(): void {
    this._day += 1;
    this._weekday = (this._weekday % 7) + 1;
    for (const l of this.listeners) l();
  }

  /** Q-BB (Bug #41, 2026-05-07): jump current day directly. Used by
   * the ink-dialog paintStep hook that parses `day_N_*` stitch names
   * out of `story.state.currentPathString` so the calendar widget +
   * weekly-meter triggers stay in sync with the narrative without
   * requiring ink to call back into TS for each day advance. Weekday
   * is rederived from day-1 (game starts day 1 = Monday). No-op if
   * the requested day matches the current state. */
  setDay(day: number): void {
    if (day < 1 || day > MONTH_DAYS) {
      console.warn(`[calendar] setDay out of range: ${day} (cap=${MONTH_DAYS})`);
      return;
    }
    if (this._day === day) return;
    this._day = day;
    this._weekday = ((day - 1) % 7) + 1;
    for (const l of this.listeners) l();
  }

  advanceMonth(): void {
    this._day = 1;
    this._month += 1;
    // Weekday continues from where it was (real-world calendar behavior).
    for (const l of this.listeners) l();
  }

  onDateChanged(fn: CalendarListener): () => void {
    this.listeners.add(fn);
    let unsubscribed = false;
    return () => {
      if (unsubscribed) return;
      unsubscribed = true;
      this.listeners.delete(fn);
    };
  }
}

export const calendar = new CalendarSystem();
