# Story 005: Modal Lock Stack + Two-Tier Strategy

> **Epic**: input-handler
> **Status**: Done
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-002` + `TR-input-007`
**ADR Governing Implementation**: ADR-0002 Autoload Init Order(Recursive Control disable 4.5)
**ADR Decision Summary**: 模态二阶策略 — `acquire_modal_lock(node, blocking: bool)` / `release_modal_lock(node)` API;blocking=true 吞 skip + 焦点循环仅 modal 内;blocking=false toast 持锁不阻 skip;嵌套 lock-stack 最严格 blocking 胜出;Recursive Control disable 4.5 实施 modal 外 disable 路由。

**Engine**: Godot 4.6 | **Risk**: HIGH(via ADR-0002 Recursive Control disable 4.5)
**Engine Notes**: `Control.set_focus_mode(FOCUS_NONE)` 递归;OQ-INP-01 嵌套 modal lock 栈实测留 ADR-0002 Pre-Production。

**Control Manifest Rules**:
- Required: lock-stack(嵌套 acquire/release counter)
- Required: blocking=true 吞 skip + 焦点循环 modal 内 + Recursive Control disable
- Forbidden: skip 从 MODAL_LOCKED 态泄漏(R-INP-2 R-RISK GUARD)

## Acceptance Criteria

- [x] `acquire_modal_lock(modal_node, blocking: bool)` / `release_modal_lock(modal_node)` API
- [x] **AC-FUNC-05** R7 模态隔离二阶策略:blocking=true modal 激活 → (a) `act_skip` 合规事件不发射 + (b) 焦点导航仅 modal 内循环 [DEFERRED OQ-INP-01 — 真 Control tree 集成实测] + (c) modal 内 `act_confirm` 信号到达 modal 元素 [DEFERRED Story 002 owns act_confirm];`release_modal_lock` 后普通 skip 恢复
- [x] **AC-FUNC-06** Edge 2.1 嵌套 modal lock-stack:blocking=false toast 持锁后再 `acquire_modal_lock(dialog, blocking=true)` 叠加 → (a) `act_skip` 被吞(最严格 blocking 胜出)+ (b) 解锁 non-blocking 层后状态仍 MODAL_LOCKED;两把锁均 release 后才回 NORMAL
- [x] **AC-ROBUST-02** R7 blocking modal skip-leak 守门:`release_modal_lock` 与合规 skip 同帧到达 → 处理顺序保证 release 先,skip 在 NORMAL 态发射(skip 不应在任何路径下从 MODAL_LOCKED 态泄漏)— **[RISK GUARD R-INP-2]**

## Implementation Notes

```gdscript
# input_handler.gd
var _modal_lock_stack: Array[Dictionary] = []  # [{node, blocking}]

func acquire_modal_lock(modal_node: Node, blocking: bool) -> void:
    _modal_lock_stack.append({"node": modal_node, "blocking": blocking})
    _state = InputState.MODAL_LOCKED
    if blocking and modal_node.has_method(&"set_recursive_focus_disable"):
        # Godot 4.5 Recursive Control disable
        _disable_focus_outside_modal(modal_node)

func release_modal_lock(modal_node: Node) -> void:
    var to_remove := -1
    for i in range(_modal_lock_stack.size()):
        if _modal_lock_stack[i]["node"] == modal_node:
            to_remove = i
            break
    if to_remove != -1:
        _modal_lock_stack.remove_at(to_remove)
    if _modal_lock_stack.is_empty():
        _state = InputState.NORMAL
        _restore_focus_routing()

func _is_blocking_modal_active() -> bool:
    for entry in _modal_lock_stack:
        if entry["blocking"]:
            return true
    return false

func _input(event: InputEvent) -> void:
    if _state == InputState.MODAL_LOCKED and _is_blocking_modal_active():
        # 吞 skip,但 modal 内 act_confirm 仍传给 modal 元素(via _gui_input)
        if _is_skip_event(event):
            return  # skip 吞
    # ... 其余 act_* 处理
```

## Out of Scope

- Story 002:NORMAL 态合法判定
- Story 004:skippable 注册

## QA Test Cases

- **AC-FUNC-05**:blocking=true modal 激活 → (a) act_skip 不发射;(b) D-Pad 焦点循环 modal 内;(c) modal 内 act_confirm 到达;release 后 skip 恢复
- **AC-FUNC-06**:non-blocking toast 持锁 + 叠加 blocking dialog → act_skip 吞;release toast 后状态仍 MODAL_LOCKED;两把锁 release 后回 NORMAL + skip 恢复
- **AC-ROBUST-02 [R-INP-2]**:release 与 skip 同帧 → release 先转 NORMAL + skip 在 NORMAL 态发射;skip 发射时 state log 显示 NORMAL

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/input/modal_lock_stack_test.gd`(含同帧 race fixture)
**Status**: [x] Created — 15 GdUnit4 函数,Arrange/Act/Assert,deterministic(no-await),no real engine input pipeline

## Dependencies

- Depends on: Story 002(NORMAL 态)+ Story 004(skippable)
- Unlocks: Story 007(Gamepad 热插拔 toast 用 blocking=false modal)

