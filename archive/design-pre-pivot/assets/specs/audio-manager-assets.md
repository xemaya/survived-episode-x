# Asset Specs — System: Audio Manager

> **Source**: design/gdd/audio-manager.md (Section G Audio Asset Catalogue + Rule 3 namespace + Rule 6 ambient layer schema + Rule 7 BGM 白名单)
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 30 audio assets specced (29 from GDD Section G + 1 cross-ref) / 0 in production / 0 done / 0 approved
> **Mode**: solo (audio-director not consulted; tone descriptions are sonic character only — NO generation prompts per /asset-spec audio rule)

> Coverage: 4 Bus 配置 (Master/SFX/Music/Ambient) + 6 ambient layers + 11+ SFX (打卡机/热敏/键盘/咖啡/纸张 etc) + 2 Music tracks (KPI Review LOOP + GAMEOVER CREDITS_OUTRO) + farewell event SFX 替代 BGM 切. **Pillar 4 红线**: 8 类禁止 SFX + 4 类禁止 BGM 切换. **总体积** ≤ 30 MB. **预加载 ≤ 200 ms**.

---

## ASSET-125 — Audio Bus Configuration (default.tres)

| Field | Value |
|-------|-------|
| Category | Configuration |
| Format | `.tres` AudioBusLayout |
| Naming | `default_bus_layout.tres` |

**Sonic Character**:
4-Bus configuration: Master (0 dB, peak limiter, NOT user-adjustable), SFX (-6 dB default, [-60, 0]), Music (-9 dB default), Ambient (-12 dB default). Master applies hardware brick-wall limiter at -1 dBFS to prevent clipping. Music sidechains Ambient with -6 dB duck during PUNCH_CLOCK + RECEIPT_THERMAL events.

**Status**: Needed (project config)
**Referenced by**: audio-manager, main-menu-pause-settings-ui (volume sliders)

---

## ASSET-126 — AMBIENT.OFFICE.FLUORESCENT_HUM (日光灯底噪)

| Field | Value |
|-------|-------|
| Category | Ambient (loop) |
| Format | OGG q=4 (~12 KB) |
| Naming | `assets/audio/ambient/fluorescent_hum.ogg` |
| Loop | yes (seamless, ≤ 30 s loop length) |

**Sonic Character**:
60 Hz electrical hum with subtle 50 Hz subharmonic. Fluorescent ballast gentle warble at ~0.5 Hz amplitude modulation. Frequency content: dominant 60 Hz + 120/180/240 Hz harmonics + faint 4-8 kHz hiss. NO music. NO melody. Mixes seamlessly with AC_LOW_HISS. Player-fantasy anchor: "日光灯嗡的不是 BGM" — this IS what they hear, perpetual.

**Source Strategy**: Freesound CC0 + EQ filter (low-pass 8 kHz, high-pass 40 Hz, notch any musical pitches).

**Status**: Needed
**Referenced by**: audio-manager, scene-day-flow-controller

---

## ASSET-127 — AMBIENT.OFFICE.AC_LOW_HISS (空调低频)

| Field | Value |
|-------|-------|
| Category | Ambient (loop) |
| Format | OGG q=4 (~10 KB) |
| Naming | `assets/audio/ambient/ac_low_hiss.ogg` |
| Loop | yes |

**Sonic Character**:
Constant pink-noise-like low-frequency hiss centered ~80-200 Hz. Subtle slow modulation suggesting compressor cycling (~30-60 s cycle). NO definable pitch. Mixes under FLUORESCENT_HUM as background bed.

**Source Strategy**: Freesound CC0 + 200 Hz low-pass + slow LFO amplitude modulation.

**Status**: Needed
**Referenced by**: audio-manager

---

## ASSET-128 — AMBIENT.OFFICE.KEYBOARD_RHYTHM (隔间键盘节奏)

| Field | Value |
|-------|-------|
| Category | Ambient (loop) |
| Format | OGG q=4 (~25 KB) |
| Naming | `assets/audio/ambient/keyboard_rhythm.ogg` |
| Loop | yes |

