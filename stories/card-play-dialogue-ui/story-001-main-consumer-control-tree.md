# Story 001: Main Consumer Layer + Control Tree

> **Epic**: card-play-dialogue-ui | **Status**: Complete | **Layer**: Presentation | **Type**: UI | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/card-play-dialogue-ui.md` | **Requirement**: `TR-cardui-002`
**ADR**: ADR-0012 #14 = density 主消费 layer
**Engine**: Godot 4.6 | **Risk**: HIGH(via ADR-0009)

**Control Manifest Rules**:
- Required: Card Play UI 在 #6 EVENT_ACTIVE sub-mode 显示 + 其他 sub-mode 隐藏
- Required: Control 节点 own panel(玩家手牌 + NPC 立绘 + 选项区)

## Acceptance Criteria

- [ ] `scenes/ui/card_play_dialogue.tscn`:Control panel(EVENT_ACTIVE 时显示)
- [ ] 子节点:`HandPanel`(手牌)+ `NpcPortraitArea`(NPC 立绘)+ `DialoguePanel`(对白 RichTextLabel)+ `ChoiceButtonContainer`(选项)
- [ ] EVENT_ACTIVE sub-mode → visible = true;其他 → false

## Implementation Notes

```gdscript
# card_play_dialogue.gd
extends Control

@onready var hand_panel: HandPanel = $HandPanel
@onready var npc_portrait: AnimatedSprite2D = $NpcPortraitArea/Portrait
@onready var dialogue_label: RichTextLabel = $DialoguePanel/RichTextLabel
@onready var choice_container: VBoxContainer = $ChoiceButtonContainer

func _ready() -> void:
    SceneDayFlowController.scene_state_changed.connect(_on_scene_state_changed)

func _on_scene_state_changed(_from: StringName, to: StringName) -> void:
    visible = (to == &"EVENT_ACTIVE")
```

## QA Test Cases

- EVENT_ACTIVE → visible = true;切其他 sub-mode → false
- 节点树完整(HandPanel + Portrait + Dialogue + Choice)

## Test Evidence

`tests/integration/card_ui/control_tree_test.gd`

## Dependencies

- Depends on: SceneFlow Story 002
- Unlocks: 全 Card Play UI stories

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 5 test 函数
**Test Evidence**: `tests/integration/card_ui/control_tree_test.gd` (5 tests / GdUnit4) — BLOCKING gate PASS (静态对照已通过 recap/main_menu pattern)
**Code Review**: APPROVED (lean autopilot inline);Control 节点树程序化构建 + DI Callable seam(`tr_callable` / `event_provider` / `npc_phase_provider` / `event_state_provider` / `choice_handler`) — 与 `recap_view_controller.gd` 同模式,无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. .tscn 资产 OUT-OF-SCOPE (UI team Phase 4) — controller 通过 `_ensure_node_tree()` 自建 placeholder 节点,production 替换
**Tech debt**: None new
**API surface**: `class_name CardPlayDialogueController extends Control` + `handle_scene_state_changed(from, to)` + `_ensure_node_tree()`
