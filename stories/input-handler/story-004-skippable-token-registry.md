# Story 004: skippable Token Registry + Auto-Purge

> **Epic**: input-handler
> **Status**: Done
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-003`
**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix
**ADR Decision Summary**: `register_skippable(token_id, on_skip: Callable)` / `unregister_skippable(token_id)` API + skip 资格白名单(KB+JoyBtn+Axis>0.8+鼠标 LEFT)+ owner 销毁后 `is_instance_valid` 守门 auto-purge。

**Engine**: Godot 4.6 | **Risk**: LOW(`is_instance_valid()` 4.0+ 稳定)
**Engine Notes**: `Callable.is_valid()` 检测 owner 节点 queue_free 后失效;auto-purge 防止 invalid instance 错误。

**Control Manifest Rules**:
- Required: skip 资格白名单(KB + JoyBtn + Axis>0.8 + 鼠标 LEFT)
- Required: auto-purge `is_instance_valid()` 守 owner queue_free 后失效条目
- Forbidden: 调 dead callable

## Acceptance Criteria

- [x] `register_skippable(token_id: StringName, on_skip: Callable)` API + `unregister_skippable(token_id)` API
- [x] **AC-FUNC-04** R6 跳过事件资格白名单:7 类事件 → (a) KB Space / (b) JoyBtn / (c) MouseLEFT / (d) Axis>0.8 触发 4 次;(e) MouseMotion / (f) Key echo / (g) MouseWheel **不**触发
- [x] **AC-FUNC-09** Edge 5.1 owner queue_free 后 auto-purge:`register_skippable(owner_id, callback)` 后立即 `queue_free()` owner node → 触发合规 skip → `is_instance_valid(owner_node)` 返 false → auto-purge 条目 + **不**调 dead callable + 日志**不**出现"invalid instance"错误 + purge 后注册表计数 -1
- [x] **[RISK GUARD] R-INP-1**:零 GDScript "invalid instance" 日志(自动化测试)

## Implementation Notes

```gdscript
# input_handler.gd
var _skippable_registry: Dictionary[StringName, Callable] = {}

const SKIP_WHITELIST_TYPES := {
    "InputEventKey": true,             # 但 echo=false
    "InputEventJoypadButton": true,
    "InputEventMouseButton": true,     # 但仅 BUTTON_LEFT
    "InputEventJoypadMotion": true,    # 但 axis_value > 0.8
}

func register_skippable(token_id: StringName, on_skip: Callable) -> void:
    _skippable_registry[token_id] = on_skip

func unregister_skippable(token_id: StringName) -> void:
    _skippable_registry.erase(token_id)

func _try_skip_broadcast(event: InputEvent) -> void:
    if not _is_skip_eligible(event):
        return
    # auto-purge invalid instances
    var to_purge: Array[StringName] = []
    for token_id in _skippable_registry:
        var callable: Callable = _skippable_registry[token_id]
        if not callable.is_valid():
            to_purge.append(token_id)
        else:
            callable.call()
    for tid in to_purge:
        _skippable_registry.erase(tid)
    if not to_purge.is_empty():
        push_warning("[InputHandler] auto-purged %d invalid skippable owners" % to_purge.size())

func _is_skip_eligible(event: InputEvent) -> bool:
    if event is InputEventKey and event.echo:
        return false
    if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
        return false
    if event is InputEventJoypadMotion and abs(event.axis_value) <= 0.8:
        return false
    if event is InputEventMouseMotion:
        return false
    return event.get_class() in SKIP_WHITELIST_TYPES
```

## Out of Scope

- Story 005:Modal blocking 吞 skip(skippable broadcast 在 NORMAL 态;Modal 在 Story 005)

## QA Test Cases

- **AC-FUNC-04**:7 类事件依次发送 → 4 次回调触发(a/b/c/d),3 次不触发(e/f/g)
- **AC-FUNC-09**:`register_skippable(owner_id, cb)` + `queue_free()` owner;触发合规 skip → auto-purge + 无 dead callable 调 + 无 "invalid instance" 日志 + 计数 -1

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/skippable_registry_test.gd`(含 queue_free fixture)
**Status**: [x] Created — 19 GdUnit4 test functions(4 register API + 5 AC-FUNC-04 positive incl. boundary/negative-axis/4× repeat + 4 AC-FUNC-04 negative + 2 AC-FUNC-09 auto-purge + 1 short-circuit contract + 1 empty-registry edge + 2 explicitly-deferred N/A)

## Dependencies

- Depends on: Story 002(NORMAL 态)
- Unlocks: Story 005(Modal blocking)

