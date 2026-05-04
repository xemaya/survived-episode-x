# Slice 1 / Phase 4 — Save + Energy + Effort + Archive (Scope B: GDD MVP, no audio)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Activate the Pillar 3 (cross-run) and Pillar 1 (cross-day) loops. Currently each app launch starts fresh from main_menu and KPI Formula B's α (effort) term is permanently zero so the reverse-KPI math is half-active. P4 lands all the GDD-MVP machinery for the complete reverse-KPI loop minus audio: persisted save/load, GameOver→Archive transaction, energy as a cross-day resource, the overtime/hero-card effort tracking that drives Formula B's α term, three new FSM states (MORNING_BRIEFING / AFTER_WORK / ACTION_OVERTIME) so overtime + early-leave decisions are real, MONTH_DAYS retuned to the GDD value of 30, HR-evaluation selection so each Run's death certificate is meaningful, and a hr_word_library that accumulates HR phrases across runs (Pillar 3 "你死了但你的羞辱被存档"). Audio comes in P5.

**Architecture:**
- **`save/`** module: single ironman save (per GDD, NOT 3-slot). One `current_run.save` (autosaved after every card play and major transition), one `meta.save` (archive index + settings + cross-run unlocks), and per-Run `archive/[run_id].save` files written atomically (`.tmp` → `fs.rename`). Uses Tauri 2 `@tauri-apps/plugin-fs`. Schema validated by zod on load. P4 migration policy: schema mismatch → "incompatible save, start new game" dialog (real migrations are VS scope per GDD).
- **`economy/energy.ts`**: separate from AP, range [0, 100], cross-day. Domain emitter `onChanged` per spec §6.5. `burnoutFlag` blocks overtime. Mug sprite binds to energy via 5-tier formula (similar pattern to monitor↔KPI).
- **AP system extended**: holds three monthly effort counters (`overtime_count`, `hero_card_count`, `overage_count`). `reportOvertime()` / `reportHeroCardPlayed()` methods called from AFTER_WORK overlay and `card/play.ts` respectively. Counters reset in `confirmKpiReview` AFTER pushing to KPI system.
- **KPI system extended**: `applyMonthlyRecalc` now computes real `effortNorm` from AP system counters (was hardcoded 0 in P3). Formula B's α term becomes meaningful.
- **3 new FSM states**: `morning_briefing` (transient, skippable, shows day intro), `after_work` (overtime decision: continue overtime vs end day), `action_overtime` (+2 AP cap, costs 15 energy on entry). Day-cycle controller refactored to drive the full sub-mode chain.
- **GameOver → Archive transaction**: 5-step atomic sequence per GDD save-system Rule. Compute RunSummary → write `archive/[run_id].save` → write meta with new entry → delete `current_run.save` → transition to Archive list view.
- **Archive list UI**: Preact overlay reachable from main menu (new "档案" button) AND auto-shown after GameOver. Read-only per-entry display, individual delete (no batch).
- **HR evaluation selection**: at GameOver, `run-meta/hr-evaluation.ts` picks an HR phrase from a small placeholder library based on (death reason, final threshold ratio, NPC relationship snapshot stub). The library is small (~6 phrases) for P4; full 30+ word library is writer content deferred.
- **`hr_word_library`**: meta state Set of HR phrases the player has seen across runs. Each new HR phrase encountered increments. Visible inside Archive list as a sub-section.
- **MONTH_DAYS retune to 30**: re-tunes weekend rest cadence, overtime ceiling, capacity decay alignment. Required so energy / effort / Formula B all work in their designed regime.

**Tech Stack:** Existing toolchain + `@tauri-apps/plugin-fs@~2.0.0` + `zod@~3.23.0`. No other additions.

**Spec reference:** spec §3 (modules), §4.5 (save format), §6.5 (domain emitters). GDD ground truth: `design/gdd/save-system.md`, `design/gdd/run-meta-system.md`, `design/gdd/ap-economy-system.md` (energy + effort), `design/gdd/kpi-reverse-threshold-system.md` (effort_norm + Formula B α), `design/gdd/scene-day-flow-controller.md` (MORNING_BRIEFING / AFTER_WORK / ACTION_OVERTIME sub-modes).

**Prior tag:** `v0.4.0-p3` — day cycle + KPI Review + GameOver + early-leave working in-memory.

---

## Critical design corrections from GDD review

These were wrong in P0/P3-era spec narrative; P4 codebase will match GDD:

- **Save is single-slot ironman, NOT 3-slot + auto-save.** Spec §4.5 was wrong. GDD save-system Rule 2: "任何时刻 current_run.save 至多存在一份；不提供手动另存为、不提供多槽、不提供读档回溯." Three FILES exist (current_run / meta / archive/[run_id]) but only one is the live game.
- **No save migration in MVP.** schema_version field is written and checked. Mismatch → dialog "incompatible save, start new game". Real migration chain is VS+ scope.
- **Continue button on main menu** must be functional whenever `current_run.save` exists. First launch (empty data dir) → Continue grayed out, "新游戏" enters directly.
- **Energy ≠ AP.** Cross-day [0,100], does NOT reset daily. Affected by overtime (-15), early leave (+8 or +16), weekend rest (+30). Mug visualizes energy via 5 sprite tiers.
- **effort_norm has 3 inputs**: overtime_count (weight 0.45) / hero_card_count (0.20) / overage_count (0.30), each normalized to [0,1] against monthly maxes. P4 implements first two; overage_count stubs at 0 (needs per-card KPI delta plumbing not yet built).
- **`overage_count` deferred to Slice 2** because it requires #9 to compute incremental KPI delta per card play vs accumulated; current `applyContribution` is additive only. Stubbing at 0 in P4 means α term is partial but functional.
- **Apple Developer signing not in any GDD** — production-side decision, not P4 scope. P4 produces unsigned `.dmg` same as P0-P3.

---

## File Structure

After P4:

