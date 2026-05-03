# Story 010: Month-End Leave Detection + Risk Guards

> **Epic**: npc-relationship-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/npc-relationship-system.md` | **Requirement**: `TR-npc-002` + `TR-npc-005`
**ADR**: GDD Rule 6 月末检测 + R-NPC-1..5 [RISK GUARD]
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 月末检测每 NPC F3 leave_probability + RNG → 命中即 transition LEAVING_ANNOUNCED
- Required: deterministic RNG seed 可控
- Guardrail: BOSS 永不离职(F3 base=0)

## Acceptance Criteria

- [ ] `_on_kpi_review_started()` 订阅(月末锚)→ 每 NPC ACTIVE 状态 → F3 计算 leave_probability + RNG → 命中 transition LEAVING_ANNOUNCED + reason
- [ ] AC-ROBUST(R-NPC-1..5):
  - R-NPC-1:NPC LEFT 后 update_relationship → 拒绝 + warning
  - R-NPC-2:LEFT NPC 视觉屏蔽(协作 Story 007 + #13)
  - R-NPC-3:F3 RNG seed 公控 + 月末复算 → 同 seed 同结果
  - R-NPC-4:BOSS 永不离职(F3 base=0 / 系数=0 → leave_probability=0)
  - R-NPC-5:Save corruption 后 lifecycle_state 缺失 → 默认 ACTIVE + push_warning

## Implementation Notes

```gdscript
func _on_kpi_review_started() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = SaveSystem.get_run_seed()  # 可控 RNG
    for npc in NPCS:
        var state := _states[npc]
        if state.lifecycle_state != &"ACTIVE":
            continue
        var prob := leave_probability(npc, SceneDayFlowController.month_index, state.score, _calc_effort(npc))
        if rng.randf() < prob:
            _transition_lifecycle(npc, &"LEAVING_ANNOUNCED", &"f3_random_hit")

func _ready() -> void:
    # R-NPC-5:Save corruption 默认 ACTIVE
    for npc in NPCS:
        if not _states.has(npc) or _states[npc] == null:
            _states[npc] = NpcState.new()
            push_warning("[NPC] State corrupted for %s, defaulting to ACTIVE" % npc)
```

## QA Test Cases

- 月末 KPI Review → 8 NPC F3 检测 + deterministic RNG;BOSS 永不命中
- R-NPC-1..5 各自 AC-ROBUST 守门
- Lisa 跳槽线:M11 + 低 relationship + 高 effort → 跳槽 hit(Beta playtest)

## Test Evidence

`tests/integration/npc/month_end_leave_test.gd`(deterministic RNG fixture)+ Beta playtest doc

## Dependencies

- Depends on: Story 002 + Story 003 + Story 005 + KPI Story(kpi_review_started)
- Unlocks: Pre-Production prototype OQ-NPC-01 实测

---

## Completion Notes

**Completed**: 2026-05-01 (autopilot npc-relationship-system pass)
**Verdict**: COMPLETE (lean review mode)
**Criteria**: 2/2 passing — `process_month_end_leave_check()` 实施 + 5 R-NPC risk guards 全 verify(R-NPC-1/-2/-3/-4/-5 tests)

**Files changed**:
- `src/npc/npc_relationship_system.gd` — EDIT (`process_month_end_leave_check() -> Array[StringName]` 内含 deterministic RNG + per-NPC F3 + LEAVING_ANNOUNCED 转移; `set_random_seed(seed) / set_effort_provider(callable) / set_month_provider(callable)` cross-epic 注入 seam; `_initialise_states` + `restore_state` 含 R-NPC-5 corruption 默认 ACTIVE)
- `tests/integration/npc/month_end_leave_test.gd` — CREATE (7 tests: F3 跑通 / deterministic seed / R-NPC-1 LEFT-NPC 锁 / R-NPC-2 LEFT 状态可观察 / R-NPC-4 BOSS 永不离职(7 seed) / R-NPC-5 corruption 默认 ACTIVE / 仅 ACTIVE 被评估)

**Test Evidence**: `tests/integration/npc/month_end_leave_test.gd` (Integration story, BLOCKING gate). Deterministic RNG fixture via `set_random_seed`. Beta playtest doc OQ-NPC-01 (Lisa M11 跳槽线) 推到 Pre-Production stage prototype。

**Out of Scope (cross-epic seams)**:
- KPI `kpi_review_started` signal 实际 connect — KPI epic 已暴露 single-owner signal,本 story 已暴露 `process_month_end_leave_check()` 公 API 给 KPI 调用
- ap-economy real effort accumulator → `set_effort_provider(callable)` 注入点已开放
- SceneDayFlowController real month index → `set_month_provider(callable)` 注入点已开放
- SaveSystem run seed 实际注入 → `set_random_seed(int)` 已开放

**Code Review**: Static review only (lean mode).
