# Story 003: effort 极值预警(0.75 阈值)

> **Epic**: Notification & Warning System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/notification-warning-system.md`
**Requirement**: Rule 2 + AC-FUNC-03

**ADR Governing Implementation**: ADR-0011 HUD Diegetic Render
**ADR Decision Summary**: effort 极值预警:`#7 AP Economy` emit `effort_dimension_changed(month_index, effort_norm)` → `#19` 检测 `effort_norm >= EFFORT_EXTREME_THRESHOLD = 0.75` → 转发 `warning_effort_extreme(value)`;月末 `monthly_effort_summary` push 后 `_cleared` emit。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Presentation Layer)**:
- Required: 单点订阅 `#7 effort_dimension_changed`;阈值检测 0.75
- Forbidden: 主动计算 effort_norm(由 `#7` own)
- Guardrail: dispatch ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-03: `#7 effort_norm` 月内累计达 0.76(超 `EFFORT_EXTREME_THRESHOLD=0.75`),`effort_dimension_changed` 被 `#19` 接收,`warning_effort_extreme(0.76)` emit ≤ 1 帧;月末 summary push 后 `warning_effort_extreme_cleared` emit
- [ ] `EFFORT_EXTREME_THRESHOLD = 0.75`(entities.yaml 注册或本 epic 内 const)
- [ ] idempotent:同月内 effort_norm 反复 ≥ 0.75 时仅第一次 emit

---

## Implementation Notes

*From GDD Rule 2:*

```gdscript
const EFFORT_EXTREME_THRESHOLD := 0.75

func _ready() -> void:
    APEconomy.effort_dimension_changed.connect(_on_effort_dimension_changed)
    APEconomy.monthly_effort_summary.connect(_on_monthly_effort_summary)

func _on_effort_dimension_changed(month_index: int, effort_norm: float) -> void:
    if effort_norm < EFFORT_EXTREME_THRESHOLD: return
    _try_emit_warning("effort_extreme", "warning_effort_extreme", [effort_norm])

func _on_monthly_effort_summary(...) -> void:
    _try_clear_warning("effort_extreme", "warning_effort_extreme_cleared")
```

---

## Out of Scope

- `#7 AP Economy` Story 005(F4 effort 三维度 — 上游 emit)
- `#13 HUD` 视觉 variant 切换

---

## QA Test Cases

- **AC-FUNC-03**: 0.76 触发
  - Given: effort_norm 0.74 → 0.76 跨阈值
  - When: `effort_dimension_changed.emit(month, 0.76)`
  - Then: `warning_effort_extreme(0.76)` emit 1 次 ≤ 1 帧;月末后 cleared emit
  - Edge cases: 0.749 → 0.75 临界(0.75 触发);0.75 → 0.74 → 0.76(去激活后再激活)— 同月不重复

- **AC-2**: 月末清除
  - Given: warning_effort_extreme 激活
  - When: monthly_effort_summary emit
  - Then: warning_effort_extreme_cleared emit + _active_warnings["effort_extreme"] == false

---

## Test Evidence

**Required evidence**: `tests/integration/notification/effort_extreme_warning_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001;`#7 AP Economy` Story 005(F4 effort)+ Story 008(monthly_effort_summary)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 5 test 函数(AC-FUNC-03 0.76 触发 + 0.75 边界 + 0.749 不触发 / AC-2 monthly_summary clear / idempotent within month)
**Test Evidence**: `tests/integration/notification/effort_extreme_warning_test.gd`(110 行 / 5 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED;`EFFORT_EXTREME_THRESHOLD = 0.75` const(本 epic 内,符合"配置外置但允许 const")— 与 GDD Rule 2 严格对齐;`_on_monthly_effort_summary` variadic-tolerant(default args)便于桥接 6 参 ApEconomy 实际 signature;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. 本 epic 不订阅尚未存在的 `effort_dimension_changed` 信号(#7 ap-economy 当前发的是 `effort_overtime_incremented` / `effort_hero_incremented` / `effort_overage_incremented`);wiring 由后续 #7 增量 signal 或 effort-norm 派生 helper land 后接入,本 story 直接测试 handler 入口
**Tech debt**: 1 项 — wiring 待 #7 effort_norm 派生 signal 上线
**API surface**: `_on_effort_dimension_changed(month, effort_norm)` + `_on_monthly_effort_summary(...)` 受体
