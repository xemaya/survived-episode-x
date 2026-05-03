# Asset Manifest

> Last updated: 2026-05-01
> Mode: solo (art-director + technical-artist + audio-director not consulted in batch generation)
> Phase: Pre-Production / Phase 4 (asset spec authoring before production)

## Progress Summary

| Total | Needed | In Progress | Done | Approved |
|-------|--------|-------------|------|----------|
| 172 | 172 | 0 | 0 | 0 |

> **Asset breakdown by category**:
> - Sprite (Visual): 92
> - Audio (SFX/Ambient/Music): 30
> - UI (overlays / frames): 28
> - Configuration / Tool / Theme: 22

> **Cross-reference reuse count**: 11 assets are pure cross-references to others (e.g. ASSET-027 → ASSET-020, ASSET-094 → ASSET-049 scaled). True unique-asset count: 161.

> **Negative specs (deliberately not produced)**: 2 (ASSET-153, ASSET-170 — pause/menu UI silence enforcement).

---

## Spec Files

| Spec File | Asset Range | System | Asset Count |
|-----------|-------------|--------|-------------|
| `specs/hud-diegetic-assets.md` | ASSET-001 to ASSET-022 | hud-diegetic | 22 |
| `specs/lighting-visual-state-assets.md` | ASSET-023 to ASSET-040 | lighting-visual-state | 18 |
| `specs/card-play-dialogue-ui-assets.md` | ASSET-041 to ASSET-064 | card-play-dialogue-ui | 24 |
| `specs/npc-relationship-system-assets.md` | ASSET-065 to ASSET-076 | npc-relationship-system | 12 |
| `specs/kpi-review-game-over-ui-assets.md` | ASSET-077 to ASSET-092 | kpi-review-game-over-ui | 16 |
| `specs/main-menu-pause-settings-ui-assets.md` | ASSET-093 to ASSET-107 | main-menu-pause-settings-ui | 14 (15 IDs, ASSET-101 cross-ref) |
| `specs/notification-warning-system-assets.md` | ASSET-108 to ASSET-112 | notification-warning-system | 5 |
| `specs/daily-weekly-recap-ui-assets.md` | ASSET-113 to ASSET-124 | daily-weekly-recap-ui | 12 |
| `specs/audio-manager-assets.md` | ASSET-125 to ASSET-154 | audio-manager | 30 |
| `specs/event-script-engine-assets.md` | ASSET-155 to ASSET-164 | event-script-engine | 10 |
| `specs/scene-day-flow-controller-assets.md` | ASSET-165 to ASSET-172 | scene-day-flow-controller | 8 |
| **TOTAL** | **ASSET-001 to ASSET-172** | **11 systems** | **172** |

---

## Skipped Targets

P3 logic-only systems were evaluated and skipped (no Visual/Audio Requirements section content per `/asset-spec` skip rule, or fully covered by cross-references):
- `save-system` — pure data/serialization
- `input-handler` — Section G zero audio per Audio Manager Rule 11 (cross-system tone decoupling)
- `localization-hooks` — zero audio per Rule 11
- `accessibility-options` — VS scope, not yet asset-rich
- `ap-economy-system` — no own visuals; consumed by hud-diegetic
- `npc-relationship-system` — partially specced; reuses ASSET-010/011/012 from hud-diegetic, additional in npc-relationship-system-assets.md
- `kpi-reverse-threshold-system` — no own visuals; consumed by kpi-review-game-over-ui (ASSET-007/077-091)
- `tutorial-onboarding-system` — VS scope, not asset-defined yet
- `run-meta-system` — administrative; reuses ASSET-083-091 archive UI
- `action-card-system` — face/icons specced under card-play-dialogue-ui (ASSET-044/063); per-card content owned by action-card-system itself once full card list exists

---

## Cross-Target Shared Assets

These assets are specced once but referenced by multiple systems (per task brief: "不要重复 spec — 第二个 target 引用第一个 ASSET-NNN 即可"):

