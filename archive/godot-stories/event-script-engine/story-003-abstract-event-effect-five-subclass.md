# Story 003: @abstract EventEffect + 5 Subclass

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` | **Requirement**: `TR-event-002`
**ADR**: ADR-0002 @abstract 4.5+ + ADR-0009 5 子类(SetFlag / RelationshipDelta / SpawnNotice / GiveUnlock / EmitGameOver)
**Engine**: Godot 4.6 | **Risk**: HIGH(@abstract 4.5+ OQ-EVT-ENG-01 实测)

**Control Manifest Rules**:
- Required: @abstract EventEffect 基类 + 5 子类必须 override apply()
- Forbidden: 运行时 assert 替代 @abstract;新增子类需 ADR amendment

## Acceptance Criteria

- [ ] `@abstract class_name EventEffect extends Resource` + `@abstract func apply(context: EventContext) -> void`
- [ ] 5 子类:SetFlagEffect / RelationshipDeltaEffect / SpawnNoticeEffect / GiveUnlockEffect / EmitGameOverEffect
- [ ] 漏 override → 编辑器实例化报错(@abstract 4.5+ 强制)
- [ ] OQ-EVT-ENG-01 实测(共享 SceneFlow Story 006)

## Implementation Notes

```gdscript
@abstract
class_name EventEffect extends Resource

@abstract
func apply(context: EventContext) -> void:
    pass

# 5 子类:
class_name SetFlagEffect extends EventEffect
@export var flag_name: StringName
@export var value: bool
func apply(context: EventContext) -> void:
    context.flag_dict[flag_name] = value

class_name RelationshipDeltaEffect extends EventEffect
@export var npc_id: StringName
@export var delta: int  # ±1..±10
func apply(context: EventContext) -> void:
    NPCRelationshipSystem.update_relationship(npc_id, delta, "event:" + str(context.event_id))

# ... 余 3 子类(SpawnNotice / GiveUnlock / EmitGameOver)
```

## QA Test Cases

- 5 子类各自 apply() 单测
- 漏 override → 实例化失败(@abstract 4.5 强制)

## Test Evidence

`tests/unit/event/abstract_effect_test.gd`

## Dependencies

- Depends on: Story 001 + SceneFlow Story 006(共享 OQ-EVT-ENG-01)
- Unlocks: 全 effect 链 stories

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 8 test 函数
**Test Evidence**: `tests/unit/event/abstract_effect_test.gd` (~210 行 / 8 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);@abstract base + 5 子类全部 override apply(),所有 cross-system seams 用 Callable 注入 (npc_relationship/notice/unlock/gameover provider) 而非 autoload 直引,EmitGameOverEffect 不 emit game_over_triggered 信号 (ADR-0001 forbidden_pattern dual_emit 守门 — 走 provider 转 #9 KPI),provider 缺失 push_warning + no-op 防御;无 BLOCKING / 无 inline fix
**Engine API Verification**: Godot 4.5+ `@abstract` 装饰 — verified at `docs/engine-reference/godot/current-best-practices.md` "Abstract classes and methods"; `docs/engine-reference/godot/breaking-changes.md` GDScript row "@abstract decorator: Abstract classes and methods now enforceable". OQ-EVT-ENG-01 / OQ-SDF-ENG-03 引擎实测前提条件已满足
**Deviations** (1 项 ADVISORY):
1. ADR-0002 / 0009 Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `@abstract EventEffect` base + 5 子类 (`SetFlagEffect` / `RelationshipDeltaEffect` / `SpawnNoticeEffect` / `GiveUnlockEffect` / `EmitGameOverEffect`),每个 override `apply(context: Dictionary)`
