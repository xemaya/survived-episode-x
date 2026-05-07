# Epic: Scene & Day Flow Controller

> **Layer**: Core(Bottleneck ⭐⭐ — 全游戏 dispatch 总线)
> **GDD**: [design/gdd/scene-day-flow-controller.md](../../../design/gdd/scene-day-flow-controller.md)
> **Architecture Module**: Scene & Day Flow #6(Core)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: HIGH(`PROCESS_MODE_ALWAYS` 4.6 SceneTree.paused + `change_scene_to_packed()` 4.5 + `@abstract` 4.5+ 三 OQ 实测)
> **Stories**: 15 created — see Stories section below

## Overview

Scene & Day Flow Controller 是项目的总线 dispatcher — Autoload 单例 `/root/SceneDayFlowController` `PROCESS_MODE_ALWAYS`(autoload 列表末位);8 sub-mode 状态机(`MAIN_MENU` / `LOADING` / `ACTION_DAY` / `EVENT_ACTIVE` / `WEEKEND` / `KPI_REVIEW` / `GAMEOVER` / `PAUSE` / `SETTINGS`)+ `scene_state_changed` 总线唯一 emit owner(15 subscribers)+ `request_transition()` 唯一合法入口 + 主语翻转 dispatch 强制;启动序列 P5 5000ms 总预算(720ms 必要 + 4280ms 缓冲)+ bool ready 检查 + `await _mark_ready` 4 Foundation;settings 防抖单 timer 共享(500ms,6 信号合流 — ADR-0004);pause game-time vs wall-clock 边界严守(`PAUSE_INHERIT` vs `PROCESS_MODE_ALWAYS` 二分);`change_scene_to_packed()` 预加载守门 + `@abstract BaseSubModeState` 4.5+ 基类。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | scene_state_changed 单 owner = #6 + soft_pause_requested + weekend_rest_day | LOW |
| [ADR-0002](../../../docs/architecture/adr-0002-autoload-init-order.md) | 6 Autoload 顺序 + #6 末位 + PROCESS_MODE_ALWAYS + @abstract BaseSubModeState + change_scene_to_packed 预加载 + 启动序列 | HIGH |
| [ADR-0004](../../../docs/architecture/adr-0004-settings-reflow-coalescing.md) | settings 防抖单 timer 共享 + 6 信号合流 + 单次 reflow 广播 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-sceneflow-001 | Autoload 末位 + PROCESS_MODE_ALWAYS | ADR-0002 ✅ |
| TR-sceneflow-002 | 8 sub-mode 状态机 + scene_state_changed 单 owner | ADR-0001 + ADR-0002 ✅ |
| TR-sceneflow-003 | request_transition 唯一入口 + 主语翻转 dispatch | ADR-0001 + ADR-0002 ✅ |
| TR-sceneflow-004 | 启动序列 P5 5000ms + bool ready 检查 | ADR-0002 ✅ |
| TR-sceneflow-005 | settings 防抖单 timer + 6 信号合流 | ADR-0004 ✅ |
| TR-sceneflow-006 | pause game-time vs wall-clock 边界 | ADR-0002 ✅ |
| TR-sceneflow-007 | change_scene_to_packed 预加载守门 | ADR-0002 ✅ |
| TR-sceneflow-008 | @abstract BaseSubModeState 4.5+ | ADR-0002 ✅ |
| TR-sceneflow-009 | NOTIFICATION_WM_WINDOW_FOCUS_OUT 三方语义(act_pause 公版) | ⚠️ Partial(GDD-internal) |
| TR-sceneflow-010 | 6 项 cross-system BLOCKING 仲裁责任 | ADR-0001..0008 全 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/scene-day-flow-controller.md` Section H 27 AC 全部 verify(5 [RISK GUARD] AC-ROBUST-01..05 守 R-SDF-1..5)
- 10 C-ENG-01..10(Engine Integration Rules)全部落地 + 自动化 perf test 验证
- Logic stories(state machine / 8 sub-mode 转移矩阵 / dispatch ≤ 1 帧)passing tests in `tests/unit/scene_flow/`
- Integration stories(启动序列 + 4 _mark_ready + change_scene_to_packed 预加载)passing tests in `tests/integration/scene_flow/`
- OQ-SDF-ENG-01/02/03 实测 PASS(Pre-Production prototype):
  - PROCESS_MODE_ALWAYS 4.6 SceneTree.paused 行为
  - change_scene_to_packed() 4.5 性能基准(2D 路径 ≤ 200ms p95)
  - @abstract 4.5+ 语法实测
- Smoke check #6(8 sub-mode 转移序列正确)PASS

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [8 Sub-Mode Enum + scene_sub_mode Owner](story-001-eight-submode-enum.md) | Logic | Complete | ADR-0002 |
| 002 | [scene_state_changed Single Owner + Inversion Dispatch](story-002-scene-state-changed-signal.md) | Logic | Complete | ADR-0001 |
| 003 | [Autoload Last + PROCESS_MODE_ALWAYS](story-003-autoload-process-mode-always.md) | Integration | Complete | ADR-0002 |
| 004 | [Startup Sequence — P5 5000ms Budget](story-004-startup-sequence-5000ms.md) | Integration | Complete | ADR-0002 |
| 005 | [change_scene_to_packed Preload Guard](story-005-change-scene-packed-preload.md) | Integration | Complete | ADR-0002 |
| 006 | [@abstract BaseSubModeState + 9 Subclass](story-006-abstract-base-submode-state.md) | Logic | Complete | ADR-0002 |
| 007 | [WM_FOCUS_OUT Three-Way Semantic](story-007-wm-focus-out-three-way.md) | Integration | Complete | GDD Rule 5 |
| 008 | [Pause Game-Time vs Wall-Clock](story-008-pause-game-time-vs-wall-clock.md) | Logic | Complete | ADR-0002 |
| 009 | [Settings Debounce 6-Signal Coalescing](story-009-settings-debounce-coalesce.md) | Integration | Complete | ADR-0004 |
| 010 | [8x8 Transition Matrix](story-010-eight-by-eight-transition-matrix.md) | Logic | Complete | GDD Rule 1 |
| 011 | [Game-Time Tick — Discrete Event-Driven](story-011-game-time-tick-discrete.md) | Logic | Complete | GDD Rule 9 |
| 012 | [KPI Review Three-Track Coordinator (800ms)](story-012-kpi-review-three-track-coordinator.md) | Integration | Complete | ADR-0007 |
| 013 | [GAMEOVER 1500ms + ARCHIVING](story-013-gameover-1500ms-archiving.md) | Integration | Complete | ADR-0006 + ADR-0003 |
| 014 | [FrameTimeMonitor Debug Self-Monitor](story-014-frame-time-monitor-debug.md) | Logic | Complete | GDD Rule 8 |
| 015 | [5 Risk Guards + Skippable + Frame Budget](story-015-risk-guards-skippable.md) | Logic | Complete | GDD R-SDF-1..5 |

**Story type breakdown**:8 Logic + 7 Integration

## Next Step

按依赖树推进:001 / 003 / 005 / 006 并行 → 002 / 004 / 008 → 007 / 009 / 010 → 011 / 014 → 012 / 013 / 015。
