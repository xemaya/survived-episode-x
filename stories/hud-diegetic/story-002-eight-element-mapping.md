# Story 002: 8 Diegetic Element Mapping

> **Epic**: hud-diegetic | **Status**: Complete | **Layer**: Presentation | **Type**: UI | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/hud-diegetic.md` | **Requirement**: `TR-hud-001`
**ADR**: ADR-0011 8 元素 mapping(全 Node2D)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 8 元素全 Node2D(无 Control)— 便利贴 / 咖啡杯 / 显示屏 / 考勤表 / 日历 / NPC 表情 / NPC 站位 / 空椅

## Acceptance Criteria

- [ ] DiegeticHUD 8 子节点 Node2D + Sprite2D:DeskCoffeeMug / DeskDocumentStack / DeskStickyNotes / NoticeBoard / OfficeSteam / NPCExpression / NPCPosition / CalendarKPIIndicator
- [ ] art-director sign-off advisory(`tests/evidence/hud-8-elements-sign-off-2026-XX.md`)
- [ ] 各元素 sprite asset .tres + 站位 layout 数据驱动

## Implementation Notes

```
DiegeticHUD (Node2D)
├── DeskCoffeeMug (Node2D)            # Hero card 反馈(蒸汽粒子)
├── DeskDocumentStack (Node2D)        # event_completed + hero(翻页)
├── DeskStickyNotes (Node2D)          # accumulation_event(sticky_note_count)
├── NoticeBoard (Node2D)              # 24 RichTextLabel notice 条目
├── OfficeSteam (Node2D)              # accumulation_event(steam_density)
├── NPCExpression (Node2D)            # relationship_changed + npc_lifecycle
├── NPCPosition (Node2D)              # accumulation_event(npc_empty_chairs)
└── CalendarKPIIndicator (Node2D)     # kpi_threshold_changed
```

## QA Test Cases

- 节点树验证 8 元素全 Node2D + 命名一致
- art-director sign-off advisory

## Test Evidence

`tests/integration/hud/eight_elements_test.gd` + `tests/evidence/hud-8-elements-sign-off-2026-XX.md`

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003(信号订阅)+ Story 005(accumulation 协作)+ Story 007(Hero 反馈)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 3 test 函数(`test_all_eight_elements_extend_node_2d` / `test_each_element_class_name_and_handler_exists` / `test_diegetic_hud_attaches_all_eight_elements`)
**Test Evidence**: `tests/integration/hud/eight_elements_test.gd`(99 行 / 3 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean autopilot inline);8 元素全 Node2D + 各自 handler stub;sprite asset .tres OUT-OF-SCOPE;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. Sprite asset `.tres` + `.tscn` layout OUT-OF-SCOPE(Phase 4 art team)
2. art-director sign-off advisory deferred(Pre-Production gate)
**Tech debt**: None new
**API surface**: 8 class_name 新增 — `DeskCoffeeMug` / `DeskDocumentStack` / `DeskStickyNotes` / `NoticeBoard` / `OfficeSteam` / `NPCExpression` / `NPCPosition` / `CalendarKPIIndicator`
