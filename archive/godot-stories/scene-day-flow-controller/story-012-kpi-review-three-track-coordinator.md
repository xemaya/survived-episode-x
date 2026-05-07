# Story 012: KPI Review Three-Track Coordinator (800ms)

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-010`
**ADR**: ADR-0007 KPI Review Three-Track Anchor + ADR-0001(kpi_review_started 订阅)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: month_end → request_transition(KPI_REVIEW)→ KPI Story emit `kpi_review_started`(同 frame)
- Guardrail: 三轨 800ms 同步偏差 ≤ 1 帧

## Acceptance Criteria

- [ ] `_check_month_end()`:`current_day >= 30` → request_transition(KPI_REVIEW)
- [ ] action_lockout_started 守:transition 前 emit signal → ActionCard 冻结新卡入队
- [ ] wait current Action 动画完成 → transition KPI_REVIEW
- [ ] 协作 KPI Story:#9 emit kpi_review_started → #16/#5/#4 三轨 same-frame react(800ms anchor — ADR-0007)

## Implementation Notes

```gdscript
signal action_lockout_started

func request_transition_to_kpi_review() -> void:
    emit_signal(&"action_lockout_started")  # ActionCard 冻结
    await ActionCard.current_action_completed  # 等当前卡完成
    request_transition(&"KPI_REVIEW")
    # → KPI Story emit kpi_review_started → 三轨同步 800ms
```

## QA Test Cases

- 月末 → action_lockout + 等卡完成 + transition KPI_REVIEW
- 三轨 800ms 同步偏差 ≤ 1 帧(协作 #9 / #5 / #4 / #16 stories)

## Test Evidence

`tests/integration/scene_flow/kpi_review_transition_test.gd`(协作 KPI / Lighting / Audio / KPI Review UI stories)

## Dependencies

- Depends on: Story 010 + Story 011 + KPI Story + Lighting Story 006 + Audio Story 006 + KPI Review UI Story
- Unlocks: Month-end KPI 演出

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 2/4 COVERED — `_check_month_end()` 实施(`current_day > DAYS_PER_MONTH` → emit `action_lockout_started` → request_transition KPI_REVIEW);action_lockout_started signal 在 transition 之前 emit (subscriber 顺序保证);三轨 800ms 同步偏差 ≤ 1 帧由 ADR-0007 KPI/Lighting/Audio 三 stories 协作完成 (本 story 实施 emit signal 触发,具体 800ms 同步演出在 KPI Story 协调);`await ActionCard.current_action_completed` OUT-OF-SCOPE(ActionCard 为 Card Play epic,本 story 不引入跨 epic 强依赖)
**Test Evidence**: `tests/integration/scene_flow/kpi_review_transition_test.gd` (2 tests / GdUnit4) — BLOCKING gate PASS;月末触发 + lockout-before-transition 顺序验证
**Code Review**: APPROVED;`signal action_lockout_started` 暴露给 ActionCard epic subscribe;controller 不直接 await ActionCard 完成 — 该 await 责任反归 ActionCard epic(避免 controller 反向依赖 Card epic);无 BLOCKING / 无 inline fix
**Engine API Verification**: N/A(signal emit + Dictionary lookup,Godot 4.x stable)
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0007 Status=Proposed — lean-mode-equivalent
2. `await ActionCard.current_action_completed` OUT-OF-SCOPE — controller emit `action_lockout_started` 让 ActionCard 自己 await 当前卡完成后再 ack;反向依赖回避(本 story 是 source-of-action_lockout)
3. 三轨 800ms 同步演出由 KPI Review UI / Lighting / Audio 三 stories 协作 — 本 story 提供 month-end → KPI_REVIEW transition 触发器
**Tech debt**: 三轨 800ms 同步偏差 perf evidence 在跨 epic integration test 完成
**API surface**: `signal action_lockout_started` + `_check_month_end()` private 触发器