## Completion Notes

**Completed**: 2026-04-30
**Verdict**: COMPLETE WITH NOTES
**Criteria**: 4/4 AC checkbox passing(2 deferred sub-items 显式 assigned to Story 002 + OQ-INP-01,非 coverage gap)
**Files changed**:
- `src/autoload/input_handler.gd`(modified — Story 005 only;Story 003/004 代码无触):
  - 新增 `_modal_lock_stack: Array[Dictionary]` field + `_saved_focus_modes: Dictionary[Control, int]` field(post-review typed)
  - 新增公共 API:`acquire_modal_lock(modal_node, blocking)` + `release_modal_lock(modal_node)`
  - 新增私有 helper:`_is_blocking_modal_active()` + `_disable_focus_outside_modal()` + `_restore_focus_routing()`
  - `try_skip_broadcast()` 顶部 step 1.5 gate(AC-FUNC-05 (a) + AC-ROBUST-02 R-INP-2)
  - 模块级 docstring 增 "What Story 005 adds" 段;Story:/ADR:/TR-ID: 拼接 005/0002/002+007
- `tests/integration/input/modal_lock_stack_test.gd`(new — 15 函数 + 内置 _SkipProbe extends Node fixture)

**Test count**: 15 函数(13 初始 + 2 code-review 内联新增)— API contract 2 + AC-FUNC-05 2 + AC-FUNC-06 3 + non-blocking 2 + AC-ROBUST-02 双向 2 + identity-removal 2 + 幂等 re-acquire 1 + 3-level nesting 1
**Code-review inline fixes applied**: 5 项 convergent / 内联修复(0 BLOCKING,4 GAP + 1 后续 GAP)
- GAP-1 → `_saved_focus_modes` 改 `Dictionary[Control, int]`(typed)
- GAP-2 → 修订 `_disable_focus_outside_modal` doc 不再误导引用 mouse_filter API
- GAP-3 + B1(双 specialist convergent)→ `acquire_modal_lock` 加幂等 re-acquire guard:同节点重复 acquire 更新 blocking in place(防 phantom entry)+ doc 描述 + 新 test pinning
- GAP-4 → `acquire_modal_lock` doc 加 focus scope 限直接 sibling 段
- B4 → 新增 `test_three_level_nested_locks_most_strict_wins` pin N>2 nesting 正确性

**Skipped findings**:
- SUG-1(typed inner class refactor 替代 Array[Dictionary])— story spec literal 要求
- SUG-2(test naming 三段式 vs 两段式)— codebase precedent(skippable_registry_test + dual_focus_path_arbitration_test 已建立)优先;跨 codebase sweep 待协调(承袭 Story 003/004 已记 tech debt)
- B2/B3(release on empty stack / acquire-wrong-then-correct)— 非关键 low-risk
- D2(`_saved_focus_modes` 公共 count seam)— OQ-INP-01 Pre-Production 集成测试时再加
- 6 NIT 全 PASS 无 action

**Specialists**: godot-gdscript-specialist + qa-tester(parallel)
- gdscript: 0 BLOCKING + 4 GAP + 3 SUGGESTION + 6 NIT → APPROVED WITH SUGGESTIONS
- qa-tester: 0 BLOCKING + 3 GAP + 2 SUGGESTION + 2 NIT → APPROVED WITH SUGGESTIONS
- 5 inline 修复后:0 BLOCKING / 0 残留 GAP

**Deviations**:
- ADVISORY: Story 002(NORMAL 态合法判定)Status=Ready 非 Complete — autopilot [A] proceed:Story 003/004 已 scaffold InputState enum + `_state` field;Story 005 modal stack 仅 `_state` 写入 + `try_skip_broadcast` gate,无运行时 Story 002 内部状态机依赖
- ADVISORY: 故事 Implementation Notes 用 `set_recursive_focus_disable` 占位方法 — 实测 Godot 4.5+ 真 API 是 `Control.focus_mode = FOCUS_NONE`;实施改用真实 API + scope 限直接 parent siblings + 显式 doc + ADR-0002 OQ-INP-01 Pre-Production 实测留 deferred
- ADVISORY: 实施引入幂等 re-acquire(code-review GAP-3 + qa B1 convergent)— 比 story Implementation Notes literal `Array.append` 更安全;ADVISORY 因为是 spec 改进而非偏离
- ADVISORY: 测试命名两段式 codebase precedent vs test-standards.md 字面三段式 — 跨 codebase 统一 sweep 待协调(承袭 Story 003/004)

**Test Evidence**: Integration — `tests/integration/input/modal_lock_stack_test.gd`(15 函数 GdUnit4)
**Code Review**: Complete(specialists parallel,5 inline 修复,APPROVED WITH SUGGESTIONS → APPROVED post-fixes)
**Manifest Version**: 2026-04-28 ↔ control-manifest 2026-04-28 = match
**TR registry consistency**: TR-input-002 + TR-input-007 当前 requirement text 与实施一致
**Out-of-Scope respected**: Story 002 act_* signal logic / Story 003 path arbitration / project.godot autoload 全未触
