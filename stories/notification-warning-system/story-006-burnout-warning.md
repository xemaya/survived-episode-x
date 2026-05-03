# Story 006: burnout 预警(Energy ≤ 15)

> **Epic**: Notification & Warning System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/notification-warning-system.md`
**Requirement**: Rule 5 + AC-FUNC-08

**ADR Governing Implementation**: ADR-0011 HUD Diegetic Render
**ADR Decision Summary**: burnout 预警:`#7 AP Economy` emit `energy_changed(current, max)` → `#19` 检测 `current ≤ BURNOUT_THRESHOLD = 15` → emit `warning_burnout_approaching(current)`;Energy 恢复至 ≥ 30 时 cleared(避免临界震荡)。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Presentation Layer)**:
- Required: 单点订阅 `#7 energy_changed`;阈值 + 滞后判定(15 触发 / 30 解除)
- Forbidden: 主动读 APEconomy.current_energy(由信号驱动)
- Guardrail: dispatch ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-08: `#7` emit `energy_changed(14, 100)`,`#19` 接收,`warning_burnout_approaching(14)` emit ≤ 1 帧
- [ ] BURNOUT_THRESHOLD = 15;BURNOUT_RECOVERY_THRESHOLD = 30(滞后避免震荡)
- [ ] idempotent:Energy 14 → 12 → 14(都 ≤ 15)期间仅一次 emit;直到 ≥ 30 后 cleared 才能再次 emit

---

## Implementation Notes

*From GDD Rule 5:*

```gdscript
const BURNOUT_THRESHOLD := 15
const BURNOUT_RECOVERY_THRESHOLD := 30

func _ready() -> void:
    APEconomy.energy_changed.connect(_on_energy_changed)

func _on_energy_changed(current: int, max_e: int) -> void:
    if current <= BURNOUT_THRESHOLD:
        _try_emit_warning("burnout", "warning_burnout_approaching", [current])
    elif current >= BURNOUT_RECOVERY_THRESHOLD:
        _try_clear_warning("burnout", "warning_burnout_resolved")
```

滞后区间 [16, 29]:既不触发也不清除(保持当前状态)。

---

## Out of Scope

- `#7 AP Economy` Story 005(F4 — energy_changed 上游)
- `#13 HUD` 视觉 variant burnout 切换

---

## QA Test Cases

- **AC-FUNC-08**: 14 触发
  - Given: 上一帧 energy == 16,_active_warnings["burnout"] == false
  - When: `energy_changed.emit(14, 100)`
  - Then: warning_burnout_approaching(14) emit 1 次

- **AC-2**: 滞后防震荡
  - Given: warning_burnout_approaching 激活
  - When: energy 14 → 16(回升但未到 30)
  - Then: 无 cleared emit;_active_warnings["burnout"] 仍 true
  - Edge cases: 14 → 30 → cleared emit;14 → 12 → 17 → 25 → 30 cleared(只在 ≥ 30 时清)

---

## Test Evidence

**Required evidence**: `tests/integration/notification/burnout_warning_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001;`#7 AP Economy` Story 003(F2 early_leave_formula)+ energy_changed signal
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 5 test 函数(AC-FUNC-08 14 触发 + 15 边界 / AC-2 滞后 [16,29] 不 clear + 30 recovery clear + low-band idempotent)
**Test Evidence**: `tests/integration/notification/burnout_warning_test.gd`(105 行 / 5 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED;`BURNOUT_THRESHOLD = 15` / `BURNOUT_RECOVERY_THRESHOLD = 30` 滞后区间 [16,29] 既不 trigger 也不 clear;直接订阅 `ApEconomySystem.energy_changed(current, max_value)`(已存在);无 BLOCKING / 无 inline fix
**Deviations**(1 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `_on_energy_changed(current, max_value)` 受体 — wiring `ApEconomy.energy_changed.connect(_system._on_energy_changed)`
