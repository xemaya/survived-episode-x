# Story 012: CSV File Missing Startup Gate + Deprecated Key Flow

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-001`
**ADR Governing Implementation**: GDD R-LOC-1 + Rule 10 key 稳定性
**ADR Decision Summary**: CSV 文件缺失 → CI asset integrity check FAIL + Pillar 5 5s 启动承诺阻塞;runtime push_error;dev 每 tr() 调用 push_error 而非静默返 key name;deprecated key 流程 — `context = "DEPRECATED: replaced by [new_key]"` + dev WARN + Release FAIL。

**Engine**: Godot 4.6 | **Risk**: LOW
**Control Manifest Rules**:
- Required: CSV asset integrity CI gate
- Required: deprecated key WARN(dev)/ FAIL(Release)

## Acceptance Criteria

- [x] **AC-ROBUST-01 [R-LOC-1]** CSV 文件缺失:本 story 内 `check_csv_integrity(repo_root)` 返 ERR_ASSET_MISSING + Pillar 5 5s entry promise blocked phrase 已验;runtime `TranslationServer.get_loaded_locales()` 不含 `"zh_CN"` 在 Story 008 load_translation 失败路径已 land(push_error);dev build 每 tr() 调用 push_error 是 Story 003 dev sentinel + push_error 行为已 land(隐式守)
- [x] **AC-FUNC-12** Rule 10 deprecated 流程:`lint_deprecated_keys` 已实施 — dev branch WARN / release branch FAIL / 单双引号匹配 / 替换 key 不误报均已验;runtime "返 zh_CN 值不返 [MISSING:]" = 故事约定靠 CSV row 不删 + context 加 DEPRECATED 标注,runtime tr() 自然返 CSV value(无 src 改动需要)— OUT-OF-SCOPE no-op

## Implementation Notes

```python
# tools/asset_integrity_lint.py
import os

REQUIRED_LOCALES = ["zh_CN"]  # MVP

def check_csv_integrity() -> list[str]:
    errors = []
    for locale in REQUIRED_LOCALES:
        path = f"assets/i18n/{locale}.csv"
        if not os.path.exists(path):
            errors.append(f"ERR_ASSET_MISSING: {path} not found — Pillar 5 5s entry promise blocked")
    return errors
```

```python
# tools/i18n_lint.py
def lint_deprecated_keys(gd_files: list[str], deprecated_keys: dict, branch: str) -> list[str]:
    errors = []
    for path in gd_files:
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        for old_key, new_key in deprecated_keys.items():
            if f'tr("{old_key}")' in content or f"tr('{old_key}')" in content:
                msg = f"DEPRECATED_KEY_IN_USE: {old_key} — migrate to {new_key} (in {path})"
                if branch == "release":
                    errors.append(f"FAIL: {msg}")
                else:
                    errors.append(f"WARN: {msg}")
    return errors
```

## QA Test Cases

- **AC-ROBUST-01**:zh_CN.csv 缺失 → CI asset integrity FAIL;runtime push_error + dev tr() 每次 push_error
- **AC-FUNC-12**:context "DEPRECATED: ..." + dev tr(deprecated_key) → 返手工拷贝值;lint 引用 deprecated key dev → WARN;Release → FAIL

## Test Evidence

`tests/unit/loc/asset_integrity_test.py` + `tests/unit/loc/deprecated_key_test.py`

## Dependencies

- Depends on: Story 001(lint chain)+ Story 008(load_translation)
- Unlocks: Release pipeline asset gate

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 2/2 COVERED via 2 asset integrity tests + 5 deprecated key tests — `python3 -m unittest tests.unit.loc.asset_integrity_test tests.unit.loc.deprecated_key_test`: 7 / 0 fail
**Test Evidence**: `tests/unit/loc/asset_integrity_test.py`(58 行 / 2 tests / unittest)+ `tests/unit/loc/deprecated_key_test.py`(74 行 / 5 tests / unittest)+ `tools/i18n_lint.py` 新增 `check_csv_integrity(repo_root)` + `lint_deprecated_keys(text, deprecated_keys, branch)` + `REQUIRED_LOCALES = ("zh_CN",)` 常量 — BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode autopilot inline);check_csv_integrity 接受 repo_root 参数(测试可注入 tempdir,生产用默认 ".");lint_deprecated_keys branch-specific prefix(release "FAIL:" / 其他 "WARN:")— CLI 层 errors 非空 → exit 1 不分级,但消息层有 actionable 区分;单双引号 tr() 形式都匹配;无 BLOCKING / 无 inline fix
**Deviations**(全 ADVISORY,无 BLOCKING):
1. ADR governing = GDD R-LOC-1 + Rule 10(无独立 ADR 文件)
2. 故事 line 39 `tools/asset_integrity_lint.py` 单独脚本 — 实施合并入 `tools/i18n_lint.py` 的 `check_csv_integrity` 函数(避免多脚本碎片化,CI 单入口)
3. 故事 line 23 "dev build 每 tr() 调用 push_error" — Story 003 dev sentinel + push_error 已实施 `tr_safe()` 用 push_error 路径,本 story 无须重复实施
4. AC-FUNC-12 runtime 返 zh_CN value 不返 [MISSING:] — 这是 CSV 数据层契约(row 不删 + context 加 DEPRECATED:),tr() runtime 自然行为,无 src 改动需要,标 OUT-OF-SCOPE no-op
**Tech debt**: None new
**API surface**: `i18n_lint.check_csv_integrity(repo_root) -> list[str]` + `i18n_lint.lint_deprecated_keys(text, deprecated_keys: dict, branch: str, path: str) -> list[str]` + `i18n_lint.REQUIRED_LOCALES = ("zh_CN",)`
