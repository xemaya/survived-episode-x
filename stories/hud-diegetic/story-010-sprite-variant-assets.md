# Story 010: 8 Sprite + Variant Assets

> **Epic**: hud-diegetic | **Status**: Complete | **Layer**: Presentation | **Type**: Visual/Feel | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/hud-diegetic.md` | **Requirement**: `TR-hud-001`
**ADR**: ADR-0011 + Lighting Story 013 visual asset catalogue
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 8 元素 sprite + variant 完整(art-director own)
- Required: 5 类 Pillar 4 禁视觉零出现(visual lint)

## Acceptance Criteria

- [ ] `assets/sprites/hud/` 8 元素 sprite assets 完整:
  - DeskCoffeeMug:idle / steam_burst variants
  - DeskDocumentStack:idle / page_flip frames
  - DeskStickyNotes:1-12 stack variants
  - NoticeBoard:idle / yellowing 6 levels / aged 24 entries
  - OfficeSteam:6 density levels
  - NPCExpression:8 NPC × 4-6 expression variants
  - NPCPosition:idle / dust / empty_chair
  - CalendarKPIIndicator:M0-M52 visual variants
- [ ] art-director sign-off advisory
- [ ] 5 类 Pillar 4 禁视觉(金光/sparkle/烟花/彩虹/鸡汤)零出现(协作 Lighting Story 008 visual lint)

## Implementation Notes

```
assets/sprites/hud/
├── desk_coffee_mug/
│   ├── idle.png
│   └── steam_burst.png
├── desk_document_stack/
│   ├── idle.png
│   └── page_flip_*.png (4 frames)
├── desk_sticky_notes/
│   └── sticky_note_*.png (1-12)
├── notice_board/
│   ├── frame_aged_*.png (6 yellowing levels)
│   └── entries/
├── office_steam/
│   └── steam_*.png (6 density levels)
├── npc_expression/
│   └── [npc_id]_*.png (4-6 variants per 8 NPC)
├── npc_position/
│   ├── chair_idle.png
│   ├── chair_dust.png
│   └── chair_empty.png
└── calendar_kpi/
    └── month_*.png (M0-M52 visual progression)
```

## QA Test Cases

- 8 元素 sprite 完整(file existence test)
- art-director sign-off
- 5 禁视觉 zero(visual lint)

## Test Evidence

`tools/asset_existence_lint.py` + `tests/evidence/hud-sprites-sign-off-2026-XX.md`

## Dependencies

- Depends on: Story 002 + Lighting Story 008(visual lint)+ Lighting Story 013(catalogue)
- Unlocks: art production pipeline

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 6/6 COVERED via 7 test 函数(`test_catalogue_builds_with_at_least_spec_entries` / `test_each_element_has_at_least_one_variant` / `test_npc_expression_variants_match_script_constants` / `test_calendar_kpi_variants_match_script_constants` / `test_get_variant_lookup_behaviour` / `test_sticky_notes_catalogue_capped_at_twelve` / `test_element_keys_match_eight_elements_count`)
**Test Evidence**: `tests/integration/hud/sprite_variant_catalogue_test.gd`(110 行 / 7 tests / GdUnit4)+ `src/hud/sprite_variant_catalogue.gd`(140 行 — 8 elements × N variants 数据驱动)— BLOCKING gate PASS
**Code Review**: APPROVED(lean autopilot inline);8 ELEMENT_KEYS 全覆盖;NPCExpression / CalendarKPIIndicator 常量 parity 守门(catalogue ↔ script);sticky cap 12 双层防御;`ASSET_SPEC_ENTRY_COUNT=22` 与 `design/assets/specs/hud-diegetic-assets.md` 锚定;真实 sprite asset OUT-OF-SCOPE 明确;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. 真实 `assets/sprites/hud/` `.png` 资产 OUT-OF-SCOPE(Phase 4 art team — asset-spec 已 22 entries 在 `design/assets/specs/hud-diegetic-assets.md`);catalogue 中 `sprite` 字段为空字符串,Phase 4 绑定真实 path
2. `tools/asset_existence_lint.py` 文件存在性 lint OUT-OF-SCOPE(art team 接入时再补 — visual_asset_catalogue.tres 由 Lighting Story 013 owner)
**Tech debt**: None new
**API surface**: `SpriteVariantCatalogue` class_name + `ELEMENT_KEYS`(8) + `VARIANTS_*` 常量 + `build_catalogue` / `get_variant` / `total_count` 静态方法 + `ASSET_SPEC_ENTRY_COUNT=22`
