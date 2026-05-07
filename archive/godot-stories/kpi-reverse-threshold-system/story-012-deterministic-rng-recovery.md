# Story 012: Deterministic RNG + Crash Re-Detection

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-010`
**ADR**: GDD Edge 8.1 + 10.3(crash 恢复 Pillar 3 不可逃)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: deterministic RNG seed 可控(SaveSystem.get_run_seed())
- Required: 月末重新 GAME OVER 检测(crash 不可成复活手段)
- Required: settlement_locked_for_this_month per-month flag(防月内反复 reload)

## Acceptance Criteria

- [ ] RNG seed 公控:`var rng := RandomNumberGenerator.new(); rng.seed = SaveSystem.get_run_seed() + month_index`
- [ ] 月内反复 reload(Edge 10.3):`settlement_locked_for_this_month: bool` 在 KPI_REVIEW 开始置 true,日 reset 清 false → 每月仅结算一次
- [ ] crash 恢复:已 GAME OVER → 每次 load 即 GAME OVER(Pillar 3 不可逃)

## Implementation Notes

```gdscript
var settlement_locked_for_this_month: bool = false

func _run_monthly_settlement() -> void:
    if settlement_locked or settlement_locked_for_this_month:
        return
    settlement_locked_for_this_month = true
    # ... 正常 settlement(Story 010)

func _on_day_ended(_day: int) -> void:
    # 日 reset(月初新月)
    if SceneDayFlowController.current_day == 1:
        settlement_locked_for_this_month = false

func _on_save_loaded() -> void:
    # crash 恢复 — Pillar 3 不可逃
    if settlement_locked:
        SceneDayFlowController.request_recovery_to_gameover(_persisted_reason)
```

## QA Test Cases

- 反复 reload 月末 → 仅一次 settle
- 已 GAME OVER → 每次 load 即 GAME OVER
- RNG seed 公控:同 seed 同结果

## Test Evidence

`tests/integration/kpi/deterministic_rng_recovery_test.gd`

## Dependencies

- Depends on: Story 001 + Story 009 + Save Story
- Unlocks: Pillar 3 守门
