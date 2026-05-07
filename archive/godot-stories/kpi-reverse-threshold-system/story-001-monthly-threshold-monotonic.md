# Story 001: monthly_threshold + Anti-P1 Monotonic Increase

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-001`
**ADR**: architecture.md principle 2(Anti-P1 红线 — threshold 单调递增)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `monthly_threshold: int` 单调递增(月末更新只增不降)
- Forbidden: threshold 反向调低 — Anti-P1 PR-blocking + push_error

## Acceptance Criteria

- [ ] state vars:`monthly_threshold: int`(初始 100)+ `month_index: int`(初始 0)+ `actual_kpi_history: Array[float]`
- [ ] `update_threshold(new: int)` API:守门 `new > monthly_threshold`(单调递增);失败 push_error
- [ ] Anti-P1 lint:`tools/anti_p1_lint.py` 检测 effect/event 反向调 threshold → CI FAIL

## Implementation Notes

```gdscript
extends Node
var monthly_threshold: int = 100
var month_index: int = 0
var actual_kpi_history: Array[float] = []

func update_threshold(new_threshold: int) -> void:
    if new_threshold <= monthly_threshold:
        push_error("ERR_KPI_MONOTONIC: threshold must monotonically increase (got %d, current %d)" % [new_threshold, monthly_threshold])
        return
    monthly_threshold = new_threshold
```

## QA Test Cases

- new < current → push_error;new > current → 应用
- Anti-P1 lint:effect 含 `threshold_offset_decrease` → CI FAIL

## Test Evidence

`tests/unit/kpi/threshold_monotonic_test.gd`

## Dependencies

- Depends on: None
- Unlocks: 全 KPI stories
