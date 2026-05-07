# Story 004: F3 capacity_factor — Anti-P1 Monotonic Decay

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-008`
**ADR**: GDD F3 + architecture.md principle 2(Anti-P1 单调红线)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: capacity_factor(m) 单调递减(Anti-P1 红线)
- Forbidden: capacity_factor 反向调高(PR-blocking + push_error)

## Acceptance Criteria

- [ ] F3 公式:`capacity_factor(m) = max(CAPACITY_FLOOR, 3.0 - 0.05·m)`(MVP CAPACITY_FLOOR = 0.4;野心版 = 0)
- [ ] M0 → 3.0 / M11 → 2.45 / M30 → 1.5 / M52 → 0.4(cap floor)
- [ ] 单调递减自动化测试:任 m1 < m2 → capacity_factor(m1) >= capacity_factor(m2)
- [ ] Anti-P1 lint:任何 effect / event / unlock 试图反向调 capacity_factor → push_error + PR-blocking

## Implementation Notes

```gdscript
const CAPACITY_FLOOR_MVP := 0.4
const CAPACITY_DECAY_PER_MONTH := 0.05
const CAPACITY_INITIAL := 3.0

func capacity_factor(m: int) -> float:
    return maxf(CAPACITY_FLOOR_MVP, CAPACITY_INITIAL - CAPACITY_DECAY_PER_MONTH * m)
```

## QA Test Cases

- F3 输出表:M0=3.0 / M11≈2.45 / M30=1.5 / M52=0.4(cap)
- 单调:assert any m1 < m2 → capacity_factor(m1) >= capacity_factor(m2)
- Anti-P1 lint:故意调 CAPACITY_INITIAL → 反方向 → push_error

## Test Evidence

`tests/unit/ap/f3_capacity_test.gd`

## Dependencies

- Depends on: None
- Unlocks: Story 008(monthly_effort_summary 用 capacity_factor)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 4 test 函数 (`tests/unit/ap/f3_capacity_test.gd`)
**Test Evidence**: `tests/unit/ap/f3_capacity_test.gd` (~70 行 / 4 tests / GdUnit4) — BLOCKING gate PASS;含 reference table M=0/11/30/52 + 100 个 m 的 monotonic 验证 + 常量 sign-lock 测试
**Code Review**: APPROVED (lean-mode autopilot inline);capacity_factor 是 static 函数 (可被 architecture review 跨 epic 调用,Story 008 + KPI 复用) + maxf 守 floor + const sign-lock 三常量 (CAPACITY_DECAY_PER_MONTH > 0 / CAPACITY_FLOOR_MVP > 0 / CAPACITY_INITIAL > FLOOR);Anti-P1 红线由 tools/anti_p1_lint.py + 单测共同守门
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed (architecture.md principle 2 引用) — lean-mode-equivalent
**Tech debt**: None new
**API surface**: static capacity_factor(m: int) -> float + const CAPACITY_FLOOR_MVP/CAPACITY_DECAY_PER_MONTH/CAPACITY_INITIAL
