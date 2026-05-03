# Story 013: actual_kpi Accumulator (F7) + 5 Risk Guards

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-001`
**ADR**: GDD F7 + R-KPI-1..5
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: actual_kpi_m 累加 — `report_overage(card_id, kpi_delta)` from #11 → actual_kpi_m += kpi_delta
- Required: kpi_contribution_reported signal subscriber(从 #11 单卡贡献回调)
- Required: 5 [RISK GUARD] R-KPI-1..5 全 AC-ROBUST 守门

## Acceptance Criteria

- [ ] `actual_kpi_m: float` 月内累加器
- [ ] `_on_kpi_contribution_reported(amount: float)` 订阅(#11 emit)→ actual_kpi_m += amount
- [ ] 月末 settle 后 reset(`actual_kpi_history.append(actual_kpi_m); actual_kpi_m = 0`)
- [ ] AC-ROBUST(R-KPI-1..5):
  - R-KPI-1:Anti-P1 红线 — threshold / capacity_factor 反向 → push_error + PR-blocking
  - R-KPI-2:settlement_locked 月末重入(Story 009)
  - R-KPI-3:F1-F4 公式 RNG fairness(Story 012)
  - R-KPI-4:emit 顺序 kpi_threshold_changed before game_over_triggered(Story 010)
  - R-KPI-5:Save crash 恢复 Pillar 3 不可逃(Story 012)

## Implementation Notes

```gdscript
var actual_kpi_m: float = 0.0

func _on_kpi_contribution_reported(amount: float) -> void:
    if settlement_locked:
        return  # R-KPI-2 守门
    actual_kpi_m += amount

func _run_monthly_settlement() -> void:
    actual_kpi_history.append(actual_kpi_m)
    # ... settle 完成后
    actual_kpi_m = 0.0
    month_index += 1
```

## QA Test Cases

- 月内 N 次 report → actual_kpi_m = sum
- 月末 settle 后 reset = 0
- R-KPI-1..5 各自守门

## Test Evidence

`tests/unit/kpi/actual_kpi_accumulator_test.gd` + `tests/integration/kpi/risk_guards_test.gd`

## Dependencies

- Depends on: Story 001 + Story 005 + Action Card Story(report_overage)
- Unlocks: 全 KPI 月末完整链
