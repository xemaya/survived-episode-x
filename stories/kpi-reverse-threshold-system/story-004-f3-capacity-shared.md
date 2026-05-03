# Story 004: F3 capacity_factor Reuse from AP Story

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-002`
**ADR**: 协作 AP Story 004(F3 公式共享)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: capacity_factor 单点定义在 AP 模块(KPI 调用)
- Required: capacity_factor(0)=3.0 / capacity_factor(11)≈2.45 / capacity_factor(52)=0.4

## Acceptance Criteria

- [ ] `capacity_now() -> float`:调用 `APEconomy.capacity_factor(month_index)` 返当前月 capacity factor
- [ ] capacity_now × monthly_threshold = capacity_kpi(F4 GAME OVER 检测分母)
- [ ] 协作测试:KPI / AP 双 module 同 month → 相同 capacity_factor 值

## Implementation Notes

```gdscript
func capacity_now() -> float:
    return APEconomy.capacity_factor(month_index)

func capacity_kpi() -> float:
    return capacity_now() * float(monthly_threshold)
```

## QA Test Cases

- M0 → 3.0 × 100 = 300;M11 → 2.45 × 142 ≈ 348
- 与 AP Story 004 输出一致

## Test Evidence

`tests/integration/kpi/capacity_shared_test.gd`(协作 AP Story 004)

## Dependencies

- Depends on: Story 001 + AP Story 004
- Unlocks: Story 005(F4 GAME OVER)
