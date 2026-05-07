# Story 008: Deadzone 3-Zone Formula F1

> **Epic**: input-handler
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-001`
**ADR Governing Implementation**: GDD-internal formula(F1)
**ADR Decision Summary**: `deadzone_inner = 0.15` / `deadzone_outer = 0.85`;3-zone 映射:r < inner → 0;inner ≤ r ≤ outer → 线性归一化 (r - inner) / (outer - inner);r > outer → 1.0(饱和)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `InputEventJoypadMotion.axis_value` 已在 Godot 内部走默认 deadzone 0.5;手动覆盖。

**Control Manifest Rules**:
- Required: F1 输出值 ∈ [0, 1] 且单调;无负数泄漏

## Acceptance Criteria

- [ ] F1 公式实施:`joystick_effective(r) = 0` if r < inner;`(r - inner) / (outer - inner)` if inner ≤ r ≤ outer;`1.0` if r > outer
- [ ] **AC-COMPAT-01** F1 deadzone 3-zone 映射 inner=0.15 / outer=0.85:r=0.10 → 0.0 + 无 act_focus_*;r=0.50 → ≈ 0.500(±0.005)+ fire act_focus_* + 不触发 skip;r=0.90 → 1.0(饱和)+ fire act_focus_* + skip 触发(> 0.8 阈值)

## Implementation Notes

```gdscript
# input_handler.gd
const DEADZONE_INNER := 0.15
const DEADZONE_OUTER := 0.85
const SKIP_AXIS_THRESHOLD := 0.8

func joystick_effective_axis(raw: float) -> float:
    var r := abs(raw)
    if r < DEADZONE_INNER:
        return 0.0
    if r > DEADZONE_OUTER:
        return 1.0 * sign(raw)
    var normalized := (r - DEADZONE_INNER) / (DEADZONE_OUTER - DEADZONE_INNER)
    return normalized * sign(raw)
```

## Out of Scope

- Story 009:F2 D-Pad repeat(独立公式)
- Story 012:Tuning knob clamp(独立守门)

## QA Test Cases

- **AC-COMPAT-01**:r=0.10 → 0.0;r=0.50 → 0.500 ±0.005;r=0.90 → 1.0;skip 触发仅 r > 0.8

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/deadzone_formula_test.gd`
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003(path arbitration 用 effective axis)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 2/2 COVERED via 9 test 函数
- F1 公式 3-zone 实施 → `joystick_effective_axis(raw: float) -> float` 读 `_deadzone_inner` / `_deadzone_outer` 运行时 tunable (Story 012 owned fields)
- AC-COMPAT-01 三点 trace (inner=0.15 / outer=0.85):
  - r=0.10 → 0.0 → `test_raw_below_inner_returns_zero`
  - r=0.50 → 0.500 ±0.005 → `test_raw_in_live_band_returns_normalized`
  - r=0.90 → 1.0 → `test_raw_above_outer_returns_saturated_one`
- 符号保留 (live + saturate) → `test_negative_raw_in_live_band_preserves_sign` + `test_negative_raw_above_outer_returns_saturated_negative_one`
- 边界 (r==inner / r==outer) → `test_raw_exactly_at_inner_boundary_returns_zero` + `test_raw_exactly_at_outer_boundary_returns_one`
- 单调性 invariant → `test_output_monotonicity_across_live_band` (r=0.20 < 0.50 < 0.80 → out_a < out_b < out_c, [0,1] bounds)
- 默认 tunable 集成 → `test_default_tunables_keep_mid_value_in_live_band` (公式读 runtime field 而非 hard-coded const)

**Test Evidence**: `tests/unit/input/deadzone_formula_test.gd` (320 行 / 9 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);
- F1 公式 3-zone 实施严格按 story line 28-43 piecewise:
  - `r < inner` → 0.0 (deadzone 短路,无符号泄漏 — control manifest "无负数泄漏" 守)
  - `r > outer` → `1.0 * signf(raw)` (saturation,符号保留)
  - 否则 → `((r - inner) / (outer - inner)) * signf(raw)` (linear normalisation,符号保留)
- 公式读 `_deadzone_inner` / `_deadzone_outer` 而非自定义 const — Story 012 tuning knobs 自动生效。
- 边界数学验证: r==inner 时 live branch 求值为 0.0 (`(0 - 0) / 0.7 = 0`),r==outer 时 live branch 求值为 1.0 (`(0.7 - 0) / 0.7 = 1`),deadzone branch 与 live branch 在边界处汇合 — 公式分段连续。
- 无 BLOCKING / 无 inline fix。

**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. **GDD-internal F1 (no separate ADR)**: control manifest #Input guardrail "F1 输出值 ∈ [0, 1] 且单调; 无负数泄漏" 是 source of truth — `test_output_monotonicity_across_live_band` + sign-preservation 双 test 覆盖该 invariant。

**Tech debt**: None new
**API surface**: `joystick_effective_axis(raw: float) -> float` (public)
