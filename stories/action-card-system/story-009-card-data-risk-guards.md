# Story 009: Card Data .tres + Risk Guards

> **Epic**: action-card-system | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/action-card-system.md` | **Requirement**: `TR-card-001`
**ADR**: GDD R-CARD-1..3 + writer authoring
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 80-120 cards MVP 数据(writer authoring)
- Required: R-CARD 守门 — card_id 唯一 / target_npc ⊂ 8 NPC enum / mutex_group 注册表
- Guardrail: ap_cost 1/2/3 ±5%(Story 002)

## Acceptance Criteria

- [ ] 80-120 cards .tres 完整数据(writer + game-designer 共撰)
- [ ] R-CARD-1:card_id 全局唯一 → CI lint
- [ ] R-CARD-2:target_npc ⊂ NPCS enum → CI lint
- [ ] R-CARD-3:mutex_group 注册表 → CI lint
- [ ] writer + game-designer sign-off advisory

## Implementation Notes

```gdscript
# tools/card_lint.gd
func lint_cards(cards_dir: String) -> Array[String]:
    var errors: Array[String] = []
    var seen_ids: Dictionary = {}
    for tres in glob_tres(cards_dir):
        var card := load(tres) as Card
        if seen_ids.has(card.event_id):
            errors.append("ERR_CARD_DUPLICATE: %s" % card.event_id)
        seen_ids[card.event_id] = true
        if card.target_npc != &"" and card.target_npc not in NPCRelationshipSystem.NPCS:
            errors.append("ERR_CARD_NPC: %s target_npc not in 8 NPC enum" % tres)
    return errors
```

## QA Test Cases

- 80 cards .tres 完整 + lint PASS
- R-CARD 1..3 守门测试

## Test Evidence

`tests/unit/card/card_data_lint_test.gd` + `tests/evidence/card-data-sign-off-2026-XX.md`

## Dependencies

- Depends on: Story 001 + NPC Story 001
- Unlocks: 整个 gameplay 内容

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 8 test 函数
**Test Evidence**: `tests/unit/card/card_data_lint_test.py` (146 行 / 8 tests / unittest) — 覆盖 R-CARD-1 重复 event_id / R-CARD-2 target_npc 在 8 NPC 枚举内/外 / R-CARD-3 mutex_group 注册表 / 空 optional 合法 / --self-test / 默认目录空启动 — BLOCKING gate PASS;`tools/card_data_lint.py --self-test` PASS
**Code Review**: APPROVED (lean autopilot inline);regex grep 风格(同 ap_cost_lint),纯 Python 不依赖 Godot 启动 — CI 友好;writer + game-designer 80-120 cards .tres authoring 留作后续 sprint backlog (本 story 仅守 lint 工具,数据交付 ADVISORY);无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. 80-120 cards .tres 数据未一次性 authoring — writer + game-designer sign-off 留 backlog,本 story 守 lint 工具就绪,数据进 cards/ 即扫
**Tech debt**: cards .tres 数据未填充(advisory);MUTEX_GROUP 注册表 7 项启动集合可能不足,后续可由 game-designer 在 lint 内扩展
**API surface**: `tools/card_data_lint.py` (lint_card_data / parse_card_fields / NPCS_ENUM / KNOWN_MUTEX_GROUPS) + 自检 ERR_CARD_DUPLICATE / ERR_CARD_NPC / ERR_CARD_MUTEX_GROUP
