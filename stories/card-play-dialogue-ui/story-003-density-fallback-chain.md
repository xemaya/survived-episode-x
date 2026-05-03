# Story 003: Density Fallback Chain (brief→standard→verbose)

> **Epic**: card-play-dialogue-ui | **Status**: Complete | **Layer**: Presentation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/card-play-dialogue-ui.md` | **Requirement**: `TR-cardui-004`
**ADR**: ADR-0012 fallback 链 + standard 必填 assert
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: brief 缺 → standard;verbose 缺 → standard;standard 必填 assert
- Required: fallback 链单点实施(`#15 Recap UI` 共享逻辑)

## Acceptance Criteria

- [ ] `_select_dialogue_keys_by_density(event, density) -> PackedStringArray` API + fallback 链
- [ ] `_select_effects_by_density(event, density) -> Array[EventEffect]` API + fallback 链
- [ ] standard 缺失 → assert 失败 + 日志 push_error
- [ ] `#15 Recap UI` Story 共享此 API(协作)

## Implementation Notes

```gdscript
func _select_dialogue_keys_by_density(event: EventResource, density: StringName) -> PackedStringArray:
    match density:
        &"brief":
            if not event.dialogue_keys_brief.is_empty():
                return event.dialogue_keys_brief
            push_warning("event %s missing brief, fallback standard" % event.event_id)
            return event.dialogue_keys_standard
        &"standard":
            assert(not event.dialogue_keys_standard.is_empty(),
                   "event %s missing required standard" % event.event_id)
            return event.dialogue_keys_standard
        &"verbose":
            if not event.dialogue_keys_verbose.is_empty():
                return event.dialogue_keys_verbose
            push_warning("event %s missing verbose, fallback standard" % event.event_id)
            return event.dialogue_keys_standard
    return event.dialogue_keys_standard
```

## QA Test Cases

- brief 缺 → fallback standard + WARN
- verbose 缺 → fallback standard + WARN
- standard 缺 → assert 失败 + push_error

## Test Evidence

`tests/unit/card_ui/density_fallback_test.gd`

## Dependencies

- Depends on: Story 002 + Event Script Story 005
- Unlocks: Recap Story(共享 API)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 9 test 函数(brief/verbose 缺 → standard fallback;brief/verbose 非空 直返;standard 缺失 push_error 路径不爆;null event 返回空)
**Test Evidence**: `tests/unit/card_ui/density_fallback_test.gd` (9 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`select_dialogue_keys_by_density` + `select_effects_by_density` 双 API 镜像 EventScriptEngine.gd:291-337 — 同 ADR-0012 fallback 语义,允许 #14 layer self-resolve(测试免 autoload 启动);无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. 与 #10 EventScriptEngine 平行实现 fallback chain — 同 ADR-0012 单点逻辑(共享 const 名),production 应通过 DI 复用 #10 实例(留给 .tscn Phase 4 wiring)
**Tech debt**: None new
**API surface**: `select_dialogue_keys_by_density(event, density) -> PackedStringArray` + `select_effects_by_density(event, density) -> Array`
