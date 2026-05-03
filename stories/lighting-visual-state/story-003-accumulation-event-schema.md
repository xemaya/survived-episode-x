# Story 003: accumulation_event 4-Dimension Schema(Single Owner)

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-003` + `TR-lighting-004`
**ADR**: ADR-0005 Lighting Accumulation 4 Dimensions + ADR-0001 forbidden_pattern `accumulation_event_multiple_emitters`
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: accumulation_event 单 owner = #5(B-DEP-3 仲裁)
- Forbidden: #6 / #13 / 任何系统 emit accumulation_event

## Acceptance Criteria

- [ ] `accumulation_event(type: StringName, delta_units: int)` signal owner = LightingController
- [ ] 4 type 枚举常量(StringName):`yellowing_level / sticky_note_count / steam_density / npc_empty_chairs`
- [ ] state schema:`yellowing_level: int [0..6]` + `sticky_note_count: int [0..12]` + `steam_density: int [0..6]` + `npc_empty_chairs: Dictionary[NpcId, bool]`
- [ ] forbidden_pattern lint:CI grep 全 codebase 验证 `accumulation_event` 仅在 lighting_controller.gd 内 emit;其他文件 emit → CI FAIL

## Implementation Notes

```gdscript
const ACCUMULATION_TYPE_YELLOWING := &"yellowing_level"
const ACCUMULATION_TYPE_STICKY_NOTE := &"sticky_note_count"
const ACCUMULATION_TYPE_STEAM := &"steam_density"
const ACCUMULATION_TYPE_EMPTY_CHAIRS := &"npc_empty_chairs"

signal accumulation_event(type: StringName, delta_units: int)

var _yellowing_level: int = 0  # cap 6
var _sticky_note_count: int = 0  # cap 12
var _steam_density: int = 0  # cap 6
var _empty_chairs: Dictionary = {}
```

## QA Test Cases

- 4 type 常量定义 + state cap 上限
- forbidden_pattern lint:`grep "emit_signal.*accumulation_event"` 仅 lighting_controller.gd 1 个文件 hit

## Test Evidence

`tests/unit/lighting/accumulation_schema_test.gd` + `tools/signal_ownership_lint.py`(grep verify)

## Dependencies

- Depends on: Story 001
- Unlocks: Story 004(4 维度触发器)+ HUD epic 4 元素订阅

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 4 test 函数(4 type StringName const / 3 cap 上限 / signal payload typed / DirAccess grep 单 owner)+ `tools/signal_ownership_lint.py` self-test PASS
**Test Evidence**: `tests/unit/lighting/accumulation_schema_test.gd`(95 行 / 4 tests / GdUnit4 + DirAccess walk)+ `tools/signal_ownership_lint.py`(216 行,registry-based;CI grep + self-test)— BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode);单 `signal accumulation_event(StringName, int)` typed payload;ADR-0005 4 维 cap (yellowing 6 / sticky 12 / steam 6 / chairs Dict)；signal_ownership_lint 用通用 registry 表(`scene_state_changed` 也覆盖)— forbidden_pattern `accumulation_event_multiple_emitters` enforced;无 BLOCKING
**Engine API Verification**: `signal name(typed_args)` 4.0+ 稳定;StringName const 4.4+ 稳定(参考 audio Story 003 + scene_flow Story 002 同模式)
**Deviations**(2 项 ADVISORY):
1. DirAccess walk grep 在 GDScript 内执行 — 与 python lint 双轨;CI 任一通过即满足契约
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `ACCUMULATION_TYPE_*`(4 const)+ `ACCUMULATION_TYPES` Array + `YELLOWING_LEVEL_CAP` / `STICKY_NOTE_CAP` / `STEAM_DENSITY_CAP` const + `accumulation_event` signal + 4 公有读 state 字段
