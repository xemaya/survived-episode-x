# Story 006: kpi_review_started Signal + Three-Track 800ms

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-004` + `TR-kpi-008`
**ADR**: ADR-0007 KPI Review Three-Track Anchor + ADR-0001
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: kpi_review_started signal 单 owner = #9(3 subs:#16/#5/#4)
- Required: 三轨同步偏差 ≤ 1 帧;`kpi_review_intro_duration_ms = 800ms`

## Acceptance Criteria

- [ ] `signal kpi_review_started` owner = #9
- [ ] SceneFlow 转移 KPI_REVIEW 时 emit signal → #16/#5/#4 三 subs same-frame react(800ms anchor)
- [ ] 三轨同步偏差 ≤ 1 帧(自动化测试)

## Implementation Notes

```gdscript
signal kpi_review_started

func _on_scene_state_changed(_from: StringName, to: StringName) -> void:
    if to == &"KPI_REVIEW":
        emit_signal(&"kpi_review_started")
        # 3 subs(协作 stories):
        # → #16 KPI Review UI Story 003 (UI fade-in 800ms)
        # → #5 Lighting Story 006 (palette swap 800ms)
        # → #4 Audio Story 006 (cross-fade 800ms)
        _run_monthly_settlement()
```

## QA Test Cases

- SceneFlow → KPI_REVIEW → emit kpi_review_started + 3 subs same-frame react;偏差 ≤ 1 帧

## Test Evidence

`tests/integration/kpi/three_track_anchor_test.gd`(协作 #16 / #5 / #4 stories)

## Dependencies

- Depends on: SceneFlow Story 002 + KPI Review UI + Lighting + Audio stories
- Unlocks: 月末仪式
