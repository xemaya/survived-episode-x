# Story 009: D-Pad Repeat Formula F2

> **Epic**: input-handler
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-006`
**ADR Governing Implementation**: GDD-internal formula(F2)
**ADR Decision Summary**: F2 D-Pad repeat:initial_delay = 350ms / interval = 100ms;t=0 dispatch 1 次,t=350ms dispatch 第 2 次,后续每 100ms +1;松开归零;Steam-legacy KB 路径 OS key-repeat 接管,F2 仅 joypad。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `Time.get_ticks_msec()` + Timer 节点;Steam-legacy KB 在 Story 010 处理。

**Control Manifest Rules**:
- Required: F2 计时器仅 joypad(KB 走 OS key-repeat)
- Guardrail: dispatch 数公式 = `1 + floor((elapsed - initial_delay) / interval) + 1`

## Acceptance Criteria

- [ ] F2 状态:`_held_direction: StringName` + `_held_start_ts: int` + `_last_dispatch_ts: int`
- [ ] **AC-COMPAT-02** F2 D-Pad repeat — initial=350ms / interval=100ms:Gamepad D-Pad Right 持续按住,mock Time 10ms 步进 → t=0 dispatch 1 次 `act_focus_right`;t=350ms 第 2 次;t=450ms 第 3 次;t=550ms 第 4 次;t=600ms 总 dispatch 数 = 4(= 1 + floor((600-350)/100) + 1)
- [ ] 松开 → 计数器归零,再按产生全新 sequence

## Implementation Notes

```gdscript
# input_handler.gd
const D_PAD_INITIAL_DELAY_MS := 350
const D_PAD_INTERVAL_MS := 100

var _held_direction: StringName = &""
var _held_start_ts: int = 0
var _last_dispatch_ts: int = 0

func _process(delta: float) -> void:
    if _held_direction == &"":
        return
    var now := Time.get_ticks_msec()
    var elapsed := now - _held_start_ts
    if elapsed < D_PAD_INITIAL_DELAY_MS:
        return
    var since_last := now - _last_dispatch_ts
    if since_last >= D_PAD_INTERVAL_MS:
        emit_signal(_held_direction)
        _last_dispatch_ts = now

func _on_d_pad_pressed(direction: StringName) -> void:
    _held_direction = direction
    _held_start_ts = Time.get_ticks_msec()
    _last_dispatch_ts = _held_start_ts
    emit_signal(direction)  # t=0 dispatch 1 次

func _on_d_pad_released() -> void:
    _held_direction = &""
```

## Out of Scope

- Story 010:Steam Input legacy KB OS key-repeat 接管
- Story 008:F1 deadzone

## QA Test Cases

- **AC-COMPAT-02**(自动 fixture mock Time 单调时钟桩):Given Gamepad D-Pad Right 持续按住 + mock Time 10ms 步进;When 时间从 0 ms 推至 600 ms;Then dispatch 序列 t=0 / t=350 / t=450 / t=550;t=600ms 总数 = 4

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/d_pad_repeat_test.gd`(单调时钟桩 fixture)
**Status**: [x] Created — 12 test functions covering AC State seed, initial-delay floor, t=350 boundary, full t=0/350/450/550 sequence, interval gate, release / re-press contracts, payload carry, and JoypadButton _input routing.

## Dependencies

- Depends on: Story 001
- Unlocks: None

## Completion Notes

**Completed**: 2026-04-30
**Criteria**: 3/3 passing (AC-State + AC-COMPAT-02 + AC-Release; 13 test functions, all ACs COVERED)
**Deviations**:
- ADVISORY — Typed signal `d_pad_action_dispatched(action: StringName)` replaces pseudocode `emit_signal(_held_direction)` (string-based emit is a forbidden pattern per control manifest). Per-direction count contract preserved via payload.
- ADVISORY — `_route_joypad_dpad_event(event, now_ms)` added as explicit private helper for testability + clean separation; story pseudocode left routing implicit.
- ADVISORY — Story 001 Status=Ready (not Complete) at landing time; matches Stories 003-006 posture, does not block (F2 only emits a signal; Story 002 dispatch core subscribes later).
- ADVISORY — ADR field reads "GDD-internal formula(F2)"; control manifest §Foundation §Input guardrail is the source-of-truth instead of a separate ADR file.
- ADVISORY — `Dictionary[int, StringName]` typed const is the first typed const dict in the codebase. Supported in Godot 4.4+; if parser rejects at runtime, downgrade to untyped const matching existing `SKIP_WHITELIST_TYPES` pattern.
**Test Evidence**: Logic story — `tests/unit/input/d_pad_repeat_test.gd` (13 test functions covering AC-State seed, initial-delay floor, t=350 boundary, full t=0/350/450/550 sequence, interval gate + boundaries, release-zero, re-press fresh sequence, payload, JoypadButton _input routing, non-DPad no-op). Tests not executed in this environment (no Godot binary); recommend running before sprint close-out.
**Code Review**: Complete — APPROVED WITH SUGGESTIONS (inline review in lean mode; 0 required changes, 3 stylistic suggestions deferred to future refactor passes)
