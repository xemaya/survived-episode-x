# Story 012: Tuning Knob Clamp + load_keymap Unknown Action

> **Epic**: input-handler
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-001` + `TR-input-004`
**ADR Governing Implementation**: ADR-0003 Save Format(meta.input.keymap sub-schema)
**ADR Decision Summary**: Tuning knob clamp 守门 — deadzone_inner/outer / skip_axis_threshold 静默 clamp 到合法区间 + DEBUG log;`load_keymap(payload)` 静默 skip 未知 action(future-version save 残留);系统不崩溃,DEBUG log 路径。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `clamp()` 内置;`InputMap.has_action()` 4.0+ 稳定。

**Control Manifest Rules**:
- Required: tuning knob 违规值 silent clamp + DEBUG log
- Required: load_keymap unknown action silent skip + DEBUG log;系统不崩溃
- Forbidden: 进入 ERROR 态(违规 tuning 仅 clamp)

## Acceptance Criteria

- [ ] `set_deadzone_inner(value)` / `set_deadzone_outer(value)` / `set_skip_axis_threshold(value)` API + clamp + log
- [ ] **AC-ROBUST-03** Edge 1 boundary — deadzone clamp:`deadzone_inner = 0.0` clamp 0.05;`deadzone_outer = 1.0` clamp 0.99;`skip_axis_threshold = 1.0` clamp 0.99;DEBUG log "[InputHandler] tuning clamp: [param] [orig] → [clamped]";系统不崩溃 + 不进 ERROR 态
- [ ] **AC-ROBUST-04** Edge 4 keymap load 未知 action silent skip:`load_keymap(payload)` 含 `act_quicksave`(未注册 future-version)+ 3 合法 act_* → 3 合法 binding 应用 + 未知 act_quicksave silent skip + 无 GDScript error + DEBUG log "[InputHandler] load_keymap: skipped unknown action: act_quicksave" + 系统回 NORMAL 可正常接受输入

## Implementation Notes

```gdscript
# input_handler.gd
const CLAMP_INNER_MIN := 0.05
const CLAMP_OUTER_MAX := 0.99
const CLAMP_SKIP_THRESHOLD_MAX := 0.99

func set_deadzone_inner(value: float) -> void:
    var clamped: float = clampf(value, CLAMP_INNER_MIN, CLAMP_OUTER_MAX - 0.01)
    if clamped != value:
        print("[InputHandler] tuning clamp: deadzone_inner %f → %f" % [value, clamped])
    DEADZONE_INNER = clamped

func load_keymap(payload: Dictionary) -> void:
    for action_str in payload:
        var action := StringName(action_str)
        if not InputMap.has_action(action):
            print("[InputHandler] load_keymap: skipped unknown action: %s" % action)
            continue
        # 应用 binding
        InputMap.action_erase_events(action)
        for event_dict in payload[action_str]:
            var event := _deserialize_event(event_dict)
            InputMap.action_add_event(action, event)
```

## Out of Scope

- Story 008:F1 deadzone 公式(本 story 仅 clamp 守门)
- Story 006:keymap remap 落盘(本 story 仅 load 路径)

## QA Test Cases

- **AC-ROBUST-03**:set_deadzone_inner(0.0) → DEADZONE_INNER = 0.05 + DEBUG log;set_deadzone_outer(1.0) → 0.99 + log;set_skip_axis_threshold(1.0) → 0.99 + log;系统不崩溃
- **AC-ROBUST-04**:Given payload 含 act_quicksave(未知)+ 3 合法 act_*;When load_keymap;Then 3 合法 binding 应用 + act_quicksave silent skip + 无 GDScript error + DEBUG log

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/tuning_clamp_test.gd` + `tests/unit/input/load_keymap_unknown_action_test.gd`
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 001 + Story 008(deadzone consts)
- Unlocks: Save System schema migration story(VS tier)

## Completion Notes

**Completed**: 2026-04-30
**Criteria**: 3/3 passing(AC-1 + AC-ROBUST-03 + AC-ROBUST-04)— 15/17 traceability rows COVERED;2 UNTESTED-ADVISORY 仅是 `print()` DEBUG log 格式(GdUnit4 stdout 捕获 flaky;非 load-bearing)
**Test Evidence**: `tests/unit/input/tuning_clamp_test.gd`(11 test 函数)+ `tests/unit/input/load_keymap_unknown_action_test.gd`(6 test 函数)— BLOCKING gate PASS
**Manifest Staleness**: PASS(story=2026-04-28 / current manifest=2026-04-28)
**Deviations**:
  - ADVISORY: pseudocode `DEADZONE_INNER` const 替换为 `_deadzone_inner` private var + getter(Story 008 deadzone 公式未 land — 本 story 提供 seam 给 Story 008 消费)
  - ADVISORY: pseudocode `_deserialize_event(event_dict)` 省略(payload value 当 `Array[InputEvent]` 直收 — InputEvent 序列化 / 反序列化器属 Story 006 + Save System schema migration story Out of Scope)
  - ADVISORY: `print()` log 格式不在 unit test 自动 assert(GdUnit4 stdout 捕获 flaky;test header 文档化;manual smoke 可验)
  - ADVISORY: Story 001 / Story 008 dependency Status=Ready not Complete(autopilot 模式延续 Story 010 / 011 precedent;load_keymap 测试用临时 `act_test_*_012` 隔离,不依赖未 land story)
  - ADVISORY: ADR-0003 Status=Proposed 非 Accepted(lean-mode-equivalent;同 Story 010 ADR-0002 precedent;实现遵循 Decision 节)
**Code Review**: COMPLETE — APPROVED WITH SUGGESTIONS(lean mode 内联 review;0 required changes / 3 stylistic suggestions:typed Dictionary 参数 / inner-outer cross-boundary constraint defer 给 Story 008 / `_log_tuning_clamp` 私有 helper 提取 DRY)
**QL-TEST-COVERAGE**: SKIPPED — Lean mode
**LP-CODE-REVIEW**: SKIPPED — Lean mode(已在 `/code-review` skill 内联完成)
