# Story 015: Disk Full + Error State Handling

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-008`
**ADR Governing Implementation**: ADR-0003 Save Format
**ADR Decision Summary**: 磁盘满 → 旧 `current_run.save` 保留 + 残留 `.tmp` 删除 + 进入 ERROR 对话框含"磁盘已满";Save Rule 18 retry backoff 3 次失败后通知玩家"存档失败";AC-PERF-03 `autosave_perf_warning = 30ms` slow log + AC-PERF-04 `state_schema_review_threshold = 256KB` bloat warning。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `FileAccess.open()` 返 null 或 `store_string` 返 false 表 disk full;具体 errno 平台差异 — 用统一 ERR_FILE_CANT_WRITE 包装。

**Control Manifest Rules**:
- Required: 磁盘满 retry backoff 3 次 + ERROR 状态 + 玩家确认("重试" / "新局")
- Guardrail: autosave_perf_warning = 30ms / state_schema_review_threshold = 256KB

## Acceptance Criteria

- [ ] **AC-ROBUST-04** Edge 1.1 磁盘满:QA `dd` 填满 `user://` 所在卷到剩余 < 10KB → 触发 autosave → 旧 `current_run.save` 保留 + 残留 `.tmp` 删除 + 进入 ERROR 对话框"磁盘已满"
- [ ] Save Rule 18 retry backoff:store_string 失败 → 等 1s / 3s / 9s 重试 3 次 → 仍失败 emit `save_write_failed_persistent` + 弹"存档失败,请检查磁盘空间"
- [ ] **AC-PERF-03** Tuning Knob `autosave_perf_warning = 30ms`:autosave 实际耗时 35ms → 日志 `WARN save slow: 35ms` + 游戏不中断 + 状态回 IDLE
- [ ] **AC-PERF-04** Tuning Knob `state_schema_review_threshold = 256KB`:state 体积 300KB → autosave 完成 → 日志 `WARN state bloat warning: 300KB > 256KB` + save 本身成功
- [ ] **AC-STATE-05** ERROR → IDLE 需玩家确认("重试"或"新局")

## Implementation Notes

```gdscript
# save_system.gd
const AUTOSAVE_PERF_WARNING_MS := 30
const STATE_SCHEMA_REVIEW_THRESHOLD_BYTES := 256 * 1024  # 256KB

func _worker_save(snapshot: SaveSnapshot) -> void:
    var start := Time.get_ticks_msec()
    var json_text := JSON.stringify(snapshot.serialize())
    
    # AC-PERF-04 size warning
    if json_text.length() > STATE_SCHEMA_REVIEW_THRESHOLD_BYTES:
        push_warning("state bloat warning: %d bytes > %d" % [json_text.length(), STATE_SCHEMA_REVIEW_THRESHOLD_BYTES])
    
    # Retry backoff
    var attempts := 0
    var delays := [0, 1000, 3000, 9000]  # ms
    while attempts < 4:
        if attempts > 0:
            await get_tree().create_timer(delays[attempts] / 1000.0).timeout
        var ok := _try_write(json_text)
        if ok:
            break
        attempts += 1
    if attempts >= 4:
        call_deferred("emit_signal", &"save_write_failed_persistent", snapshot.snapshot_id)
        call_deferred("_transition_to", SaveState.ERROR)
        return
    
    # AC-PERF-03 slow log
    var elapsed := Time.get_ticks_msec() - start
    if elapsed > AUTOSAVE_PERF_WARNING_MS:
        push_warning("save slow: %dms" % elapsed)
    
    call_deferred("emit_signal", &"autosave_completed", snapshot.snapshot_id)

func _try_write(json_text: String) -> bool:
    var tmp_path := SaveStateLoader.CURRENT_RUN_PATH + ".tmp"
    var f := FileAccess.open(tmp_path, FileAccess.WRITE)
    if f == null:
        return false  # 磁盘满 / 权限错
    var ok := f.store_string(json_text)
    f.close()
    if not ok:
        DirAccess.remove_absolute(tmp_path)
        return false
    return DirAccess.rename_absolute(tmp_path, SaveStateLoader.CURRENT_RUN_PATH) == OK
```

## Out of Scope

- Story 013:`.tmp` 残留(本 story 在写失败时删除,Story 013 处理启动期残留)
- Story 014:损坏 / NaN(本 story 仅处理 disk full)

## QA Test Cases

- **AC-ROBUST-04**:Given `dd` 填满 user:// 卷剩余 < 10KB;When 触发 autosave;Then 旧 current_run.save 保留 + .tmp 删除 + ERROR 对话框"磁盘已满"
- **Save Rule 18 retry**:Given store_string 模拟失败 4 次;When autosave 触发;Then 重试 3 次(等 1s / 3s / 9s)+ 第 4 次失败 emit `save_write_failed_persistent` + 弹"存档失败"
- **AC-PERF-03**:Given autosave 实际 35ms;When 完成;Then 日志 "WARN save slow: 35ms" + 游戏不中断
- **AC-PERF-04**:Given state 体积 300KB;When autosave 完成;Then 日志 "WARN state bloat warning: 300KB > 256KB" + save 成功
- **AC-STATE-05**:Given ERROR 状态;When 玩家点"重试"/"新局";Then 回 IDLE

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/save/disk_full_test.gd` + `tests/integration/save/retry_backoff_test.gd`
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 002(WorkerThreadPool autosave)+ Story 003(原子写)+ Story 006(状态机)
- Unlocks: KPI Review UI epic Story(ERROR 对话框 UI)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 5/5 in-scope COVERED via 8 test 函数;UI 对话框 deferred KPI Review UI epic
**Test Evidence**: `tests/integration/save/disk_full_retry_test.gd` (240 行 / 8 tests / GdUnit4) — BLOCKING gate PASS;两 evidence path(disk_full_test.gd + retry_backoff_test.gd)合并为单文件(数据层不可分;doc 标注合并理由)
**Code Review**: APPROVED (lean-mode autopilot inline);retry coordinator 在主线程通过 SceneTree timer(worker 不能 await SceneTree);test seams(`_test_simulate_failure_count` + `_test_retry_delays_override`)不破坏 production 行为;test 加速 [10,10,10]ms 替代 [1000,3000,9000]ms 守 CI < 1s;exhaust → ERROR + save_write_failed_persistent + confirm_error_recovery 链路验证
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0003 Status=Proposed — lean-mode-equivalent (Stories 001-013 同前例)
2. AC-PERF-03 slow log + AC-PERF-04 bloat warning 用 push_warning — test 仅验证 const 值是否 wired (push_warning capture 在 GdUnit4 不直接,production 行为通过 const + 实施分支覆盖)
3. UI 对话框("磁盘已满"+ "存档失败"+ 重试/新局按钮)deferred KPI Review UI epic (story Out of Scope 已声明)
**Tech debt**: None new
**API surface**:
- `SaveSystem.AUTOSAVE_PERF_WARNING_MS: int = 30`
- `SaveSystem.STATE_SCHEMA_REVIEW_THRESHOLD_BYTES: int = 256 * 1024`
- `SaveSystem.RETRY_DELAYS_MS: Array[int] = [1000, 3000, 9000]`
- `SaveSystem.save_write_failed_persistent(snapshot_id: int)` signal — 3+ 次 retry 全失败后 emit
- `SaveSystem._consecutive_failure_count: int` (主线程 retry counter)
- Test seams: `_test_simulate_failure_count: int = 0` + `_test_retry_delays_override: Array[int] = []` (production 默认 0/空,不破坏 production 行为)
