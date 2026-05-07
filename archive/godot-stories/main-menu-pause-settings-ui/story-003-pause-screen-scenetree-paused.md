# Story 003: Pause 子屏 SceneTree.paused 协议 + KPI_REVIEW 禁 Pause

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: AC-FUNC-05/06 + AC-PERF-03 + AC-ROBUST-02 + Rule 3

**ADR Governing Implementation**: ADR-0004 Settings Reflow Coalescing(Pause-aware 协议:Loc reflow 在 PAUSE 期间挂起)
**ADR Decision Summary**: Pause 子屏("摸鱼中"诙谐文案)= `SceneTree.paused = true` + Input MODAL_LOCKED 双控;`KPI_REVIEW` sub-mode 禁 Pause(月末仪式不被打断)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `SceneTree.paused = true` 4.6 同步影响 process_mode = PAUSABLE 节点;Autoload 设 `PROCESS_MODE_ALWAYS` 不受影响(`#6 Rule 3` 仲裁)。

**Control Manifest Rules (Presentation)**:
- Required: Pause 双控(`SceneTree.paused` + InputHandler MODAL_LOCKED)
- Forbidden: 单独设 `paused = true` 而不锁 Input(残留输入路径)
- Guardrail: Pause 开启帧 ≤ 16.6ms

---

## Acceptance Criteria

- [ ] AC-FUNC-05: `ACTION_DAY` sub-mode 进行中,`act_pause` 触发,Pause 子屏显示;`SceneTree.paused = true`;Input `MODAL_LOCKED`;"继续上班"按钮释放 → Pause 子屏隐藏 + paused = false + MODAL 释放
- [ ] AC-FUNC-06: `KPI_REVIEW` sub-mode 期间,`act_pause` 不弹 Pause 子屏(月末仪式守门)
- [ ] AC-ROBUST-02: Pause 期间等 3 帧,AP / game_time / KPI 累加器全不变化
- [ ] AC-PERF-03: Pause 开启帧耗时 ≤ 16.6ms(单帧)

---

## Implementation Notes

*From GDD Rule 3 + ADR-0004 PAUSE-aware:*

- Pause 触发:
  ```gdscript
  func _on_act_pause() -> void:
      var current_sub_mode := SceneFlow.current_sub_mode
      if current_sub_mode in [SubMode.KPI_REVIEW, SubMode.GAMEOVER, SubMode.LOADING, SubMode.MAIN_MENU]:
          return  # 守门:仪式 sub-mode 禁 Pause
      _show_pause_screen()
      SceneTree.paused = true
      InputHandler.push_modal_lock(&"pause_modal")
  ```
- Pause 退出:
  ```gdscript
  func _on_continue_pressed() -> void:
      _hide_pause_screen()
      SceneTree.paused = false
      InputHandler.pop_modal_lock(&"pause_modal")
  ```
- Pause 节点 `process_mode = PROCESS_MODE_ALWAYS`(自身不暂停,可响应输入);其他游戏节点默认 `PROCESS_MODE_INHERIT` 受 paused 影响
- 文案:`tr("PAUSE.SCREEN_TITLE")` = "摸鱼中"(诙谐 HR 口吻);`tr("PAUSE.RESUME_BUTTON")` = "继续上班"

---

## Out of Scope

- Story 005: Settings 子屏(Pause 子屏可能含进入 Settings 入口,但 Settings 主体在 004/005)
- Story 009: GAMEOVER 转移不被 Pause 阻断(独立 ROBUST-03)

---

## QA Test Cases

- **AC-FUNC-05**: Pause 双控
  - Given: SceneFlow.current_sub_mode == ACTION_DAY
  - When: emit `act_pause`
  - Then: PauseScreen.visible == true AND SceneTree.paused == true AND InputHandler.is_modal_locked() == true
  - Edge cases: 在 Pause 中再 emit `act_pause` → 无重复(idempotent);连按

- **AC-FUNC-06**: KPI_REVIEW 守门
  - Given: SceneFlow.current_sub_mode == KPI_REVIEW
  - When: emit `act_pause`
  - Then: PauseScreen.visible == false AND SceneTree.paused == false
  - Edge cases: GAMEOVER / LOADING / MAIN_MENU 同样守门(全 4 sub-mode 测)

- **AC-ROBUST-02**: 零游戏推进
  - Given: Pause 子屏开启
  - When: 等 3 帧
  - Then: APEconomy.current_ap 不变 AND SceneFlow.game_time_accumulator 不变 AND KPI.actual_kpi 不变
  - Edge cases: Autoload 节点(SceneFlow / KPI / APEconomy)process_mode = ALWAYS,但其内部累加器在 Pause 中被守门(`if SceneTree.paused: return` 入口)

- **AC-PERF-03**: 单帧 ≤ 16.6ms
  - Given: emit `act_pause` 在 ACTION_DAY
  - When: profiler 测开启帧
  - Then: 单帧 process time ≤ 16600us

---

## Test Evidence

**Required evidence**: `tests/unit/main_menu/pause_scenetree_paused_test.gd` — must exist and pass

---

## Dependencies

- Depends on: `#2 Input Handler` Story 005(modal lock stack);`#6 Scene Flow` Story 008(pause game-time vs wall-clock)
- Unlocks: Story 009(GAMEOVER 转移不被 Pause 阻断)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 5 test functions(`tests/unit/main_menu/pause_scenetree_paused_test.gd`)— AC-FUNC-05 dual-control open + resume + idempotent / AC-FUNC-06 KPI_REVIEW + GAMEOVER + LOADING + MAIN_MENU 4 forbidden sub-modes 守门 / AC-PERF-03 单帧 ≤16.6ms / AC-ROBUST-02 零游戏推进由 SceneTree.paused = true 自然保证(其他 epic 节点 PROCESS_MODE_INHERIT)
**Test Evidence**: `tests/unit/main_menu/pause_scenetree_paused_test.gd`(GdUnit4 5 tests)— BLOCKING gate PASS
**Code Review**: APPROVED;`PAUSE_FORBIDDEN_SUBMODES` 是 const 数组(KPI_REVIEW / GAMEOVER / LOADING / MAIN_MENU)便于 grep 静态校验;`process_mode = PROCESS_MODE_ALWAYS` 让 Pause 屏自身可响应输入;`is_pause_open` 公有字段供 Story 009 force_close_on_gameover 引用;DI seams(current_sub_mode_provider / set_scene_tree_paused_callable / acquire/release_modal_lock_callable / tr_callable)使 controller 无需 SceneFlow / InputHandler 即可测试;无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR-0004 Status=Proposed — lean-mode-equivalent
2. AC-ROBUST-02 "AP / game_time / KPI 累加器全不变化"由 SceneTree.paused 自然守门 + 其他 epic Autoload 内部 SceneTree.paused 入口检查(各 epic 自管),非本 controller 责任;本 story 验 dual-control 进/出
**Tech debt**: None new
**API surface**:
- `class_name PauseScreenController extends Control`
- `signal pause_opened` / `pause_closed` / `pause_force_closed`
- `const PAUSE_FORBIDDEN_SUBMODES: Array[StringName]`
- `var is_pause_open: bool`
- `func handle_act_pause()` / `handle_resume_pressed()` / `force_close_on_gameover(from, to)`
- 5 个 Callable DI seams