| Asset ID | Owner Spec File | Referenced By Systems |
|----------|----------------|----------------------|
| ASSET-007 (Monitor Data Variants) | hud-diegetic | hud-diegetic, kpi-review-game-over-ui, notification-warning-system |
| ASSET-008 (Attendance Board) | hud-diegetic | hud-diegetic, lighting-visual-state, notification-warning-system |
| ASSET-010 (NPC Expression 8×4) | hud-diegetic | hud-diegetic, npc-relationship-system, card-play-dialogue-ui, kpi-review-game-over-ui |
| ASSET-011 (NPC Position 8×4) | hud-diegetic | hud-diegetic, npc-relationship-system, card-play-dialogue-ui |
| ASSET-012 (Empty Chair) | hud-diegetic | hud-diegetic, npc-relationship-system, lighting-visual-state |
| ASSET-014 (Numeric Flash Caption) | hud-diegetic | hud-diegetic, notification-warning-system, event-script-engine |
| ASSET-016 (Anniversary Banner) | hud-diegetic | hud-diegetic, lighting-visual-state |
| ASSET-017 (Notice Board Aging) | hud-diegetic | hud-diegetic, lighting-visual-state |
| ASSET-020 (Desk Stain Cumulative) | hud-diegetic | hud-diegetic, lighting-visual-state |
| ASSET-024 (Palette Swap Shader) | lighting-visual-state | lighting-visual-state, all NPC/env sprites |
| ASSET-025 (Palette LUT Atlas) | lighting-visual-state | lighting-visual-state, ASSET-024 |
| ASSET-049 (Choice Button 4 states) | card-play-dialogue-ui | card-play-dialogue-ui, event-script-engine, kpi-review-game-over-ui (Settings + Archive), main-menu-pause-settings-ui |
| ASSET-119 (Skip Hint Strip) | daily-weekly-recap-ui | daily-weekly-recap-ui, kpi-review-game-over-ui |
| ASSET-132 (PUNCH_CLOCK_CLACK_BUREAUCRATIC) | audio-manager | audio-manager, kpi-review-game-over-ui, scene-day-flow-controller (anchor t=800 ms) |
| ASSET-133 (RECEIPT_THERMAL_HISS_BUREAUCRATIC) | audio-manager | audio-manager, kpi-review-game-over-ui, scene-day-flow-controller (anchor t=1000 ms) |

---

## Assets by Context

### System: hud-diegetic (22 assets, ASSET-001 to ASSET-022)

| Asset ID | Name | Category | Status | Spec File | Referenced By |
|----------|------|----------|--------|-----------|---------------|
| ASSET-001 | Sticky Note Default | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, lighting-visual-state |
| ASSET-002 | Sticky Note Crossed-Out | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic |
| ASSET-003 | Sticky Note Overtime | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic |
| ASSET-004 | Sticky Note Folded Corner | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic |
| ASSET-005 | Coffee Cup Liquid States 5 variants | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, lighting-visual-state |
| ASSET-006 | Coffee Stain Ring | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic |
| ASSET-007 | Monitor Data Display 5 variants | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, kpi-review-game-over-ui, notification-warning-system |
| ASSET-008 | Attendance Board 8 variants | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, lighting-visual-state, notification-warning-system |
| ASSET-009 | Desk Calendar 24×24 | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, daily-weekly-recap-ui |
| ASSET-010 | NPC Expression 8×4 atlas | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, npc-relationship-system, card-play-dialogue-ui, kpi-review-game-over-ui |
| ASSET-011 | NPC Position 8×4 atlas | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, npc-relationship-system, card-play-dialogue-ui |
| ASSET-012 | Empty Chair (LEFT) | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, npc-relationship-system, lighting-visual-state |
| ASSET-013 | Sticky Note Lifecycle Atlas | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic |
| ASSET-014 | Numeric-Only Flash Caption | UI/Theme | Needed | specs/hud-diegetic-assets.md | hud-diegetic, notification-warning-system, event-script-engine |
| ASSET-015 | Workstation Desk Surface | Environment | Needed | specs/hud-diegetic-assets.md | hud-diegetic |
| ASSET-016 | Anniversary Banner Variant | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, lighting-visual-state |
| ASSET-017 | Notice Board Aging 4 variants | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, lighting-visual-state |
| ASSET-018 | HUD Z-Layer Configuration | Configuration | Needed | specs/hud-diegetic-assets.md | hud-diegetic |
| ASSET-019 | Active Workstation Chair | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, npc-relationship-system |
| ASSET-020 | Desk Stain Cumulative 5 levels | Sprite | Needed | specs/hud-diegetic-assets.md | hud-diegetic, lighting-visual-state |
| ASSET-021 | Monitor Bezel Frame | Environment | Needed | specs/hud-diegetic-assets.md | hud-diegetic |
| ASSET-022 | HUD Boundary Marker (debug) | Sprite (debug) | Needed | specs/hud-diegetic-assets.md | hud-diegetic |

