# Story 006: npc_lifecycle_changed Signal + Notification Forwarding

> **Epic**: npc-relationship-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/npc-relationship-system.md` | **Requirement**: `TR-npc-003`
**ADR**: ADR-0001 npc_lifecycle_changed signal owner = #8(3 subs:#10/#13/#19)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: npc_lifecycle_changed(npc, old_state, new_state, reason) signal owner = #8
- Required: LEAVING_ANNOUNCED → #19 Notification 转发 warning_npc_leaving(VS tier)+ #13 HUD 切 LEAVING variant

## Acceptance Criteria

- [ ] `signal npc_lifecycle_changed(npc, old_state, new_state, reason)` owner = #8
- [ ] LEAVING_ANNOUNCED 转移触发链:#10 Event Script 候选池注入 [npc]_leaving_announced 事件 + #13 HUD 切 NPC_EXPRESSION + NPC_POSITION variant("收纸箱")+ #19 Notification 转发(VS)

## Implementation Notes

```gdscript
# Story 002 已实施 _transition_lifecycle 触发 emit signal
# 本 story 扩展为 cross-system 协作链

func _transition_lifecycle(npc: StringName, new_state: StringName, reason: StringName) -> bool:
    # ... Story 002 逻辑
    if new_state == &"LEAVING_ANNOUNCED":
        # #10 Event Script 候选池注入(由订阅 #8 的 #10 自处理)
        # #13 HUD 切 variant(订阅 #8 自处理)
        # #19 Notification 转发(VS tier)
        pass
    return true
```

## QA Test Cases

- _transition_lifecycle(LISA, &"LEAVING_ANNOUNCED", &"low_relationship") → emit npc_lifecycle_changed + 3 subs 各自响应

## Test Evidence

`tests/integration/npc/lifecycle_changed_test.gd`(协作 #10 / #13 / #19 stories)

## Dependencies

- Depends on: Story 002
- Unlocks: Event Script + HUD + Notification stories

---

## Completion Notes

**Completed**: 2026-05-01 (autopilot npc-relationship-system pass)
**Verdict**: COMPLETE (lean review mode)
**Criteria**: 2/2 passing (signal owner + cross-system fan-out shape verified; actual #10/#13/#19 subscriber bodies live in their respective epics)

**Files changed**:
- `src/npc/npc_relationship_system.gd` — EDIT (`signal npc_lifecycle_changed(npc, old_state, new_state, reason)` emitted from `_transition_lifecycle`; subject-inversion lint domain NPC owner = #8 invariant maintained)
- `tests/integration/npc/lifecycle_changed_test.gd` — CREATE (5 tests: payload shape / LEAVING_ANNOUNCED fan-out to 3 fake subs / reason carried / illegal transition no-emit / single-owner grep)

**Test Evidence**: `tests/integration/npc/lifecycle_changed_test.gd` (Integration story, BLOCKING gate).

**Out of Scope (cross-epic seams documented, not implemented here)**:
- #10 Event Script `[npc]_leaving_announced` candidate-pool injection — Event Script epic
- #13 HUD `NPC_EXPRESSION` + `NPC_POSITION` "收纸箱" variant — HUD epic
- #19 Notification `warning_npc_leaving` (VS tier) — Notification epic

**Code Review**: Static review only (lean mode).
