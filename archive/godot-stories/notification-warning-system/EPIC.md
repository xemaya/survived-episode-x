# Epic: Notification & Warning System(VS)

> **Layer**: Presentation
> **GDD**: [design/gdd/notification-warning-system.md](../../../design/gdd/notification-warning-system.md)
> **Architecture Module**: Notification & Warning #19(Presentation,VS tier)
> **Status**: Ready(10 stories created 2026-04-29;Story 005 部分依赖 propagation flag #6;实施推迟到 VS milestone)
> **Tier**: VS
> **Engine Risk**: LOW(纯信号转发器 + diegetic variant 切换)
> **Stories**: 10 stories | 4 Logic + 6 Integration

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [5 类 warning 信号架构 + idempotent](story-001-five-warning-signal-architecture.md) | Logic | Complete | ADR-0011 |
| 002 | [capacity_floor 预警(R-AP-5 + R-KPI-3)](story-002-capacity-floor-warning.md) | Integration | Complete | ADR-0011 |
| 003 | [effort 极值预警(0.75 阈值)](story-003-effort-extreme-warning.md) | Integration | Complete | ADR-0011 |
| 004 | [NPC 离职预兆(LEAVING_ANNOUNCED)](story-004-npc-leaving-prediction.md) | Integration | Complete | ADR-0011 |
| 005 | [月末倒计时 3/2/1 档](story-005-month-end-countdown.md) | Integration | Ready (partial flag #6) | ADR-0011 |
| 006 | [burnout 预警(Energy ≤ 15)](story-006-burnout-warning.md) | Integration | Complete | ADR-0011 |
| 007 | [GAMEOVER 全预警清除](story-007-gameover-clear-all-warnings.md) | Integration | Complete | ADR-0011 |
| 008 | [R-NW-1 popup 红线 CI 守门 \[BLOCKING\]](story-008-r-nw-1-popup-forbidden-lint.md) | Logic | Complete | ADR-0011 |
| 009 | [R-NW-2 LEFT NPC leak 防护](story-009-r-nw-2-left-npc-leak-guard.md) | Logic | Complete | ADR-0001 |
| 010 | [HR 口吻预警 lint(NPC.NOTICE.*)](story-010-hr-tone-notice-key-lint.md) | Logic | Complete | ADR-0010 |

## Overview

Notification & Warning System(VS tier 增强版)owns 4 类预警 schema(`capacity_floor` / `effort` 极值 / NPC 离职预兆 / 月末倒计时);通过 `#13 HUD` diegetic 元素 visual variant 显示(无 popup — `#19` GDD + ADR-0011 forbidden_pattern `action_day_canvaslayer_visible`);HR 口吻预警语义(扩展 `NPC.NOTICE.*` keys,ADR-0010);信号转发器(无独立 UI 节点)。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0010](../../../docs/architecture/adr-0010-subject-inversion-lint-domains.md) | NPC master domain + NPC.NOTICE.* keys + HR 口吻预警 | LOW |
| [ADR-0011](../../../docs/architecture/adr-0011-hud-diegetic-render.md) | DiegeticNotifications Node2D + 通过 #13 元素 variant 显示(无 popup)| LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-notification-001 | 4 类预警 schema | ⚠️ Partial(VS tier,GDD-internal) |
| TR-notification-002 | 通过 #13 HUD diegetic 元素 visual variant 显示(无 popup) | ADR-0011 ✅ |
| TR-notification-003 | HR 口吻预警语义(扩展 NPC.NOTICE.* keys) | ADR-0010 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`(VS milestone)
- `design/gdd/notification-warning-system.md` Section H 全部 AC verify
- Logic stories(4 类预警 schema + 信号转发)passing tests in `tests/unit/notification/`
- Integration stories(`#19` 转发 → `#13` HUD diegetic variant 切换 + HR 口吻预警语义)passing tests in `tests/integration/notification/`
- 严禁 popup / "警告!"弹层(diegetic 主轨守门测试)
- `subject_inversion_lint.py --domain NPC` 预警 keys PR-blocking 通过

## Next Step

Stories 已创建(2026-04-29,10 stories)。MVP 阶段不实施(VS tier)。

**MVP 即上线守门**:Story 008(R-NW-1 popup 红线 CI 守门)+ Story 010(HR 口吻 NPC.NOTICE.* lint)— 防护性 lint,可在 VS milestone 之前先上线 CI。

VS milestone 启动后:全 10 stories 走 `/story-readiness [story-path]` → `/dev-story [story-path]` → `/code-review` → `/story-done` 流程。Story 005 等 propagation flag #6(`#6 Rule 3` `scene_state_changed` ctx payload 扩展)解决后再实施。