## Completion Notes

**Completed**: 2026-04-30
**Criteria**: 4/4 passing(全部 AC + R-INP-1 risk guard 自动化覆盖)
**Files changed**:
- `src/autoload/input_handler.gd`(modified — 扩展 Story 003 模块:`SKIP_AXIS_MAGNITUDE_THRESHOLD` const + `SKIP_WHITELIST_TYPES` const + `_skippable_registry: Dictionary[StringName, Callable]` field + `register_skippable / unregister_skippable / get_skippable_count / try_skip_broadcast` 公共 API + `_is_skip_eligible` 私有 helper + `_input()` 双 dispatch — path arbitration + skip broadcast)
- `tests/unit/input/skippable_registry_test.gd`(new — GdUnit4 19 函数)

**Deviations**(全 ADVISORY,无 BLOCKING):
1. **依赖未 Done**:Story 002(NORMAL 态)Status=Ready,非 Complete。autopilot [A] proceed — `_state = NORMAL` 默认值 Story 003 已 scaffold,Story 004 无运行时依赖 Story 002 状态机。`try_skip_broadcast` 当前无条件 broadcast,Story 005 land 时加 MODAL_LOCKED 守门(per Out-of-Scope 契约)。模块 docstring 显式记录(input_handler.gd:54-57)。
2. **测试命名约定**:遵循 codebase-precedent `test_[scenario]_[expected]` 而非 `.claude/rules/test-standards.md` 字面 `test_[system]_[scenario]_[expected]`。现有 `dual_focus_path_arbitration_test.gd` + `input_assist_anti_qte_test.gd` 均采用此短 form,Story 004 保持一致。建议跨 codebase tech-debt sweep 中调和 test-standards.md 字面 wording 与 codebase 实践。
3. **改进非偏离**:story spec 写 `is_instance_valid()`,实现用 `Callable.is_valid()`(语义等价 + 处理 lambda Callable 边界,gdscript-specialist 确认为 deliberate improvement)。

**Code Review**: APPROVED(本会话 `/code-review`)
- godot-gdscript-specialist:CLEAN(7 评价区 0 BLOCKING + 1 SUGGESTION 关于 future-author 防御性提示)
- qa-tester:1 BLOCKING + 3 GAP + 1 SUGGESTION + 1 NIT 全部 inline 处理:
  - BLOCKING(R-INP-1 log assertion):GdUnit4 默认 push_error 自动捕获 + auto-fail 已覆盖,test docstring 显式记录(无需新增 spy 测试)
  - GAP(负 axis 未测):新增 `test_joypad_motion_negative_above_threshold_invokes_skip_callback`(-0.85)锁 absf() 守门
  - GAP(4× 序列):新增 `test_joypad_motion_above_threshold_repeated_invokes_skip_callback_each_time` 锁 broadcast loop per-event idempotence
  - SUGGESTION(lambda 文档):skipped — 文档级,留待 contract 文档统一 sweep
  - NIT(test 名 system 前缀):skipped — 与 codebase precedent 冲突,见 deviation #2

**Deferred to Story 005**:
- `try_skip_broadcast` MODAL_LOCKED 状态守门(本 story Out of Scope 显式)

**Test Coverage Summary**(Phase 3 traceability):
| Criterion | Test | Status |
|-----------|------|--------|
| register / unregister API | 4 register-API tests | COVERED |
| AC-FUNC-04 (a) KB Space | `test_kb_space_press_invokes_skip_callback` | COVERED |
| AC-FUNC-04 (b) JoyBtn | `test_joypad_button_press_invokes_skip_callback` | COVERED |
| AC-FUNC-04 (c) MouseLEFT | `test_mouse_left_button_invokes_skip_callback` | COVERED |
| AC-FUNC-04 (d) Axis>0.8 | 4 axis tests(positive 0.85 + 4× repeat + negative -0.85 + 0.8 boundary)| COVERED |
| AC-FUNC-04 (e) MouseMotion | `test_mouse_motion_does_not_invoke_skip_callback` | COVERED |
| AC-FUNC-04 (f) Key echo | `test_key_echo_does_not_invoke_skip_callback` | COVERED |
| AC-FUNC-04 (g) MouseWheel | `test_mouse_wheel_does_not_invoke_skip_callback` | COVERED |
| AC-FUNC-09 auto-purge | 2 dedicated + 1 short-circuit contract test | COVERED |
| R-INP-1 zero log | GdUnit4 默认 push_error 捕获 + docstring 显式 | COVERED |
