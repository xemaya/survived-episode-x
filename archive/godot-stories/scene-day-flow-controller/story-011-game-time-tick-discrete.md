# Story 011: Game-Time Tick — Discrete Event-Driven (ap_consumed → +60min)

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-002`
**ADR**: GDD Rule 9 + ADR-0001(ap_consumed signal)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 离散事件驱动 game-time(`ap_consumed → +60min`),非 _process 累加
- Required: weekend_rest_day 信号触发 → energy +30(协作 AP Story)

## Acceptance Criteria

- [ ] `_on_ap_consumed(amount)` 订阅 — `_game_time_minutes += amount * 60`(每 AP = 60 game-time min)
- [ ] `_check_day_end()`:`_game_time_minutes >= 480`(8 AP × 60min)→ emit `day_ended(day)` + transition DAILY_RECAP
- [ ] `_check_week_end()`:连续 5 day_ended → emit `weekend_rest_day` + transition WEEKEND
- [ ] `_check_month_end()`:`current_day >= days_in_month`(30 day)→ transition KPI_REVIEW

## Implementation Notes

```gdscript
signal day_ended(day: int)
signal weekend_rest_day

var _game_time_minutes: int = 0
var current_day: int = 1
var month_index: int = 0
const DAILY_BUDGET_MIN := 480  # 8 AP × 60min

func _on_ap_consumed(amount: int) -> void:
    if _current_sub_mode not in [&"ACTION_DAY", &"EVENT_ACTIVE"]:
        return
    _game_time_minutes += amount * 60
    if _game_time_minutes >= DAILY_BUDGET_MIN:
        _end_day()

func _end_day() -> void:
    current_day += 1
    _game_time_minutes = 0
    emit_signal(&"day_ended", current_day - 1)
    if current_day % 5 == 0:  # 周末
        emit_signal(&"weekend_rest_day")
        request_transition(&"WEEKEND")
    elif current_day > _days_in_month():
        request_transition(&"KPI_REVIEW")
    else:
        request_transition(&"ACTION_DAY")
```

## QA Test Cases

- ap_consumed × 8(8 AP)→ game_time 480min → day_ended + transition
- 连续 5 day_ended → weekend_rest_day + transition WEEKEND
- 月末 day >= 30 → transition KPI_REVIEW

## Test Evidence

`tests/integration/scene_flow/game_time_tick_test.gd`

## Dependencies

- Depends on: Story 002 + Story 008(pause game-time)+ AP Story(ap_consumed signal)
- Unlocks: Story 012(月末 KPI Review)+ AP Story(weekend_rest_day)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED — `notify_ap_consumed(amount)` 公有 API + `_game_time_minutes += amount * 60` + `DAILY_BUDGET_MIN = 480` (8 AP × 60min)→ `_end_day()` 触发 + `day_ended(day)` signal emit + `_current_day` 增 + 5-day 周末检测 (`(_current_day - 1) % WEEKEND_INTERVAL == 0`)→ `weekend_rest_day(month, day)` emit + transition WEEKEND + 月末检测 (`_current_day > DAYS_PER_MONTH`)→ `_check_month_end()` → KPI_REVIEW
**Test Evidence**: `tests/integration/scene_flow/game_time_tick_test.gd` (2 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED;ap_consumed signal subscription 由 AP epic 实施(本 story 暴露 `notify_ap_consumed` 公有入口,subscriber 由 AP epic wire-up);weekend 触发判断 (current_day - 1) % 5 == 0 — 因 `_end_day` 已 ++current_day,所以判断已结束的日 (ended_day = current_day - 1) 是否 5 倍数;无 BLOCKING / 无 inline fix
**Engine API Verification**: N/A(纯 int 算术 + signal emit,Godot 4.x stable)
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR-0001 + GDD Rule 9 Status=Proposed — lean-mode-equivalent
2. AP Story `ap_consumed` signal 订阅 OUT-OF-SCOPE(本 story 暴露 `notify_ap_consumed()` 公有入口替代直接 subscriber pattern;AP epic 调本接口或通过 signal connect)
**Tech debt**: None new
**API surface**: `notify_ap_consumed(amount: int) -> void` + `signal day_ended(day: int)` + `signal weekend_rest_day(month: int, day: int)` + `current_day: int` 只读 + `current_month: int` 只读 + `DAILY_BUDGET_MIN`/`DAYS_PER_MONTH`/`WEEKEND_INTERVAL` consts
