# Story 008: Pause Game-Time vs Wall-Clock Boundary

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-006`
**ADR**: ADR-0002 + C-ENG-02 + C-ENG-07
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: PAUSE_INHERIT(game-time)vs PROCESS_MODE_ALWAYS(wall-clock)二分严守
- Required: game-time 累加器在 SceneTree.paused 期间**不增长**;wall-clock(Time.get_ticks_msec)继续

## Acceptance Criteria

- [ ] `_game_time_minutes: int` accumulator 仅在 ACTION_DAY / EVENT_ACTIVE / WEEKEND 期间增长
- [ ] PAUSE / SETTINGS / KPI_REVIEW / GAMEOVER / MAIN_MENU sub-mode 期间 game-time 冻结
- [ ] `Time.get_ticks_msec()` wall-clock(Watchdog 用)继续推进
- [ ] `request_soft_pause(source)` API:`SceneTree.paused = true` + game-time 冻结
- [ ] `request_soft_resume()` API:`SceneTree.paused = false` + game-time 恢复

## Implementation Notes

```gdscript
var _game_time_minutes: int = 0
const GAMEPLAY_SUBMODES := [&"ACTION_DAY", &"EVENT_ACTIVE", &"WEEKEND"]

func _process(_delta: float) -> void:
    # PROCESS_MODE_ALWAYS — 跑在 paused 期间
    # 但 game-time 仅 gameplay sub-mode 累加(Rule 9 离散事件驱动)
    pass  # game-time 累加在 _on_ap_consumed,非 _process

func _on_ap_consumed(_amount: int) -> void:
    if _current_sub_mode in GAMEPLAY_SUBMODES and not get_tree().paused:
        _game_time_minutes += 60

func request_soft_pause(_source: StringName) -> void:
    get_tree().paused = true

func request_soft_resume() -> void:
    get_tree().paused = false
```

## QA Test Cases

- ACTION_DAY 期间 ap_consumed → game_time +60min;PAUSE 期间 ap_consumed(不可能,但测试)→ game_time 不增长
- wall-clock(Time.get_ticks_msec)在 PAUSE 期间继续推进

## Test Evidence

`tests/unit/scene_flow/game_time_pause_test.gd`

## Dependencies

- Depends on: Story 003(PROCESS_MODE_ALWAYS)+ Story 011(Rule 9 ap_consumed → game-time)
- Unlocks: Watchdog Timer / KPI 月末检测

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 5/5 COVERED — `_game_time_minutes: int` accumulator + `notify_ap_consumed()` 仅在 GAMEPLAY_SUBMODES 期间增长 + pause(`get_tree().paused == true`)期间冻结 + `request_soft_pause(source)` / `request_soft_resume()` API + wall-clock(`Time.get_ticks_msec`)未被冻结(测试用 wall-clock 等待 debounce flush 验证)
**Test Evidence**: `tests/unit/scene_flow/game_time_pause_test.gd` (3 tests / GdUnit4) — BLOCKING gate PASS;Wall-clock 持续推进由 settings_signals_coalescing_test PAUSE-RESUME 测试已 cover
**Code Review**: APPROVED;`GAMEPLAY_SUBMODES` const 显式列出 (ACTION_DAY/EVENT_ACTIVE/WEEKEND);非 gameplay sub-mode 的 ap_consumed 调用 silently no-op;无 BLOCKING / 无 inline fix
**Engine API Verification**: SceneTree.paused / Time.get_ticks_msec 是 Godot 4.x stable API,无变更
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. ADR-0002 Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `notify_ap_consumed(amount: int) -> void` + `request_soft_pause(source: StringName) -> void` + `request_soft_resume() -> void` + `game_time_minutes: int` 只读 property + `GAMEPLAY_SUBMODES: Array[StringName]` const
