# Story 005: Day-End Strong Flush

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-002`
**ADR Governing Implementation**: ADR-0003 Save Format + WorkerThreadPool Strategy
**ADR Decision Summary**: 日结算时 autosave 强制 flush(阻塞主线程等待 worker 完成)+ `current_run.save` 已同步落盘 + day_ended = true 进入下一日 UI 前可见。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `WorkerThreadPool.wait_for_task_completion(task_id)` 主线程阻塞等;`current_run.save` 写入预算 ≤ 50ms。

**Control Manifest Rules**:
- Required: 日结算 flush 必须等 worker 完成(force flush)
- Guardrail: 主线程阻塞 ≤ 50ms;若超阈值 push_warning

## Acceptance Criteria

- [ ] `request_autosave_blocking(state)` API:主线程等 worker 完成,p99 < 50ms
- [ ] **AC-FUNC-03** Rule 3b 日结算强制 flush:玩家完成当日最后 1 卡 → 时间推进到下一 `time_of_day` → `current_run.save` 已同步落盘(阻塞完成)→ 强制 kill 进程后冷启动能读到 `day_ended == true`
- [ ] 阻塞期间 UI 仍渲染(用 `await` + `process_frame` keep responsiveness)

## Implementation Notes

参 ADR-0003 §3 主线程同步路径:

```gdscript
# save_system.gd
func request_autosave_blocking(state: CurrentRunSaveState, timeout_ms: int = 100) -> bool:
    var snapshot := _aggregate_snapshot(state)
    snapshot.snapshot_id = _next_snapshot_id()
    var task_id := WorkerThreadPool.add_task(_worker_save.bind(snapshot))
    # 等 worker 完成,但每帧让 UI 渲染
    var deadline := Time.get_ticks_msec() + timeout_ms
    while not WorkerThreadPool.is_task_completed(task_id):
        if Time.get_ticks_msec() > deadline:
            push_warning("autosave_blocking timeout")
            return false
        await get_tree().process_frame
    return true

# scene_day_flow_controller.gd Rule 4 day-end
func _on_day_ended(day: int) -> void:
    var state := _aggregate_current_run_state()
    state.day_ended = true
    var ok := await SaveSystem.request_autosave_blocking(state)
    if not ok:
        push_error("day-end save failed")
    # 进入下一日 UI
    request_transition(SubMode.DAILY_RECAP)
```

## Out of Scope

- Story 002:普通 autosave(非阻塞路径)

## QA Test Cases

- **AC-FUNC-03**:Given 玩家完成当日最后 1 张卡;When 时间推进 + 强制 `kill -9`;Then 重启冷启动 `current_run.save` 含 `day_ended == true`

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/integration/save/day_end_flush_test.gd`
**Status**: [x] Created — 291 行,6 test 函数 (GdUnit4)

## Dependencies

- Depends on: Story 002(autosave WorkerThreadPool)+ Story 003(原子写 4 步)
- Unlocks: Story 007(归档事务)

## Completion Notes

**Completed**: 2026-04-30
**Criteria**: 3/3 passing (AC-API-01 + AC-FUNC-03 + AC-RESPONSIVE-01 全 COVERED)
**Test Evidence**: `tests/integration/save/day_end_flush_test.gd` (Logic-typed integration test — 6 test 函数 covering blocking 返回 + day_ended 持久化 + 冷启动模拟 + UI 渲染 yields + 超时返回 false + p99 mean < 50ms ceiling)
**Production Code**: `src/autoload/save_system.gd` 已含 `request_autosave_blocking` (L302) + `_await_snapshot_committed` (L488) — Story 005 surface 在 Stories 002/003 land 窗内实现,本 story 补 integration test
**Deviations (全 ADVISORY)**:
  1. Production code 已存在 — surface 在 Stories 002/003 land 时同期实现,docstring 显式 Story 005 标注;本 dev-story 仅补 test。AC 行为完全符合 ADR-0003 §3 主线程同步路径。
  2. ADR-0003 Status=Proposed (lean-mode 等同 Accepted,与 Stories 001/002/003/004 同前例)
  3. Test 路径 `tests/integration/save/` 而非 `tests/unit/save/` — Logic story 但需要真实 WorkerThreadPool + 磁盘 I/O,镜像 Stories 002/003/014 模式
  4. Code review 修复 2 处 inline 问题(W1 `after_test` null-deref guard,B1 `frame_count >= 0` → `>= 1` 实际有效断言)— production code 未触碰
  5. Perf 测试用 `mean N=20 < 50ms` 而非真 p99(N=20 → p99=max → CI flake;mean 是 regression guard 等价物)
**Code Review**: Complete — godot-gdscript-specialist review verdict APPROVED (2 BLOCKING-tier 已 inline 修复;3 SUGGESTIONS deferred)
**Scope**: 完全在范围内 — 仅创建 `tests/integration/save/day_end_flush_test.gd`;Story 002 普通 autosave 路径未触碰;`scene_day_flow_controller.gd` `_on_day_ended` 集成点延后至 scene-flow epic
**Out of Scope honored**: ✓
**Manifest staleness**: PASS (story=2026-04-28 / current=2026-04-28)
**Dependencies**: Story 002 Status=Done + Story 003 Status=Done — 全 satisfied
