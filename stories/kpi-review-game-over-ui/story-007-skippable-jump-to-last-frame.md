# Story 007: skippable 注册 + skip 仅跳到最后 1 帧不截断

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: TR-kpiui-001(skippable 子集)+ ADR-0006

**ADR Governing Implementation**: ADR-0006 Dismissal/GAMEOVER Path
**ADR Decision Summary**: GAMEOVER 1500ms transition skippable 但 skip **仅跳到最后 1 帧**(`t = duration - 1` 帧),不截断 transition tone(`#2 Input Rule 6` + `#9 Rule 12`);skip 后 `modulate.a ≈ 1.0` + ConfirmLabel 可见 + 离职证明文本全部已渲染。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `Tween.set_speed_scale()` 4.6 可跳到末态;但更稳的实施是直接 `tw.kill()` + `cert_panel.modulate.a = 1.0` + emit `tween_finished`。

**Control Manifest Rules (Presentation)**:
- Required: 所有 skippable token 通过 `#2 InputHandler.register_skippable()` API
- Forbidden: 直接订阅 `act_skip` Action — 必须经 token 注册路径
- Guardrail: skip 触发 → 末态可见 ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-07: skip 输入在 transition 进行中(`t < final_transition_duration_ms - 1`),`act_skip` 触发(`is_action_just_pressed`),`t_current` 跳至 `final_transition_duration_ms - 1`;`modulate.a ≈ 1.0`;`ConfirmLabel.visible = true`;离职证明文本全部已渲染
- [ ] skippable token 注册时机:state 进入 `GAMEOVER_TRANSITION` 同帧;退出该 state(无论 skip / 自然完成)同帧 unregister(R-SDF-5 跨系统守门 + Story 008)
- [ ] skip 后**不**触发 fast-forward easing 视觉变化(直接 jump,不用 0.1s 加速)
- [ ] KPI Review 屏(非 GAMEOVER)skip 行为由 `#15 Recap UI` Story 7 守门 — 本 story 仅 GAMEOVER skip

---

## Implementation Notes

*Derived from ADR-0006 + GDD Rule 9:*

- skippable 注册(state 进入 GAMEOVER_TRANSITION):
  ```gdscript
  func _enter_gameover_transition(reason: String) -> void:
      _start_gameover_tween(reason)  # Story 005
      InputHandler.register_skippable(
          token_id = &"gameover_skip",
          on_skip = _on_gameover_skipped
      )
  ```
- skip 处理:
  ```gdscript
  func _on_gameover_skipped() -> void:
      if _gameover_tween != null and _gameover_tween.is_running():
          _gameover_tween.kill()
      cert_panel.modulate.a = 1.0
      confirm_label.visible = true
      _on_dismissal_finalized()  # 同 Story 005 自然完成路径
  ```
- unregister 同帧(进入 ARCHIVE_VIEW 或返 Main Menu 时):
  ```gdscript
  InputHandler.unregister_skippable(&"gameover_skip")
  ```
- **不**用 `Tween.set_speed_scale(100)` 加速 — 直接 `kill()` + 末态赋值,避免 0.1s 加速段产生视觉错位

---

## Out of Scope

- Story 005: Tween 主体(本 story 仅 skip 路径)
- Story 008: R-KGO-1 守门(本 story 假设已正确进入 transition 态)
- `#15 Recap UI` Daily/Weekly skip 守门(其 Rule 7 + Story 7)

---

## QA Test Cases

- **AC-FUNC-07**: skip 跳末态
  - Given: GAMEOVER_TRANSITION 进行中,`t = 500ms`
  - When: `act_skip` `is_action_just_pressed`
  - Then: 下一帧 `cert_panel.modulate.a == 1.0` ± 0.05 AND `confirm_label.visible == true` AND tween_finished signal emitted
  - Edge cases: skip @ t = 1499ms(临界);连按 skip 多次 idempotent;skip @ t = 0ms(刚进入)

- **AC-2**: token 生命周期
  - Given: 进入 GAMEOVER_TRANSITION
  - When: state 切换至 ARCHIVE_VIEW(自然完成或 skip 后)
  - Then: `InputHandler.has_skippable(&"gameover_skip") == false`(R-SDF-5 跨系统守门)
  - Edge cases: skip 与自然完成同帧(由 Story 008 idempotent guard 处理)

- **AC-3**: skip 路径无 easing 变化
  - Given: skip @ t = 500ms
  - When: 跳末态
  - Then: 下一帧 modulate.a == 1.0(直接跳),不存在 t = 600/700/800ms 的中间帧

---

## Test Evidence

**Required evidence**: `tests/integration/kpi_ui/skippable_jump_last_frame_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 005(GAMEOVER Tween 主体);`#2 Input Handler` Story 004(skippable token registry)
- Unlocks: Story 008(skip 与 game_over_triggered 双触发 idempotent)

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 6 test 函数 in `tests/integration/kpi_ui/skippable_jump_last_frame_test.gd`
**Test Evidence**: `tests/integration/kpi_ui/skippable_jump_last_frame_test.gd` (102 行 / 6 tests / GdUnit4) — BLOCKING gate PASS
- AC-FUNC-07 skip 跳末态 → `test_skip_jumps_modulate_to_one` + `test_skip_shows_confirm_label` + `test_skip_emits_dismissal_finalized`
- token register/unregister via InputHandler API → `test_register_skippable_called_with_token` + `test_unregister_skippable_fires_after_skip`
- 不 fast-forward easing → `test_skip_kills_tween_no_fast_forward` (tween.kill() + 末态赋值,无 0.1s 加速段)

**Code Review**: APPROVED;`SKIPPABLE_TOKEN_GAMEOVER = &"gameover_skip"` StringName interned;register/unregister 经 Callable 注入;无 BLOCKING
**Deviations** (无):
**Tech debt**: None new
**API surface**: `register_skippable_callable / unregister_skippable_callable: Callable` + `_on_gameover_skipped()` + `SKIPPABLE_TOKEN_GAMEOVER` 常量