### System: lighting-visual-state (18 assets, ASSET-023 to ASSET-040)

| Asset ID | Name | Category | Status | Spec File |
|----------|------|----------|--------|-----------|
| ASSET-023 | CanvasModulate 8 sub-mode preset | Configuration | Needed | specs/lighting-visual-state-assets.md |
| ASSET-024 | Palette Swap Shader | Shader | Needed | specs/lighting-visual-state-assets.md |
| ASSET-025 | Palette LUT Atlas 8×N | LUT | Needed | specs/lighting-visual-state-assets.md |
| ASSET-026 | Dither Overlay Shader | Shader | Needed | specs/lighting-visual-state-assets.md |
| ASSET-027 | Desk Stain (cross-ref ASSET-020) | Sprite | Cross-ref | specs/lighting-visual-state-assets.md |
| ASSET-028 | Notice Board Aging (cross-ref ASSET-017) | Sprite | Cross-ref | specs/lighting-visual-state-assets.md |
| ASSET-029 | Break Room Crack 4 levels | Sprite | Needed | specs/lighting-visual-state-assets.md |
| ASSET-030 | Anniversary Banner (cross-ref ASSET-016) | Sprite | Cross-ref | specs/lighting-visual-state-assets.md |
| ASSET-031 | Boss Office Fake Plant | Sprite | Needed | specs/lighting-visual-state-assets.md |
| ASSET-032 | Tea Room Water Sign-In | Sprite | Needed | specs/lighting-visual-state-assets.md |
| ASSET-033 | Hallway Delivery Box 2 variants | Sprite | Needed | specs/lighting-visual-state-assets.md |
| ASSET-034 | Meeting Room Whiteboard 4 layers | Sprite | Needed | specs/lighting-visual-state-assets.md |
| ASSET-035 | CanvasModulate Tween Easing Config | Configuration | Needed | specs/lighting-visual-state-assets.md |
| ASSET-036 | Tonemapper Configuration | Configuration | Needed | specs/lighting-visual-state-assets.md |
| ASSET-037 | Steam Particle | VFX | Needed (VS) | specs/lighting-visual-state-assets.md |
| ASSET-038 | Dust Mote Particle | VFX | Needed (VS) | specs/lighting-visual-state-assets.md |
| ASSET-039 | Fluorescent Light Tube | Environment | Needed | specs/lighting-visual-state-assets.md |
| ASSET-040 | Boss Office Purple Edge Light | Sprite | Needed | specs/lighting-visual-state-assets.md |

### System: card-play-dialogue-ui (24 assets, ASSET-041 to ASSET-064)

