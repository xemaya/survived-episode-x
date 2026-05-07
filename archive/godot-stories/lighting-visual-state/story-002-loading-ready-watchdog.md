# Story 002: LOADING/READY State + 10s Watchdog

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-002`
**ADR**: ADR-0001(`_mark_ready` signal)+ ADR-0002(autoload + watchdog Timer PAUSE_INHERIT)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: LOADING/READY + `lighting_loading_watchdog_ms = 10000ms`(同 audio 同模式)
- Required: `lighting_visual_state_ready` signal 一次

## Acceptance Criteria

- [ ] enum `LightingState { LOADING, READY }` + `_mark_ready()` 私有
- [ ] watchdog 10000ms:LOADING 永不 ready → push_error + 强制 READY + flush pending queue
- [ ] R-LVS-2:超时 push_error,启动序列继续(Pillar 5 5s 守)

## Implementation Notes

类似 Audio Story 003,watchdog Timer + force READY:

```gdscript
const LIGHTING_LOADING_WATCHDOG_MS := 10000
signal lighting_visual_state_ready

func _on_watchdog_timeout() -> void:
    push_error("[LightingController] LOADING exceeded 10000ms — force READY")
    _state = LightingState.READY
    emit_signal(&"lighting_visual_state_ready")
```

## QA Test Cases

- LOADING 永不 ready → 10s watchdog 触发 + force READY + signal 发射
- 合法 ≤ 10s ready → watchdog 不触发

## Test Evidence

`tests/integration/lighting/loading_watchdog_test.gd`(单调时钟桩)

## Dependencies

- Depends on: Story 001(8 sub-mode)
- Unlocks: Scene Flow 协作(`_mark_ready` 启动序列)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 4 test 函数(`LIGHTING_LOADING_WATCHDOG_MS = 10000` / `_mark_ready` idempotent + emit 一次 / watchdog 超时 force READY + emit / 二次超时 idempotent)
**Test Evidence**: `tests/integration/lighting/loading_watchdog_test.gd`(70 行 / 4 tests / GdUnit4)— BLOCKING gate PASS;同步 `force_watchdog_timeout_for_test()` 替代 10s 等待 (deterministic)
**Code Review**: APPROVED(lean-mode autopilot inline);Timer `process_mode = PROCESS_MODE_PAUSABLE` 与 audio Story 003 watchdog 一致;`_ready_emitted` flag 防 double-emit;无 BLOCKING / 无 inline fix
**Engine API Verification**: Godot 4.6 `Node.PROCESS_MODE_PAUSABLE` = PAUSE_INHERIT alias(per `scene_day_flow_controller.gd` doc L20);Timer `one_shot=true` + `timeout` signal 4.0+ 稳定
**Deviations**(1 项 ADVISORY):
1. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `LightingState` enum(LOADING/READY)+ `LIGHTING_LOADING_WATCHDOG_MS` const + `_mark_ready()` 私有 + `lighting_visual_state_ready` signal + `state` 公有读 + 2 个 test seam
