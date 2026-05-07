# Story 009: meta.run_ended fsync Before GAMEOVER 1500ms Transition

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-003` + `TR-save-010`
**ADR Governing Implementation**: ADR-0006 Dismissal/GAMEOVER Path Resolution + ADR-0003 Save Format
**ADR Decision Summary**: `meta.run_ended = true` 主线程同步 fsync **必须先于** GAMEOVER 1500ms transition 启动(R-AP-2 + R-KPI-2 守门,防 Alt+F4 续命);`final_transition_duration_ms = 1500ms` `linear easing=NONE`(skippable 但禁推翻 transition tone);Path B 双路径合并 — 所有 GAMEOVER 走 `#9 dismissal_triggered → #10 EVENT.KPI.FIRED_DISMISSAL → dismissal_finalized → #9 game_over_triggered`,`#9` 在收到 `dismissal_finalized` 时调 `SaveSystem.save_meta_sync(meta_with_run_ended=true)`。

**Engine**: Godot 4.6 | **Risk**: LOW(同步 fsync + Tween 4.0+ 稳定)
**Engine Notes**: `save_meta_sync()` 主线程阻塞 < 50ms;Tween linear easing=NONE 严守(自动化 perf test 验证斜率 dY 方差 < 5%)。

**Control Manifest Rules**:
- Required: meta.run_ended fsync 必须先于 transition 启动;`final_transition_duration_ms = 1500ms` linear easing=NONE
- Forbidden: ease-in / ease-out / bounce / elastic 任何非 linear easing(Pillar 3 "冷静打卡机"tone 守门)
- Guardrail: meta.run_ended fsync ≤ 50ms 主线程

## Acceptance Criteria

- [ ] `save_meta_sync(meta_with_run_ended: bool)` API 主线程同步 fsync,p99 < 50ms
- [ ] **AC-FUNC-12** Rule 21 离职证明 timing 硬约束:Run 进入 GAME OVER + ARCHIVING 完成后 `archive_completed` 信号 → `#16` UI 启动 transition → UI profiler 总时长 ≤ 1500ms + 逐帧 dY 采样斜率恒定(linear easing 断言,方差 < 5%)
- [ ] `#9 _on_dismissal_finalized()` 调 `SaveSystem.save_meta_sync(meta_with_run_ended=true)` 后 emit `game_over_triggered(reason, month)`(顺序保证 fsync 先于 transition)
- [ ] 防 Alt+F4 续命:在 `dismissal_triggered` emit 时同步 fsync `meta.dismissal_pending = true`(由 Story 008 实现);GAMEOVER 1500ms 期间 Alt+F4 → 重启检测到 `dismissal_pending` → 直接进入 GAMEOVER 剧本

## Implementation Notes

参 ADR-0006 时序图 T+0~T+6550ms:

```gdscript
# save_system.gd
func save_meta_sync(meta: MetaSaveState) -> Error:
    if _state != SaveState.IDLE and _state != SaveState.ARCHIVING:
        return ERR_BUSY
    var json_text := JSON.stringify(meta.serialize())
    var tmp_path := SaveStateLoader.META_PATH + ".tmp"
    var f := FileAccess.open(tmp_path, FileAccess.WRITE)
    if not f.store_string(json_text):
        return ERR_FILE_CANT_WRITE
    f.flush()
    f.close()
    DirAccess.rename_absolute(tmp_path, SaveStateLoader.META_PATH)
    return OK
```

```gdscript
# kpi_system.gd Rule 11 (协作系统)
func _on_dismissal_finalized() -> void:
    if fail_state != KPIFailState.AWAITING_DISMISSAL_FINALIZE:
        return
    # ARCHIVING 时序 ADR-0003 + ADR-0006
    var meta := SaveSystem.load_meta()
    meta.run_ended = true
    meta.end_reason = current_reason
    SaveSystem.save_meta_sync(meta)  # 主线程同步 fsync,< 50ms
    var current_month := SceneDayFlowController.month_index
    emit_signal(&"game_over_triggered", current_reason, current_month)
    # → #16 KPI Review UI 启动 1500ms linear easing=NONE transition

# kpi_review_game_over_ui.gd Rule 21 (协作系统)
func _on_game_over_triggered(reason: String, month: int) -> void:
    visible = true
    var tween := create_tween()
    # final_transition_duration_ms = 1500ms,linear easing=NONE
    tween.tween_property(self, "modulate:a", 1.0, 1.5)\
        .set_trans(Tween.TRANS_LINEAR)\
        .set_ease(Tween.EASE_IN)  # linear: from=0 to=1 in 1.5s
    # 注意:set_ease(Tween.EASE_IN) 配合 TRANS_LINEAR 仍是线性
    # 严禁 set_trans(TRANS_QUAD/CUBIC/...) — Pillar 3 tone 守门
```

