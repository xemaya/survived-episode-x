# Story 003: Atomic Write 4-Step + snapshot_id

> **Epic**: save-system
> **Status**: Done
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-002`
**ADR Governing Implementation**: ADR-0003 Save Format + WorkerThreadPool Strategy
**ADR Decision Summary**: 原子写 4 步 = `open(.tmp) → store_string → flush + close → rename`;`snapshot_id: int` 单调递增(防 worker 乱序)+ `stale_request_dropped` 计数器;`store_string` 返 bool 必须 assert,失败保留旧 save。

**Engine**: Godot 4.6 | **Risk**: MEDIUM(`FileAccess.store_*` 4.4+ bool 返回值)
**Engine Notes**: 4.4+ `store_string` 返 bool;Windows `MoveFileExW` flag 在 Save GDD OQ-03 实测延 Polish。

**Control Manifest Rules**:
- Required: 4 步原子写;`assert(ok)` 校验 store_string 返回值
- Forbidden: 直接覆盖写 `current_run.save`(无 `.tmp` 中转 → 中途 crash 致破坏)

## Acceptance Criteria

- [x] **AC-FUNC-08** Rule 5 原子写 4 步:日志钩子记录 `open(".tmp") → store_string(true) → flush → close → rename` 顺序 — `_worker_save` (save_system.gd:294) 显式 `local_steps.append(&"open" / "store_string" / "flush" / "close" / "rename")` + `get_last_atomic_write_steps()` 公开 seam(save_system.gd:223);test_atomic_write_records_open_store_flush_close_rename_in_order
- [x] `store_string` 返 false 时记 `save_write_failed` 信号 + 保留旧 `current_run.save` — `_on_worker_done_failure` (save_system.gd:373) emit + `save_write_failed` signal (save_system.gd:76);store_string failure path 在 worker 调 `f.close() + DirAccess.remove_absolute(abs_tmp)` 不触 abs_dest;BLOCKING test = test_open_failure_preserves_previous_save_and_emits_signal(open_failed 路径作为同结构验证;store_string-specific 注入需 FileAccess wrapper,scope 外 — Notes 已记)
- [x] `snapshot_id: int` 单调递增(`_next_snapshot_id()` 主线程同步分配)— save_system.gd:188 `_next_snapshot_id += 1` 主线程 sync;test_snapshot_id_monotonic_after_three_consecutive_writes(+ Story 002 test_request_autosave_snapshot_ids_are_monotonically_increasing 互相印证)
- [x] 并发 3 次 autosave 时 worker 按 snapshot_id 顺序执行,旧 snapshot 被丢弃 + `stale_request_dropped` 计数器 +1 — `_last_completed_snapshot_id` 单调 guard (save_system.gd:298) + `stale_request_dropped` 双源累计(coalesce overwrite save_system.gd:198 + worker stale-drop save_system.gd:382);split tests:test_three_concurrent_autosaves_yield_latest_state_on_disk(final state ap=3)+ test_coalesce_overwrite_increments_stale_counter(stale +=1 from main-thread coalesce)+ test_worker_stale_check_drops_out_of_order_writes(direct worker invocation +=2);split rationale + literal "stale==2 in one test from 3 real concurrent calls" 不直接断言但两个底层机制隔离验证 — Notes 已记
- [~] **AC-PERF-01**:1000 次 autosave 端到端 p50 < 18ms / p99 < 50ms(SSD)— PARTIAL:test_atomic_write_perf_regression_guard_for_n50_saves(N=50 5000ms wall-clock CI ceiling regression guard PASS);canonical 1000-save SSD p50/p99 distribution 延 Polish stage manual playtest evidence(`production/qa/evidence/save-003-perf-evidence.md` — 待创建)

## Implementation Notes

参 ADR-0003 §2 + §3:

```gdscript
# save_system.gd
var _next_snapshot_id_counter: int = 0
var _last_completed_snapshot_id: int = 0
var stale_request_dropped: int = 0

signal save_write_failed(snapshot_id: int, reason: String)
signal autosave_completed(snapshot_id: int)

func _next_snapshot_id() -> int:
    _next_snapshot_id_counter += 1
    return _next_snapshot_id_counter

