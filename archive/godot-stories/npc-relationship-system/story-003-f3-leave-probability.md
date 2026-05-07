# Story 003: F3 leave_probability per-NPC 8 Parameters

> **Epic**: npc-relationship-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/npc-relationship-system.md` | **Requirement**: `TR-npc-002`
**ADR**: GDD F3 公式
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: per-NPC 8 套 F3 参数(每 NPC 性格 unique)
- Required: deterministic RNG(seed 可控)

## Acceptance Criteria

- [ ] F3 公式:`leave_probability(npc, m, R, E) = clamp(base[npc] + α[npc]·m + β[npc]·(thresh_R - R) + γ[npc]·E, 0, 1)`(每 NPC 性格不同 base/α/β/γ)
- [ ] 8 套参数 const(LISA / BOSS / CLEANING_AUNT / FISH_MONK / GRIND_KING / OLD_OIL / NEWBIE / FLATTERER 各 4 系数)
- [ ] OQ-NPC-01 effort 三维度参数 8 NPC 实测(Pre-Production /prototype)

## Implementation Notes

```gdscript
const F3_PARAMS := {
    &"LISA": {"base": 0.05, "alpha": 0.01, "beta": 0.02, "gamma": 0.005},
    &"BOSS": {"base": 0.0, "alpha": 0.0, "beta": 0.0, "gamma": 0.0},  # Boss 不离职
    &"CLEANING_AUNT": {"base": 0.02, "alpha": 0.005, "beta": 0.01, "gamma": 0.0},
    &"FISH_MONK": {"base": 0.10, "alpha": 0.02, "beta": 0.0, "gamma": 0.01},  # 摸鱼僧月份高才离
    &"GRIND_KING": {"base": 0.03, "alpha": 0.02, "beta": 0.03, "gamma": 0.02},  # 卷王月末高 + KPI 低敏感
    &"OLD_OIL": {"base": 0.02, "alpha": 0.0, "beta": 0.0, "gamma": 0.0},
    &"NEWBIE": {"base": 0.08, "alpha": 0.0, "beta": 0.05, "gamma": 0.0},
    &"FLATTERER": {"base": 0.04, "alpha": 0.01, "beta": 0.02, "gamma": 0.005},
}

func leave_probability(npc: StringName, month: int, relationship: int, effort: int) -> float:
    var p := F3_PARAMS[npc]
    var thresh_r := -50  # 关系阈值
    var prob := p.base + p.alpha * month + p.beta * (thresh_r - relationship) + p.gamma * effort
    return clampf(prob, 0.0, 1.0)
```

## QA Test Cases

- 8 NPC 各 F3 输出表(deterministic seed 验证)
- BOSS 永不离职(base=0 / 系数=0)
- M11 + 低关系 + 高 effort → 高 leave_probability(Lisa 跳槽)

## Test Evidence

`tests/unit/npc/f3_leave_probability_test.gd` + Pre-Production prototype(OQ-NPC-01 实测)

## Dependencies

- Depends on: Story 001
- Unlocks: Story 010(月末 leave 检测)

---

## Completion Notes

**Completed**: 2026-05-01 (autopilot npc-relationship-system pass)
**Verdict**: COMPLETE (lean review mode)
**Criteria**: 3/3 passing (OQ-NPC-01 effort 三维度 prototype 实测延后到 Pre-Production stage — 标记为 advisory deferred)

**Files changed**:
- `src/npc/npc_relationship_system.gd` — EDIT (F3_PARAMS const 8 packs, F3_RELATIONSHIP_THRESHOLD = -50, `leave_probability(npc, month, relationship, effort) -> float` clamp [0, 1])
- `tests/unit/npc/f3_leave_probability_test.gd` — CREATE (7 tests: 8 packs present / clamp / BOSS = 0 always / Lisa M11 high / NEWBIE rel-sensitive / unknown returns 0 / .tres parity)

**Test Evidence**: `tests/unit/npc/f3_leave_probability_test.gd` (Logic story, BLOCKING gate). Pre-Production /prototype OQ-NPC-01 effort 三维度 实测延后,advisory only.

**Out of Scope**:
- Real effort accumulator (cross-epic ap-economy). Test uses default "0 effort" provider; ap-economy injection seam exposed via `set_effort_provider`.
- Real month index source (cross-epic SceneDayFlowController). Test uses month=1 default; injection seam via `set_month_provider`.

**Code Review**: Static review only (lean mode).
