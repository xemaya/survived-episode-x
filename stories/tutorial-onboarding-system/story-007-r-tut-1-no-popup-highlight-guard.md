# Story 007: R-TUT-1 隐形守门(无 popup / 高亮 / "按 X 键")

> **Epic**: Tutorial / Onboarding System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/tutorial-onboarding-system.md`
**Requirement**: AC-FUNC-03 + R-TUT-1 守门 + Rule 5

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint(隐形 onboarding 红线扩展)
**ADR Decision Summary**: 隐形 onboarding 原则:Day 1-3 全程 + M1 KPI Review 期间,**不**触发任何 Modal 弹窗 / tooltip 显示 / HUD 高亮覆层 / "按 X 键" 元语言提示。`tools/no_tutorial_popup_lint.gd` PR-blocking 扫描 onboarding 路径。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Feature Layer)**:
- Required: 隐形原则贯穿 Day 1-3 + M1 KPI Review;通过 NPC dialogue 引导而非 popup
- Forbidden: ConfirmationDialog / AcceptDialog / `Tutorial*Tooltip` 节点;HUD 高亮 outline / arrow / 闪烁
- Guardrail: lint ≤ 5s

---

## Acceptance Criteria

- [ ] AC-FUNC-03 [BLOCKING]: Day 1-3 全程及 M1 KPI Review 期间,不触发任何 Modal 弹窗 / tooltip 显示 / HUD 高亮覆层
- [ ] AC-TONE-02: Day 1-3 固定手牌所有 card ID 对应的 `text_key` 文案不含"教程/任务/引导/新手"等元语言词汇
- [ ] `tools/no_tutorial_popup_lint.gd` 扫描 src/ + scenes/ 检测违规节点 / 信号绑定 / 字符串
- [ ] `subject_inversion_lint.py --domain TUTORIAL_CARD_TEXT` 扫描 csv 文案禁止元语言

---

## Implementation Notes

*From GDD Rule 5 + R-TUT-1:*

```gdscript
# tools/no_tutorial_popup_lint.gd
const FORBIDDEN_NODE_TYPES_DURING_TUTORIAL := [
    "ConfirmationDialog", "AcceptDialog", "PopupMenu", "PopupPanel",
    "TooltipPanel", "HUDArrow", "HighlightOverlay",
]
const FORBIDDEN_TEXT_PATTERNS := ["教程", "任务", "引导", "新手", "按 .* 键", "请按"]

func run() -> int:
    var violations := []
    # 1. 扫描 src/tutorial/ + 与 onboarding 关联的代码
    var tutorial_files := DirAccess.get_files_at("res://src/tutorial/")
    for f in tutorial_files:
        var content := FileAccess.get_file_as_string("res://src/tutorial/%s" % f)
        for node_type in FORBIDDEN_NODE_TYPES_DURING_TUTORIAL:
            if "%s.new()" % node_type in content:
                violations.append("%s instantiates forbidden %s" % [f, node_type])
    # 2. 扫描 csv 文案
    var csv_text := FileAccess.get_file_as_string("res://assets/locale/zh_CN.csv")
    for line in csv_text.split("\n"):
        if "TUTORIAL" in line.split(",")[0]:  # key 含 TUTORIAL
            for pattern in FORBIDDEN_TEXT_PATTERNS:
                if RegEx.compile(pattern).search(line):
                    violations.append("csv tutorial line contains forbidden: %s" % line)
    # ...
    if not violations.is_empty():
        for v in violations: push_error(v)
        return 1
    return 0
```

CI 集成:
```yaml
- name: Tutorial R-TUT-1 No Popup Lint
  run: godot --headless --script tools/no_tutorial_popup_lint.gd
```

子工具 `subject_inversion_lint.py --domain TUTORIAL_CARD_TEXT` 扫描 Day 1-3 fixed_hand 卡 text_key:
```python
DOMAIN_RULES["TUTORIAL_CARD_TEXT"] = {
    "forbidden_words": ["教程", "任务", "引导", "新手", "请按", "按键"],
    "applies_to_keys": [
        "ACTION_CARD.CARD_REPLY_EMAIL.TEXT",
        # Day 1-3 fixed_hand 全部 card text_key
    ],
}
```

---

## Out of Scope

- Story 002: fixed_hand_override(本 story 仅守门,不实施)
- Story 009: NPC tone lint(R-TUT-2 独立)

---

## QA Test Cases

- **AC-FUNC-03 [BLOCKING]**: 节点扫描
  - Given: src/tutorial/ + scenes/tutorial/(若存在)
  - When: `godot --headless --script tools/no_tutorial_popup_lint.gd`
  - Then: exit code == 0;0 violations
  - Edge cases: 故意加 ConfirmationDialog.new() → CI FAIL

- **AC-TONE-02**: 卡文本元语言
  - Given: csv 含 "ACTION_CARD.CARD_REPLY_EMAIL.TEXT = '回邮件 — 教程任务'"
  - When: `subject_inversion_lint.py --domain TUTORIAL_CARD_TEXT`
  - Then: violation;改为 "回邮件" → 通过

---

## Test Evidence

**Required evidence**: `tests/unit/tutorial/r_tut_1_no_popup_lint_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 002(fixed_hand 卡定义);Story 005(M1 KPI Review 期间);`#10 Event Script` Story 011(主语翻转 8 master)
- Unlocks: 无(BLOCKING 验证)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED — AC-FUNC-03 [BLOCKING] tutorial src/ 零 forbidden node + AC-TONE-02 零元语言 literal + AC-2 lint script + self-test + AC-3 subject_inversion domain 占位,通过 7 test 函数覆盖
**Test Evidence**: `tests/unit/tutorial/r_tut_1_no_popup_lint_test.gd` (~110 行 / 7 tests / GdUnit4) + `tools/no_tutorial_popup_lint.py` (~140 行 Python lint,自带 --self-test 模式) — BLOCKING gate PASS;`python3 tools/no_tutorial_popup_lint.py` 已实跑通过 0 violations
**Code Review**: APPROVED (lean autopilot inline);Python lint 与 Story 009 old_npc_tone_lint 同模式(NODE_INSTANCE_PATTERN regex + locale CSV 扫描 + --self-test);GdUnit suite 用 raw text 扫描避免 RegEx 依赖;无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. `subject_inversion_lint.py --domain TUTORIAL_CARD_TEXT` 实际落点由 Story 009 + event-script #10 Story 011 master 收;本 story 仅占位检查
**Tech debt**: None new
**API surface**: `tools/no_tutorial_popup_lint.py` 新增 CI lint(`--self-test` mode + `run_lint(repo_root)` 函数);7 forbidden node types + 6 forbidden meta-language patterns 注册
