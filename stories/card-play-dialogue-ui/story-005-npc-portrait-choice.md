# Story 005: NPC Portrait + Choice Interaction (long)

> **Epic**: card-play-dialogue-ui | **Status**: Complete | **Layer**: Presentation | **Type**: UI | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/card-play-dialogue-ui.md` | **Requirement**: `TR-cardui-002`
**ADR**: 协作 NPC + Event Script stories
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: long density 时 — NPC 立绘 + 对白 + 选项区显示
- Required: choice 选项 keyboard / gamepad navigation(focus 环)

## Acceptance Criteria

- [ ] NpcPortraitArea 显示 event.target_npc 立绘(基于 NPC.relationship_phase 选 expression)
- [ ] DialoguePanel 渲染 dialogue_keys_standard / verbose 列表(`tr()` + RichTextLabel BBCode)
- [ ] ChoiceButtonContainer 渲染 event.choices Array(每 choice 1 Button + focus_entered 焦点环)
- [ ] 选 choice → 触发 effect 链 + emit event_completed

## Implementation Notes

```gdscript
func _render_long_dialogue(event: EventResource, density: StringName) -> void:
    # NPC 立绘
    if event.target_npc != &"":
        var npc_state := NPCRelationshipSystem.get_npc_state(event.target_npc)
        npc_portrait.frame = _select_portrait_frame(event.target_npc, npc_state.relationship_phase)
        npc_portrait.visible = true
    # 对白 list
    var dialogue_keys := _select_dialogue_keys_by_density(event, density)
    var bbcode_text := ""
    for key in dialogue_keys:
        bbcode_text += "[b]" + tr(key) + "[/b]\n"
    dialogue_label.parse_bbcode(bbcode_text)
    # 选项
    _clear_choices()
    for choice in event.choices:
        var btn := preload("res://scenes/ui/choice_button.tscn").instantiate()
        btn.choice = choice
        btn.choice_selected.connect(_on_choice_selected)
        choice_container.add_child(btn)
```

## QA Test Cases

- long density event → NPC 立绘 + 对白渲染 + choice 区
- D-Pad 焦点遍历 choices + focus 环可见
- 选 choice → emit event_completed

## Test Evidence

`tests/integration/card_ui/long_dialogue_test.gd`

## Dependencies

- Depends on: Story 002 + Story 003 + NPC Story 004(relationship_phase)+ Loc Story 002(register_rich_text_refresh)
- Unlocks: 全 long event 玩家体验

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 5 test 函数(target_npc 非空 → portrait 可见 + relationship_phase meta;无 target_npc → portrait 隐藏;BBCode 包裹的 dialogue 行;ChoiceButtonContainer 每 choice 1 button;press → choice_handler 触发)
**Test Evidence**: `tests/integration/card_ui/long_dialogue_test.gd` (5 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`_render_long_dialogue()` 三段式(NPC 立绘 / RichTextLabel BBCode / Choice button container)+ duck-type 读 `target_npc` & `label_loc_key`(避免硬依赖 Card 派生类 / ChoiceBlock schema);`npc_phase_provider` Callable seam 让单测注入 RelationshipPhase 不需要 NPCRelationshipSystem autoload;无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. AnimatedSprite2D portrait frame 实际选帧 OUT-OF-SCOPE — UI team Phase 4 wiring(我们写入 `npc_portrait_area.set_meta("relationship_phase", phase_int)` 让 Phase 4 读)
2. focus 环 D-Pad navigation 由 Story 004 CardButton 已 cover(ADR-0014);Choice button 直接 `focus_mode = FOCUS_ALL`
**Tech debt**: None new
**API surface**: `_render_long_dialogue(event, density)` + `signal long_dialogue_rendered(event_id, dialogue_line_count, choice_count)` + `choice_handler` Callable seam
