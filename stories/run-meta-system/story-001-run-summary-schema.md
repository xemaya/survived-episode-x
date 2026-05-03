# Story 001: RunSummary 7-Field Schema + run_started/run_ended Signals

> **Epic**: run-meta-system | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/run-meta-system.md` | **Requirement**: `TR-run-meta-001`
**ADR**: ADR-0003 sub-schema run_meta + ADR-0001 run_started / run_ended signal owner = #12
**Engine**: Godot 4.6 | **Risk**: MEDIUM

**Control Manifest Rules**:
- Required: RunSummary 7 字段 schema + run_started/run_ended signal owner = #12

## Acceptance Criteria

- [ ] `class_name RunSummary extends Resource` 含 7 字段:`run_id / start_timestamp / end_timestamp / month_at_end / end_reason / hr_evaluation_text / final_archive_path`
- [ ] `signal run_started` + `signal run_ended(run_id: int, month: int, reason: StringName)` owner = #12
- [ ] `_on_save_loaded` 启动 → 检测 current_run.save 存在 → emit run_started

## Implementation Notes

```gdscript
class_name RunSummary extends Resource
@export var run_id: int
@export var start_timestamp: int
@export var end_timestamp: int
@export var month_at_end: int
@export var end_reason: StringName  # KPI_EXCEEDS_CAPACITY / DISMISSAL / ...
@export var hr_evaluation_text: String  # F1 三轴选词
@export var final_archive_path: String
```

## QA Test Cases

- 7 字段 schema 完整 + Save round-trip(协作 Save Story)
- run_started/run_ended signal owner = #12

## Test Evidence

`tests/unit/run_meta/run_summary_schema_test.gd`

## Dependencies

- Depends on: Save Story 001
- Unlocks: 全 Run Meta stories

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 12 test 函数
**Test Evidence**: `tests/unit/run_meta/run_summary_schema_test.gd` (228 行 / 12 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);RunSummary 7 字段 @export Resource + serialize/deserialize round-trip(76 行);RunMetaSystem run_started/run_ended/run_meta_unlock/demo_end_reached signal owner = #12;begin_run / end_run / _on_save_loaded 入口,session 级一次性 guard;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. project.godot autoload 注册推迟到后续配置 story(同 SaveSystem 先例)— lean-mode-equivalent
**Tech debt**: None new
**API surface**: `class_name RunSummary extends Resource` (7 @export 字段 + serialize/deserialize);`class_name RunMetaSystem extends Node` (signals: run_started / run_ended(run_id, month, reason) / run_meta_unlock(content_id) / demo_end_reached;methods: _on_save_loaded(has_active_run) / begin_run(run_id) / end_run(month, reason) / has_active_run / get_active_run)
