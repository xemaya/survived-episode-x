# Story 002: capacity_floor 预警(R-AP-5 + R-KPI-3 agency 守门)

> **Epic**: Notification & Warning System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/notification-warning-system.md`
**Requirement**: Rule 1 + AC-FUNC-01/02

**ADR Governing Implementation**: ADR-0011 HUD Diegetic Render
**ADR Decision Summary**: capacity_floor 预警:`#9 KPI` emit `capacity_warning_emitted(month_index, capacity_now, threshold_now)` → `#19` 转发 `warning_capacity_critical(severity, month_index)` → `#13 HUD diegetic` 切换 capacity 显示 variant(色调变冷)。同月不重复 emit(idempotent per Story 001)。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Presentation Layer)**:
- Required: 单点订阅 `#9 capacity_warning_emitted`;转发到 `warning_capacity_critical`
- Forbidden: 直接 popup / 弹层(R-NW-1 守门)
- Guardrail: dispatch ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-01: `#9` emit `capacity_warning_emitted(month_index=9, capacity_now=0.65, threshold_now=200)`,`#19` 接收信号,`warning_capacity_critical(severity=1, month_index=9)` 在 ≤ 1 帧内 emit 给 `#13`
- [ ] AC-FUNC-02: `_active_warnings["capacity_critical"] == true`(已激活),`#9` 同月再次 emit `capacity_warning_emitted(severity=1)`,`#19` 不重复 emit `warning_capacity_critical`
- [ ] severity 计算(per Rule 1):capacity_now ≤ 0.7 → severity=1;capacity_now ≤ 0.5 → severity=2;capacity_now ≤ 0.3 → severity=3
- [ ] 月末进入 KPI_REVIEW → `_try_clear_warning("capacity_critical", "warning_capacity_critical_cleared")`;次月可再次触发

---

## Implementation Notes

*From GDD Rule 1:*

```gdscript
# notification_warning.gd
func _ready() -> void:
    KPI.capacity_warning_emitted.connect(_on_capacity_warning)
    SceneFlow.scene_state_changed.connect(_on_scene_state_changed)

func _on_capacity_warning(month_index: int, capacity_now: float, threshold_now: int) -> void:
    var severity := 0
    if capacity_now <= 0.3: severity = 3
    elif capacity_now <= 0.5: severity = 2
    elif capacity_now <= 0.7: severity = 1
    if severity == 0: return
    _try_emit_warning(
        "capacity_critical",
        "warning_capacity_critical",
        [severity, month_index]
    )

func _on_scene_state_changed(from, to, ctx) -> void:
    if to == SubMode.KPI_REVIEW:
        _try_clear_warning("capacity_critical", "warning_capacity_critical_cleared")
```

---

## Out of Scope

- Story 001: 信号架构 + idempotent
- `#9 KPI` Story 011(kpi_prediction_hint + capacity_warning_emitted emit)
- `#13 HUD` Story 005(accumulation_visual_variant — capacity color 切换)

---

## QA Test Cases

- **AC-FUNC-01**: 单次 emit
  - Given: `_active_warnings["capacity_critical"] == false`
  - When: `KPI.capacity_warning_emitted.emit(9, 0.65, 200)`
  - Then: 1 帧内 `warning_capacity_critical(1, 9)` emit 1 次
  - Edge cases: capacity_now == 0.71 → severity=0,不 emit;capacity_now == 0.3 → severity=3

- **AC-FUNC-02**: idempotent
  - Given: `warning_capacity_critical` 已激活
  - When: `KPI.capacity_warning_emitted.emit(9, 0.55, ...)`(同月再次)
  - Then: emit 总次数仍为 1(防重)

- **AC-3**: 月末清除
  - Given: warning 激活
  - When: scene_state_changed(→KPI_REVIEW)
  - Then: warning_capacity_critical_cleared emit + _active_warnings["capacity_critical"] == false;次月初再次 trigger 可重新 emit

---

## Test Evidence

**Required evidence**: `tests/integration/notification/capacity_floor_warning_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001;`#9 KPI` Story 011(capacity_warning_emitted)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 6 test 函数(AC-FUNC-01 三个 severity 边界 / AC-FUNC-02 idempotent / AC-3 KPI_REVIEW clear + re-trigger 次月)
**Test Evidence**: `tests/integration/notification/capacity_floor_warning_test.gd`(135 行 / 6 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean autopilot inline);`_on_capacity_warning(month, capacity_now, threshold_now)` 严格遵循 ADR-0011 单点订阅 + 转发;severity 计算静态查表;KPI_REVIEW 是清除触发点;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. 上游 `KPI.capacity_warning_emitted` signal 在 #9 仍未 emit(本 epic 测试通过直接调用 handler 模拟);wiring 迁移到 #9 Story 011 land 后只需 `KPI.capacity_warning_emitted.connect(_system._on_capacity_warning)` 一行
**Tech debt**: None new
**API surface**: `_on_capacity_warning(month_index, capacity_now, threshold_now)` 受体 + KPI_REVIEW 自动 clear path