**Sonic Character**:
Distant cubicle keyboards in even, monotonous rhythm. Mix of 2-3 keyboards at varying distances/volumes. Tempo ~80-120 keystrokes/minute (uneven, NOT musical). Low-pass at 4 kHz to suggest distance through partition walls. NO emphasis or drumming patterns. Crossfades in 0.5 s on ACTION_DAY entry.

**Source Strategy**: Freesound CC0 keyboard recordings + low-pass + reverb (small room) + de-rhythmize via random gating.

**Status**: Needed
**Referenced by**: audio-manager, scene-day-flow-controller

---

## ASSET-129 — AMBIENT.OFFICE.SCREEN_BUZZ_OVERTIME (overtime 蜂鸣叠加)

| Field | Value |
|-------|-------|
| Category | Ambient (loop, overlay) |
| Format | OGG q=4 (~15 KB) |
| Naming | `assets/audio/ambient/screen_buzz_overtime.ogg` |
| Loop | yes |

**Sonic Character**:
High-frequency whine ~15-18 kHz suggesting CRT/monitor whine + faint 60 Hz electrical breath. Player-fantasy anchor: feeling "你听到的是屏幕,不是音乐". Stinger-FREE — purely volume tween 2 s in. Subtle modulation. Layers ON TOP of base ambient stack, never replaces.

**Source Strategy**: Freesound CC0 CRT/monitor whine + EQ enhance high-frequency + pitch-wobble for organic feel.

**Status**: Needed
**Referenced by**: audio-manager, lighting-visual-state (ACTION_OVERTIME audio-visual dual encoding)

---

## ASSET-130 — AMBIENT.OFFICE.PHONE_THREE_RINGS (远处电话三声)

| Field | Value |
|-------|-------|
| Category | Ambient (oneshot, randomized) |
| Format | OGG q=4 (~30 KB) |
| Naming | `assets/audio/ambient/phone_three_rings.ogg` |
| Loop | no — oneshot at random intervals (60-180 s) |

**Sonic Character**:
Distant office phone, 3 rings, no one picks up. Each ring ~0.5 s with ~1.5 s gap. Pitched ~700-900 Hz electromechanical bell-style. Heavy low-pass (3 kHz) for distance. NO melody. The "no one answers" is the design — bureaucratic indifference.

**Source Strategy**: Freesound CC0 office phone + low-pass + extra distance reverb.

**Status**: Needed
**Referenced by**: audio-manager

---

## ASSET-131 — AMBIENT.OFFICE.MAIN_MENU_AMBIENT (主菜单底噪)

| Field | Value |
|-------|-------|
| Category | Ambient (loop) |
| Format | OGG q=4 (~12 KB) |
| Naming | `assets/audio/ambient/main_menu_ambient.ogg` |
| Loop | yes |

**Sonic Character**:
Combination layer of FLUORESCENT_HUM at -18 dB + AC_LOW_HISS at -12 dB. Pre-mixed for main menu where keyboard/phone are absent (empty office). Per main-menu-pause-settings-ui Rule 4: NO BGM, this ambient stand-in suggests "no one is here yet".

**Status**: Needed (premix)
**Referenced by**: audio-manager, main-menu-pause-settings-ui

---

## ASSET-132 — SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC (打卡机咔哒)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.3 s) |
| Format | WAV 16-bit (~30 KB) |
| Naming | `assets/audio/sfx/punch_clock_clack_bureaucratic.wav` |
| `_BUREAUCRATIC` Anchor | yes — Player Fantasy "月末打卡机不是胜利音" |

**Sonic Character**:
Mechanical punch-clock stamp. Single sharp metallic click + paper-ink contact thud. Frequency: prominent 800 Hz click + 80 Hz body thud. Duration ~300 ms with 50 ms tail. NO musical pitch, NO success-chime. Tone: bureaucratic, deliberate. CRITICAL: not "ding ✓" — it's "kachunk-thud, recorded."

