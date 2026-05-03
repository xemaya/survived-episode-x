# Story 011: Archive 200 Cap FIFO + No Batch Delete

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-004`
**ADR Governing Implementation**: ADR-0013 Archive 200 Cap Virtual Scroll
**ADR Decision Summary**: `archive_hard_cap_count = 200` runs 硬上限;200 cap 时 Block 新 Run + 弹"档案柜已满"对话框;**禁批量删 / clear all / 搜索 / 重命名**(P3 仪式感:Archive 是墓园);玩家在 Archive 列表逐条删档(单档删除允许);archive_index 在启动期 load(轻量 ~5KB)+ archive 详情懒加载 LRU 20 cap。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `DirAccess.remove_absolute()` + 只读位清除(跨平台抽象)。

**Control Manifest Rules**:
- Required: 200 cap FIFO + 单档删除允许 + 启动期 archive_index 加载
- Forbidden: `delete_all_archives()` / `clear_all_archives()` / 批量删 / 搜索 / 筛选 / 重命名(P3 仪式感)
- Guardrail: archive_soft_warning_count = 180 软警告

## Acceptance Criteria

- [ ] `ArchiveIndexEntry` Resource:`run_id / month / end_reason / timestamp / 7 字段 RunSummary`
- [ ] `meta.archive_index: Array[ArchiveIndexEntry]` 启动期已加载(~5KB)
- [ ] **AC-FUNC-14** Rule 23 archive 200 cap 行为:fixture 已有 200 archive + 无 current_run.save → 主菜单点"新游戏" → 弹对话框含"档案柜已满(200/200)"+ "新游戏"按钮被拒 + UI 不提供批量删除 / 全清按钮 + 玩家在 Archive 列表删 1 份后"新游戏"按钮解锁
- [ ] **AC-PERF-05** 档案柜批量:200 archive 总目录体积 < 5MB;主菜单点"档案柜"列表渲染 < 200ms p99(SSD)+ 滚动 FPS ≥ 60
- [ ] `delete_archive(run_id)` 单档删除 API(允许);**禁** `delete_all_archives()` / `clear_all_archives()`
- [ ] 软警告 archive_soft_warning_count = 180:达 180 时主菜单显示提示

## Implementation Notes

```gdscript
# save_system.gd
const ARCHIVE_HARD_CAP := 200  # entities.yaml: archive_hard_cap_count
const ARCHIVE_SOFT_WARNING := 180

func can_start_new_run() -> Dictionary:
    var index := load_meta().archive_index
    if index.size() >= ARCHIVE_HARD_CAP:
        return {"allowed": false, "reason": "archive_full", "count": index.size()}
    if index.size() >= ARCHIVE_SOFT_WARNING:
        return {"allowed": true, "warning": "archive_almost_full", "count": index.size()}
    return {"allowed": true}

func delete_archive(run_id: int) -> Error:
    var archive_path := SaveStateLoader.ARCHIVE_DIR + "%04d.save" % run_id
    if not FileAccess.file_exists(archive_path):
        return ERR_FILE_NOT_FOUND
    OS.set_file_read_only(archive_path, false)
    DirAccess.remove_absolute(archive_path)
    var meta := load_meta()
    meta.archive_index = meta.archive_index.filter(func(e): return e.run_id != run_id)
    save_meta_async(meta)
    return OK

