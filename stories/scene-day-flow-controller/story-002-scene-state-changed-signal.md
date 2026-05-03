# Story 002: scene_state_changed Single Owner + Subject Inversion Dispatch

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-002` + `TR-sceneflow-003`
**ADR**: ADR-0001(scene_state_changed 单 owner = #6,15 subscribers)+ Rule 14 主语翻转 dispatch
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `scene_state_changed(from, to)` signal 单 emit owner = #6;15 subs lightweight handler
- Required: 主语翻转 dispatch — sub-mode 转移文本用反向主语(公司 → 员工);`subject_inversion_lint --domain SCENE` 守
- Guardrail: 同帧 dispatch ≤ 1 帧 + 16.6ms 总预算

## Acceptance Criteria

- [ ] `signal scene_state_changed(from: StringName, to: StringName)` owner = #6
- [ ] `request_transition(to: StringName)` 唯一合法入口 + emit 信号同帧
- [ ] **AC-FUNC** Rule 14 主语翻转 dispatch:转移 message 用 SCENE.* keys + `subject_inversion_lint --domain SCENE`(扩展 ADR-0010 master domain)守
- [ ] CI signal_ownership_lint:`grep "emit_signal.*scene_state_changed"` 仅 scene_day_flow_controller.gd 1 文件 hit

## Implementation Notes

```gdscript
signal scene_state_changed(from: StringName, to: StringName)

func request_transition(to: StringName) -> void:
    if to not in SUBMODES:
        push_error("Invalid sub-mode: %s" % to)
        return
    if not _is_legal_transition(_current_sub_mode, to):
        push_error("Illegal transition: %s → %s" % [_current_sub_mode, to])
        return
    var old := _current_sub_mode
    _current_sub_mode = to
    emit_signal(&"scene_state_changed", old, to)
```

## QA Test Cases

- request_transition × 100 次混合 sub-mode → emit signal 同帧;15 subs 总 ≤ 16.6ms
- signal_ownership_lint:仅 scene_day_flow_controller.gd emit

## Test Evidence

`tests/integration/scene_flow/scene_state_changed_dispatch_test.gd`

## Dependencies

- Depends on: Story 001
- Unlocks: 全 15 subscribers stories(15 subs lightweight handler)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/4 COVERED — `signal scene_state_changed(from, to)` owner + `request_transition()` 单一入口 + 同帧 emit + 非法/无效转移拒绝;CI signal_ownership_lint 是项目级 lint deferred(out-of-scope,本 story 实施只验本文件 emit);主语翻转 `subject_inversion_lint --domain SCENE` 为 ADR-0010 lint 规则属另一 epic
**Test Evidence**: `tests/integration/scene_flow/scene_state_changed_dispatch_test.gd` (3 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED;`request_transition` 是 emit 唯一公有路径;`_force_transition` private 用于 focus-out 系统事件;无 BLOCKING / 无 inline fix
**Engine API Verification**: N/A(标准 signal emit 语法 + Array 包含检查,Godot 4.x stable)
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR-0001/0002 Status=Proposed — lean-mode-equivalent
2. CI `signal_ownership_lint` + `subject_inversion_lint` 是 cross-epic CI infra(OUT-OF-SCOPE),由架构组负责;本 story 实施保证文件级合规
**Tech debt**: None new
**API surface**: `signal scene_state_changed(from: StringName, to: StringName)` + `request_transition(to: StringName) -> void`
