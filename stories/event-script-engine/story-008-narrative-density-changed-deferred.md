# Story 008: narrative_density_changed Subscriber (EVENT_ACTIVE Deferred)

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` | **Requirement**: `TR-event-009`
**ADR**: ADR-0001(narrative_density_changed signal subscriber 之一)+ ADR-0004(EVENT_ACTIVE 切档延后下个 event_started)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `_on_narrative_density_changed(new_tier)` 订阅 #17 Settings UI emit
- Required: EVENT_ACTIVE 态切档 → 缓存到 `_pending_density_for_next_event`,当前 event 用旧密度
- Required: IDLE 态切档 → 立即应用 `_current_density`

## Acceptance Criteria

- [ ] `_on_narrative_density_changed(new_tier: StringName)` 订阅
- [ ] EVENT_ACTIVE 时 → `_pending_density_for_next_event = new_tier`(缓冲到下个 event_started 应用)
- [ ] 非 EVENT_ACTIVE 时 → `_current_density = new_tier`(立即应用)

## Implementation Notes

```gdscript
func _on_narrative_density_changed(new_tier: StringName) -> void:
    if _state == EventState.EVENT_ACTIVE:
        _pending_density_for_next_event = new_tier
    else:
        _current_density = new_tier
```

## QA Test Cases

- EVENT_ACTIVE + narrative_density_changed → _pending 缓存 + 当前 event 用旧密度;下个 event 用新密度
- IDLE + narrative_density_changed → _current_density 立即应用

## Test Evidence

`tests/integration/event/density_changed_deferred_test.gd`

## Dependencies

- Depends on: Story 007 + Main Menu Story(narrative_density_changed emit)
- Unlocks: ADR-0004 完整集成

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 5 test 函数
**Test Evidence**: `tests/integration/event/density_changed_deferred_test.gd` (~85 行 / 5 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`on_narrative_density_changed(new_tier)` 公共订阅入口 (期 `#17` MainMenuController 的 `narrative_density_changed` signal 连接到此),EVENT_ACTIVE 态 buffer 到 `_pending_density_for_next_event` last-wins,IDLE 立即写 `_current_density`,emit_event_completed 消费 pending;无 BLOCKING / 无 inline fix
**Engine API Verification**: 标准 GDScript — 无 4.5+ 新 API
**Deviations** (1 项 ADVISORY):
1. ADR-0001 / 0004 Status=Proposed — lean-mode-equivalent
**Tech debt**: None new (实际 wiring 由 main_menu epic 或 controller 在 _ready 中 `MainMenu.narrative_density_changed.connect(EventScriptEngine.on_narrative_density_changed)` — 待 project.godot 注册 autoload)
**API surface**: `EventScriptEngine.on_narrative_density_changed(new_tier: StringName)` 公共订阅入口 + `get_current_density() / get_pending_density()` 测 seam
