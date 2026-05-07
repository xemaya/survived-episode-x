# Story 001: AP 4-State Machine + try_consume_ap

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-001`
**ADR**: ADR-0001(ap_changed / ap_consumed signal)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: AP 4 态(NORMAL / OVERTIME_AVAILABLE / OVERTIME_ACTIVE / DEPLETED)+ ap_changed signal
- Forbidden: AP cost 反向调高(Anti-P1 红线 PR-blocking)

## Acceptance Criteria

- [ ] enum `APState { AP_NORMAL, AP_OVERTIME_AVAILABLE, AP_OVERTIME_ACTIVE, AP_DEPLETED }`
- [ ] state vars:`current_ap: int / max_ap_today: int / current_energy: int`
- [ ] `try_consume_ap(amount: int) -> bool` API:守门 amount > 0 + current_ap >= amount → 扣减 + emit ap_consumed + ap_changed + return true;失败返 false
- [ ] state transitions:current_ap == 0 → DEPLETED;OVERTIME 开启时 → OVERTIME_AVAILABLE;OVERTIME 使用中 → OVERTIME_ACTIVE

## Implementation Notes

```gdscript
enum APState { AP_NORMAL, AP_OVERTIME_AVAILABLE, AP_OVERTIME_ACTIVE, AP_DEPLETED }
var current_ap: int = 8
var max_ap_today: int = 8
var current_energy: int = 100
var _state: APState = APState.AP_NORMAL

signal ap_changed(current: int, max: int)
signal ap_consumed(amount: int)
signal ap_depleted

func try_consume_ap(amount: int) -> bool:
    if amount <= 0 or current_ap < amount:
        return false
    current_ap -= amount
    emit_signal(&"ap_consumed", amount)
    emit_signal(&"ap_changed", current_ap, max_ap_today)
    if current_ap == 0:
        _state = APState.AP_DEPLETED
        emit_signal(&"ap_depleted")
    return true
```

## QA Test Cases

- 8 AP → try_consume(1) × 8 → 0 AP + DEPLETED;消耗 9 → false
- ap_consumed signal × 8 emit + 1 次 ap_depleted

## Test Evidence

`tests/unit/ap/state_machine_test.gd`

## Dependencies

- Depends on: None
- Unlocks: 全 AP stories

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 7 test 函数 (`tests/unit/ap/state_machine_test.gd`)
**Test Evidence**: `tests/unit/ap/state_machine_test.gd` (~135 行 / 7 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);AP 4-state enum literal-locked + try_consume_ap 三段守门 (locked / amount<=0 / overdraw) + ap_consumed→ap_changed 同帧时序 + AP_DEPLETED 自动转移 + reset_day 日初恢复; 无 BLOCKING/无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. APEconomySystem 实例化为 Node (RefCounted 不行,signal owner 必须是 Node);autoload 注册延后 (story 不要求 — 当前可由 SceneDayFlowController 实例化或 Card scene attach)
**Tech debt**: None new
**API surface**: `class_name APEconomySystem` + enum APState{4} + signal ap_changed/ap_consumed/ap_depleted + property current_ap/max_ap_today/current_energy/state + try_consume_ap()/reset_day()
