export type DayPhase = 'morning' | 'midday' | 'afternoon' | 'evening';

export type GameOverReason =
  | 'kpi_exceeds_capacity' // threshold > capacity_now after month-end recalc
  | 'dismissal_severe'; // raw potential < -0.15

export type RecapKind = 'daily' | 'weekly';

export type SceneState =
  | { kind: 'main_menu' }
  | { kind: 'action_day'; day: number; phase: DayPhase }
  | { kind: 'recap'; recapKind: RecapKind; day: number }
  | { kind: 'kpi_review'; monthIndex: number }
  | { kind: 'gameover'; reason: GameOverReason; monthIndex: number }
  | { kind: 'pause'; resumeTo: SceneState };

export function describe(s: SceneState): string {
  switch (s.kind) {
    case 'main_menu':
      return 'main_menu';
    case 'action_day':
      return `action_day(day=${s.day}, phase=${s.phase})`;
    case 'recap':
      return `recap(${s.recapKind}, day=${s.day})`;
    case 'kpi_review':
      return `kpi_review(month=${s.monthIndex})`;
    case 'gameover':
      return `gameover(reason=${s.reason}, month=${s.monthIndex})`;
    case 'pause':
      return `pause(resumeTo=${describe(s.resumeTo)})`;
  }
}