| Asset ID | Name | Category | Status |
|----------|------|----------|--------|
| ASSET-041 | NPC Event CG 8×2 emotions = 16 | Sprite (CG) | Needed (BLOCKING — OQ-CPU-01) |
| ASSET-042 | NPC Interactive Portrait 8 | Sprite | Needed |
| ASSET-043 | Card Background 3 AP variants | UI | Needed |
| ASSET-044 | Card Front Face | UI | Needed |
| ASSET-045 | Card Selected/Hover Overlay | UI | Needed |
| ASSET-046 | Card Disabled Overlay | UI | Needed |
| ASSET-047 | Dialogue Background Frame 9-slice | UI | Needed |
| ASSET-048 | Dialogue Speaker Name Plate | UI | Needed |
| ASSET-049 | Choice Button 4 states | UI | Needed |
| ASSET-050 | AP Slot Icons 2 variants | UI | Needed |
| ASSET-051 | Card Hand Layout | UI | Needed |
| ASSET-052 | Long Event Letterbox Frame | UI | Needed |
| ASSET-053 | Choice Indicator Bullet | UI | Needed |
| ASSET-054 | Card Played Animation 4 frames | UI | Needed |
| ASSET-055 | Long Event Background Wash | Color | Needed |
| ASSET-056 | Card Empty Slot Placeholder | UI | Needed |
| ASSET-057 | Dialogue Continue Indicator | UI | Needed |
| ASSET-058 | Speaker Portrait Frame | UI | Needed |
| ASSET-059 | NPC LEAVING_ANNOUNCED CG | Sprite | Deferred (OQ-CPU-05) |
| ASSET-060 | Subject-Inversion Lint Reference | Localization | N/A |
| ASSET-061 | Card Hand Disabled Background | UI | Needed |
| ASSET-062 | Numeric Only Flash Cross-Ref | Cross-ref ASSET-014 | Cross-ref |
| ASSET-063 | Card Front Generic Icons 10 | UI Icon | Needed |
| ASSET-064 | Hand Card Container Theme | Theme | Needed |

### System: npc-relationship-system (12 assets, ASSET-065 to ASSET-076)

| Asset ID | Name | Category | Status |
|----------|------|----------|--------|
| ASSET-065 | NPC ACTIVE State (cross-ref ASSET-011) | Sprite | Cross-ref |
| ASSET-066 | NPC LEAVING_ANNOUNCED Overlay 8 | Sprite | Needed |
| ASSET-067 | NPC LEFT Empty Chair (cross-ref ASSET-012) | Sprite | Cross-ref |
| ASSET-068 | NPC RETURNED Marker (VS) | Sprite | Deferred (VS) |
| ASSET-069 | NPC Clothing Color Variants 8 | LUT | Needed |
| ASSET-070 | NPC Walking Cycle 8×4 | Sprite | Needed |
| ASSET-071 | NPC Idle Sit/Stand 8×2 | Sprite | Needed |
| ASSET-072 | NPC 喜丧 Trigger 8×2 | Sprite | Needed (CRITICAL) |
| ASSET-073 | LEFT Workplace Cleared Desk | Sprite | Needed |
| ASSET-074 | NPC Lifecycle Visual Map | Configuration | Needed |
| ASSET-075 | NPC Talk Animation 8×2 | Sprite | Needed |
| ASSET-076 | Skin Palette Base LUT | Palette | Needed |

### System: kpi-review-game-over-ui (16 assets, ASSET-077 to ASSET-092)

| Asset ID | Name | Category | Status |
|----------|------|----------|--------|
| ASSET-077 | KPI Review Screen Background | UI | Needed |
| ASSET-078 | KPI Breakdown 3-Row Panel | UI | Needed |
| ASSET-079 | Capacity vs Threshold Display | UI | Needed |
| ASSET-080 | GAMEOVER Certificate Background | UI | Needed |
| ASSET-081 | Termination Stamp "恭喜晋升" | UI | Needed |
| ASSET-082 | KPI Confirm Button (cross-ref ASSET-049) | UI | Cross-ref |
| ASSET-083 | Archive List Row | UI | Needed |
| ASSET-084 | Archive Screen Background | UI | Needed |
| ASSET-085 | Archive Cap-Reached Banner | UI | Needed |
| ASSET-086 | Archive Delete Confirm Dialog | UI | Needed |
| ASSET-087 | KPI Transition Fade Overlay | UI | Needed |
| ASSET-088 | Settlement Locked Indicator | UI | Needed |
| ASSET-089 | Run Summary Detail Panel | UI | Deferred (VS) |
| ASSET-090 | KPI Skippable Indicator | UI | Needed |
| ASSET-091 | HR Word Library Submenu | UI | Needed |
| ASSET-092 | KPI 三轨 anchor SFX (cross-ref) | Audio | Cross-ref to scene-day-flow-controller |

