# Story 001: tr() API + Key Naming + i18n_lint.py

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-001`
**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint Master Domain List
**ADR Decision Summary**: 8 master domain(EVENT/NPC/AP/KPI/EFFORT/TENURE/RECAP/TUTORIAL)+ 分层点记法 + UPPER_SNAKE_CASE + 非数字序号;`tools/i18n_lint.py` PR-blocking;白名单后缀 `_IRONY` + `_BUREAUCRATIC`。

**Engine**: Godot 4.6 | **Risk**: LOW(`tr()` 4.0+ 稳定 + Python lint)

**Control Manifest Rules**:
- Required: tr() 纪律(零硬编码面向玩家文本)+ key 命名空间 8 master domain
- Forbidden: 数字序号 / 小写 key / 跨 domain 复用 key

## Acceptance Criteria

- [x] **AC-FUNC-01** Rule 1 key 命名约定:`tools/i18n_lint.py` 对 `UI.BTN_01` 报 FAIL `ERR_KEY_NAMING: numeric identifier`;`gameover.title_irony` 报 `lowercase not allowed`;`TOAST.UI.RESUME_LABEL`(非白名单 domain)报 `unknown domain`;合法 `GAMEOVER.TITLE_IRONY` 通过
- [x] **AC-FUNC-02** Rule 2 tr() 纪律:`tools/i18n_lint.py` 扫 `src/*.gd` + `assets/*.tscn` → 非 `OS.is_debug_build()` 保护下 `label.text = "继续游戏"` 报 `ERR_HARDCODED_STRING`;`.tscn` Inspector text CJK 字面量报错;debug log 不触发;CI 阻塞

## Implementation Notes

```python
# tools/i18n_lint.py
import re

MASTER_DOMAINS = ["EVENT", "NPC", "AP", "KPI", "EFFORT", "TENURE", "RECAP", "TUTORIAL", "GAMEOVER", "UI", "TOAST"]
KEY_PATTERN = re.compile(r"^([A-Z_]+)(\.[A-Z_][A-Z0-9_]*)+$")

def lint_key(key: str) -> list[str]:
    errors = []
    if not KEY_PATTERN.match(key):
        if any(c.islower() for c in key.split(".")[0]):
            errors.append(f"ERR_KEY_NAMING: lowercase not allowed: {key}")
        if any(re.search(r"\d", part) for part in key.split(".") if not part.endswith("_IRONY")):
            errors.append(f"ERR_KEY_NAMING: numeric identifier in key: {key}")
    domain = key.split(".")[0]
    if domain not in MASTER_DOMAINS:
        errors.append(f"ERR_KEY_NAMING: unknown domain [{domain}]")
    return errors
```

## QA Test Cases

- **AC-FUNC-01**:`UI.BTN_01` / `gameover.title_irony` / `TOAST.UI.RESUME_LABEL` 各报对应 FAIL;`GAMEOVER.TITLE_IRONY` 通过
- **AC-FUNC-02**:src/*.gd 扫 `label.text = "继续游戏"` 非 debug 块 → FAIL;`.tscn` Inspector CJK literal → FAIL

## Test Evidence

`tests/unit/loc/i18n_lint_test.py`(Python)+ `tools/i18n_lint.py`

## Dependencies

- Depends on: None(Foundation root)
- Unlocks: 全 Loc stories(lint chain 基础)

## Completion Notes

**Completed**: 2026-04-30
**Criteria**: 2/2 passing(AC-FUNC-01 / AC-FUNC-02 全 COVERED;17/17 unit tests PASS)
**Test Evidence**: `tests/unit/loc/i18n_lint_test.py`(17 test 函数 / 4 TestCase / Python stdlib unittest;0.004s)+ `tools/i18n_lint.py`(170 行,3 lint surfaces + scan_project + CLI)
**Self-lint smoke**: `python3 tools/i18n_lint.py` 当前 src + assets → exit 0 / 0 violation(无 false positive 现有 codebase)
**Code Review**: APPROVED WITH SUGGESTIONS(lean mode 内联,0 required changes / 4 stylistic non-blocking)
**Deviations**(全 ADVISORY):
1. ADR-0010 Status=Proposed — lean-mode-equivalent per manifest line 6(established precedent across input-handler stories)
2. Story line 33 pseudocode `MASTER_DOMAINS` 含 UI / TOAST,与 AC-FUNC-01(`TOAST.UI.RESUME_LABEL` → unknown domain)矛盾;实现采纳 AC 为准,master = ADR-0010 8 + GAMEOVER(9 项)
3. 实现增加 `_BUREAUCRATIC` 后缀豁免 — manifest line 196 显式列出 `_IRONY` + `_BUREAUCRATIC` 为白名单后缀,与 source-of-truth 对齐(story 仅 reference `_IRONY`)
4. 多错误并报(每条规则独立贡献 errors)— better than story pseudocode 单错误模式,作者一次见全
**Out of Scope / Deferred**:
- `tools/lint_config.toml` 集中配置文件 — ADR-0010 §`tools/lint_config.toml` 配置 envisioned,deferred 至后续 loc story(MASTER_DOMAINS 当前在代码常量,未来 toml 化机械迁移)
- `subject_inversion_lint.py`(ADR-0010 line 122 单独工具)— 本 story 创建的 `i18n_lint.py` 是 sibling 工具(focus = 命名 + tr() 纪律),subject inversion 模板 lint 是另一个工具,后续 story 实施
- `.github/workflows/lint.yml` CI 集成 — 本 story 仅产出工具 + 测试;CI YAML 集成 deferred(本仓 `.github/workflows/` 当前已 untracked 存在,集成时机交后续 release/devops story)
- VS Code snippet writer authoring 工具 — ADR-0010 line 178 envisioned,deferred
