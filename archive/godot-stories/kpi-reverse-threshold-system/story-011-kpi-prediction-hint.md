# Story 011: kpi_prediction_hint 4-Tier (Old NPC Prophecy)

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-009`
**ADR**: ADR-0001 kpi_prediction_hint signal owner = #9
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 月末 -2 天触发 → 4 档 hint(老 NPC 预言)
- Required: kpi_prediction_hint(npc_id, hint_type) signal owner = #9(1 sub:#10 老 NPC 预言台词)

## Acceptance Criteria

- [ ] enum `KpiHintType { SAFE, SLIGHTLY_CONCERNING, RISKY, IMPENDING }`(4 档)
- [ ] 月末 -2 天触发(`current_day == days_in_month - 2`)+ projection threshold 计算 + 4 档分类
- [ ] emit `kpi_prediction_hint(npc_id, hint_type)`,#10 老 NPC 触发 4 档预言台词

## Implementation Notes

```gdscript
enum KpiHintType { SAFE, SLIGHTLY_CONCERNING, RISKY, IMPENDING }
signal kpi_prediction_hint(npc_id: StringName, hint_type: KpiHintType)

func _check_prediction_hint() -> void:
    var days_left := SceneDayFlowController.days_in_month - SceneDayFlowController.current_day
    if days_left != 2:
        return
    # 估算 projected_kpi(基于当前 actual + 剩 2 天估算)
    var projected := _estimate_projected_kpi()
    var ratio := projected / float(monthly_threshold)
    var hint: KpiHintType
    if ratio >= 1.05: hint = KpiHintType.SAFE
    elif ratio >= 0.95: hint = KpiHintType.SLIGHTLY_CONCERNING
    elif ratio >= 0.85: hint = KpiHintType.RISKY
    else: hint = KpiHintType.IMPENDING
    var npc := _select_old_npc()  # OLD_OIL / FISH_MONK 等老员工
    emit_signal(&"kpi_prediction_hint", npc, hint)
```

## QA Test Cases

- 月末 -2 天 + projected ratio 1.0 → SLIGHTLY_CONCERNING
- 4 档分类正确

## Test Evidence

`tests/unit/kpi/prediction_hint_test.gd`

## Dependencies

- Depends on: Story 001 + SceneFlow Story 011(current_day)
- Unlocks: Event Script Story(老 NPC 预言剧本)
