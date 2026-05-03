# Story 010: Hero Card Monthly Cap + report_overage Bidirectional

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-003`
**ADR**: ADR-0001(report_overage / report_hero_card_played 双向回调)+ ADR-0008(Hero 频次约束)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: Hero card 月内 ≤ 4 次(`hero_card_played_this_month` cap)
- Required: report_overage(card_id, kpi_delta) 双向回调 + report_hero_card_played(card_id) 协作

## Acceptance Criteria

- [ ] `report_hero_card_played(card_id: StringName)` API:hero_card_played_this_month++;若 ≥ 4 → emit `effort_hero_capped` warning
- [ ] `report_overage(card_id: StringName, kpi_delta: float)` API:overage_card_played_this_month++;协作 KPI Story F7 actual_kpi 累加
- [ ] effort_hero_incremented + effort_overage_incremented signal owner = #7

## Implementation Notes

```gdscript
const HERO_CARD_MONTHLY_CAP := 4

signal effort_hero_incremented(card_id: StringName, day: int, total: int)
signal effort_overage_incremented(card_id: StringName, day: int, total: int)
signal effort_hero_capped

func report_hero_card_played(card_id: StringName) -> void:
    hero_card_played_this_month += 1
    var day := SceneDayFlowController.current_day
    emit_signal(&"effort_hero_incremented", card_id, day, hero_card_played_this_month)
    if hero_card_played_this_month >= HERO_CARD_MONTHLY_CAP:
        emit_signal(&"effort_hero_capped")

func report_overage(card_id: StringName, kpi_delta: float) -> void:
    overage_card_played_this_month += 1
    var day := SceneDayFlowController.current_day
    emit_signal(&"effort_overage_incremented", card_id, day, overage_card_played_this_month)
    KPISystem.report_overage(card_id, kpi_delta)  # 双向回调
```

## QA Test Cases

- 4 次 report_hero_card_played → cap warning emit
- report_overage → KPI Story F7 累加 actual_kpi

## Test Evidence

`tests/integration/ap/hero_overage_test.gd`(协作 Action Card + KPI stories)

## Dependencies

- Depends on: Story 001 + Story 005 + Action Card Story + KPI Story
- Unlocks: KPI F7 actual_kpi 累加

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 5 test 函数 (`tests/integration/ap/hero_overage_test.gd`)
**Test Evidence**: `tests/integration/ap/hero_overage_test.gd` (~125 行 / 5 tests / GdUnit4) — BLOCKING gate PASS;含 effort_hero_incremented(card_id, day, total) + 4-cap → effort_hero_capped + report_overage emit + KPI proxy bidirectional + 无 KPI 时 graceful no-crash
**Code Review**: APPROVED (lean-mode autopilot inline);report_hero_card_played + report_overage 双向 — 增 counter + emit 自家 signal + (有 KPI bound) proxy 到 KPI.report_overage(card_id, kpi_delta);has_method gating 守 KPI unbound 场景 (cross-epic graceful);HERO_CARD_MONTHLY_CAP=4 阈值告警仅是 informational signal (gameplay throttle 由 cards epic 拥有)
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. Action Card / KPI epic 未实现 → bind_kpi_system seam + has_method gating;ActionCard 端调 report_hero_card_played / report_overage 也是 cross-epic responsibility (调用方编排,非 AP 主动 wire) — 无 OUT-OF-SCOPE
2. ADR-0008 (Hero 频次约束) 当前以 const HERO_CARD_MONTHLY_CAP=4 锁;ADR Status=Proposed
3. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: report_hero_card_played(card_id) + report_overage(card_id, kpi_delta) + signal effort_hero_incremented/effort_overage_incremented/effort_hero_capped + const HERO_CARD_MONTHLY_CAP
