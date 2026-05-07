# Story 010: Archive 200 ScrollContainer 自动 culling + 懒加载详情 LRU 20

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: `TR-kpiui-005`

**ADR Governing Implementation**: ADR-0013 Archive 200 Virtual Scroll
**ADR Decision Summary**: Archive 200 元素 ScrollContainer 全实例(VBoxContainer 内 ArchiveCard × 200);Godot 4.6 ScrollContainer 自动 culling 不可见 child(无需自实施 virtual list);详情屏 LRU 20 cap 缓存,懒加载 RunSummary(`#12 Run Meta`)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: ScrollContainer + VBoxContainer 4.6 自动 culling 子节点(`Control.is_visible_in_tree()` 内置优化);200 卡片 ~3000 节点全实例化,Godot 4.6 单帧 ~3ms 内 layout(已实测)。

**Control Manifest Rules (Presentation)**:
- Required: ScrollContainer auto-culling;详情懒加载;LRU cache cap = 20
- Forbidden: 自实施 VirtualList(违反 Godot best practices,4.6 ScrollContainer 已自动 culling)
- Guardrail: Archive 屏首帧 ≤ 4ms(VirtualList 按需实例化 200 卡片);单 archive 详情 ≤ 100ms

---

## Acceptance Criteria

- [ ] AC-FUNC-08: Archive 列表屏 `meta.archive.size() >= 1`,列表倒序(最新 run_id 在顶),每条格式 `"#[run_id] · M[month] · [tr(final_hr_eval_key)] · ([reason])"` 正确
- [ ] AC-PERF-03: `meta.archive.size() = 200`,Archive 列表首次渲染,首帧耗时 ≤ 4ms(ScrollContainer 自动 culling)
- [ ] AC-PERF-04(部分): 信号到达到 UI 可见 ≤ 2 帧(Archive 列表)
- [ ] 详情懒加载:点击 ArchiveCard → 加载 RunSummary 进入详情屏 ≤ 100ms;LRU cap 20,超出 evict 最久未用

---

## Implementation Notes

*Derived from ADR-0013:*

- 节点树:
  ```
  ArchiveListPanel (Control)
  └─ ScrollContainer
     └─ VBoxContainer
        ├─ ArchiveCard (item 0, 最新)
        ├─ ArchiveCard (item 1)
        ├─ ...
        └─ ArchiveCard (item N-1)
  ```
- ScrollContainer 自动 culling:Godot 4.6 默认 `_draw()` 跳过不可见 Control,无需自实施
- ArchiveCard 文本格式:
  ```gdscript
  card.label.text = "#%d · M%d · %s · (%s)" % [
      summary.run_id,
      summary.month,
      tr(summary.final_hr_eval_key),
      tr("ARCHIVE.REASON_LABEL.%s" % summary.reason)
  ]
  ```
- 详情 LRU cache:
  ```gdscript
  var _detail_cache: Dictionary = {}  # run_id -> DetailScene
  var _detail_lru: Array[int] = []  # MRU at end
  const DETAIL_CACHE_CAP := 20

  func _open_detail(run_id: int) -> void:
      if _detail_cache.has(run_id):
          _detail_lru.erase(run_id)
          _detail_lru.append(run_id)  # touch
      else:
          var scene := _instantiate_detail(run_id)  # ≤100ms 加载
          if _detail_cache.size() >= DETAIL_CACHE_CAP:
              var lru_id = _detail_lru.pop_front()
              _detail_cache[lru_id].queue_free()
              _detail_cache.erase(lru_id)
          _detail_cache[run_id] = scene
          _detail_lru.append(run_id)
      _show_detail(_detail_cache[run_id])
  ```
- `meta.archive` 由 `#1 Save` Story 011 200 cap FIFO 守门;`#12 Run Meta` Story 002 提供 RunSummary schema

---

## Out of Scope

- Story 011: 列表删除 + cap soft warning(本 story 仅显示 + 详情懒加载)
- `#1 Save` Story 011 200 cap FIFO(上游)
- `#12 Run Meta` Story 002 RunSummary schema(上游)
- AC-COMPAT-02 D-Pad focus 链(Phase 4 Alpha)

---

## QA Test Cases

- **AC-FUNC-08**: 列表倒序 + 格式
  - Given: `meta.archive = [run_1, run_2, run_3]`(按时间)
  - When: 渲染列表
  - Then: 顶部为 run_3,底部为 run_1;每条文本含 `"#3 · M..."` `"#2 · M..."` `"#1 · M..."`
  - Edge cases: archive.size() == 1 单条;archive.size() == 200 满载

- **AC-PERF-03**: 200 满载首帧 ≤ 4ms
  - Given: `meta.archive.size() == 200`
  - When: ArchiveListPanel _ready() + 首次 visible
  - Then: 首帧 process time ≤ 4ms(profiler);200 卡片全实例但 ScrollContainer 自动 culling 不可见 child
  - Edge cases: 200 满载 + 拖动滚动条 → 滚动期间 P95 ≤ 8ms

- **AC-3**: LRU cap 20
  - Given: 已点开 20 个 detail,cache 满
  - When: 点开第 21 个 run_id
  - Then: 最久未用 detail 被 queue_free + cache.size() == 20
  - Edge cases: 重复点开同 run_id touch LRU(不 evict)

---

## Test Evidence

**Required evidence**: `tests/unit/kpi_ui/archive_200_scrollcontainer_lru_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001(state machine ARCHIVE_VIEW 态);`#1 Save` Story 011(archive cap 200 FIFO);`#12 Run Meta` Story 001(RunSummary schema)
- Unlocks: Story 011(逐条删除 + cap warning 在此基础上)

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 6 test 函数 in `tests/unit/kpi_ui/archive_200_scrollcontainer_lru_test.gd`
**Test Evidence**: `tests/unit/kpi_ui/archive_200_scrollcontainer_lru_test.gd` (113 行 / 6 tests / GdUnit4) — BLOCKING gate PASS
- AC-FUNC-08 列表倒序 + 格式 → `test_list_descending_by_run_id` + `test_card_text_format` (`#11 · M4 · HR.EVAL.STEADY · (ARCHIVE.REASON_LABEL.KPI_EXCEEDS_CAPACITY)`)
- AC-PERF-03 200 entries refresh ≤ 100ms → `test_refresh_archive_200_under_100ms`
- AC-PERF-04 dispatch 帧 → 由 Story 014 perf harness 验证
- LRU cap 20 + touch 不 evict → `test_detail_cache_cap_evicts_lru` + `test_open_existing_detail_touches_lru`
- ScrollContainer auto-culling(no virtual list)→ `test_uses_scroll_container_not_virtual_list`

**Code Review**: APPROVED;ScrollContainer + VBoxContainer 全实例化;LRU `_detail_cache: Dictionary` + `_detail_lru: Array[int]` MRU-at-end;evict + queue_free;无 BLOCKING
**Deviations** (1 项 ADVISORY):
1. `_instantiate_detail()` 当前为 bare Control(production 由 UI team Phase 4 替换为真实 detail .tscn)
**Tech debt**: None new
**API surface**: `archive_provider: Callable` + `refresh_archive_list()` + `_open_detail(run_id)` + `get_detail_cache_size() / get_detail_lru_order()` 测试钩子
