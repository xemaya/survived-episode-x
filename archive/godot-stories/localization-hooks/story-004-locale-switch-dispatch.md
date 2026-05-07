# Story 004: locale_switch Dispatch ≤ 1 Frame + Signal Boundary

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-002`
**ADR Governing Implementation**: ADR-0004 Settings Reflow Coalescing + ADR-0001 Signal Ownership
**ADR Decision Summary**: `locale_changed(new_locale)` signal owner = LocalizationHooks;dispatch ≤ 1 帧(`TranslationServer.set_locale` + signal 发射同帧);Save 防抖经 ADR-0004;Loc **不直调** SaveSystem.write_*;`broadcast_translation_changed_once` 单次广播。

**Engine**: Godot 4.6 | **Risk**: LOW
**Control Manifest Rules**:
- Required: dispatch ≤ 1 帧 + signal 边界(无直调 Save)
- Forbidden: call_deferred(Pillar 5 ≤ 1 帧)

## Acceptance Criteria

- [x] `set_locale(locale: StringName)` API + `_force_dispatch(locale)` debug 钩子
- [x] **AC-FUNC-05** locale switch dispatch ≤ 1 帧:`_force_dispatch(&"zh_CN")` → 同帧 `TranslationServer.set_locale` 调用 + `locale_changed(&"zh_CN")` 信号 1 次发射 + 无 call_deferred + Loc 不直调 SaveSystem.write_* / FileAccess(本 story 内验);**Save 500ms 防抖后 meta 写入** = OUT-OF-SCOPE 协作 Save Story 004(本 story 内 in-scope: signal 边界 — `locale_changed` emit 一次,无 SaveSystem.write_* / FileAccess)
- [x] **AC-PERF-04** dispatch p99 < 2ms 主线程(连续 100 次 `_force_dispatch`)+ 0 call_deferred 调用
- [x] **AC-COMPAT-05** 跨系统协作:HUD #13 RichTextLabel `register_rich_text_refresh` 后 dispatch → rebuild_callable 同帧调用 + handler 内 `TranslationServer.get_locale()` 反新 locale;owner queue_free 未 unregister → auto-purge(Story 002 已验,本 story 不重复)

## Implementation Notes

```gdscript
# localization_hooks.gd
signal locale_changed(new_locale: StringName)

func _force_dispatch(locale: StringName) -> void:
    TranslationServer.set_locale(locale)
    emit_signal(&"locale_changed", locale)
    _broadcast_rebuild()  # Story 002 broadcast

func set_locale(locale: StringName) -> void:
    if TranslationServer.get_locale() == locale:
        return  # no-op
    if SceneDayFlowController.is_locale_locked():
        _pending_locale = locale  # Story 005 演出 lock
        return
    _force_dispatch(locale)
```

## QA Test Cases

- **AC-FUNC-05**:`_force_dispatch(&"zh_CN")` → 同帧 set_locale + signal 1 次 + Save write_* 计数当帧 0 + 500ms 后 meta.save mtime 更新
- **AC-PERF-04**:100 次 `_force_dispatch` → p99 < 2ms;0 call_deferred(日志断言)
- **AC-COMPAT-05**:HUD #13 register + dispatch → rebuild_callable 同帧调用;owner queue_free 未 unregister → auto-purge

## Test Evidence

`tests/integration/loc/locale_switch_dispatch_test.gd` + `tests/integration/loc/perf_dispatch_test.gd`

## Dependencies

- Depends on: Story 001 + Story 002(broadcast)+ Save Story 004(meta debounce 协作)
- Unlocks: Story 005(演出 lock + flush_pending_locale)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 in-scope COVERED via 7 dispatch tests + 2 perf tests(AC-FUNC-05 in-scope dispatch + signal + AC-PERF-04 p99 + AC-COMPAT-05 register-then-dispatch);Save mtime / FileAccess cross-epic 部分 OUT-OF-SCOPE 交 Save Story 004 集成测试覆盖
**Test Evidence**: `tests/integration/loc/locale_switch_dispatch_test.gd`(266 行 / 7 tests / GdUnit4)+ `tests/integration/loc/perf_dispatch_test.gd`(170 行 / 2 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode autopilot inline);新增公有 API `set_locale(locale)` 等价短路 + `_force_dispatch(locale)` 三步同帧(set_locale → emit → broadcast_rich_text_refresh);`signal locale_changed(new_locale: StringName)` past-tense snake_case + ADR-0001 owner 标注;无 call_deferred / await;无 BLOCKING / 无 inline fix
**Deviations**(全 ADVISORY,无 BLOCKING):
1. ADR-0004 / ADR-0001 Status=Proposed — lean-mode-equivalent per control-manifest.md 既有先例
2. `_force_dispatch` 名字带 `_` 前缀但语义上是 public 测试/Story 010 hook seam — 故事伪代码字面如此,镜像 Story 002 `broadcast_rich_text_refresh` 公有 seam 前例(无下划线)的反向版,doc string 显式标 public 用途
3. `set_locale` 等价短路 (`String(locale) == TranslationServer.get_locale()`) — 故事伪代码未显式列(只列了 `if TranslationServer.get_locale() == locale: return`),实现中 StringName/String 比较用 `String(locale)` 显式转换,避免 4.6 typed equality 边界(语义等价)
4. Story 005 lock check (`SceneDayFlowController.is_locale_locked`) intentionally NOT present — Story 005 scope 显式承担 lock + pending + watchdog;本 story `set_locale` 直接 force_dispatch,Story 005 dev 时插入 lock guard
**Tech debt**: None new
**API surface**: `LocalizationHooks.set_locale(locale: StringName) -> void` + `LocalizationHooks._force_dispatch(locale: StringName) -> void`(public seam 字面带 underscore)+ `signal locale_changed(new_locale: StringName)`
