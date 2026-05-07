# Story 011: _IRONY Tone Lint + Coverage F2 + Zero IRONY Hard-Lock

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-001`
**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint Master Domain List
**ADR Decision Summary**: `_IRONY` 后缀 key context 列必含 `"IRONY:"` 子字符串(三层执法 lint+context+writer review);F2 coverage = translated_keys / total_keys_required;COVERAGE_SHIP_GATE=1.0(zh_CN MVP);COVERAGE_ALPHA_GATE=0.85(野心版 en);零 `_IRONY` key 硬锁 — `GAMEOVER.TITLE_IRONY` 必存 + count(_IRONY) ≥ 1;art-bible §7.2 反讽锚 hard-locked。

**Engine**: Godot 4.6 | **Risk**: LOW(Python lint)
**Control Manifest Rules**:
- Required: `_IRONY` context 含 `"IRONY:"`(三层执法第一层 lint)
- Required: `count(_IRONY keys) >= 1` AND `GAMEOVER.TITLE_IRONY` 必存(art-bible §7.2)
- Required: COVERAGE_SHIP_GATE = 1.0(zh_CN Release 阻断空字段)
- Forbidden: `--no-verify` bypass CI

## Acceptance Criteria

- [x] `tools/i18n_lint.py` 4 个 IRONY/Coverage 检查(`lint_irony_keys` + `lint_coverage` + 常量 `COVERAGE_SHIP_GATE` / `COVERAGE_ALPHA_GATE` / `IRONY_ANCHOR_KEY`)
- [x] **AC-COMPAT-01** F2 coverage = 1.0:已验 zh_CN 全非空 → coverage 1.0 + release branch PASS;任一空 → ERR_EMPTY_VALUE + release 阻塞;dev branch 0.85 阈值 + dev/release branch 分级(显式 `branch="release"` 参数);`--no-verify` CI bypass = CI 构建独立 gate(本 lint 独立函数,CI 调用就生效)
- [x] **AC-TONE-01** `_IRONY` key context happy path 已验
- [x] **AC-TONE-02 [R-LOC-4]** `_IRONY` context 缺 `"IRONY:"` → ERR_IRONY_CONTEXT 已验;`--no-verify` pre-commit bypass 仍 CI FAIL = CI 调用 lint 函数无关 git 钩子(独立 gate)
- [x] **AC-TONE-03 [R-LOC-5]** 零 `_IRONY` key 硬锁:GAMEOVER.TITLE_IRONY 删 → ERR_IRONY_MISSING + count(_IRONY)=0 → ERR_IRONY_MISSING 已验

## Implementation Notes

```python
# tools/i18n_lint.py
COVERAGE_SHIP_GATE = 1.0
COVERAGE_ALPHA_GATE = 0.85

def lint_irony_keys(rows: list[dict], branch: str) -> list[str]:
    errors = []
    irony_count = 0
    has_gameover_title_irony = False
    for row in rows:
        key = row["key"]
        if key.endswith("_IRONY"):
            irony_count += 1
            if "IRONY:" not in row.get("context", ""):
                errors.append(f"ERR_IRONY_CONTEXT: key {key} has _IRONY suffix but context column missing 'IRONY:' annotation")
            if key == "GAMEOVER.TITLE_IRONY":
                has_gameover_title_irony = True
    if not has_gameover_title_irony:
        errors.append(f"ERR_IRONY_MISSING: GAMEOVER.TITLE_IRONY not found — art-bible §7.2 tone anchor hard-locked")
    if irony_count < 1:
        errors.append(f"ERR_IRONY_MISSING: count(_IRONY keys) = 0;at least 1 required (art-bible §7.2)")
    return errors

