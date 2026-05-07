# Story 010: kpi_threshold_changed emit Before game_over_triggered

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-001`
**ADR**: GDD Edge 4.1(R-KPI-4)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: kpi_threshold_changed emit 顺序早于 game_over_triggered(UI 先展示阈值再被覆盖)
- Required: GDScript 单线程保证 emit 顺序 = 调用顺序

## Acceptance Criteria

- [ ] `signal kpi_threshold_changed(old: int, new: int, delta_pct: float, breakdown: Dictionary)` owner = #9
- [ ] _run_monthly_settlement 调用顺序:F1 计算 → emit kpi_threshold_changed → F4 检测 → emit game_over_triggered(若命中)
- [ ] settlement_locked 同帧设置(防其他订阅者重触发)— 在 game_over_triggered emit **之后**

## Implementation Notes

```gdscript
signal kpi_threshold_changed(old: int, new: int, delta_pct: float, breakdown: Dictionary)

func _run_monthly_settlement() -> void:
    if settlement_locked:
        return
    var actual := actual_kpi_history[-1]
    var potential := calculate_potential(actual)
    if potential < POTENTIAL_LOWER:
        _trigger_path_b_dismissal(&"SEVERE_UNDERPERFORMANCE")
        return
    var effort := APEconomy.monthly_effort_summary_value()
    var new_t := calculate_next_threshold(effort, potential, month_index)
    var old_t := monthly_threshold
    var delta_pct := (new_t - old_t) / float(old_t)
    var breakdown := {"effort_part": effort, "potential_part": potential, "tenure_part": month_index}
    update_threshold(new_t)
    emit_signal(&"kpi_threshold_changed", old_t, new_t, delta_pct, breakdown)  # 先 emit
    if _check_game_over():
        _trigger_game_over(&"KPI_EXCEEDS_CAPACITY")  # settlement_locked 内部锁 + emit game_over_triggered
```

## QA Test Cases

- 月末 settle 触发 GAME OVER → 同帧 emit kpi_threshold_changed × 1 → emit game_over_triggered × 1(顺序保证)

## Test Evidence

`tests/integration/kpi/emit_order_test.gd`

## Dependencies

- Depends on: Story 002 + Story 005 + Story 007
- Unlocks: KPI Review UI Story(breakdown 渲染)