### System: main-menu-pause-settings-ui (15 assets, ASSET-093 to ASSET-107)

| Asset ID | Name | Category | Status |
|----------|------|----------|--------|
| ASSET-093 | Main Menu Background | UI | Needed |
| ASSET-094 | Main Menu Buttons (cross-ref ASSET-049) | UI | Cross-ref |
| ASSET-095 | Pause Overlay Background | UI | Needed |
| ASSET-096 | Settings Screen Background | UI | Needed |
| ASSET-097 | Settings Group Panel Frame | UI | Needed |
| ASSET-098 | Volume Slider | UI | Needed |
| ASSET-099 | Locale Selector Dropdown | UI | Needed |
| ASSET-100 | Narrative Density Toggle | UI | Needed |
| ASSET-101 | Remap Background (cross-ref ASSET-096) | UI | Cross-ref |
| ASSET-102 | Keymap Row | UI | Needed |
| ASSET-103 | Keyboard Key Atlas ~50 | UI | Needed |
| ASSET-104 | Reset Defaults Button (cross-ref ASSET-049) | UI | Cross-ref |
| ASSET-105 | Confirm Quit Dialog (reuse ASSET-086) | UI | Cross-ref |
| ASSET-106 | Tooltip Sprite | UI | Needed |
| ASSET-107 | Settings Group Icons 4 | UI Icon | Needed |

### System: notification-warning-system (5 assets, ASSET-108 to ASSET-112)

| Asset ID | Name | Category | Status |
|----------|------|----------|--------|
| ASSET-108 | Sticky Note Notification 3-frame pulse | Sprite | Needed |
| ASSET-109 | Monitor Warning Variant (cross-ref ASSET-007) | Sprite | Cross-ref |
| ASSET-110 | Attendance KPI_REVIEW (cross-ref ASSET-008) | Sprite | Cross-ref |
| ASSET-111 | Numeric Flash (cross-ref ASSET-014) | UI | Cross-ref |
| ASSET-112 | NPC Expression Cue (cross-ref ASSET-010) | Sprite | Cross-ref |

### System: daily-weekly-recap-ui (12 assets, ASSET-113 to ASSET-124)

| Asset ID | Name | Category | Status |
|----------|------|----------|--------|
| ASSET-113 | Daily Recap Background | UI | Needed |
| ASSET-114 | Weekly Recap Background | UI | Needed |
| ASSET-115 | HR Header Strip | UI | Needed |
| ASSET-116 | Effort 3-Dimension Visualization | UI | Needed |
| ASSET-117 | Event List Row | UI | Needed |
| ASSET-118 | KPI Prediction Reference Strip | UI | Needed |
| ASSET-119 | Skip Hint Strip | UI | Needed |
| ASSET-120 | Daily Recap Body Container | UI | Needed |
| ASSET-121 | Weekly Recap Body Container | UI | Needed |
| ASSET-122 | Recap Fade-In Animation | UI | Needed (programmatic) |
| ASSET-123 | AP/Energy Daily Summary Row | UI | Needed |
| ASSET-124 | Recap Calendar Mini Glyph | UI Icon | Needed |

### System: audio-manager (30 assets, ASSET-125 to ASSET-154)

