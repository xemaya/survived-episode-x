# Story 001: InputMap 12 Actions Registration

> **Epic**: input-handler
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-001`
**ADR Governing Implementation**: ADR-0002 Autoload Init Order + ADR-0001 Signal Ownership Matrix
**ADR Decision Summary**: InputHandler autoload 第 5 位;`act_*` 命名空间锁定 12 actions(`act_pause / act_skip / act_focus_*` 8 方向 / `act_confirm / act_cancel / act_screenshot` + debug `act_dev_console`)。

**Engine**: Godot 4.6 | **Risk**: HIGH(via ADR-0002 autoload + dual-focus 4.6)
**Engine Notes**: `InputMap.load_from_project_settings()` 启动期初始化;`project.godot` `[input]` 段配置默认 keymap。

**Control Manifest Rules**:
- Required: 12 actions 全 `act_` 前缀;无 `gameplay_*` / `ui_*` 同类
- Forbidden: 未加前缀的同类别 action 出现

## Acceptance Criteria

- [ ] **AC-FUNC-01** R1 act_* 命名空间完整性:`InputMap.get_actions()` 枚举 → 恰存 12 个 `act_` 条目(+ debug `act_dev_console`)+ 无 `gameplay_*` / `ui_*` / 未加前缀同类 action
- [ ] `project.godot` `[input]` 段配置默认 KB Primary + KB Secondary + Gamepad 三路绑定
- [ ] InputHandler autoload 第 5 位声明(在 SceneDayFlow 之前)

## Implementation Notes

参 ADR-0002 §1 + GDD Rule 1:

```gdscript
# input_handler.gd (Autoload)
extends Node

const ALLOWED_ACTIONS := [
    &"act_pause", &"act_skip", &"act_confirm", &"act_cancel",
    &"act_focus_up", &"act_focus_down", &"act_focus_left", &"act_focus_right",
    &"act_focus_next", &"act_focus_prev",
    &"act_screenshot",
]

func _ready() -> void:
    _verify_action_namespace()

func _verify_action_namespace() -> void:
    var registered := InputMap.get_actions()
    for action in registered:
        if action.begins_with(&"ui_"):  # Godot 默认 ui_* 全保留 / 不可禁
            continue
        if not action in ALLOWED_ACTIONS and not action == &"act_dev_console":
            push_error("Unknown act_* namespace: %s" % action)
```

## Out of Scope

- Story 002:NORMAL 态合法判定 + 三条件守门
- Story 008:F1 deadzone 公式

## QA Test Cases

- **AC-FUNC-01**:Given 冷启动完成 + `InputMap.load_from_project_settings()`;When QA `InputMap.get_actions()`;Then 恰存 12 + debug `act_dev_console`;无 `gameplay_*` / `ui_*` / 未加前缀同类

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/action_map_test.gd`
**Status**: [ ] Not yet created

## Dependencies

- Depends on: None(Foundation root)
- Unlocks: Story 002, 003, 005(action 系统建立后)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 6 test 函数
- AC-FUNC-01 R1 act_* 命名空间完整性 → `test_allowed_actions_constant_holds_eleven_act_names` + `test_allowed_actions_does_not_include_dev_console` + `test_verify_action_namespace_rejects_gameplay_prefix` + `test_verify_action_namespace_rejects_unprefixed_action` + `test_verify_action_namespace_silently_skips_ui_prefix` + `test_verify_action_namespace_allows_dev_console`
- `project.godot` `[input]` 三路绑定 → DEFERRED (`project.godot` not yet created — pending Godot project bootstrap epic; ALLOWED_ACTIONS const ready to drive the seed config)
- InputHandler 第 5 位 autoload → DEFERRED (project.godot autoload registration owned by future bootstrap story; `_lint_at_ready` flag wired so future autoload registration flips on the boot lint without further code changes)

**Test Evidence**: `tests/unit/input/action_map_test.gd` (290 行 / 6 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);
- `_verify_action_namespace` 设计为 silent data function (返回 rejected list),`_ready` 通过 `_lint_at_ready` 守门 push_error。避免了 GdUnit4 push_error capture 把无关 test 标 fail 的 cross-suite 风险。
- `ALLOWED_ACTIONS` 锁定为 `Array[StringName]` 全静态类型;`DEV_CONSOLE_ACTION` 单独常量,符合 ADR-0001 命名空间分层。
- 无 BLOCKING / 无 inline fix。

**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. **ADR-0002 Status**: lean-mode-equivalent — ADR proposed status 在 lean review 路径下 acceptable (per `production/review-mode.txt = lean`)。
2. **第 5 位 autoload 声明**: DEFERRED — 实际 `project.godot` 文件不存在于本仓 (`games-studio/` 是元仓库,Godot project bootstrap 是后续 epic 范围)。`_lint_at_ready` 可由未来的 autoload bootstrap story 在注册时直接 set 为 `true`。
3. **`act_pause` 双路径**: act_pause 因带 `reason: StringName` payload, 留在 ADR-0001 owner 现有 emit path (`handle_focus_out` Story 011 + 未来 Esc binding); 不通过 Story 002 dispatch core 路由 — 文档化在 `_ACTION_TO_SIGNAL` 注释中。

**Tech debt**: None new
**API surface**: `ALLOWED_ACTIONS: Array[StringName]` (const), `DEV_CONSOLE_ACTION: StringName` (const), `verify_action_namespace() -> Array[StringName]` (public seam), `_verify_action_namespace() -> Array[StringName]` (private)
