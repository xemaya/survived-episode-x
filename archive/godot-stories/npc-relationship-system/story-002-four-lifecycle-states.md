# Story 002: 4 Lifecycle State Machine

> **Epic**: npc-relationship-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/npc-relationship-system.md` | **Requirement**: `TR-npc-001`
**ADR**: GDD Rule 7 NpcLifecycleState
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 4 态(ACTIVE / LEAVING_ANNOUNCED / LEFT / RETURNED)+ 转移合法性

## Acceptance Criteria

- [ ] enum `NpcLifecycleState { ACTIVE, LEAVING_ANNOUNCED, LEFT, RETURNED }`
- [ ] 转移合法性:ACTIVE → LEAVING_ANNOUNCED → LEFT;LEFT → RETURNED(VS tier 推迟)
- [ ] `transition_lifecycle(npc, new_state, reason)` 私有 API + 守门

## Implementation Notes

```gdscript
const LIFECYCLE_TRANSITIONS := {
    &"ACTIVE": [&"LEAVING_ANNOUNCED"],
    &"LEAVING_ANNOUNCED": [&"LEFT", &"ACTIVE"],  # ACTIVE 是补救路径(玩家挽留)
    &"LEFT": [&"RETURNED"],  # VS tier
    &"RETURNED": [&"LEFT"],
}

func _transition_lifecycle(npc: StringName, new_state: StringName, reason: StringName) -> bool:
    var state := _states[npc]
    if new_state not in LIFECYCLE_TRANSITIONS.get(state.lifecycle_state, []):
        push_error("Illegal lifecycle: %s %s → %s" % [npc, state.lifecycle_state, new_state])
        return false
    var old := state.lifecycle_state
    state.lifecycle_state = new_state
    emit_signal(&"npc_lifecycle_changed", npc, old, new_state, reason)
    return true
```

## QA Test Cases

- ACTIVE → LEAVING_ANNOUNCED 合法;ACTIVE → LEFT 直接非法
- LEAVING_ANNOUNCED → ACTIVE 补救路径合法

## Test Evidence

`tests/unit/npc/lifecycle_state_test.gd`

## Dependencies

- Depends on: Story 001
- Unlocks: Story 005-007(signals)

---

## Completion Notes

**Completed**: 2026-05-01 (autopilot npc-relationship-system pass)
**Verdict**: COMPLETE (lean review mode)
**Criteria**: 3/3 passing

**Files changed**:
- `src/npc/npc_relationship_system.gd` — EDIT (LIFECYCLE_TRANSITIONS const Dictionary, public `transition_lifecycle(npc, new_state, reason) -> bool`, private `_transition_lifecycle` 守门 + push_error on illegal)
- `tests/unit/npc/lifecycle_state_test.gd` — CREATE (7 tests: 4 keys / ACTIVE→LEAVING legal / ACTIVE→LEFT illegal / retention path / signal payload / illegal returns false / VS RETURNED path)

**Test Evidence**: `tests/unit/npc/lifecycle_state_test.gd` (Logic story, BLOCKING gate).

**Out of Scope**:
- Cross-system fan-out (HUD / Event Script / Notif) is on Story 006 — this story only owns the lifecycle table + signal emit.

**Code Review**: Static review only (lean mode).
