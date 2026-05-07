# Story 002: Three-Density Differential Rendering

> **Epic**: card-play-dialogue-ui | **Status**: Complete | **Layer**: Presentation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/card-play-dialogue-ui.md` | **Requirement**: `TR-cardui-001`
**ADR**: ADR-0012 三档密度主消费 layer
**Engine**: Godot 4.6 | **Risk**: HIGH

**Control Manifest Rules**:
- Required: 三档差异化渲染 — flash(HUD-only)/ long(立绘+对白+选项)/ verbose(完整)/ numeric_only(HUD-only,无 UI)

## Acceptance Criteria

- [ ] `_render_event_by_density(event, density)`:
  - **flash** → `#13` HUD Story 008 flash overlay 单行 Label,`#14` 自身 visible = false
  - **long** → 立绘 + 对白 + 选项区显示
  - **verbose** → 同 long,但 dialogue/effects 数量更多
  - **numeric_only** → `#13` HUD-only,`#14` 自身 visible = false

## Implementation Notes

```gdscript
func _render_event_by_density(event: EventResource, density: StringName) -> void:
    match density:
        &"flash":
            visible = false  # HUD Story 008 接管
        &"numeric_only":
            visible = false  # HUD only,无对白 UI
        &"long", &"verbose":
            visible = true
            _render_long_dialogue(event, density)
```

## QA Test Cases

- flash density → #14 visible = false + HUD flash overlay 显示
- long density → #14 visible = true + 立绘+对白+选项
- numeric_only density → #14 visible = false

## Test Evidence

`tests/integration/card_ui/three_density_render_test.gd`

## Dependencies

- Depends on: Story 001 + HUD Story 008
- Unlocks: Story 003(fallback chain)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 5 test 函数(flash + numeric_only HUD-only / standard 长路径 / verbose 长路径 / brief 当 flash overlay 处理)
**Test Evidence**: `tests/integration/card_ui/three_density_render_test.gd` (5 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`_render_event_by_density` match 五档 + `_density_should_show_panel` 纯函数可单测 + `density_rendered(event_id, density, visible_panel)` 信号让 HUD #13 / 测试观测;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. brief 落到 HUD flash overlay delegate(协作 HUD #13 Story 008),本 layer self-hide — 与 Story 002 AC 一致
**Tech debt**: None new
**API surface**: `_render_event_by_density(event, density)` + `signal density_rendered(event_id, density, visible_panel)`
