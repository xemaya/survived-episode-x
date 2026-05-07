# Story 007: event_started Signal + Density Lock at Emit Time

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` | **Requirement**: `TR-event-009`
**ADR**: ADR-0001 event_started signal owner = #10 + ADR-0004(EVENT_ACTIVE 切档延后)+ ADR-0012(密度在 emit 时锁定)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `event_started(event_id, narrative_tier)` signal owner = #10(2 subs:#14 主消费 + #13 flash overlay)
- Required: density 在 emit 时锁定到事件结束(EVENT_ACTIVE 切档延后,ADR-0004)

## Acceptance Criteria

- [ ] `signal event_started(event_id: StringName, narrative_tier: StringName)` owner = #10
- [ ] `_emit_event_started(event)` API:读取当前 narrative_density 锁定到 event end + emit signal + 同帧 dispatch
- [ ] `event_completed(event_id)` signal owner = #10(3 subs:#6 / #13 / #15)+ emit at effect 链完成

## Implementation Notes

```gdscript
signal event_started(event_id: StringName, narrative_tier: StringName)
signal event_completed(event_id: StringName)

var _current_density: StringName = &"standard"
var _pending_density_for_next_event: StringName = &""

func _emit_event_started(event: EventResource) -> void:
    var density := _current_density  # 锁定到 event end
    emit_signal(&"event_started", event.event_id, density)

func _on_event_complete(event_id: StringName) -> void:
    if _pending_density_for_next_event != &"":
        _current_density = _pending_density_for_next_event
        _pending_density_for_next_event = &""
    emit_signal(&"event_completed", event_id)
```

## QA Test Cases

- emit event_started → density 锁定 + 2 subs 响应
- EVENT_ACTIVE 切档 → 当前 event 用旧密度,下个 event 用新密度

## Test Evidence

`tests/integration/event/event_started_test.gd`

## Dependencies

- Depends on: Story 001 + Story 005
- Unlocks: Story 008(narrative_density_changed)+ #14 Card Play UI Story

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 5 test 函数
**Test Evidence**: `tests/integration/event/event_started_test.gd` (~115 行 / 5 tests / GdUnit4 + SignalCapture helper) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`event_started(event_id, narrative_tier)` 单 emitter 签名正确,`event_completed(event_id)` payload 1-arg,emit_event_started 在 emit 前锁定 _current_density (Story 005 verbose lock 测覆盖),emit_event_completed 应用 _pending_density (Story 008 集成);无 BLOCKING / 无 inline fix
**Engine API Verification**: GDScript signal emit + Callable 订阅 — 无 4.5+ 新 API
**Deviations** (1 项 ADVISORY):
1. ADR-0001 / 0004 / 0012 Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `signal event_started(event_id, narrative_tier)` + `signal event_completed(event_id)` (owner = #10) + `emit_event_started(event)` / `emit_event_completed(event_id)` 公共 API
