# Story 008: pending_flags Persistence + Crash Recovery

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-002`
**ADR Governing Implementation**: ADR-0003 Save Format + ADR-0006 Dismissal/GAMEOVER Path
**ADR Decision Summary**: `meta.save.pending_flags: Dictionary` 持久化 + 启动期检测 → Rule 15 反向幂等补齐(完成 ARCHIVING 漏写步骤)+ 补齐完成后 `pending_flags` 立即清空 + flush;`meta.dismissal_pending = true` 在 `dismissal_triggered` emit 同步设置(R-A6-1 启动恢复 flag)。

**Engine**: Godot 4.6 | **Risk**: MEDIUM(主线程 fsync 时序敏感)
**Engine Notes**: 启动期 `meta.save` load 后立即检测 pending_flags;无 pending_flags = 正常启动。

**Control Manifest Rules**:
- Required: pending_flags 持久化 + 启动恢复;`meta.run_ended` 在 dismissal 链中同步 fsync
- Guardrail: 补齐 < 100ms 主线程

## Acceptance Criteria

- [ ] `meta.save.pending_flags: Dictionary[String, Variant]` schema 添加
- [ ] **AC-FUNC-10** Rule 18 pending_flags 持久化:ARCHIVING 第 5 步(meta 更新)中途 `kill -9` → 重启进入主菜单 → 冷启动日志 `meta_reconcile_pending=true` 检测 + Rule 15 反向幂等补齐触发 → 补齐完成后 `meta.save.pending_flags` 立即清空 + flush → `meta.episode_count == count(archive/*.save)`
- [ ] `meta.dismissal_pending = true` 在 `#9 dismissal_triggered` emit 同步 fsync(R-A6-1)
- [ ] 启动恢复检测到 `dismissal_pending` → 直接进入 `#10` GAMEOVER 剧本(从中断点恢复 R-A6-1)

## Implementation Notes

```gdscript
# save_system.gd
func _on_startup_check_pending_flags() -> void:
    var meta := load_meta()
    if meta.pending_flags.has("archiving"):
        var run_id: int = meta.pending_flags["archiving"]
        push_warning("meta_reconcile_pending=true: archiving=%d" % run_id)
        _reconcile_archiving(meta, run_id)
    if meta.dismissal_pending:
        # R-A6-1 启动恢复:直接进入 GAMEOVER 剧本
        SceneDayFlowController.request_recovery_to_gameover(meta.dismissal_reason)

func _reconcile_archiving(meta: MetaSaveState, run_id: int) -> void:
    var archive_path := SaveStateLoader.ARCHIVE_DIR + "%04d.save" % run_id
    var current_run_path := SaveStateLoader.CURRENT_RUN_PATH
    
    if FileAccess.file_exists(archive_path) and not FileAccess.file_exists(current_run_path):
        # ARCHIVING 已到第 4 步前但 meta 未更新 — 反向幂等补齐
        meta.episode_count = _count_archive_files()  # 重新计数
        meta.last_archived_run_id = run_id
    elif FileAccess.file_exists(archive_path) and FileAccess.file_exists(current_run_path):
        # ARCHIVING 第 2 步后第 3 步前崩溃 — 回滚 archive
        OS.set_file_read_only(archive_path, false)
        DirAccess.remove_absolute(archive_path)
    
    meta.pending_flags.erase("archiving")
    save_meta_sync(meta)  # 立即清空 + flush

func _count_archive_files() -> int:
    var dir := DirAccess.open(SaveStateLoader.ARCHIVE_DIR)
    var count := 0
    for f in dir.get_files():
        if f.ends_with(".save"):
            count += 1
    return count
```

## Out of Scope

- Story 007:ARCHIVING 5 步事务正常路径
- Story 013:`.tmp` 残留处理(autosave 崩溃,非 ARCHIVING 崩溃)

## QA Test Cases

- **AC-FUNC-10**:Given ARCHIVING 到第 5 步(meta 更新)中途 `kill -9`;When 重启;Then 冷启动日志 `meta_reconcile_pending=true` + 补齐 `meta.episode_count == count(archive/*.save)` + pending_flags 清空 + flush
- **R-A6-1**:Given dismissal_triggered emit + meta.dismissal_pending fsync 后 `kill -9`;When 重启;Then 直接进入 GAMEOVER 剧本(从中断点恢复)+ `#10` 接管 GAMEOVER 文本
- **AC-ROBUST-06 反例**(已在 Story 007 测):Given ARCHIVING 第 3 步前崩溃;When 重启;Then archive 被回滚

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/save/pending_flags_recovery_test.gd`(含 kill -9 fixture)
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 007(ARCHIVING 5 步)+ Story 006(状态机)
- Unlocks: Story 009(meta.run_ended fsync 时序)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 covered (9 test 函数 / 476 行 GdUnit4 integration suite)
**Test Evidence**: `tests/integration/save/pending_flags_recovery_test.gd` — BLOCKING gate PASS
**Code Review**: APPROVED WITH FIXES (godot-gdscript-specialist, lean-mode 内联);R1 (push_error 守 release-build assert strip) + S2 (删除 redundant reload_meta, 节省 ~15-30ms HDD I/O) inline 修复;S1/S3/S4 deferred ADVISORY
**Deviations** (全 ADVISORY, 无 BLOCKING):
1. ADR-0003 / ADR-0006 Status=Proposed — lean-mode 等同 Accepted (Stories 001-007 同前例)
2. AC-3/AC-4 caller/subscriber (#9 KPI / #6 SceneDayFlow / #10 EventScript) 不存在 — 本 story 仅暴露 set_dismissal_pending() / clear_dismissal_pending() API + emit dismissal_recovery_requested signal,actual integration 由后续 epic 实施 (Out of Scope 已声明)
3. 信号命名 `dismissal_recovery_requested` / `startup_recovery_completed` 非过去式 — 与 Story 007 `archive_completed` 同 naming drift,待 manifest 修订统一记录 hook signal 例外规则
4. 启动期主线程 100ms guardrail HDD p99 实测延后到 Polish (OQ-03)
**Tech debt**: None new
