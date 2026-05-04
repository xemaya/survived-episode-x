import type { GameOverReason } from '@/flow/scene-state';
import type { MetaState, RunState, RunSummary } from '@/save/schema';
import { ARCHIVE_HARD_CAP } from '@/save/schema';
import { selectHrEvaluation } from './hr-evaluation';

// Constructs a RunSummary from current state at GameOver time.
// kpiHistory is a placeholder in P4 — only the FINAL month's actualKpi
// is captured (one-element array). Full month-by-month history requires
// per-month snapshots which P4+ adds when KPI System maintains a log.
export function buildRunSummary(
  runId: number,
  reason: GameOverReason,
  state: RunState,
): RunSummary {
  const { key } = selectHrEvaluation(reason, state);
  return {
    runId,
    monthAtDeath: state.monthIndex,
    reason,
    finalThreshold: state.monthlyThreshold,
    kpiHistory: [state.kpiActual], // P4 stub; P5+ accumulates per-month
    hrEvaluationKey: key,
    diedAt: new Date().toISOString(),
  };
}

// Inserts a RunSummary into meta.archive (newest-first), evicts oldest
// if above ARCHIVE_HARD_CAP, and adds the HR phrase to hrWordLibrary
// if not already seen.
export function appendToArchive(meta: MetaState, summary: RunSummary): MetaState {
  const archive = [summary, ...meta.archive];
  const trimmed = archive.length > ARCHIVE_HARD_CAP ? archive.slice(0, ARCHIVE_HARD_CAP) : archive;
  const lib = new Set(meta.hrWordLibrary);
  lib.add(summary.hrEvaluationKey);
  return {
    ...meta,
    archive: trimmed,
    hrWordLibrary: [...lib].sort(),
    nextRunId: Math.max(meta.nextRunId, summary.runId + 1),
  };
}

// Removes one entry. Per-entry delete only, no batch.
export function removeFromArchive(meta: MetaState, runId: number): MetaState {
  return {
    ...meta,
    archive: meta.archive.filter((e) => e.runId !== runId),
  };
}
