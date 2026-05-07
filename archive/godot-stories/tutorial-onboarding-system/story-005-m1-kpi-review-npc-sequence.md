# Story 005: M1 KPI 评语序列(老油条 1500ms + Lisa 800ms 条件触发)

> **Epic**: Tutorial / Onboarding System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/tutorial-onboarding-system.md`
**Requirement**: `TR-tutorial-003`(M1 评语部分)+ Rule 4

**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix(`#16 KPI Review` Story 001 状态机内触发)
**ADR Decision Summary**: M1 月末 `kpi_threshold_changed` emit 后 `1500 ± 200ms`,老油条 `NPC.OLD_OIL.M1_REVIEW` flash 事件触发;条件 `lisa.relationship_score >= 20` 时,老油条 flash 后 `800 ± 200ms` Lisa flash 触发;否则 Lisa 不触发,`tutorial_completed = true` 仍在老油条 flash 后写入。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `Timer` 4.6 已稳;`Time.get_ticks_msec()` 测量。

**Control Manifest Rules (Feature Layer)**:
- Required: 序列触发由 TutorialState own,串联走 Timer.timeout 链
- Forbidden: 直接调 `#14` flash 渲染(违反 layer — 走 EventScript signal 路径)
- Guardrail: 老油条 flash 1500ms ± 200ms;Lisa 800ms ± 200ms

---

## Acceptance Criteria

- [ ] AC-FUNC-05: M1 月末 `kpi_threshold_changed` emit 后 `1500 ± 200ms`,老油条 `NPC.OLD_OIL.M1_REVIEW` flash 事件触发
- [ ] AC-FUNC-06: M1 月末 `lisa.relationship_score >= 20` 时,老油条 flash 后 `800 ± 200ms`,Lisa flash 触发;`lisa.relationship_score < 20` 时,Lisa flash 不触发,但 `tutorial_completed = true` 仍写入(per AC-FUNC-07)
- [ ] AC-RULE-02: M1 月末 `game_over_triggered` 在 `kpi_threshold_changed` 之前 emit 时,M1 NPC 评论不触发(R-TUT-1 GAME OVER 路径守门)
- [ ] state 切 `TUT_M1_NPC_REVIEW` 在 `kpi_threshold_changed` 触发时

---

## Implementation Notes

*From GDD Rule 4 + AC-FUNC-05/06:*

```gdscript
# TutorialState.gd
const M1_OLD_OIL_DELAY_MS := 1500
const M1_LISA_DELAY_AFTER_OLD_OIL_MS := 800
const LISA_RELATIONSHIP_THRESHOLD := 20

func _on_kpi_threshold_changed(...) -> void:
    if KPI.current_month != 1: return
    if _state == State.TUT_COMPLETED: return
    if EventScript.game_over_pending: return  # AC-RULE-02 守门
    _state = State.TUT_M1_NPC_REVIEW
    await get_tree().create_timer(M1_OLD_OIL_DELAY_MS / 1000.0).timeout
    EventScript.trigger_event("NPC.OLD_OIL.M1_REVIEW")  # 老油条 flash
    if NPC.relationship_score("lisa") >= LISA_RELATIONSHIP_THRESHOLD:
        await get_tree().create_timer(M1_LISA_DELAY_AFTER_OLD_OIL_MS / 1000.0).timeout
        EventScript.trigger_event("NPC.LISA.M1_REVIEW")  # Lisa flash
    SaveSystem.write_tutorial_completed(true)  # Story 006
    _state = State.TUT_COMPLETED
```

注意:`game_over_pending` flag 由 `#9 KPI` Story 005 own — 当月末 detect game over 但尚未 dispatch GAMEOVER sub-mode 时为 true;若此时已 emit `game_over_triggered`,则跳过整个评语序列。

---

## Out of Scope

- Story 006: tutorial_completed Save 持久化(本 story 仅触发写入,Story 006 实施 content-only 守门)
- `#16 KPI Review UI` Story 008(R-KGO-1 game_over 守门)
- `#10 Event Script` Story 003(trigger_event 主体)
- `#14 Card Play UI` flash 渲染

---

## QA Test Cases

- **AC-FUNC-05**: 1500ms 老油条
  - Given: KPI.current_month == 1,emit kpi_threshold_changed
  - When: 测时间 t = emit + 1500ms
  - Then: NPC.OLD_OIL.M1_REVIEW event 已 emit,`#14` flash overlay 可见(误差 ± 200ms)
  - Edge cases: KPI.current_month == 2 → 序列不触发

- **AC-FUNC-06**: Lisa 条件触发
  - Given: lisa.relationship_score == 25(≥ 20)
  - When: 老油条 flash 完成后 + 800ms
  - Then: NPC.LISA.M1_REVIEW event emit;tutorial_completed 在 Lisa flash 后写入
  - Edge cases: relationship_score == 19 → Lisa 不 flash;tutorial_completed 仍在老油条 flash 后写入

- **AC-RULE-02**: GAME OVER 路径守门
  - Given: M1 月末 game_over_triggered 先 emit(R-KPI-4 路径变体)
  - When: kpi_threshold_changed 之后 TutorialState 检查
  - Then: 序列不触发;_state 转 TUT_INACTIVE(per Rule 4)

---

## Test Evidence

**Required evidence**: `tests/integration/tutorial/m1_kpi_review_npc_sequence_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001;`#9 KPI` Story 010(kpi_threshold_changed 信号顺序);`#8 NPC Relationship` Story 005(relationship_changed signal);`#10 Event Script` Story 003(abstract event effect)+ `#14 Card Play UI` flash overlay 实施
- Unlocks: Story 006(tutorial_completed 写入)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED — AC-FUNC-05 老油条 1500ms / AC-FUNC-06 Lisa 800ms 条件触发 / AC-RULE-02 game_over_pending 守门 / state TUT_M1_NPC_REVIEW 切换,通过 8 test 函数覆盖
**Test Evidence**: `tests/integration/tutorial/m1_kpi_review_npc_sequence_test.gd` (~165 行 / 8 tests / GdUnit4) — BLOCKING gate PASS;timer-driven coroutine via `_run_m1_sequence()` 真实 await(无 mock 时序)
**Code Review**: APPROVED (lean autopilot inline);Timer chain 严守 1500/800ms ADR-0001 anchor;AC-RULE-02 在 1500ms 等待中再次 re-check `game_over_pending` 防 R-KPI-4 路径变体;`_m1_sequence_dispatched` idempotency 守门;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent;实际 timing tolerance ±200ms 通过 fixture mode 可测但 production playtest 在 VS milestone 验收
**Tech debt**: None new
**API surface**: `TutorialState._on_kpi_threshold_changed()` (KPI signal subscriber) + `_run_m1_sequence()` coroutine + `m1_sequence_finished` 诊断 signal + 4 个时序常量(M1_OLD_OIL_DELAY_MS / M1_LISA_DELAY_AFTER_OLD_OIL_MS / LISA_RELATIONSHIP_THRESHOLD)
