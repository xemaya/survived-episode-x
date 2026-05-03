# Story 002: F1 next_threshold Formula (α=0.04, β=0.18, γ=0.012)

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-002`
**ADR**: GDD Formula B 乘性公式
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: F1 公式锁定 — `next_threshold = threshold × (1 + α·E) × (1 + β·p) × (1 + γ·m)`
- Required: α=0.04(effort 系数)/ β=0.18(potential 系数)/ γ=0.012(月份 tenure 系数)— 公式锁

## Acceptance Criteria

- [ ] F1 公式实施:`next_threshold = monthly_threshold × (1 + 0.04·effort) × (1 + 0.18·potential) × (1 + 0.012·month)`
- [ ] M11 标准 profile:M11 + effort 2.5 + potential 0 → threshold 涨 ~25%(playtest 验证)
- [ ] Worked example 表(GDD Section D)对照测试

## Implementation Notes

```gdscript
const F1_ALPHA := 0.04
const F1_BETA := 0.18
const F1_GAMMA := 0.012

func calculate_next_threshold(effort: float, potential: float, month: int) -> int:
    var multiplier := (1.0 + F1_ALPHA * effort) * (1.0 + F1_BETA * potential) * (1.0 + F1_GAMMA * month)
    return ceili(monthly_threshold * multiplier)
```

## QA Test Cases

- M11 + effort=2.5 + potential=0 → threshold *1.232(~+23%)
- α/β/γ 系数验证(deterministic)

## Test Evidence

`tests/unit/kpi/f1_next_threshold_test.gd`

## Dependencies

- Depends on: Story 001
- Unlocks: Story 005(F4 GAME OVER 检测)