```
game/
├── src/
│   ├── save/                                      (NEW directory)
│   │   ├── schema.ts                              (CREATE — zod RunState/MetaState/RunSummary)
│   │   ├── system.ts                              (CREATE — SaveSystem class + Tauri fs)
│   │   └── tauri-fs.ts                            (CREATE — thin Tauri 2 fs wrapper)
│   ├── economy/
│   │   ├── ap.ts                                  (MODIFY — add effort counters + report methods)
│   │   ├── kpi.ts                                 (MODIFY — applyMonthlyRecalc reads real effortNorm)
│   │   ├── energy.ts                              (CREATE — Energy module + burnout)
│   │   └── constants.ts                           (MODIFY — MONTH_DAYS=30 + new energy/effort constants)
│   ├── flow/
│   │   ├── scene-state.ts                         (MODIFY — +3 SceneState variants)
│   │   ├── transitions.ts                         (MODIFY — extend matrix)
│   │   ├── day-cycle.ts                           (REFACTOR — drive morning_briefing/after_work/overtime path)
│   │   └── calendar.ts                            (unchanged; MONTH_DAYS auto-applies via constants)
│   ├── card/
│   │   ├── card.ts                                (unchanged; isHero already on schema)
│   │   ├── play.ts                                (MODIFY — call ap.reportHeroCardPlayed if isHero)
│   │   └── data/defense.ts                        (MODIFY — set isHero=true on call_in_sick)
│   ├── run-meta/                                  (NEW directory)
│   │   ├── archive.ts                             (CREATE — RunSummary construction + cap eviction)
│   │   └── hr-evaluation.ts                       (CREATE — phrase selection + word library)
│   ├── render/
│   │   ├── stage.ts                               (MODIFY — extend OVERLAY_ALLOWED for new states)
│   │   ├── ui-overlay.tsx                         (MODIFY — route 3 new states + archive list)
│   │   ├── scene/
│   │   │   └── workstation.ts                     (MODIFY — mug binding to energy)
│   │   └── menu/
│   │       ├── main-menu.tsx                      (MODIFY — Continue button + Archive button)
│   │       ├── morning-briefing.tsx               (CREATE — brief intro overlay)
│   │       ├── after-work.tsx                     (CREATE — overtime decision overlay)
│   │       ├── archive-list.tsx                   (CREATE — Archive list UI)
│   │       └── save-corrupt-dialog.tsx            (CREATE — error dialog)
│   ├── input/
│   │   └── keyboard.ts                            (unchanged)
│   └── main.ts                                    (MODIFY — load save on boot, wire autosave hooks)
└── tests/
    ├── save/
    │   ├── schema.test.ts                         (CREATE — zod parse + reject malformed)
    │   └── system.test.ts                         (CREATE — round-trip in-memory mock fs)
    ├── economy/
    │   ├── energy.test.ts                         (CREATE — delta/clamp/burnout/regen)
    │   └── ap-effort.test.ts                      (CREATE — counter wiring + reset on month-end)
    ├── flow/
    │   ├── transitions.test.ts                    (MODIFY — +12 cases for new states)
    │   └── day-cycle.test.ts                      (MODIFY — extend for overtime/morning path)
    └── run-meta/
        ├── archive.test.ts                        (CREATE — cap FIFO + RunSummary construction)
        └── hr-evaluation.test.ts                  (CREATE — selection branches)
```

---

## Task 1: Save infrastructure — Tauri fs + zod schema + autosave + Continue button

**Why first:** every other module that holds game state needs a place to persist. Build the save system standalone with TDD, then later tasks just call `save.write()` after their state changes.

**Files:**
- Create: `game/src/save/schema.ts`
- Create: `game/src/save/tauri-fs.ts`
- Create: `game/src/save/system.ts`
- Create: `game/tests/save/schema.test.ts`
- Create: `game/tests/save/system.test.ts`
- Modify: `game/src-tauri/Cargo.toml` (add `tauri-plugin-fs`)
- Modify: `game/src-tauri/src/lib.rs` (register fs plugin)
- Modify: `game/src-tauri/capabilities/default.json` (grant fs scope)
- Modify: `game/src/render/menu/main-menu.tsx` (add Continue button)
- Modify: `game/src/main.ts` (load save on boot)
- Add devDep: `@tauri-apps/plugin-fs@~2.0.0` + `zod@~3.23.0`

- [ ] **Step 1.1: Install dependencies**

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x/game
pnpm add @tauri-apps/plugin-fs@~2.0.0 zod@~3.23.0
```

- [ ] **Step 1.2: Add Rust-side fs plugin** — edit `game/src-tauri/Cargo.toml`. Find the `[dependencies]` block and add:

```toml
tauri-plugin-fs = "2.0.0-rc"
```

(Use the matching version of your tauri crate. If `cargo update` is needed, run it.)

- [ ] **Step 1.3: Register the fs plugin** — edit `game/src-tauri/src/lib.rs`. Find the `tauri::Builder::default()` chain and add `.plugin(tauri_plugin_fs::init())` after the existing `.plugin(...)` calls (or before `.invoke_handler` if no other plugins).

Example final builder block:

```rust
tauri::Builder::default()
    .plugin(tauri_plugin_log::Builder::default().build())
    .plugin(tauri_plugin_fs::init())
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
```

- [ ] **Step 1.4: Grant fs capability** — edit `game/src-tauri/capabilities/default.json`. Add to the `permissions` array:

```json
"fs:default",
"fs:allow-app-write",
"fs:allow-app-read",
"fs:allow-app-meta",
"fs:allow-mkdir",
"fs:allow-rename",
"fs:allow-exists"
```

(Final permissions field becomes a JSON array including these alongside `"core:default"`.)

- [ ] **Step 1.5: Create `game/src/save/schema.ts`** (exact content):

```ts
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
  // pause is transient — not saved (player must restart from saved state)
]);

