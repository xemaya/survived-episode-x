# Asset Specs — System: Scene & Day Flow Controller

> **Source**: design/gdd/scene-day-flow-controller.md (Section A 8 sub-mode enum + Rule 13 三轨铁三角 + KPI Review 800ms anchor)
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 8 audio assets specced / 0 in production / 0 done / 0 approved
> **Mode**: solo (audio-director not consulted; sonic character only)

> Coverage: 8 sub-mode transition stinger SFX (mostly NOT applied — sub-mode transitions are silent per Pillar 4) + KPI Review 三轨 800ms anchor SFX + GAMEOVER 1500ms transition closing chord. Per Audio Manager Rule 6 + Pillar 4 守门: most sub-mode transitions use ambient crossfade, NOT stingers. This spec documents the FEW transitions that DO get audio cues.

---

## ASSET-165 — SFX.SUBMODE.MORNING_BRIEFING_OPEN (早晨预告 sub-mode 进入)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.4 s) |
| Format | WAV 16-bit (~30 KB) |
| Naming | `assets/audio/sfx/submode_morning_briefing_open.wav` |

**Sonic Character**:
A single soft folder-tap sound when MORNING_BRIEFING enters from MAIN_MENU. ~400 ms. Frequency: 200-800 Hz folder/paper tap. Used as a quiet bookmark cue, not a fanfare. Per Rule 6: ambient crossfade is primary; this is supplementary punctuation.

**Tone Brief**: Bureaucratic "let's begin" without ceremony. NO chime. NO uplifting note.

**Status**: Needed (subtle)
**Referenced by**: scene-day-flow-controller, audio-manager

---

## ASSET-166 — SFX.SUBMODE.AFTER_WORK_OPEN (下班抉择 sub-mode 进入)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.5 s) |
| Format | WAV 16-bit (~40 KB) |
| Naming | `assets/audio/sfx/submode_after_work_open.wav` |

**Sonic Character**:
Workplace clock-tower distant chime (single tone, NOT melodic) ~500 ms. Frequency: distant ~600 Hz bell with heavy low-pass. Per art-bible §2.4 "下班抉择拉锯窒息" — this is the ONE moment per day where the audio acknowledges time passing. Heavy reverb suggests distance.

**Tone Brief**: Like a building's old PA system clicking on briefly. NOT victory bell.

**Status**: Needed
**Referenced by**: scene-day-flow-controller, audio-manager

---

## ASSET-167 — SFX.KPIREVIEW.ANCHOR_TRACK1_PUNCH_CLOCK_AT_T800

| Field | Value |
|-------|-------|
| Category | SFX (sequenced) |
| Format | WAV 16-bit (~30 KB, plays at exactly t=800 ms after KPI_REVIEW transition) |
| Naming | `assets/audio/sfx/kpireview_anchor_t800_punchclock.wav` |
| Source | Reuses ASSET-132 PUNCH_CLOCK_CLACK_BUREAUCRATIC, scheduled at exact 800 ms anchor |

**Sonic Character**:
Per Rule 13 三轨铁三角 800ms anchor: at exactly t=800 ms after `KPI_REVIEW` sub-mode entry, ASSET-132 (punch clock clack) fires. This is one of three synchronized tracks (audio + visual + localization) all anchored to 800 ms. Anchor enforces simultaneous tone: text reveal + visual stamp animation + this sound all within ±50 ms.

**Status**: Needed (config — uses ASSET-132 file, exact-timing scheduler)
**Referenced by**: scene-day-flow-controller, kpi-review-game-over-ui, audio-manager

---

## ASSET-168 — SFX.KPIREVIEW.ANCHOR_TRACK2_RECEIPT_AT_T1000

| Field | Value |
|-------|-------|
| Category | SFX (sequenced) |
| Format | WAV 16-bit (uses ASSET-133, scheduled at t=1000 ms) |
| Naming | (config reuse — see ASSET-133) |

**Sonic Character**:
RECEIPT_THERMAL_HISS_BUREAUCRATIC fires at t=1000 ms after KPI Review entry, beginning its 2 s hiss. Concurrently ducks Ambient -6 dB per Rule 1. The hiss completes at t=3000 ms, ambient duck releases at t=3800 ms (per `ambient_duck_release_ms` 800 ms tail).

**Status**: Needed (config — schedule ASSET-133)
**Referenced by**: scene-day-flow-controller, kpi-review-game-over-ui, audio-manager

---

## ASSET-169 — SFX.GAMEOVER.TRANSITION_CHORD_AT_T1500

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~3.0 s sustain) |
| Format | OGG q=4 (~120 KB) |
| Naming | `assets/audio/sfx/gameover_transition_chord_t1500.ogg` |

**Sonic Character**:
Single sustained low chord at the start of GAMEOVER 1500 ms transition (Rule 5, Save Rule 21 lock). Sustained ~3 s tail extending past transition. Per art-bible §2.6 "尘埃落定" — somber, NOT tragic. Pitches in `#3A3050` deep blue-gray tonal equivalent (~A2 + E3 + C3, low-density). NO crescendo. NO climax.

**Tone Brief**: A door closing in a long corridor. The sound of "this is over." NO emotional punctuation.

**Status**: Needed (CRITICAL — GAMEOVER tone anchor)
**Referenced by**: scene-day-flow-controller, kpi-review-game-over-ui, audio-manager

---

## ASSET-170 — SFX.PAUSE.OPEN_CLOSE_INTENTIONALLY_OMITTED

| Field | Value |
|-------|-------|
| Category | NOT NEEDED |

**Sonic Character**:
**Per main-menu-pause-settings-ui Rule + Audio Rule 9**: Pause / Settings 打开 / 关闭 ZERO SFX. This negative spec confirms no asset to be produced — Pause sub-mode entry is SILENT. Documented to prevent scope creep.

**Status**: NOT NEEDED (negative spec)
**Referenced by**: scene-day-flow-controller, audio-manager, main-menu-pause-settings-ui

---

## ASSET-171 — Anchor Timing Configuration Resource

| Field | Value |
|-------|-------|
| Category | Configuration |
| Format | `.tres` Resource |
| Naming | `assets/data/scene_anchor_timings.tres` |

**Sonic Character**:
N/A — config resource holding all sub-mode anchor offsets:
- KPI_REVIEW entry: track1 at 800 ms (PUNCH_CLOCK), track2 at 1000 ms (RECEIPT)
- GAMEOVER entry: chord at 0 ms, transition fade lock 1500 ms (`final_transition_duration_ms`)
- DAILY_RECAP entry: NONE (text-reveal handles its own timing)
- AFTER_WORK entry: ASSET-166 at 0 ms

**Status**: Needed (config)
**Referenced by**: scene-day-flow-controller, audio-manager, kpi-review-game-over-ui

---

## ASSET-172 — SFX.SUBMODE.DAILY_RECAP_OPEN (今日总结进入)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.3 s) |
| Format | WAV 16-bit (~25 KB) |
| Naming | `assets/audio/sfx/submode_daily_recap_open.wav` |

**Sonic Character**:
Subtle tear-paper sound — like ripping today's page from a desk calendar. ~300 ms. Used as the daily recap open punctuation when sub-mode shifts to DAILY_RECAP. Per ambient transition rule: KEYBOARD_RHYTHM crossfades out 1 s while this single tear plays.

**Tone Brief**: Day is over. NOT triumphant. Anchor: tearing yesterday's page off a calendar.

**Status**: Needed
**Referenced by**: scene-day-flow-controller, daily-weekly-recap-ui, audio-manager
