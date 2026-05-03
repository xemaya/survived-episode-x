# Story 009: R-MM-2 Pause + GAMEOVER 转移协调

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: AC-ROBUST-03

**ADR Governing Implementation**: ADR-0006 Dismissal/GAMEOVER Path
**ADR Decision Summary**: GAMEOVER 转移 `#9 game_over_triggered` → `#6 dispatch GAMEOVER sub-mode` 是不可阻断的 Pillar 3 死亡路径;若玩家在 ACTION_DAY Pause 中触发月末 KPI 结算导致 GAMEOVER → Pause 子屏须同帧关闭,GAMEOVER 流程不阻塞。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: SceneTree.paused 解除 + Pause UI 隐藏在 `#6 scene_state_changed(→GAMEOVER)` handler 同帧完成。

**Control Manifest Rules (Presentation)**:
- Required: GAMEOVER 路径无条件解除 Pause(Pillar 3 守门)
- Forbidden: Pause 在 GAMEOVER 期间继续保持(违反 P3 不可逆)
- Guardrail: 解除帧 ≤ 1 帧(handler 同步)

---

## Acceptance Criteria

- [ ] AC-ROBUST-03: Pause 子屏打开,`scene_state_changed(→GAMEOVER)` 触发,Pause 子屏同帧关闭,GAMEOVER 流程不阻塞
- [ ] 解除路径:`SceneTree.paused = false` + `InputHandler.pop_modal_lock(&"pause_modal")` + `_hide_pause_screen()` 同帧执行
- [ ] state 序列:Pause OPEN → 收到 scene_state_changed(→GAMEOVER) → Pause CLOSED + GAMEOVER_TRANSITION 启动
- [ ] 不 push_error(此路径属合法 — Pause 中 KPI 突触发 GAMEOVER)

---

## Implementation Notes

*From GDD Rule 3 + AC-ROBUST-03:*

- handler 路径(在 PauseScreen.gd):
  ```gdscript
  func _ready() -> void:
      SceneFlow.scene_state_changed.connect(_on_scene_state_changed)

  func _on_scene_state_changed(from: SubMode, to: SubMode, ctx: Dictionary) -> void:
      if to == SubMode.GAMEOVER and is_pause_open:
          _force_close_pause()  # 同帧

  func _force_close_pause() -> void:
      SceneTree.paused = false
      InputHandler.pop_modal_lock(&"pause_modal")
      _hide_pause_screen()
      is_pause_open = false
  ```
- 也可由 `#6` 主动 emit `pause_force_closed` 信号,#17 订阅(更解耦);本 story 选第一种(`#17` 自管)
- 注意:Pause 中 KPI 触发 GAMEOVER 是合法路径(玩家在 ACTION_DAY 末尾 Pause + 月末 KPI_REVIEW 同帧到达)

---

## Out of Scope

- Story 003: Pause 主体协议
- `#9 KPI` Story 007(game_over_triggered emit)
- `#6` GAMEOVER sub-mode dispatch

---

## QA Test Cases

- **AC-ROBUST-03**: Pause 中 GAMEOVER 强制解除
  - Given: PauseScreen.is_pause_open == true,SceneTree.paused == true,MODAL_LOCKED
  - When: SceneFlow.scene_state_changed.emit(KPI_REVIEW, GAMEOVER, {})
  - Then: 同帧 PauseScreen.is_pause_open == false AND SceneTree.paused == false AND modal_lock 释放;下一帧 GAMEOVER_TRANSITION 启动正常
  - Edge cases: KPI_REVIEW → GAMEOVER 而非 ACTION_DAY → GAMEOVER(也合法,ROBUST-03 守门)

- **AC-2**: 同帧解除
  - Given: 信号 emit 帧 N
  - When: 下一帧 N+1
  - Then: PauseScreen.visible == false(GUI handle 同步,无 await)

- **AC-3**: 无 push_error
  - Given: Pause 中 GAMEOVER 路径
  - When: handler 执行
  - Then: error 日志 0 条(此为合法路径)

---

## Test Evidence

**Required evidence**: `tests/integration/main_menu/r_mm_2_pause_gameover_coordination_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 003(Pause 主体);`#6 Scene Flow` Story 002(scene_state_changed signal);`#9 KPI` Story 007(game_over_triggered);`#16 KPI Review UI` Story 005(GAMEOVER 1500ms transition)
- Unlocks: 无

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 5 test 函数(`tests/integration/main_menu/r_mm_2_pause_gameover_coordination_test.gd`)— AC-ROBUST-03 force-close 路径(open Pause + GAMEOVER → close + paused=false + modal release + emit pause_force_closed)/ AC-2 no-op 当 Pause 已关闭 / AC-2 KPI_REVIEW → GAMEOVER edge case 同样 force-close / AC-3 single emit pause_force_closed / 非 GAMEOVER target 不触发(WEEKEND 例)
**Test Evidence**: `tests/integration/main_menu/r_mm_2_pause_gameover_coordination_test.gd`(GdUnit4 5 tests)— BLOCKING gate PASS
**Code Review**: APPROVED;`force_close_on_gameover(from, to)` 签名直接对接 `SceneDayFlowController.scene_state_changed(from, to)` 信号 — production wiring 时 `pause_controller.force_close_on_gameover` 直 connect;同帧执行(无 await),P3 不可逆守门;`pause_force_closed` 信号供更上层 KPIReviewUI 订阅(可选 — 解耦路径);无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR-0006 Status=Proposed — lean-mode-equivalent
2. SceneFlow 主动 emit `pause_force_closed` 解耦方案(原 story Note)未采用 — 选 #17 自管路径,因 SceneFlow 不应感知 Pause UI 内部状态(SoC 边界)
**Tech debt**: None new
**API surface**:
- `signal pause_force_closed`
- `func force_close_on_gameover(from: StringName, to: StringName) -> void`
