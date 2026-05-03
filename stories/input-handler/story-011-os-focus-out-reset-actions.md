# Story 011: OS Focus Out — reset_all_action_presses Guard

> **Epic**: input-handler
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-001`
**ADR Governing Implementation**: ADR-0001 + 协作 ADR-0002 + Audio Manager Story 协作(act_pause + WM_FOCUS_OUT 公版)
**ADR Decision Summary**: OS 失焦持键 ghost 防御 — `NOTIFICATION_WM_WINDOW_FOCUS_OUT` 通知到达时调 `Input.reset_all_action_presses()`;F2 计时器重置;焦点恢复后无 ghost `act_focus_*` 重复发射;与 `#6 Scene Flow` `act_pause` 公版协调(Music → -∞ 200ms / Ambient → -24 300ms)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `NOTIFICATION_WM_WINDOW_FOCUS_OUT` Godot 4.0+ 稳定;`Input.reset_all_action_presses()` 4.5 SDL3 兼容。

**Control Manifest Rules**:
- Required: WM_FOCUS_OUT 同 notification 内调 reset_all_action_presses
- Required: F2 计时器重置
- Guardrail: 焦点恢复后无 ghost act_focus_* 发射(R-INP-4)

## Acceptance Criteria

- [x] `_notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT)` 处理 + `Input.reset_all_action_presses()` 调用
- [x] F2 状态(_held_direction / _held_start_ts)重置
- [x] **AC-ROBUST-01** Edge 9.1 OS 失焦持键 reset_all_action_presses 守门:玩家按住 D-Pad Right(或 KB 右方向键)+ F2 repeat 计时运行 → OS 窗口失焦(`NOTIFICATION_WM_WINDOW_FOCUS_OUT`)→ Input Handler 同 notification 内调 `Input.reset_all_action_presses()`(GUT mock 断言)+ 所有 held-direction 计时器重置 0 + 焦点恢复后无 ghost `act_focus_*` 重复发射(再次聚焦不按任何键 → 0 dispatch)

## Implementation Notes

```gdscript
# input_handler.gd
func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        Input.reset_all_action_presses()
        _held_direction = &""
        _held_start_ts = 0
        _last_dispatch_ts = 0
        # 协作:emit act_pause(reason=&"focus_out")
        emit_signal(&"act_pause", &"focus_out")
```

## Out of Scope

- Story 009:F2 D-Pad repeat(本 story 仅复位)
- Audio epic Story:`act_pause` 公版协作(Music fade -∞ 200ms / Ambient -24 300ms)

## QA Test Cases

- **AC-ROBUST-01**:Given D-Pad Right 持续按住 + F2 repeat 计时;When `NOTIFICATION_WM_WINDOW_FOCUS_OUT`;Then 同 notification 内 `Input.reset_all_action_presses()` 调用 + held-direction 计时器 = 0 + 再次聚焦不按任何键 → 0 dispatch

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/input/focus_out_reset_test.gd`
**Status**: [x] Created — 11 test functions covering: reset-provider invocation count, F2 state clear, no-ghost dispatch after focus-out, act_pause(focus_out) emission, signal owner, idempotent repeat focus-out, cold-start safety, fresh-press re-arm path, _notification → handle_focus_out routing, unrelated-notification filter, and seam wiring lock.

## Dependencies

- Depends on: Story 001 + Story 009(F2 计时器)
- Unlocks: Audio epic Story(`act_pause` 公版协作)

## Completion Notes
**Completed**: 2026-04-30
**Criteria**: 3/3 passing — all ACs covered by 11 integration test functions in `tests/integration/input/focus_out_reset_test.gd`
**Files changed**:
- `src/autoload/input_handler.gd` — added `signal act_pause(reason: StringName)` (architecture.md L306 + ADR-0001 owner = InputHandler); added `_reset_actions_provider: Callable` test seam defaulting to `Input.reset_all_action_presses`; added `_notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT)` filter virtual; added public `handle_focus_out()` seam (calls reset provider, zeroes Story 009 F2 ticker state, emits `act_pause(&"focus_out")`); added `set_reset_actions_provider()` setter mirroring `set_clock_provider` pattern; updated module header docstring with Story 011 R-INP-4 explanation
- `tests/integration/input/focus_out_reset_test.gd` — new integration test suite (11 functions)
**Test Evidence**: Integration test at `tests/integration/input/focus_out_reset_test.gd` ✓ (BLOCKING gate PASS)
**Code Review**: Complete (lean-mode inline at `/code-review` — APPROVED WITH SUGGESTIONS / 0 required changes / 3 stylistic non-blocking suggestions)
**Deviations** (all ADVISORY — none BLOCKING):
- Story 001 dependency Status=Ready (not Complete) — accepted per Stories 003-010 batch-approval posture; F2 ticker emits signal regardless, downstream Story 002 dispatch consumer subscribes later
- act_pause `&"player"` reason path (player-issued Esc/Start) deferred to Story 002 NORMAL-state action dispatch; Story 011 wires only `&"focus_out"` reason
- Audio Manager Music fade -∞/200ms + Ambient -24dB/300ms reaction is owned by Audio Manager epic (TR-audio-007); Story 011 only verifies InputHandler emits the signal contract correctly
- Real OS-window-focus-loss smoke evidence (Win / Linux / macOS) cannot fire from headless GdUnit; manual evidence template captured at `tests/evidence/input-focus-out-2026-XX.md` for post-launch capture
- QL-TEST-COVERAGE skipped — Lean mode
- LP-CODE-REVIEW skipped — Lean mode (lean inline review completed at /code-review skill)
**Tech debt logged**: None (deviation 全 ADVISORY 性质,均与 Story 009 / 010 同性质,未升 tech-debt-register)
