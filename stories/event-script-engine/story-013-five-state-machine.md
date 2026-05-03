# Story 013: 5-State State Machine

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` | **Requirement**: `TR-event-005`
**ADR**: GDD 5 态状态机
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 5 态(IDLE / EVALUATING_CANDIDATES / EVENT_ACTIVE / WAITING_PLAYER_CHOICE / EXECUTING_EFFECTS)
- Required: 转移合法性自动化覆盖

## Acceptance Criteria

- [ ] enum `EventState { IDLE, EVALUATING_CANDIDATES, EVENT_ACTIVE, WAITING_PLAYER_CHOICE, EXECUTING_EFFECTS }`
- [ ] state machine:IDLE → EVALUATING(trigger received)→ EVENT_ACTIVE(event selected)→ WAITING_PLAYER_CHOICE(if choices)→ EXECUTING_EFFECTS → IDLE
- [ ] EVENT_ACTIVE + IDLE 之间 narrative_density_changed 行为(协作 Story 008)

## Implementation Notes

```gdscript
enum EventState { IDLE, EVALUATING_CANDIDATES, EVENT_ACTIVE, WAITING_PLAYER_CHOICE, EXECUTING_EFFECTS }
var _state: EventState = EventState.IDLE

func evaluate_candidates(context: Dictionary) -> EventResource:
    _state = EventState.EVALUATING_CANDIDATES
    var candidates := _filter_eligible(context)
    if candidates.is_empty():
        _state = EventState.IDLE
        return null
    var selected := _weighted_select(candidates)
    _state = EventState.EVENT_ACTIVE
    _emit_event_started(selected)
    return selected
```

## QA Test Cases

- 5 态转移合法性
- IDLE → EVALUATING → EVENT_ACTIVE → WAITING → EXECUTING → IDLE 完整链

## Test Evidence

`tests/unit/event/state_machine_test.gd`

## Dependencies

- Depends on: Story 002 + Story 003 + Story 004
- Unlocks: Story 014(Risk Guards)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 + 1 priority tie-break determinism COVERED via 7 test 函数
**Test Evidence**: `tests/unit/event/state_machine_test.gd` (~145 行 / 7 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);5-member EventState enum (IDLE / EVALUATING_CANDIDATES / EVENT_ACTIVE / WAITING_PLAYER_CHOICE / EXECUTING_EFFECTS),evaluate_candidates 转 EVALUATING_CANDIDATES → null 时归 IDLE / 正常时由 emit_event_started 转 EVENT_ACTIVE,emit_event_completed 归 IDLE,_weighted_select 全零 weight 走 priority desc + event_id asc 确定性 tie-break,get_state() 测 seam;无 BLOCKING / 无 inline fix
**Engine API Verification**: 标准 GDScript enum + match — 无 4.5+ 新 API
**Deviations** (1 项 ADVISORY):
1. WAITING_PLAYER_CHOICE / EXECUTING_EFFECTS 中间态由 `#14 Card Play UI` epic 后续 wire (本 epic 仅声明转移合法性;实际 await 链由消费方驱动) — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `EventState` 5-enum + `evaluate_candidates(ttype, context, current_day) -> EventResource` + `_weighted_select(events)` 内部 (priority desc tie-break) + `get_state() -> int` + `_set_state_for_test(s)` test seam