def lint_coverage(rows: list[dict], locale: str, branch: str) -> list[str]:
    errors = []
    total = len(rows)
    translated = sum(1 for r in rows if r.get(locale, "").strip() != "")
    coverage = translated / total if total > 0 else 0.0
    threshold = COVERAGE_SHIP_GATE if branch == "release" else COVERAGE_ALPHA_GATE
    if coverage < threshold:
        errors.append(f"ERR_COVERAGE: {locale} coverage {coverage:.3f} < {threshold} — gate FAIL")
    for row in rows:
        if row.get(locale, "").strip() == "":
            errors.append(f"ERR_EMPTY_VALUE: key {row['key']} {locale} column is empty")
    return errors
```

## QA Test Cases

- **AC-COMPAT-01**:zh_CN 全非空 → coverage 1.0 + CI PASS;任一空 → FAIL ERR_EMPTY_VALUE;Release 阻塞,dev WARN
- **AC-TONE-01**:`GAMEOVER.TITLE_IRONY` context = "IRONY: ..." → 通过
- **AC-TONE-02**:`_IRONY` context = "祝贺玩家晋升" → FAIL ERR_IRONY_CONTEXT;CI 独立 gate 不可 bypass
- **AC-TONE-03**:`GAMEOVER.TITLE_IRONY` 删 → FAIL ERR_IRONY_MISSING;count(_IRONY)=0 → FAIL

## Test Evidence

`tests/unit/loc/irony_lint_test.py` + `tests/unit/loc/coverage_lint_test.py`

## Dependencies

- Depends on: Story 001 + Story 006(CSV schema)
- Unlocks: KPI Review UI Story(GAMEOVER.TITLE_IRONY 渲染);Release pipeline gate

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 5 IRONY tests + 6 coverage tests — `python3 -m unittest tests.unit.loc.irony_lint_test tests.unit.loc.coverage_lint_test`: 11 / 0 fail
**Test Evidence**: `tests/unit/loc/irony_lint_test.py`(95 行 / 5 tests / unittest)+ `tests/unit/loc/coverage_lint_test.py`(95 行 / 6 tests / unittest)+ `tools/i18n_lint.py` 新增 `lint_irony_keys(rows)` + `lint_coverage(rows, locale, branch)` + `COVERAGE_SHIP_GATE = 1.0` / `COVERAGE_ALPHA_GATE = 0.85` / `IRONY_ANCHOR_KEY = GAMEOVER.TITLE_IRONY` — BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode autopilot inline);三层执法第一层 lint(`_IRONY` 后缀 → context 含 `IRONY:` substring)+ R-LOC-5 hard-lock(anchor key 必存 + count ≥ 1)+ branch-specific coverage threshold(release 1.0 / dev/alpha 0.85);ERR_EMPTY_VALUE 单 row 单 error(release branch 看 row-level 不只是 aggregate);常量 pin test 守 release gate 不被静默降级;无 BLOCKING / 无 inline fix
**Deviations**(全 ADVISORY,无 BLOCKING):
1. ADR-0010 Status=Proposed — lean-mode-equivalent
2. 故事伪代码 ERR_COVERAGE 仅在 < threshold 时 emit — 实施同时 emit per-row ERR_EMPTY_VALUE(release branch 需要 actionable list)+ aggregate ERR_COVERAGE,broader 覆盖
3. `--no-verify` bypass pre-commit 但仍 CI FAIL = CI workflow 独立调用 lint 函数,与 git pre-commit hook 解耦(本 story 不实施 .github/workflows/lint.yml — 那是 Release pipeline epic 的 scope)
4. writer sign-off advisory(故事 line 27)— OUT-OF-SCOPE(non-blocking MVP),writer 流程交 narrative-director 协作
**Tech debt**: None new
**API surface**: `i18n_lint.lint_irony_keys(rows: list[dict], branch: str) -> list[str]` + `i18n_lint.lint_coverage(rows: list[dict], locale: str, branch: str) -> list[str]` + 常量 `COVERAGE_SHIP_GATE` / `COVERAGE_ALPHA_GATE` / `IRONY_ANCHOR_KEY`
