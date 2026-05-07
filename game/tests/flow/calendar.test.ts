import { beforeEach, describe, expect, it, vi } from 'vitest';
import { MONTH_DAYS } from '../../src/economy/constants';
import { CalendarSystem } from '../../src/flow/calendar';

describe('CalendarSystem', () => {
  let calendar: CalendarSystem;

  beforeEach(() => {
    calendar = new CalendarSystem();
  });

  it('starts at day 1, weekday 1 (Monday), month 1', () => {
    expect(calendar.currentDay).toBe(1);
    expect(calendar.currentWeekday).toBe(1);
    expect(calendar.monthIndex).toBe(1);
  });

  it('advanceDay() increments day and weekday, emits dateChanged', () => {
    const listener = vi.fn();
    calendar.onDateChanged(listener);
    calendar.advanceDay();
    expect(calendar.currentDay).toBe(2);
    expect(calendar.currentWeekday).toBe(2);
    expect(listener).toHaveBeenCalledTimes(1);
  });

  it('weekday wraps 1..7 and continues with day', () => {
    for (let i = 0; i < 7; i++) calendar.advanceDay();
    expect(calendar.currentDay).toBe(8); // overshoots MONTH_DAYS=7; advanceMonth must be called separately
    expect(calendar.currentWeekday).toBe(1); // wrapped back to Monday after 7 advances
  });

  it('isMonthEndAfter(currentDay) reports when current day equals MONTH_DAYS', () => {
    expect(calendar.isMonthEnd()).toBe(false); // day 1
    for (let i = 0; i < MONTH_DAYS - 1; i++) calendar.advanceDay();
    expect(calendar.currentDay).toBe(MONTH_DAYS);
    expect(calendar.isMonthEnd()).toBe(true); // last day of month
  });

  it('isWeeklyRecapDay() returns true on Friday (weekday=5)', () => {
    // Mon=1, Tue=2, Wed=3, Thu=4, Fri=5
    for (let i = 0; i < 4; i++) calendar.advanceDay();
    expect(calendar.currentWeekday).toBe(5);
    expect(calendar.isWeeklyRecapDay()).toBe(true);
  });

  it('advanceMonth() resets day to 1, increments monthIndex, weekday continues', () => {
    for (let i = 0; i < 3; i++) calendar.advanceDay(); // day=4, weekday=4
    calendar.advanceMonth();
    expect(calendar.currentDay).toBe(1);
    expect(calendar.monthIndex).toBe(2);
    expect(calendar.currentWeekday).toBe(4); // weekday continuous across months
  });

  it('setDay jumps to the requested day and rederives weekday (Q-BB)', () => {
    const listener = vi.fn();
    calendar.onDateChanged(listener);
    calendar.setDay(15); // day 15 → (15-1) % 7 + 1 = 1 (Monday again)
    expect(calendar.currentDay).toBe(15);
    expect(calendar.currentWeekday).toBe(1);
    expect(listener).toHaveBeenCalledTimes(1);
  });

  it('setDay to current day is a no-op (no listener fire)', () => {
    const listener = vi.fn();
    calendar.onDateChanged(listener);
    calendar.setDay(1); // already at day 1
    expect(listener).not.toHaveBeenCalled();
  });

  it('setDay rederives weekday correctly across the week', () => {
    calendar.setDay(5); // Friday
    expect(calendar.currentWeekday).toBe(5);
    calendar.setDay(7); // Sunday
    expect(calendar.currentWeekday).toBe(7);
    calendar.setDay(8); // next Monday
    expect(calendar.currentWeekday).toBe(1);
  });

  it('setDay clamps to MONTH_DAYS — out-of-range is rejected with no fire', () => {
    const listener = vi.fn();
    calendar.onDateChanged(listener);
    calendar.setDay(0);
    expect(calendar.currentDay).toBe(1);
    calendar.setDay(MONTH_DAYS + 1);
    expect(calendar.currentDay).toBe(1);
    expect(listener).not.toHaveBeenCalled();
  });

  it('unsubscribe stops emissions', () => {
    const listener = vi.fn();
    const unsub = calendar.onDateChanged(listener);
    calendar.advanceDay();
    unsub();
    calendar.advanceDay();
    expect(listener).toHaveBeenCalledTimes(1);
  });
});