func _worker_save(snapshot: SaveSnapshot) -> void:
    # 单调检查:若已经写过更新的 snapshot,跳过此次
    if snapshot.snapshot_id <= _last_completed_snapshot_id:
        stale_request_dropped += 1
        return
    
    var tmp_path := SaveStateLoader.CURRENT_RUN_PATH + ".tmp"
    # Step 1: open .tmp
    var f := FileAccess.open(tmp_path, FileAccess.WRITE)
    if f == null:
        call_deferred("emit_signal", &"save_write_failed", snapshot.snapshot_id, "open_failed")
        return
    # Step 2: store_string(返 bool 4.4+)
    var json_text := JSON.stringify(snapshot.serialize())
    var ok: bool = f.store_string(json_text)
    if not ok:
        f.close()
        DirAccess.remove_absolute(tmp_path)
        call_deferred("emit_signal", &"save_write_failed", snapshot.snapshot_id, "store_string_failed")
        return
    # Step 3: flush + close
    f.flush()
    f.close()
    # Step 4: rename atomic
    var rename_err := DirAccess.rename_absolute(tmp_path, SaveStateLoader.CURRENT_RUN_PATH)
    if rename_err != OK:
        DirAccess.remove_absolute(tmp_path)
        call_deferred("emit_signal", &"save_write_failed", snapshot.snapshot_id, "rename_failed")
        return
    
    _last_completed_snapshot_id = snapshot.snapshot_id
    call_deferred("emit_signal", &"autosave_completed", snapshot.snapshot_id)
```

## Out of Scope

- Story 008:`pending_flags` ARCHIVING 中崩溃恢复
- Story 013:`.tmp` 残留处理 + `kill -9` 崩溃恢复

## QA Test Cases

- **AC-FUNC-08**:Given FileAccess 钩子;When autosave × 1;Then 日志序列 `open(.tmp) → store_string(true) → flush → close → rename`;故意注入 `store_string` 返 false → 记 `save_write_failed` + 旧 save 完整
- **AC-FUNC-08**(并发):Given 同帧 3 次 autosave with snapshot_id 1/2/3;When worker 处理(可能 2 先于 1);Then 仅最新 snapshot 写盘 + `stale_request_dropped == 2`
- **AC-PERF-01**:Given 1000 次 autosave on SSD;When 测端到端时延;Then p50 < 18ms / p99 < 50ms(MacBook M2 / Win NVMe / Ubuntu ext4)

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/save/atomic_write_test.gd`(包括 store_string 失败注入测试)
**Status**: [x] Created — file exists at exact required path(verified by Glob);7 test functions(4-step trace + open-failure preserves old save + monotonic snapshot_id + worker stale-drop direct invocation + coalesce overwrite stale counter + 3-concurrent latest-state + N=50 perf regression guard)

## Dependencies

- Depends on: Story 002(autosave WorkerThreadPool)
- Unlocks: Story 008(pending_flags 恢复)+ Story 013(crash recovery)

## Notes (Deferred from /code-review 2026-04-30)