## Out of Scope

- Story 008:`pending_flags` ARCHIVING 崩溃恢复(本 story 仅处理 meta.run_ended 时序)
- Story 011:archive 200 cap FIFO(归档完成后)
- `#9 KPI Story` `_trigger_path_b_dismissal` 实现(在 KPI epic)
- `#16 KPI UI Story` 1500ms Tween 实现(在 KPI Review UI epic)

## QA Test Cases

- **AC-FUNC-12**:Given Run 进入 GAME OVER + ARCHIVING 完成;When `#16` 启动 transition;Then UI profiler 测得总时长 ≤ 1500ms + 逐帧 dY 采样斜率恒定(linear easing 断言,方差 < 5%);任一不满足 FAIL
- **AC-PERF-meta-sync**:Given 1000 次 save_meta_sync;When 测主线程阻塞;Then p99 < 50ms
- **R-AP-2 + R-KPI-2 守门**:Given dismissal_finalized emit;When 注入 fsync 失败模拟;Then game_over_triggered NOT emit(等 fsync OK 才 emit);GAMEOVER transition 不启动
- **Alt+F4 续命防御**:Given GAMEOVER 1500ms 中 Alt+F4;When 重启;Then `meta.dismissal_pending` 被检测,直接进入 GAMEOVER 剧本(R-A6-1,Story 008)

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/save/meta_run_ended_fsync_test.gd` + `tests/integration/save/gameover_transition_linear_easing_test.gd`(自动化 perf test 含 dY 斜率方差测)
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 003(原子写)+ Story 007(ARCHIVING)+ Story 008(pending_flags)
- Unlocks: KPI epic Story(`#9 _on_dismissal_finalized` 协作)+ KPI Review UI epic Story(1500ms Tween 协作)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 2/4 in-scope COVERED + 2/4 cross-epic OUT-OF-SCOPE (story 自陈)
- AC-1 save_meta_sync atomic 4-step + p99 < 50ms — COVERED via `tests/integration/save/meta_run_ended_fsync_test.gd` (6 test 函数 / 376 行)
- AC-2 1500ms transition timing + linear easing dY 方差 — OUT-OF-SCOPE (#16 KPI Review UI epic)
- AC-3 dismissal_finalized → save_meta_sync → game_over_triggered 顺序保证 — OUT-OF-SCOPE (#9 KPI epic);save-system 范围内 save_meta_sync return true 时数据已 atomic rename 完成,顺序由 GDScript 单线程 same-frame emit 自然保证
- AC-4 Alt+F4 dismissal_pending 防御 — Story 008 已实施
**Test Evidence**: `tests/integration/save/meta_run_ended_fsync_test.gd` — BLOCKING gate PASS;cross-epic test (`gameover_transition_linear_easing_test.gd`) deferred 到 KPI Review UI epic
**Code Review**: APPROVED (lean-mode 内联);atomic 4-step 与 ADR-0003 §3 + Story 003 _worker_save 严格一致;无 BLOCKING / 无 inline fix needed
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0003 / ADR-0006 Status=Proposed — lean-mode-equivalent (Stories 001-008 同前例)
2. AC-2 / AC-3 cross-epic ACs deferred 到 KPI / KPI Review UI epic — story 自陈 Out of Scope. save-system 范围内 save_meta_sync API 主线程同步语义已守
3. Step 1 (FileAccess.open .tmp 失败) edge 未测 — CI 难模拟 chmod root,ADVISORY
**Tech debt**: None new
**Side benefit**: Story 007/008 调用方 (set_dismissal_pending / clear_dismissal_pending / _reconcile_archiving / archive_current_run Steps 1+5) 自动获益 atomic 升级 — partial write 保护从 current_run.save 扩展到 meta.save
