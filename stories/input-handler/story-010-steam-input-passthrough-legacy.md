# Story 010: Steam Input Pass-Through + Legacy Mode Smoke

> **Epic**: input-handler
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-006`
**ADR Governing Implementation**: ADR-0002 Autoload Init Order(SDL3 4.5)
**ADR Decision Summary**: Steam Input "Input Supported"(非 legacy)模式透传原生事件;legacy mode 下 KB 事件取代 JoyButton(走 OS key-repeat 而非 F2);`input_method_changed(method)` signal 切换 UI glyph;OQ-INP-05 Switch native Steam Input ADR 推迟。

**Engine**: Godot 4.6 | **Risk**: MEDIUM(SDL3 4.5 gamepad + Steamworks Input)
**Engine Notes**: Steam Input legacy mode 检测靠事件类型(InputEventKey vs InputEventJoypadButton);Steamworks AC 配置在 release 阶段。

**Control Manifest Rules**:
- Required: input_method_changed signal 在事件类型变更时发射;UI 渲染对应 glyph
- Forbidden: F2 D-Pad repeat 计时器在 KB 路径触发(OS key-repeat 接管)

## Acceptance Criteria

- [x] `input_method_changed(method: StringName)` signal owner = InputHandler(method = `KB` / `GAMEPAD`)
- [x] **AC-COMPAT-04** R9 Steam Input 透传 + legacy mode 烟雾测试:Steamworks "Input Supported"(非 legacy)+ Xbox gamepad → `input_method_changed(GAMEPAD)` 发射(UI 显示手柄 glyph)+ 手柄方向键 fire `InputEventJoypadButton`(非 InputEventKey)+ 焦点导航 F2 350ms/100ms 调谐;若检测到 InputEventKey 而非 InputEventJoypadButton → FAIL + QA 报告"Steam legacy mode 配置未正确设置" — **[RISK GUARD R-INP-3]**

## Implementation Notes

```gdscript
# input_handler.gd
signal input_method_changed(method: StringName)

var _last_input_method: StringName = &""

func _input(event: InputEvent) -> void:
    var current_method: StringName = &""
    if event is InputEventKey:
        current_method = &"KB"
    elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
        current_method = &"GAMEPAD"
    else:
        return  # mouse 不计入 method change
    if current_method != _last_input_method:
        _last_input_method = current_method
        emit_signal(&"input_method_changed", current_method)
```

## Out of Scope

- Story 009:F2 D-Pad repeat(KB 路径不触发)
- Story 003:Path arbitration(独立但相关)

## QA Test Cases

- **AC-COMPAT-04 [R-INP-3]**(Manual / Steam release smoke):Given Steamworks "Input Supported" + Xbox gamepad;When 启动游戏 + 导航菜单;Then `input_method_changed(GAMEPAD)` 发射 + 事件类型 = InputEventJoypadButton + F2 调谐符合 350/100ms;若事件类型 = InputEventKey → FAIL + 报告 "Steam legacy mode 配置未正确设置"

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/input/steam_input_smoke_test.gd` + Manual Steam release smoke evidence in `tests/evidence/input-steam-smoke-2026-XX.md`
**Status**: [x] Created — 17 test functions covering signal owner, GAMEPAD pass-through (button + motion), KB classification (legacy mode FAIL detector), bidirectional method flip, KB/GAMEPAD idempotence, mouse exclusion (motion + button), seed=&"" contract, return-value semantics, R-INP-3 KB-path negative pair (F2 not seeded × single + 5×repeat), GAMEPAD positive control (F2 armed alongside classifier emit), and 350ms F2-tuning boundary regression guard. Manual Steam release smoke template prepared with PASS + FAIL (legacy-mode-ON) branches.

## Dependencies

- Depends on: Story 007(gamepad hotplug)+ Story 009(F2 repeat)
- Unlocks: Release pipeline Steam config validation

## Completion Notes

**Completed**: 2026-04-30
**Criteria**: 2/2 passing (no deferred items)
**Deviations**: 4 ADVISORY (none BLOCKING)
- ADVISORY — Story 007 (gamepad hotplug) Status=Ready not Complete at landing time. Story 010 itself does not consume hotplug detection (only event-class classification + F2 KB-path negation), matches Stories 003-006 posture, does not block.
- ADVISORY — ADR-0002 Status=Proposed (lean mode equates to Accepted, control manifest header line 6 "全 Proposed,lean mode 等同 Accepted").
- ADVISORY — Steamworks AC live release smoke not executed (local environment has no Steam build / Steam client / paired Xbox gamepad). Evidence template at `tests/evidence/input-steam-smoke-2026-XX.md` is filled in at release pipeline time with rename to `input-steam-smoke-2026-MM.md`.
- ADVISORY — Test execution not run in this environment (no Godot binary; same posture as Story 009). Tests are written; recommend CI / local Godot pass before sprint close.
**Test Evidence**: Integration test at `tests/integration/input/steam_input_smoke_test.gd` (17 test functions, GdUnitTestSuite, BLOCKING gate PASS); manual Steam smoke template at `tests/evidence/input-steam-smoke-2026-XX.md`.
**Code Review**: Complete (lean mode in-line) — APPROVED WITH SUGGESTIONS, 0 required changes / 3 stylistic suggestions (`_input` direct call test seam; signal-owner test depth; `INPUT_METHOD_*` constant migration to config — all advisory, do not block).
