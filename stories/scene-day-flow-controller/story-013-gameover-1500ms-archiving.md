# Story 013: GAMEOVER 1500ms Transition + ARCHIVING During Performance

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-010`
**ADR**: ADR-0006 Dismissal/GAMEOVER Path + ADR-0003 ARCHIVING 时序
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: KPI Story emit game_over_triggered → transition KPI_REVIEW → GAMEOVER 1500ms linear
- Required: ARCHIVING 5 步事务在 1500ms transition 演出**期间**执行(玩家无感)
- Forbidden: ARCHIVING 在 transition 之前(meta.run_ended fsync 必须先于 transition 启动 — Save Story 009 协作)

## Acceptance Criteria

- [ ] `_on_game_over_triggered(reason, month)` 订阅 → request_transition(GAMEOVER)
- [ ] GAMEOVER sub-mode `on_enter()`:启动 1500ms linear easing=NONE Tween(协作 KPI Review UI Story)
- [ ] ARCHIVING 5 步事务在 transition 期间(T+5050ms ~ T+6550ms)由 SaveSystem.archive_current_run() 主线程同步 < 50ms(协作 Save Story 007)
- [ ] transition 完成后 → request_transition(MAIN_MENU)+ archive 入列(协作 Run Meta Story)

## Implementation Notes

```gdscript
func _on_game_over_triggered(reason: StringName, _month: int) -> void:
    request_transition(&"GAMEOVER")
    # KPI Review UI Story 启动 1500ms transition
    # ARCHIVING 在 transition 期间执行(SaveSystem.archive_current_run 主线程同步 < 50ms)
    SaveSystem.archive_current_run(_get_next_run_id())
    await SaveSystem.archive_completed  # 等 ARCHIVING 完成
    await get_tree().create_timer(1.5).timeout  # 等 transition 完成
    request_transition(&"MAIN_MENU")
```

## QA Test Cases

- emit game_over_triggered → transition GAMEOVER + 1500ms transition + ARCHIVING 期间执行 < 50ms + transition 完成后 → MAIN_MENU
- 协作 Save Story 009 + KPI Review UI Story(三屏 own)

## Test Evidence

`tests/integration/scene_flow/gameover_transition_test.gd`(协作 Save / KPI Review UI stories)

## Dependencies

- Depends on: Story 010 + KPI Story + Save Story 009 + KPI Review UI Story
- Unlocks: Run Meta Story(archive_completed)+ Pre-Production gate

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED — `handle_game_over(reason, run_id)` 公有 coroutine API + transition `KPI_REVIEW`(若 not 已 in)→ `GAMEOVER` + 调 `SaveSystem.archive_current_run(run_id)`(已 implemented Save Story 007 — 5-step main-thread sync < 50ms)+ await `archive_completed` signal + 1500ms transition wait + transition `MAIN_MENU` + emit `archive_handed_off(run_id)` 给 Run Meta epic subscribers
**Test Evidence**: `tests/integration/scene_flow/gameover_transition_test.gd` (3 tests / GdUnit4) — BLOCKING gate PASS;graceful no-SaveSystem path 验证 + run_id payload 验证
**Code Review**: APPROVED;`SaveSystem.archive_current_run` 用 `_get_autoload_node` + `has_method` + `call(name, args)` graceful pattern(允许 test harness 不带 SaveSystem 跑);`archive_handed_off` signal 给 Run Meta epic subscribe;无 BLOCKING / 无 inline fix
**Engine API Verification**: SaveSystem.archive_current_run / archive_completed API 已在 save-system epic Story 007 实施(已查 `src/autoload/save_system.gd:801` `archive_current_run(run_id) -> Error` + L177 `signal archive_completed(run_id: int)`);本 story 调用 contract 与 save-system Story 007 commitment 一致
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0006 + ADR-0003 Status=Proposed — lean-mode-equivalent
2. KPI Review UI Story 1500ms transition Tween 由 KPI Review UI epic 实施(本 story 用 `create_timer(1.5).timeout` 等 transition 时长完成,不直接 own 演出 Tween)
3. ARCHIVING 5 步事务在 transition 期间执行 — Save Story 007 archive_current_run 是同步主线程 < 50ms,本 story await `archive_completed` signal 完成 (graceful 跨实现:同步/异步皆兼容)
**Tech debt**: None new
**API surface**: `handle_game_over(reason: StringName, run_id: int) -> void` (coroutine) + `signal archive_handed_off(run_id: int)`
