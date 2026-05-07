# Story 005: accumulation_event 4 Element Visual Variant

> **Epic**: hud-diegetic | **Status**: Complete | **Layer**: Presentation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/hud-diegetic.md` | **Requirement**: `TR-hud-003`
**ADR**: ADR-0005 4 累积维度 + ADR-0011 4 元素订阅
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 4 HUD 元素订阅 accumulation_event:DeskStickyNotes / OfficeSteam / NoticeBoard / NPCPosition
- Required: visual variant 仅响应,不写 #5 state(forbidden_pattern accumulation_event_multiple_emitters)

## Acceptance Criteria

- [ ] DeskStickyNotes 订阅 `accumulation_event(sticky_note_count, +1)` → spawn 1 sticky_note 节点(累计 ≤ 12)
- [ ] OfficeSteam 订阅 `accumulation_event(steam_density, +1)` → TextureRect.modulate.a Tween +0.03(累计 ≤ 6 级)
- [ ] NoticeBoard 订阅 `accumulation_event(yellowing_level, +1)` → NoticeBoard 边缘 yellowing tint Tween
- [ ] NPCPosition 订阅 `accumulation_event(npc_empty_chairs, +1)` → 椅子 visibility = false + dust TextureRect 渐显

## Implementation Notes

```gdscript
# desk_sticky_notes.gd
const MAX_STICKY := 12

func _on_accumulation_event(type: StringName, _delta: int) -> void:
    if type != LightingController.ACCUMULATION_TYPE_STICKY_NOTE:
        return
    if get_child_count() < MAX_STICKY:
        var sticky := preload("res://scenes/sticky_note.tscn").instantiate()
        sticky.rotation_degrees = randf_range(-8.0, 8.0)
        add_child(sticky)
```

## QA Test Cases

- emit accumulation_event(sticky, 1) × 12 → 12 sticky_note 节点
- emit accumulation_event(steam, 1) × 6 → modulate.a 0.18(M6 cap)
- accumulation_event 仅响应,不 write back(协作 Lighting Story 011 守)

## Test Evidence

`tests/integration/hud/accumulation_visual_test.gd`

## Dependencies

- Depends on: Story 002 + Story 003 + Lighting Story 003/004
- Unlocks: 累积视觉完整链

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 6 test 函数(`test_sticky_notes_cap_at_twelve` / `test_sticky_notes_multi_unit_delta_caps` / `test_office_steam_alpha_caps_at_six_levels` / `test_notice_board_yellowing_caps_at_six` / `test_npc_position_empty_chair_dust_accumulates` / `test_no_emit_in_hud_elements`)
**Test Evidence**: `tests/integration/hud/accumulation_visual_test.gd`(120 行 / 6 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean autopilot inline);4 元素 cap 守门(STICKY_NOTE_CAP=12 / STEAM_DENSITY_CAP=6 / YELLOWING_LEVEL_CAP=6 / dust=1.0);subscriber-only 不 emit;无 BLOCKING / 无 inline fix
**Deviations**(1 项 ADVISORY,无 BLOCKING):
1. 真 Tween/Sprite 视觉资产 OUT-OF-SCOPE(Phase 4 — modulate 直接 set;test 断言 final value 而非 curve)
**Tech debt**: None new
**API surface**: 4 元素 `_on_accumulation_event(type, delta)` + cap 常量(`MAX_STICKY` / `STEAM_DENSITY_CAP` / `YELLOWING_LEVEL_CAP`)+ `OfficeSteam.set_steam_layer_for_test`