**Tone Brief for sound-designer**: 行政流程音化. 禁: 上行音符 / 励志节奏 / 英雄弦乐 / 完美 timing 质感. Anchor: 1990s 机关单位办公室 punch clock.

**Source Strategy**: 自录 (real punch clock + paper) OR Freesound Pro punch-clock-stamp recordings + transient shaping.

**Status**: Needed (CRITICAL — Player Fantasy anchor)
**Referenced by**: audio-manager, kpi-review-game-over-ui

---

## ASSET-133 — SFX.UI.RECEIPT_THERMAL_HISS_BUREAUCRATIC (热敏收据嘶)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~2.0 s) |
| Format | WAV 16-bit (~120 KB) |
| Naming | `assets/audio/sfx/receipt_thermal_hiss_bureaucratic.wav` |
| `_BUREAUCRATIC` Anchor | yes — 月末评级打印 |

**Sonic Character**:
Thermal printer extruding receipt. Continuous 2-second hiss at ~3-6 kHz with paper-friction undertone ~200 Hz. Subtle stepper-motor whir at ~8 kHz. Ends with light paper-tear if receipt completes. NO musical pitch. Anchor: convenience store receipt printer.

**Tone Brief**: 行政流程音化. 与 PUNCH_CLOCK_CLACK 配对作"通过结算"事件 audio. 禁: 励志合成器 / 庆祝 fanfare.

**Source Strategy**: 自录 (real thermal printer) OR Freesound Pro.

**Status**: Needed (CRITICAL)
**Referenced by**: audio-manager, kpi-review-game-over-ui

---

## ASSET-134 — SFX.RECAP.ENDGAME_LETTER_PRINT (GO 信件打印)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~3.0 s) |
| Format | WAV 16-bit (~180 KB) |
| Naming | `assets/audio/sfx/endgame_letter_print.wav` |
| `_BUREAUCRATIC` Anchor | yes |

**Sonic Character**:
Daisy-wheel or dot-matrix style letter printing for the termination certificate. 3 s duration with rhythmic mechanical chunks at ~10 Hz. Paper feed and ink-ribbon advancement. Synced with character-by-character certificate text reveal in GAMEOVER UI. Ends with paper tear and final settle.

**Source Strategy**: Freesound CC0 dot-matrix printer + careful synchronization with text reveal animation timing.

**Status**: Needed
**Referenced by**: audio-manager, kpi-review-game-over-ui

---

## ASSET-135 — SFX.CARD.HERO_CARD_PLAYED (hero card 出卡)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.4 s) |
| Format | WAV 16-bit (~40 KB) |
| Naming | `assets/audio/sfx/card_hero_played.wav` |

**Sonic Character**:
Soft paper-flick + table-slap. Quiet, NOT triumphant. Frequency: 200 Hz body slap + 1.5 kHz paper crinkle + faint air whoosh. Duration 400 ms. CRITICAL: this is NOT a "summon" or "epic move" sound — it's filing a report. Pillar 4 红线: NO triumph, NO bell.

**Tone Brief**: Bureaucratic paper handling. 禁: hero theme / 升级音效.

**Source Strategy**: Freesound CC0 paper handling + EQ tame any inadvertent musical resonance.

**Status**: Needed
**Referenced by**: audio-manager, card-play-dialogue-ui, action-card-system

---

## ASSET-136 — SFX.CARD.STANDARD_CARD_PLAYED (普通行动卡)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, round-robin 3 variants) |
| Format | WAV 16-bit (3 × ~30 KB) |
| Naming | `assets/audio/sfx/card_standard_played_[01-03].wav` |

**Sonic Character**:
Lighter than HERO. 3 round-robin variants for variety (avoid repetition fatigue). Each ~250 ms. Frequency: 1-2 kHz paper rustle dominant. NO percussive thud. Tone: filing one of many cards.

**Source Strategy**: Freesound CC0 + 3 distinct paper-handle recordings + variation in pitch ±2%.

