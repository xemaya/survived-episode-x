# Story 004: Hero Flag + Mutex + Monthly 4 Cap

> **Epic**: action-card-system | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/action-card-system.md` | **Requirement**: `TR-card-003`
**ADR**: ADR-0008(Hero 月内 4 次上限)+ AP Story 010 协作
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: is_hero flag → AP Story 010 report_hero_card_played 上限 4
- Required: mutex_group 同组互斥(同月只能 1 次)

## Acceptance Criteria

- [ ] is_hero=true 时 → 月内 ≤ 4 次(协作 AP Story 010 hero_card_played_this_month cap)
- [ ] mutex_group != "" → 同 mutex_group 卡同月仅 1 次
- [ ] 超 cap → DISABLED + 提示(NPC dialogue 或 HUD warning)

## Implementation Notes

```gdscript
var _mutex_played_this_month: Dictionary[StringName, bool] = {}

func _is_mutex_locked(mutex_group: StringName) -> bool:
    if mutex_group == &"":
        return false
    return _mutex_played_this_month.get(mutex_group, false)

func _on_card_played(card: Card) -> void:
    if card.mutex_group != &"":
        _mutex_played_this_month[card.mutex_group] = true
    if card.is_hero:
        APEconomy.report_hero_card_played(card.event_id)

func _on_month_end() -> void:
    _mutex_played_this_month.clear()
```

## QA Test Cases

- Hero 月内 4 次后 → DISABLED + AP Story 010 capped warning
- mutex_group 同组同月仅 1 次

## Test Evidence

`tests/unit/card/hero_mutex_test.gd`(协作 AP Story 010)

## Dependencies

- Depends on: Story 003 + AP Story 010
- Unlocks: Story 005(try_play_card)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 5 test 函数
**Test Evidence**: `tests/unit/card/hero_mutex_test.gd` (132 行 / 5 tests / GdUnit4) — 覆盖 hero 4-cap / AP report_hero_card_played 协作 / mutex 同月互斥 / 空 mutex 不锁 / on_month_end 重置 — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);try_play_card 同步双向 record (本类 _hero_played_this_month + AP.report_hero_card_played),AP Story 010 effort_hero_capped 第 4 次同步触发;无 BLOCKING / 无 inline fix
**Deviations** (无)
**Tech debt**: None new
**API surface**: `is_mutex_locked(group)` + `hero_played_this_month` getter + `on_month_end()` + 内部 _record_play hook
