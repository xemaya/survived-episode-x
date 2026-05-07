# Epic: HUD Diegetic

> **Layer**: Presentation(⭐ 关键依赖节点 — 8 元素 cross-system 订阅)
> **GDD**: [design/gdd/hud-diegetic.md](../../../design/gdd/hud-diegetic.md)
> **Architecture Module**: HUD Diegetic #13(Presentation)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: LOW(2D Node2D + Sprite2D + RichTextLabel 4.0+ 稳定)
> **Stories**: 10 created — see Stories section below

## Overview

HUD Diegetic owns 8 diegetic 元素 mapping(便利贴 / 咖啡杯 / 显示屏 / 考勤表 / 日历 / NPC 表情 / NPC 站位 / 空椅 — 全 Node2D);节点树架构 World (Node2D, layer=0) / DiegeticHUD / DiegeticNotifications / 单 CanvasLayer (layer=1);CanvasLayer 仅 4 sub-mode 切换屏使用(PAUSE / KPI_REVIEW / GAMEOVER / SETTINGS);art-bible §7.1 no overlay 锁(`art-bible §7.1 lint` PR-blocking + forbidden_pattern `action_day_canvaslayer_visible`);8 信号订阅(scene_state_changed + accumulation_event + relationship_changed + ap_changed + kpi_threshold_changed + npc_lifecycle_changed + event_completed + hero_card_played);farewell event 禁渲染 flash overlay(AC-FAREWELL-01 守门)+ 仅 NPC 表情 / 站位 LEFT variant + HUD_EMPTY_CHAIR;Hero card 三 element 反馈;总 draw call ≤ 70 / 100 budget;帧预算 ≤ 2ms / 屏。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | 8 元素订阅 7 信号 + 离别事件 numeric_only AC-FAREWELL-01 守门 | LOW |
| [ADR-0005](../../../docs/architecture/adr-0005-lighting-accumulation-dimensions.md) | 4 元素订阅 accumulation_event(yellowing / sticky / steam / empty_chairs) | LOW |
| [ADR-0008](../../../docs/architecture/adr-0008-visual-boundary-pillar4-vs-mute-parity.md) | hero_card_played 三 element 反馈(咖啡蒸汽 + 文件翻页 + NPC raised eyebrow) | LOW |
| [ADR-0011](../../../docs/architecture/adr-0011-hud-diegetic-render.md) | 节点树架构 + 单 CanvasLayer + 70 draw call budget + art-bible §7.1 lint | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-hud-001 | 8 diegetic 元素 mapping | ADR-0011 ✅ |
| TR-hud-002 | sub-mode 视觉布局状态机 + 帧预算 ≤ 2ms / 屏 | ADR-0011 ✅ |
| TR-hud-003 | 8 信号订阅 | ADR-0001 + ADR-0011 ✅ |
| TR-hud-004 | art-bible §7.1 no overlay 锁(CanvasLayer 仅 sub-mode 切换屏) | ADR-0011 ✅ |
| TR-hud-005 | farewell event 禁渲染 flash overlay(AC-FAREWELL-01 守门) | ADR-0001 + ADR-0011 ✅ |
| TR-hud-006 | 总 draw call ≤ 70 / 100 budget | ADR-0011 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/hud-diegetic.md` Section H 全部 AC verify
- Logic stories(8 元素 visual variant 切换 / 帧预算 ≤ 2ms / draw call ≤ 70)passing tests in `tests/unit/hud/`
- Integration stories(8 信号订阅链 / Hero card 三 element 反馈 / accumulation 4 维度响应)passing tests in `tests/integration/hud/`
- Visual stories(8 元素 sprite + variant 切换)evidence 在 `tests/evidence/`
- AC-FAREWELL-01(`#10 Rule 23` FAREWELL_EVENT_IDS 禁 flash overlay)守门测试 PASS
- `art-bible §7.1 lint` PR-blocking:ACTION_DAY 期间 CanvasLayer.visible = true 阻断 PR
- 性能测试:draw call ≤ 70(8 静态 + 12 sticky + 24 notice + ~10 dust;Godot 自动 batching 应聚合更多)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [Node Tree + Single CanvasLayer](story-001-node-tree-architecture.md) | Logic | Complete | ADR-0011 |
| 002 | [8 Diegetic Element Mapping](story-002-eight-element-mapping.md) | UI | Complete | ADR-0011 |
| 003 | [8 Element 7-Signal Subscriptions](story-003-eight-signal-subscriptions.md) | Integration | Complete | ADR-0001 + ADR-0011 |
| 004 | [art-bible §7.1 No Overlay Lock](story-004-art-bible-no-overlay-lock.md) | Logic | Complete | ADR-0011 |
| 005 | [accumulation_event Visual Variant](story-005-accumulation-visual-variant.md) | Integration | Complete | ADR-0005 + ADR-0011 |
| 006 | [Farewell No Flash Overlay](story-006-farewell-no-flash-overlay.md) | Integration | Complete | ADR-0001 + ADR-0011 |
| 007 | [Hero Card 3-Element Feedback](story-007-hero-card-three-element-feedback.md) | Integration | Complete | ADR-0008 + ADR-0011 |
| 008 | [Flash Overlay numeric_only](story-008-flash-overlay-numeric-only.md) | Visual/Feel | Complete | ADR-0012 |
| 009 | [Draw Call Budget ≤ 70](story-009-draw-call-budget-perf.md) | Logic | Complete | ADR-0011 |
| 010 | [8 Sprite + Variant Assets](story-010-sprite-variant-assets.md) | Visual/Feel | Complete | ADR-0011 |

**Story type breakdown**:3 Logic + 4 Integration + 2 Visual/Feel + 1 UI

## Next Step

依赖树:001 → 002 / 004 → 003 → 005 / 006 / 007 / 008 → 009 / 010
