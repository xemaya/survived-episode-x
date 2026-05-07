# Story 007: hero_card_played 3-Element Reaction

> **Epic**: action-card-system | **Status**: Complete | **Layer**: Feature | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/action-card-system.md` | **Requirement**: `TR-card-005`
**ADR**: ADR-0008 Visual Boundary Pillar 4 vs Mute Parity + ADR-0011 HUD Diegetic
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 三 element 反馈 — DeskCoffeeMug 蒸汽粒子 + DeskDocumentStack 翻页 + NPCExpression raised eyebrow + #5 brightness +0.05
- Forbidden: 5 类 Pillar 4 视觉(金光/sparkle/烟花/彩虹/鸡汤)

## Acceptance Criteria

- [ ] is_hero=true → emit hero_card_played → 协作:
  - #13 HUD Story:DeskCoffeeMug 蒸汽粒子(0.5s)+ DeskDocumentStack 翻页(0.3s)+ NPCExpression eyebrow flash(0.5s)
  - #5 Lighting Story 009:brightness lift +0.05 0.5s
  - #4 Audio:`sfx_hero_card_played` Bus=SFX +3dB
- [ ] mute_visual_parity:全 mute(三 Bus -60)→ 三 element 反馈仍触发(信号物理音频解耦)
- [ ] AC-FUNC-Pillar4:5 类禁视觉零出现(visual lint)

## Implementation Notes

参 ADR-0008 §3 + ADR-0011:

```gdscript
# 由 #11 emit hero_card_played
# 4 subscribers 各自实施(不在 #11 内)

# 在 #13 HUD Story:
func _on_hero_card_played(_card_id: StringName) -> void:
    desk_coffee_mug.play_steam_particle()  # 0.5s
    desk_document_stack.play_page_flip()   # 0.3s
    npc_expression_node.flash_raised_eyebrow()  # 0.5s

# 在 #5 Lighting Story 009:
func _on_hero_card_played(_card_id: StringName) -> void:
    _brightness_lift_tween()  # +0.05 0.5s
```

## QA Test Cases

- emit hero_card_played → 3 element + brightness lift + SFX 协作触发
- 全 mute 模式仍触发 3 element + brightness lift(信号解耦)
- 5 类 Pillar 4 视觉零出现(visual lint 守门)

## Test Evidence

`tests/integration/card/hero_card_reaction_test.gd`(协作 #13 + #5 + #4 stories)+ `tests/evidence/hero-card-reaction-mute-2026-XX.png`(visual sign-off)

## Dependencies

- Depends on: Story 006 + Lighting Story 009 + HUD Story + Audio Story 011
- Unlocks: mute_visual_parity 完整守

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 5 test 函数
**Test Evidence**: `tests/integration/card/hero_card_reaction_test.gd` (132 行 / 5 tests / GdUnit4) — 覆盖 emit payload / 非 hero 不 emit / mute_visual_parity (audio bus mute 不影响 emit) / Pillar 4 5 类禁视觉源码扫 (golden_glow/sparkle/firework/rainbow/chicken_soup) / emit 顺序 (card_played → hero_card_played 同帧固定) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);本 epic 仅 emit hero_card_played,4 subscribers (HUD #13 Story 007 三 element / Lighting #5 Story 009 brightness +0.05 / Audio #4 Story 011 SFX) 已在 cross-epic 落地 (与 Manifest 一致);信号物理音频解耦守 mute_visual_parity;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. visual lint 由现有 `tools/pillar4_visual_lint.py` 维护,本 story 测试通过源码 token scan 补充验证,与 Pillar 4 lint 工具协同 — 无重复
**Tech debt**: None new
**API surface**: `signal hero_card_played(card_id: StringName)` (上 Story 006 owner) + try_play_card 内部 emit 顺序契约
