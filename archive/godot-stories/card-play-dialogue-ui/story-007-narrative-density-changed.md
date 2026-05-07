# Story 007: narrative_density_changed Subscriber (Main Consumer)

> **Epic**: card-play-dialogue-ui | **Status**: Complete | **Layer**: Presentation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/card-play-dialogue-ui.md` | **Requirement**: `TR-cardui-003`
**ADR**: ADR-0001 + ADR-0004 + Event Script Story 008(EVENT_ACTIVE 切档延后)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `narrative_density_changed` subscriber(主消费 layer)
- Required: 同协议 — EVENT_ACTIVE 切档延后(由 #10 处理,#14 仅订阅 event_started 时获取最新 density)

## Acceptance Criteria

- [ ] `_on_narrative_density_changed(new_tier)` 订阅 — 仅 IDLE 态更新 _current_density(EVENT_ACTIVE 由 #10 处理 deferral)
- [ ] 与 #10 Event Script Story 008 协调 — #10 emit event_started 时 density 已锁定

## Implementation Notes

```gdscript
var _current_density: StringName = &"standard"

func _ready() -> void:
    SettingsUI.narrative_density_changed.connect(_on_narrative_density_changed)
    # 也协作 Event Script Story 008(#10 内部 _pending_density_for_next_event)

func _on_narrative_density_changed(new_tier: StringName) -> void:
    if EventScriptEngine.get_state() != EventState.EVENT_ACTIVE:
        _current_density = new_tier
    # EVENT_ACTIVE 中 → #10 内部 _pending_density 处理 deferral
```

## QA Test Cases

- IDLE 态 narrative_density_changed → _current_density 立即应用
- EVENT_ACTIVE 态 narrative_density_changed → #10 内部 deferred(协作 Event Story 008)

## Test Evidence

`tests/integration/card_ui/density_changed_test.gd`

## Dependencies

- Depends on: Story 002 + Event Script Story 008 + Main Menu Story(narrative_density_changed emit)
- Unlocks: ADR-0004 完整集成

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 2/2 COVERED via 4 test 函数(IDLE 立即 apply;EVENT_ACTIVE deferred 不变;int 0/1/2 → brief/standard/verbose mapping + 未知 int 防御性 STANDARD;pending 通过下一次 event_started 应用)
**Test Evidence**: `tests/integration/card_ui/density_changed_test.gd` (4 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`_on_narrative_density_changed(tier: int)` 接收 settings 端 int payload;`_density_int_to_name(tier)` 转 StringName;EVENT_ACTIVE 期不更新 mirror — 与 #10 EventScriptEngine Story 008 `_pending_density_for_next_event` 协调(deferral 由 #10 owner,layer 仅订阅 + 等下次 event_started 携带的 locked tier);`event_state_provider` Callable seam 让测试控制 EventState;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. `SettingsScreenController.narrative_density_changed` connect 由 .tscn Phase 4 wiring(不在 _ready 内 hard-connect autoload)
**Tech debt**: None new
**API surface**: `_on_narrative_density_changed(tier: int)` + `_density_int_to_name(tier) -> StringName` + `var current_density / locked_density: StringName`
