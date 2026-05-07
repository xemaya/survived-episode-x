# Story 002: F1 Overtime Formula + try_overtime

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-007`
**ADR**: GDD F1 加班公式 + Anti-P1 红线
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 加班代价 — F1(`current_energy`)→ AP +N + energy -M
- Forbidden: F1 输出反向(加班无代价)— Anti-P1 红线

## Acceptance Criteria

- [ ] `try_overtime() -> bool` API:守门 current_energy > 0 + transition AP_OVERTIME_AVAILABLE → AP_OVERTIME_ACTIVE
- [ ] F1 公式实施(GDD Section D F1):AP 增量 = clamp((current_energy / 100) × 4, 1, 4);energy 扣减 = AP 增量 × 25
- [ ] emit `effort_overtime_incremented(day, total)` + ap_changed + energy_changed

## Implementation Notes

```gdscript
signal effort_overtime_incremented(day: int, total: int)
signal energy_changed(current: int, max: int)

const F1_OVERTIME_AP_MAX := 4
const F1_OVERTIME_ENERGY_COST_PER_AP := 25

var overtime_used_this_month: int = 0

func try_overtime() -> bool:
    if current_energy <= 0:
        return false
    var ap_gain: int = clampi(int(float(current_energy) / 100.0 * F1_OVERTIME_AP_MAX), 1, F1_OVERTIME_AP_MAX)
    var energy_cost := ap_gain * F1_OVERTIME_ENERGY_COST_PER_AP
    current_ap += ap_gain
    max_ap_today += ap_gain
    current_energy = maxi(0, current_energy - energy_cost)
    overtime_used_this_month += 1
    _state = APState.AP_OVERTIME_ACTIVE
    emit_signal(&"effort_overtime_incremented", SceneDayFlowController.current_day, overtime_used_this_month)
    emit_signal(&"ap_changed", current_ap, max_ap_today)
    emit_signal(&"energy_changed", current_energy, 100)
    return true
```

## QA Test Cases

- energy=100 → try_overtime → AP +4 + energy -100 + DEPLETED 状态错(不,AP+4 后 NORMAL)
- energy=50 → AP +2 + energy -50
- energy=0 → false + 状态不变

## Test Evidence

`tests/unit/ap/f1_overtime_test.gd`

## Dependencies

- Depends on: Story 001
- Unlocks: Story 008(monthly_effort_summary)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 6 test 函数 (`tests/unit/ap/f1_overtime_test.gd`)
**Test Evidence**: `tests/unit/ap/f1_overtime_test.gd` (~115 行 / 6 tests / GdUnit4) — BLOCKING gate PASS;包含 R-AP-3 monotonicity invariant
**Code Review**: APPROVED (lean-mode autopilot inline);F1 公式 clampi(energy/100*4,1,4) + energy_cost = ap_gain*25 + state→AP_OVERTIME_ACTIVE + overtime_used_this_month++ + 三 signal 同帧 emit (effort_overtime_incremented + ap_changed + energy_changed); 无 BLOCKING/无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. day 来源用 _resolve_day() 注入 (Callable 或 SceneFlow.current_day,缺省 0) — story body 直引 `SceneDayFlowController.current_day`,改成 cross-epic seam (graceful);无 contract 影响
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: try_overtime() + signal effort_overtime_incremented/energy_changed + property overtime_used_this_month + const F1_OVERTIME_AP_MAX/F1_OVERTIME_ENERGY_COST_PER_AP
