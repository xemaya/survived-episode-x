# Story 003: 8 Element 7-Signal Subscriptions

> **Epic**: hud-diegetic | **Status**: Complete | **Layer**: Presentation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/hud-diegetic.md` | **Requirement**: `TR-hud-003`
**ADR**: ADR-0001 + ADR-0011 8 元素订阅 7 信号
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 8 元素订阅链 — scene_state_changed / accumulation_event / relationship_changed / ap_changed / kpi_threshold_changed / npc_lifecycle_changed / event_completed / hero_card_played

## Acceptance Criteria

- [ ] 8 元素各自 _ready 订阅(per ADR-0011 表):
  - DeskCoffeeMug → hero_card_played
  - DeskDocumentStack → event_completed + hero_card_played
  - DeskStickyNotes → accumulation_event(sticky_note_count)
  - NoticeBoard → npc_left_company + event_completed
  - OfficeSteam → accumulation_event(steam_density)
  - NPCExpression → relationship_changed + npc_lifecycle_changed
  - NPCPosition → accumulation_event(npc_empty_chairs) + npc_lifecycle_changed
  - CalendarKPIIndicator → kpi_threshold_changed

## Implementation Notes

```gdscript
# desk_coffee_mug.gd
func _ready() -> void:
    ActionCardSystem.hero_card_played.connect(_on_hero_card_played)

func _on_hero_card_played(_card_id: StringName) -> void:
    play_steam_particle()  # 0.5s

# 类似 8 元素 各自 connect
```

## QA Test Cases

- 8 元素各自 _ready 后 connect 列表完整
- 触发 7 信号 → 8 元素响应 visual variant

## Test Evidence

`tests/integration/hud/signal_subscriptions_test.gd`

## Dependencies

- Depends on: Story 001 + Story 002 + Story 003 全 Foundation+Core 信号 stories
- Unlocks: Story 005(accumulation visual variant)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 8/8 COVERED via 8 test 函数(`test_accumulation_dispatch_routes_to_four_elements` / `test_hero_card_dispatch_routes_to_three_elements` / `test_event_completed_dispatch_routes_to_two_elements` / `test_npc_lifecycle_dispatch_routes_to_two_elements` / `test_relationship_dispatch_routes_to_npc_expression` / `test_kpi_dispatch_routes_to_calendar` / `test_npc_left_company_routes_to_notice_board` / `test_ap_changed_dispatch_no_op`)
**Test Evidence**: `tests/integration/hud/signal_subscriptions_test.gd`(143 行 / 8 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean autopilot inline);DiegeticHUD `register_elements()` + 7 个 `dispatch_*` 路由 callable;subscriber-only 不 emit;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. Cross-epic emitter `.connect()` 物理布线 OUT-OF-SCOPE(Phase 4 .tscn / autoload init order)
2. ap_changed 暂无 element 订阅,提供 pass-through 接口
**Tech debt**: None new
**API surface**: `DiegeticHUD.register_elements()` + `dispatch_accumulation_event` / `dispatch_relationship_changed` / `dispatch_npc_lifecycle_changed` / `dispatch_kpi_threshold_changed` / `dispatch_event_completed` / `dispatch_npc_left_company` / `dispatch_hero_card_played` / `dispatch_ap_changed`
