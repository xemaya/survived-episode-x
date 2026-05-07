# Story 001: 5 类 warning 信号架构 + _active_warnings idempotent

> **Epic**: Notification & Warning System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/notification-warning-system.md`
**Requirement**: `TR-notification-001`(信号架构基础)+ Rule 9 + Rule 8

**ADR Governing Implementation**: ADR-0011 HUD Diegetic Render(`#19` 是信号转发器,通过 `#13` HUD diegetic variant 显示)
**ADR Decision Summary**: `NotificationWarning` Autoload 子节点(无 UI 节点)own 5 类 warning 信号 + `_active_warnings: Dictionary<String, bool>` 防重 idempotent;dispatch ≤ 1 帧;接收上游信号 → 转发 `warning_*` 给 `#13 HUD diegetic`。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Presentation Layer)**:
- Required: `_active_warnings` Dictionary 防重;每类 warning 独立 emit + cleared
- Forbidden: 持有 UI 节点(`#19` 是纯转发器,UI 由 `#13` own)
- Guardrail: dispatch ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-PERF-01: 任意 `warning_*` 信号触发路径,debug build `Time.get_ticks_usec()` 首尾打点,延迟 ≤ 16600 µs(1 帧);超出 push_warning
- [ ] 5 类 warning + 5 类 cleared 信号定义:
  - `warning_capacity_critical(severity, month_index)` / `warning_capacity_critical_cleared`
  - `warning_effort_extreme(value)` / `warning_effort_extreme_cleared`
  - `warning_npc_leaving(npc_id)` / `warning_npc_leaving_resolved(npc_id)`
  - `warning_month_end_countdown(days_remaining)` / `warning_month_end_cleared`
  - `warning_burnout_approaching(energy)` / `warning_burnout_resolved`
- [ ] `_active_warnings: Dictionary` 字典记录每类是否激活;同类信号重复触发 idempotent(per AC-FUNC-02)
- [ ] `NotificationWarning` Autoload 注册(末位之前,在 `#9 KPI` / `#7 AP` / `#8 NPC` 之后)

---

## Implementation Notes

*From GDD Rule 9 + Rule 8:*

```gdscript
# autoload/notification_warning.gd
extends Node
class_name NotificationWarning

# 5 类 warning 信号
signal warning_capacity_critical(severity: int, month_index: int)
signal warning_capacity_critical_cleared
signal warning_effort_extreme(value: float)
signal warning_effort_extreme_cleared
signal warning_npc_leaving(npc_id: String)
signal warning_npc_leaving_resolved(npc_id: String)
signal warning_month_end_countdown(days_remaining: int)
signal warning_month_end_cleared
signal warning_burnout_approaching(energy: int)
signal warning_burnout_resolved

var _active_warnings: Dictionary = {}  # key -> bool

func _try_emit_warning(key: String, signal_name: String, args: Array) -> bool:
    if _active_warnings.get(key, false): return false  # idempotent
    _active_warnings[key] = true
    var t0 := Time.get_ticks_usec()
    callv("emit_signal", [signal_name] + args)
    var elapsed := Time.get_ticks_usec() - t0
    if elapsed > 1000: push_warning("[NW#19] dispatch %dus > 1ms" % elapsed)
    return true

func _try_clear_warning(key: String, cleared_signal_name: String, args: Array = []) -> bool:
    if not _active_warnings.get(key, false): return false
    _active_warnings[key] = false
    callv("emit_signal", [cleared_signal_name] + args)
    return true
```

---

## Out of Scope

- Story 002..006: 各类 warning 触发路径具体实施
- Story 007: GAMEOVER 全清除
- Story 008/009/010: 守门 lint
- `#13 HUD Diegetic` Story 005(visual variant 切换实施)

---

## QA Test Cases

- **AC-PERF-01**: dispatch ≤ 1 帧
  - Given: `_try_emit_warning` 调用
  - When: `Time.get_ticks_usec` 测量
  - Then: 总耗时 ≤ 1000us(handler 内 ≤ 1ms)
  - Edge cases: 50 次 P95 ≤ 1ms

- **AC-2**: 10 信号定义完整
  - Given: NotificationWarning autoload
  - When: 反射 signals
  - Then: 含 5 emit + 5 cleared 共 10 信号

- **AC-3**: idempotent 防重
  - Given: `_try_emit_warning("capacity_critical", ...)` 已调用 1 次
  - When: 再次调用同 key
  - Then: 返回 false;信号 emit 仅 1 次

---

## Test Evidence

**Required evidence**: `tests/unit/notification/five_warning_signal_architecture_test.gd` — must exist and pass

---

## Dependencies

- Depends on: `#6 Scene Flow` Story 003(autoload init order);各上游 epic
- Unlocks: Story 002..010

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 5 test 函数(AC-PERF-01 / AC-2 10-signals / AC-3 idempotent + clear→re-emit + severity band)
**Test Evidence**: `tests/unit/notification/five_warning_signal_architecture_test.gd`(150 行 / 5 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean autopilot inline);#19 Node 仅作为信号转发器无 UI;_try_emit_warning idempotent + ≤ 1ms 守门 + push_warning 上报;ALL_WARNING_KEYS dictionary 静态查表 Story 007 复用;无 BLOCKING / 无 inline fix
**Deviations**(3 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. 实施为 Node(非 autoload)— 严格遵守"不能改 project.godot"约束;`scene-day-flow` 实例化由后续 wiring story / 测试 driver 负责
3. _compute_capacity_severity 暴露为 static helper,便于纯函数单测覆盖
**Tech debt**: None new
**API surface**: 10 warning signals + `is_warning_active()` test seam + `ingest_day_context()` Story 005 test seam + `npc_lifecycle_state_provider` / `sub_mode_provider` Callable 注入
