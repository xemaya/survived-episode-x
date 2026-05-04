import { describe, expect, it } from 'vitest';
import { selectHrEvaluation } from '../../src/run-meta/hr-evaluation';
import { defaultRunState } from '../../src/save/schema';

describe('selectHrEvaluation', () => {
  it('dismissal_severe + KPI < 50% threshold → DRAMATIC_COLLAPSE', () => {
    const state = { ...defaultRunState(), kpiActual: 30, monthlyThreshold: 100 };
    expect(selectHrEvaluation('dismissal_severe', state).key).toBe('HR_EVAL_DRAMATIC_COLLAPSE');
  });

  it('dismissal_severe + KPI 50-85% → QUIET_QUITTING', () => {
    const state = { ...defaultRunState(), kpiActual: 70, monthlyThreshold: 100 };
    expect(selectHrEvaluation('dismissal_severe', state).key).toBe('HR_EVAL_QUIET_QUITTING');
  });

  it('kpi_exceeds_capacity + heavy hero → HERO_SYNDROME', () => {
    const state = { ...defaultRunState(), effortHero: 5 };
    expect(selectHrEvaluation('kpi_exceeds_capacity', state).key).toBe('HR_EVAL_HERO_SYNDROME');
  });

  it('kpi_exceeds_capacity + heavy overtime → BURNOUT_FATIGUE', () => {
    const state = { ...defaultRunState(), effortHero: 0, effortOvertime: 10 };
    expect(selectHrEvaluation('kpi_exceeds_capacity', state).key).toBe('HR_EVAL_BURNOUT_FATIGUE');
  });

  it('kpi_exceeds_capacity + late tenure → TENURE_PEAK', () => {
    const state = { ...defaultRunState(), monthIndex: 8 };
    expect(selectHrEvaluation('kpi_exceeds_capacity', state).key).toBe('HR_EVAL_TENURE_PEAK');
  });

  it('kpi_exceeds_capacity + nothing notable → GENERIC', () => {
    expect(selectHrEvaluation('kpi_exceeds_capacity', defaultRunState()).key).toBe(
      'HR_EVAL_GENERIC',
    );
  });
});