**Status**: Needed (3 variants)
**Referenced by**: audio-manager, card-play-dialogue-ui, action-card-system

---

## ASSET-137 — SFX.UI.TYPING_KEYSTROKE (打字击键, round-robin)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, round-robin 3 variants) |
| Format | WAV 16-bit (3 × ~10 KB) |
| Naming | `assets/audio/sfx/ui_typing_[01-03].wav` |

**Sonic Character**:
Single keyboard keystroke. 3 round-robin variants ~50-80 ms each. Frequency: ~3 kHz click + faint 600 Hz body. Used during dialog text-reveal animation. Subtle, not punchy. Mixes well at -10 dB so it doesn't dominate dialog audio.

**Source Strategy**: 自录 from real mechanical keyboard (membrane preferred — quieter than mechanical click switches).

**Status**: Needed (3 variants)
**Referenced by**: audio-manager, card-play-dialogue-ui

---

## ASSET-138 — SFX.UI.PAPER_RUSTLE (纸张翻动)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, round-robin 3) |
| Format | WAV 16-bit (3 × ~25 KB) |
| Naming | `assets/audio/sfx/ui_paper_rustle_[01-03].wav` |

**Sonic Character**:
Paper handling — turning page, shuffling reports. 3 variants, each ~300 ms. Frequency: 1-3 kHz with crinkle texture. Used for sticky note / archive entry interactions.

**Status**: Needed (3 variants)
**Referenced by**: audio-manager, hud-diegetic, kpi-review-game-over-ui

---

## ASSET-139 — SFX.UI.COFFEE_SIP (咖啡杯一口)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.6 s) |
| Format | WAV 16-bit (~50 KB) |
| Naming | `assets/audio/sfx/ui_coffee_sip.wav` |

**Sonic Character**:
A small sip + cup-on-desk thunk. Frequency: 500-1500 Hz liquid + 80 Hz desk impact. Duration 600 ms. Tone: tired-functional, not refreshing. Used when energy ticks up via coffee-related actions (if any).

**Status**: Needed
**Referenced by**: audio-manager, hud-diegetic

---

## ASSET-140 — SFX.UI.AP_SLOT_CROSS (划格)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.15 s) |
| Format | WAV 16-bit (~10 KB) |
| Naming | `assets/audio/sfx/ui_ap_slot_cross.wav` |

**Sonic Character**:
Pencil scratch sound when AP sticky note gets crossed. Single quick stroke ~150 ms. Frequency: 800 Hz pencil-on-paper. Subtle. Synced with `card_played` signal.

**Status**: Needed
**Referenced by**: audio-manager, hud-diegetic

---

## ASSET-141 — SFX.NPC.DIALOG_OPEN (对白框出现)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.2 s) |
| Format | WAV 16-bit (~15 KB) |
| Naming | `assets/audio/sfx/npc_dialog_open.wav` |

**Sonic Character**:
Soft chair-roll + paper-on-desk. Used when an NPC initiates a `long` dialog event. NO chime, NO bell. Tone: someone walking up to your desk.

**Source Strategy**: Freesound CC0 chair + paper.

**Status**: Needed
**Referenced by**: audio-manager, card-play-dialogue-ui

---

## ASSET-142 — SFX.OFFICE.CHAIR_PUSH (椅子拖动)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.5 s) |
| Format | WAV 16-bit (~40 KB) |
| Naming | `assets/audio/sfx/office_chair_push.wav` |

**Sonic Character**:
Wheeled office chair scraping floor. Used for NPC LEAVING_ANNOUNCED / LEFT lifecycle audio cue + Lisa pulling chair over (Player Fantasy 主锚).

**Status**: Needed
**Referenced by**: audio-manager, npc-relationship-system

---

## ASSET-143 — SFX.OFFICE.PHONE_HANG_UP (电话挂断)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.3 s) |
| Format | WAV 16-bit (~25 KB) |
| Naming | `assets/audio/sfx/office_phone_hangup.wav` |

