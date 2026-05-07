import { z } from 'zod';

// Single source of truth for save shape. Any module storing player state
// must define a slice here. P4 includes:
// - economy (ap, energy, kpi, monthly threshold + effort counters)
// - calendar (current day/weekday/month)
// - card (playedThisDay)
// - flow (current SceneState — for crash-safe resume)
//
// schemaVersion bump → next P4+ field rev. Mismatch on load → MVP path
// is "discard save, start fresh" dialog (per save-system GDD Rule 7).

export const SCHEMA_VERSION = 1 as const;

const dayPhase = z.enum(['morning', 'midday', 'afternoon', 'evening']);

const sceneStateSchema = z.discriminatedUnion('kind', [
  z.object({ kind: z.literal('main_menu') }),
  z.object({
    kind: z.literal('action_day'),
    day: z.number().int().positive(),
    phase: dayPhase,
  }),
  z.object({
    kind: z.literal('morning_briefing'),
    day: z.number().int().positive(),
  }),
  z.object({
    kind: z.literal('after_work'),
    day: z.number().int().positive(),
  }),
  z.object({
    kind: z.literal('action_overtime'),
    day: z.number().int().positive(),
  }),
  z.object({
    kind: z.literal('recap'),
    recapKind: z.enum(['daily', 'weekly']),
    day: z.number().int().positive(),
  }),
  z.object({
    kind: z.literal('kpi_review'),
    monthIndex: z.number().int().positive(),
  }),
  z.object({
    kind: z.literal('gameover'),
    reason: z.enum(['kpi_exceeds_capacity', 'dismissal_severe']),
    monthIndex: z.number().int().positive(),
  }),
  // pause + weekly_meter are transient overlays — not saved. autosave
  // only fires from ink choice (action_day phase), never while these
  // modals are mounted. If a sceneState ever leaks into a save, zod
  // parse will reject it and the corrupt-save dialog kicks in.
]);

export const runStateSchema = z.object({
  schemaVersion: z.literal(SCHEMA_VERSION),
  // Economy
  // Bug #27 (2026-05-06): AP system deleted. `apCurrent` field is
  // optional so older saves (with the field) parse cleanly; new saves
  // omit it. The field is otherwise ignored.
  apCurrent: z.number().int().min(0).max(10).optional(),
  energyCurrent: z.number().int().min(0).max(100),
  energyBurnoutFlag: z.boolean(),
  // KPI + threshold
  kpiActual: z.number().int().min(0),
  monthlyThreshold: z.number().int().positive(),
  monthIndex: z.number().int().positive(),
  // Effort counters (reset at month-end after KPI recalc)
  effortOvertime: z.number().int().min(0),
  effortHero: z.number().int().min(0),
  effortOverage: z.number().int().min(0),
  // Calendar
  currentDay: z.number().int().min(1),
  currentWeekday: z.number().int().min(1).max(7),
  // Card play
  playedThisDay: z.array(z.string()),
  // FSM
  sceneState: sceneStateSchema,
  // P5 T16: ink runtime state, serialized via story.state.toJson().
  // Optional — saves predating T16 simply lack this field and fall
  // back to a fresh `intro` divert on resume (graceful migration).
  inkStateJson: z.string().optional(),
  // P5 T16 follow-up (QA Bug #11): last narration text shown in the
  // dialog panel before save. Used to pre-fill the panel on restore
  // when ink's `Continue()` has nothing more to drain (because the
  // text was already consumed by the pre-save selectChoice). Optional
  // — older saves omit it and the panel falls back to its `...`
  // placeholder until the next ink advance.
  lastNarrationText: z.string().optional(),
});

export type RunState = z.infer<typeof runStateSchema>;

export const runSummarySchema = z.object({
  runId: z.number().int().positive(),
  monthAtDeath: z.number().int().positive(),
  reason: z.enum(['kpi_exceeds_capacity', 'dismissal_severe']),
  finalThreshold: z.number().int().positive(),
  // Final actualKpi history per month [m1_actual, m2_actual, ...]
  kpiHistory: z.array(z.number().int().min(0)),
  // HR evaluation phrase key (from hr-evaluation.ts library)
  hrEvaluationKey: z.string(),
  diedAt: z.string(), // ISO timestamp
});

export type RunSummary = z.infer<typeof runSummarySchema>;

export const ARCHIVE_HARD_CAP = 200;

export const metaStateSchema = z.object({
  schemaVersion: z.literal(SCHEMA_VERSION),
  // Monotonic counter for new runs
  nextRunId: z.number().int().positive(),
  // Reverse-chronological. Capped at ARCHIVE_HARD_CAP via FIFO eviction.
  archive: z.array(runSummarySchema),
  // Cross-run accumulated HR phrases (Set serialized as sorted array).
  // Each unique phrase the player has seen across all runs.
  hrWordLibrary: z.array(z.string()),
});

export type MetaState = z.infer<typeof metaStateSchema>;

export function defaultMetaState(): MetaState {
  return {
    schemaVersion: SCHEMA_VERSION,
    nextRunId: 1,
    archive: [],
    hrWordLibrary: [],
  };
}

export function defaultRunState(): RunState {
  return {
    schemaVersion: SCHEMA_VERSION,
    energyCurrent: 80, // start with comfortable energy
    energyBurnoutFlag: false,
    kpiActual: 0,
    monthlyThreshold: 100,
    monthIndex: 1,
    effortOvertime: 0,
    effortHero: 0,
    effortOverage: 0,
    currentDay: 1,
    currentWeekday: 1, // Monday
    playedThisDay: [],
    sceneState: { kind: 'morning_briefing', day: 1 },
  };
}
