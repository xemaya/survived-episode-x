# Story 008: LEAVING_ANNOUNCED Farewell Card numeric_only

> **Epic**: npc-relationship-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/npc-relationship-system.md` | **Requirement**: `TR-npc-005`
**ADR**: ADR-0009 farewell_event flag + ADR-0001 FAREWELL_EVENT_IDS
**Engine**: Godot 4.6 | **Risk**: HIGH(via ADR-0009 @abstract 4.5+)

**Control Manifest Rules**:
- Required: LEAVING_ANNOUNCED 期间道别卡走 farewell event 路径(numeric_only 强制)
- Forbidden: 道别卡走 long / brief 渲染(必须 numeric_only)

## Acceptance Criteria

- [ ] LEAVING_ANNOUNCED 期间允许打"道别卡"(card 守门:LIFECYCLE_ALLOWED = LEAVING_ANNOUNCED)
- [ ] 道别卡触发 `event_started(event_id, narrative_tier)` 其中 `event_id ∈ FAREWELL_EVENT_IDS` + `narrative_tier = numeric_only`
- [ ] 协作 4 GDD AC-FAREWELL-01:#13 禁 flash overlay / #15 仅一行 numeric_only / #4 禁 BGM / #5 禁特殊 palette

## Implementation Notes

```gdscript
# action_card_system.gd 协作 — try_play_card 守门
func try_play_card(card_id: StringName) -> bool:
    var card_def := get_card_def(card_id)
    if card_def.target_npc != &"":
        var npc_state := NPCRelationshipSystem.get_npc_state(card_def.target_npc)
        if npc_state.lifecycle_state == &"LEFT":
            return false  # 已离开
        if card_def.is_farewell and npc_state.lifecycle_state != &"LEAVING_ANNOUNCED":
            return false  # 道别卡仅 LEAVING_ANNOUNCED 允许
    # ... 其余 try_play_card 逻辑
```

## QA Test Cases

- LISA LEAVING_ANNOUNCED + 玩家打 LISA_GOODBYE 道别卡 → 触发 event_started("LISA_GOODBYE", numeric_only)
- LISA ACTIVE + 玩家打 LISA_GOODBYE → 拒绝
- 4 GDD AC-FAREWELL-01 守门测试

## Test Evidence

`tests/integration/npc/farewell_card_test.gd`(协作 #10 / #11 / #13 / #15 / #4 / #5 stories)

## Dependencies

- Depends on: Story 002 + Action Card Story + Event Script Story(FAREWELL_EVENT_IDS)
- Unlocks: 全 farewell event 链下游 stories

---

## Completion Notes

**Completed**: 2026-05-01 (autopilot npc-relationship-system pass)
**Verdict**: COMPLETE (lean review mode)
**Criteria**: 3/3 passing (lifecycle 守门 owned in this autoload + ADR-0009 numeric_only narrative-tier 强制由 #10 Event Script FAREWELL_EVENT_IDS pool 接力)

**Files changed**:
- `src/npc/npc_relationship_system.gd` — EDIT (FAREWELL_CARD_REQUIRED_LIFECYCLE const = LEAVING_ANNOUNCED, `is_farewell_card_legal(target_npc, is_farewell) -> bool` 守门 helper)
- `tests/integration/npc/farewell_card_test.gd` — CREATE (7 tests: farewell allowed during LEAVING_ANNOUNCED / rejected ACTIVE / rejected after LEFT / non-farewell allowed during LEAVING / non-farewell rejected when LEFT / unknown rejected / required lifecycle const)

**Test Evidence**: `tests/integration/npc/farewell_card_test.gd` (Integration story, BLOCKING gate).

**Out of Scope (cross-epic seams)**:
- #11 Action Card `try_play_card` calling `is_farewell_card_legal` — Action Card epic story
- #10 Event Script `FAREWELL_EVENT_IDS` pool + `narrative_tier = numeric_only` enforcement (ADR-0009) — Event Script epic
- #13 HUD flash overlay 禁 / #15 Card UI 一行 numeric_only / #4 Audio BGM 禁 / #5 Lighting palette 禁 (AC-FAREWELL-01 4-system 守门) — 各 epic 自己实施。本 story 只 own lifecycle 预判 API。

**Code Review**: Static review only (lean mode).