| Asset ID | Name | Category | Status |
|----------|------|----------|--------|
| ASSET-125 | Bus Configuration default.tres | Configuration | Needed |
| ASSET-126 | FLUORESCENT_HUM ambient loop | Audio | Needed |
| ASSET-127 | AC_LOW_HISS ambient loop | Audio | Needed |
| ASSET-128 | KEYBOARD_RHYTHM ambient loop | Audio | Needed |
| ASSET-129 | SCREEN_BUZZ_OVERTIME ambient | Audio | Needed |
| ASSET-130 | PHONE_THREE_RINGS oneshot | Audio | Needed |
| ASSET-131 | MAIN_MENU_AMBIENT premix | Audio | Needed |
| ASSET-132 | PUNCH_CLOCK_CLACK_BUREAUCRATIC | Audio | Needed (CRITICAL) |
| ASSET-133 | RECEIPT_THERMAL_HISS_BUREAUCRATIC | Audio | Needed (CRITICAL) |
| ASSET-134 | ENDGAME_LETTER_PRINT | Audio | Needed |
| ASSET-135 | HERO_CARD_PLAYED | Audio | Needed |
| ASSET-136 | STANDARD_CARD_PLAYED 3 variants | Audio | Needed |
| ASSET-137 | TYPING_KEYSTROKE 3 variants | Audio | Needed |
| ASSET-138 | PAPER_RUSTLE 3 variants | Audio | Needed |
| ASSET-139 | COFFEE_SIP | Audio | Needed |
| ASSET-140 | AP_SLOT_CROSS pencil scratch | Audio | Needed |
| ASSET-141 | NPC_DIALOG_OPEN | Audio | Needed |
| ASSET-142 | OFFICE_CHAIR_PUSH | Audio | Needed |
| ASSET-143 | OFFICE_PHONE_HANG_UP | Audio | Needed |
| ASSET-144 | OFFICE_DOOR_CLOSE | Audio | Needed |
| ASSET-145 | OFFICE_STAPLE_THUNK | Audio | Needed |
| ASSET-146 | KPIREVIEW_ENDGAME_LOOP_BUREAUCRATIC | Audio | Needed (CRITICAL) |
| ASSET-147 | GAMEOVER_CREDITS_OUTRO_BUREAUCRATIC | Audio | Needed (CRITICAL) |
| ASSET-148 | audio_lint.gd Tool | Tool | Needed |
| ASSET-149 | Crossfade Configuration | Configuration | Needed |
| ASSET-150 | Bus Default Volume Resource | Configuration | Needed |
| ASSET-151 | Audio Brief Templates 5 _BUREAUCRATIC | Documentation | Needed |
| ASSET-152 | Farewell SFX (cross-ref) | Cross-ref to event-script-engine | Cross-ref |
| ASSET-153 | UI Menu Focus SFX (NEGATIVE SPEC) | NOT NEEDED | Negative |
| ASSET-154 | Audio Bank Size Audit CI | CI | Needed |

### System: event-script-engine (10 assets, ASSET-155 to ASSET-164)

| Asset ID | Name | Category | Status |
|----------|------|----------|--------|
| ASSET-155 | LISA_GOODBYE_NUMERIC | Audio | Needed (CRITICAL) |
| ASSET-156 | CLEANING_AUNT_LEAVE_NUMERIC | Audio | Needed |
| ASSET-157 | FISH_MONK_LAID_OFF_NUMERIC | Audio | Needed |
| ASSET-158 | SYCOPHANT_TRANSFER_NUMERIC | Audio | Needed |
| ASSET-159 | OLD_HAND_RETIRES_NUMERIC | Audio | Needed |
| ASSET-160 | FLASH_OVERLAY_PUNCTUATION | Audio | Needed |
| ASSET-161 | LONG_DIALOG_PARAGRAPH_BREATHE | Audio | Needed |
| ASSET-162 | NUMERIC_ONLY_TICK | Audio | Needed |
| ASSET-163 | event_lint.gd Audio Coverage | Tool | Needed |
| ASSET-164 | Audio Brief Templates 5 farewell | Documentation | Needed |

### System: scene-day-flow-controller (8 assets, ASSET-165 to ASSET-172)

| Asset ID | Name | Category | Status |
|----------|------|----------|--------|
| ASSET-165 | MORNING_BRIEFING_OPEN | Audio | Needed |
| ASSET-166 | AFTER_WORK_OPEN distant chime | Audio | Needed |
| ASSET-167 | KPI Track1 punch clock t=800 ms | Audio (config) | Needed (uses ASSET-132) |
| ASSET-168 | KPI Track2 receipt t=1000 ms | Audio (config) | Needed (uses ASSET-133) |
| ASSET-169 | GAMEOVER_TRANSITION_CHORD t=1500 | Audio | Needed (CRITICAL) |
| ASSET-170 | Pause Open/Close SFX (NEGATIVE SPEC) | NOT NEEDED | Negative |
| ASSET-171 | Anchor Timing Configuration | Configuration | Needed |
| ASSET-172 | DAILY_RECAP_OPEN tear paper | Audio | Needed |

