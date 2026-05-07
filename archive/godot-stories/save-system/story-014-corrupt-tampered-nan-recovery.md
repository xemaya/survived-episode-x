# Story 014: Corrupt / Tampered / NaN Recovery

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-005`
**ADR Governing Implementation**: ADR-0003 Save Format
**ADR Decision Summary**: 损坏存档(无效 JSON)→ 弹"存档损坏"对话框 + 备份原文件至 `.corrupt_[ISO8601]`(取证保留)+ "继续"按钮变灰;手改字段(如 `current_ap: 999`)→ 加载不抛异常 + AP 字段以 999 载入(clamp 责任在 AP System);NaN/Inf 净化(R-AP-5 + Rule 16)→ 替换为 0.0 + `sanitized_fields` 数组记录路径 + 一次性"数值异常已修复"对话框。

**Engine**: Godot 4.6 | **Risk**: LOW(JSON parse 错误处理 + float NaN 检测)
**Engine Notes**: GDScript 内置 `is_nan()` / `is_inf()` 检测;`JSON.parse_string()` 返 null 时是 invalid JSON。

**Control Manifest Rules**:
- Required: 损坏文件备份至 `.corrupt_[ISO8601]`(取证保留)
- Required: NaN/Inf 净化为 0.0 + `sanitized_fields` 数组记录
- Forbidden: 静默吞错 / crash 进程

## Acceptance Criteria

- [ ] **AC-ROBUST-03** Edge 3.1 损坏弹窗:QA 替换 `current_run.save` 为 `"{ invalid json"` → 点"继续" → 弹"存档损坏" + `user://` 下生成 `current_run.save.corrupt_[ISO8601]` + "继续"按钮变灰
- [ ] **AC-ROBUST-02** Edge 3.4 手改 AP:QA 文本编辑器把 `current_ap: 5` 改 999 → 点"继续" → 加载不抛异常不崩溃 + Save 不拒绝 + AP 字段 999 载入(clamp 责任在 `#7 AP System`)+ 进程未退出
- [ ] **AC-ROBUST-05** Edge 6.2 / Rule 16 NaN 净化:测试钩子注入 `effort_accumulator = NaN, potential = +Inf` → autosave 完成 + reload → 两字段值 0.0 + `sanitized_fields` 数组包含对应路径 + loader 展示一次"数值异常已修复"对话框

## Implementation Notes

```gdscript
# save_system.gd
const ISO_FORMAT := "%04d-%02d-%02dT%02d-%02d-%02dZ"

func load_current_run() -> CurrentRunSaveState:
    var path := SaveStateLoader.CURRENT_RUN_PATH
    if not FileAccess.file_exists(path):
        return null
    var f := FileAccess.open(path, FileAccess.READ)
    var json_text := f.get_as_text()
    f.close()
    var parsed := JSON.parse_string(json_text)
    if parsed == null:
        # 损坏 — 备份 + 弹对话框
        var ts := Time.get_datetime_dict_from_system()
        var corrupt_path := path + ".corrupt_" + ISO_FORMAT % [ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second]
        DirAccess.copy_absolute(path, corrupt_path)
        emit_signal(&"save_corrupt_detected", corrupt_path)
        return null
    var dict := parsed as Dictionary
    var state := CurrentRunSaveState.new()
    var sanitized := state.deserialize(dict)  # deserialize 返 sanitized_fields Array
    if not sanitized.is_empty():
        emit_signal(&"sanitized_fields_recovered", sanitized)
    return state

# save_state.gd
class_name CurrentRunSaveState
extends Resource

func deserialize(dict: Dictionary) -> Array[String]:
    var sanitized: Array[String] = []
    for key in dict:
        var value = dict[key]
        if value is float:
            if is_nan(value) or is_inf(value):
                dict[key] = 0.0
                sanitized.append(key)
        # ... 递归 nested Dict / Array 检查
    # ... 应用 sanitized dict 到 self
    return sanitized
```

## Out of Scope

- Story 013:`.tmp` 残留处理(独立)
- Story 015:磁盘满(独立)
- AP / KPI / NPC system 各自的 clamp 责任(在各 epic Story)

## QA Test Cases

- **AC-ROBUST-03**:Given QA 替换 current_run.save 为 `"{ invalid json"`;When 点"继续";Then 弹"存档损坏" + `current_run.save.corrupt_[ISO]` 生成 + "继续"按钮变灰
- **AC-ROBUST-02**:Given 文本编辑器改 `current_ap: 5` → 999;When 点"继续";Then 加载不抛异常不崩溃 + AP 999 载入 + 进程未退出
- **AC-ROBUST-05**:Given 测试钩子 `effort_accumulator = NaN, potential = +Inf`;When autosave + reload;Then 两字段 = 0.0 + sanitized_fields = [`effort_accumulator`, `potential`] + 一次性"数值异常已修复"对话框

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/save/corrupt_recovery_test.gd` + `tests/integration/save/nan_inf_sanitize_test.gd`
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 001(三槽位)+ Story 002(autosave)+ Story 006(状态机 ERROR)
- Unlocks: KPI Review UI epic Story(损坏弹窗 UI)

## Completion Notes
**Completed**: 2026-05-01 (retroactive close — implementation landed during Stories 002/003 implementation cycle, /story-done was missed)
**Criteria**: 3/3 in-scope COVERED via 8 test 函数 (4 in corrupt_recovery_test + 4 in nan_inf_sanitize_test):
- AC-ROBUST-03 损坏 JSON 弹窗 + ISO backup — `test_corrupt_invalid_json_emits_signal_and_creates_iso_backup` + `test_corrupt_backup_signal_carries_iso_timestamp_format`
- AC-ROBUST-02 手改 AP 999 不崩 — `test_tampered_ap_field_loads_999_without_exception` + `test_tampered_field_does_not_emit_corrupt_signal`
- AC-ROBUST-05 NaN/Inf 净化 + sanitized_fields signal — `test_nan_and_inf_floats_sanitize_to_zero_and_emit_signal_with_paths` + `test_clean_save_emits_no_sanitized_signal` + `test_nested_array_nan_recorded_with_index_path` + `test_sanitize_walks_nested_dictionaries_in_subsystem_payload`
**Test Evidence**:
- `tests/integration/save/corrupt_recovery_test.gd` (267 行 / 4 tests)
- `tests/integration/save/nan_inf_sanitize_test.gd` (304 行 / 4 tests)
- BLOCKING gate PASS
**Implementation surface (already shipped)**:
- `SaveStateLoader.load_current_run_with_recovery() -> Dictionary` (corrupt detection + sanitization 入口)
- `SaveStateLoader._backup_corrupt_file(path) -> String` (ISO 8601 备份 + sentinel 路径处理)
- `CurrentRunSaveState.deserialize() -> Array[String]` (sanitize walker, NaN/Inf → 0.0 + sanitized_fields 收集)
- `SaveSystem.save_corrupt_detected(backup_path)` signal
- `SaveSystem.sanitized_fields_recovered(fields)` signal (一次性 per-session guard)
- UI subscriber 接 dialog 实施 — KPI Review UI epic
**Code Review**: Complete (随 Stories 002/003 同期 review,signal 契约 + per-session guard 已 land)
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0003 Status=Proposed — lean-mode-equivalent
2. UI subscriber (存档损坏 modal / 数值异常已修复 toast) deferred KPI Review UI epic
3. Status field 未在原实施时同步更新 — 本次 retroactive close (实施事实 + tests + signals 全部已 ship)
**Tech debt**: None new
