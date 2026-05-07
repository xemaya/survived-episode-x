# Story 013: Crash Recovery + .tmp Cleanup + Exit Timeout

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-005` + `TR-save-002`
**ADR Governing Implementation**: ADR-0003 Save Format
**ADR Decision Summary**: autosave 写 `.tmp` 期间 `kill -9` → 重启时 ① 旧 `current_run.save` 未被破坏 ② 孤立 `.tmp` 正确处理(完整则提示采用/丢弃,不完整则静默删除);`app_pause_save_timeout = 100ms` 退出超时强制中断 — 进程在 ≤ 200ms 内退出(不阻塞 Steam kill)。

**Engine**: Godot 4.6 | **Risk**: MEDIUM(`NOTIFICATION_WM_CLOSE_REQUEST` + WorkerThreadPool 任务取消)
**Engine Notes**: `NOTIFICATION_WM_CLOSE_REQUEST` 通知 → 主线程 100ms 内中断 worker;`WorkerThreadPool.wait_for_task_completion(task_id, timeout_msec)` 4.4+ 支持 timeout 参数。

**Control Manifest Rules**:
- Required: `.tmp` 残留启动期检测 + 处理(完整 → 提示采用 / 丢弃;不完整 → 静默删除)
- Required: 退出超时 100ms 强制中断 worker;进程 ≤ 200ms 内退出
- Forbidden: 退出阻塞等 worker 完成(违反 Steam kill 友好)

## Acceptance Criteria

- [ ] 启动期 `_check_orphan_tmp()` 检测 `current_run.save.tmp`:
  - 完整 JSON(可解析)→ 弹对话框"上次未保存的进度,采用/丢弃?"
  - 不完整(JSON parse 失败)→ 静默删除 + log
- [ ] **AC-ROBUST-01** Edge 2.1/2.2 崩溃:autosave 正在写 `.tmp` 时 `kill -9`(Win `taskkill /F`)→ 重启 ① 旧 `current_run.save` 未被破坏 ② 孤立 `.tmp` 正确处理
- [ ] **AC-FUNC-11** Rule 19 退出超时强制中断:注入 `app_pause_save_timeout = 100` + autosave snapshot 500ms 慢钩子 → `NOTIFICATION_WM_CLOSE_REQUEST` → SaveManager 100ms 后强制中断当前写入 → `.tmp` 被删除 → 旧 save 完整保留 → 进程 ≤ 200ms 内退出
- [ ] `app_pause_save_timeout = 100` Tuning Knob

## Implementation Notes

```gdscript
# save_system.gd
const TMP_SUFFIX := ".tmp"

func _ready() -> void:
    _check_orphan_tmp()  # 启动期处理

func _check_orphan_tmp() -> void:
    var tmp_path := SaveStateLoader.CURRENT_RUN_PATH + TMP_SUFFIX
    if not FileAccess.file_exists(tmp_path):
        return
    # 尝试 parse
    var f := FileAccess.open(tmp_path, FileAccess.READ)
    var json_text := f.get_as_text()
    f.close()
    var parsed := JSON.parse_string(json_text)
    if parsed == null:
        # 不完整 — 静默删除
        DirAccess.remove_absolute(tmp_path)
        push_warning("Orphan .tmp deleted (incomplete JSON)")
    else:
        # 完整 — 弹对话框
        emit_signal(&"orphan_tmp_recovered", tmp_path, parsed)

# 退出超时
func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        _on_close_request()

func _on_close_request() -> void:
    # 100ms 内强制中断 worker
    if _current_worker_task_id != -1:
        var completed := WorkerThreadPool.wait_for_task_completion(_current_worker_task_id, 100)
        if not completed:
            # 强制中断 — 删除 .tmp
            push_warning("Save worker timeout, force interrupt")
            var tmp_path := SaveStateLoader.CURRENT_RUN_PATH + TMP_SUFFIX
            if FileAccess.file_exists(tmp_path):
                DirAccess.remove_absolute(tmp_path)
    get_tree().quit()
```

## Out of Scope

- Story 014:损坏 / 篡改 / NaN 净化(本 story 仅处理 `.tmp` 残留)
- Story 015:磁盘满(独立路径)

## QA Test Cases

- **AC-ROBUST-01**:Given autosave 正写 `.tmp`;When QA `kill -9`(Win `taskkill /F`);Then 重启 ① 旧 `current_run.save` 未破坏 ② 孤立 `.tmp` 正确处理(完整 → 弹对话框;不完整 → 静默删除)
- **AC-FUNC-11**:Given `app_pause_save_timeout=100` + autosave 500ms 慢钩子;When `NOTIFICATION_WM_CLOSE_REQUEST` 发送;Then SaveManager 100ms 后中断 → `.tmp` 删除 → 旧 save 保留 → 进程 ≤ 200ms 内退出

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/save/crash_recovery_test.gd` + `tests/integration/save/exit_timeout_test.gd`(含 kill -9 fixture)
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 003(原子写 4 步 + .tmp)+ Story 002(WorkerThreadPool autosave)
- Unlocks: Story 014(损坏处理可独立扩展)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 in-scope COVERED via 6 test 函数;kill -9 进程级 fixture deferred manual QA
**Test Evidence**: `tests/integration/save/orphan_tmp_recovery_test.gd` (182 行 / 6 tests / GdUnit4) — BLOCKING gate PASS;test 文件名调整避免与 Story 014 `crash_recovery_test.gd` 冲突
**Code Review**: APPROVED (lean-mode autopilot inline);_check_orphan_tmp 三态分支(无 / 完整 / 不完整);recovery signal 不自动删 .tmp(subscriber 决策);_on_close_request 用 polling(Godot 4.x WorkerThreadPool.wait_for_task_completion 无 timeout 参数);5ms 步长 ~20 polling iterations 在 100ms budget 内;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0003 Status=Proposed — lean-mode-equivalent (Stories 001-012 同前例)
2. kill -9 进程级 fixture(QA test case AC-ROBUST-01 验证)deferred 到 manual QA — in-process GdUnit4 无法模拟真 process 终止;tests 覆盖 .tmp 文件状态 disk fixture 等价行为 + signal-emit 路径
3. WorkerThreadPool.wait_for_task_completion 无 4.x timeout 参数 — 实施用 polling loop + OS.delay_msec(5) 替代,与 Godot 4.6 ClassRef 一致
**Tech debt**: None new
**API surface**:
- `SaveSystem.APP_PAUSE_SAVE_TIMEOUT_MS: int = 100` const (Tuning Knob)
- `SaveSystem.orphan_tmp_recovered(tmp_path: String, parsed_state: Dictionary)` signal — UI subscriber 接 "采用 / 丢弃" 对话框
- `SaveSystem._check_orphan_tmp()` 启动期自动调用
- `SaveSystem._on_close_request()` test seam (生产 NOTIFICATION_WM_CLOSE_REQUEST 自动 dispatch)
- `SaveSystem._current_worker_task_id: int` tracking (modify _submit_worker / _on_worker_done 已落)
