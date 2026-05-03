# Story 012: Save Persistence — event_history + cooldown + blacklist

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` | **Requirement**: `TR-event-005`
**ADR**: ADR-0003 sub-schema event_script
**Engine**: Godot 4.6 | **Risk**: MEDIUM

**Control Manifest Rules**:
- Required: Save sub-schema event_script(event_history / cooldown_map / flag_dict / morning_blacklist)round-trip
- Required: schema_version 匹配 — 旧版 lint DEPRECATED;MVP 不支持迁移

## Acceptance Criteria

- [ ] `serialize() / deserialize(dict)` API 协作 SaveSystem
- [ ] sub-schema 4 字段:`event_history: Array[StringName] / cooldown_map: Dictionary / flag_dict: Dictionary / morning_blacklist: Dictionary`
- [ ] schema_version=1 匹配;旧版 lint DEPRECATED + dev WARN

## Implementation Notes

```gdscript
func serialize() -> Dictionary:
    return {
        "schema_version": 1,
        "event_history": _triggered_history.keys(),
        "cooldown_map": _cooldown_until.duplicate(true),
        "flag_dict": _flag_dict.duplicate(true),
        "morning_blacklist": _morning_blacklist.duplicate(true),
    }

func deserialize(dict: Dictionary) -> void:
    if dict.get("schema_version", 0) != 1:
        push_warning("[EventScript] schema_version mismatch — DEPRECATED")
    var hist: Array = dict.get("event_history", [])
    for eid in hist:
        _triggered_history[StringName(eid)] = true
    _cooldown_until = dict.get("cooldown_map", {})
    _flag_dict = dict.get("flag_dict", {})
    _morning_blacklist = dict.get("morning_blacklist", {})
```

## QA Test Cases

- Save round-trip:event_history / cooldown / blacklist 4 字段保留
- schema_version=0 旧版 → push_warning + DEPRECATED
- crash 恢复后 once_per_run / cooldown 状态保留

## Test Evidence

`tests/integration/event/save_persistence_test.gd`(协作 Save Story)

## Dependencies

- Depends on: Story 004 + Save Story 001(三槽位)
- Unlocks: 跨 Run state persist

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 + R-EVT-3 corrupt grace COVERED via 8 test 函数
**Test Evidence**: `tests/integration/event/save_persistence_test.gd` (~165 行 / 8 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`serialize()` 5 字段 (schema_version=1 + event_history Array[String] sorted / cooldown_map / flag_dict / morning_blacklist),round-trip 4 字段全保留,deserialize schema_version != 1 push_warning DEPRECATED,空 dict 安全清空 (R-EVT-3 corrupt grace),event_history 用 sorted Array 而非 Dictionary 导出 (stable git-friendly diff);无 BLOCKING / 无 inline fix
**Engine API Verification**: Dictionary.duplicate(true) — 4.x 标准
**Deviations** (1 项 ADVISORY):
1. ADR-0003 Status=Proposed — lean-mode-equivalent;实际 SaveSystem 集成 (request_autosave 协作) 留作 cross-epic wiring,本 story 仅 sub-schema 自治
**Tech debt**: None new (SaveSystem 三槽位调用方在 #6 SceneFlow 已有 hook 点;sub-schema 自治测覆盖)
**API surface**: `EventScriptEngine.serialize() -> Dictionary` + `deserialize(dict)` + `SAVE_SCHEMA_VERSION = 1` const + `_get_triggered_history_snapshot() / _get_cooldown_until_snapshot() / _get_morning_blacklist_snapshot() / get_flag_dict()` 测 seam
