# Story 010: 信号架构 + Save 持久化

> **Epic**: Tutorial / Onboarding System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/tutorial-onboarding-system.md`
**Requirement**: Rule 8(信号架构)+ Rule 9(Save 持久化整合)

**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix + ADR-0003 Save sub-schema
**ADR Decision Summary**: TutorialState own 4 信号:`tutorial_started` / `tutorial_completed` / `onboarding_hint_emitted` / `tutorial_state_changed(from, to)`;`#1 Save` Story 010(content-only)守门 tutorial sub-schema 仅触发白名单 unlock。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Feature Layer)**:
- Required: TutorialState 4 信号单点 emit;Save sub-schema 持久化
- Forbidden: 信号绕过 TutorialState 直接 emit(违反 owner 矩阵)
- Guardrail: 信号 dispatch ≤ 1 帧

---

## Acceptance Criteria

- [ ] TutorialState 4 信号定义 + emit 路径单点:
  - `tutorial_started` — 在 Day 1 启动 + tutorial_completed == false 时 emit
  - `tutorial_completed` — 在 Story 005 + 006 完成后 emit(Save fsync 完成)
  - `onboarding_hint_emitted(hint_id)` — 由 Story 004 inject_onboarding_hint() 触发
  - `tutorial_state_changed(from: State, to: State)` — 4 态切换时 emit
- [ ] Save sub-schema `meta.tutorial.tutorial_completed` 持久化(Story 006 已实施)
- [ ] 4 信号下游订阅者表(本 story 仅 emit owner 端,订阅由各下游 epic 实施)
- [ ] grep 校验:`tutorial_completed.emit` 仅 1 处(在 TutorialState.gd 内)

---

## Implementation Notes

*From GDD Rule 8 + Rule 9:*

```gdscript
# TutorialState.gd
signal tutorial_started
signal tutorial_completed
signal onboarding_hint_emitted(hint_id: String)
signal tutorial_state_changed(from: State, to: State)

func _set_state(new_state: State) -> void:
    var old := _state
    _state = new_state
    tutorial_state_changed.emit(old, new_state)
    if new_state == State.TUT_ACTIVE_DAY13:
        tutorial_started.emit()
    elif new_state == State.TUT_COMPLETED:
        tutorial_completed.emit()
```

下游订阅表(由各 epic 实施):
- `tutorial_started` → Analytics(Polish);UI 统计(可选)
- `tutorial_completed` → `#1 Save` queue_autosave(已 Story 006);UI 切回正常 onboarding-free state
- `onboarding_hint_emitted` → `#14 Card Play UI` flash overlay 渲染(per Story 004 链路)
- `tutorial_state_changed` → debug logger;`#11 Action Card` 取 fixed_hand_override 状态

---

## Out of Scope

- Story 005: M1 KPI 评语序列具体触发
- Story 006: Save sub-schema 实施
- 各下游订阅者实施(各 epic 自管)

---

## QA Test Cases

- **AC-1**: 4 信号定义
  - Given: TutorialState autoload
  - When: 反射 signals
  - Then: 4 个 signal 精确定义

- **AC-2**: 单点 emit 守门
  - Given: 全代码库 grep `tutorial_completed.emit`
  - When: 静态分析
  - Then: 仅 1 处命中(在 src/autoload/tutorial_state.gd)

- **AC-3**: tutorial_state_changed 序列
  - Given: TutorialState 进入 TUT_ACTIVE_DAY13 → TUT_M1_NPC_REVIEW → TUT_COMPLETED
  - When: 监听 tutorial_state_changed
  - Then: 信号 emit 3 次,from / to 对正确

---

## Test Evidence

**Required evidence**: `tests/integration/tutorial/signal_architecture_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001..006(状态机 + 各路径触发);`#1 Save` Story 010(content-only)
- Unlocks: 无(epic 整合验证)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED — AC-1 4 signals 定义 + 单点 emit / AC-2 Save sub-schema round-trip / AC-3 emit 路径仅 src/tutorial/tutorial_state.gd 命中 / AC-4 完整 run 序列 3 transitions,通过 8 test 函数覆盖
**Test Evidence**: `tests/integration/tutorial/signal_architecture_test.gd` (~135 行 / 8 tests / GdUnit4) — BLOCKING gate PASS;`tools/signal_ownership_lint.py` 注册 4 个 tutorial signal owner pair + 实跑通过(`signal_ownership_lint: OK`)
**Code Review**: APPROVED (lean autopilot inline);`signal_ownership_lint.py` 新增 4 行 owner 注册(tutorial_started / tutorial_completed / onboarding_hint_emitted / tutorial_state_changed → tutorial_state.gd);所有 emit 经 `_set_state` 单点 owner 路径;`MetaSaveState.tutorial` 已存在,Save 持久化复用;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent;下游订阅表(Analytics / UI / #14 flash overlay)按 ADR-0001 §1 各 epic 自管,不在本 story 实施
**Tech debt**: None new
**API surface**: TutorialState 4 signals(`tutorial_started` / `tutorial_completed` / `onboarding_hint_emitted(hint_id)` / `tutorial_state_changed(from, to)`)+ `signal_ownership_lint.py` 4 个 owner pair 注册 + `inject_onboarding_hint(hint_id: StringName)` API(Story 004 VS tier 占位)
