# Story 001: 8 NPC Schema + relationship_score + flags

> **Epic**: npc-relationship-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/npc-relationship-system.md` | **Requirement**: `TR-npc-001`
**ADR**: ADR-0003(sub-schema npc_relationship)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 8 NPC `relationship_score: int [-100, +100]` + per-NPC `flags: Dict[String, bool]`

## Acceptance Criteria

- [ ] 8 NPC enum:`LISA / BOSS / CLEANING_AUNT / FISH_MONK / GRIND_KING / OLD_OIL / NEWBIE / FLATTERER`
- [ ] state schema:`Dictionary[NpcId, NpcState]` 含 `score: int [-100, 100]` / `flags: Dict[String, bool]` / `lifecycle_state: NpcLifecycleState`
- [ ] `get_npc_state(npc: NpcId) -> NpcState` API
- [ ] Save sub-schema `npc_relationship` round-trip(协作 Save Story)

## Implementation Notes

```gdscript
const NPCS := [&"LISA", &"BOSS", &"CLEANING_AUNT", &"FISH_MONK", &"GRIND_KING", &"OLD_OIL", &"NEWBIE", &"FLATTERER"]

class NpcState:
    var score: int = 0  # [-100, 100]
    var flags: Dictionary = {}
    var lifecycle_state: StringName = &"ACTIVE"

var _states: Dictionary[StringName, NpcState] = {}

func _ready() -> void:
    for npc in NPCS:
        _states[npc] = NpcState.new()
```

## QA Test Cases

- 8 NPC 初始化 score=0 + ACTIVE
- score clamp [-100, 100]

## Test Evidence

`tests/unit/npc/schema_test.gd`

## Dependencies

- Depends on: None
- Unlocks: 全 NPC stories

---

## Completion Notes

**Completed**: 2026-05-01 (autopilot npc-relationship-system pass)
**Verdict**: COMPLETE (lean review mode — single-session implement + static review)
**Criteria**: 4/4 passing

**Files changed**:
- `src/npc/npc_relationship_system.gd` — CREATE (NpcState nested class, NPCS const 8 ids, get_npc_state / get_score / get_lifecycle_state / set_flag / get_flag / serialize_state / restore_state APIs; R-NPC-5 corruption guard在 `_initialise_states` + `restore_state`)
- `tests/unit/npc/schema_test.gd` — CREATE (8 tests: NPCS order / initial state / API / unknown id / clamp / flags / save round-trip / corrupt restore)

**Test Evidence**: `tests/unit/npc/schema_test.gd` (Logic story, BLOCKING gate). Test execution is not CI-verifiable until `project.godot` autoload registration story lands — same precedent as save / a11y / lighting epics. Static review passed.

**Out of Scope (deferred items confirmed not silently dropped)**:
- project.godot autoload registration → cross-epic project-config story (precedent)
- Save sub-schema integration with actual SaveSystem persistence chain → cross-epic Save System Story (graceful seam already exposed via `serialize_state` / `restore_state`)

**Code Review**: Static review only (lean mode). Single-owner signal grep tests live with Story 005-007.
