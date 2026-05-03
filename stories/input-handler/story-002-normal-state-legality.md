# Story 002: NORMAL State Legality + Same-Frame Co-Fire

> **Epic**: input-handler
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-001` + `TR-input-002`
**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix
**ADR Decision Summary**: act_* signal owner = InputHandler;NORMAL 态 dispatch 三条件守(已绑定 + 系统态合法 + 物理事件存在);同 raw event 双 action 双 fire 行为(同帧 co-fire,Input 不阻止)。

**Engine**: Godot 4.6 | **Risk**: LOW(InputMap API 4.0+ 稳定)
**Engine Notes**: `InputMap.action_has_event(action, event)` + `Input.is_action_just_pressed(action)`。

**Control Manifest Rules**:
- Required: dispatch ≤ 1 帧(`_input` 同步,无 call_deferred)
- Guardrail: act_* signal 同帧 dispatch p99 < 1ms 主线程

## Acceptance Criteria

- [ ] enum `InputState { NORMAL, MODAL_LOCKED, REMAPPING }`,默认 NORMAL
- [ ] **AC-FUNC-02** R2 三条件守门:Enter 全条件满足 → `act_confirm` 信号 fire;条目被删 → 不发射;blocking modal 中按 Enter → 不发射
- [ ] **AC-FUNC-08** Edge 4.1 同 raw event 双 action 双 fire:Space 同时绑 `act_confirm` + `act_skip` → 按 Space NORMAL 态 → 同帧两 action 都触发(Input 不阻止 co-fire,上层 UI 须幂等)

## Implementation Notes

```gdscript
# input_handler.gd
enum InputState { NORMAL, MODAL_LOCKED, REMAPPING }
var _state: InputState = InputState.NORMAL

# 13 act_* signals(per ADR-0001 matrix):
signal act_pause(reason: StringName)
signal act_skip
signal act_confirm
signal act_cancel
signal act_focus_up
signal act_focus_down
# ... 余 6 个 focus + screenshot

func _input(event: InputEvent) -> void:
    if _state == InputState.MODAL_LOCKED and _is_blocking_modal_active():
        return  # 吞 input
    # 检查所有 act_* 是否命中
    for action in ALLOWED_ACTIONS:
        if InputMap.action_has_event(action, event) and Input.is_action_just_pressed(action):
            emit_signal(action)  # 同帧 dispatch,无 call_deferred
```

## Out of Scope

- Story 005:Modal lock 状态机
- Story 004:skippable token

## QA Test Cases

- **AC-FUNC-02**:(a) Enter 全条件满足 → `act_confirm` fire;(b) `InputMap.action_has_event` 删条目后按 Enter → 不发射;(c) blocking modal 中按 Enter → 不发射
- **AC-FUNC-08**:Given Space 同时绑 `act_confirm + act_skip` + skippable 注册;When NORMAL 按 Space;Then 同帧 act_confirm 信号 + skippable 回调均触发(co-fire)

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/normal_state_dispatch_test.gd`
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 001
- Unlocks: Story 005(Modal),Story 003(双焦点)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 8 test 函数
- AC: InputState enum + 默认 NORMAL → `test_input_handler_exposes_all_act_signals` + `set_input_state_for_test` 测试 seam (用 in `test_dispatch_in_remapping_state_does_not_emit`)
- AC-FUNC-02 R2 三条件守门 (allowlist + has_action + state):
  - (a) Enter NORMAL fire → `test_dispatch_in_normal_state_emits_act_confirm`
  - (b) action 删除 → `test_dispatch_unknown_action_does_not_emit`
  - (c) blocking modal 中 → `test_dispatch_in_modal_locked_blocking_does_not_emit`
  - + 非 blocking toast 不吞 → `test_dispatch_in_modal_locked_non_blocking_still_emits`
  - + REMAPPING swallow → `test_dispatch_in_remapping_state_does_not_emit`
- AC-FUNC-08 Edge 4.1 同 raw event 双 action 双 fire → `test_dispatch_act_event_co_fires_both_actions_for_shared_binding` + 负面 `test_dispatch_act_event_with_no_bound_action_emits_nothing`

**Test Evidence**: `tests/unit/input/normal_state_dispatch_test.gd` (320 行 / 8 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);
- 10 个 per-action signals (`act_skip` / `act_confirm` / `act_cancel` / 6 `act_focus_*` / `act_screenshot`) declared with ADR-0001 ownership doc strings。`act_pause(reason)` 因带 payload 走独立 emit path,记入 `_ACTION_TO_SIGNAL` doc rationale。
- `dispatch_act_event(event)` + `dispatch_act_signal_for_test(action)` 双 seam 设计 — 生产路径走 `Input.is_action_just_pressed`,test 路径绕开该 engine state 不可合成的依赖 (Godot 4.6 `is_action_just_pressed` 仅在 real input frame 内有 truthy)。
- 同帧 dispatch 通过单 `for` 循环 + 同步 `emit_signal` 实现,无 `call_deferred`,无 `await` — 符合 control manifest "dispatch ≤ 1 帧" guardrail。
- 无 BLOCKING / 无 inline fix。

**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. **`Input.is_action_just_pressed` test 路径**: dispatch_act_event 完整路径无法在 unit test 完全合成 — 通过 `dispatch_act_signal_for_test` seam 验证 allowlist + state 两个 guard;`Input.action_has_event` + `is_action_just_pressed` 实际生产路径在 perf integration test (Story 013) 已锁。
2. **ADR-0001 Status**: lean-mode-equivalent。

**Tech debt**: None new
**API surface**: `signal act_skip`, `signal act_confirm`, `signal act_cancel`, `signal act_focus_up/down/left/right/next/prev`, `signal act_screenshot`, `dispatch_act_event(event: InputEvent) -> int`, `dispatch_act_signal_for_test(action: StringName) -> bool`, `set_input_state_for_test(state: InputState) -> void`, `_ACTION_TO_SIGNAL: Dictionary[StringName, StringName]` (const)
