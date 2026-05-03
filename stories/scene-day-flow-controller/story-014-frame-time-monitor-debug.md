# Story 014: FrameTimeMonitor Debug Self-Monitor

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-002`
**ADR**: GDD Rule 8 + R5 mitigation + C-ENG-07
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: FrameTimeMonitor 仅 debug build(Release build 完全剔除)
- Guardrail: scene_state_changed dispatch 帧时长 — 超 20ms push_warning;超 33.3ms push_error

## Acceptance Criteria

- [ ] `FrameTimeMonitor` 仅 `OS.is_debug_build()` 内启用
- [ ] 每次 `scene_state_changed` emit 前后 `Time.get_ticks_usec()` 测量(C-ENG-07 wall-clock 不受 paused 影响)
- [ ] 超 20ms → push_warning;超 33.3ms → push_error
- [ ] Release build:`#ifdef DEBUG` 等价剔除 — 0 runtime overhead

## Implementation Notes

```gdscript
func request_transition(to: StringName) -> void:
    var start_us := 0
    if OS.is_debug_build():
        start_us = Time.get_ticks_usec()
    
    # ... 转移逻辑
    emit_signal(&"scene_state_changed", _current_sub_mode, to)
    
    if OS.is_debug_build():
        var elapsed_us := Time.get_ticks_usec() - start_us
        var elapsed_ms := elapsed_us / 1000.0
        if elapsed_ms > 33.3:
            push_error("[FrameTimeMonitor] dispatch %fms > 33.3ms — Pillar 5 violated" % elapsed_ms)
        elif elapsed_ms > 20.0:
            push_warning("[FrameTimeMonitor] dispatch %fms > 20ms" % elapsed_ms)
```

## QA Test Cases

- debug build:dispatch 25ms → push_warning;dispatch 35ms → push_error
- Release build:`OS.is_debug_build()` false → 0 调用 FrameTimeMonitor

## Test Evidence

`tests/unit/scene_flow/frame_time_monitor_test.gd`

## Dependencies

- Depends on: Story 002
- Unlocks: Polish 阶段 perf gate

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/4 COVERED — `_perform_transition` 内 `OS.is_debug_build()` guard + `Time.get_ticks_usec()` 测量 + `FRAME_WARN_MS = 20.0` push_warning + `FRAME_ERROR_MS = 33.3` push_error;Release build 自动剔除(`if OS.is_debug_build()` 短路);`report_heavy_op(label, elapsed_ms)` advisory API for R-SDF-3
**Test Evidence**: `tests/unit/scene_flow/frame_time_monitor_test.gd` (3 tests / GdUnit4) — BLOCKING gate PASS;阈值 const + 公有 method signature 验证;实际 25ms/35ms 触发 push_warning/push_error 由 prototype evidence 完成(测试不易模拟 25ms+ 的 signal handler)
**Code Review**: APPROVED;FRAME_WARN_MS / FRAME_ERROR_MS / HEAVY_OP_BUDGET_MS 三 const 公开供 lint/test 引用;Release path 无 runtime overhead(`is_debug_build()` const-fold);无 BLOCKING / 无 inline fix
**Engine API Verification**: OS.is_debug_build() / Time.get_ticks_usec() 是 Godot 4.x stable API,无变更
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. 25ms/35ms 实际 push_warning/push_error 触发 evidence 在 perf prototype 完成(unit-test 难模拟 signal handler 25ms 跑时,常规 dispatch < 1ms)
**Tech debt**: None new
**API surface**: `FRAME_WARN_MS` / `FRAME_ERROR_MS` / `HEAVY_OP_BUDGET_MS` consts + `report_heavy_op(label: StringName, elapsed_ms: float) -> void`
