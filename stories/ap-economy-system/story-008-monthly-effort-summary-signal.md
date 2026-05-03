# Story 008: monthly_effort_summary Signal — KPI Input

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-004`
**ADR**: ADR-0001 monthly_effort_summary signal owner = #7
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: monthly_effort_summary signal 月末 push 给 #9 KPI(F1 输入)
- Required: 三维度权重 0.45/0.20/0.30(Story 005)+ capacity_factor(Story 004)+ days_in_month

## Acceptance Criteria

- [ ] `signal monthly_effort_summary(month, potential, ot, hero, ovr, days, capacity_factor)` owner = #7
- [ ] `_on_month_end()` 触发 — 计算 F4 effort 总值 + capacity_factor + emit signal 给 #9
- [ ] 月末 reset 三 counter(协作 Story 005)
- [ ] potential = clamp(actual_kpi / threshold, -0.15, 1.0)— 协作 #9 KPI Story F2

## Implementation Notes

```gdscript
signal monthly_effort_summary(month: int, potential: float, ot: int, hero: int, ovr: int, days: int, cap_factor: float)

func _on_month_end() -> void:
    var month := SceneDayFlowController.month_index
    var days := SceneDayFlowController.days_in_month
    var cap := capacity_factor(month)
    var potential := KPISystem.calculate_potential()  # 协作 #9
    emit_signal(&"monthly_effort_summary", month, potential, overtime_used_this_month, hero_card_played_this_month, overage_card_played_this_month, days, cap)
    # reset counters(Story 005)
    overtime_used_this_month = 0
    hero_card_played_this_month = 0
    overage_card_played_this_month = 0
```

## QA Test Cases

- 月末 emit signal × 1 + payload 含 7 字段
- KPI Story 接收 → F1 计算 next_threshold

## Test Evidence

`tests/integration/ap/monthly_summary_test.gd`(协作 KPI Story)

## Dependencies

- Depends on: Story 002 + Story 004 + Story 005 + KPI Story(potential 计算协作)
- Unlocks: KPI Story F1 next_threshold 计算

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 4 test 函数 (`tests/integration/ap/monthly_summary_test.gd`)
**Test Evidence**: `tests/integration/ap/monthly_summary_test.gd` (~145 行 / 4 tests / GdUnit4) — BLOCKING gate PASS;含 7-tuple payload 验证 + month/days_in_month/KPI provider 注入 + capacity_factor(11)=2.45 数值 + potential clamp [-0.15, 1.0] 双向边界
**Code Review**: APPROVED (lean-mode autopilot inline);ADR-0001 single-emit-owner — `monthly_effort_summary.emit` 仅出现在 emit_monthly_summary() 内 + 7-tuple 顺序固定 + reset_monthly_counters() emit 后无条件调用 (Story 005 协作) + KPI/SceneFlow 通过 Callable / bind_* seam 注入,unbound 时 graceful (potential=0.0 / month=0 / days=30)
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. KPI #9 calculate_potential 跨 epic 未落地 → bind_kpi_system seam + has_method gating 优雅降级 (无 OUT-OF-SCOPE 改动)
2. SceneFlow month_index 属性 (Story 012 cross-epic) 未实施 → _resolve_month 回退到 SceneFlow.current_month 然后 0
3. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: emit_monthly_summary() + signal monthly_effort_summary(month, potential, ot, hero, ovr, days, cap_factor) + bind_kpi_system() + set_month_provider() / set_days_in_month_provider()
