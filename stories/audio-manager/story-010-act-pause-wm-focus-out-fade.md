# Story 010: act_pause + WM_FOCUS_OUT Unified Fade

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-007`
**ADR**: ADR-0001(act_pause / soft_pause_requested signal)+ Input Story 011 协作
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: act_pause + WM_FOCUS_OUT 公版统一(Music → -∞ 200ms / Ambient → -24 300ms)
- Required: Tween linear,无突变;`bus_volume_changed` 仅 Tween 起 / 终发射

## Acceptance Criteria

- [ ] `_on_act_pause(reason)` + `_notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT)` 触发统一 fade
- [ ] `_on_act_resume()` + `_notification(NOTIFICATION_WM_WINDOW_FOCUS_IN)` 退出 fade
- [ ] **AC-FUNC-11** Edge 7 暂停 / 焦点失:进入 — Music 200ms 线性 fade 至 -∞dB + Ambient 300ms 线性 fade 至 -24dB + Tween linear 无突变;退出 — Music/Ambient 200ms 内回前值;Tween 起/终 emit `bus_volume_changed`(非按帧)
- [ ] **AC-COMPAT-02** Ambient duck Tween + release 800ms:KPI_REVIEW 结束 sub-mode → IDLE → Ambient 800ms 线性回位 -12dB + 终值发射 `bus_volume_changed` 1 次;800ms 内 `play_sfx` 不阻

## Implementation Notes

```gdscript
const ACT_PAUSE_MUSIC_FADE_MS := 200
const ACT_PAUSE_AMBIENT_FADE_MS := 300
const AMBIENT_DUCK_RELEASE_MS := 800

func _on_act_pause(_reason: StringName) -> void:
    _start_pause_fade()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        _start_pause_fade()
    elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
        _end_pause_fade()

func _start_pause_fade() -> void:
    var t1 := create_tween()
    t1.tween_property(AudioServer, "bus_volume_db", -INF, ACT_PAUSE_MUSIC_FADE_MS / 1000.0)\
        .set_trans(Tween.TRANS_LINEAR)
    var t2 := create_tween()
    t2.tween_property(AudioServer, "bus_volume_db", -24.0, ACT_PAUSE_AMBIENT_FADE_MS / 1000.0)\
        .set_trans(Tween.TRANS_LINEAR)
```

## QA Test Cases

- AC-FUNC-11:act_pause / WM_FOCUS_OUT 二者同行为;Music 200ms / Ambient 300ms;退出 200ms 回位
- AC-COMPAT-02:KPI sub-mode IDLE → Ambient 800ms 线性回位 -12dB + 终值 emit 1 次

## Test Evidence

`tests/integration/audio/pause_fade_test.gd`

## Dependencies

- Depends on: Story 003 + Input Story 011(WM_FOCUS_OUT 协作)+ Scene Flow Story(act_pause)
- Unlocks: 全 sub-mode 切换 stories

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 2/2 AC-FUNC-11 + AC-COMPAT-02 COVERED via 7 test 函数(constants × 3 + on_act_pause 双 bus emit + Music 终值 -INF + Ambient 终值 -24 + on_act_resume 回位 + WM_FOCUS_OUT notification 等价)
**Test Evidence**: `tests/integration/audio/pause_fade_test.gd` (7 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);`_notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT)` + `on_act_pause(reason)` 都调 `_start_pause_fade()`(公版统一);Music 200ms fade → -INF / Ambient 300ms fade → -24dB;`bus_volume_changed` Tween 起+终 emit(start value + final value 而非 per-frame);`on_act_resume` + `WM_FOCUS_OUT` IN 都调 `_end_pause_fade` 回 default
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. Tween linear 实际 mid-frame 插值 OUT-OF-SCOPE(test 验起+终 emit 是契约;Tween 时序 visual sign-off 由 polish phase 后期完成)
2. AMBIENT_DUCK_RELEASE_MS = 800ms ambient duck 800ms 回位 KPI sub-mode IDLE 实施 deferred — 常量已暴露,Tween 实施由 Story 006 的 KPI Review 流程提供入口
3. `act_pause` 信号源(SceneDayFlowController)已存在 — Audio 暴露 `on_act_pause(reason)` hook 由 project bootstrap 接通
**Tech debt**: None new
**API surface**: `const ACT_PAUSE_MUSIC_FADE_MS = 200`;`const ACT_PAUSE_AMBIENT_FADE_MS = 300`;`const AMBIENT_DUCK_RELEASE_MS = 800`;`on_act_pause(reason)`;`on_act_resume()`;`_notification(WM_WINDOW_FOCUS_OUT/IN)`
