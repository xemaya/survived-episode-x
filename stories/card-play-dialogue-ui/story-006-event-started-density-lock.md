# Story 006: event_started Subscriber + Density Lock

> **Epic**: card-play-dialogue-ui | **Status**: Complete | **Layer**: Presentation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/card-play-dialogue-ui.md` | **Requirement**: `TR-cardui-003`
**ADR**: ADR-0001 + ADR-0012(density 在 event_started emit 时锁定)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `_on_event_started(event_id, narrative_tier)` 订阅
- Required: 渲染 density 在 emit 时锁定(EVENT_ACTIVE 中途切档不影响当前 event)

## Acceptance Criteria

- [ ] `_on_event_started(event_id: StringName, narrative_tier: StringName)` 订阅 #10
- [ ] 渲染 density = narrative_tier(锁定到 event end)
- [ ] event_completed 后 visible = false + 清空 choices

## Implementation Notes

```gdscript
func _ready() -> void:
    EventScriptEngine.event_started.connect(_on_event_started)
    EventScriptEngine.event_completed.connect(_on_event_completed)

func _on_event_started(event_id: StringName, narrative_tier: StringName) -> void:
    var event := EventScriptEngine.get_event(event_id)
    _render_event_by_density(event, narrative_tier)

func _on_event_completed(_event_id: StringName) -> void:
    visible = false
    _clear_choices()
    npc_portrait.visible = false
```

## QA Test Cases

- event_started("LISA_LUNCH", "long") → 立绘+对白+choice 渲染
- event_started("LISA_GOODBYE", "numeric_only") → visible = false(HUD Story 008 显示)
- event_completed → visible = false + 清空

## Test Evidence

`tests/integration/card_ui/event_started_test.gd`

## Dependencies

- Depends on: Story 002 + Event Script Story 007
- Unlocks: Story 007(narrative_density_changed)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 4 test 函数(event_started "standard" → 长路径渲染 + visible=true;event_started "numeric_only" → visible=false (HUD-only);locked_density 镜像 emit-time tier;event_completed → visible=false + clear + panel_cleared signal + portrait hidden)
**Test Evidence**: `tests/integration/card_ui/event_started_test.gd` (4 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`_on_event_started(event_id, narrative_tier)` + `_on_event_completed(event_id)` 双 handler;density 在 emit time 锁到 `locked_density`(不再受 EVENT_ACTIVE 期 narrative_density_changed 影响)— 与 ADR-0001 + ADR-0012 一致;`event_provider` Callable seam 让测试可注入 .tres-free 字典 registry;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. `EventScriptEngine.event_started` connect 由 .tscn Phase 4 wiring 完成(本 controller 不在 _ready 内 hard-connect autoload — DI 风格)
**Tech debt**: None new
**API surface**: `_on_event_started(event_id: StringName, narrative_tier: StringName)` + `_on_event_completed(event_id: StringName)` + `signal panel_cleared`
