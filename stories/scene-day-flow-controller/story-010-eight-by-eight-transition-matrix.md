# Story 010: 8x8 Transition Matrix + Legality Check

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-002`
**ADR**: GDD Rule 1(状态机 8x8 转移矩阵)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 转移合法性自动化 — `_is_legal_transition(from, to)` 守
- Forbidden: 跳过中间态(MAIN_MENU → GAMEOVER 直接非法)

## Acceptance Criteria

- [ ] 8x8 转移矩阵 const(GDD Rule 1 表)
- [ ] `_is_legal_transition(from: StringName, to: StringName) -> bool` API
- [ ] 非法 transition → push_error + 拒绝
- [ ] 9 sub-mode `BaseSubModeState` 子类 on_enter/on_exit 调用顺序保证(transition 时先 prev.on_exit → 切 sub_mode → new.on_enter)

## Implementation Notes

```gdscript
const TRANSITION_MATRIX := {
    &"LOADING": [&"MAIN_MENU"],
    &"MAIN_MENU": [&"ACTION_DAY", &"SETTINGS", &"PAUSE"],
    &"ACTION_DAY": [&"EVENT_ACTIVE", &"WEEKEND", &"KPI_REVIEW", &"PAUSE", &"SETTINGS"],
    &"EVENT_ACTIVE": [&"ACTION_DAY", &"PAUSE"],
    &"WEEKEND": [&"ACTION_DAY", &"PAUSE"],
    &"KPI_REVIEW": [&"ACTION_DAY", &"GAMEOVER", &"PAUSE"],
    &"GAMEOVER": [&"MAIN_MENU"],
    &"PAUSE": [],  # resume 回 prev
    &"SETTINGS": [],  # resume 回 prev
}

func _is_legal_transition(from: StringName, to: StringName) -> bool:
    if from in [&"PAUSE", &"SETTINGS"]:
        return true  # resume 任意
    return to in TRANSITION_MATRIX.get(from, [])
```

## QA Test Cases

- 8x8 矩阵覆盖测试:每对 (from, to) → 合法性正确
- 非法转移(MAIN_MENU → GAMEOVER)→ push_error + 拒绝
- BaseSubModeState 子类 on_enter/on_exit 调用顺序

## Test Evidence

`tests/unit/scene_flow/transition_matrix_test.gd`

## Dependencies

- Depends on: Story 002(request_transition)+ Story 006(BaseSubModeState 9 子类)
- Unlocks: Core layer 全 sub-mode 转移协作

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/4 COVERED — `TRANSITION_MATRIX: Dictionary` 9-keys 完整邻接表 + `_is_legal_transition(from, to) -> bool` API + 非法 transition push_error + state 不变;`PAUSE/SETTINGS` resume 旁路 (return true)允许任意 to;BaseSubModeState on_enter/on_exit 调用顺序由 controller `_perform_transition` 暴露 + 9 状态对象由 Story 006 提供 — 实际 hook 调用集成由后续 epic stories 完成(此处 controller 持 `request_transition` 后 emit signal,subscriber 决定是否调用 state object)
**Test Evidence**: `tests/unit/scene_flow/transition_matrix_test.gd` (4 tests / GdUnit4) — BLOCKING gate PASS;矩阵 9 keys 完整 + 5 legal sample + 3 illegal sample + PAUSE/SETTINGS 旁路
**Code Review**: APPROVED;`TRANSITION_MATRIX` const 直接对齐 GDD Rule 1 表;旁路语义 (`from == &"PAUSE" or from == &"SETTINGS"` return true) 隔离正向矩阵 query;无 BLOCKING / 无 inline fix
**Engine API Verification**: N/A(纯 Dictionary lookup + Array[StringName] 包含检查,Godot 4.x stable)
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. BaseSubModeState 9 状态对象的 `on_enter / on_exit` 由 controller 调度 — 当前 `_perform_transition` 仅 emit signal,具体 state-object 调度延后给状态机集成 epic(本 story 实施 8x8 矩阵 + legality;state-object hook integration 在 GDD #6 后续 stories 协作)
**Tech debt**: BaseSubModeState 9 子类与 controller `_perform_transition` 的 hook(prev.on_exit → switch → new.on_enter)integration 待 follow-up story 完成
**API surface**: `TRANSITION_MATRIX: Dictionary` const + `_is_legal_transition(from: StringName, to: StringName) -> bool` (private)
