# Story 005: change_scene_to_packed Preload Guard

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-007`
**ADR**: ADR-0002 + C-ENG-05
**Engine**: Godot 4.6 | **Risk**: HIGH(OQ-SDF-ENG-02 4.5 SceneTree 重构 2D 路径性能基准)

**Control Manifest Rules**:
- Required: ResourceLoader.load_threaded_request 预加载 + change_scene_to_packed
- Forbidden: 同步 change_scene_to_file(forbidden_pattern `sync_change_scene_to_file`)

## Acceptance Criteria

- [ ] `_transition_scene(scene_path: String)` API:走 ResourceLoader.load_threaded_request → poll 完成 → change_scene_to_packed
- [ ] OQ-SDF-ENG-02:实测 4.5 SceneTree 重构 2D 路径性能 ≤ 200ms p95(Pre-Production prototype);若 > 100ms 降级 — Loading Scene 不切换仅显隐节点
- [ ] forbidden_pattern lint:`grep "change_scene_to_file"` 全 codebase 0 hit

## Implementation Notes

```gdscript
func _transition_scene(scene_path: String) -> void:
    ResourceLoader.load_threaded_request(scene_path)
    while ResourceLoader.load_threaded_get_status(scene_path) != ResourceLoader.THREAD_LOAD_LOADED:
        await get_tree().process_frame
    var packed := ResourceLoader.load_threaded_get(scene_path)
    get_tree().change_scene_to_packed(packed)
```

## QA Test Cases

- 调 _transition_scene("res://scenes/main_menu.tscn") → 预加载完成后 change_scene_to_packed
- forbidden_pattern lint:0 hit `change_scene_to_file`
- OQ-SDF-ENG-02:perf ≤ 200ms p95(Pre-Production prototype)

## Test Evidence

`tests/integration/scene_flow/scene_switch_perf_test.gd` + Pre-Production prototype evidence

## Dependencies

- Depends on: Story 003
- Unlocks: Story 004(启动序列)+ Story 011(MAIN_MENU → ACTION_DAY 等转移)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 2/3 COVERED — `transition_scene_packed(scene_path) -> Error` API + ResourceLoader 三步 (load_threaded_request → poll status → load_threaded_get → change_scene_to_packed) + 错误路径 graceful;forbidden_pattern lint `change_scene_to_file` test 验证 controller 源 0 hit;OQ-SDF-ENG-02 4.5 SceneTree-rebuild 2D 路径 ≤ 200ms p95 perf prototype evidence deferred to Pre-Production
**Test Evidence**: `tests/integration/scene_flow/scene_switch_perf_test.gd` (3 tests / GdUnit4) — BLOCKING gate PASS;forbidden_pattern lint inline 验证 source 文件
**Code Review**: APPROVED;poll loop 用 `await get_tree().process_frame` 避免 spin;`as PackedScene` 失败 graceful;无 BLOCKING / 无 inline fix
**Engine API Verification**: HIGH — 已查 `current-best-practices.md` ResourceLoader 4.5+ 段;`load_threaded_request / load_threaded_get_status / load_threaded_get / change_scene_to_packed` 全部 self-contained Godot 4.x stable API,4.3→4.6 breaking-changes.md 无变更;OQ-SDF-ENG-02 perf evidence(2D 路径 ≤ 200ms)deferred to Pre-Production prototype
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR-0002 Status=Proposed — lean-mode-equivalent
2. OQ-SDF-ENG-02 perf benchmark Pre-Production prototype 完成(本 story 实施 API + 0-hit forbidden lint;perf 基准属下游 OQ)
**Tech debt**: None new
**API surface**: `transition_scene_packed(scene_path: String) -> Error` (coroutine)
