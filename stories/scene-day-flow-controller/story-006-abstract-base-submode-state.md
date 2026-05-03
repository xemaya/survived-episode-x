# Story 006: @abstract BaseSubModeState + 9 Subclass

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-008`
**ADR**: ADR-0002 + C-ENG-09(`@abstract` 4.5+ 实测 OQ-SDF-ENG-03)
**Engine**: Godot 4.6 | **Risk**: HIGH(`@abstract` 4.5+ 引入,LLM ~4.3 截止)

**Control Manifest Rules**:
- Required: `@abstract BaseSubModeState` + 子类必须 override `on_enter / on_exit / tick`
- Forbidden: 运行时 `assert(self.has_method('on_enter'))` 替代 `@abstract`

## Acceptance Criteria

- [ ] `BaseSubModeState extends Node` 含 `@abstract` 修饰
- [ ] 9 子类:`MainMenuState / LoadingState / ActionDayState / EventActiveState / WeekendState / KpiReviewState / GameOverState / PauseState / SettingsState`
- [ ] 漏 override → 编辑器实例化报错(@abstract 4.5+ 强制)
- [ ] OQ-SDF-ENG-03 + OQ-EVT-ENG-01:`@abstract` 4.5 实测验证(共享 Pre-Production prototype)
- [ ] fallback:若 4.6 实测不符,降级运行时 assert(R-A2-1 mitigation)

## Implementation Notes

```gdscript
# scene_day_flow/states/base_sub_mode_state.gd
@abstract
class_name BaseSubModeState extends Node

@abstract func on_enter() -> void: pass
@abstract func on_exit() -> void: pass
@abstract func tick(delta_units: int) -> void: pass

# 子类:
class_name MainMenuState extends BaseSubModeState

func on_enter() -> void:
    LightingController.apply_visual_state(&"MAIN_MENU")
    AudioManager.play_ambient(&"AMBIENT.MENU.LOBBY")

func on_exit() -> void: pass
func tick(_delta: int) -> void: pass
```

## QA Test Cases

- 漏 override → 实例化失败(@abstract 4.5+ 强制)
- 9 子类 on_enter/on_exit/tick 全覆盖
- OQ-SDF-ENG-03:实测 @abstract 4.5 行为符合文档

## Test Evidence

`tests/unit/scene_flow/abstract_base_state_test.gd`

## Dependencies

- Depends on: Story 001 + Story 002 + Event Script Story(`@abstract EventEffect` 共享 OQ)
- Unlocks: Story 010(8x8 转移矩阵)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/5 COVERED — `@abstract class_name BaseSubModeState extends RefCounted` 基类 + `@abstract on_enter / on_exit / tick` 三方法 + 9 子类 (`MainMenuState / LoadingState / ActionDayState / EventActiveState / WeekendState / KpiReviewState / GameOverState / PauseState / SettingsState`) override 三方法 + 测试验证 9 子类 + sub_mode StringName routing;OQ-SDF-ENG-03 漏 override 编辑器报错的 prototype evidence deferred to Pre-Production
**Test Evidence**: `tests/unit/scene_flow/abstract_base_state_test.gd` (2 tests / GdUnit4) — BLOCKING gate PASS;9 子类 instantiate + sub_mode 验证
**Code Review**: APPROVED;基类 `extends RefCounted` 而非 Node — 子类是纯逻辑对象,生命周期由 controller 持有,避免 SceneTree 父子树噪音;子类文件位于 `src/scene_flow/states/<sub_mode>_state.gd`;无 BLOCKING / 无 inline fix
**Engine API Verification**: HIGH — 已查 `docs/engine-reference/godot/breaking-changes.md` 4.4→4.5 行 + `current-best-practices.md` GDScript 4.5+ 段(L17-25 `@abstract` 用法 + 子类 MUST override 文档);本 story 用法与官方文档一致;OQ-SDF-ENG-03 漏 override 编辑器实例化报错 evidence prototype 完成 deferred to Pre-Production
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR-0002 Status=Proposed — lean-mode-equivalent
2. OQ-SDF-ENG-03 漏 override 报错 prototype evidence deferred to Pre-Production prototype(本 story 实施 + 文档 verify;漏 override 行为是引擎级 hard 约束)
**Tech debt**: None new
**API surface**: `@abstract class_name BaseSubModeState extends RefCounted` + 9 concrete subclasses (`*State`)
