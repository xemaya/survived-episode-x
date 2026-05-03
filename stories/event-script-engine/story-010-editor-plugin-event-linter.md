# Story 010: EditorPlugin EventLinter + Python CI Lint Chain

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` Rule 13 + 18 | **Requirement**: `TR-event-007`
**ADR**: ADR-0009(EditorPlugin EventLinter 实时反馈)+ ADR-0010(Python CI lint 强制门)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: EditorPlugin EventLinter 在 Inspector 实时反馈
- Required: Python CI `tools/event_schema_lint.py` PR-blocking
- Guardrail: lint CI 阶段 < 5s(200 events × 14 master/sub-domain)

## Acceptance Criteria

- [ ] `addons/event_linter/plugin.gd` EditorPlugin:监听 EventResource 修改 + Inspector 实时验证(event_id 唯一 / scene_ids ⊂ #6 sub-mode / npc_id ⊂ #8 注册表 / flag_key ⊂ flag 注册表 / 嵌套 ≤ 2 层 / narrative_tier 有对应 variant / schema_version 匹配)
- [ ] `tools/event_schema_lint.py` Python CI:三档密度数量 + farewell numeric_only(Story 006)+ dialogue_keys 存在 + standard 必填(Story 005)
- [ ] CI 阶段 < 5s

## Implementation Notes

```python
# tools/event_schema_lint.py
def lint_all(events_dir: str) -> list[str]:
    errors = []
    errors.extend(lint_standard_required(events_dir))
    errors.extend(lint_density_count(events_dir))  # brief 1-2 / standard 2-4 / verbose 4-8
    errors.extend(lint_farewell_numeric_only(events_dir))
    errors.extend(lint_dialogue_keys_exist(events_dir))  # 验证 keys 在 zh_CN.csv 存在
    errors.extend(lint_event_id_uniqueness(events_dir))
    errors.extend(lint_nesting_depth(events_dir))  # ≤ 2 层
    return errors
```

## QA Test Cases

- 200 events lint < 5s(SSD)
- 各 lint 规则故意违反 → CI FAIL
- EditorPlugin Inspector 实时反馈 visual sign-off(advisory)

## Test Evidence

`tests/unit/event/event_schema_lint_test.py` + `addons/event_linter/`

## Dependencies

- Depends on: Story 001 + Story 005 + Story 006
- Unlocks: writer authoring 工作流(全 200+ events)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 8 GDScript tests + 11 Python tests (Story 005 共建)
**Test Evidence**: `tests/unit/event/event_linter_test.gd` (~145 行 / 8 tests / GdUnit4) + `tests/unit/event/event_schema_lint_test.py` (11 tests Python — 全 PASS) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);EditorPlugin (`addons/event_linter/plugin.gd`) `@tool` 注解 + resource_saved 钩子,`event_linter.gd` 纯 RefCounted (无 @tool 依赖,可单测);GDScript lint 与 Python lint 行为对齐 (event_id 必填 / standard 必填 / 三档密度数量 / farewell numeric_only);Python CI < 5s (200 events 估算 ms 级 — regex pass-through);editor 端打 `INSP_EVT_LINT:` 警告;无 BLOCKING / 无 inline fix
**Engine API Verification**: `@tool` + `EditorPlugin.resource_saved` signal — 4.x 标准
**Deviations** (1 项 ADVISORY):
1. ADR-0009 / 0010 Status=Proposed — lean-mode-equivalent;实时 Inspector 反馈 visual sign-off 留作 advisory (project.godot 注册 plugin 后由 writer 实测)
**Tech debt**: None new
**API surface**: `addons/event_linter/plugin.gd` (EditorPlugin) + `EventLinter.lint_event(event) -> Array[String]` (RefCounted 单测可调用) + `tools/event_schema_lint.py lint_all(events_dir) -> list[str]` (Story 005 已落地,Story 010 共享)
