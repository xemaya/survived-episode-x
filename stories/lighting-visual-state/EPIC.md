# Epic: Lighting & Visual State Controller

> **Layer**: Foundation
> **GDD**: [design/gdd/lighting-visual-state.md](../../../design/gdd/lighting-visual-state.md)
> **Architecture Module**: Lighting & Visual State #5(Foundation)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: LOW(2D CanvasModulate + ShaderMaterial 4.0+ 稳定;Tonemapper Filmic 锁不依赖 4.6 AgX 新特性)
> **Stories**: 13 created — see Stories section below

## Overview

Lighting & Visual State Controller owns 8 sub-mode CanvasModulate 色值表;LOADING/READY 状态机 + lighting_loading_watchdog_ms = 10000ms;palette swap shader + dither overlay shader(canvas_item shader_type);累积 4 维度 schema(`yellowing_level` / `sticky_note_count` / `steam_density` / `npc_empty_chairs` — `accumulation_event` signal 单 owner = #5,B-DEP-3 仲裁);KPI_REVIEW 紫色 800ms palette swap(ADR-0007)+ GAMEOVER 灰度 1500ms;Pillar 4 5 类禁视觉(金光/sparkle/烟花/彩虹/鸡汤 caption,4 例外白名单)+ Hero card brightness lift +0.05 0.5s(mute_visual_parity 守);notice_board_max_entries = 24 累积 cap(2 年月数 FIFO);farewell event 禁特殊 palette swap;色盲 CanvasLayer post-process Shader 整屏适配(Control + Node2D)。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | accumulation_event 单 owner = #5;_mark_ready 启动序列 | LOW |
| [ADR-0005](../../../docs/architecture/adr-0005-lighting-accumulation-dimensions.md) | 4 累积维度 schema + 单 signal + type 枚举 | LOW |
| [ADR-0007](../../../docs/architecture/adr-0007-kpi-review-three-track-anchor.md) | KPI_REVIEW 紫色 palette 800ms swap CanvasModulate Tween EASE_IN_OUT | LOW |
| [ADR-0008](../../../docs/architecture/adr-0008-visual-boundary-pillar4-vs-mute-parity.md) | Hero card brightness lift +0.05 0.5s + 5 类禁视觉守门 + 4 例外白名单 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-lighting-001 | 8 sub-mode CanvasModulate 色值表 | ⚠️ Partial(GDD-internal) |
| TR-lighting-002 | LOADING/READY 状态机 + lighting_loading_watchdog_ms 10000ms | ADR-0002 + entities.yaml ✅ |
| TR-lighting-003 | 累积 4 维度 schema | ADR-0005 ✅ |
| TR-lighting-004 | accumulation_event signal 单 owner = #5 | ADR-0001 + ADR-0005 ✅ |
| TR-lighting-005 | KPI_REVIEW 紫色 palette 800ms swap | ADR-0007 ✅ |
| TR-lighting-006 | GAMEOVER 灰度 1500ms palette | ADR-0006 + ADR-0008 ✅ |
| TR-lighting-007 | 5 类禁视觉 + 4 例外白名单 | ADR-0008 ✅ |
| TR-lighting-008 | Hero card brightness lift +0.05 0.5s | ADR-0008 ✅ |
| TR-lighting-009 | notice_board_max_entries = 24 | ADR-0005 + entities.yaml ✅ |
| TR-lighting-010 | Tonemapper Filmic 锁(4.6 AgX 不启用) | ⚠️ Partial(architecture.md L34) |
| TR-lighting-011 | palette swap shader + dither overlay shader | ⚠️ Partial(GDD-internal) |
| TR-lighting-012 | farewell event 禁特殊 palette swap(AC-FAREWELL-01) | ADR-0001 + ADR-0008 ✅ |
| TR-lighting-013 | 色盲 CanvasLayer post-process Shader 整屏 | ADR-0014 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/lighting-visual-state.md` Section H 29 AC 全部 verify(MVP 必测 25 / Beta 推迟 2;5 [RISK GUARD] AC-ROBUST-01..05 守 R-LVS-1..5)
- Logic stories(palette swap / accumulation 4 维度 / brightness lift)passing tests in `tests/unit/lighting/`
- Integration stories(KPI Review 三轨 / Hero card mute_visual_parity / farewell event AC-FAREWELL-01/02)passing tests in `tests/integration/lighting/`
- Visual stories(palette LUT / 8 sub-mode / 5 禁视觉)evidence 在 `tests/evidence/`
- 5 禁视觉 visual lint 通过(自动 visual diff 测试,brightness lift ≤ 0.07)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [8 Sub-Mode CanvasModulate Palette](story-001-eight-submode-canvasmodulate.md) | Logic | Complete | GDD Rule 1 |
| 002 | [LOADING/READY + 10s Watchdog](story-002-loading-ready-watchdog.md) | Integration | Complete | ADR-0001 + ADR-0002 |
| 003 | [accumulation_event 4-Dimension Schema](story-003-accumulation-event-schema.md) | Logic | Complete | ADR-0005 |
| 004 | [4-Dimension Accumulation Triggers](story-004-accumulation-triggers.md) | Integration | Complete | ADR-0005 + ADR-0001 |
| 005 | [Palette Swap + Dither Shader](story-005-palette-swap-dither-shader.md) | Logic | Complete | GDD Rule 4 |
| 006 | [KPI Review Purple 800ms](story-006-kpi-review-purple-800ms.md) | Integration | Complete | ADR-0007 |
| 007 | [GAMEOVER Greyscale 1500ms](story-007-gameover-grey-1500ms.md) | Integration | Complete | ADR-0006 + ADR-0008 |
| 008 | [Pillar 4 5 Forbidden Visuals Lint](story-008-pillar4-forbidden-visual-lint.md) | Logic | Complete | ADR-0008 |
| 009 | [Hero Card Brightness Lift + Mute Parity](story-009-hero-card-brightness-lift.md) | Integration | Complete | ADR-0008 |
| 010 | [notice_board 24 FIFO](story-010-notice-board-fifo-cap.md) | Logic | Complete | ADR-0005 |
| 011 | [Farewell No Palette + accumulation_event Owner](story-011-farewell-no-special-palette.md) | Integration | Complete | ADR-0001 + ADR-0005 |
| 012 | [Colorblind CanvasLayer Shader](story-012-colorblind-canvaslayer-shader.md) | Integration | Complete | ADR-0014 |
| 013 | [Visual Asset Catalogue + Perf](story-013-visual-asset-catalogue-perf.md) | Logic | Complete | ADR-0011 |

**Story type breakdown**:7 Logic + 6 Integration

## Next Step

按依赖树推进:001 → 002 / 003 → 004 / 005 / 008 → 006 / 007 / 009 / 010 / 011 / 012 → 013(perf)
