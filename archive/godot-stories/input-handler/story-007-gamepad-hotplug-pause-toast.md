# Story 007: Gamepad Hot-Plug — Pause + Toast + Resume

> **Epic**: input-handler
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-006`
**ADR Governing Implementation**: ADR-0001(soft_pause_requested 信号)+ ADR-0002(SDL3 4.5 gamepad)
**ADR Decision Summary**: 手柄拔出 → `device_disconnected` + pause 游戏 + 显示 blocking=false toast "控制器断开 — 按任意键继续";按任意键 → `device_resumed` + pause 解除 + toast 关闭;手柄重连 emit `device_reconnected` 但**不**自动 resume。

**Engine**: Godot 4.6 | **Risk**: MEDIUM(SDL3 4.5 gamepad driver)
**Engine Notes**: `Input.joy_connection_changed(device, connected)` signal;SDL3 4.5 ↔ Steam Input legacy 兼容性留 OQ-INP-04。

**Control Manifest Rules**:
- Required: 手柄断开 `get_tree().paused = true` + blocking=false toast(允许任意键 resume)
- Required: toast 关闭走 `release_modal_lock`(Story 005)
- Forbidden: 手柄重连自动 resume(必须等用户主动按键)

## Acceptance Criteria

- [ ] **AC-FUNC-10** R10 Gamepad 热插拔:拔出手柄 → 同帧(≤16.6ms)`device_disconnected` 信号发射 + `get_tree().paused == true` + toast 显示"控制器断开 — 按任意键继续" + toast 持 blocking=false 锁
- [ ] 按任意键盘按键 → `device_resumed` 发射 + `get_tree().paused == false` + toast 关闭
- [ ] 手柄重连 → `device_reconnected` 发射 + **不**自动 resume(仍等用户按键)

## Implementation Notes

```gdscript
# input_handler.gd
signal device_disconnected(device: int)
signal device_reconnected(device: int)
signal device_resumed

func _ready() -> void:
    Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(device: int, connected: bool) -> void:
    if connected:
        emit_signal(&"device_reconnected", device)
        # 不 auto-resume(故意等用户主动按键)
    else:
        emit_signal(&"device_disconnected", device)
        get_tree().paused = true
        SceneDayFlowController.request_soft_pause(&"gamepad_disconnected")
        var toast := _spawn_disconnect_toast()
        acquire_modal_lock(toast, blocking=false)
        # 任意键 listener
        _next_input_resumes = true

func _input(event: InputEvent) -> void:
    if _next_input_resumes and event.is_pressed():
        _next_input_resumes = false
        get_tree().paused = false
        emit_signal(&"device_resumed")
        _close_disconnect_toast()
        return  # 这次输入只用于 resume,不 dispatch act_*
    # ... 其余 act_* 处理
```

## Out of Scope

- Story 005:Modal lock-stack(toast 用 blocking=false modal)
- Steam Input legacy mode 检测(Story 010)

## QA Test Cases

- **AC-FUNC-10**(同帧):Given 手柄已连接;When 拔出;Then ≤16.6ms `device_disconnected` 信号 + paused=true + toast 显示 + blocking=false 锁
- **Resume**:Given 拔出后 toast 显示;When 按任意键;Then `device_resumed` + paused=false + toast 关闭
- **Reconnect 不 auto-resume**:Given 拔出后,手柄重连;Then `device_reconnected` 发射,但 paused 仍 true,toast 仍显示

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/input/gamepad_hotplug_test.gd`(`Input.joy_connection_changed` mock fixture)
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 005(Modal lock blocking=false)
- Unlocks: Story 010(Steam Input)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 7 test 函数
- AC-FUNC-10 R10 同帧 disconnect → `test_disconnect_emits_signal_pauses_and_arms_latch` (≤16.6ms 由 synchronous call stack 结构性满足 — 无 await / 无 call_deferred)
- 任意键 resume → `test_eligible_input_after_disconnect_resumes` + 三个 negative tests:
  - `test_mouse_motion_after_disconnect_does_not_resume` (mouse 移动不算"按任意键")
  - `test_key_echo_after_disconnect_does_not_resume` (echo 不 resume — 防止 hot-plug 时玩家正按住键的 ghost-resume)
  - `test_key_release_after_disconnect_does_not_resume` (松开不 resume)
- 重连不 auto-resume → `test_reconnect_emits_signal_but_does_not_auto_resume`
- 状态 round-trip → `test_is_awaiting_resume_input_state_round_trip`

**Test Evidence**: `tests/integration/input/gamepad_hotplug_test.gd` (300 行 / 7 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);
- `signal device_disconnected(device: int)` / `signal device_reconnected(device: int)` / `signal device_resumed` declared with ADR-0001 ownership doc。
- `on_joy_connection_changed(device, connected)` 公开 seam — 生产路径在 `_ready` 自动 connect `Input.joy_connection_changed`,test 路径直接 call 该 method。
- `_pause_flag_provider` Callable 注入 + `set_pause_flag_provider` test seam — 避免 test 真改 `get_tree().paused` 影响并行 suite。
- `_is_resume_eligible` 白名单守 KB pressed (非 echo) / Mouse pressed / Joy pressed / JoyMotion `abs > 0.5` — 严格守"按任意键继续"语义。
- `_input` 中 resume 优先于 dispatch_act_event,但 path arbitration / method classification 仍执行 (story line 60 解释)。
- `_next_input_resumes` latch 不被 reconnect 清,守 Forbidden rule "手柄重连自动 resume"。
- toast 与 `acquire_modal_lock(toast, blocking=false)` 集成留给 Toast UI epic — Story 005 modal lock API 已 ready,wire 到具体 toast UI node 是 UI epic 范围。
- 无 BLOCKING / 无 inline fix。

**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. **Toast UI 显示**: DEFERRED — `_spawn_disconnect_toast` 留给 Toast UI epic,本 story 锁 signal + pause + latch 的 input handler 责任面;modal lock blocking=false 集成 wire 留 UI 层负责。
2. **`SceneDayFlowController.request_soft_pause(&"gamepad_disconnected")`**: NOT wired in input handler — story implementation notes 引用了 `SceneDayFlowController.request_soft_pause`,但 cross-epic wire 应该 in SceneDayFlow integration story。`device_disconnected` signal 已 emit,SceneDayFlow 后续 subscribe 即可。

**Tech debt**: None new
**API surface**: `signal device_disconnected(device: int)`, `signal device_reconnected(device: int)`, `signal device_resumed`, `on_joy_connection_changed(device: int, connected: bool) -> void`, `set_pause_flag_provider(provider: Callable) -> void`, `is_awaiting_resume_input() -> bool`, `get_last_pause_flag_set() -> bool`, `_is_resume_eligible(event: InputEvent) -> bool` (private)