**Sonic Character**:
Distant landline hang-up clack. Used as occasional environmental punctuation.

**Status**: Needed
**Referenced by**: audio-manager

---

## ASSET-144 — SFX.OFFICE.DOOR_CLOSE (门关闭)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.4 s) |
| Format | WAV 16-bit (~35 KB) |
| Naming | `assets/audio/sfx/office_door_close.wav` |

**Sonic Character**:
Office door closing softly. Used for AFTER_WORK transition when NPC departs scene.

**Status**: Needed
**Referenced by**: audio-manager, scene-day-flow-controller

---

## ASSET-145 — SFX.OFFICE.STAPLE_THUNK (订书机)

| Field | Value |
|-------|-------|
| Category | SFX (oneshot, ~0.2 s) |
| Format | WAV 16-bit (~15 KB) |
| Naming | `assets/audio/sfx/office_staple_thunk.wav` |

**Sonic Character**:
Single staple-pressed-into-paper sound. Used for archival / saving moments where bureaucratic finality should be felt.

**Status**: Needed
**Referenced by**: audio-manager, kpi-review-game-over-ui (archive entry creation)

---

## ASSET-146 — MUSIC.KPIREVIEW.ENDGAME_LOOP_BUREAUCRATIC

| Field | Value |
|-------|-------|
| Category | Music (loop) |
| Format | OGG q=5 (~180 KB, 90 s) |
| Naming | `assets/audio/music/kpireview_endgame_loop_bureaucratic.ogg` |
| `_BUREAUCRATIC` Anchor | yes — 月末考核 BGM |

**Sonic Character**:
Closest reference: a 1990s government office cassette tape playing over an intercom. Slow, bureaucratic ambient drone with occasional paper-shuffle / typewriter rhythm. NO melody. NO ascending stinger. NO heroic strings. NO "tension build". Frequency: predominantly 80-2000 Hz. Could include subtle filtered punch-clock rhythm at ~30 BPM. Length 90 s, perfect loop. Plays ducked Ambient -6 dB during KPI Review演出.

**Tone Brief**: Strict bureaucracy. Imagine waiting in a DMV line for the next thirty minutes — that emotional landscape, expressed sonically.

**Source Strategy**: Freesound Pro curation OR self-composed using office-machine field recordings + minimal harmonic content. License decision deferred (OQ-AUD-defer).

**Status**: Needed (CRITICAL — Pillar 4 anchor)
**Referenced by**: audio-manager, kpi-review-game-over-ui

---

## ASSET-147 — MUSIC.GAMEOVER.CREDITS_OUTRO_BUREAUCRATIC

| Field | Value |
|-------|-------|
| Category | Music (oneshot) |
| Format | OGG q=5 (~90 KB, 45 s) |
| Naming | `assets/audio/music/gameover_credits_outro_bureaucratic.ogg` |
| `_BUREAUCRATIC` Anchor | yes — GO 片尾 |

**Sonic Character**:
45 s outro. Closest reference: a 70-80s Chinese state-enterprise farewell at a工人 retirement ceremony — formal, grayish, neither sad nor celebratory. Light percussion at funeral march tempo (60 BPM). Single sustained drone in `#3A3050` "深蓝灰" tonal equivalent (~A2 with low harmonic spread). Closing chord plays as final certificate text settles. Total perceived effect: "事情结束了，不是好也不是坏。" NO ascending finale. NO triumphant build.

**Tone Brief**: Closure without catharsis. The end is an administrative footnote, not a story climax. Sync with `GAMEOVER.TITLE_IRONY "恭喜晋升"` text reveal — Localization irony anchor pairs with audio's cold neutrality.

**Source Strategy**: Self-composed OR Freesound Pro curated. License OQ-AUD-defer.

**Status**: Needed (CRITICAL)
**Referenced by**: audio-manager, kpi-review-game-over-ui

---

## ASSET-148 — Audio Lint Tool (audio_lint.gd)

