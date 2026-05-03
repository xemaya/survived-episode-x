# Story 004: Dictionary 3-Layer Index + Cooldown + Morning Blacklist

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` | **Requirement**: `TR-event-005` + `TR-event-006`
**ADR**: ADR-0009(三层索引 + cooldown + once_per_run + morning_blacklist 7 天滑动)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: Dictionary 三层索引(by_trigger / by_chapter / by_npc)
- Required: cooldown_until + once_per_run + morning_blacklist 7 天滑动

## Acceptance Criteria

- [ ] `_by_trigger: Dictionary[TriggerType, Array[EventResource]]`
- [ ] `_by_chapter: Dictionary[String, Array[EventResource]]`
- [ ] `_by_npc: Dictionary[NpcId, Array[EventResource]]`
- [ ] `_triggered_history: Dictionary[StringName, bool]`(once_per_run)
- [ ] `_cooldown_until: Dictionary[StringName, float]`(per-event cooldown)
- [ ] `_morning_blacklist: Dictionary[StringName, int]`(7 天滑动 — day_index)

## Implementation Notes

```gdscript
var _by_trigger: Dictionary[EventTrigger.TriggerType, Array] = {}
var _by_chapter: Dictionary[String, Array] = {}
var _by_npc: Dictionary[StringName, Array] = {}
var _triggered_history: Dictionary[StringName, bool] = {}
var _cooldown_until: Dictionary[StringName, float] = {}
var _morning_blacklist: Dictionary[StringName, int] = {}

func _index_events(events: Array[EventResource]) -> void:
    for event in events:
        _by_trigger.get_or_add(event.trigger.type, []).append(event)
        if event.chapter:
            _by_chapter.get_or_add(event.chapter, []).append(event)
        if event.trigger.npc_id:
            _by_npc.get_or_add(event.trigger.npc_id, []).append(event)

func is_eligible(event: EventResource, current_day: int) -> bool:
    if event.once_per_run and _triggered_history.get(event.event_id, false):
        return false
    if _cooldown_until.get(event.event_id, 0.0) > Time.get_ticks_msec():
        return false
    if event.morning_blacklist:
        var day_in_blacklist := _morning_blacklist.get(event.event_id, 0)
        if current_day - day_in_blacklist < 7:
            return false
    return true
```

## QA Test Cases

- 三层索引完整(by_trigger / by_chapter / by_npc)
- once_per_run + cooldown + morning_blacklist 7 天滑动各自守门

## Test Evidence

`tests/unit/event/three_layer_index_test.gd`

## Dependencies

- Depends on: Story 001 + Story 002
- Unlocks: Story 013(状态机 trigger evaluator)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 6/6 COVERED via 8 test 函数
**Test Evidence**: `tests/unit/event/three_layer_index_test.gd` (~155 行 / 8 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);3 layer Dictionary 索引 (by_trigger/by_chapter/by_npc) + by_id 第 4 fast-lookup 索引,is_eligible 三 gate 顺序 (once_per_run → cooldown → morning_blacklist),mark_fired 写 3 maps,7-day 窗 严格 `delta < 7` (off-by-one guard verified day 17 boundary);无 BLOCKING / 无 inline fix
**Engine API Verification**: GDScript Dictionary 索引 / Array.duplicate() / Array.has() — 无 4.5+ 新 API
**Deviations** (1 项 ADVISORY):
1. ADR-0009 Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `EventScriptEngine` autoload + `index_events(events)` / `is_eligible(event, current_day)` / `mark_fired(event, current_day)` / `get_events_by_trigger/chapter/npc()` / `get_event_by_id()` + `MORNING_BLACKLIST_WINDOW_DAYS = 7` const
