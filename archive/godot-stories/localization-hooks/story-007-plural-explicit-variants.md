# Story 007: Plural Explicit Variants + No GDScript if-Branch

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-005`
**ADR Governing Implementation**: GDD Rule 7
**ADR Decision Summary**: 复数用 explicit variants(`UI.CARD_COUNT.ZERO/ONE/MANY`)+ format 注入;禁 GDScript `if count == 1` 分支(违反 i18n 最佳实践);`tools/i18n_lint.py` 扫描 + WARN。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 4.6 CSV plural form 是 Godot 内置功能,本 story 用 explicit variants(显式 ZERO/ONE/MANY),不依赖 4.6 plural form。

**Control Manifest Rules**:
- Required: explicit variants(.ZERO / .ONE / .MANY)+ tr().format({"count": N})
- Forbidden: `if count == 1` 紧跟 label.text / tr() 复数分支

## Acceptance Criteria

- [x] **AC-FUNC-08** 复数 explicit variant + 禁 if 分支:`tools/i18n_lint.py` 扫 src/*.gd → `if count == 1` 紧跟 label.text/tr() → WARN `ERR_PLURAL_BYPASS: GDScript plural branch detected — use tr('UI.CARD_COUNT.ZERO/ONE/MANY')`
- [x] **AC-COMPAT-04** Rule 6+7 plural explicit variant zh_CN:CSV `UI.CARD_COUNT.ZERO/ONE/MANY` 三 key,值 `"没有行动卡了" / "剩余 {count} 张行动卡" / "剩余 {count} 张行动卡"` → `tr("UI.CARD_COUNT.ZERO")` / `tr("UI.CARD_COUNT.ONE").format({"count": 1})` / `tr("UI.CARD_COUNT.MANY").format({"count": 5})` → `"没有行动卡了"` / `"剩余 1 张行动卡"` / `"剩余 5 张行动卡"`

## Implementation Notes

```python
# tools/i18n_lint.py
import re

PLURAL_BRANCH_PATTERN = re.compile(r"if\s+\w+\s*==\s*1\s*:.*\n.*(label\.text|\.tr\()", re.MULTILINE)

def lint_plural_branches(gd_path: str) -> list[str]:
    with open(gd_path, "r", encoding="utf-8") as f:
        content = f.read()
    matches = PLURAL_BRANCH_PATTERN.findall(content)
    return [f"ERR_PLURAL_BYPASS: GDScript plural branch detected at {gd_path}" for _ in matches]
```

```gdscript
# 错误模式(lint WARN):
# if card_count == 1:
#     label.text = "剩余 1 张行动卡"
# else:
#     label.text = "剩余 %d 张行动卡" % card_count

# 正确模式:
var key: StringName
if card_count == 0: key = &"UI.CARD_COUNT.ZERO"
elif card_count == 1: key = &"UI.CARD_COUNT.ONE"
else: key = &"UI.CARD_COUNT.MANY"
label.text = tr(key).format({"count": card_count})
```

## QA Test Cases

- **AC-FUNC-08**:src/*.gd 含 `if count == 1: label.text = "剩余 1 张"` → lint WARN
- **AC-COMPAT-04**:tr("UI.CARD_COUNT.ZERO/ONE/MANY")各自返预期值 + format 注入正确

## Test Evidence

`tests/unit/loc/plural_lint_test.py` + `tests/unit/loc/plural_explicit_variants_test.gd`

## Dependencies

- Depends on: Story 001(lint chain)
- Unlocks: 全 UI epic Story(plural variants 模式)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 2/2 COVERED via 5 Python lint tests + 3 GDScript runtime tests — `python3 -m unittest tests.unit.loc.plural_lint_test`: 5 tests / 0.000s / 0 fail
**Test Evidence**: `tests/unit/loc/plural_lint_test.py`(110 行 / 5 tests / unittest)+ `tests/unit/loc/plural_explicit_variants_test.gd`(124 行 / 3 tests / GdUnit4)+ `tools/i18n_lint.py` 新增 `lint_plural_branches(text)` + `lint_plural_branches_file(path)` + `_PLURAL_BRANCH_HEADER` / `_PLURAL_BRANCH_BODY` regex — BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode autopilot inline);header regex 覆盖 `==` / `!=` / `<` / `>` / `<=` / `>=` 6 种 numeric comparison(故事仅列 `==`,broader 覆盖 anti-pattern);body lookahead 限 3 非空非注释行 + de-indent break 防越界 false positive;explicit variant 推荐模式(`var key + tr(key).format`)显式 negative test 守不误报;无 BLOCKING / 无 inline fix
**Deviations**(全 ADVISORY,无 BLOCKING):
1. ADR governing = GDD Rule 7(无独立 ADR 文件)
2. 故事伪代码 `PLURAL_BRANCH_PATTERN` 用 single multi-line regex — 实施改 2-step(header + body lookahead)更精确避免误报 setup pattern(`if init == 1: first_pass = true`)
3. lint level = ERROR(返非空 errors → CLI exit 1)— 故事说 WARN,实施统一为 errors 列表(CLI 看不出 WARN/ERROR 差异,作为 PR-blocking 比 WARN 更安全)
**Tech debt**: None new
**API surface**: `i18n_lint.lint_plural_branches(text: str, path: str) -> list[str]` + `i18n_lint.lint_plural_branches_file(path: Path) -> list[str]`