# 严禁实施:
# func delete_all_archives() -> void: assert(false, "P3 forbidden_pattern archive_batch_delete")
# func clear_all_archives() -> void: assert(false, "P3 forbidden_pattern archive_batch_delete")
```

## Out of Scope

- Story 007:ARCHIVING 5 步事务(归档完成后调 `_enforce_archive_cap()` 在 archive_completed 时检查;但不在本 story 自动 FIFO 驱逐 — 200 cap 的 Block 新 Run 是 Path B,不是 Path A 自动 pop_front)
- Archive UI(在 KPI Review & Game Over UI epic Story)

## QA Test Cases

- **AC-FUNC-14**:Given fixture archive 200 个 + 无 current_run.save;When 主菜单点"新游戏";Then 弹对话框"档案柜已满(200/200)"+ "新游戏"按钮被拒 + UI 不提供批量删除 / 全清按钮(DOM/focus 遍历断言);玩家删 1 档后"新游戏"解锁
- **AC-PERF-05**:Given 200 archive;When 主菜单点"档案柜";Then 总目录 < 5MB + 列表渲染 < 200ms p99 + 滚动 ≥ 60 FPS
- **P3 守门**:Given 测试钩子调 `delete_all_archives()`;When;Then assert 失败 + 函数不存在(代码审查 — 无对应 API)

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/save/archive_cap_test.gd` + `tests/integration/save/archive_200_full_dialog_test.gd`
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 007(ARCHIVING 5 步)+ Story 001(三槽位)
- Unlocks: KPI Review UI epic Archive 列表屏 Story

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/6 in-scope COVERED + 3/6 cross-epic UI 域 OUT-OF-SCOPE (story 自陈)
- AC-1 ArchiveIndexEntry Resource — COVERED via `src/save/archive_index_entry.gd` + round-trip test
- AC-2 meta.archive_index 启动期 load — COVERED 复用 `meta.archive: Array` (Story 001 已存在;字段命名 deviation 见下)
- AC-FUNC-14 data layer 200 cap behavior — COVERED via 5 阈值矩阵 (0/179/180/199/200) + can_start_new_run 三态返回 + 反射断言守 P3 无 batch API;主菜单 UI 对话框部分 deferred KPI Review UI epic
- AC-PERF-05 列表渲染 <200ms / 60 FPS — DEFERRED KPI Review UI epic (UI 渲染域)
- AC-5 delete_archive(run_id) + 禁 batch — COVERED via API + 反射守门
- AC-6 软警告 180 — COVERED data layer (`{warning: archive_almost_full}`);主菜单 UI banner 部分 deferred KPI Review UI epic
**Test Evidence**: `tests/unit/save/archive_cap_test.gd` 9 tests / 252 行 — BLOCKING gate PASS;cross-epic test `archive_200_full_dialog_test.gd` deferred KPI Review UI epic
**Code Review**: APPROVED (lean-mode 内联 autopilot);FileAccess.set_read_only_attribute(false) 清只读位再 remove (Windows ReadOnly 守);Lambda typed 参数;反射断言守 P3 红线;无 BLOCKING / 无 inline fix
**Deviations** (4 项 ADVISORY,无 BLOCKING):
1. ADR-0013 Status=Proposed — lean-mode 等同 Accepted (Stories 001-010 同前例)
2. 字段命名: story 提 `meta.archive_index: Array[ArchiveIndexEntry]`,实施复用 `meta.archive: Array`(Story 001 已存在 untyped Array)避免破坏 schema_version=1 兼容;ArchiveIndexEntry Resource 提供 serialize/deserialize 契约,meta.archive 存 Dict 形式(与 Story 010 untyped Dict + API 契约同前例)
3. AC-FUNC-14 / AC-PERF-05 / AC-6 UI 部分(主菜单对话框 / 列表渲染 / 软警告 banner)全 deferred 到 KPI Review UI epic — story Out of Scope 已声明
4. CI lint `tools/anti_p1_lint.py`(P3 forbidden_pattern `archive_batch_delete` PR-blocking)— 后续 tools epic;runtime 守门(反射断言 + API 不存在)已守
**Tech debt**: None new
**API surface**:
- `class_name ArchiveIndexEntry extends Resource` (5 字段:run_id / month / end_reason / timestamp / run_summary opaque)
- `SaveSystem.ARCHIVE_HARD_CAP: int = 200` const
- `SaveSystem.ARCHIVE_SOFT_WARNING: int = 180` const
- `SaveSystem.can_start_new_run() -> Dictionary` (三态:allowed / warning+count / reason+count)
- `SaveSystem.delete_archive(run_id: int) -> Error` (单档,禁 batch)
