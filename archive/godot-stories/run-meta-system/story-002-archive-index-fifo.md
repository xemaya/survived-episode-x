# Story 002: archive_index Array[200] FIFO

> **Epic**: run-meta-system | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/run-meta-system.md` | **Requirement**: `TR-run-meta-002`
**ADR**: ADR-0013 archive 200 cap + ADR-0003 启动期 archive_index 加载
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: archive_index 启动期已加载(meta.save 含,~5KB)
- Required: archive_hard_cap_count = 200 + FIFO 驱逐
- Forbidden: 批量删 / clear all(P3 仪式感)

## Acceptance Criteria

- [ ] `archive_index: Array[ArchiveIndexEntry]` 200 cap(协作 Save Story 011)
- [ ] `class_name ArchiveIndexEntry extends Resource` 含 `run_id / month / end_reason / timestamp / 7 字段 RunSummary 摘要`
- [ ] FIFO 驱逐:超 200 → pop_front + DirAccess.remove_absolute(archive 文件)
- [ ] AC-FUNC-14 archive 200 cap dialog(协作 Main Menu UI Story)

## Implementation Notes

```gdscript
class_name ArchiveIndexEntry extends Resource
@export var run_id: int
@export var month: int
@export var end_reason: StringName
@export var timestamp: int

func add_archive_entry(entry: ArchiveIndexEntry) -> void:
    archive_index.append(entry)
    if archive_index.size() > 200:
        var oldest := archive_index.pop_front()
        var archive_path := "user://save/archive/%04d.save" % oldest.run_id
        OS.set_file_read_only(archive_path, false)
        DirAccess.remove_absolute(archive_path)
```

## QA Test Cases

- 201 archive → FIFO pop_front 最旧 + 删 .save
- 启动期加载 < 5KB(meta.save 引用)

## Test Evidence

`tests/unit/run_meta/archive_fifo_test.gd`(协作 Save Story 011)

## Dependencies

- Depends on: Story 001 + Save Story 011
- Unlocks: KPI Review UI Archive 屏 Story

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 10 test 函数
**Test Evidence**: `tests/unit/run_meta/archive_fifo_test.gd` (190 行 / 10 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);ARCHIVE_HARD_CAP=200 const + add_archive_entry() FIFO pop_front + DirAccess.remove_absolute() best-effort 驱逐 + archive_count() / is_archive_full() Main Menu 谓词;复用 ArchiveIndexEntry(Save Story 011 既有);严格 201 触发 / 5-batch FIFO 顺序 / null 守门 / missing-file 不报错四类边界覆盖;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. on-disk eviction 走 push_warning(不是 push_error)— 仪式感 P3 非阻塞,index 已 pop_front 即视为成功
**Tech debt**: None new
**API surface**: `RunMetaSystem.add_archive_entry(entry: ArchiveIndexEntry) -> int`(返回驱逐 run_id 或 -1) / `archive_count() -> int` / `is_archive_full() -> bool` / const ARCHIVE_HARD_CAP=200
