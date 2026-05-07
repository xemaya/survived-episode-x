# Story 002: RichTextLabel Register / Unregister + Auto-Purge

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-002`
**ADR Governing Implementation**: ADR-0004 Settings Reflow Coalescing
**ADR Decision Summary**: `register_rich_text_refresh(token_id, rebuild_callable)` / `unregister_rich_text_refresh(token_id)` API;owner queue_free 后 auto-purge `is_instance_valid` 守门(R-LOC-2)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Control Manifest Rules**:
- Required: auto-purge `is_instance_valid()` 守
- Forbidden: 调 dead callable

## Acceptance Criteria

- [x] `register_rich_text_refresh(token_id: StringName, rebuild_callable: Callable)` API
- [x] `unregister_rich_text_refresh(token_id)` API
- [x] **AC-FUNC-03** Rule 3:`register_rich_text_refresh("hud_card_desc", cb)` + `_force_dispatch(&"zh_CN")` → cb 同帧调用 + Registry 条目存活;`unregister` 后再 dispatch → cb 不再调用
- [x] **AC-ROBUST-02 [R-LOC-2]** owner queue_free 未 unregister:`is_instance_valid` 检测返 false → auto-purge + cb 不调 + 无"invalid instance"日志 + 计数 -1;广播继续对其余有效条目执行

## Implementation Notes

```gdscript
# localization_hooks.gd
var _refresh_registry: Dictionary[StringName, Callable] = {}

func register_rich_text_refresh(token_id: StringName, rebuild: Callable) -> void:
    _refresh_registry[token_id] = rebuild

func unregister_rich_text_refresh(token_id: StringName) -> void:
    _refresh_registry.erase(token_id)

func _broadcast_rebuild() -> void:
    var to_purge: Array[StringName] = []
    for token_id in _refresh_registry:
        var cb: Callable = _refresh_registry[token_id]
        if not cb.is_valid():
            to_purge.append(token_id)
        else:
            cb.call()
    for tid in to_purge:
        _refresh_registry.erase(tid)
```

## QA Test Cases

- **AC-FUNC-03**:register + dispatch → cb 同帧调用;unregister → cb 不再调
- **AC-ROBUST-02**:register + queue_free owner;dispatch → auto-purge + 无 dead callable 调 + 无 "invalid instance" 日志 + 其余条目仍执行

## Test Evidence

`tests/unit/loc/refresh_registry_test.gd`(含 queue_free fixture)

## Dependencies

- Depends on: Story 001
- Unlocks: Story 004(locale switch dispatch 用此 broadcast)

## Completion Notes

**Completed**: 2026-04-30
**Criteria**: 4/4 passing(AC-FUNC-03 via test seam `broadcast_rich_text_refresh()`;AC-ROBUST-02 via `Callable.is_valid()` 守门 + GdUnit4 push_error capture 隐式守"invalid instance"零日志契约)
**Test Evidence**: `tests/unit/loc/refresh_registry_test.gd`(GdUnit4 / 10 test 函数 / 4 AC + 边界全覆盖)+ `src/autoload/localization_hooks.gd`(133 行,4 公有方法 + 私有 `_refresh_registry`)
**Code Review**: APPROVED WITH SUGGESTIONS(lean mode 内联;0 required changes / 4 stylistic non-blocking)
**Test-Criterion Traceability**:
| AC | Test 函数 | Status |
|----|----------|--------|
| register API | `test_register_rich_text_refresh_adds_entry_to_registry` | COVERED |
| unregister API | `test_unregister_rich_text_refresh_removes_entry` + `test_unregister_unknown_token_is_no_op` | COVERED |
| AC-FUNC-03 register + dispatch 同帧 | `test_broadcast_invokes_registered_callbacks_same_frame` + `test_register_same_token_twice_overwrites` | COVERED(via test seam — `_force_dispatch` 是 Story 004 scope) |
| AC-FUNC-03 unregister 后 dispatch 不调 | `test_broadcast_after_unregister_does_not_invoke_callback` | COVERED |
| AC-ROBUST-02 R-LOC-2 auto-purge | `test_freed_owner_callback_is_auto_purged_on_broadcast` + `test_freed_owner_alone_purges_to_empty_registry` + `test_multiple_freed_owners_all_purged_one_broadcast` | COVERED |

**Deviations**(全 ADVISORY):
1. ADR-0004 Status=Proposed — lean-mode-equivalent per control-manifest.md L6(established precedent across loc / input-handler stories)
2. 故事伪代码 `_broadcast_rebuild()` (私有) → 实现为 `broadcast_rich_text_refresh()` (公有 seam) — Story 004 `_force_dispatch` 入口 + 测试 seam,镜像 `try_skip_broadcast` 公有 seam 前例(input_handler.gd:733)
3. `push_warning` 在 purge 时触发 — 故事伪代码未列,但 prompt 显式要求 mirror input_handler.try_skip_broadcast L753-757(live builds 暴露 leak)
4. 测试用 `.free()` 同步释放(非 `queue_free()`)— 故事 Test Evidence 行 59 提"含 queue_free fixture",但同步 `.free()` 触发 `Callable.is_valid()` 即时翻 false,无需 `await get_tree().process_frame`,deterministic;镜像 skippable_registry_test L570 前例
5. Manifest 写"`is_instance_valid()` 守",故事伪代码 + 实现用 `Callable.is_valid()` — 后者是 Callable 类型的 canonical Godot API,语义等价(检查 bound Object 是否 freed),input_handler.gd:746 同前例

**Out of Scope / Deferred**:
- `_force_dispatch(&"zh_CN")` 入口 — Story 004 scope(locale switch dispatch);本 story `broadcast_rich_text_refresh()` 公有 seam 已就位待 Story 004 hook
- `broadcast_translation_changed_once()` + `propagate_notification(NOTIFICATION_TRANSLATION_CHANGED)` — Story 004 scope(ADR-0004 §2 平行机制)
- PAUSE-suspension 契约(ADR-0004 §4 `_pending_translation_change`)— Story 004 scope
- `project.godot` autoload 注册 — bootstrap 延后,镜像 input_handler.gd L145-149 前例
