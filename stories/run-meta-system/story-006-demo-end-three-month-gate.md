# Story 006: Demo End 3-Month Gate

> **Epic**: run-meta-system | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/run-meta-system.md` | **Requirement**: `TR-run-meta-004`
**ADR**: entities.yaml `DEMO_END_MONTH = 3`
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: demo build 仅 3 月 gate;月 4 触发 demo end 屏

## Acceptance Criteria

- [ ] const `DEMO_END_MONTH = 3`(从 entities.yaml 引用)
- [ ] Demo build 月末检测:`SceneDayFlowController.month_index == 3` 末尾 → emit `demo_end_reached` + transition DEMO_END sub-mode
- [ ] Full build:DEMO_END_MONTH = -1(disabled)+ 不限制

## Implementation Notes

```gdscript
const DEMO_END_MONTH := 3  # entities.yaml

func _on_kpi_review_started() -> void:
    # KPI Review UI 完成后检测
    if _is_demo_build() and SceneDayFlowController.month_index >= DEMO_END_MONTH:
        emit_signal(&"demo_end_reached")
        SceneDayFlowController.request_transition(&"DEMO_END")

func _is_demo_build() -> bool:
    return ProjectSettings.get_setting("application/build_type", "full") == "demo"
```

## QA Test Cases

- demo build M3 末 → demo_end_reached + DEMO_END sub-mode
- full build M3 末 → 正常 M4

## Test Evidence

`tests/integration/run_meta/demo_end_test.gd`

## Dependencies

- Depends on: Story 001 + KPI Story 005
- Unlocks: Demo build pipeline

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 8 test 函数
**Test Evidence**: `tests/integration/run_meta/demo_end_test.gd` (155 行 / 8 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);const DEMO_END_MONTH=3 + check_demo_end_gate(month) demo-only 触发;build_type 检测走 ProjectSettings.application/build_type + test override seam(set_build_type_for_test);re-entry guard 一 session 一 emit;Demo M3 触发 / Demo M4 也触发(cheat-skip 场景)/ Full M3 + M12 静默 / Demo M1+M2 静默 / 无 ProjectSettings 默认 full 五种边界覆盖;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. SceneDayFlowController.month_index 联动暂未 wire(KPI Story 005 完成后才能在月末自动触发)— 本 story 提供 check_demo_end_gate(month) 入口供 KPI Review UI 调用
**Tech debt**: None new
**API surface**: const `DEMO_END_MONTH=3` / `BUILD_TYPE_SETTING_PATH="application/build_type"`;`check_demo_end_gate(month: int) -> bool` / `is_demo_build() -> bool` / `has_demo_end_been_reached() -> bool` / `set_build_type_for_test(build_type)`;signal `demo_end_reached`
