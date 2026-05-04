import { describe, expect, it } from 'vitest';
import { appendToArchive, buildRunSummary, removeFromArchive } from '../../src/run-meta/archive';
import { ARCHIVE_HARD_CAP, defaultMetaState, defaultRunState } from '../../src/save/schema';

describe('archive helpers', () => {
  it('buildRunSummary populates required fields', () => {
    const state = { ...defaultRunState(), kpiActual: 250, monthIndex: 5 };
    const summary = buildRunSummary(1, 'kpi_exceeds_capacity', state);
    expect(summary.runId).toBe(1);
    expect(summary.monthAtDeath).toBe(5);
    expect(summary.kpiHistory).toEqual([250]);
    expect(summary.hrEvaluationKey).toMatch(/^HR_EVAL_/);
  });

  it('appendToArchive inserts newest first', () => {
    const meta = defaultMetaState();
    const s1 = buildRunSummary(1, 'kpi_exceeds_capacity', defaultRunState());
    const s2 = buildRunSummary(2, 'dismissal_severe', defaultRunState());
    const after = appendToArchive(appendToArchive(meta, s1), s2);
    expect(after.archive[0]?.runId).toBe(2);
    expect(after.archive[1]?.runId).toBe(1);
  });

  it('appendToArchive evicts oldest when exceeding ARCHIVE_HARD_CAP', () => {
    let meta = defaultMetaState();
    for (let i = 1; i <= ARCHIVE_HARD_CAP + 5; i++) {
      meta = appendToArchive(meta, buildRunSummary(i, 'dismissal_severe', defaultRunState()));
    }
    expect(meta.archive.length).toBe(ARCHIVE_HARD_CAP);
    expect(meta.archive[0]?.runId).toBe(ARCHIVE_HARD_CAP + 5); // newest
    expect(meta.archive[ARCHIVE_HARD_CAP - 1]?.runId).toBe(6); // oldest still in
  });

  it('appendToArchive adds new HR phrase to library', () => {
    const meta = defaultMetaState();
    const s = buildRunSummary(1, 'dismissal_severe', defaultRunState());
    const after = appendToArchive(meta, s);
    expect(after.hrWordLibrary).toContain(s.hrEvaluationKey);
  });

  it('appendToArchive does not duplicate HR library entries', () => {
    const meta = defaultMetaState();
    const s1 = buildRunSummary(1, 'dismissal_severe', defaultRunState());
    const s2 = buildRunSummary(2, 'dismissal_severe', defaultRunState()); // same key likely
    const after = appendToArchive(appendToArchive(meta, s1), s2);
    const occurrences = after.hrWordLibrary.filter((k) => k === s1.hrEvaluationKey).length;
    expect(occurrences).toBe(1);
  });

  it('removeFromArchive removes by runId', () => {
    let meta = defaultMetaState();
    meta = appendToArchive(meta, buildRunSummary(1, 'kpi_exceeds_capacity', defaultRunState()));
    meta = appendToArchive(meta, buildRunSummary(2, 'dismissal_severe', defaultRunState()));
    const after = removeFromArchive(meta, 1);
    expect(after.archive.length).toBe(1);
    expect(after.archive[0]?.runId).toBe(2);
  });

  it('updates nextRunId monotonically', () => {
    const meta = defaultMetaState();
    const after = appendToArchive(meta, buildRunSummary(7, 'dismissal_severe', defaultRunState()));
    expect(after.nextRunId).toBe(8);
  });
});
