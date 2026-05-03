# Story 009: settlement_locked R-KPI-2 Guard

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-007`
**ADR**: ADR-0006 R-KPI-2 + Edge 8.1/8.2 crash 恢复
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: settlement_locked 防月末重入(R-KPI-2)
- Required: Save crash 恢复后 settlement_locked = true 时直接进 GAME OVER 检测(Pillar 3 不可逃)
- Required: 同帧 `kpi_threshold_changed → game_over_triggered` 顺序保证(GDScript 单线程)

## Acceptance Criteria

- [ ] `settlement_locked: bool` state(Save sub-schema 持久化)
- [ ] `_run_monthly_settlement()` 入口守门:settlement_locked = true → 早返(防月末重入)
- [ ] 启动恢复:settlement_locked + threshold > capacity_kpi → 直接 _trigger_game_over(crash 恢复 — Edge 8.1)
- [ ] Edge 8.2:settlement_locked = true 写成功 + threshold 写失败(部分崩溃)→ load 后 settlement_locked 优先 → 直接 GAME OVER UI

## Implementation Notes

```gdscript
func _run_monthly_settlement() -> void:
    if settlement_locked:
        push_warning("[KPI] Re-entrant settlement (R-KPI-2 guard)")
        return
    # ... 正常 F1-F4 settlement
    # 在 _trigger_game_over 内 settlement_locked = true(已锁同帧)

func _on_save_loaded() -> void:
    # crash 恢复
    if settlement_locked:
        # 已 GAMEOVER,直接进 GAMEOVER UI(协作 Save Story 008 + KPI Review UI Story)
        SceneDayFlowController.request_recovery_to_gameover(_persisted_reason)
```

## QA Test Cases

- 月末重入 _run_monthly_settlement 2 次 → 第 2 次拒绝
- crash 恢复:settlement_locked + threshold > capacity → 直接 GAME OVER
- Edge 8.2:settlement_locked 写成功 + threshold 失败 → settlement_locked 优先

## Test Evidence

`tests/integration/kpi/settlement_locked_test.gd`(协作 Save Story 008)

## Dependencies

- Depends on: Story 005 + Save Story 008
- Unlocks: 跨 Run crash 恢复 Pillar 3 守
