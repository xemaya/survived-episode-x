import type { GameOverReason } from '@/flow/scene-state';
import type { RunState } from '@/save/schema';

// Tiny placeholder library for P4. Full 30+ phrase library is writer
// content (OQ-RM-1 in GDD). 6 keys cover the basic axes: which death
// reason × which performance bracket. The keys themselves are the
// "phrase identifiers"; the human-readable copy is in the same file
// since P4 has no localization yet.

export const HR_EVALUATION_LIBRARY: Record<string, string> = {
  HR_EVAL_BURNOUT_FATIGUE: '该员工长期超负荷运转，绩效已饱和。建议归档。',
  HR_EVAL_HERO_SYNDROME: '该员工屡次主动加码，超额贡献已被组织充分吸收。可优化。',
  HR_EVAL_QUIET_QUITTING: '该员工长期低于岗位要求，适配度不达标。建议解约。',
  HR_EVAL_DRAMATIC_COLLAPSE: '该员工本月绩效断崖式下滑，已无法承担岗位职责。',
  HR_EVAL_TENURE_PEAK: '该员工资历已达天花板，进一步增长成本不可控。建议优化。',
  HR_EVAL_GENERIC: '该员工已不适合现岗位。',
};

export type HrEvaluationKey = keyof typeof HR_EVALUATION_LIBRARY;

// Selection logic per run-meta-system.md F1 three-axis formula:
// - reason (capacity vs dismissal)
// - performance (high effort vs low effort)
// - tenure (early vs late)
// P4 implements minimal branches; full F1 is writer scope.
export function selectHrEvaluation(
  reason: GameOverReason,
  state: RunState,
): { key: string; phrase: string } {
  let key: HrEvaluationKey;
  if (reason === 'dismissal_severe') {
    key =
      state.kpiActual < state.monthlyThreshold * 0.5
        ? 'HR_EVAL_DRAMATIC_COLLAPSE'
        : 'HR_EVAL_QUIET_QUITTING';
  } else {
    // kpi_exceeds_capacity
    if (state.effortHero >= 3) {
      key = 'HR_EVAL_HERO_SYNDROME';
    } else if (state.effortOvertime >= 8) {
      key = 'HR_EVAL_BURNOUT_FATIGUE';
    } else if (state.monthIndex >= 5) {
      key = 'HR_EVAL_TENURE_PEAK';
    } else {
      key = 'HR_EVAL_GENERIC';
    }
  }
  // key is always a valid key in HR_EVALUATION_LIBRARY — non-null assert is safe.
  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
  return { key, phrase: HR_EVALUATION_LIBRARY[key]! };
}
