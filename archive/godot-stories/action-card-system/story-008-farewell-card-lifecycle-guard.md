# Story 008: Farewell Card LIFECYCLE_ANNOUNCED Guard

> **Epic**: action-card-system | **Status**: Complete | **Layer**: Feature | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/action-card-system.md` | **Requirement**: `TR-card-001`
**ADR**: ADR-0009 farewell_event flag + NPC Story 008 + Event Script Story 006
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 道别卡仅 LEAVING_ANNOUNCED 期允许;ACTIVE / LEFT 拒绝
- Required: 道别卡触发 farewell event(numeric_only)

## Acceptance Criteria

- [ ] Card 守门:if `card.event_id ∈ FAREWELL_EVENT_IDS` → `lifecycle_allowed = [&"LEAVING_ANNOUNCED"]`
- [ ] try_play_card:LISA ACTIVE + 玩家打 LISA_GOODBYE → DISABLED(拒绝);LISA LEAVING_ANNOUNCED + 打 → 触发 farewell event(numeric_only)
- [ ] LISA LEFT + 打 → DISABLED + 提示

## Implementation Notes

```gdscript
func _can_play(card: Card) -> bool:
    if card.target_npc != &"":
        var npc_state := NPCRelationshipSystem.get_npc_state(card.target_npc)
        if npc_state.lifecycle_state not in card.lifecycle_allowed:
            return false
    # 其他守门(Story 003)...
    return true
```

## QA Test Cases

- LISA ACTIVE + LISA_GOODBYE → DISABLED;LEAVING_ANNOUNCED + LISA_GOODBYE → PLAYABLE + 触发 farewell event;LEFT + LISA_GOODBYE → DISABLED

## Test Evidence

`tests/integration/card/farewell_lifecycle_guard_test.gd`(协作 NPC Story 008 + Event Script Story 006)

## Dependencies

- Depends on: Story 003 + NPC Story 008 + Event Script Story 006
- Unlocks: 全 farewell event 链

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 5 test 函数
**Test Evidence**: `tests/integration/card/farewell_lifecycle_guard_test.gd` (147 行 / 5 tests / GdUnit4) — 覆盖 LISA ACTIVE+farewell→DISABLED / LEAVING_ANNOUNCED+farewell→PLAYABLE+success+AP 扣 / LEFT+farewell→DISABLED / 普通卡默认仅 ACTIVE 允许 / Card.validate() 强制 farewell+lifecycle=[LEAVING_ANNOUNCED] — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);lifecycle_allowed 数组守门顺序在 evaluate_state Step 1 (NPC 早于 AP),farewell_event=true 时 validate() 拒绝错配;numeric_only 由 ADR-0009 farewell_lint.py 既有维护;无 BLOCKING / 无 inline fix
**Deviations** (无)
**Tech debt**: None new
**API surface**: `Card.lifecycle_allowed: Array[StringName]` + `Card.validate()` ERR_CARD_FAREWELL_LIFE + CardPlaySystem._resolve_lifecycle 调 NPC.get_lifecycle_state
