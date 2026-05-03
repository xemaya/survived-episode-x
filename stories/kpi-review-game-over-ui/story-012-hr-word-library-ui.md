# Story 012: HR 评语词库 UI 子菜单(无星标无进度条)

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: AC-FUNC-11

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint(HR 词条 tone 守门)
**ADR Decision Summary**: HR 评语词库 UI 子菜单展示 `meta.hr_word_library` 收集词条,**禁**新词条弹出动画 + **禁**星标 / 等级标记 / 进度条("已收集 N 条"灰字底部即止);Anti-P2 红线 — 词库不能游戏化收集成就。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 普通 Control + Label 列表;无特殊 4.6 API。

**Control Manifest Rules (Presentation)**:
- Required: 灰字底部 "已收集 N 条";所有词条 `tr(key)` 渲染
- Forbidden: 星标 / 等级标记 / 进度条 / "新词条!"弹出 / 金光动画(违反 Anti-P2)
- Guardrail: 词库屏 ≤ 4ms 单帧

---

## Acceptance Criteria

- [ ] AC-FUNC-11: `meta.hr_word_library` 有 N 条,玩家打开词库子菜单,显示 N 条 `tr(key)` 文本;无"新词条!"弹出;无星标;底部显示 `"已收集 N 条"` 灰字;无进度条
- [ ] 子菜单入口:Archive 列表屏 → "HR 词库"按钮 → HRWordLibraryPanel
- [ ] 词条渲染顺序:按收集时间倒序(最新在顶);文本展示 `tr(word_key)` + (可选)收集时间灰字标注
- [ ] **禁** ProgressBar / TextureProgressBar 节点出现在 HRWordLibraryPanel 场景树(per Rule 10 红线)

---

## Implementation Notes

*From GDD Rule 8:*

- 节点树:
  ```
  HRWordLibraryPanel (Control)
  ├─ ScrollContainer
  │  └─ VBoxContainer
  │     └─ HRWordCard × N(每条 tr(word_key) Label)
  └─ FooterLabel ("已收集 N 条" 灰字)
  ```
- 渲染:
  ```gdscript
  func refresh() -> void:
      for c in vbox.get_children(): c.queue_free()
      for word in RunMeta.hr_word_library.values():  # 倒序
          var card := preload("res://scenes/ui/hr_word_card.tscn").instantiate()
          card.label.text = tr(word.key)
          vbox.add_child(card)
      footer_label.text = tr("HR.LIBRARY.COLLECTED_COUNT").format({"n": RunMeta.hr_word_library.size()})
      footer_label.modulate = Color(0.7, 0.7, 0.7)
  ```
- HR 词条 source:`#12 Run Meta` Story 004 F1 三轴选词(effort/potential/tenure 组合)+ `#15 Recap` HR 周报词条共享(per OQ-RCP-05 待 Content plan)

---

## Out of Scope

- `#12 Run Meta` Story 004 F1 三轴选词逻辑(本 story 仅渲染)
- 词库分组 / 搜索 / 过滤(MVP 不实施)
- AC-COMPAT-02 D-Pad focus(Phase 4 Alpha)

---

## QA Test Cases

- **AC-FUNC-11**: 词库渲染
  - Given: `RunMeta.hr_word_library` 含 5 条
  - When: HRWordLibraryPanel.refresh()
  - Then: vbox 含 5 HRWordCard child + 各自 label 含 tr() 文本(非 key 字面量)+ `footer_label.text` 含 "5"
  - Edge cases: hr_word_library 空 → vbox 空 + footer "已收集 0 条";hr_word_library 30 条满 MVP → 全渲染

- **AC-2**: 禁特殊视觉元素
  - Given: HRWordLibraryPanel 场景树
  - When: 反射节点类型
  - Then: 0 ProgressBar/TextureProgressBar 节点;0 starred_count 字段;0 "level" 字段;无"新词条!"弹出动画

- **AC-3**: 灰字 footer
  - Given: 30 条词库
  - When: refresh
  - Then: `footer_label.modulate.r < 0.85` AND `footer_label.modulate == footer_label.modulate.lerp(Color.GRAY, 0)`(冷调灰)

---

## Test Evidence

**Required evidence**: `tests/unit/kpi_ui/hr_word_library_ui_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 010(Archive 列表 + 子菜单入口);`#12 Run Meta` Story 004(F1 三轴选词);`#3 Localization` Story 001(tr API)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 7 test 函数 in `tests/unit/kpi_ui/hr_word_library_ui_test.gd`
**Test Evidence**: `tests/unit/kpi_ui/hr_word_library_ui_test.gd` (115 行 / 7 tests / GdUnit4) — BLOCKING gate PASS
- AC-FUNC-11 N 条渲染 + tr() → `test_renders_one_card_per_word` + `test_footer_uses_count_key`
- 倒序(最新在顶)→ `test_descending_order_newest_top`
- 红线: 0 ProgressBar / 0 popup → `test_no_progress_bar_in_subtree` (recursive) + `test_no_new_word_popup`
- 灰字 footer → `test_footer_modulate_is_grey`
- 空库边界 → `test_empty_library_zero_count`

**Code Review**: APPROVED;HRWordLibraryPanel + ScrollContainer + VBoxContainer + 灰字 footer;keys.reverse() 倒序;无 ProgressBar 无星标无金光动画(Anti-P2 红线);无 BLOCKING
**Deviations** (1 项 ADVISORY):
1. AC-COMPAT-02 D-Pad focus 链 OUT-OF-SCOPE(Phase 4 Alpha — 由 a11y 团队对接)
**Tech debt**: None new
**API surface**: `hr_word_library_provider: Callable` + `refresh_hr_word_library()` + `LOC_KEY_HR_LIBRARY_COUNT`
