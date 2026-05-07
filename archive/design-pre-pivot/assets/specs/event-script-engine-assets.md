# Asset Specs — System: Event Script Engine

> **Source**: design/gdd/event-script-engine.md (Rule 23 FAREWELL_EVENT_IDS + Rule 5/6 三档密度 + numeric_only audio cue 替代 BGM 切)
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 10 audio assets specced / 0 in production / 0 done / 0 approved
> **Mode**: solo (audio-director not consulted; sonic character only)

> Coverage: 5 farewell events 替代 BGM 切的 numeric_only 配套音效 + flash event SFX cue (≤ 3 s overlay) + long event 段落 SFX (paper / chair / sigh / etc.). Per Rule 23 守门: farewell SFX MUST NOT trigger BGM swap; uses ambient continuity + minimal SFX punctuation.

---

## ASSET-155 — SFX.FAREWELL.LISA_GOODBYE_NUMERIC (Lisa 离别 numeric_only 音效)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~1.5 s) |
| Format | WAV 16-bit (~80 KB) |
| Naming | `assets/audio/sfx/farewell_lisa_goodbye_numeric.wav` |

**Sonic Character**:
A single soft chair-roll backwards + light footsteps fading into the hallway. NO door close (door close is for ASSET-144 generic). NO music. NO emotional swell. Per Rule 23 + Pillar 4: "沉默比文字更重". Total duration 1.5 s. Frequency content: 200-1000 Hz (chair wheels, footsteps), with 0.3 s silence at end before ambient continues. ABSOLUTELY no melodic content, no string swell.

**Tone Brief for sound-designer**: 行政流程音化的"NPC 离开"具象化. 禁: 音乐 / 情感乐句 / 钢琴单音 / 弦乐 long-fade. Anchor: someone has packed and left while you were focused on something else.

**Status**: Needed (CRITICAL — Rule 23 anchor)
**Referenced by**: event-script-engine, audio-manager

---

## ASSET-156 — SFX.FAREWELL.CLEANING_AUNT_LEAVE_NUMERIC

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~2.0 s) |
| Format | WAV 16-bit (~100 KB) |
| Naming | `assets/audio/sfx/farewell_cleaning_aunt_leave_numeric.wav` |

**Sonic Character**:
Distant mop-bucket rolling away on tile floor + a single faint humming syllable (clearly not a song, just a person clearing throat). 2 s. Frequency: 80-2000 Hz mop wheels + brief 300-600 Hz vocal. NO sentimentality. Anchor: art-bible §5.2 cleaning aunt 喜丧 — "见人晕倒继续擦地嘴角上扬" — her departure is equally indifferent.

**Status**: Needed
**Referenced by**: event-script-engine, audio-manager

---

## ASSET-157 — SFX.FAREWELL.FISH_MONK_LAID_OFF_NUMERIC

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~1.8 s) |
| Format | WAV 16-bit (~90 KB) |
| Naming | `assets/audio/sfx/farewell_fish_monk_laid_off_numeric.wav` |

**Sonic Character**:
The 摸鱼族 NPC's farewell — a single phone-screen-off click + headphone-cable-snap sound + chair scoot. ~1.8 s. Captures the archetype: their phone was their world, now silenced. NO drama.

**Status**: Needed
**Referenced by**: event-script-engine, audio-manager

---

## ASSET-158 — SFX.FAREWELL.SYCOPHANT_TRANSFER_NUMERIC

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~1.5 s) |
| Format | WAV 16-bit (~70 KB) |
| Naming | `assets/audio/sfx/farewell_sycophant_transfer_numeric.wav` |

**Sonic Character**:
Sycophant NPC transfer — name-card-shuffle sound + brief footsteps. They left the most actively, gathering their network connections to take with them. ~1.5 s.

**Status**: Needed
**Referenced by**: event-script-engine, audio-manager

---

