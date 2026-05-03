# Story 006: F5 decision_space Formula

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-007`
**ADR**: GDD F5(决策熵 — 每张可选卡的不同 effect 数量)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: F5 输出 ≥ 2 维(防 Pillar 1 dominant strategy)
- Guardrail: research H1 决策熵假设(AC-FUNC-08 Beta tier playtest)

## Acceptance Criteria

- [ ] F5 公式:`decision_space = unique_card_effects_in_hand / total_cards_in_hand`(每手牌的"决策维度数")
- [ ] H1 假设(AC-FUNC-08 Beta 推迟):decision_space < 2 → P1 dominant strategy 风险 → playtest H1 决策熵实测
- [ ] H2 后悔感 + H5 玩家聚类(AC-FUNC-09 Beta 推迟)

## Implementation Notes

```gdscript
func decision_space(hand: Array[StringName]) -> float:
    if hand.is_empty():
        return 0.0
    var unique_effects: Dictionary = {}
    for card_id in hand:
        var card := ActionCard.get_card_def(card_id)
        for effect in card.effects:
            unique_effects[effect.get_class()] = true
    return float(unique_effects.size()) / float(hand.size())
```

## QA Test Cases

- hand 4 张 + 2 类 effect → decision_space = 0.5
- hand 4 张全同 effect → decision_space = 0.25
- H1 playtest(Beta tier 推迟):AC-FUNC-08 决策熵 ≥ 2(防 P1 dominant)

## Test Evidence

`tests/unit/ap/f5_decision_space_test.gd` + Beta playtest doc

## Dependencies

- Depends on: Action Card Story 001(card schema)
- Unlocks: Beta tier playtest H1/H2/H5

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED (H2/H5 Beta-tier playtest 推迟 — story 已注明) via 5 test 函数 (`tests/unit/ap/f5_decision_space_test.gd`)
**Test Evidence**: `tests/unit/ap/f5_decision_space_test.gd` (~110 行 / 5 tests / GdUnit4) — BLOCKING gate PASS;含 empty/2-class-of-4/all-same-class/all-unique/no-effects 5 case
**Code Review**: APPROVED (lean-mode autopilot inline);F5 = unique-effect-classes / hand-size + schema-agnostic (用 Object.get(&"effects") 不硬绑 ActionCard schema 演化) + @noeffect 占位防 under-report + degenerate empty-hand → 0.0
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ActionCard 尚未实现 → F5 schema-agnostic 设计 (cross-epic graceful) — 当 ActionCard 落地 effects array,F5 自动适配;无 OUT-OF-SCOPE 改动
2. H1/H2/H5 playtest 守门推迟 (Beta tier) — 文档已 explicit;ADR Status=Proposed
**Tech debt**: None new
**API surface**: static decision_space(hand: Array) -> float
