export type DayPhase = 'morning' | 'midday' | 'afternoon' | 'evening';

export type GameOverReason =
  | 'kpi_exceeds_capacity' // threshold > capacity_now after month-end recalc
  | 'dismissal_severe'; // raw potential < -0.15

export type RecapKind = 'daily' | 'weekly';

export type WeeklyMeterPhase = 'week_start' | 'week_end';

export type SceneState =
  | { kind: 'main_menu' }
  | { kind: 'morning_briefing'; day: number }
  | { kind: 'action_day'; day: number; phase: DayPhase }
  | { kind: 'action_overtime'; day: number }
  | { kind: 'after_work'; day: number }
  | { kind: 'recap'; recapKind: RecapKind; day: number }
  | { kind: 'kpi_review'; monthIndex: number }
  | { kind: 'gameover'; reason: GameOverReason; monthIndex: number }
  | { kind: 'pause'; resumeTo: SceneState }
  | { kind: 'weekly_meter'; phase: WeeklyMeterPhase; resumeTo: SceneState }
  | { kind: 'archive_list' }
  | { kind: 'save_corrupt'; errorMessage: string };

export function describe(s: SceneState): string {
  switch (s.kind) {
    case 'main_menu':
      return 'main_menu';
    case 'morning_briefing':
      return `morning_briefing(day=${s.day})`;
    case 'action_day':
      return `action_day(day=${s.day}, phase=${s.phase})`;
    case 'action_overtime':
      return `action_overtime(day=${s.day})`;
    case 'after_work':
      return `after_work(day=${s.day})`;
    case 'recap':
      return `recap(${s.recapKind}, day=${s.day})`;
    case 'kpi_review':
      return `kpi_review(month=${s.monthIndex})`;
    case 'gameover':
      return `gameover(reason=${s.reason}, month=${s.monthIndex})`;
    case 'pause':
      return `pause(resumeTo=${describe(s.resumeTo)})`;
    case 'weekly_meter':
      return `weekly_meter(${s.phase}, resumeTo=${describe(s.resumeTo)})`;
    case 'archive_list':
      return 'archive_list';
    case 'save_corrupt':
      return 'save_corrupt';
  }
}
