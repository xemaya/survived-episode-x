# Story 003: Card 4-State Machine

> **Epic**: action-card-system | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/action-card-system.md` | **Requirement**: `TR-card-003`
**ADR**: GDD 4 态状态机
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 4 态(IDLE / PLAYABLE / DISABLED / PLAYED)+ 转移合法性

## Acceptance Criteria

- [ ] enum `CardState { IDLE, PLAYABLE, DISABLED, PLAYED }`
- [ ] `_evaluate_state(card_id) -> CardState`:基于 NPC lifecycle / cooldown / mutex / AP 不足等判定
- [ ] 转移合法性自动化测试

## Implementation Notes

```gdscript
enum CardState { IDLE, PLAYABLE, DISABLED, PLAYED }

func _evaluate_state(card: Card, npc_state: NpcState) -> CardState:
    if card.target_npc_required and npc_state.lifecycle_state == &"LEFT":
        return CardState.DISABLED
    if APEconomy.current_ap < card.ap_cost:
        return CardState.DISABLED
    if _cooldown_active(card.event_id):
        return CardState.DISABLED
    if _mutex_locked(card.mutex_group):
        return CardState.DISABLED
    return CardState.PLAYABLE
```

## QA Test Cases

- 4 态各自触发条件
- 转移合法性

## Test Evidence

`tests/unit/card/state_machine_test.gd`

## Dependencies

- Depends on: Story 001 + AP Story 001 + NPC Story 002
- Unlocks: Story 005(try_play_card)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 9 test 函数
**Test Evidence**: `tests/unit/card/state_machine_test.gd` (185 行 / 9 tests / GdUnit4) — 覆盖 4 态枚举顺序 / IDLE / PLAYABLE 默认 / DISABLED (AP/NPC LEFT/hero capped/npc required) / PLAYED (mutex) / cooldown — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);CardPlaySystem.evaluate_state 守门顺序固定 (NPC lifecycle → AP → cooldown → mutex → hero),graceful degradation 当 AP/NPC 未注入;无 BLOCKING / 无 inline fix
**Deviations** (无)
**Tech debt**: None new
**API surface**: `CardPlaySystem.CardState {IDLE/PLAYABLE/DISABLED/PLAYED}` enum + `evaluate_state(card: Card) -> int`
