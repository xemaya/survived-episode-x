# Story 007: Hero Card 3-Element Feedback Implementation

> **Epic**: hud-diegetic | **Status**: Complete | **Layer**: Presentation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/hud-diegetic.md` | **Requirement**: `TR-hud-001` + `TR-hud-003`
**ADR**: ADR-0008 Visual Boundary Pillar 4 + ADR-0011 三 element 反馈
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 三 element 反馈 — 咖啡蒸汽 0.5s + 文件翻页 0.3s + NPC raised eyebrow 0.5s
- Forbidden: 5 类 Pillar 4 视觉(金光/sparkle/烟花/彩虹/鸡汤)

## Acceptance Criteria

- [ ] DeskCoffeeMug `_on_hero_card_played(card_id)` → CPUParticles2D emit 1 蒸汽粒子(0.5s)
- [ ] DeskDocumentStack `_on_hero_card_played(card_id)` → AnimationPlayer 翻页(0.3s)
- [ ] NPCExpression `_on_hero_card_played(card_id)` → flash raised eyebrow frame(0.5s)+ return
- [ ] mute_visual_parity:全 mute 模式仍触发 3 element(信号物理音频解耦)
- [ ] visual lint:5 类禁视觉零出现(art-director sign-off advisory)

## Implementation Notes

```gdscript
# desk_coffee_mug.gd
@onready var steam_particle: CPUParticles2D = $SteamParticle

func _on_hero_card_played(_card_id: StringName) -> void:
    steam_particle.emitting = false
    steam_particle.amount = 1
    steam_particle.lifetime = 0.5
    steam_particle.emitting = true

# desk_document_stack.gd
@onready var page_flip_anim: AnimationPlayer = $PageFlipAnim

func _on_hero_card_played(_card_id: StringName) -> void:
    page_flip_anim.play(&"flip", -1, 0.3 / page_flip_anim.get_animation(&"flip").length)

# npc_expression.gd
func _on_hero_card_played(_card_id: StringName) -> void:
    var tween := create_tween()
    tween.tween_callback(func(): set_frame(EYEBROW_RAISED_FRAME))
    tween.tween_interval(0.5)
    tween.tween_callback(func(): set_frame(NEUTRAL_FRAME))
```

## QA Test Cases

- emit hero_card_played → 3 element 同帧触发(0.5s / 0.3s / 0.5s timing)
- 全 mute 模式仍触发 3 element + brightness lift(协作 Lighting Story 009)
- visual diff:5 类禁视觉零出现

## Test Evidence

`tests/integration/hud/hero_card_three_element_test.gd` + `tests/evidence/hero-card-3-element-2026-XX.md`

## Dependencies

- Depends on: Story 002 + Action Card Story 006/007 + Lighting Story 009
- Unlocks: mute_visual_parity 完整守门

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 5/5 COVERED via 7 test 函数(`test_coffee_mug_emits_one_steam_burst` / `test_document_stack_plays_flip_at_correct_speed` / `test_document_stack_no_animplayer_no_crash` / `test_npc_expression_raises_eyebrow_then_restores` / `test_npc_expression_skips_left_variant` / `test_dispatch_hero_card_routes_to_three_elements` / `test_visual_parity_independent_of_audio`)
**Test Evidence**: `tests/integration/hud/hero_card_three_element_test.gd`(155 行 / 7 tests / GdUnit4)+ `tests/evidence/hero-card-3-element-2026-05.md`(advisory)— BLOCKING gate PASS
**Code Review**: APPROVED(lean autopilot inline);3 元素 timing 常量 lock(`STEAM_BURST_DURATION_SECONDS=0.5` / `PAGE_FLIP_DURATION_SECONDS=0.3` / `HERO_EYEBROW_DURATION_SECONDS=0.5`);mute_visual_parity 结构断言(无 AudioStreamPlayer 路径);5 Pillar-4 禁视觉 evidence MD 备案;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. art-director sign-off advisory deferred(Phase 4 sprite production)
2. visual lint(5 类禁视觉零出现)依赖 Lighting Story 008 既存工具
**Tech debt**: None new
**API surface**: `DeskCoffeeMug._on_hero_card_played` + `DeskDocumentStack._on_hero_card_played` + `NPCExpression._on_hero_card_played` + `set_steam_particle_for_test` / `set_page_flip_anim_for_test` / `set_frame_handler_for_test`
