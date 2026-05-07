# Story 005: F4 effort 3-Dimension Weight (0.45/0.20/0.30)

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-003` + `TR-ap-007`
**ADR**: GDD F4(KPI research deviation 0.40/0.35/0.25 → **0.45/0.20/0.30** 锁,防 Hero 等价加班漏洞)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: F4 effort 三维度权重锁定 — overtime 0.45 / hero 0.20 / overage 0.30
- Forbidden: 反向调权重(违反 KPI research deviation 锁)

## Acceptance Criteria

- [ ] F4 公式:`monthly_effort = 0.45 × overtime_count + 0.20 × hero_card_count + 0.30 × overage_count`
- [ ] 三维度 counter:`overtime_used_this_month / hero_card_played_this_month / overage_card_played_this_month`
- [ ] 月末 reset 三 counter(月初新月 → 0)

## Implementation Notes

```gdscript
const F4_OVERTIME_WEIGHT := 0.45
const F4_HERO_WEIGHT := 0.20
const F4_OVERAGE_WEIGHT := 0.30

var hero_card_played_this_month: int = 0
var overage_card_played_this_month: int = 0

func monthly_effort_summary_value() -> float:
    return F4_OVERTIME_WEIGHT * overtime_used_this_month \
        + F4_HERO_WEIGHT * hero_card_played_this_month \
        + F4_OVERAGE_WEIGHT * overage_card_played_this_month

func _on_month_end() -> void:
    overtime_used_this_month = 0
    hero_card_played_this_month = 0
    overage_card_played_this_month = 0
```

## QA Test Cases

- F4 数值表:OT=4 / Hero=2 / Over=1 → effort = 4*0.45 + 2*0.20 + 1*0.30 = 1.80 + 0.40 + 0.30 = 2.50
- 月末 reset → 三 counter = 0

## Test Evidence

`tests/unit/ap/f4_effort_weight_test.gd`

## Dependencies

- Depends on: Story 002(overtime)+ Story 011(hero/overage report)
- Unlocks: Story 008(monthly_effort_summary)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 4 test 函数 (`tests/unit/ap/f4_effort_weight_test.gd`)
**Test Evidence**: `tests/unit/ap/f4_effort_weight_test.gd` (~75 行 / 4 tests / GdUnit4) — BLOCKING gate PASS;含 OT=4/Hero=2/Over=1 → 2.50 数值 + 月末 reset_monthly_counters() 三维度归零
**Code Review**: APPROVED (lean-mode autopilot inline);F4 weights 锁 0.45/0.20/0.30 + monthly_effort_value() lazy compute + reset_monthly_counters() 公开 API (Story 008 emit_monthly_summary 内部调用) + const lock 测试守 KPI research deviation
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: monthly_effort_value() + reset_monthly_counters() + property hero_card_played_this_month/overage_card_played_this_month + const F4_OVERTIME_WEIGHT/F4_HERO_WEIGHT/F4_OVERAGE_WEIGHT
