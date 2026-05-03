# Story 003: Autoload Last + PROCESS_MODE_ALWAYS + Watchdog PAUSE_INHERIT

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-001` + `TR-sceneflow-006`
**ADR**: ADR-0002 Autoload Init Order(C-ENG-01 + C-ENG-02 + C-ENG-07)
**Engine**: Godot 4.6 | **Risk**: HIGH(OQ-SDF-ENG-01 PROCESS_MODE_ALWAYS 4.6 SceneTree.paused 实测)

**Control Manifest Rules**:
- Required: SceneDayFlowController autoload 末位 + PROCESS_MODE_ALWAYS
- Required: watchdog Timer PAUSE_INHERIT(pause 期间挂起)
- Required: Tween fade PROCESS_MODE_ALWAYS(跨 pause 边界继续)

## Acceptance Criteria

- [ ] `project.godot` `[autoload]` 段:Save → Localization → Audio → Lighting → Input → SceneDayFlow(末位)→ Tutorial → Accessibility
- [ ] `_ready()`:`process_mode = Node.PROCESS_MODE_ALWAYS`
- [ ] OQ-SDF-ENG-01 实测:`SceneTree.paused = true` 期间 `#6._process(delta)` 仍调用(wall-clock)+ game-time 累加器不增长(选择性累加 — Story 008)
- [ ] watchdog Timer 节点 `process_mode = PAUSE_INHERIT`(pause 期间挂起)

## Implementation Notes

```gdscript
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS  # C-ENG-02
    
    # watchdog Timers 用 PAUSE_INHERIT(C-ENG-02 + C-ENG-07)
    var watchdog := Timer.new()
    watchdog.process_mode = Node.PROCESS_MODE_PAUSABLE  # 等价 PAUSE_INHERIT
    add_child(watchdog)
```

## QA Test Cases

- OQ-SDF-ENG-01:Pre-Production prototype `SceneTree.paused = true` → #6._process 仍调用 + game-time 不累加
- watchdog Timer pause 期间挂起;Tween PROCESS_MODE_ALWAYS 仍跑

## Test Evidence

`tests/integration/scene_flow/process_mode_always_test.gd` + Pre-Production prototype evidence

## Dependencies

- Depends on: Story 001
- Unlocks: Story 004(启动序列)+ Story 008(pause game-time)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/4 COVERED — `process_mode = PROCESS_MODE_ALWAYS` in `_ready()` + `WatchdogTimer` child PROCESS_MODE_PAUSABLE + `SettingsDebounceTimer` PROCESS_MODE_ALWAYS;`project.godot` `[autoload]` 段注册 OUT-OF-SCOPE(项目无 project.godot 文件,save-system Story 004 头部已注 `Registration deferred`)
**Test Evidence**: `tests/integration/scene_flow/process_mode_always_test.gd` (3 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED;Watchdog Timer 用 PROCESS_MODE_PAUSABLE(等价 PAUSE_INHERIT — 4.x 重命名);Tween 跨 pause boundary 是后续 stories 的 Tween 实例属性,不在 controller `_ready` 设置;无 BLOCKING / 无 inline fix
**Engine API Verification**: HIGH — 已查 `docs/engine-reference/godot/breaking-changes.md` 4.3→4.6 全量 + `current-best-practices.md`,Node.PROCESS_MODE_ALWAYS / PROCESS_MODE_PAUSABLE API 自 4.0 stable 无变更;OQ-SDF-ENG-01 行为 prototype evidence deferred to Pre-Production
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR-0002 Status=Proposed — lean-mode-equivalent
2. `project.godot` autoload 注册 OUT-OF-SCOPE(项目级配置,save-system Story 004 头注释已记)
**Tech debt**: None new
**API surface**: `_ready()` 设置 process_mode + 创建 `SettingsDebounceTimer` (ALWAYS) + `WatchdogTimer` (PAUSABLE)