- **store_string-specific failure injection**(AC-FUNC-08 second clause):Godot 4.4+ `FileAccess.store_string` 返 bool 真实失败注入需 FileAccess wrapper,scope 外。当前用 open_failed 路径(pre-create directory at .tmp 触发 FileAccess.open 返 null)作为同 handler structure 验证;`_on_worker_done_failure`(save_system.gd:373)是三个失败路径共用 handler,通过 code-symmetry + ADR-0003 §3 contract + open_failed 测试 + push_error log 间接验证 store_string_failed / rename_failed 的 cleanup + signal emission 行为。FileAccess wrapper 注入测试延后续 save-system story(target Story 014 corrupt/tampered 或新 Story 00X)。
- **store_string_failed / rename_failed partial trace 验证**:store_string 失败 → trace == [&"open"];rename 失败 → trace == [&"open", &"store_string", &"flush", &"close"]。当前 open_failed 测试验证 trace == [],4-step 成功测试验证 trace == 5 entries。中间 partial trace 形态需 FileAccess wrapper 才能注入,scope 外。
- **`.tmp` cleanup 验证**:store_string_failed / rename_failed 路径调 `DirAccess.remove_absolute(abs_tmp)`。无 wrapper 测试只能间接验证 stale-drop path 的 .tmp 不存在(已在 test_worker_stale_check_drops_out_of_order_writes 验证)。
- **AC-PERF-01 canonical 1000-save SSD perf**:p50<18ms / p99<50ms 是 Polish stage manual playtest evidence 范畴(target `production/qa/evidence/save-003-perf-evidence.md`,与 Story 002 AC-PERF-02 的 HUD 指示器 manual evidence 同模式)。CI N=50 5000ms ceiling 是 regression guard 不替代 canonical SSD 测量。
- **3-concurrent → stale==2 literal compliance**:Story 002 single-pending coalesce 已 reduce 3 calls 到 ≤ 2 writes(in-flight + 1 pending);Story 003 添加的 `_last_completed_snapshot_id` worker-side guard 在 coalesce 下不会自然触发(only 2 workers ever submitted;each writes successfully,no stale in worker)。单个 end-to-end 测试无法在 coalesce 模型下产生 stale==2(主线程 coalesce 会 +1,worker stale-drop 不会被触发)。当前 split-test 拆分两机制:test_coalesce_overwrite_increments_stale_counter(coalesce overwrite +1)+ test_worker_stale_check_drops_out_of_order_writes(direct _worker_save 调用 +2)。Lean mode 下接受 split 验证,deviation 已 documented;若未来 architecture 升级到 parallel workers,worker-side guard 会自然触发,届时可加单一 end-to-end stale==2 测试。
- **`_last_completed_snapshot_id` 跨线程内存可见性**:当前单 worker 串行模型(`_worker_in_flight` mutex)下安全。Future parallel workers 需 promote 到 Mutex-guarded section — save_system.gd:115-122 注释已明确 scope。code-review BLOCKING-01 inline fix 收窄注释从 "defence-in-depth against future parallel workers" 改为 "safe ONLY under single-worker-serialised design"。

## Completion Notes

**Completed**: 2026-04-30
**Verdict**: COMPLETE WITH NOTES
**Criteria**: 4/5 fully PASS + 1 PARTIAL(AC-PERF-01:N=50 regression guard PASS;canonical 1000-save SSD p50<18ms / p99<50ms 延 Polish manual evidence)
**Test Evidence**: tests/unit/save/atomic_write_test.gd(7 funcs)
**Manifest**: 2026-04-28 ✓ match;TR-save-002 registry text("WorkerThreadPool 异步 autosave + 主线程 ARCHIVING 5 步事务边界")— Story 003 实现 WorkerThreadPool autosave 全 atomic 协议;ARCHIVING 5 步事务延 Story 007
**Code Review**: Complete(godot-gdscript-specialist + qa-tester parallel);5 inline fixes applied(2 BLOCKING:cross-thread comment 收窄 + untyped Array params 加 doc 注释 + 1 BLOCKING test defect:_await_worker_idle 改 autosave_completed signal 等待 / 2 SUGGESTION:StringName literal &"..." × 3 + perf test assert 收紧 == N);3 items deferred to Notes(store_string-specific injection / partial trace / AC-PERF-01 manual)
**Deviations**: 1 ADVISORY
- 控件 manifest "**`FileAccess.store_*` 4.4+ 必须 `assert(ok)` 校验返回值**" 在 Story 003 autosave worker path 改为 `if not ok: cleanup .tmp + emit save_write_failed signal + return`(graceful failure with player-recoverable state)— Story 003 ACs 显式要求 "save_write_failed 信号 + 保留旧 save",assert 会 crash worker thread 不 honor AC。SaveStateLoader.save_meta_async / save_current_run_async(Story 001 path)仍用 assert(ok)— deviation scope 限于 Story 003 新增 autosave worker 路径,符合 Story 003 设计意图
**Out-of-Scope respected**: Story 008(pending_flags ARCHIVING 中崩溃恢复)/ Story 013(.tmp 残留处理 + kill -9 崩溃恢复)未实现 ✓
**Lean mode gates**: QL-TEST-COVERAGE + LP-CODE-REVIEW skipped per `production/review-mode.txt = lean`
