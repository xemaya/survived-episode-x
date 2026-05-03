# Epic: Audio Manager

> **Layer**: Foundation
> **GDD**: [design/gdd/audio-manager.md](../../../design/gdd/audio-manager.md)
> **Architecture Module**: Audio Manager #4(Foundation)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: HIGH(via ADR-0002 autoload + `change_scene_to_packed` 启动序列协调)
> **Stories**: 12 created — see Stories section below

## Overview

Audio Manager 提供 4 Bus 架构(Master / Music / Ambient / SFX);LOADING/READY 状态机 + 8 sub-mode ambient 表 + audio_preload_budget_ms = 200ms / audio_loading_watchdog_ms = 10000ms / bgm_loop_length_max_sec = 120s / audio_bank_total_size_mb = 30MB;月末 KPI Review 三轨 800ms cross-fade(ADR-0007);farewell event 禁切 BGM(`#10 FAREWELL_EVENT_IDS` numeric_only AC-FAREWELL-01 守门);act_pause + WM_FOCUS_OUT fade 公版统一(Music → -∞ 200ms / Ambient → -24 300ms);Pillar 4 红线 8 SFX + 4 BGM 切换禁止类型(`subject_inversion_lint.py --domain` 守)。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | bus_volume_changed signal 防抖合流到 Save;_mark_ready 启动序列 | LOW |
| [ADR-0002](../../../docs/architecture/adr-0002-autoload-init-order.md) | AudioManager autoload 第 3 位;LOADING watchdog 10s + Tween fade `PROCESS_MODE_ALWAYS` 跨 pause | HIGH |
| [ADR-0007](../../../docs/architecture/adr-0007-kpi-review-three-track-anchor.md) | 月末 800ms cross-fade out + stinger 同帧 + KPI_REVIEW BGM cross-fade in | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-audio-001 | 4 Bus 架构(Master / Music / Ambient / SFX) | ⚠️ Partial(GDD-internal) |
| TR-audio-002 | LOADING/READY 状态机 + _mark_ready signal + 8 sub-mode ambient | ADR-0001 + ADR-0002 ✅ |
| TR-audio-003 | audio_preload_budget_ms 200ms + watchdog 10000ms | ADR-0002 + entities.yaml ✅ |
| TR-audio-004 | bgm_loop_length_max_sec = 120s + audio_bank_total_size_mb = 30MB | ⚠️ Partial(entities.yaml) |
| TR-audio-005 | 月末 KPI Review 三轨 800ms cross-fade | ADR-0007 ✅ |
| TR-audio-006 | farewell event 禁切 BGM(AC-FAREWELL-01 守门) | ADR-0001 + ADR-0009 ✅ |
| TR-audio-007 | act_pause + WM_FOCUS_OUT fade 公版统一 | ⚠️ Partial(`#6` GDD `act_pause` 公版) |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/audio-manager.md` Section H 27 AC 全部 verify(MVP 必测 24 / Beta 推迟 2;5 [RISK GUARD] AC-ROBUST-01..05 守 R-AUD-1..5)
- Logic stories(Bus 4 通道 / SFX 池 LRU 8 / BGM 白名单)passing tests in `tests/unit/audio/`
- Integration stories(LOADING watchdog 10s / 静音 visual_parity / KPI Review 三轨 同步)passing tests in `tests/integration/audio/`
- `tools/audio_lint.gd` `assets/audio/` ≤ 30MB CI 通过
- AC-FAREWELL-01(`#10 Rule 23` FAREWELL_EVENT_IDS 禁 BGM 切换)守门测试 PASS

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [4-Bus Architecture + Master Lock](story-001-four-bus-architecture.md) | Logic | Complete | GDD Rule 1 |
| 002 | [Audio Event Naming + Pillar 4 Lint](story-002-audio-event-naming-pillar4-lint.md) | Logic | Complete | ADR-0010 |
| 003 | [LOADING/READY State + 10s Watchdog](story-003-loading-ready-state-watchdog.md) | Integration | Complete | ADR-0001 + ADR-0002 |
| 004 | [Bus Volume Signal + Save Load](story-004-bus-volume-signal-save-load.md) | Logic | Complete | ADR-0001 + ADR-0004 |
| 005 | [6 Sub-Mode Ambient Schema](story-005-six-submode-ambient-layer.md) | Integration | Complete | ADR-0001 |
| 006 | [BGM Whitelist + KPI 800ms Three-Track](story-006-bgm-whitelist-three-track-anchor.md) | Integration | Complete | ADR-0007 |
| 007 | [SFX Pool LRU 8 + CRITICAL](story-007-sfx-pool-lru-critical.md) | Logic | Complete | GDD Rule 8 |
| 008 | [Preload < 200ms + 30MB + MUSIC_TRACK_MAX](story-008-preload-30mb-music-track-max.md) | Logic | Complete | ADR-0002 |
| 009 | [Farewell Event No BGM Switch](story-009-farewell-event-no-bgm-switch.md) | Integration | Complete | ADR-0001 + ADR-0009 |
| 010 | [act_pause + WM_FOCUS_OUT Fade](story-010-act-pause-wm-focus-out-fade.md) | Integration | Complete | ADR-0001 |
| 011 | [Mute Visual Parity + Signal Decoupling](story-011-mute-visual-parity.md) | Logic | Complete | ADR-0008 |
| 012 | [_BUREAUCRATIC Anchor + Tone + Perf](story-012-bureaucratic-anchor-tone-perf.md) | Logic | Complete | ADR-0010 |

**Story type breakdown**:7 Logic + 5 Integration

## Next Step

按依赖树推进:001 → 002 / 003 → 004 / 005 / 008 → 006 / 007 / 009 / 010 → 011 / 012。
