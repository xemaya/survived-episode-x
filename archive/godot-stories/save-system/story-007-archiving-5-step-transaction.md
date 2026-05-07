# Story 007: ARCHIVING 5-Step Transaction

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-003` + `TR-save-004`
**ADR Governing Implementation**: ADR-0003 Save Format + ADR-0006 Dismissal/GAMEOVER Path
**ADR Decision Summary**: ARCHIVING 5 步事务主线程同步(< 50ms);在 1500ms transition 演出**期间**执行(玩家无感);事务步骤 = ① 锁 settlement_locked ② 写 archive/[run_id].save 只读 ③ 删 current_run.save ④ 更新 meta.episode_count + last_archived_run_id ⑤ 清 pending_flags。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `DirAccess.remove_absolute()` + 文件只读位(平台差异 — chmod 只在 Linux/Mac);Windows 用 ReadOnly attribute。

**Control Manifest Rules**:
- Required: 5 步事务主线程同步 < 50ms;ARCHIVING 期间拒绝其他 I/O(Story 006 AC-STATE-04)
- Forbidden: 异步 ARCHIVING(必须主线程同步 + 在 1500ms transition 期间执行)

## Acceptance Criteria

- [ ] `archive_current_run(run_id: int) -> Error` API + 主线程同步 5 步执行
- [ ] **AC-FUNC-05** Rule 9 归档事务正常完成:① `archive/[run_id].save` 存在且只读位 ② `current_run.save` 不存在 ③ `meta.save` 的 `episode_count +1` + `last_archived_run_id == run_id`
- [ ] `meta.run_ended = true` 主线程同步 fsync(在 1500ms transition 启动**前** — Story 009)
- [ ] **AC-ROBUST-06** ARCHIVING 第 3 步完成后第 4 步前 `kill -9` → 重启 `archive/[run_id].save` 被删除(含清只读位)+ `current_run.save` 完整保留 + "继续"可用 + 再次 GAME OVER 能正常归档
- [ ] ARCHIVING 总耗时 < 50ms(自动化 perf test)
- [ ] `archive_completed(run_id)` signal owner = `#1 Save`(emit 在第 5 步完成后)

## Implementation Notes

参 ADR-0003 §5 + ADR-0006 时序图(T+5050ms transition 启动 + ARCHIVING 在 transition 期间):

```gdscript
# save_system.gd
signal archive_completed(run_id: int)

func archive_current_run(run_id: int) -> Error:
    if _state != SaveState.IDLE:
        return ERR_BUSY
    _transition_to(SaveState.ARCHIVING)
    
    # Step 1: settlement_locked = true(已由 #9 KPI Rule 11 设置)+ pending_flags["archiving"] = run_id
    var meta := load_meta()
    meta.pending_flags["archiving"] = run_id
    save_meta_sync(meta)  # 主线程同步 fsync
    
    # Step 2: 写 archive/[run_id].save + 设只读位
    var current_run := load_current_run()
    var archive_path := SaveStateLoader.ARCHIVE_DIR + "%04d.save" % run_id
    var json_text := JSON.stringify(current_run.serialize())
    var f := FileAccess.open(archive_path, FileAccess.WRITE)
    if not f.store_string(json_text):
        _transition_to(SaveState.ERROR)
        return ERR_FILE_CANT_WRITE
    f.flush()
    f.close()
    OS.set_file_read_only(archive_path)  # 只读位(跨平台抽象)
    
    # Step 3: 删 current_run.save
    DirAccess.remove_absolute(SaveStateLoader.CURRENT_RUN_PATH)
    
    # Step 4: meta.episode_count +1 + last_archived_run_id
    meta.episode_count += 1
    meta.last_archived_run_id = run_id
    
    # Step 5: 清 pending_flags + 立即 flush
    meta.pending_flags.erase("archiving")
    save_meta_sync(meta)  # 主线程同步 fsync,Step 5 完成
    
    _transition_to(SaveState.IDLE)
    emit_signal(&"archive_completed", run_id)
    return OK
```

崩溃恢复(R-A6-2 + AC-ROBUST-06)在 Story 008 处理(`pending_flags["archiving"]` 检测 + Rule 15 反向幂等补齐 / 回滚)。

## Out of Scope

- Story 008:pending_flags 持久化 + 启动恢复 + 反向幂等补齐
- Story 009:meta.run_ended fsync 时序(GAMEOVER 1500ms 之前)
- Story 011:archive 200 cap FIFO 驱逐(在 archive_completed 后)

## QA Test Cases

- **AC-FUNC-05**:Given Run 进入 GAME OVER + ARCHIVING 正常完成;When QA 检查文件系统;Then ① `archive/[run_id].save` 存在且只读位 ② `current_run.save` 不存在 ③ meta.episode_count +1 + last_archived_run_id == run_id
- **AC-ROBUST-06**:Given ARCHIVING 到第 3 步完成后第 4 步前 `kill -9`;When 重启;Then ① `archive/[run_id].save` 被删除(含清只读位)② `current_run.save` 完整保留 ③ "继续"可用 ④ 再次 GAME OVER 能正常归档
- **AC-PERF**:ARCHIVING 总耗时 < 50ms 主线程(自动化 perf test)

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/save/archiving_transaction_test.gd`(包括 kill -9 fixture)
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 002(autosave)+ Story 003(原子写)+ Story 006(状态机)
- Unlocks: Story 008(pending_flags 恢复)+ Story 009(meta.run_ended 时序)+ Story 011(200 cap)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 6/6 covered (11 test 函数 / 544 行 GdUnit4 integration suite)
**Test Evidence**: `tests/integration/save/archiving_transaction_test.gd` — BLOCKING gate PASS
**Code Review**: APPROVED WITH SUGGESTIONS (godot-gdscript-specialist, lean-mode 内联);S1 dead-code 已 inline 修复;S4/S5 deferred 为 ADVISORY
**Deviations** (全 ADVISORY,无 BLOCKING):
1. ADR-0003 / ADR-0006 Status=Proposed — lean-mode 等同 Accepted (Stories 001-006 同前例)
2. `OS.set_file_read_only` (story 伪代码) → `FileAccess.set_read_only_attribute(file, ro)` Godot 4.4+ 跨平台真 API (已通过 Godot 4.6 官方 ClassRef 核实)
3. `engine-reference/godot/breaking-changes.md` 未记录 `FileAccess.set_read_only_attribute` — 后续 docs PR 补
4. `archive_completed` 信号未用过去式 — 与 Control Manifest 字面一致,naming drift deferred 到 manifest 修订
**Tech debt**: None new
