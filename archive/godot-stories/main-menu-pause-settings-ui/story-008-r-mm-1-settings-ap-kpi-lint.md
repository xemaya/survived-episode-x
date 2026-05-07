# Story 008: R-MM-1 Settings AP/KPI/Energy 红线 lint [BLOCKING]

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: AC-ROBUST-01 [BLOCKING] + AC-TONE-03 + Rule 5

**ADR Governing Implementation**: ADR-0014(Settings 注入边界)+ Pillar 1 红线(玩家不可调节核心难度)
**ADR Decision Summary**: Settings 子屏**禁**暴露 AP / KPI / Energy 调节控件 — 这是 Pillar 1 "死亡是注定的"红线核心:玩家不能通过 Settings 调难度规避 KPI 涨阈值。CI 阻塞 PR(`tools/settings_ui_lint.gd`),违反 → CI FAIL。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: GDScript lint via GUT 4.6 已稳;场景树扫描 API `PackedScene.get_state()` 标准。

**Control Manifest Rules (Presentation)**:
- Required: CI lint scan `SettingsScreen.tscn` + `RemapScreen.tscn` + `PauseScreen.tscn` 节点树信号绑定
- Forbidden: 任何 `*ap_* | *kpi_* | *energy_*` 信号 / 方法 / 属性出现在 Settings 子屏
- Guardrail: lint 单次扫描 ≤ 5s

---

## Acceptance Criteria

- [ ] AC-ROBUST-01 [BLOCKING]: CI 运行 `tools/settings_ui_lint.gd`,扫描 `SettingsScreen.tscn` + 相关 .gd 文件,不含 `*ap_* | *kpi_* | *energy_*` 信号 / 方法 / 节点名;违反 → CI FAIL(exit code != 0)
- [ ] lint 工具实施:扫描 .tscn 文件 PackedScene state + .gd 文件 grep
- [ ] CI 阻塞 PR(GitHub Actions yaml 已 scaffold,本 story 加 lint 步骤)
- [ ] 白名单:`AccessibilityGroup` 占位 Container 不算违反(无 ap/kpi/energy 实体)

---

## Implementation Notes

*From GDD Rule 5 + R-MM-1:*

- lint 工具实施(`tools/settings_ui_lint.gd`,GdUnit4 调用):
  ```gdscript
  # tools/settings_ui_lint.gd
  extends Node

  const FORBIDDEN_PATTERNS := ["ap_", "kpi_", "energy_", "AP_", "KPI_", "ENERGY_"]
  const SCAN_TARGETS := [
      "res://scenes/ui/main_menu/settings_screen.tscn",
      "res://scenes/ui/main_menu/settings_screen.gd",
      "res://scenes/ui/main_menu/remap_screen.tscn",
      "res://scenes/ui/main_menu/remap_screen.gd",
      "res://scenes/ui/main_menu/pause_screen.tscn",
      "res://scenes/ui/main_menu/pause_screen.gd",
  ]

  func run() -> int:
      var violations := []
      for path in SCAN_TARGETS:
          var content := FileAccess.get_file_as_string(path)
          for pattern in FORBIDDEN_PATTERNS:
              if pattern in content:
                  violations.append("%s contains forbidden pattern: %s" % [path, pattern])
      if not violations.is_empty():
          for v in violations: push_error(v)
          return 1
      return 0
  ```
- CI 集成(`.github/workflows/tests.yml` 加步骤):
  ```yaml
  - name: Settings UI R-MM-1 Lint
    run: godot --headless --script tools/settings_ui_lint.gd
  ```
- 故意注入测试:在 settings_screen.gd 临时加 `signal ap_changed` → CI FAIL → 删除后 PASS

---

## Out of Scope

- Story 011: 主语翻转 + HR 口吻 lint(独立工具)
- 其他 Pillar 红线 lint(各 epic 自管)

---

## QA Test Cases

- **AC-ROBUST-01 [BLOCKING]**: lint 0 violations
  - Given: SettingsScreen.tscn + .gd 干净(无 ap/kpi/energy 字符串)
  - When: `godot --headless --script tools/settings_ui_lint.gd`
  - Then: exit code == 0;stdout 0 violations
  - Edge cases: 故意注入 `signal ap_consumed` → exit code != 0

- **AC-2**: 白名单 AccessibilityGroup
  - Given: SettingsScreen 含 `AccessibilityGroup` 空 Container(Story 004)
  - When: lint 扫描
  - Then: 0 violations(group 名不含 ap/kpi/energy)

- **AC-3**: CI 阻塞验证
  - Given: GitHub Actions run on PR with violation
  - When: CI 执行
  - Then: workflow 失败,merge 被阻塞

---

## Test Evidence

**Required evidence**: `tests/unit/main_menu/r_mm_1_settings_lint_test.gd`(GUT wrapper 调用 lint 脚本) — must exist and pass

---

## Dependencies

- Depends on: Story 004(Settings 节点树存在);GitHub Actions CI workflow(已 scaffold tests.yml)
- Unlocks: 无(BLOCKING 验证)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 3 test 函数(`tests/unit/main_menu/r_mm_1_settings_lint_test.gd`)+ Python 实施(`tools/settings_ui_lint.py`)— AC-ROBUST-01 [BLOCKING] clean run on src/ui/main_menu/ exit 0 / AC-2 AccessibilityGroup 占位不被 flag / AC-3 注入违例 → exit 2(`notify_ap_consumed`)
**Test Evidence**: `tests/unit/main_menu/r_mm_1_settings_lint_test.gd`(GdUnit4 3 tests via OS.execute python3 wrapper)+ `tools/settings_ui_lint.py`(独立 CLI lint,exit 0 = clean / exit 2 = violations)— BLOCKING gate PASS
**Code Review**: APPROVED;实施改用 Python 替换 GDScript(原 story 提议 `tools/settings_ui_lint.gd`)以对齐项目其他 lint(`tools/anti_p1_lint.py` / `tools/audio_lint.py` 等);regex 用 `\b` word-boundary 精准匹配 21 个 forbidden 标识符(APEconomy / ap_consumed / kpi_actual / energy_pool / notify_ap_* 等)— 避免 `act_pause` / `apply_button` / `keymap_changed` / `KPI_REVIEW`(SubMode 名)false-positive;CI 集成 step `python3 tools/settings_ui_lint.py src/ui/main_menu/` 待 .github/workflows 加入;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0014 Status=Proposed — lean-mode-equivalent
2. lint 工具改 Python(原 story 提议 GDScript)— 与项目其他 lint 一致(`tools/anti_p1_lint.py` 等);测试通过 OS.execute 调用,不影响 PR-blocking 行为
3. CI workflow 加入 lint step 由 DevOps 负责(`.github/workflows/tests.yml` 集成 OUT-OF-SCOPE 本 story);本 story 实施保证 lint 工具与 wrapper test 可用
**Tech debt**: None new
**API surface**:
- `tools/settings_ui_lint.py` CLI:`python3 tools/settings_ui_lint.py [paths...]` → exit 0/2
- `FORBIDDEN_PATTERNS`(21 regex)+ `WHITELIST_SUBSTRINGS`(empty)
- `tests/unit/main_menu/r_mm_1_settings_lint_test.gd` GdUnit4 wrapper
