# Story 004: Hand Panel + Card Render

> **Epic**: card-play-dialogue-ui | **Status**: Complete | **Layer**: Presentation | **Type**: UI | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/card-play-dialogue-ui.md` | **Requirement**: `TR-cardui-002`
**ADR**: 协作 ActionCard Story 001 Card schema
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: HandPanel 显示玩家当前手牌(数量 = 3-6 枚)
- Required: Card UI 显示 ap_cost / target_npc / is_hero icon

## Acceptance Criteria

- [ ] `HandPanel: HBoxContainer` + `CardButton` 子节点(每张卡 1 button)
- [ ] CardButton 显示:Card name + ap_cost icon + target_npc avatar(若有)+ is_hero star(若 true)
- [ ] state-aware:CardState.PLAYABLE → enabled;DISABLED → grey;PLAYED → 临时高亮 0.3s + queue_free
- [ ] dual-focus 4.6:diegetic UI focus 环可见(`#C8963C` 2px;协作 ADR-0014)

## Implementation Notes

```gdscript
class_name CardButton extends Button

@export var card_id: StringName

func _ready() -> void:
    var card: Card = ActionCardSystem.get_card(card_id)
    text = card.name  # 通过 Loc tr() 取
    $ApIcon.text = "AP %d" % card.ap_cost
    $TargetAvatar.visible = (card.target_npc != &"")
    $HeroStar.visible = card.is_hero
    # focus_entered 守(协作 Input Story 003)
    focus_entered.connect(_on_focus_entered)

func _on_focus_entered() -> void:
    # 显示焦点环 #C8963C 2px
    show_focus_ring()

func _pressed() -> void:
    if ActionCardSystem.try_play_card(card_id):
        _highlight_played()
```

## QA Test Cases

- HandPanel 渲染 3-6 卡;PLAYABLE / DISABLED / PLAYED 状态视觉差异
- focus_entered 触发 → 焦点环可见

## Test Evidence

`tests/integration/card_ui/hand_panel_test.gd` + `tests/evidence/hand-panel-2026-XX.md`

## Dependencies

- Depends on: Story 001 + ActionCard Story 001 + Input Story 003
- Unlocks: Pre-Production playtest 完整 gameplay loop

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 7 test 函数(3-card / 6-card 渲染 + label fields {AP, target, ★} + PLAYABLE/DISABLED 状态视觉 + try_play press → emit + focus_entered/exited 焦点环)
**Test Evidence**: `tests/integration/card_ui/hand_panel_test.gd` (7 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`HandPanel extends HBoxContainer` + `CardButton extends Button` 解耦;DI Callable seam(`try_play_card_callable` / `tr_callable`)+ duck-type bind 兼容 Card 资源 / Dictionary;ADR-0014 焦点环 #C8963C 2px via `_draw()` override(单测可观测);PLAYED → 0.3s timer + queue_free;无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ActionCardSystem autoload 未着陆(ActionCard epic 仍 in-flight)— `try_play_card_callable` DI 让本 story 独立可测
2. .tscn 资产 OUT-OF-SCOPE (UI team Phase 4)— 文本 fallback (`Name [AP X] → npc ★`) 替代图标
**Tech debt**: None new
**API surface**: `class_name HandPanel extends HBoxContainer` + `render_hand(cards: Array)` + `signal card_play_requested / card_played_resolved`;`class_name CardButton extends Button` + `bind_card(entry)` + `is_focus_ring_visible()`
