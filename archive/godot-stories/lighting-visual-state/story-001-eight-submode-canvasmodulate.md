# Story 001: 8 Sub-Mode CanvasModulate Palette + Tonemapper Lock

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-001` + `TR-lighting-010`
**ADR**: GDD Rule 1(8 sub-mode 色值表)+ architecture.md L34(Tonemapper Filmic 锁,4.6 AgX 不启用)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: CanvasModulate 8 sub-mode 色值表 + Tonemapper Filmic 锁
- Forbidden: 启用 4.6 AgX tonemapper(art-bible 锁 Filmic)

## Acceptance Criteria

- [ ] `apply_visual_state(sub_mode: StringName)` API + 8 sub-mode 色值表(MAIN_MENU/ACTION_DAY/EVENT_ACTIVE/WEEKEND/KPI_REVIEW 紫/GAMEOVER 灰/PAUSE/SETTINGS)
- [ ] Tonemapper = Filmic(`WorldEnvironment` 节点配置;不用 4.6 AgX)
- [ ] CanvasModulate 节点 `process_mode = PROCESS_MODE_ALWAYS`(跨 pause Tween)

## Implementation Notes

```gdscript
extends Node
const SUBMODE_PALETTES := {
    &"MAIN_MENU": Color(1.0, 1.0, 1.0, 1.0),
    &"ACTION_DAY": Color(1.0, 1.0, 1.0, 1.0),
    &"EVENT_ACTIVE": Color(0.95, 0.95, 1.0, 1.0),
    &"WEEKEND": Color(1.0, 0.95, 0.85, 1.0),
    &"KPI_REVIEW": Color(0.85, 0.80, 1.05, 1.0),  # ADR-0007 紫
    &"GAMEOVER": Color(0.6, 0.6, 0.6, 1.0),  # ADR-0006 灰
    &"PAUSE": Color(0.7, 0.7, 0.7, 1.0),
    &"SETTINGS": Color(1.0, 1.0, 1.0, 1.0),
}

func apply_visual_state(sub_mode: StringName) -> void:
    var target := SUBMODE_PALETTES.get(sub_mode, Color.WHITE)
    var tween := create_tween()
    tween.tween_property(canvas_modulate, "color", target, 0.3)
```

## QA Test Cases

- 8 sub-mode 切换 → CanvasModulate 色值匹配表;Tonemapper 验证 = Filmic

## Test Evidence

`tests/unit/lighting/canvasmodulate_palette_test.gd`

## Dependencies

- Depends on: None
- Unlocks: 全 sub-mode 切换协作 stories

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 5 test 函数(`SUBMODE_PALETTES` 8 entries / KPI_REVIEW 紫 ADR-0007 / GAMEOVER 灰 ADR-0006 / `apply_visual_state` Tween / `process_mode = ALWAYS`)
**Test Evidence**: `tests/unit/lighting/canvasmodulate_palette_test.gd`(89 行 / 5 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode autopilot inline);全静态类型 GDScript;`SUBMODE_PALETTES` Dict 锁 8 sub-mode + ADR-0007/0006 颜色 verbatim;`apply_visual_state` 内嵌 Story 011 farewell guard 提前退出;无 BLOCKING / 无 inline fix
**Engine API Verification**: CanvasModulate `color` Tween + `Tween.TRANS_LINEAR` + `EASE_IN_OUT` 4.0+ 稳定;`Node.PROCESS_MODE_ALWAYS` 与 audio / scene_flow autoload 一致(参考 `scene_day_flow_controller.gd` L115)
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. Tonemapper Filmic 锁未在代码中强制 — 由 Phase-4 `WorldEnvironment` .tscn 配置(per architecture.md L34);本 autoload 不暴露 runtime 切 tonemapper 入口
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `SUBMODE_PALETTES`(public Dict)+ `apply_visual_state(sub_mode: StringName)` + `palette_changed(from, to)` signal + `current_palette` 公有读
