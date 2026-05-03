# Story 004: 4-Dimension Accumulation Triggers

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-003`
**ADR**: ADR-0005 + ADR-0001(npc_left_company / scene_state_changed 订阅)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 触发链 — MONTH_END +yellowing / npc_left_company +sticky+empty_chair / overage_card_played +steam
- Required: cap 上限严守(yellowing 6 / sticky 12 / steam 6 / empty_chair = NPC pool size)

## Acceptance Criteria

- [ ] `_on_scene_state_changed(from, to)` 订阅 — `to == &"MONTH_END"` → `_yellowing_level += 1` cap 6 + emit `accumulation_event("yellowing_level", 1)` + persist Save
- [ ] `_on_npc_left_company(npc_id, reason)` 订阅 — `reason ∈ [FAREWELL/DISMISSAL/PROMOTED_LEAVE/OPTIMIZED_OUT]` → `_sticky_note_count = min(+1, 12)` + `_empty_chairs[npc_id] = true` + emit 2 signals(sticky + empty_chair) + persist
- [ ] `_on_overage_card_played(card_id)` 订阅 — `_steam_density = min(+1, 6)` + emit + persist
- [ ] Save sub-schema `lighting` 4 字段 round-trip 保留(协作 Save Story)

## Implementation Notes

```gdscript
func _on_scene_state_changed(_from: StringName, to: StringName) -> void:
    if to == &"MONTH_END" and _yellowing_level < 6:
        _yellowing_level += 1
        emit_signal(&"accumulation_event", ACCUMULATION_TYPE_YELLOWING, 1)
        _persist_to_save()

func _on_npc_left_company(npc_id: StringName, reason: StringName) -> void:
    if reason in [&"FAREWELL", &"DISMISSAL", &"PROMOTED_LEAVE", &"OPTIMIZED_OUT"]:
        _sticky_note_count = min(_sticky_note_count + 1, 12)
        _empty_chairs[npc_id] = true
        emit_signal(&"accumulation_event", ACCUMULATION_TYPE_STICKY_NOTE, 1)
        emit_signal(&"accumulation_event", ACCUMULATION_TYPE_EMPTY_CHAIRS, 1)
        _persist_to_save()
```

## QA Test Cases

- MONTH_END × 6 → yellowing cap 6;再 MONTH_END 不 emit
- npc_left_company × 12 → sticky cap 12 + empty_chair Dict 累积
- overage_card_played × 6 → steam cap 6
- Save round-trip:4 字段保留

## Test Evidence

`tests/integration/lighting/accumulation_triggers_test.gd`

## Dependencies

- Depends on: Story 003(schema)+ Save Story(sub-schema)+ Scene Flow Story + NPC Story
- Unlocks: HUD epic 4 元素订阅

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 5 test 函数(MONTH_END × 7 → cap 6 / npc_left 2 emit 同帧 / 非法 reason 忽略 / overage_card × 7 → cap 6 / Save round-trip)
**Test Evidence**: `tests/integration/lighting/accumulation_triggers_test.gd`(120 行 / 5 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode);3 个 `_on_*` handler 全签名匹配 ADR-0001 signal payload;npc_left 2 个 emit 在同函数顺序调,保证同帧 dispatch;`get_save_state_for_test`/`load_save_state_for_test` test seam 与 Save sub-schema 协作 — 实际 SaveSystem.write_section 通过 `_persist_to_save` best-effort;无 BLOCKING
**Engine API Verification**: signal `.emit()` typed args 4.0+ 稳定;`Dictionary.duplicate(true)` 深拷贝 4.4+ 稳定;`min` 内置 4.0+
**Deviations**(2 项 ADVISORY):
1. SaveSystem `write_section(section_name, dict)` 假设 — 实际签名以 Save epic 为准,本 epic 用 `has_method` guard 不会硬错
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `_on_scene_state_changed(from, to)` + `_on_npc_left_company(npc_id, reason)` + `_on_overage_card_played(card_id)` 3 个订阅 + `NPC_LEAVE_REASONS` const + `get_save_state_for_test`/`load_save_state_for_test` test seam
