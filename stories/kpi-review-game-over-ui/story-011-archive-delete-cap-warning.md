# Story 011: Archive 逐条删除 + autosave 触发 + soft warning ≥180

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: AC-FUNC-09 + AC-FUNC-10 + ADR-0013

**ADR Governing Implementation**: ADR-0013 Archive 200 Virtual Scroll
**ADR Decision Summary**: Archive 列表逐条选档删除(禁批量,P3 死亡仪式感),`#1 Save Rule 23` autosave 触发;`archive_soft_warning_threshold = 180`,达此阈值显示灰字 cap 警告(非红色非阻断弹框);**禁**主动 cap 弹框打断玩家。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `ConfirmationDialog` 4.6 已稳;modulate 灰字直接赋 `Color(0.7, 0.7, 0.7)`,不需 shader。

**Control Manifest Rules (Presentation)**:
- Required: 删除走 `ConfirmationDialog` 二次确认;autosave 由 `#1 Save` Story 002 触发,UI 不直接调 fsync
- Forbidden: 批量删除按钮(违反 P3 仪式感);红色警告 + 阻断弹框(违反 Rule 5 数字克制 + Anti-P2)
- Guardrail: 单条删除 ≤ 50ms(含 dialog + memory update + autosave queue)

---

## Acceptance Criteria

- [ ] AC-FUNC-09: 玩家选中条目 + confirm 删除,confirm 对话框弹出,文案使用 `tr("ARCHIVE.DELETE_CONFIRM")`(HR 口吻);confirm 后条目从列表消失 + `#12` 内存更新 + `#1 autosave` 触发
- [ ] AC-FUNC-10: `archive.size() >= 180`,Archive 列表屏展示,`CapWarningBar` 可见 + `tr("ARCHIVE.CAP_SOFT_WARNING")` 灰字(非红色,非阻断弹框)
- [ ] `archive_soft_warning_threshold = 180`(从 entities.yaml 加载,若未注册则 hardcode 此 epic 内并加 propagation flag 给 `#1 Save`)
- [ ] 删除二次确认必弹 — 防误删

---

## Implementation Notes

*From GDD Rule 7 + AC-FUNC-09/10:*

- 删除流程:
  ```gdscript
  func _on_card_delete_pressed(run_id: int) -> void:
      var dlg := ConfirmationDialog.new()
      dlg.dialog_text = tr("ARCHIVE.DELETE_CONFIRM")
      dlg.confirmed.connect(func(): _confirm_delete(run_id))
      add_child(dlg)
      dlg.popup_centered()

  func _confirm_delete(run_id: int) -> void:
      RunMeta.delete_archive_entry(run_id)  # #12 Story 002
      _refresh_list()  # 重渲染 Archive
      SaveSystem.queue_autosave()  # #1 Story 002
  ```
- cap soft warning:
  ```gdscript
  const ARCHIVE_SOFT_WARNING_THRESHOLD := 180  # 待 entities.yaml 注册

  func _refresh_list() -> void:
      # ... 渲染 ScrollContainer
      cap_warning_bar.visible = (RunMeta.archive_size() >= ARCHIVE_SOFT_WARNING_THRESHOLD)
      cap_warning_bar.modulate = Color(0.7, 0.7, 0.7)  # 灰字
      cap_warning_bar.text = tr("ARCHIVE.CAP_SOFT_WARNING")
  ```
- ARCHIVE.* keys 必填(writer 维护):
  - `ARCHIVE.DELETE_CONFIRM` — "确认归档此份记录?(此操作不可撤销)"
  - `ARCHIVE.CAP_SOFT_WARNING` — "档案柜接近上限(180 / 200),建议清理较旧条目"
  - `ARCHIVE.REASON_LABEL.*` — 三 reason 标签

---

## Out of Scope

- Story 010: 列表显示 + 详情懒加载主体
- 批量删除(MVP 不实施,Anti-P3 红线)
- AC-ROBUST-03 LEFT NPC 标注(VS tier ADVISORY)

---

## QA Test Cases

- **AC-FUNC-09**: 删除流程
  - Given: archive 含 5 entries,玩家点 entry #3 delete 按钮
  - When: ConfirmationDialog 弹出 + confirmed signal
  - Then: archive.size() == 4(去掉 #3)+ list 重渲染不含 #3 + `SaveSystem.queue_autosave()` 调用 1 次
  - Edge cases: dialog 取消 → 不删除,archive.size() 不变;连续删 5 个

- **AC-FUNC-10**: cap warning ≥180
  - Given: archive.size() == 180
  - When: 进入 Archive 列表屏
  - Then: `cap_warning_bar.visible == true` + `cap_warning_bar.modulate == Color(0.7,0.7,0.7)` + 文本 == tr("ARCHIVE.CAP_SOFT_WARNING")
  - Edge cases: archive.size() == 179 → warning 不可见;archive.size() == 200(满载)→ warning 可见(不阻断)

- **AC-3**: 无红色 / 无弹框警告
  - Given: archive.size() == 195
  - When: 进入 Archive
  - Then: 无 `AcceptDialog` 弹框 + `cap_warning_bar.modulate.r < 0.9`(非红色)

---

## Test Evidence

**Required evidence**: `tests/integration/kpi_ui/archive_delete_cap_warning_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 010(列表显示);`#12 Run Meta` Story 002(delete_archive_entry API);`#1 Save` Story 002(queue_autosave API)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 7 test 函数 in `tests/integration/kpi_ui/archive_delete_cap_warning_test.gd`
**Test Evidence**: `tests/integration/kpi_ui/archive_delete_cap_warning_test.gd` (130 行 / 7 tests / GdUnit4) — BLOCKING gate PASS
- AC-FUNC-09 删除流程 → `test_delete_dialog_uses_hr_tone_key` + `test_confirm_invokes_delete_and_autosave` + `test_archive_entry_deleted_signal_emitted`
- AC-FUNC-10 cap warning ≥180 灰字非阻断 → `test_cap_warning_visible_at_threshold` + `test_cap_warning_bar_grey` + `test_no_blocking_popup_at_threshold`
- 阈值边界 → `test_cap_warning_hidden_below_threshold` (179 → 不可见)
- soft warning 阈值默认 180(可注入 override)→ `archive_soft_warning_threshold: int` 字段

**Code Review**: APPROVED;ConfirmationDialog 二次确认;delete + queue_autosave 双 Callable seam;非红色非阻断弹框(灰 0.7,0.7,0.7);无批量删除按钮(P3 仪式感);无 BLOCKING
**Deviations** (1 项 ADVISORY):
1. `archive_soft_warning_threshold = 180` 当前为常量(per Story §"待 entities.yaml 注册");注册由 design-registry epic propagation flag 跟进
**Tech debt**: 1 — entities.yaml `archive_soft_warning_count = 180` knob 待注册(propagation flag)
**API surface**: `delete_archive_callable / queue_autosave_callable: Callable` + `request_delete_archive_entry(run_id) -> ConfirmationDialog` + `archive_entry_deleted(run_id)` signal