export const runStateSchema = z.object({
  schemaVersion: z.literal(SCHEMA_VERSION),
  // Economy
  apCurrent: z.number().int().min(0).max(10), // base 8, overtime adds 2
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
    apCurrent: 8,
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
```

- [ ] **Step 1.6: Write the failing test** at `game/tests/save/schema.test.ts`:

```ts
import { describe, expect, it } from 'vitest';
import {
  defaultMetaState,
  defaultRunState,
  metaStateSchema,
  runStateSchema,
  SCHEMA_VERSION,
} from '../../src/save/schema';

describe('runStateSchema', () => {
  it('parses defaultRunState', () => {
    const parsed = runStateSchema.parse(defaultRunState());
    expect(parsed.schemaVersion).toBe(SCHEMA_VERSION);
    expect(parsed.apCurrent).toBe(8);
    expect(parsed.energyCurrent).toBe(80);
  });

  it('rejects negative AP', () => {
    expect(() =>
      runStateSchema.parse({ ...defaultRunState(), apCurrent: -1 }),
    ).toThrow();
  });

  it('rejects energy > 100', () => {
    expect(() =>
      runStateSchema.parse({ ...defaultRunState(), energyCurrent: 150 }),
    ).toThrow();
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
```

- [ ] **Step 1.7: Run the test — expect FAIL** (module not found):

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x/game
pnpm vitest run tests/save/schema.test.ts
```

- [ ] **Step 1.8: After Step 1.5's schema.ts is written, re-run the test — expect 7 PASS**.

- [ ] **Step 1.9: Create `game/src/save/tauri-fs.ts`** (thin wrapper around Tauri 2 fs API; tests can mock this):

```ts
import {
  BaseDirectory,
  exists,
  mkdir,
  readTextFile,
  remove,
  rename,
  writeTextFile,
} from '@tauri-apps/plugin-fs';

// Thin abstraction over Tauri 2's fs plugin. All paths are relative to
// AppData base directory (auto-namespaced by tauri.conf.json identifier).
// Tests inject an alternative implementation via dependency injection
// in SaveSystem.
export interface SaveFs {
  exists(path: string): Promise<boolean>;
  read(path: string): Promise<string>;
  // Atomic write: writes to {path}.tmp, then renames over path.
  writeAtomic(path: string, content: string): Promise<void>;
  delete(path: string): Promise<void>;
  ensureDir(path: string): Promise<void>;
}

const BASE = { baseDir: BaseDirectory.AppData };

export const tauriFs: SaveFs = {
  async exists(path) {
    return exists(path, BASE);
  },
  async read(path) {
    return readTextFile(path, BASE);
  },
  async writeAtomic(path, content) {
    const tmp = `${path}.tmp`;
    await writeTextFile(tmp, content, BASE);
    // Tauri 2 rename overwrites destination atomically on the same volume.
    await rename(tmp, path, { ...BASE, newPathBaseDir: BaseDirectory.AppData });
  },
  async delete(path) {
    await remove(path, BASE);
  },
  async ensureDir(path) {
    if (!(await exists(path, BASE))) {
      await mkdir(path, { ...BASE, recursive: true });
    }
  },
};
```

- [ ] **Step 1.10: Write the failing test** at `game/tests/save/system.test.ts`:

```ts
import { beforeEach, describe, expect, it } from 'vitest';
import {
  defaultMetaState,
  defaultRunState,
  type RunState,
  type MetaState,
} from '../../src/save/schema';
import { SaveSystem } from '../../src/save/system';
import type { SaveFs } from '../../src/save/tauri-fs';

// In-memory mock fs for tests
class MemoryFs implements SaveFs {
  files = new Map<string, string>();
  dirs = new Set<string>(['']);

  async exists(path: string): Promise<boolean> {
    return this.files.has(path) || this.dirs.has(path);
  }
  async read(path: string): Promise<string> {
    const v = this.files.get(path);
    if (v === undefined) throw new Error(`ENOENT: ${path}`);
    return v;
  }
  async writeAtomic(path: string, content: string): Promise<void> {
    this.files.set(path, content);
  }
  async delete(path: string): Promise<void> {
    this.files.delete(path);
  }
  async ensureDir(path: string): Promise<void> {
    this.dirs.add(path);
  }
}

describe('SaveSystem', () => {
  let fs: MemoryFs;
  let save: SaveSystem;

  beforeEach(() => {
    fs = new MemoryFs();
    save = new SaveSystem(fs);
  });

  describe('current_run.save', () => {
    it('returns null when no save exists', async () => {
      expect(await save.loadCurrentRun()).toBeNull();
    });

    it('round-trips a RunState', async () => {
      const state = defaultRunState();
      state.apCurrent = 5;
      state.kpiActual = 42;
      await save.writeCurrentRun(state);
      const loaded = await save.loadCurrentRun();
      expect(loaded).not.toBeNull();
      expect(loaded?.apCurrent).toBe(5);
      expect(loaded?.kpiActual).toBe(42);
    });

    it('returns null + reports corrupt on schemaVersion mismatch', async () => {
      const bad = { ...defaultRunState(), schemaVersion: 99 };
      await fs.writeAtomic('saves/current_run.save', JSON.stringify(bad));
      const result = await save.loadCurrentRun();
      expect(result).toBeNull();
      expect(save.lastLoadError).toMatch(/schema|version/i);
    });

    it('returns null + reports corrupt on malformed JSON', async () => {
      await fs.writeAtomic('saves/current_run.save', '{not json');
      expect(await save.loadCurrentRun()).toBeNull();
      expect(save.lastLoadError).toMatch(/parse|json/i);
    });

    it('hasCurrentRun() reports true after write', async () => {
      expect(await save.hasCurrentRun()).toBe(false);
      await save.writeCurrentRun(defaultRunState());
      expect(await save.hasCurrentRun()).toBe(true);
    });

    it('clearCurrentRun() removes the file', async () => {
      await save.writeCurrentRun(defaultRunState());
      await save.clearCurrentRun();
      expect(await save.hasCurrentRun()).toBe(false);
    });
  });

  describe('meta.save', () => {
    it('returns defaultMetaState when no meta exists', async () => {
      const meta = await save.loadMeta();
      expect(meta).toEqual(defaultMetaState());
    });

    it('round-trips meta with archive entries', async () => {
      const meta: MetaState = {
        ...defaultMetaState(),
        nextRunId: 5,
        hrWordLibrary: ['HR_EVAL_BURNOUT_FATIGUE'],
      };
      await save.writeMeta(meta);
      const loaded = await save.loadMeta();
      expect(loaded.nextRunId).toBe(5);
      expect(loaded.hrWordLibrary).toEqual(['HR_EVAL_BURNOUT_FATIGUE']);
    });
  });

  describe('archive', () => {
    it('writes and reads back per-run archive file', async () => {
      const state = defaultRunState();
      await save.writeArchiveSnapshot(7, state);
      const loaded = await save.loadArchiveSnapshot(7);
      expect(loaded?.apCurrent).toBe(state.apCurrent);
    });
  });
});
```

- [ ] **Step 1.11: Run — expect FAIL** (system.ts not yet created).

- [ ] **Step 1.12: Implement `game/src/save/system.ts`** (exact content):

```ts
import {
  defaultMetaState,
  type MetaState,
  metaStateSchema,
  type RunState,
  runStateSchema,
} from './schema';
import { tauriFs as productionFs, type SaveFs } from './tauri-fs';

const SAVES_DIR = 'saves';
const CURRENT_RUN_PATH = `${SAVES_DIR}/current_run.save`;
const META_PATH = `${SAVES_DIR}/meta.save`;
const ARCHIVE_PATH = (runId: number) => `${SAVES_DIR}/archive/${runId}.save`;

export class SaveSystem {
  private fs: SaveFs;
  // Last error message from a failed load — UI dialog reads this.
  lastLoadError: string | null = null;

  constructor(fs: SaveFs = productionFs) {
    this.fs = fs;
  }

  async hasCurrentRun(): Promise<boolean> {
    return this.fs.exists(CURRENT_RUN_PATH);
  }

  async loadCurrentRun(): Promise<RunState | null> {
    this.lastLoadError = null;
    if (!(await this.fs.exists(CURRENT_RUN_PATH))) return null;
    let raw: string;
    try {
      raw = await this.fs.read(CURRENT_RUN_PATH);
    } catch (e) {
      this.lastLoadError = `read failed: ${(e as Error).message}`;
      return null;
    }
    let parsed: unknown;
    try {
      parsed = JSON.parse(raw);
    } catch (e) {
      this.lastLoadError = `JSON parse failed: ${(e as Error).message}`;
      return null;
    }
    const result = runStateSchema.safeParse(parsed);
    if (!result.success) {
      this.lastLoadError = `schema validation failed: ${result.error.message}`;
      return null;
    }
    return result.data;
  }

  async writeCurrentRun(state: RunState): Promise<void> {
    await this.fs.ensureDir(SAVES_DIR);
    await this.fs.writeAtomic(CURRENT_RUN_PATH, JSON.stringify(state, null, 2));
  }

  async clearCurrentRun(): Promise<void> {
    if (await this.fs.exists(CURRENT_RUN_PATH)) {
      await this.fs.delete(CURRENT_RUN_PATH);
    }
  }

  async loadMeta(): Promise<MetaState> {
    if (!(await this.fs.exists(META_PATH))) return defaultMetaState();
    try {
      const raw = await this.fs.read(META_PATH);
      const parsed = JSON.parse(raw);
      const result = metaStateSchema.safeParse(parsed);
      if (!result.success) {
        // Corrupt meta — start fresh. (Real impl backs up the old file; P4 stubs.)
        this.lastLoadError = `meta corrupt: ${result.error.message}`;
        return defaultMetaState();
      }
      return result.data;
    } catch {
      return defaultMetaState();
    }
  }

  async writeMeta(meta: MetaState): Promise<void> {
    await this.fs.ensureDir(SAVES_DIR);
    await this.fs.writeAtomic(META_PATH, JSON.stringify(meta, null, 2));
  }

  async writeArchiveSnapshot(runId: number, state: RunState): Promise<void> {
    await this.fs.ensureDir(`${SAVES_DIR}/archive`);
    await this.fs.writeAtomic(ARCHIVE_PATH(runId), JSON.stringify(state, null, 2));
  }

  async loadArchiveSnapshot(runId: number): Promise<RunState | null> {
    if (!(await this.fs.exists(ARCHIVE_PATH(runId)))) return null;
    try {
      const raw = await this.fs.read(ARCHIVE_PATH(runId));
      const parsed = JSON.parse(raw);
      const result = runStateSchema.safeParse(parsed);
      return result.success ? result.data : null;
    } catch {
      return null;
    }
  }
}

// Singleton — production code uses this; tests construct their own.
export const save = new SaveSystem();
```

- [ ] **Step 1.13: Run the test — expect 11 PASS** (5 schema + 6 system... wait, recount. Schema: 5+2 = 7. System: 5 current_run + 2 meta + 1 archive = 8. Total: 15. Re-verify in your run.).

```bash
pnpm vitest run tests/save/
```

Expected: all save tests pass.

- [ ] **Step 1.14: Wire Continue + load on boot** — modify `game/src/main.ts`. Full file:

```ts
import { dayCycle } from '@/flow/day-cycle';
import { flow } from '@/flow/dispatcher';
import { installKeyboardHandler } from '@/input/keyboard';
import { Container } from 'pixi.js';
import { createPixiApp } from '@/render/pixi-app';
import { bindStageToFlow } from '@/render/stage';
import { mountOverlay } from '@/render/ui-overlay';
import { save } from '@/save/system';
import { applyRunState } from '@/save/restore'; // see Step 1.15

async function main(): Promise<void> {
  const pixiRoot = document.getElementById('pixi-root');
  const overlayRoot = document.getElementById('ui-overlay');
  if (!pixiRoot || !overlayRoot) {
    throw new Error('Required DOM nodes not found');
  }
  const { app } = await createPixiApp(pixiRoot);

  const worldLayer = new Container();
  worldLayer.label = 'world';
  app.stage.addChild(worldLayer);

  // P4: try to load existing save on boot. If found, restore state and
  // resume from saved sceneState. If not, leave FSM at initial main_menu.
  const restored = await save.loadCurrentRun();
  if (restored) {
    applyRunState(restored);
    flow.request(restored.sceneState);
    console.info('[boot] restored save:', restored.sceneState.kind);
  } else if (save.lastLoadError) {
    console.warn('[boot] save load failed:', save.lastLoadError);
    // Save-corrupt dialog wired in Task 8
  }

  dayCycle.attach();
  bindStageToFlow({ app, worldLayer });
  mountOverlay(overlayRoot);
  installKeyboardHandler();

  console.info('[boot] flow + dayCycle + overlay + keyboard ready');
}

void main();
```

- [ ] **Step 1.15: Create `game/src/save/restore.ts`** — bidirectional state ↔ singleton sync:

```ts
import { ap } from '@/economy/ap';
import { kpi } from '@/economy/kpi';
import { calendar } from '@/flow/calendar';
import { playedThisDay } from '@/card/play';
import type { RunState } from './schema';

// Mutates singletons to match a loaded RunState. Called on boot if a
// save exists. The reverse direction (snapshot singletons → RunState)
// is in snapshot.ts (used for autosave).
export function applyRunState(state: RunState): void {
  // AP: directly set internal value via spend/refill primitives is awkward;
  // since AP is reset-only or spend-only, we expose a setForRestore method
  // on ApSystem (added in Task 4 alongside effort counters). For P4 Task 1
  // we fake it with a fresh refill + spend the difference.
  ap.resetForNewDay();
  if (state.apCurrent < ap.max) {
    ap.spend(ap.max - state.apCurrent);
  }

  // KPI: similar — needs a setForRestore that bypasses the additive guard.
  // For P4 Task 1, only reset to defaults; Task 4 wires real restore.
  // (This is OK because Task 1 just adds the persistence layer; full
  // restore semantics land alongside the energy + effort modules in
  // Task 4 when we have setForRestore methods on every domain singleton.)

  // Calendar
  while (calendar.currentDay < state.currentDay) calendar.advanceDay();

  // Played this day
  playedThisDay.clear();
  for (const id of state.playedThisDay) playedThisDay.add(id);
}
```

(Note: this is a P4 Task 1 placeholder. Task 4 adds proper `setForRestore` methods. The Task 1 version is good enough to verify the save/load plumbing without breaking existing behavior.)

- [ ] **Step 1.16: Add Continue button to `game/src/render/menu/main-menu.tsx`** — modify to show "继续" enabled iff a save exists. Full file:

```tsx
import { flow } from '@/flow/dispatcher';
import { useEffect, useState } from 'preact/hooks';
import { save } from '@/save/system';

export function MainMenu(): preact.JSX.Element {
  const [hasSave, setHasSave] = useState(false);
  useEffect(() => {
    void save.hasCurrentRun().then(setHasSave);
  }, []);

  const startGame = (): void => {
    // Task 4 will check if save exists and prompt "discard previous run?"
    // P4 Task 1 placeholder: always start fresh from action_day day=1.
    flow.request({ kind: 'action_day', day: 1, phase: 'morning' });
  };

  const continueGame = (): void => {
    // Save was already loaded on boot via main.ts; just transition to
    // the saved sceneState. main.ts has already done flow.request for
    // restored state, so by the time MainMenu shows, this button just
    // dismisses to the current state.
    void save.loadCurrentRun().then((s) => {
      if (s) flow.request(s.sceneState);
    });
  };

  return (
    <div class="menu-root menu-root--main">
      <h1 class="menu-title">活过第 X 集</h1>
      <p class="menu-subtitle">一个反向 KPI 办公室生存模拟</p>
      <div class="menu-buttons">
        <button
          type="button"
          class={`menu-button ${hasSave ? '' : 'menu-button--primary'}`}
          onClick={startGame}
        >
          新游戏
        </button>
        <button
          type="button"
          class="menu-button menu-button--primary"
          onClick={continueGame}
          disabled={!hasSave}
          style={{ opacity: hasSave ? 1 : 0.4, cursor: hasSave ? 'pointer' : 'not-allowed' }}
        >
          继续
        </button>
      </div>
    </div>
  );
}
```

- [ ] **Step 1.17: Smoke headless** — verify dev compiles:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x/game
pnpm dev > /tmp/vite-dev-task1.log 2>&1 &
DEV_PID=$!
sleep 5
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
tail -10 /tmp/vite-dev-task1.log
kill $DEV_PID 2>/dev/null; wait 2>/dev/null
pgrep vite || echo "no leftover"
pnpm tsc
pnpm test
```

Expected: HTTP 200, tsc 0, vitest +15 cases (total ~97).

- [ ] **Step 1.18: Smoke Tauri build** (required because we added Rust dep):

```bash
hdiutil detach "/Volumes/活过第 X 集" 2>&1 | tail -1 || true
pnpm tauri build 2>&1 | tail -8
```

Expected: cargo build incremental compiles `tauri-plugin-fs`, .app + .dmg produced.

- [ ] **Step 1.19: Manual smoke** (controller does):

```bash
killall "活过第 X 集" 2>/dev/null
open ".../bundle/macos/活过第 X 集.app"
```

Walk:
1. First launch → main menu shows 「新游戏」 (gold) + 「继续」 (greyed)
2. 「新游戏」 → workstation
3. Play a card → background autosave fires (Task 4 will hook this; P4 Task 1 just provides the plumbing — controller can manually verify save plumbing works by checking `~/Library/Application Support/com.huanghaibin.survived-episode-x/saves/` after Task 4 lands)

For Task 1 the only visible change is the Continue button presence (greyed). Full save flow lights up after Task 4.

- [ ] **Step 1.20: Commit**:

```bash
cd /Users/huanghaibin/Workspace/games/survived-episode-x
git add game/src/save game/tests/save game/src/main.ts game/src/render/menu/main-menu.tsx \
        game/src-tauri/Cargo.toml game/src-tauri/src/lib.rs \
        game/src-tauri/capabilities/default.json \
        game/package.json game/pnpm-lock.yaml
git commit -m "feat(game): save/ infrastructure — Tauri fs + zod schema + Continue button

P4 Task 1 lands the save plumbing without yet wiring autosave hooks
(Tasks 4-7 integrate them as each module gains restorable state):

- save/schema.ts: zod RunState + MetaState + RunSummary, schemaVersion=1.
  RunState includes all P4 fields (energy, effort counters) ahead of
  their owning modules so the schema is stable across Tasks 2-7.
- save/tauri-fs.ts: thin wrapper over @tauri-apps/plugin-fs (BaseDir
  AppData). writeAtomic uses .tmp + rename per save-system GDD Rule 5.
  Tests inject MemoryFs.
- save/system.ts: SaveSystem class + production singleton. loadCurrentRun
  returns null on missing/corrupt save and stores lastLoadError for
  UI dialog (Task 8 wires the dialog).
- save/restore.ts: P4 Task 1 placeholder for state restore on boot;
  Task 4 replaces with setForRestore methods on each singleton.
- main-menu.tsx: 'Continue' button enabled iff save.hasCurrentRun().
- main.ts: loads save on boot, applies state if found, resumes from
  saved sceneState.

Tauri side:
- Cargo.toml + lib.rs: tauri-plugin-fs registered.
- capabilities/default.json: AppData read/write/mkdir/rename grants.

Vitest: +15 cases (7 schema + 8 system) covering round-trip, missing
file, corrupt JSON, schema version mismatch, ironman invariant.

Per design/gdd/save-system.md (single-slot, atomic write, schemaVersion).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 2: Energy module + mug 5-frame binding + burnout

**Files:**
- Create: `game/src/economy/energy.ts`
- Create: `game/tests/economy/energy.test.ts`
- Modify: `game/src/economy/constants.ts` (add ENERGY_*)
- Modify: `game/src/render/scene/workstation.ts` (mug 5-frame binding)

- [ ] **Step 2.1: Add energy constants to `game/src/economy/constants.ts`** (append):

```ts
// ─── Energy ───────────────────────────────────────────────────────────────
// design/gdd/ap-economy-system.md energy section. Cross-day [0,100].
// Drained by overtime, restored by early-leave + weekend rest.
export const ENERGY_MAX = 100;
export const ENERGY_INITIAL = 80;
export const ENERGY_OT_BASE = 15;       // overtime declaration cost
export const ENERGY_EL_BASE = 8;        // early-leave per AP saved
export const ENERGY_REGEN_PER_DAY = 30; // weekend rest day regen
export const ENERGY_OVERTIME_GUARD = 15; // can't go overtime if below this
```

- [ ] **Step 2.2: Write the failing test** at `game/tests/economy/energy.test.ts`:

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  ENERGY_INITIAL,
  ENERGY_MAX,
  ENERGY_OT_BASE,
  ENERGY_REGEN_PER_DAY,
  ENERGY_OVERTIME_GUARD,
} from '../../src/economy/constants';
import { EnergySystem } from '../../src/economy/energy';

describe('EnergySystem', () => {
  let energy: EnergySystem;

  beforeEach(() => {
    energy = new EnergySystem();
  });

  it('starts at ENERGY_INITIAL with no burnout', () => {
    expect(energy.current).toBe(ENERGY_INITIAL);
    expect(energy.burnoutFlag).toBe(false);
  });

  it('change(+n) increases and clamps at ENERGY_MAX', () => {
    energy.change(50);
    expect(energy.current).toBe(ENERGY_MAX);
  });

  it('change(-n) decreases and clamps at 0; sets burnoutFlag at exactly 0', () => {
    energy.change(-ENERGY_INITIAL);
    expect(energy.current).toBe(0);
    expect(energy.burnoutFlag).toBe(true);
  });

  it('emits onChanged with new value and delta', () => {
    const listener = vi.fn();
    energy.onChanged(listener);
    energy.change(-10);
    expect(listener).toHaveBeenCalledWith(ENERGY_INITIAL - 10, -10);
  });

  it('canOvertime() returns false if energy < ENERGY_OVERTIME_GUARD', () => {
    energy.change(-(ENERGY_INITIAL - ENERGY_OVERTIME_GUARD + 1)); // just below guard
    expect(energy.canOvertime()).toBe(false);
    energy.change(1); // back at guard
    expect(energy.canOvertime()).toBe(true);
  });

  it('canOvertime() returns false if burnoutFlag (even if recovered above guard)', () => {
    energy.change(-ENERGY_INITIAL);
    expect(energy.burnoutFlag).toBe(true);
    energy.change(50); // recovered, but flag persists
    expect(energy.canOvertime()).toBe(false);
  });

  it('clearBurnout() resets the flag', () => {
    energy.change(-ENERGY_INITIAL);
    energy.change(50);
    energy.clearBurnout();
    expect(energy.canOvertime()).toBe(true);
  });

  it('regenForRestDay() adds ENERGY_REGEN_PER_DAY (clamped)', () => {
    energy.change(-50); // 30
    energy.regenForRestDay();
    expect(energy.current).toBe(60);
  });

  it('reportOvertime() drains ENERGY_OT_BASE (called by AFTER_WORK)', () => {
    energy.reportOvertime();
    expect(energy.current).toBe(ENERGY_INITIAL - ENERGY_OT_BASE);
  });

  it('setForRestore(value) directly sets value; preserves burnoutFlag separately', () => {
    energy.setForRestore(50, true);
    expect(energy.current).toBe(50);
    expect(energy.burnoutFlag).toBe(true);
  });

  it('unsubscribe stops emissions', () => {
    const listener = vi.fn();
    const unsub = energy.onChanged(listener);
    energy.change(-1);
    unsub();
    energy.change(-1);
    expect(listener).toHaveBeenCalledTimes(1);
  });
});
```

- [ ] **Step 2.3: Run — expect FAIL** (energy.ts not yet created).

- [ ] **Step 2.4: Implement `game/src/economy/energy.ts`**:

```ts
import {
  ENERGY_INITIAL,
  ENERGY_MAX,
  ENERGY_OT_BASE,
  ENERGY_OVERTIME_GUARD,
  ENERGY_REGEN_PER_DAY,
} from './constants';

export type EnergyListener = (current: number, delta: number) => void;

// design/gdd/ap-economy-system.md energy section. Cross-day [0,100],
// drained by overtime, restored by early-leave + weekend rest.
// burnoutFlag persists across recovery — prevents overtime spam after
// hitting 0 once. Cleared explicitly (e.g. on month-end if design wants
// — TBD per GDD; P4 keeps it persistent until manual clearBurnout()).
export class EnergySystem {
  private value: number = ENERGY_INITIAL;
  private burnout = false;
  private listeners = new Set<EnergyListener>();

  get current(): number {
    return this.value;
  }
  get max(): number {
    return ENERGY_MAX;
  }
  get burnoutFlag(): boolean {
    return this.burnout;
  }

  canOvertime(): boolean {
    return !this.burnout && this.value >= ENERGY_OVERTIME_GUARD;
  }

  change(delta: number): void {
    const next = Math.max(0, Math.min(ENERGY_MAX, this.value + delta));
    const actualDelta = next - this.value;
    this.value = next;
    if (next === 0) this.burnout = true;
    for (const l of this.listeners) l(this.value, actualDelta);
  }

  regenForRestDay(): void {
    this.change(ENERGY_REGEN_PER_DAY);
  }

  reportOvertime(): void {
    this.change(-ENERGY_OT_BASE);
  }

  clearBurnout(): void {
    this.burnout = false;
  }

  // Used by save/restore; bypasses change() so the burnout flag is
  // restored independently of value (player could be at energy=50 with
  // burnoutFlag=true if they recovered after a previous burnout).
  setForRestore(value: number, burnout: boolean): void {
    this.value = Math.max(0, Math.min(ENERGY_MAX, value));
    this.burnout = burnout;
  }

  onChanged(fn: EnergyListener): () => void {
    this.listeners.add(fn);
    let unsubscribed = false;
    return () => {
      if (unsubscribed) return;
      unsubscribed = true;
      this.listeners.delete(fn);
    };
  }
}

export const energy = new EnergySystem();
```

- [ ] **Step 2.5: Run energy test — expect 11 PASS**.

- [ ] **Step 2.6: Wire mug to energy in `workstation.ts`** — replace the static mug entry from STATIC_PROPS with a dynamic 5-frame binding (similar to monitor↔KPI). Find this line in STATIC_PROPS:

```ts
{ url: 'sprites/hud/coffee_full.png', x: 130, y: 260, scale: 0.1, label: 'mug' },
```

REMOVE it from STATIC_PROPS, then add this block AFTER the calendar-binding block (or alongside the monitor binding — order doesn't matter for rendering):

```ts
  // ── Mug (energy binding, swappable sprite) ──────────────────────────────
  // 5 tiers per energy level. tier = floor(energy / 20), clamped 0..4.
  // tier 4 = full (80-100), tier 0 = empty (0-19) + stain ring (P5).
  const mugContainer = new Container();
  mugContainer.label = 'mug';
  mugContainer.x = 130;
  mugContainer.y = 260;
  ctx.worldLayer.addChild(mugContainer);

  const MUG_FRAMES = [
    'sprites/hud/coffee_empty.png',          // tier 0 [0-19]
    'sprites/hud/coffee_empty.png',          // tier 1 [20-39] — placeholder; ideal coffee_quarter.png if present
    'sprites/hud/coffee_half.png',           // tier 2 [40-59]
    'sprites/hud/coffee_three_quarter.png',  // tier 3 [60-79]
    'sprites/hud/coffee_full.png',           // tier 4 [80-100]
  ] as const;

  function pickMugFrame(value: number): string {
    const tier = Math.max(0, Math.min(4, Math.floor(value / 20)));
    return MUG_FRAMES[tier]!;
  }

  let currentMugSprite: Sprite | null = null;
  const swapMugTo = async (url: string) => {
    const tex = await Assets.load(url);
    tex.source.scaleMode = 'linear';
    if (currentMugSprite) currentMugSprite.destroy();
    const s = new Sprite(tex);
    s.anchor.set(0.5);
    s.scale.set(0.1);
    mugContainer.addChild(s);
    currentMugSprite = s;
  };
  await swapMugTo(pickMugFrame(energy.current));

  const unsubEnergy = energy.onChanged((value) => {
    void swapMugTo(pickMugFrame(value));
  });
  teardowns.push(() => {
    unsubEnergy();
    mugContainer.destroy({ children: true });
  });
```

Add the import at top:

```ts
import { energy } from '@/economy/energy';
```

- [ ] **Step 2.7: Smoke + verify**:

```bash
pnpm tsc; pnpm test
pnpm dev > /tmp/v.log 2>&1 & DEV_PID=$!; sleep 5
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:1420/
kill $DEV_PID 2>/dev/null; wait 2>/dev/null
```

Expected: tsc 0, vitest ~108 (97 + 11), HTTP 200.

- [ ] **Step 2.8: Commit**:

```bash
git add game/src/economy/energy.ts game/src/economy/constants.ts \
        game/tests/economy/energy.test.ts game/src/render/scene/workstation.ts
git commit -m "feat(game): energy module + mug 5-frame binding + burnout flag

energy.ts: cross-day [0,100] resource per ap-economy-system.md energy
section. EnergySystem singleton with onChanged emitter. change(delta)
clamps + sets burnoutFlag at 0. canOvertime() false if burnout OR
below ENERGY_OVERTIME_GUARD. setForRestore for save/load.

workstation.ts: mug sprite removed from STATIC_PROPS, replaced with
5-frame binding subscribed to energy.onChanged. Tier formula:
floor(energy/20), clamped 0..4. tier 4 = full (80-100), tier 0 =
empty (0-19). Same swap pattern as monitor↔KPI.

Constants added: ENERGY_MAX=100, INITIAL=80, OT_BASE=15, EL_BASE=8,
REGEN_PER_DAY=30, OVERTIME_GUARD=15 — all per GDD Rule 7.

Vitest: +11 cases. Total now ~108.

Mug visual now changes based on energy. AFTER_WORK overlay (Task 6)
will call energy.reportOvertime(); confirmRecap will trigger
energy.regenForRestDay() on weekends (Task 5).

Per design/gdd/ap-economy-system.md + design/gdd/hud-diegetic.md.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

---

## Task 3: GameOver → Archive transaction + RunSummary writing + Archive list UI

**Files:**
- Create: `game/src/run-meta/archive.ts`
- Create: `game/src/run-meta/hr-evaluation.ts`
- Create: `game/tests/run-meta/archive.test.ts`
- Create: `game/tests/run-meta/hr-evaluation.test.ts`
- Create: `game/src/render/menu/archive-list.tsx`
- Modify: `game/src/flow/scene-state.ts` (add `archive_list` SceneState)
- Modify: `game/src/flow/transitions.ts` (extend matrix)
- Modify: `game/src/flow/day-cycle.ts` (gameover triggers archive write)
- Modify: `game/src/render/menu/gameover.tsx` (button → archive_list instead of main_menu)
- Modify: `game/src/render/menu/main-menu.tsx` (add 「档案」 button)
- Modify: `game/src/render/ui-overlay.tsx` (route archive_list state)

(This task is large but tightly scoped to the cross-run loop. Implementer may split into sub-commits if helpful.)

- [ ] **Step 3.1: Create `game/src/run-meta/hr-evaluation.ts`**:

```ts
import type { RunState } from '@/save/schema';
import type { GameOverReason } from '@/flow/scene-state';

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
    key = state.kpiActual < state.monthlyThreshold * 0.5
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
  return { key, phrase: HR_EVALUATION_LIBRARY[key] };
}
```

- [ ] **Step 3.2: Create `game/src/run-meta/archive.ts`**:

```ts
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
```

- [ ] **Step 3.3: Write tests** — `game/tests/run-meta/hr-evaluation.test.ts` and `game/tests/run-meta/archive.test.ts`. Sample for archive (cap eviction + HR library accumulation):

```ts
// archive.test.ts
import { describe, expect, it } from 'vitest';
import { appendToArchive, buildRunSummary, removeFromArchive } from '../../src/run-meta/archive';
import { defaultMetaState, defaultRunState, ARCHIVE_HARD_CAP } from '../../src/save/schema';

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
```

Sample for hr-evaluation:

```ts
// hr-evaluation.test.ts
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
    expect(selectHrEvaluation('kpi_exceeds_capacity', defaultRunState()).key).toBe('HR_EVAL_GENERIC');
  });
});
```

- [ ] **Step 3.4: Run tests — expect 7 archive + 6 hr-evaluation = 13 PASS**.

- [ ] **Step 3.5: Add `archive_list` SceneState** to `game/src/flow/scene-state.ts`:

```ts
// Add to the SceneState union:
| { kind: 'archive_list' }
```

Update `describe()` to handle it.

- [ ] **Step 3.6: Update `transitions.ts`** — `archive_list` is reachable from main_menu (player click) and from gameover (auto). Exits to main_menu only.

```ts
if (to.kind === 'archive_list') {
  return from.kind === 'main_menu' || from.kind === 'gameover';
}
// In main_menu case, add archive_list as a legal source:
if (to.kind === 'main_menu') {
  return from.kind === 'action_day' || from.kind === 'pause' || from.kind === 'gameover' || from.kind === 'archive_list';
}
```

Update transitions.test.ts with +4 cases for the new state's legal/illegal pairs.

- [ ] **Step 3.7: Wire GameOver → Archive transaction in `day-cycle.ts`** — modify `confirmKpiReview` so when transitioning to gameover, it ALSO writes archive + meta + clears current_run. Add a new private async method `commitGameOverArchive(reason)` that does:

```ts
async commitGameOverArchive(reason: GameOverReason): Promise<void> {
  const meta = await save.loadMeta();
  const runId = meta.nextRunId;
  const snapshot = snapshotCurrentRunState();  // helper TBD; see Step 3.8
  const summary = buildRunSummary(runId, reason, snapshot);
  await save.writeArchiveSnapshot(runId, snapshot);
  await save.writeMeta(appendToArchive(meta, summary));
  await save.clearCurrentRun();
}
```

This is called BEFORE `flow.request({ kind: 'gameover', ... })` so by the time GameOver renders, the save side is committed.

- [ ] **Step 3.8: Create `game/src/save/snapshot.ts`** — bidirectional with restore.ts:

```ts
import { ap } from '@/economy/ap';
import { kpi } from '@/economy/kpi';
import { energy } from '@/economy/energy';
import { calendar } from '@/flow/calendar';
import { flow } from '@/flow/dispatcher';
import { playedThisDay } from '@/card/play';
import { SCHEMA_VERSION, type RunState } from './schema';

// Snapshots all singleton state into a RunState. Called by autosave hooks
// and by gameover transaction. Inverse of restore.ts.
export function snapshotCurrentRunState(): RunState {
  return {
    schemaVersion: SCHEMA_VERSION,
    apCurrent: ap.current,
    energyCurrent: energy.current,
    energyBurnoutFlag: energy.burnoutFlag,
    kpiActual: kpi.actualKpi,
    monthlyThreshold: kpi.monthlyThreshold,
    monthIndex: kpi.month,
    effortOvertime: ap.effortOvertime,  // Task 4 adds these
    effortHero: ap.effortHero,
    effortOverage: ap.effortOverage,
    currentDay: calendar.currentDay,
    currentWeekday: calendar.currentWeekday,
    playedThisDay: [...playedThisDay],
    sceneState: flow.state as RunState['sceneState'],
  };
}
```

(Note: `ap.effortOvertime` etc. are added in Task 4. For Task 3 the linter will fail; gate Task 3's commit behind Task 4 OR add stub fields to ApSystem now.)

**Decision: stub effort fields on ApSystem in Task 3** so snapshot compiles. Task 4 wires the real reportXxx methods. Add to `ap.ts`:

```ts
// Stub fields for snapshot/restore plumbing; real wiring lands in Task 4.
private _effortOvertime = 0;
private _effortHero = 0;
private _effortOverage = 0;
get effortOvertime(): number { return this._effortOvertime; }
get effortHero(): number { return this._effortHero; }
get effortOverage(): number { return this._effortOverage; }
```

- [ ] **Step 3.9: Build the Archive list UI** at `game/src/render/menu/archive-list.tsx`:

```tsx
import { useEffect, useState } from 'preact/hooks';
import { flow } from '@/flow/dispatcher';
import { HR_EVALUATION_LIBRARY } from '@/run-meta/hr-evaluation';
import { removeFromArchive } from '@/run-meta/archive';
import { type MetaState, type RunSummary } from '@/save/schema';
import { save } from '@/save/system';

const REASON_LABEL: Record<RunSummary['reason'], string> = {
  kpi_exceeds_capacity: '产能溢出',
  dismissal_severe: '严重低于预期',
};

export function ArchiveList(): preact.JSX.Element {
  const [meta, setMeta] = useState<MetaState | null>(null);

  useEffect(() => {
    void save.loadMeta().then(setMeta);
  }, []);

  const goBack = (): void => flow.request({ kind: 'main_menu' });

  const deleteEntry = async (runId: number): Promise<void> => {
    if (!meta) return;
    const next = removeFromArchive(meta, runId);
    await save.writeMeta(next);
    setMeta(next);
  };

  if (!meta) {
    return <div class="menu-root">载入档案中...</div>;
  }

  return (
    <div class="menu-root menu-root--archive">
      <h2 class="menu-title menu-title--small">归档目录 · 共 {meta.archive.length} 条</h2>
      {meta.archive.length === 0 ? (
        <p class="menu-subtitle">暂无归档记录</p>
      ) : (
        <ul class="archive-list">
          {meta.archive.map((entry) => (
            <li key={entry.runId} class="archive-row">
              <div class="archive-row-main">
                <span class="archive-runid">#{entry.runId}</span>
                <span class="archive-month">第 {entry.monthAtDeath} 月</span>
                <span class="archive-reason">{REASON_LABEL[entry.reason]}</span>
              </div>
              <p class="archive-eval">{HR_EVALUATION_LIBRARY[entry.hrEvaluationKey] ?? ''}</p>
              <button
                type="button"
                class="archive-delete"
                onClick={() => void deleteEntry(entry.runId)}
              >
                删除
              </button>
            </li>
          ))}
        </ul>
      )}
      {meta.hrWordLibrary.length > 0 && (
        <details class="archive-library">
          <summary>HR 词库 ({meta.hrWordLibrary.length} 项)</summary>
          <ul>
            {meta.hrWordLibrary.map((k) => (
              <li key={k}>{HR_EVALUATION_LIBRARY[k] ?? k}</li>
            ))}
          </ul>
        </details>
      )}
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={goBack}>
          回主菜单
        </button>
      </div>
    </div>
  );
}
```

- [ ] **Step 3.10: Add CSS for archive list** — append to `game/index.html` `<style>`:

```css
.menu-root--archive { min-width: 480px; max-height: 70vh; overflow-y: auto; }
.archive-list { list-style: none; padding: 0; margin: 0; width: 100%; }
.archive-row { padding: 8px; border-bottom: 1px dashed #3a3d42; }
.archive-row-main { display: flex; gap: 12px; font-size: 12px; }
.archive-runid { color: #c8a85a; font-weight: 700; }
.archive-month { color: #e8e0cc; }
.archive-reason { color: #c83428; }
.archive-eval { font-size: 11px; color: #c4b8a0; margin: 4px 0; line-height: 1.4; }
.archive-delete { background: transparent; border: 1px solid #5a3a18; color: #7a5838; font-size: 11px; padding: 2px 8px; cursor: pointer; }
.archive-delete:hover { color: #c83428; border-color: #c83428; }
.archive-library { width: 100%; margin-top: 12px; color: #7a8088; font-size: 12px; }
.archive-library summary { cursor: pointer; padding: 4px 0; }
```

- [ ] **Step 3.11: Update `gameover.tsx`** — change click target from main_menu to archive_list:

```tsx
const goToArchive = (): void => flow.request({ kind: 'archive_list' });
// in JSX onClick={goToArchive}
// hint text: "点击任意位置查看归档"
```

- [ ] **Step 3.12: Add 「档案」 button to main-menu.tsx** alongside 新游戏 + 继续:

```tsx
const viewArchive = (): void => flow.request({ kind: 'archive_list' });
// add a third button: 档案
```

- [ ] **Step 3.13: Update ui-overlay.tsx** routing — add archive_list case → ArchiveList component. Update OVERLAY_ALLOWED in stage.ts to include archive_list.

- [ ] **Step 3.14: Smoke + verify** — same drill. Total tests now ~121.

- [ ] **Step 3.15: Commit** with detailed body.

---

## Task 4: Effort tracking + Formula B α activation + autosave hooks

Wires `ap.reportOvertime()` / `reportHeroCardPlayed()` / counter resets, replaces stub effort fields with real ones, computes effortNorm in KPI recalc, sets isHero=true on `call_in_sick`, and adds autosave triggers (after every card play + scene state change).

**Files:**
- Modify: `game/src/economy/ap.ts` (real effort counters + report methods + reset)
- Modify: `game/src/economy/kpi.ts` (applyMonthlyRecalc reads ap.effort* into Formula B)
- Modify: `game/src/card/play.ts` (call ap.reportHeroCardPlayed if isHero)
- Modify: `game/src/card/data/defense.ts` (call_in_sick.isHero = true)
- Modify: `game/src/flow/day-cycle.ts` (counter reset + autosave hooks)
- Add tests: `game/tests/economy/ap-effort.test.ts`

(Detailed steps follow same TDD pattern. Estimated: ~1 day work, +10 vitest cases.)

---

## Task 5: 3 new FSM states (MORNING_BRIEFING / AFTER_WORK / ACTION_OVERTIME) + transitions + day-cycle refactor

Adds the missing sub-modes per GDD scene-day-flow-controller. Day-cycle controller drives:
- `MORNING_BRIEFING` (transient) → ACTION_DAY
- ACTION_DAY (AP=0 OR early-leave) → AFTER_WORK
- AFTER_WORK → ACTION_OVERTIME (player chose 加班) OR DAILY_RECAP/KPI_REVIEW
- ACTION_OVERTIME (AP=0) → AFTER_WORK (loop) OR DAILY_RECAP/KPI_REVIEW

**Files:** scene-state.ts, transitions.ts, day-cycle.ts, transitions.test.ts, day-cycle.test.ts.

Adds ~12 transitions test cases + ~6 day-cycle test cases.

---

## Task 6: AFTER_WORK overlay + MORNING_BRIEFING screen + ACTION_OVERTIME wiring

UI for the new states:
- `morning-briefing.tsx`: brief "Day N — 早餐时间" overlay; click to skip.
- `after-work.tsx`: 「申报加班 (-15 energy, +2 AP)」 vs 「按时下班」. 加班 disabled if `!energy.canOvertime()`.
- ACTION_OVERTIME: workstation rendered with AP top capped at 10; 「下班」 button still works.

Plus weekend-rest energy regen: in confirmRecap when entering a weekend day (weekday == 6 || == 7), call `energy.regenForRestDay()`.

---

## Task 7: HR evaluation polish + hr_word_library cross-run accumulation + save corruption dialog

Wires the HR phrase selection on GameOver (already partially done in Task 3); adds the corruption dialog screen if save.loadMeta or save.loadCurrentRun returns lastLoadError; ensures hrWordLibrary survives multiple runs.

---

## Task 8: MONTH_DAYS=30 retune + parameter rebalance + exit verification + tag v0.5.0-p4

Switches `MONTH_DAYS` from 7 to 30. Verify that:
- Energy regen on weekends accumulates ~120/month (4 weekends × 30 regen/day, but weekends are 1-day each per GDD week pattern actually — confirm)
- Overtime ceiling of 20/month is approachable but not trivial
- KPI Formula B threshold growth feels right over a 3-6 month run
- Capacity decay timing feels right

Manual smoke: full run new-game → 月末考核 → death certificate → archive → main menu → 继续 (after restart) shows correct restored state.

Tag `v0.5.0-p4` and update spec §9.2 P4 row.

---

## Self-review checklist

After all 8 tasks:
- [ ] `pnpm verify` from `game/` is green (~140 vitest cases expected)
- [ ] `pnpm tauri build` produces a fresh `.dmg`
- [ ] Save/load works across .app restart (controller verifies manually)
- [ ] GameOver writes archive entry; Archive list shows it; delete works
- [ ] Mug sprite changes with energy; AFTER_WORK overlay correctly gates overtime on energy
- [ ] Effort counters increment on overtime + hero card; KPI threshold growth rate visibly higher than P3 with effort high
- [ ] `v0.5.0-p4` tagged + pushed

## Notes for Claude when executing

- **Save module is foundational** — Tasks 4-7 all autosave through `save.writeCurrentRun(snapshotCurrentRunState())`. Don't add the autosave call until the snapshot helper compiles (after Task 3 stubs the effort fields on ApSystem).
- **Task 1's restore.ts is intentionally minimal** — Task 4 replaces it with proper `setForRestore` methods. Don't try to make Task 1's restore complete.
- **Energy + mug binding (Task 2) is independent** of save plumbing — can be implemented before or after Task 1; the autosave in Task 4 picks it up.
- **The 3 new FSM states (Task 5) collide with Task 3's archive_list**. Make sure both rounds of transitions.ts edits coexist cleanly.
- **MONTH_DAYS=30 retune (Task 8)** is the LAST thing — don't switch midway, otherwise tests in Tasks 4-7 may flake on tight timing assumptions.
- **Audio is OUT OF SCOPE for P4.** Resist the urge to add audio anchors in KPI Review even though they'd be cool. P5 is the dedicated audio pass.
