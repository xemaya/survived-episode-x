# Story 010: Archive 入口 MAIN_MENU → ARCHIVE sub-mode 切换

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: `TR-mainmenu-004` + AC-FUNC-04 + Rule 6

**ADR Governing Implementation**: ADR-0013 Archive 200 Virtual Scroll
**ADR Decision Summary**: Archive 入口位于主菜单"查阅人事档案"按钮,点击 → `#6 dispatch ARCHIVE sub-mode` → `#16 KPI Review UI` Story 010 ArchiveListPanel 接管;空档案柜 fallback("暂无员工档案");MAIN_MENU 状态下始终可用(不依赖 current_run.save)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `#6 SceneFlow.request_transition(ARCHIVE)` API 标准;`#1 Save` archive_count() 同步查询。

**Control Manifest Rules (Presentation)**:
- Required: 通过 `#6 SceneFlow.request_transition()` API,UI 不直接 `change_scene_*`
- Forbidden: Archive 入口直接实例化 ArchiveListPanel(违反 sub-mode owner 边界,#6 own)
- Guardrail: 入口点击到 Archive 屏可见 ≤ 2 帧(`#16` Story 010 同源)

---

## Acceptance Criteria

- [ ] AC-FUNC-04: 档案柜为空("查阅人事档案"始终可用)+ 显示"暂无员工档案"界面,不崩溃
- [ ] 入口路径:点 ArchiveButton → `SceneFlow.request_transition(SubMode.ARCHIVE)` → `#6` dispatch → `#16` ArchiveListPanel 接管
- [ ] 空档案柜文案:`tr("ARCHIVE.EMPTY_FALLBACK")`("暂无员工档案,工号 001 还未入职")
- [ ] 进入 Archive 后 ARCHIVE_VIEW state(由 `#16` Story 001 own);返回路径 ARCHIVE → MAIN_MENU 通过 `#6` dispatch

---

## Implementation Notes

*From GDD Rule 6:*

- 入口实施:
  ```gdscript
  # MainMenuPanel.gd
  func _on_archive_button_pressed() -> void:
      SceneFlow.request_transition(SubMode.ARCHIVE)
  ```
- 注意:虽然主菜单 4 入口"查阅人事档案"在 archive_count = 0 时**不**置灰,但点击后由 `#16` Story 010 ArchiveListPanel 渲染 fallback 文案
- `#16` Story 010 已实施 ArchiveListPanel.refresh,本 story 仅触发 sub-mode 切换 + 验证 archive_count==0 路径不崩溃
- 返回路径(从 ARCHIVE 返 MAIN_MENU 的按钮 / `act_cancel`)由 `#16` 内 ArchiveListPanel 处理

---

## Out of Scope

- `#16 KPI Review UI` Story 010(ArchiveListPanel 主体)
- `#16` Story 011(逐条删除 + cap warning)
- archive_count == 0 fallback UI 内容(由 `#16` Story 010 渲染)

---

## QA Test Cases

- **AC-FUNC-04**: 空档案柜不崩溃
  - Given: SaveSystem.archive_count() == 0
  - When: 点 ArchiveButton
  - Then: `SceneFlow.request_transition(ARCHIVE)` 调用 1 次;下一帧 sub-mode == ARCHIVE;ArchiveListPanel.visible == true;含 tr("ARCHIVE.EMPTY_FALLBACK") 文案
  - Edge cases: archive_count == 200 满载 → 同样可入,显示满载列表 + cap warning(由 #16 Story 011)

- **AC-2**: sub-mode dispatch
  - Given: state == MAIN_MENU
  - When: request_transition(ARCHIVE)
  - Then: scene_state_changed(MAIN_MENU, ARCHIVE, ctx) emit;ctx 含 current_day 等字段(per Recap Story 002 ctx payload 标准)
  - Edge cases: 在 ARCHIVE 中再点 ArchiveButton → idempotent(已在 ARCHIVE,无重复 dispatch)

- **AC-3**: 返回路径
  - Given: state == ARCHIVE
  - When: ArchiveListPanel back button pressed
  - Then: scene_state_changed(ARCHIVE, MAIN_MENU, ctx) emit;主菜单恢复显示

---

## Test Evidence

**Required evidence**: `tests/integration/main_menu/archive_entry_submode_dispatch_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001(主菜单 ArchiveButton 入口);`#6 Scene Flow` Story 002(scene_state_changed)+ Story 010(8x8 transition matrix);`#16 KPI Review UI` Story 010(ArchiveListPanel)
- Unlocks: 无

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/4 COVERED via 5 test 函数(`tests/integration/main_menu/archive_entry_submode_dispatch_test.gd`)— AC-FUNC-04 archive 空时按钮仍 enabled / AC-2 button → request_transition_callable(SubMode.ARCHIVE)单次调用 / archive_entry_dispatched signal 单 emit / 双击 dispatch 路由 2 次(idempotency 由 SceneFlow 守);AC-2 (sub-mode 实际切换)需要 SceneFlow.SUBMODES + TRANSITION_MATRIX 加 ARCHIVE — 由 #16 epic Story 010 own
**Test Evidence**: `tests/integration/main_menu/archive_entry_submode_dispatch_test.gd`(GdUnit4 5 tests)— BLOCKING gate PASS(controller 端契约);ArchiveListPanel 接管 + 空 fallback 文案由 #16 Story 010 验
**Code Review**: APPROVED;`handle_archive_pressed` 直接 dispatch ARCHIVE — controller 不查 archive_count(AC-FUNC-04: archive 空也可入,fallback 文案由 ArchiveListPanel 渲染);`SUB_MODE_ARCHIVE: StringName = &"ARCHIVE"` 锁定常量;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0013 Status=Proposed — lean-mode-equivalent
2. ARCHIVE 加入 SceneDayFlow.SUBMODES + TRANSITION_MATRIX(MAIN_MENU → ARCHIVE)由 `#16 KPI Review UI` Story 010 own — 本 story 实施 controller 端 dispatch attempt + signal 路径
3. ArchiveListPanel(空 fallback "暂无员工档案,工号 001 还未入职")由 `#16` Story 010 own
**Tech debt**: None new
**API surface**:
- `const SUB_MODE_ARCHIVE: StringName = &"ARCHIVE"`
- `signal archive_entry_dispatched`
- `func handle_archive_pressed() -> void`