---

## Critical / Blocking Issues (surface for producer)

1. **OQ-CPU-01 BLOCKING — NPC CG Asset Production Scope**: ASSET-041 alone is 16 high-detail 128×192 portraits. art-bible §5.5 caps single-dev 3-month output at 16 张/NPC TOTAL (including walks/sits/CG). Current spec for 8 NPCs implies ~20-24 张/NPC (CG×2 + portrait + 4 positions + 4 expressions + walks + idle + 喜丧×2). **Producer must validate scope or reduce CG count to 1/NPC + reuse expressions**.

2. **OQ-CPU-05 deferred — NPC LEAVING_ANNOUNCED CG variants**: ASSET-059 deferred. If implemented, adds 8 portraits to art budget. If not, reuses ASSET-041 with `self_modulate` desaturation.

3. **OQ-AUD-defer — Music license**: ASSET-146 (KPI_REVIEW_LOOP) and ASSET-147 (GAMEOVER_CREDITS) require either self-composition OR Freesound Pro license. License decision pending.

4. **Audio total volume estimate**: 30 audio assets at average ~50 KB each ≈ 1.5 MB on disk; memory ~3 MB after decompression. Well within 30 MB hard cap (`audio_bank_total_size_mb`). PASS.

5. **Cross-system shared assets (15 entries)**: Producer must coordinate art-director assignment so the OWNER spec file's asset is produced FIRST (e.g. ASSET-007, ASSET-010, ASSET-049 are blocking dependencies for 2-3 other systems).

---

## Art Bible Anchors Coverage (sanity check)

Sections cross-referenced across all spec files:
- §2.1-2.6 Mood references → ASSET-023, 077, 080, 093, 095, 113
- §3.1-3.4 Shape Language → ASSET-001 through ASSET-022 (UI shapes), 041-042 (silhouettes)
- §4.1-4.6 Color System → all sprite/UI specs
- §5.1-5.5 Character Design → ASSET-010, 011, 041-042, 065-076 (all NPC assets)
- §6.1-6.5 Environment Design → ASSET-015, 023, 029-040, 113-114
- §7.1-7.6 UI/HUD Visual Direction → all UI/Diegetic specs
- §8.1-8.11 Asset Standards → ASSET-018 (z-layer), 023-026 (CanvasModulate/Shaders), 035-036 (Tween/Tonemapper), 148, 154 (audio CI gates)

No major art-bible vs GDD contradictions surfaced during spec generation.

---

## Phase 4 Production Readiness

This manifest plus the 11 spec files complete the **/asset-spec system:* batch run**. Outputs are ready for:
- art-director: review of all `Sprite/UI/Environment` assets before Phase 4 production kickoff
- audio-director + sound-designer: review of all `Audio` assets and the 10 `_BUREAUCRATIC` + farewell briefs (ASSET-151, ASSET-164) for tone verification
- producer: validate OQ-CPU-01 scope risk before art production assignments
- technical-artist: validate ASSET-024 (palette swap shader), ASSET-026 (dither overlay shader), ASSET-018 (z-layer config) compile correctly in Godot 4.6
- godot-shader-specialist: confirm ASSET-024/025/026 align with art-bible §8.4 and Godot 4.6 Shader Baker requirements
- localization-lead: cross-check ASSET-014, ASSET-060, ASSET-100 (density toggle) for `_IRONY` / `_BUREAUCRATIC` / subject inversion lint coverage

Solo mode means art-director + technical-artist + audio-director have NOT signed off on these specs. **Recommended next step**: each domain lead reviews their spec file and either approves or requests revision before any production work begins.
