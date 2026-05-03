# Story 005: F4 GAME OVER Detection (threshold > capacity_now)

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-003`
**ADR**: ADR-0006(GAME OVER 检测协议)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: F4 检测 — `threshold > capacity_kpi` → GAME OVER trigger
- Required: M11 ± 2 标准 profile 玩家平均 GAME OVER(KPI research,Pre-Production prototype 实测)

## Acceptance Criteria

- [ ] `_check_game_over() -> bool`:`monthly_threshold > capacity_kpi()` 返 true
- [ ] M11 标准:262 > 245 → GAME OVER;M8 过度优秀:294 > 260 → GAME OVER(过度成功也死)
- [ ] 触发后调 `_trigger_game_over(reason="KPI_EXCEEDS_CAPACITY")` (Story 007)
- [ ] OQ-KPI-01 标准玩家 M11 ± 2 GAME OVER 实证(Pre-Production /prototype core-loop)

## Implementation Notes

```gdscript
func _check_game_over() -> bool:
    return float(monthly_threshold) > capacity_kpi()

func _on_monthly_kpi_settled(actual: float) -> void:
    var potential := calculate_potential(actual)
    if potential < POTENTIAL_LOWER:
        return  # dismissal_triggered already emitted (Story 003)
    var effort := APEconomy.monthly_effort_summary_value()
    var new_threshold := calculate_next_threshold(effort, potential, month_index)
    update_threshold(new_threshold)
    emit_signal(&"kpi_threshold_changed", monthly_threshold, new_threshold, ...)
    if _check_game_over():
        _trigger_game_over(&"KPI_EXCEEDS_CAPACITY")
```

## QA Test Cases

- M11 profile:262 > 245 → GAME OVER
- OQ-KPI-01:M11 ± 2 标准玩家 GAME OVER 实证(prototype playtest)

## Test Evidence

`tests/unit/kpi/f4_game_over_test.gd` + Pre-Production prototype core-loop

## Dependencies

- Depends on: Story 002 + Story 003 + Story 004 + AP Story 008(monthly_effort_summary)
- Unlocks: Story 007 + Story 008(Path B)
