# Story 001: EventResource .tres Schema

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` | **Requirement**: `TR-event-001`
**ADR**: ADR-0009 EventResource .tres single file per event(`@export` 字段 + Inspector 编辑)
**Engine**: Godot 4.6 | **Risk**: HIGH(via @abstract 4.5+)

**Control Manifest Rules**:
- Required: `EventResource extends Resource` + .tres 单文件 per event;writer 用 Godot Inspector 编辑
- Forbidden: events.json 集中文件;GDScript func 直接定义事件

## Acceptance Criteria

- [ ] `EventResource extends Resource` 类:`@export var event_id: StringName / schema_version: int / scene_ids / trigger / conditions / variants / choices / effects / cooldown / weight / weight_modifiers / narrative_tier / npc_arc_tag / chapter / tags / priority / author / review_status / farewell_event: bool`
- [ ] `data/events/[category]/[event_id].tres` 目录结构:npc/lisa/ + npc/boss/ + kpi/ + month_end/ + morning/
- [ ] `EventLoader.load_all()` 启动期 batch load + `_index_events()` 建立 Dictionary 三层索引

## Implementation Notes

```gdscript
class_name EventResource extends Resource
@export var event_id: StringName
@export var schema_version: int = 1
@export var scene_ids: Array[StringName]
@export var trigger: EventTrigger
@export var conditions: Array[ConditionBlock]
@export var variants: Array[VariantBlock]
@export var choices: Array[ChoiceBlock]
@export var effects: Array[EventEffect]
@export var cooldown: CooldownBlock
@export var weight: float = 1.0
@export var narrative_tier: StringName = &"standard"  # flash / standard / verbose / numeric_only
@export var farewell_event: bool = false  # B-DEP-2 守门
@export var once_per_run: bool = false
@export var morning_blacklist: bool = false
@export var npc_arc_tag: String = ""
@export var chapter: String = ""
@export var tags: Array[String]
@export var priority: int = 0
@export var author: String = ""
@export var review_status: String = ""
```

## QA Test Cases

- 200 events 启动期 load < 200ms 主线程占
- EventResource 实例化字段完整

## Test Evidence

`tests/unit/event/event_resource_schema_test.gd`

## Dependencies

- Depends on: None
- Unlocks: 全 Event Script stories

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 8 test 函数
**Test Evidence**: `tests/unit/event/event_resource_schema_test.gd` (~250 行 / 8 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);EventResource 全 19 @export 字段定义完整,默认值 round-trip,EventLoader 静态 RefCounted 不依赖 autoload,目录结构 5 子目录;无 BLOCKING / 无 inline fix
**Engine API Verification**: `DirAccess.open` 4.4+ 静态工厂 (verified at docs/engine-reference/godot/breaking-changes.md); `ResourceLoader.CACHE_MODE_REUSE` 4.5+ 现行 API
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR-0009 Status=Proposed — lean-mode-equivalent (autopilot 通用 deviation)
2. effects_brief/standard/verbose 三档为 schema 字段;Story 005 实施 fallback 链
**Tech debt**: None new
**API surface**: 新增 `EventResource` (.tres schema) + `EventTrigger` / `EventEffect` (Story 002/003 细化) + `ConditionBlock` / `VariantBlock` / `ChoiceBlock` / `CooldownBlock` (sub-resource scaffolds) + `EventLoader.load_all(root)` static
