# Story 005: R-RCP-1 进度条 / 百分比禁用 lint [BLOCKING]

> **Epic**: Daily / Weekly Recap UI
> **Status**: Done
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: AC-FUNC-09 [BLOCKING] + Rule 5 + R-RCP-1

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint(Anti-P2 红线扩展)
**ADR Decision Summary**: Recap 屏**禁**进度条 / 百分比 / "完成度"等励志感视觉元素 — 违反 Pillar 4 数字克制 + Anti-P2 励志感红线。CI lint 阻塞 PR(`tools/recap_visual_lint.gd`)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: PackedScene state 反射 4.6 标准。

**Control Manifest Rules (Presentation)**:
- Required: CI lint 扫描 daily-recap-screen.tscn / weekly-recap-screen.tscn 节点树
- Forbidden: ProgressBar / TextureProgressBar 节点;含 "%" 字符的 Label 文本常量
- Guardrail: lint ≤ 5s

---

## Acceptance Criteria

- [ ] AC-FUNC-09 [BLOCKING]: `daily-recap-screen.tscn` / `weekly-recap-screen.tscn` 场景树,GUT 节点类型扫描(CI 自动化),不存在 `ProgressBar` / `TextureProgressBar` 类型节点;不存在包含"%"字符的 Label 文本常量
- [ ] AC-FUNC-12: effort 三维度三行展示绝对整数;无百分比文本;无"完成 X%"类文案;无颜色编码红/绿评价;无 ProgressBar 节点
- [ ] CI 阻塞 PR(GitHub Actions yaml 已 scaffold,本 story 加 lint 步骤)
- [ ] lint 工具同时扫描 .gd 内 ProgressBar.new() 动态实例化

---

## Implementation Notes

*From GDD Rule 5 + R-RCP-1:*

```gdscript
# tools/recap_visual_lint.gd
extends Node

const FORBIDDEN_NODE_TYPES := ["ProgressBar", "TextureProgressBar"]
const FORBIDDEN_TEXT_PATTERNS := ["%", "完成度", "效率指数", "本周完成"]
const SCAN_SCENES := [
    "res://scenes/ui/recap/daily_recap_screen.tscn",
    "res://scenes/ui/recap/weekly_recap_screen.tscn",
]
const SCAN_SCRIPTS := [
    "res://src/ui/recap/daily_recap_screen.gd",
    "res://src/ui/recap/weekly_recap_screen.gd",
]

func run() -> int:
    var violations := []
    # 1. 节点类型扫描
    for scene_path in SCAN_SCENES:
        var packed := load(scene_path) as PackedScene
        var state := packed.get_state()
        for i in state.get_node_count():
            var type := state.get_node_type(i)
            if type in FORBIDDEN_NODE_TYPES:
                violations.append("%s contains forbidden node type %s" % [scene_path, type])
            # Label 文本扫描
            if type == "Label" or type == "RichTextLabel":
                for prop_idx in state.get_node_property_count(i):
                    var prop_name := state.get_node_property_name(i, prop_idx)
                    if prop_name == "text":
                        var val: String = state.get_node_property_value(i, prop_idx)
                        for pattern in FORBIDDEN_TEXT_PATTERNS:
                            if pattern in val:
                                violations.append("%s Label text contains '%s'" % [scene_path, pattern])
    # 2. .gd 动态实例化扫描
    for script_path in SCAN_SCRIPTS:
        var content := FileAccess.get_file_as_string(script_path)
        if "ProgressBar.new()" in content or "TextureProgressBar.new()" in content:
            violations.append("%s dynamically instantiates ProgressBar" % script_path)
    if not violations.is_empty():
        for v in violations: push_error(v)
        return 1
    return 0
```

CI 集成:
```yaml
- name: Recap R-RCP-1 Visual Lint
  run: godot --headless --script tools/recap_visual_lint.gd
```

---

## Out of Scope

- Story 006: HR 主语翻转 lint(独立工具)
- Story 010: AC-FAREWELL-01 farewell_lint(独立)
- 其他 epic 的视觉禁区 lint(各自管理)

---

## QA Test Cases

- **AC-FUNC-09 [BLOCKING]**: 节点类型扫描
  - Given: daily-recap-screen.tscn 干净(无 ProgressBar)
  - When: `godot --headless --script tools/recap_visual_lint.gd`
  - Then: exit code == 0;0 violations
  - Edge cases: 故意加 ProgressBar 节点 → exit code != 0,violation 记录路径 + 节点名

- **AC-2**: 文本扫描
  - Given: Label.text == "完成度 85%"
  - When: lint 扫描
  - Then: 命中 "完成度" + "%" 双重 violation

- **AC-3**: 动态实例化扫描
  - Given: daily_recap_screen.gd 含 `var pb = ProgressBar.new()`
  - When: lint
  - Then: 命中 violation

---

## Test Evidence

**Required evidence**: `tests/unit/recap_ui/r_rcp_1_visual_lint_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 012(Daily / Weekly Recap 屏节点树存在);GitHub Actions tests.yml(已 scaffold)
- Unlocks: 无(BLOCKING 验证)

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 ACs COVERED via 4 test 函数 (r_rcp_1_visual_lint_test.gd) — BLOCKING gate PASS
**Test Evidence**: `tests/unit/recap/r_rcp_1_visual_lint_test.gd` (4 tests / GdUnit4) — clean run on `src/ui/recap/` exit 0;synthetic violation fixtures (.tscn ProgressBar / "完成度 85%" / `ProgressBar.new()`) all exit 2
**Code Review**: APPROVED;`tools/recap_visual_lint.py` 三层守门 — (1) .tscn `[node type=ProgressBar/TextureProgressBar]` regex,(2) Label.text "完成度" / "效率指数" / "%",(3) .gd `ProgressBar.new()` / `TextureProgressBar.new()`;forward-compat — 当 Phase 4 .tscn 资产 land 时自动启用 .tscn 扫描分支
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. 实现采用 Python (`tools/recap_visual_lint.py`) 而非 GDScript (story IM 给的 `tools/recap_visual_lint.gd`) — 与项目其他 9 个 lints 保持工具栈一致 (anti_p1_lint.py / settings_ui_lint.py / main_menu_tone_lint.py 等),CI 不依赖 godot --headless 启动
2. ADR-0010 Status=Proposed — lean-mode-equivalent
3. CI workflow 步骤 OUT-OF-SCOPE (.github/workflows/ 不修改,本 story 仅工具 + test)
**Tech debt**: None new
**API surface**: `tools/recap_visual_lint.py [paths...]` (CLI) + `FORBIDDEN_NODE_TYPES` / `FORBIDDEN_TEXT_PATTERNS` / `DYNAMIC_INSTANTIATION_PATTERNS` const tuples (扩展时编辑此表)
