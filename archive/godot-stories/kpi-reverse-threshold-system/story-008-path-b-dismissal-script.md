# Story 008: Path B Dismissal — Script-Routed GAMEOVER

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-006`
**ADR**: ADR-0006 Dismissal/GAMEOVER Path Resolution(Path B 双路径合并)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: Path B 唯一 — `dismissal_triggered → #10 EVENT.KPI.FIRED_DISMISSAL → dismissal_finalized → game_over_triggered`
- Required: dismissal watchdog 30s timer(防 #10 剧本崩溃)
- Required: meta.dismissal_pending fsync 在 dismissal_triggered emit 同步(R-A6-1 启动恢复 flag)

## Acceptance Criteria

- [ ] enum `KPIFailState { NORMAL, FAIL_1, FAIL_2, AWAITING_DISMISSAL_FINALIZE }`
- [ ] `_trigger_path_b_dismissal(reason)` 私有 API:settlement_locked = true + fail_state = AWAITING + emit dismissal_triggered
- [ ] `_on_dismissal_finalized()` 订阅(#10 emit)→ SaveSystem.save_meta_sync(run_ended=true) + emit game_over_triggered
- [ ] watchdog 30s:`_trigger_path_b_dismissal` 启动 + 超时 fallback emit dismissal_finalized 自身(degraded GAMEOVER)
- [ ] meta.dismissal_pending fsync 在 emit dismissal_triggered 同步(协作 Save Story 008)

## Implementation Notes

```gdscript
enum KPIFailState { NORMAL, FAIL_1, FAIL_2, AWAITING_DISMISSAL_FINALIZE }
var fail_state: KPIFailState = KPIFailState.NORMAL
var _dismissal_watchdog: Timer

func _trigger_path_b_dismissal(reason: StringName) -> void:
    settlement_locked = true
    fail_state = KPIFailState.AWAITING_DISMISSAL_FINALIZE
    SaveSystem.save_meta_dismissal_pending(reason)  # R-A6-1 fsync
    emit_signal(&"dismissal_triggered", reason)
    _dismissal_watchdog.start(30.0)

func _on_dismissal_finalized() -> void:
    if fail_state != KPIFailState.AWAITING_DISMISSAL_FINALIZE:
        return
    _dismissal_watchdog.stop()
    SaveSystem.save_meta_run_ended(_current_reason)
    emit_signal(&"game_over_triggered", _current_reason, month_index)

func _on_watchdog_timeout() -> void:
    push_warning("[KPI] dismissal watchdog 30s timeout — fallback")
    _on_dismissal_finalized()  # degraded path
```

## QA Test Cases

- Path B 完整链:dismissal_triggered → #10 → dismissal_finalized → game_over_triggered
- watchdog 30s:#10 不响应 → fallback emit
- meta.dismissal_pending 启动恢复:Alt+F4 在剧本期 → 重启检测 + 直接进 GAMEOVER 剧本

## Test Evidence

`tests/integration/kpi/path_b_dismissal_test.gd`(协作 #10 + Save Story 008)

## Dependencies

- Depends on: Story 003 + Story 007 + Event Script Story(EVENT.KPI.FIRED_DISMISSAL 剧本)+ Save Story 008
- Unlocks: GAMEOVER 演出