## ASSET-159 — SFX.FAREWELL.OLD_HAND_RETIRES_NUMERIC

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~2.0 s) |
| Format | WAV 16-bit (~100 KB) |
| Naming | `assets/audio/sfx/farewell_old_hand_retires_numeric.wav` |

**Sonic Character**:
The 老油条同行 NPC's exit — a long thermos cap-screw sound + heavy chair-push + fading footsteps. ~2 s. The thermos cue is the silhouette signature audio (per art-bible §5.2 老油条 has 保温杯 which is their visual signifier, audible counterpart here).

**Status**: Needed
**Referenced by**: event-script-engine, audio-manager

---

## ASSET-160 — SFX.EVENT.FLASH_OVERLAY_PUNCTUATION (flash 档单击触发)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.2 s) |
| Format | WAV 16-bit (~10 KB) |
| Naming | `assets/audio/sfx/event_flash_overlay_punctuation.wav` |

**Sonic Character**:
Single soft "stamp" sound — flash overlay events (~3 s, single line shown via ASSET-014 caption) get a 200 ms paper-stamp punctuation when they appear. Frequency: 1 kHz click + 80 Hz body. NO bell. Used for printer-jam / minor-event-flash type events.

**Tone Brief**: Subtle bureaucratic punctuation, NEVER attention-grabbing. Anchor: a notification on an old terminal screen.

**Status**: Needed
**Referenced by**: event-script-engine, hud-diegetic

---

## ASSET-161 — SFX.EVENT.LONG_DIALOG_PARAGRAPH_BREATHE (long 事件段间气口)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.4 s) |
| Format | WAV 16-bit (~30 KB) |
| Naming | `assets/audio/sfx/event_long_paragraph_breathe.wav` |

**Sonic Character**:
Subtle "between paragraph" filler. Plays at end of dialog text-reveal, before user advances. A brief desk-shuffle or page-turn. ~400 ms. NO music. Used in `long` events between paragraphs.

**Status**: Needed
**Referenced by**: event-script-engine, card-play-dialogue-ui

---

## ASSET-162 — SFX.EVENT.NUMERIC_ONLY_TICK (numeric_only flash 数字弹跳)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.1 s) |
| Format | WAV 16-bit (~5 KB) |
| Naming | `assets/audio/sfx/event_numeric_tick.wav` |

**Sonic Character**:
Tiny digital tick — used for `numeric_only` events that show a single number change in HUD without dialog. Frequency: ~2 kHz click ~80 ms. Per Rule 23 守门: this is the QUIETEST audio cue in the game. NO other accompaniment.

**Status**: Needed
**Referenced by**: event-script-engine, hud-diegetic

---

## ASSET-163 — Event Lint Tool Audio Coverage Check

| Field | Value |
|-------|-------|
| Category | Tool (CI gate) |
| Format | extension to `tools/event_lint.gd` |

**Sonic Character**:
N/A — adds CI check that every `event_id ∈ FAREWELL_EVENT_IDS` has an associated SFX file in farewell namespace. Missing → BLOCK PR (per Rule 23 守门).

**Status**: Needed (CI gate)
**Referenced by**: event-script-engine, audio-manager

---

## ASSET-164 — Audio Brief Templates for FAREWELL_EVENT_IDS (5 briefs)

| Field | Value |
|-------|-------|
| Category | Documentation |
| Format | `.md` per farewell event |
| Naming | `production/audio-briefs/farewell_[npc_id]_goodbye.md` |

**Sonic Character**:
Markdown brief per farewell event for sound-designer. References Rule 23 + Pillar 4 红线 + ADR-0001. Each brief:
- Tone anchor (specific NPC archetype + 喜丧 trigger from art-bible §5.2)
- Prohibited approaches (no music / no string swell / no door slam)
- Reference recordings list
- Synchronization timing (must complete before next ambient cycle)
- A/B comparison anchors

**Status**: Needed (5 briefs — 1 per FAREWELL_EVENT_IDS entry: LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF / SYCOPHANT_TRANSFER / OLD_HAND_RETIRES)
**Referenced by**: event-script-engine, audio-manager