| Field | Value |
|-------|-------|
| Category | Tool (Editor) |
| Format | `.gd` |
| Naming | `tools/audio_lint.gd` |

**Sonic Character**:
N/A — code asset enforcing GDD Rule 10 layer C: schema check, MUSIC track count ≤ 4, `_BUREAUCRATIC` brief reference check, orphaned asset warn.

**Status**: Needed (tool)
**Referenced by**: audio-manager

---

## ASSET-149 — Audio Sub-Mode Crossfade Configuration

| Field | Value |
|-------|-------|
| Category | Configuration |
| Format | Constants in `audio_manager.gd` |

**Sonic Character**:
N/A — config constants:
- `KEYBOARD_RHYTHM` crossfade-in: 0.5 s
- `KEYBOARD_RHYTHM` crossfade-out: 1.0 s
- `SCREEN_BUZZ_OVERTIME` fade-in: 2.0 s (NO stinger)
- Music BGM fade-in (KPI Review): 1.5 s
- Ambient duck during PUNCH_CLOCK + RECEIPT: -6 dB
- Ambient duck release: 800 ms

**Status**: Needed (config)
**Referenced by**: audio-manager, scene-day-flow-controller

---

## ASSET-150 — Bus Default Volume Resource (.tres)

| Field | Value |
|-------|-------|
| Category | Configuration |
| Format | `.tres` Resource |
| Naming | `assets/data/audio_bus_defaults.tres` |

**Sonic Character**:
Default volume mapping per Rule 1 dB table. Loaded by `AudioManager.load_bus_volumes(payload)` at startup.

**Status**: Needed (config)
**Referenced by**: audio-manager

---

## ASSET-151 — Audio Asset Brief Template (per `_BUREAUCRATIC` key)

| Field | Value |
|-------|-------|
| Category | Documentation |
| Format | `.md` template |
| Naming | `production/audio-briefs/[event_id].md` |

**Sonic Character**:
Markdown template for sound-designer per `_BUREAUCRATIC` key. Sections: tone anchor (行政流程音化), referenced GDD rule, prohibited approaches (上行音符 / 励志节奏 / etc.), file dimensions/format, A/B reference comparison points.

**Status**: Needed (5 briefs to be created — one per `_BUREAUCRATIC` key from GDD Section G "关键锚点"表)
**Referenced by**: audio-manager (Rule 10 Layer A enforcement)

---

## ASSET-152 — SFX.NPC.FAREWELL_NUMERIC_PUNCTUATION (cross-reference)

| Field | Value |
|-------|-------|
| Source | event-script-engine spec (ASSET-156 series) |

**Sonic Character**:
Reference to event-script-engine spec for farewell event numeric_only SFX. Audio Manager hosts the SFX bus dispatch but the brief belongs to event-script-engine.

**Status**: Cross-reference (specced in event-script-engine-assets.md)
**Referenced by**: audio-manager, event-script-engine

---

## ASSET-153 — SFX.UI.MENU_FOCUS (intentionally omitted)

| Field | Value |
|-------|-------|
| Category | NOT NEEDED |

**Sonic Character**:
**Per Rule 9 + Pillar 4 红线**: 普通 UI 按钮焦点切换 / `act_confirm` / `act_cancel` 触发 ZERO SFX. This entry exists as a NEGATIVE SPEC — confirming no asset to be produced. Documented to prevent future scope creep ("但用户体验不是应该有 click 音吗?" → No, per Pillar 4).

**Status**: NOT NEEDED (negative spec)
**Referenced by**: audio-manager, main-menu-pause-settings-ui

---

## ASSET-154 — Audio Total Bank Size Audit (CI gate)

| Field | Value |
|-------|-------|
| Category | CI configuration |
| Format | check in `audio_lint.gd` |

**Sonic Character**:
N/A — CI smoke check verifying total `assets/audio/` bank size ≤ 30 MB (`audio_bank_total_size_mb` knob). Fails build if exceeded.

**Status**: Needed (CI gate)
**Referenced by**: audio-manager
