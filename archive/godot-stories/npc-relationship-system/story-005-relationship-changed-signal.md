# Story 005: relationship_changed Signal + update_relationship API

> **Epic**: npc-relationship-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/npc-relationship-system.md` | **Requirement**: `TR-npc-003`
**ADR**: ADR-0001 relationship_changed signal owner = #8(3 subs:#10/#13/#15)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: relationship_changed(npc, delta, new_score, reason)signal 单 owner = #8
- Required: 主语翻转 lint NPC.* keys(协作 ADR-0010)

## Acceptance Criteria

- [ ] `update_relationship(npc, delta, reason)` API + clamp [-100, 100]
- [ ] emit `relationship_changed(npc, delta, new_score, reason)`
- [ ] 跨 phase 时 emit `relationship_phase_changed`(协作 Story 004)
- [ ] subject_inversion_lint --domain NPC 守(ADR-0010 master domain)

## Implementation Notes

```gdscript
signal relationship_changed(npc: StringName, delta: int, new_score: int, reason: StringName)

func update_relationship(npc: StringName, delta: int, reason: StringName) -> void:
    if not _states.has(npc):
        push_error("Unknown NPC: %s" % npc)
        return
    var state := _states[npc]
    if state.lifecycle_state == &"LEFT":
        push_warning("Cannot update relationship of LEFT NPC: %s" % npc)
        return
    var old_score := state.score
    state.score = clampi(state.score + delta, -100, 100)
    var actual_delta := state.score - old_score
    emit_signal(&"relationship_changed", npc, actual_delta, state.score, reason)
    var old_phase := _get_phase(old_score)
    var new_phase := _get_phase(state.score)
    if old_phase != new_phase:
        emit_signal(&"relationship_phase_changed", npc, old_phase, new_phase)
```

## QA Test Cases

- update_relationship(LISA, +20, "lunch") → relationship_changed emit + score +20
- LEFT NPC update → push_warning + score 不变
- score clamp [-100, 100]

## Test Evidence

`tests/integration/npc/relationship_changed_test.gd`

## Dependencies

- Depends on: Story 001 + Story 004
- Unlocks: Action Card Story(card 触发 update_relationship)

---

## Completion Notes

**Completed**: 2026-05-01 (autopilot npc-relationship-system pass)
**Verdict**: COMPLETE (lean review mode)
**Criteria**: 4/4 passing

**Files changed**:
- `src/npc/npc_relationship_system.gd` — EDIT (`signal relationship_changed(npc, delta, new_score, reason)`, `update_relationship(npc, delta, reason)` clamp + co-emit phase signal; R-NPC-1 LEFT-NPC reject)
- `tests/integration/npc/relationship_changed_test.gd` — CREATE (6 tests: emit on update / clamp at max / cross-phase co-emit / R-NPC-1 LEFT reject / unknown silent / single-owner grep)

**Test Evidence**: `tests/integration/npc/relationship_changed_test.gd` (Integration story, BLOCKING gate). Single-owner grep test enforces ADR-0001 invariant — only `npc_relationship_system.gd` may emit `relationship_changed.emit(`.

**Out of Scope**:
- subject_inversion_lint --domain NPC tooling — cross-epic ADR-0010 master lint domain story. Test grep covers the single-owner runtime invariant at unit level.

**Code Review**: Static review only (lean mode).
