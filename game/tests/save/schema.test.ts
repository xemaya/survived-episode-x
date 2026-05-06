import { describe, expect, it } from 'vitest';
import {
  SCHEMA_VERSION,
  defaultMetaState,
  defaultRunState,
  metaStateSchema,
  runStateSchema,
} from '../../src/save/schema';

describe('runStateSchema', () => {
  it('parses defaultRunState', () => {
    const parsed = runStateSchema.parse(defaultRunState());
    expect(parsed.schemaVersion).toBe(SCHEMA_VERSION);
    expect(parsed.apCurrent).toBeUndefined(); // Bug #27: AP system removed
    expect(parsed.energyCurrent).toBe(80);
  });

  it('accepts legacy apCurrent field on older saves (Bug #27 forward-compat)', () => {
    // Older saves still carry apCurrent; field is optional, must parse cleanly.
    const parsed = runStateSchema.parse({ ...defaultRunState(), apCurrent: 5 });
    expect(parsed.apCurrent).toBe(5);
  });

  it('rejects negative legacy apCurrent value', () => {
    expect(() => runStateSchema.parse({ ...defaultRunState(), apCurrent: -1 })).toThrow();
  });

  it('rejects energy > 100', () => {
    expect(() => runStateSchema.parse({ ...defaultRunState(), energyCurrent: 150 })).toThrow();
  });

  it('rejects unknown sceneState kind', () => {
    expect(() =>
      runStateSchema.parse({
        ...defaultRunState(),
        sceneState: { kind: 'fake_state' },
      }),
    ).toThrow();
  });

  it('rejects schemaVersion mismatch', () => {
    expect(() => runStateSchema.parse({ ...defaultRunState(), schemaVersion: 99 })).toThrow();
  });
});

describe('metaStateSchema', () => {
  it('parses defaultMetaState', () => {
    const parsed = metaStateSchema.parse(defaultMetaState());
    expect(parsed.archive).toEqual([]);
    expect(parsed.nextRunId).toBe(1);
  });

  it('accepts a RunSummary in the archive array', () => {
    const meta = defaultMetaState();
    meta.archive.push({
      runId: 1,
      monthAtDeath: 5,
      reason: 'kpi_exceeds_capacity',
      finalThreshold: 250,
      kpiHistory: [120, 145, 180, 210, 250],
      hrEvaluationKey: 'HR_EVAL_BURNOUT_FATIGUE',
      diedAt: new Date().toISOString(),
    });
    expect(() => metaStateSchema.parse(meta)).not.toThrow();
  });
});
