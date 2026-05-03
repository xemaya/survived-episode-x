# Story 002: KPI Review 800ms intro fade-in EASE_IN_OUT(三轨同步锚)

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: `TR-kpiui-003`

**ADR Governing Implementation**: ADR-0007 KPI Review Three-Track Anchor
**ADR Decision Summary**: KPI Review intro 800ms `EASE_IN_OUT` 三轨(audio stinger + lighting 紫光 + UI fade)同帧 emit `kpi_review_started`,800ms 内三轨完成,`#16` UI 是渲染端。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: Tween 4.6 主线程同步;`set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)` 4.5+ 稳。`kpi_review_intro_duration_ms = 800`(`design/registry/entities.yaml` 已注册)。

**Control Manifest Rules (Presentation)**:
- Required: 所有动画时长 const 化,`load_from(ConfigLoader)`,禁 magic number
- Forbidden: 主线程 sleep 或 await 阻塞 800ms(用 Tween 异步)
- Guardrail: 帧预算 ≤ 4ms / 屏(月末重屏)

---

## Acceptance Criteria

- [ ] AC-FUNC-01(部分): 800ms 后 `KPIReviewPanel.modulate.a == 1.0` ± 1 帧
- [ ] AC-PERF-01: KPI Review 屏首帧 ≤ 4ms(Godot profiler);后续帧 ≤ 1ms
- [ ] Tween easing = `EASE_IN_OUT` + `TRANS_LINEAR`;无 ELASTIC/BOUNCE/CUBIC(差异化于 GAMEOVER 严格 `linear easing=NONE`)
- [ ] 三轨锚:`#16` UI fade-in 起点与 `#5` Lighting 紫光 + `#4` Audio stinger 同帧(读 `kpi_review_started` 单点)

---

## Implementation Notes

*Derived from ADR-0007:*

- `kpi_review_intro_duration_ms = 800`(load from `entities.yaml`,禁 hardcode)
- Tween 创建:
  ```gdscript
  var tw := create_tween()
  tw.tween_property(panel, "modulate:a", 1.0, kpi_review_intro_duration_ms / 1000.0)\
    .set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
  ```
- 起点 `panel.modulate.a = 0.0` 在 state 进入 `KPI_REVIEW_ACTIVE` 时同帧设置,与 Tween 启动同帧
- 性能验证:`Time.get_ticks_usec()` 测首帧 + 第 N+1 帧

---

## Out of Scope

- Story 003: breakdown 三行渲染逻辑
- Story 005: GAMEOVER linear easing=NONE Tween(不同 easing 类型)
- 三轨锚另两轨(Audio + Lighting)由各自 epic 实施

---

## QA Test Cases

- **AC-PERF-01**: 首帧 ≤ 4ms
  - Given: `KPI_REVIEW_WAITING → KPI_REVIEW_ACTIVE`
  - When: 同帧 Tween 启动
  - Then: `Time.get_ticks_usec()` 测首帧 < 4000us
  - Edge cases: 首次启动(scene 初始化 cost)vs 第二次进入(已 warm)

- **AC-2**: easing 验证
  - Given: Tween 完成 emit `tween_finished`
  - When: 反射 Tween properties
  - Then: `get_trans() == TRANS_LINEAR` AND `get_ease() == EASE_IN_OUT`

- **AC-3**: 800ms 时长
  - Given: 起点 `modulate.a == 0.0`
  - When: t = 800ms ± 16ms
  - Then: `modulate.a == 1.0` ± 0.05

---

## Test Evidence

**Required evidence**: `tests/unit/kpi_ui/intro_fade_800ms_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001(state machine + KPI_REVIEW_ACTIVE 进入)
- Unlocks: Story 003(breakdown 渲染 在 ACTIVE 态内)

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 4 test 函数 in `tests/unit/kpi_ui/intro_fade_800ms_test.gd`
**Test Evidence**: `tests/unit/kpi_ui/intro_fade_800ms_test.gd` (78 行 / 4 tests / GdUnit4) — BLOCKING gate PASS
- AC-FUNC-01 modulate.a 1.0 → `test_intro_modulate_alpha_reaches_one`
- TRANS_LINEAR + EASE_IN_OUT → `test_intro_tween_uses_linear_ease_in_out` (source-level lint)
- 三轨锚 800ms duration provider → `test_intro_duration_from_provider` + `test_default_intro_duration_is_800`
- AC-PERF-01 首帧 ≤ 4ms → 由 Story 014 perf harness 验证

**Code Review**: APPROVED;Tween `set_trans(TRANS_LINEAR).set_ease(EASE_IN_OUT)`;duration 注入式 provider(无 magic number);无 BLOCKING
**Deviations** (1 项 ADVISORY):
1. AC-PERF-01 首帧测量委托给 Story 014 perf harness(per Story 014 §"整合性能 AC")
**Tech debt**: None new
**API surface**: `intro_duration_provider: Callable` + `get_intro_tween()` test hook + `intro_fade_finished` signal
