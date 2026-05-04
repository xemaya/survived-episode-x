// Hand-written named constants. Sources from design/registry/entities.yaml +
// the GDDs cited in each comment. A future task wires `pnpm gen:constants`
// to generate this from the YAML registry, at which point this file is
// replaced by `game/src/generated/constants.ts`. Until then, edit BOTH the
// YAML and this file when changing a value.
//
// Red Line 5: any TS file using these numbers must import from here.
// Inline magic numbers matching these values are a lint failure (deferred
// `lint:redline-5` will catch them).

// ─── AP ───────────────────────────────────────────────────────────────────
// design/gdd/ap-economy-system.md §"BASE_AP_PER_DAY = 8 (named constant,
// NOT a tuning knob — permanently fixed)". Anti-Pillar 1 monotonicity:
// AP cap can NEVER permanently increase.
export const BASE_AP_PER_DAY = 8;

// Overtime adds +2 → single-day ceiling 10. Not used in P2; reserved.
export const OVERTIME_BONUS_AP = 2;

// ─── KPI Formula B coefficients ───────────────────────────────────────────
// design/gdd/kpi-reverse-threshold-system.md "Formula B (conservative)":
// next_threshold = current × (1+α·effort) × (1+β·potential) × (1+γ_eff·m)
export const KPI_EFFORT_WEIGHT = 0.04; // α
export const KPI_POTENTIAL_WEIGHT = 0.18; // β
export const KPI_TENURE_WEIGHT = 0.012; // γ (γ_effective = 0 for month 1)

// Monthly capacity: capacity_now = max(CAPACITY_FLOOR, BASE_CAPACITY −
// DECAY_RATE × m) × 100. Player loses ~5 capacity/month; floor at 40.
export const BASE_CAPACITY = 3.0;
export const DECAY_RATE = 0.05;
export const CAPACITY_FLOOR = 0.4;

// Initial month-1 threshold (placeholder for P2; P3+ may load from registry).
export const MONTHLY_THRESHOLD_INITIAL = 100;

// Potential clamp range from GDD.
export const POTENTIAL_CLAMP_MIN = -0.15;
export const POTENTIAL_CLAMP_MAX = 1.0;

// Severe underperformance dismissal threshold (raw potential < this).
export const POTENTIAL_DISMISSAL = -0.15;

// ─── Day cycle ────────────────────────────────────────────────────────────
// design/gdd/scene-day-flow-controller.md uses 30 days/month. For P3 we
// shorten to 7 to make the loop playtestable in a single sitting; P4+
// re-tunes to the design value once core loop is verified.
export const MONTH_DAYS = 7;

// ─── Effort normalisation (Formula B α term) ──────────────────────────────
// design/gdd/ap-economy-system.md §effort-accumulators. Monthly caps used
// to clamp each raw counter to [0, 1] before weighting. Weights sum to 0.95
// (not 1.0) so zero-effort players always have a non-zero α floor.
export const MAX_MONTH_OVERTIME = 20;
export const MAX_MONTH_HERO = 10;
export const MAX_MONTH_OVERAGE = 10;

// ─── Energy ───────────────────────────────────────────────────────────────
// design/gdd/ap-economy-system.md energy section. Cross-day [0,100].
// Drained by overtime, restored by early-leave + weekend rest.
export const ENERGY_MAX = 100;
export const ENERGY_INITIAL = 80;
export const ENERGY_OT_BASE = 15; // overtime declaration cost
export const ENERGY_EL_BASE = 8; // early-leave per AP saved
export const ENERGY_REGEN_PER_DAY = 30; // weekend rest day regen
export const ENERGY_OVERTIME_GUARD = 15; // can't go overtime if below this
