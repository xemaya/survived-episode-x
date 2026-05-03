# Story 002: EventTrigger Resource + 7 TriggerType

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` | **Requirement**: `TR-event-001`
**ADR**: ADR-0009 EventTrigger Resource + 7 TriggerType enum
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 7 TriggerType:CARD / NPC_RELATIONSHIP / KPI_THRESHOLD / MONTH_END / DAY_START / FLAG / COOLDOWN

## Acceptance Criteria

- [ ] `EventTrigger extends Resource` + `enum TriggerType { CARD, NPC_RELATIONSHIP, KPI_THRESHOLD, MONTH_END, DAY_START, FLAG, COOLDOWN }`
- [ ] `_evaluate_trigger(trigger: EventTrigger, context: Dictionary) -> bool` API
- [ ] 7 类 trigger 各自 evaluator(card_id / npc_id + threshold_op + threshold_value / flag_name / month_index)

## Implementation Notes

```gdscript
class_name EventTrigger extends Resource
enum TriggerType { CARD, NPC_RELATIONSHIP, KPI_THRESHOLD, MONTH_END, DAY_START, FLAG, COOLDOWN }
@export var type: TriggerType
@export var card_id: StringName
@export var npc_id: StringName
@export var threshold_op: String  # ">=", "<=", "=="
@export var threshold_value: int
@export var flag_name: StringName
@export var month_index: int = -1

func evaluate(context: Dictionary) -> bool:
    match type:
        TriggerType.CARD: return context.card_id == card_id
        TriggerType.NPC_RELATIONSHIP: return _eval_op(context.npc_score, threshold_op, threshold_value)
        TriggerType.KPI_THRESHOLD: return _eval_op(context.kpi_actual, threshold_op, threshold_value)
        TriggerType.MONTH_END: return context.is_month_end and (month_index == -1 or context.month == month_index)
        TriggerType.FLAG: return context.flag_dict.get(flag_name, false)
        # ...
    return false
```

## QA Test Cases

- 7 TriggerType 各自 evaluator 输入/输出表

## Test Evidence

`tests/unit/event/event_trigger_test.gd`

## Dependencies

- Depends on: Story 001
- Unlocks: Story 004(三层索引)+ Story 013(状态机)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 11 test 函数
**Test Evidence**: `tests/unit/event/event_trigger_test.gd` (~165 行 / 11 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);7 TriggerType enum 顺序锁定,evaluate() 纯函数,context 缺 key 防御性返回 false (除 CARD 双 empty 等价情况),6 操作符 (>=/<=/==/!=/>/<);无 BLOCKING / 无 inline fix
**Engine API Verification**: Standard GDScript match + Dictionary.get(default) — 无 4.5+ 新 API
**Deviations** (1 项 ADVISORY):
1. ADR-0009 Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `EventTrigger` Resource + `TriggerType` 7-enum + `evaluate(context: Dictionary) -> bool`
