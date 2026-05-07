# Story 003: Missing Key Dual-Track Fallback + BBCode-Safe

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-001`
**ADR Governing Implementation**: GDD Rule 4 双轨 fallback
**ADR Decision Summary**: dev `[MISSING: KEY]` 显式 + push_error;prod fallback 链(当前 locale → zh_CN 基准 → key name);RichTextLabel BBCode-safe(`[` 转义为 `[lb]` 或用 `add_text()` plain text 路径)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Control Manifest Rules**:
- Required: dev 显式 + prod 静默(双轨)
- Required: BBCode-safe rebuild_callable 实现

## Acceptance Criteria

- [x] **AC-FUNC-04** dev/prod 双轨:dev `tr("UI.NONEXISTENT_KEY")` 返 `"[MISSING: UI.NONEXISTENT_KEY]"` + push_error;prod 同 key → fallback 链(当前 locale → zh_CN → key name)+ 不 crash 不阻塞 不 ERROR 日志
- [x] **AC-ROBUST-04** RichTextLabel BBCode-safe:rebuild_callable 用 `add_text()` plain 或转义 `[` 为 `[lb]`;渲染可见完整 `[MISSING: ...]` 字符串,无 BBCode 解析错误

## Implementation Notes

```gdscript
# localization_hooks.gd
func tr_safe(key: StringName) -> String:
    var translated := tr(key)
    if translated == key:  # missing
        if OS.is_debug_build():
            push_error("ERR_LOCALIZATION: key %s not found in locale %s" % [key, TranslationServer.get_locale()])
            return "[MISSING: %s]" % key
        else:
            # prod fallback chain
            var fallback := tr_with_locale(key, &"zh_CN")
            if fallback != key:
                return fallback
            return key  # final fallback
    return translated
```

## QA Test Cases

- **AC-FUNC-04**:dev `tr("UI.NONEXISTENT_KEY")` → `"[MISSING: ...]"` + push_error;prod 同 → fallback 链 + 不 crash
- **AC-ROBUST-04**:rebuild_callable 用 `append_text("[MISSING: ...]")` BBCode parse → 改用 `add_text()` plain;渲染可见完整字符串

## Test Evidence

`tests/unit/loc/missing_key_fallback_test.gd` + `tests/integration/loc/bbcode_safe_test.gd`

## Dependencies

- Depends on: Story 001
- Unlocks: Story 002(register API 协作 BBCode-safe rebuild)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 2/2 COVERED via 9 unit + 3 integration tests(AC-FUNC-04 dev/prod 双轨 + AC-ROBUST-04 BBCode-safe)
**Test Evidence**: `tests/unit/loc/missing_key_fallback_test.gd`(326 行 / 9 tests / GdUnit4)+ `tests/integration/loc/bbcode_safe_test.gd`(169 行 / 3 tests / GdUnit4 真 RichTextLabel 渲染) — BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode autopilot inline);src 实现公有 API `tr_safe(key)` + `bbcode_escape(text)` + 测试 seam(`debug_build_override` / `capture_push_error_for_testing`)+ 私有 `_tr_with_locale` / `_emit_missing_key_error` / `_is_debug_build`;dev push_error 经 capture seam 隐式守 prod silent 契约;无 BLOCKING / 无 inline fix
**Deviations**(全 ADVISORY,无 BLOCKING):
1. ADR governing = GDD Rule 4(无独立 ADR 文件)— story Context 字段已显式标注,无须额外 deviation
2. `_FALLBACK_LOCALE = &"zh_CN"` 作为 const(非 entities.yaml 数据驱动)— MVP zh_CN 唯一基准,Pillar 5 5s 启动承诺 + Rule 6 base CSV 锁定为 zh_CN,常量更明确
3. `_emit_missing_key_error` 测试 seam(`capture_push_error_for_testing`)— 故事伪代码未列,但 GdUnit4 默认将 push_error 视为测试失败,seam 用于隐式守 prod silent 契约不留 false-positive
**Tech debt**: None new
**API surface**: `LocalizationHooks.tr_safe(key: StringName) -> String` + `LocalizationHooks.bbcode_escape(text: String) -> String` + 测试 seam `debug_build_override: int` / `capture_push_error_for_testing: bool` / `last_push_error_message: String`
