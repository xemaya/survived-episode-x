// Discriminated union of all FSM scene states.
// Each variant carries the payload it needs at runtime — the type system
// guarantees you can't transition to e.g. `action_day` without a `day` number.
//
// P1 only implements main_menu / action_day / pause.
// Future variants (event_active, weekend, recap, kpi_review, settings, gameover)
// are added when their owning phase lands. Don't pre-declare them.

export type DayPhase = 'morning' | 'midday' | 'afternoon' | 'evening';

export type SceneState =
  | { kind: 'main_menu' }
  | { kind: 'action_day'; day: number; phase: DayPhase }
  | { kind: 'pause'; resumeTo: SceneState };

export function describe(s: SceneState): string {
  switch (s.kind) {
    case 'main_menu':
      return 'main_menu';
    case 'action_day':
      return `action_day(day=${s.day}, phase=${s.phase})`;
    case 'pause':
      return `pause(resumeTo=${describe(s.resumeTo)})`;
  }
}
