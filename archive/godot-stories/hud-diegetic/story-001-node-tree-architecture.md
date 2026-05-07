# Story 001: World Node Tree Architecture + Single CanvasLayer

> **Epic**: hud-diegetic | **Status**: Complete | **Layer**: Presentation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/hud-diegetic.md` | **Requirement**: `TR-hud-001`
**ADR**: ADR-0011 节点树架构 + 单 CanvasLayer
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: World (Node2D, layer=0) / DiegeticHUD / DiegeticNotifications / 单 CanvasLayer (layer=1)
- Required: CanvasLayer 仅 4 sub-mode 切换屏(PAUSE / KPI_REVIEW / GAMEOVER / SETTINGS)
- Forbidden: 多 CanvasLayer 嵌套;ACTION_DAY 期间 CanvasLayer.visible = true(forbidden_pattern)

## Acceptance Criteria

- [ ] `scenes/world.tscn` 节点树:World (Node2D) → Background (TileMap) / DiegeticHUD (Node2D) / DiegeticNotifications (Node2D) / CanvasLayer (layer=1)
- [ ] CanvasLayer 内 4 Control 子屏(PauseMenu / KPIReviewScreen / GameOverScreen / SettingsScreen)各自 hidden by default
- [ ] `art-bible §7.1 lint` CI 守:ACTION_DAY 期间 CanvasLayer.visible = true 阻断 PR

## Implementation Notes

```
World (Node2D, layer=0)
├── Background (TileMap)
├── DiegeticHUD (Node2D)               # 8 元素全在此 (Story 002)
├── DiegeticNotifications (Node2D)     # `#19` 通知通过 diegetic 元素 variant
└── CanvasLayer (layer=1)              # 唯一 UI 层
    ├── PauseMenu (Control) [hidden]
    ├── KPIReviewScreen (Control) [hidden]
    ├── GameOverScreen (Control) [hidden]
    └── SettingsScreen (Control) [hidden]
```

```gdscript
# diegetic_hud.gd
func _on_scene_state_changed(_from: StringName, to: StringName) -> void:
    canvas_layer.visible = to in [&"PAUSE", &"SETTINGS", &"KPI_REVIEW", &"GAMEOVER"]
```

## QA Test Cases

- 节点树验证:World (Node2D) + 单 CanvasLayer
- ACTION_DAY → canvas_layer.visible = false;PAUSE → visible = true
- art-bible §7.1 lint:故意 ACTION_DAY 期间 visible = true → CI FAIL

## Test Evidence

`tests/integration/hud/canvas_layer_visibility_test.gd` + `tools/art_bible_71_lint.gd`

## Dependencies

- Depends on: SceneFlow Story 002(scene_state_changed)
- Unlocks: 全 HUD stories

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 4 test 函数(`test_canvas_layer_visible_in_four_sub_modes` / `test_canvas_layer_hidden_in_action_day_sub_modes` / `test_no_crash_when_canvas_layer_unset` / `test_canvas_layer_visible_set_matches_constant`)
**Test Evidence**: `tests/integration/hud/canvas_layer_visibility_test.gd`(82 行 / 4 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean autopilot inline);DiegeticHUD 单 CanvasLayer 守门 + `_on_scene_state_changed` 仅 4 sub-mode 设 visible;callable 注入风格;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. ADR-0011 Status=Proposed — lean-mode-equivalent
2. `.tscn` World 节点树资产 OUT-OF-SCOPE(Phase 4 art team — set_canvas_layer_for_test seam 提供)
**Tech debt**: None new
**API surface**: `DiegeticHUD` class_name + `CANVAS_LAYER_VISIBLE_SUB_MODES` 常量 + `_on_scene_state_changed(from, to)` + `set_canvas_layer_for_test(layer)`
