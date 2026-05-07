# Story 001: 主菜单 4 入口 + New Run 冲突对话框 + Archive 满禁用

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: `TR-mainmenu-001`(主菜单部分)

**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix(主菜单不持有业务信号,仅订阅 Save current_run.save 状态)
**ADR Decision Summary**: Main Menu 4 入口("继续上班" / "入职新员工" / "查阅人事档案" / "公司停业(退出)"),状态由 `#1 Save` `current_run.exists` + `archive_count` 字段驱动,UI 不缓存 Save 状态。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `Button.disabled` 4.6 已稳;`ConfirmationDialog` API 4.6 标准。

**Control Manifest Rules (Presentation)**:
- Required: 按钮 disabled 状态由 Save 数据驱动,UI 不计算
- Forbidden: hardcode 按钮文案,违反 AC-COMPAT-03(全 tr() 路径)
- Guardrail: 主菜单首帧 ≤ 4ms

---

## Acceptance Criteria

- [ ] AC-FUNC-01: `current_run.save` 不存在,主菜单"继续上班"按钮置灰,点击无响应
- [ ] AC-FUNC-02: `current_run.save` 存在,点"入职新员工",弹确认对话框;cancel → 不变;confirm → 旧 Run 归档 → 新 Run 初始化
- [ ] AC-FUNC-03: `archive_count >= 200`,"入职新员工"置灰,tooltip 显示("档案柜已满");点击无响应
- [ ] AC-FUNC-04(部分): "查阅人事档案"始终可用(空档案柜显示"暂无员工档案",不崩溃 — Archive 入口路径在 Story 010)

---

## Implementation Notes

*From GDD Rule 1:*

- 节点树:
  ```
  MainMenuPanel (Control)
  ├─ ContinueButton (Button "继续上班")
  ├─ NewRunButton (Button "入职新员工")
  ├─ ArchiveButton (Button "查阅人事档案")
  └─ QuitButton (Button "公司停业")
  ```
- 状态同步:
  ```gdscript
  func refresh() -> void:
      continue_button.disabled = not SaveSystem.current_run_exists()
      var archive_full := SaveSystem.archive_count() >= 200
      new_run_button.disabled = archive_full
      new_run_button.tooltip_text = tr("MAINMENU.ARCHIVE_FULL_TOOLTIP") if archive_full else ""
  ```
- New Run 冲突路径(current_run 存在 + 玩家点 NewRun):
  ```gdscript
  func _on_new_run_pressed() -> void:
      if not SaveSystem.current_run_exists():
          _start_new_run()
          return
      var dlg := ConfirmationDialog.new()
      dlg.dialog_text = tr("MAINMENU.NEW_RUN_CONFIRM")
      dlg.confirmed.connect(func(): SaveSystem.archive_current_run(); _start_new_run())
      add_child(dlg)
      dlg.popup_centered()
  ```

---

## Out of Scope

- Story 002: LOADING → MAIN_MENU 5 秒进入承诺
- Story 010: Archive 入口转 sub-mode 切换
- Settings 子屏入口(由 Story 004 提供)

---

## QA Test Cases

- **AC-FUNC-01**: 继续上班 disabled
  - Given: SaveSystem.current_run_exists() == false
  - When: MainMenuPanel.refresh()
  - Then: continue_button.disabled == true AND `_on_continue_pressed` 调用无响应
  - Edge cases: current_run.save 文件存在但损坏(corrupt 路径) → 视为不存在,按钮 disabled

- **AC-FUNC-02**: New Run 冲突
  - Given: current_run_exists() == true
  - When: 点 NewRunButton + dialog confirmed
  - Then: SaveSystem.archive_current_run() 调用 1 次 + new run 初始化
  - Edge cases: dialog cancel → archive_current_run() 0 调用

- **AC-FUNC-03**: Archive 满禁用
  - Given: archive_count == 200
  - When: refresh()
  - Then: new_run_button.disabled == true AND tooltip_text != ""
  - Edge cases: archive_count == 199 → button enabled

---

## Test Evidence

**Required evidence**: `tests/unit/main_menu/main_menu_four_entries_test.gd` — must exist and pass

---

## Dependencies

- Depends on: `#1 Save` Story 001(三槽位 schema)+ Story 011(archive_count API);`#3 Localization` Story 001(tr API)
- Unlocks: Story 002, 004, 010

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 11 test functions(`tests/unit/main_menu/main_menu_four_entries_test.gd`)— AC-FUNC-01 disabled + 灰按钮无响应 / AC-FUNC-02 conflict dialog confirm + cancel + no-conflict / AC-FUNC-03 archive 200 disabled + 199 enabled + tooltip / AC-FUNC-04 archive button 始终可用 + dispatch 路径
**Test Evidence**: `tests/unit/main_menu/main_menu_four_entries_test.gd`(GdUnit4 11 tests)— BLOCKING gate PASS
**Code Review**: APPROVED(lean autopilot inline);DI seam 设计(`current_run_exists_provider` / `archive_count_provider` / `archive_current_run_callable` / `start_new_run_callable` / `request_transition_callable` / `tr_callable`)使本 controller 无 autoload 依赖即可单元测试;`refresh()` 通过 `call_deferred` 绕过 `_ready` 重负载(AC-PERF-01 配合 Story 002);`ARCHIVE_HARD_CAP` 与 SaveSystem 同源常量(本地 sentinel 避免 cross-autoload 耦合);无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0001 Status=Proposed — lean-mode-equivalent
2. .tscn 资产 OUT-OF-SCOPE(UI team Phase 4)— controller 提供 widget 骨架与信号 wiring,production wiring 时 .tscn 节点直接附加本脚本即可
3. `ConfirmationDialog` 弹出由 `_show_new_run_conflict_dialog` 钩子推迟到 production 时实例化;tests 通过 `resolve_new_run_dialog(bool)` 直注 confirm/cancel
**Tech debt**: None new
**API surface**:
- `class_name MainMenuController extends Control`
- `signal refreshed`
- `signal new_run_dialog_resolved(confirmed: bool)`
- `signal archive_entry_dispatched`
- `func refresh() -> void`
- `func handle_continue_pressed() -> void` / `handle_new_run_pressed()` / `handle_archive_pressed()` / `handle_quit_pressed()`
- `func resolve_new_run_dialog(confirmed: bool) -> void`
- 6 个 Callable seams(DI for tests + production wiring)
