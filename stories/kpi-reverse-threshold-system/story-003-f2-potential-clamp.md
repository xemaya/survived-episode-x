# Story 003: F2 potential Clamp [-0.15, 1.0]

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-002`
**ADR**: GDD F2 + Edge 1.4 + 2.1 dismissal 路径
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: F2 potential = clamp((actual - threshold) / threshold, -0.15, 1.0)
- Required: raw < -0.15 → dismissal_triggered + 不进 F1(Path B)
- Required: raw=0 时 potential 因子 = 1.0(Pillar 1 最优解 — 刚达标)

## Acceptance Criteria

- [ ] F2 公式:`raw_potential = (actual_kpi - threshold) / threshold`;`potential = clamp(raw_potential, -0.15, 1.0)`
- [ ] raw < -0.15 → emit `dismissal_triggered(reason)`,**不进 F1**(threshold 不更新)
- [ ] raw=+2.0 → clamp 1.0(F1 输入)
- [ ] raw=0 → potential=0(F1 因子 1.0,最优解)

## Implementation Notes

```gdscript
const POTENTIAL_LOWER := -0.15
const POTENTIAL_UPPER := 1.0

signal dismissal_triggered(reason: StringName)

func calculate_potential(actual_kpi: float) -> float:
    var raw := (actual_kpi - monthly_threshold) / float(monthly_threshold)
    if raw < POTENTIAL_LOWER:
        emit_signal(&"dismissal_triggered", &"SEVERE_UNDERPERFORMANCE")
        return raw  # 不 clamp,让上层判断
    return clampf(raw, POTENTIAL_LOWER, POTENTIAL_UPPER)
```

## QA Test Cases

- raw=-0.2 → emit dismissal_triggered + threshold 不更新
- raw=+2.0 → clamp 1.0
- raw=0 → potential=0

## Test Evidence

`tests/unit/kpi/f2_potential_clamp_test.gd`

## Dependencies

- Depends on: Story 001 + Story 002
- Unlocks: Story 008(Path B dismissal)
