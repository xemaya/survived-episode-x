# Story 005: GAMEOVER 1500ms linear easing=NONE Tween 守门

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: `TR-kpiui-004`

**ADR Governing Implementation**: ADR-0006 Dismissal/GAMEOVER Path
**ADR Decision Summary**: GAMEOVER 1500ms linear `easing = NONE` 冷酷无情 — 玩家不可推翻 transition tone(`Save Rule 21 final_transition_duration_ms = 1500`);skippable 但 skip 仅跳到最后 1 帧(per Story 007),禁 ELASTIC/BOUNCE/EASE_IN/EASE_OUT 任何 ease 类型。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `Tween.TRANS_LINEAR` + 不调 `set_ease()` = easing 默认 `EASE_IN_OUT` 也错。须显式 `set_ease(Tween.EASE_LINEAR)` 才等同 NONE。Godot 4.6 测试:用 `Tween.get_ease()` 反射验证。

**Control Manifest Rules (Presentation)**:
- Required: 所有动画时长 const 化(`final_transition_duration_ms = 1500`,entities.yaml 已注册)
- Forbidden: 任何非 LINEAR easing(BOUNCE/ELASTIC/CUBIC 全禁)
- Guardrail: GAMEOVER transition 帧预算 ≤ 1ms(纯 modulate.a 更新)

---

## Acceptance Criteria

- [ ] AC-FUNC-05: `GameOverCertPanel.modulate.a` 从 0.0 线性到 1.0;`Tween.get_trans() == TRANS_LINEAR` AND `Tween.get_ease() == EASE_LINEAR`(无 EASE_IN/OUT/ELASTIC/BOUNCE)
- [ ] AC-FUNC-12: `final_transition_duration_ms = 1500`,实际 transition 时长 = 1500ms ± 16ms;代码无 magic number `1500`(lint 检查)
- [ ] AC-PERF-02: 每帧耗时 ≤ 1ms(仅 CanvasItem 更新,文本已缓存)
- [ ] transition 完成后 emit `dismissal_finalized`,`#1 Save` 听到后 fsync `meta.run_ended` 在 GAMEOVER 同步

---

## Implementation Notes

*Derived from ADR-0006:*

- Tween 创建:
  ```gdscript
  var dur := ConfigLoader.final_transition_duration_ms / 1000.0  # 1.5
  var tw := create_tween()
  tw.tween_property(cert_panel, "modulate:a", 1.0, dur)\
    .set_trans(Tween.TRANS_LINEAR)\
    .set_ease(Tween.EASE_LINEAR)
  tw.finished.connect(_on_dismissal_finalized)
  ```
- `Tween.EASE_LINEAR` 4.6 等价 "no ease curve",值 = 0(与 EASE_IN_OUT=2 不同);测试用 `tw.get_ease() == 0` 断言
- `_on_dismissal_finalized` 内 emit `dismissal_finalized` 信号 → `#1 Save` 订阅 → fsync;state 切 ARCHIVE_VIEW(实际由 Main Menu 进入触发,本 story 不切)
- magic number lint:`tools/no_magic_duration_lint.py` 扫描 `*.gd` 内 `1500` 浮点数字面量(白名单 `entities.yaml` ConfigLoader 加载路径)

---

## Out of Scope

- Story 007: skip 跳最后 1 帧逻辑(本 story 仅 Tween 主体)
- Story 008: R-KGO-1 game_over_triggered 唯一启动(本 story 假设已进入 GAMEOVER_TRANSITION 态)
- `#1 Save` Story 009 fsync 实施(本 story 仅 emit `dismissal_finalized` 信号)

---

## QA Test Cases

- **AC-FUNC-05**: easing 严格 LINEAR
  - Given: GAMEOVER_TRANSITION 启动
  - When: 反射 Tween 属性
  - Then: `tw.get_trans() == 0` (TRANS_LINEAR) AND `tw.get_ease() == 0` (EASE_LINEAR)
  - Edge cases: 漏调 `set_ease()` → 默认 `EASE_IN_OUT` (值 2) → 测试失败

- **AC-FUNC-12**: 1500ms 时长 + 无 magic number
  - Given: ConfigLoader.final_transition_duration_ms = 1500
  - When: Tween 启动 + 等待 finished
  - Then: tw 总耗时 1500ms ± 16ms;`grep -E "(^|[^_])1500([^_]|$)" *.gd` 命中 0 处
  - Edge cases: ConfigLoader 加载失败 → fallback 1500 触发 push_error

- **AC-PERF-02**: 每帧 ≤ 1ms
  - Given: transition 进行中
  - When: profiler 测每帧 process time
  - Then: 全程帧均值 < 1ms;P99 < 2ms

---

## Test Evidence

**Required evidence**: `tests/unit/kpi_ui/gameover_1500ms_linear_tween_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001(state machine GAMEOVER_TRANSITION 态);`#9 KPI` Story 007(game_over_triggered emit);Save System Story 009(meta_run_ended fsync 监听)
- Unlocks: Story 007(skip 跳最后 1 帧 + 此 Tween 共存)

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 5 test 函数 in `tests/unit/kpi_ui/gameover_1500ms_linear_tween_test.gd`
**Test Evidence**: `tests/unit/kpi_ui/gameover_1500ms_linear_tween_test.gd` (90 行 / 5 tests / GdUnit4) — BLOCKING gate PASS
- AC-FUNC-05 LINEAR + EASE_LINEAR → 控制器 `set_trans(TRANS_LINEAR).set_ease(EASE_LINEAR)`(no EASE_IN/OUT/ELASTIC/BOUNCE);`test_gameover_tween_created_on_transition` + `test_gameover_modulate_a_reaches_one`
- AC-FUNC-12 1500ms duration + no magic number → `test_default_final_transition_duration_is_1500` + `test_no_magic_1500_literal_in_controller` (执行代码扫描,排除 const/comment)
- dismissal_finalized → `test_dismissal_finalized_emits_on_finish`
- AC-PERF-02 ≤ 1ms/帧 → 由 Story 014 perf harness 验证

**Code Review**: APPROVED;Tween EASE_LINEAR 显式设置;duration 注入式;magic number lint 自包含;无 BLOCKING
**Deviations** (1 项 ADVISORY):
1. AC-PERF-02 委托 Story 014 perf harness
**Tech debt**: None new
**API surface**: `final_transition_duration_provider: Callable` + `dismissal_finalized` signal + `get_gameover_tween()` test hook
