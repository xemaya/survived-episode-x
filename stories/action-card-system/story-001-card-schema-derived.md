# Story 001: Card Schema (Derived from EventResource)

> **Epic**: action-card-system | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/action-card-system.md` | **Requirement**: `TR-card-001`
**ADR**: ADR-0009(Card schema 派生 EventResource 子集)
**Engine**: Godot 4.6 | **Risk**: HIGH(via @abstract 4.5+)

**Control Manifest Rules**:
- Required: Card extends EventResource(简化字段)+ EventTrigger.type = CARD

## Acceptance Criteria

- [ ] `class_name Card extends EventResource`(派生)+ `@export var ap_cost: int / target_npc: StringName / target_npc_required: bool / is_hero: bool / mutex_group: StringName / lifecycle_allowed: Array[StringName] = [&"ACTIVE"]`
- [ ] `data/cards/[card_id].tres` × 80-120 cards MVP / 400+ 完整版
- [ ] `Card.trigger.type = EventTrigger.TriggerType.CARD`(派生 trigger)

## Implementation Notes

```gdscript
class_name Card extends EventResource
@export var ap_cost: int = 1  # 1/2/3 分布
@export var target_npc: StringName  # 空表示无 NPC 目标
@export var target_npc_required: bool = false
@export var is_hero: bool = false
@export var mutex_group: StringName  # 互斥分组
@export var lifecycle_allowed: Array[StringName] = [&"ACTIVE"]  # 道别卡可设 [LEAVING_ANNOUNCED]
```

## QA Test Cases

- 80 cards .tres 完整加载
- Card schema 字段覆盖

## Test Evidence

`tests/unit/card/card_schema_test.gd`

## Dependencies

- Depends on: Event Script Story 001 + 002
- Unlocks: 全 Card stories

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 11 test 函数
**Test Evidence**: `tests/unit/card/card_schema_test.gd` (260 行 / 11 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);Card 派生 EventResource (extends + 6 @export overlay + factory + validate);CardLoader 镜像 EventLoader 模式;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. ADR-0009 Status=Proposed — lean-mode-equivalent (派生模式与 ADR 一致)
**Tech debt**: None new
**API surface**: `class_name Card extends EventResource` + @export {ap_cost / target_npc / target_npc_required / is_hero / mutex_group / lifecycle_allowed / kpi_delta / relationship_delta} + `Card.make_minimal(id, cost, hero, mutex)` + `Card.validate() -> Array[String]` + `class_name CardLoader.load_all(root) -> Array[Card]`
