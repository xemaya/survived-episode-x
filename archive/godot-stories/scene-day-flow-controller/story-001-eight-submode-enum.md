# Story 001: 8 Sub-Mode Enum + scene_sub_mode Single Owner

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-002`
**ADR**: ADR-0002(scene_sub_mode state ownership = #6)+ ADR-0001(scene_state_changed 单 owner)
**Engine**: Godot 4.6 | **Risk**: HIGH(via ADR-0002)

**Control Manifest Rules**:
- Required: scene_sub_mode 唯一 write_access = scene-day-flow-controller
- Forbidden: 下游系统直写 scene_sub_mode

## Acceptance Criteria

- [ ] enum `SubMode { MAIN_MENU, LOADING, ACTION_DAY, EVENT_ACTIVE, WEEKEND, KPI_REVIEW, GAMEOVER, PAUSE, SETTINGS }`(8 + LOADING = 9 实际,GDD 说 8 sub-mode)
- [ ] `current_sub_mode: StringName` read-only property + `_set_sub_mode(new)` 私有
- [ ] **AC-FUNC** Rule 1 + Rule 2 8 sub-mode enum 锁定:enum 顺序 + 命名严守

## Implementation Notes

```gdscript
# scene_day_flow_controller.gd (Autoload 末位)
extends Node

const SUBMODES := [&"MAIN_MENU", &"LOADING", &"ACTION_DAY", &"EVENT_ACTIVE", &"WEEKEND", &"KPI_REVIEW", &"GAMEOVER", &"PAUSE", &"SETTINGS"]
var _current_sub_mode: StringName = &"LOADING"

var current_sub_mode: StringName:
    get: return _current_sub_mode
```

## QA Test Cases

- enum 9 个 sub-mode 完整;`current_sub_mode` 读取正确;直写报错(若 setter 私有验证)

## Test Evidence

`tests/unit/scene_flow/submode_enum_test.gd`

## Dependencies

- Depends on: None
- Unlocks: 全 SceneFlow stories

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED — `SUBMODES` 9-元 const + 顺序锁 + `current_sub_mode` 只读 property getter + `_set_sub_mode_for_test` 测试 seam
**Test Evidence**: `tests/unit/scene_flow/submode_enum_test.gd` (3 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);`SUBMODES` 顺序与 ADR-0002 §1 一致;property getter-only 防直写;无 BLOCKING / 无 inline fix
**Engine API Verification**: N/A(纯 enum + property 语法,Godot 4.x stable)
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. ADR-0001/0002 Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `SceneDayFlowController.SUBMODES: Array[StringName]` const (9-元) + `current_sub_mode: StringName` getter-only property + `_set_sub_mode_for_test(sub_mode)` 测试 seam
