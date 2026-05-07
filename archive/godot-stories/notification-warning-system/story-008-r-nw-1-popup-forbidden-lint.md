# Story 008: R-NW-1 popup 红线 CI 守门 [BLOCKING]

> **Epic**: Notification & Warning System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/notification-warning-system.md`
**Requirement**: AC-ROBUST-01 [BLOCKING] + Rule 6

**ADR Governing Implementation**: ADR-0011 HUD Diegetic Render(`action_day_canvaslayer_visible` forbidden_pattern)
**ADR Decision Summary**: `#19` 不能引入任何 popup / 弹层 / "警告!"音效 — 信息载体仅为 `#13 HUD diegetic` 元素的 visual variant 切换。CI lint 守门 PR-blocking。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Presentation Layer)**:
- Required: CI lint scan src/systems/notification/(或 src/autoload/notification_warning.gd)+ scenes/(若有)
- Forbidden: popup / overlay / show_notification / warning_sound 关键字
- Guardrail: lint ≤ 5s

---

## Acceptance Criteria

- [ ] AC-ROBUST-01 [BLOCKING]: 代码库 `src/systems/notification/` 目录,CI lint 运行 `grep -r "popup\|overlay\|show_notification\|warning_sound"`,0 命中;任何命中 = CI FAILURE,PR-blocking
- [ ] 工具实施:`tools/notification_no_popup_lint.py`
- [ ] CI 集成 GitHub Actions yaml(已 scaffold)

---

## Implementation Notes

*From GDD Rule 6 + R-NW-1:*

```python
# tools/notification_no_popup_lint.py
import os, re, sys

FORBIDDEN_PATTERNS = [
    r"\bpopup\b", r"\boverlay\b", r"\bshow_notification\b", r"\bwarning_sound\b",
    r"AcceptDialog", r"ConfirmationDialog", r"PopupMenu", r"PopupPanel",
]
SCAN_DIRS = [
    "src/autoload/notification_warning.gd",
    "src/systems/notification/",  # 若存在
]

def main():
    violations = []
    for path in SCAN_DIRS:
        if not os.path.exists(path): continue
        if os.path.isdir(path):
            for root, _, files in os.walk(path):
                for f in files:
                    if not f.endswith((".gd", ".tscn")): continue
                    full = os.path.join(root, f)
                    with open(full) as fp:
                        content = fp.read()
                    for pattern in FORBIDDEN_PATTERNS:
                        for m in re.finditer(pattern, content, re.IGNORECASE):
                            violations.append(f"{full}: {m.group()}")
        else:
            with open(path) as fp:
                content = fp.read()
            for pattern in FORBIDDEN_PATTERNS:
                for m in re.finditer(pattern, content, re.IGNORECASE):
                    violations.append(f"{path}: {m.group()}")
    if violations:
        for v in violations: print(f"VIOLATION: {v}", file=sys.stderr)
        sys.exit(1)
    sys.exit(0)

if __name__ == "__main__": main()
```

CI 集成:
```yaml
- name: Notification R-NW-1 No Popup Lint
  run: python tools/notification_no_popup_lint.py
```

---

## Out of Scope

- Story 010: HR 口吻 lint(独立)
- Story 002..006 各类 warning 实施

---

## QA Test Cases

- **AC-ROBUST-01 [BLOCKING]**: 0 violations
  - Given: notification_warning.gd 干净(无 popup 关键字)
  - When: `python tools/notification_no_popup_lint.py`
  - Then: exit code == 0;0 violations
  - Edge cases: 故意 `var dlg = AcceptDialog.new()` → CI FAIL

- **AC-2**: 大小写不敏感
  - Given: 注入 `var POPUP = ...`(大写)
  - When: lint
  - Then: 命中(re.IGNORECASE)

---

## Test Evidence

**Required evidence**: `tests/unit/notification/r_nw_1_popup_lint_test.gd`(GUT wrapper)— must exist and pass

---

## Dependencies

- Depends on: Story 001(notification_warning.gd 存在);GitHub Actions tests.yml(已 scaffold)
- Unlocks: 无(BLOCKING 验证)

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 6 test 函数(AC-ROBUST-01 clean pass / AcceptDialog instantiate fail / popup 大小写不敏感 fail / warning_sound fail / multi 联合 fail / AC-2 self_test 通过)
**Test Evidence**: `tools/notification_no_popup_lint.py`(150 行)+ `tests/unit/notification/r_nw_1_popup_lint_test.py`(95 行 / 6 tests / unittest)— BLOCKING gate PASS;repo lint 实跑 0 violations
**Code Review**: APPROVED;扫描 `src/notification/` + 兼容 legacy `src/autoload/notification_warning.gd` + scenes/notification/;forbidden 6 dialog node types + 5 token regex(case-insensitive);file 类型限定 .gd / .tscn / .tres;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. story 文档要求 `tests/unit/notification/r_nw_1_popup_lint_test.gd`(GUT wrapper),实际写 `.py`(unittest)与仓库 Python lint 测试惯例对齐(参考 `anti_p1_lint_test.py` / `ap_cost_lint_test.py`)
**Tech debt**: None new
**API surface**: `tools/notification_no_popup_lint.py`(命令行 + `--self-test` + `scan_repo()` 公共函数 + `find_repo_root()` helper)
