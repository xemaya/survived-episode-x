# Story 001: Three-Slot Save Files Schema

> **Epic**: save-system
> **Status**: Done
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-001`
*(Requirement text in `docs/architecture/tr-registry.yaml`)*

**ADR Governing Implementation**: ADR-0003 Save Format + WorkerThreadPool Strategy
**ADR Decision Summary**: 三槽位序列化 — `meta.save`(全局元数据)+ `current_run.save`(当前 Run 唯一)+ `archive/[run_id].save`(历代 200 cap FIFO);JSON-primary + Resource lazy parse(SaveStateLoader);schema_version 单调递增。

**Engine**: Godot 4.6 | **Risk**: MEDIUM
**Engine Notes**: `FileAccess.store_*` 4.4+ 返回 bool — 必须 `assert(ok)` 校验返回值;`current_schema_version = 1` MVP 不迁移。

**Control Manifest Rules (this layer)**:
- Required: 三槽位 `user://save/meta.save` + `user://save/current_run.save` + `user://save/archive/[run_id].save`
- Forbidden: tres + ResourceSaver / SQLite / 多槽位变体(`.slot2` / `.bak` / `.autosave1`)
- Guardrail: `current_schema_version: int` 单调递增;每 schema 字段变更 +1

## Acceptance Criteria

- [ ] `SaveSystem` autoload 创建 `user://save/` 目录(若不存在)
- [ ] 提供 `save_meta_async(state)` / `load_meta()` / `save_current_run_async(state)` / `load_current_run()` API
- [ ] **AC-FUNC-01** Rule 2 单槽铁人:`user://` 下有且仅有一份 `current_run.save`(无 `.slot2 / .bak / .autosave1` 等多槽产物)
- [ ] `SaveState extends Resource` 强类型 wrapper(`MetaSaveState` + `CurrentRunSaveState` + `ArchiveSaveState`)
- [ ] 写盘格式 = JSON(`JSON.stringify(state.serialize())`)
- [ ] 启动期 `meta.save` 加载 ≤ 50ms p99(autosave_perf_hard_ceiling_ms)

## Implementation Notes

参 ADR-0003 §1 + §2 + §4(三槽位 + JSON-primary + 8+ sub-schema):

```gdscript
class_name SaveStateLoader
extends RefCounted

const SAVE_DIR := "user://save/"
const META_PATH := SAVE_DIR + "meta.save"
const CURRENT_RUN_PATH := SAVE_DIR + "current_run.save"
const ARCHIVE_DIR := SAVE_DIR + "archive/"

static func ensure_save_dir() -> void:
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)
    DirAccess.make_dir_recursive_absolute(ARCHIVE_DIR)

static func load_meta() -> MetaSaveState:
    if not FileAccess.file_exists(META_PATH):
        return MetaSaveState.new()
    var f := FileAccess.open(META_PATH, FileAccess.READ)
    var json_text := f.get_as_text()
    var dict := JSON.parse_string(json_text) as Dictionary
    var state := MetaSaveState.new()
    state.deserialize(dict)
    return state
```

Sub-schema 8+ 系统各自 own:`save / scene_flow / ap_economy / npc_relationship / kpi_system / event_script / run_meta / tutorial`。

## Out of Scope

- Story 002:autosave + WorkerThreadPool 异步写盘
- Story 003:原子写 4 步 + snapshot_id

## QA Test Cases

- **AC-1**(三槽位创建):
  - Given:`user://save/` 不存在
  - When:`SaveSystem._ready()` 调用
  - Then:目录创建,`meta.save` / `current_run.save` / `archive/` 路径就绪
- **AC-FUNC-01**(单槽铁人):
  - Given:Run 进行中
  - When:QA `find user:// -name "current_run*"`
  - Then:**仅 1 个**结果(`current_run.save`),无 `.slot2 / .bak / .autosave1`
- **AC-PERF-load**:
  - Given:`meta.save` ~5KB
  - When:`load_meta()` × 1000 次(SSD)
  - Then:p99 < 50ms

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/save/save_state_loader_test.gd` — must exist and pass
**Status**: [ ] Not yet created

## Dependencies

- Depends on: None(Foundation root)
- Unlocks: Story 002(autosave WorkerThreadPool)+ Story 003(原子写)+ Story 005(日结算 flush)

## Completion Notes
**Completed**: 2026-04-29
**Criteria**: 6/6 passing(AC-1 + AC-2 + AC-FUNC-01 + AC-4 + AC-5 + AC-PERF-load all verified;AC-PERF-load 是 dev-machine synthetic approximation,canonical OQ-03 HDD+AV p99 ≤ 50ms 仍延 Polish 阶段 Save AC-PERF-01 实测)
**Deviations**:
- ADVISORY: `save_meta_async` / `save_current_run_async` 返 `int`(WorkerThreadPool task id)而非 ADR-0003 §2 spec snippet 的 `void` — 测试需 sync handle,生产 caller 可丢弃返回值,backward-compatible additive
- ADVISORY: project.godot autoload 注册延后(repo 暂无 project.godot 文件)— 与 a11y Story 001 同 precedent
- ADVISORY: ADR-0003 status = Proposed,lean mode 等同 Accepted per control-manifest header
**Test Evidence**: Logic — `tests/unit/save/save_state_loader_test.gd`(10 test functions covering AC-1 + AC-2 round-trip + AC-4 type-hierarchy + AC-5 JSON-format + AC-PERF + schema_version=1 + archive path helper)
**Code Review**: Complete — APPROVED(Lean mode,godot-gdscript-specialist + qa-tester gates skipped per `production/review-mode.txt = lean`;0 required changes;4 advisory suggestions deferred for batch sweep at save-system epic close)
**Files**:
- src/save/save_state.gd(new — base class)
- src/save/meta_save_state.gd(new — `MetaSaveState extends SaveState`)
- src/save/current_run_save_state.gd(new — `CurrentRunSaveState extends SaveState`)
- src/save/archive_save_state.gd(new — `ArchiveSaveState extends SaveState`)
- src/save/save_state_loader.gd(new — `SaveStateLoader extends RefCounted`,WorkerThreadPool + assert(ok))
- src/autoload/save_system.gd(new — `SaveSystem extends Node` autoload wrapper)
- tests/unit/save/save_state_loader_test.gd(new — 10 GdUnit4 test functions)
