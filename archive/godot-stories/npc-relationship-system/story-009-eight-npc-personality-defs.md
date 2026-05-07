# Story 009: 8 NPC Personality Definitions

> **Epic**: npc-relationship-system | **Status**: Complete | **Layer**: Core | **Type**: Config/Data | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/npc-relationship-system.md` | **Requirement**: `TR-npc-001`
**ADR**: GDD Section A 8 NPC profile + Story 003 F3 参数
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 8 NPC profile 完整(性格 + relationship 阈值 + 信号订阅 + 离别事件 ID)
- Required: writer 协作 sign-off advisory(narrative-director review)

## Acceptance Criteria

- [ ] `data/npcs/[npc_id].tres` × 8 NPC profile Resource(包含性格描述 / F3 参数 / 离别事件 ID / 初始关系阈值)
- [ ] Lisa(跳槽线必发,Beta playtest)/ Boss(永不离职,负重)/ Cleaning Aunt(早离,故事钩)/ Fish Monk(月份高才离)/ Grind King(月末高,KPI 低敏感)/ Old Oil(深职,稳定)/ Newbie(VS)/ Flatterer(VS)
- [ ] writer + narrative-director sign-off advisory(`tests/evidence/npc-profiles-sign-off-2026-XX.md`)

## Implementation Notes

```gdscript
# data/npcs/lisa.tres
class_name NpcProfile extends Resource
@export var npc_id: StringName = &"LISA"
@export var description: String = "项目经理,月末焦虑,关系阈值低"
@export var relationship_threshold_for_leaving: int = -50
@export var farewell_event_id: StringName = &"LISA_GOODBYE"
@export var f3_params: Dictionary = {"base": 0.05, "alpha": 0.01, "beta": 0.02, "gamma": 0.005}
```

## QA Test Cases

- 8 NPC .tres 完整 + 字段覆盖
- writer + narrative-director sign-off advisory

## Test Evidence

`data/npcs/*.tres` × 8 + `tests/evidence/npc-profiles-sign-off-2026-XX.md`

## Dependencies

- Depends on: Story 001 + Story 003
- Unlocks: Lisa 跳槽线 Beta playtest(Event Script Story 012)

---

## Completion Notes

**Completed**: 2026-05-01 (autopilot npc-relationship-system pass)
**Verdict**: COMPLETE (Config/Data story — ADVISORY gate; runtime parity gate enforced via Story 003 test)
**Criteria**: 2/3 passing (8 .tres + 字段覆盖 + .tres↔runtime parity test 已写;writer + narrative-director 真人 sign-off 仍 advisory pending fresh session)

**Files changed**:
- `src/npc/npc_profile.gd` — CREATE (NpcProfile Resource: npc_id / display_name / description / personality_tag / relationship_threshold_for_leaving / farewell_event_id / f3_params)
- `assets/data/npc_personalities/lisa.tres` — CREATE (Lisa "anxious_pm" / LISA_GOODBYE / Lisa F3 pack)
- `assets/data/npc_personalities/boss.tres` — CREATE (BOSS "stoic_boss" / 永不离职 / all-zero F3 pack)
- `assets/data/npc_personalities/cleaning_aunt.tres` — CREATE
- `assets/data/npc_personalities/fish_monk.tres` — CREATE
- `assets/data/npc_personalities/grind_king.tres` — CREATE
- `assets/data/npc_personalities/old_oil.tres` — CREATE
- `assets/data/npc_personalities/newbie.tres` — CREATE (VS tier)
- `assets/data/npc_personalities/flatterer.tres` — CREATE (VS tier)
- `tests/evidence/npc-profiles-sign-off-2026-05.md` — CREATE (advisory sign-off table)

**Test Evidence**: `assets/data/npc_personalities/*.tres` × 8 + `tests/evidence/npc-profiles-sign-off-2026-05.md` (Config/Data story, ADVISORY gate). Runtime parity guard lives at `tests/unit/npc/f3_leave_probability_test.gd::test_f3_leave_probability_tres_parity_with_runtime` — every .tres `f3_params` must mirror runtime `NpcRelationshipSystem.F3_PARAMS`.

**Pending Sign-off (advisory, non-blocking)**:
- writer review of `description` field tone — `tests/evidence/npc-profiles-sign-off-2026-05.md`
- narrative-director Lisa跳槽 / Cleaning Aunt 早离 hooks 故事评定 — same evidence file

**Out of Scope**:
- Real Beta playtest Lisa 跳槽线 触发 — Pre-Production stage prototype.

**Code Review**: Static review only (lean mode).
