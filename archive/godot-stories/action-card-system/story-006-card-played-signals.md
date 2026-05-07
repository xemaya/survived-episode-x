# Story 006: card_played + kpi_contribution_reported Signals

> **Epic**: action-card-system | **Status**: Complete | **Layer**: Feature | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/action-card-system.md` | **Requirement**: `TR-card-004`
**ADR**: ADR-0001 card_played + kpi_contribution_reported + report_overage signal owner = #11
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: card_played(card_id) signal owner = #11(2 subs:#10 trigger.type=card / #13 HUD)
- Required: kpi_contribution_reported(amount) signal subscriber = #9 KPI Story 013
- Required: report_overage(card_id, kpi_delta) → AP Story 010 双向回调

## Acceptance Criteria

- [ ] `signal card_played(card_id: StringName)` owner = #11
- [ ] `signal kpi_contribution_reported(amount: float)` owner = #11
- [ ] `signal hero_card_played(card_id: StringName)` owner = #11(Story 007 ADR-0008 三 element 反馈协作)
- [ ] `report_overage(card_id, kpi_delta)` 调 AP Story 010 + KPI Story 013

## Implementation Notes

```gdscript
signal card_played(card_id: StringName)
signal kpi_contribution_reported(amount: float)
signal hero_card_played(card_id: StringName)

# Story 005 try_play_card 内部 emit
```

## QA Test Cases

- try_play_card → emit card_played × 1 + kpi_contribution_reported(若 kpi_delta != 0)
- is_hero card → emit hero_card_played × 1

## Test Evidence

`tests/integration/card/signals_test.gd`

## Dependencies

- Depends on: Story 005
- Unlocks: 全 Presentation 订阅 stories

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 6 test 函数
**Test Evidence**: `tests/integration/card/signals_test.gd` (146 行 / 6 tests / GdUnit4) — 覆盖 signal 定义存在 / 成功路径 emit × 1 / kpi_delta!=0 emit / kpi_delta=0 跳过 / hero only-for-hero / 失败路径全 0 emit — BLOCKING gate PASS;signal_ownership_lint.py 新增 3 条 owner pair (`card_played` / `kpi_contribution_reported` / `hero_card_played` → `card_play_system.gd`) PASS
**Code Review**: APPROVED (lean autopilot inline);单 emitter 守门生效 (signal_ownership_lint OK);report_overage 双向回调由 AP Story 010 既有 `report_overage` 提供,Card 端无需重复实现 (Story 005 chain 已透传);无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. report_overage 在 Card epic 不显式 emit 新 signal — 直接调 AP.report_overage 双向 (与 ADR-0001 协议一致,ap-economy Story 010 owner)
**Tech debt**: None new
**API surface**: `signal card_played(card_id: StringName)` + `signal kpi_contribution_reported(amount: float)` + `signal hero_card_played(card_id: StringName)` + `signal card_play_rejected(card_id, reason)`
