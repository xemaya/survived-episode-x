# Story 004: RelationshipPhase 5-Tier + relationship_phase_changed Signal

> **Epic**: npc-relationship-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/npc-relationship-system.md` | **Requirement**: `TR-npc-003`
**ADR**: GDD Rule 3 RelationshipPhase
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 5 阶 phase(HOSTILE / COLD / NEUTRAL / WARM / FRIENDLY)+ 阈值 [-100, -50, -10, 10, 50, 100]
- Required: `relationship_phase_changed` signal 仅在跨阶时 emit(同阶 score 变化不发)

## Acceptance Criteria

- [ ] enum `RelationshipPhase { HOSTILE, COLD, NEUTRAL, WARM, FRIENDLY }`
- [ ] 阈值 const:HOSTILE [-100,-50] / COLD [-50,-10] / NEUTRAL [-10,10] / WARM [10,50] / FRIENDLY [50,100]
- [ ] `_get_phase(score)` API
- [ ] update_relationship 触发 `relationship_phase_changed(npc, old_phase, new_phase)` 仅跨阶时

## Implementation Notes

```gdscript
enum RelationshipPhase { HOSTILE, COLD, NEUTRAL, WARM, FRIENDLY }
const PHASE_THRESHOLDS := [-50, -10, 10, 50]

signal relationship_phase_changed(npc: StringName, old: RelationshipPhase, new: RelationshipPhase)

func _get_phase(score: int) -> RelationshipPhase:
    if score < PHASE_THRESHOLDS[0]: return RelationshipPhase.HOSTILE
    if score < PHASE_THRESHOLDS[1]: return RelationshipPhase.COLD
    if score < PHASE_THRESHOLDS[2]: return RelationshipPhase.NEUTRAL
    if score < PHASE_THRESHOLDS[3]: return RelationshipPhase.WARM
    return RelationshipPhase.FRIENDLY
```

## QA Test Cases

- score = -49 → HOSTILE → score = -49 → 同阶不 emit;score = -50 → COLD 跨阶 emit
- 5 阶完整覆盖

## Test Evidence

`tests/unit/npc/relationship_phase_test.gd`

## Dependencies

- Depends on: Story 001
- Unlocks: Story 005(update_relationship)

---

## Completion Notes

**Completed**: 2026-05-01 (autopilot npc-relationship-system pass)
**Verdict**: COMPLETE (lean review mode)
**Criteria**: 4/4 passing

**Files changed**:
- `src/npc/npc_relationship_system.gd` — EDIT (RelationshipPhase enum 5 tiers, PHASE_THRESHOLDS const [-50, -10, 10, 50], `get_phase(score) -> int`, `signal relationship_phase_changed(npc, old_phase, new_phase)`)
- `tests/unit/npc/relationship_phase_test.gd` — CREATE (6 tests: enum order / boundary classification / get_phase / same-tier no-emit / cross-tier emit / multi-tier jump emits once)

**Test Evidence**: `tests/unit/npc/relationship_phase_test.gd` (Logic story, BLOCKING gate).

**Code Review**: Static review only (lean mode).
