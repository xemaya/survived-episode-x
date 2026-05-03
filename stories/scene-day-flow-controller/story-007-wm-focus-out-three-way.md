# Story 007: WM_FOCUS_OUT Three-Way Semantic

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-009`
**ADR**: GDD Rule 5 + C-ENG-03 + Audio Story 010 + Input Story 011 协作
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: NOTIFICATION_WM_WINDOW_FOCUS_OUT 主线程同步 + 桌面专属
- Forbidden: NOTIFICATION_APPLICATION_PAUSED(桌面 no-op,移动专用)
- Required: 三方语义统一(act_pause + soft_pause_requested + Save flush)

## Acceptance Criteria

- [ ] `_notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT)` 接收 + emit 三信号
- [ ] **三方语义**:emit `act_pause(reason=&"focus_out")` → Audio Story 010 fade(Music 200ms / Ambient 300ms);emit `soft_pause_requested(source=&"focus_out")` → Lighting / Save flush;emit `scene_state_changed(prev, PAUSE)`
- [ ] WM_FOCUS_IN → emit `act_resume` + scene_state_changed 回 prev
- [ ] act_pause + WM_FOCUS_OUT 二者同行为(Edge 7 修正后一致)

## Implementation Notes

```gdscript
signal act_pause(reason: StringName)
signal soft_pause_requested(source: StringName)

var _prev_sub_mode: StringName = &""

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        emit_signal(&"act_pause", &"focus_out")
        emit_signal(&"soft_pause_requested", &"focus_out")
        _prev_sub_mode = _current_sub_mode
        request_transition(&"PAUSE")
    elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
        if _prev_sub_mode != &"":
            request_transition(_prev_sub_mode)
            _prev_sub_mode = &""
```

## QA Test Cases

- WM_FOCUS_OUT → 三信号同帧 emit + transition 至 PAUSE
- WM_FOCUS_IN → transition 回 prev
- act_pause + WM_FOCUS_OUT 二者同行为(Audio fade 公版统一)

## Test Evidence

`tests/integration/scene_flow/wm_focus_out_test.gd`

## Dependencies

- Depends on: Story 002 + Audio Story 010 + Input Story 011
- Unlocks: 跨系统 pause 协作(Audio fade / Save flush / Lighting watchdog 挂起)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED — `_notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT)` 接收 + 三信号同帧 emit (`act_pause(focus_out)` + `soft_pause_requested(focus_out)` + transition PAUSE) + WM_FOCUS_IN symmetric `act_resume` + restore prev sub-mode + `_focus_out_handled` dedup guard(R-SDF-4 共建);三方语义 act_pause + WM_FOCUS_OUT 公版统一(同 reason `&"focus_out"`)
**Test Evidence**: `tests/integration/scene_flow/wm_focus_out_test.gd` (3 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED;`_force_transition` 用于 focus-out 系统事件(绕开 8x8 矩阵的 from-MAIN_MENU/PAUSE 入口约束 — 系统级事件优先于矩阵 — Edge 7 修正);R-SDF-4 dedup `_focus_out_handled` flag 协同 Story 015;无 BLOCKING / 无 inline fix
**Engine API Verification**: NOTIFICATION_WM_WINDOW_FOCUS_OUT / NOTIFICATION_WM_WINDOW_FOCUS_IN 是 Godot 4.x stable Node notification constants,4.3→4.6 无变更
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. GDD Rule 5 引用直接落地(无独立 ADR,本 story 是规则唯一实施点)
**Tech debt**: None new
**API surface**: `signal act_pause(reason: StringName)` + `signal act_resume` + `_notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT/IN)` 处理
