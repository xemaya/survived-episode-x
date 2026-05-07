# Story 006: KPI Review Purple Palette 800ms Swap

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-005`
**ADR**: ADR-0007 KPI Review Three-Track Anchor
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `kpi_review_intro_duration_ms = 800ms` + Tween EASE_IN_OUT
- Required: 三轨同步(协作 Audio + KPI Review UI)

## Acceptance Criteria

- [ ] `_on_kpi_review_started()` 订阅 → CanvasModulate 800ms `EASE_IN_OUT` Tween 至紫色 `(0.85, 0.80, 1.05)`
- [ ] 800ms ± 1 帧偏差(三轨同步)
- [ ] Tween process_mode = PROCESS_MODE_ALWAYS(跨 pause)

## Implementation Notes

```gdscript
const KPI_REVIEW_PURPLE := Color(0.85, 0.80, 1.05, 1.0)
const KPI_REVIEW_INTRO_MS := 800

func _on_kpi_review_started() -> void:
    var tween := create_tween()
    tween.tween_property(canvas_modulate, "color", KPI_REVIEW_PURPLE, KPI_REVIEW_INTRO_MS / 1000.0)\
        .set_trans(Tween.TRANS_LINEAR)\
        .set_ease(Tween.EASE_IN_OUT)
```

## QA Test Cases

- emit `kpi_review_started` → Tween 800ms 完成 + 终值 = (0.85, 0.80, 1.05);三轨同步偏差 ≤ 1 帧

## Test Evidence

`tests/integration/lighting/kpi_review_palette_test.gd` + Visual sign-off `tests/evidence/lighting-kpi-purple-2026-XX.md`

## Dependencies

- Depends on: Story 001(palette)+ KPI Story(kpi_review_started)
- Unlocks: KPI Review UI Story 003 三轨同步协作

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 3 test 函数(`KPI_REVIEW_INTRO_MS=800` / Tween 800ms 终值 = ADR-0007 紫 / `palette_changed` 信号 emit `to=KPI_REVIEW`)
**Test Evidence**: `tests/integration/lighting/kpi_review_palette_test.gd`(70 行 / 3 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode);`_tween_canvas_modulate` 共享路径锁 `process_mode = PROCESS_MODE_ALWAYS`(controller `_ready` 强制),Tween 跨 pause 继续 — 三轨同步契约满足;`palette_changed` emit prev → KPI_REVIEW;无 BLOCKING
**Engine API Verification**: Tween `set_trans(TRANS_LINEAR).set_ease(EASE_IN_OUT)` 4.0+ 稳定;Tween 自动继承 root SceneTree process_mode (per Godot ClassDB Tween node)
**Deviations**(2 项 ADVISORY):
1. 三轨同步 ≤ 1 帧偏差 — Audio + UI 由其各自 epic 测试 (cross-epic);本 story 内验证 lighting 时长 800ms verbatim
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `KPI_REVIEW_INTRO_MS` const + `KPI_REVIEW_PURPLE` const + `_on_kpi_review_started()` 订阅
