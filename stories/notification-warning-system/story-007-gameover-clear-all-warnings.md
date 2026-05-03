# Story 007: GAMEOVER 时全预警清除

> **Epic**: Notification & Warning System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/notification-warning-system.md`
**Requirement**: AC-FUNC-09

**ADR Governing Implementation**: ADR-0011(死亡路径不可逆)
**ADR Decision Summary**: GAMEOVER sub-mode 进入时,`#19` 强制清除所有 `_active_warnings`;每个 cleared 信号 emit 1 次;Pillar 3 死亡仪式不被 warning 残留干扰。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Presentation Layer)**:
- Required: GAMEOVER 路径无条件清除全部 warnings
- Forbidden: 选择性保留某些 warning(违反 Pillar 3)
- Guardrail: 清除路径 ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-09: `warning_capacity_critical` + `warning_npc_leaving(LISA)` + `warning_month_end_countdown(1)` 同时活跃,`scene_state_changed(→GAMEOVER)` 触发,`_clear_all_warnings()` 执行;`_active_warnings` 全空;对应 `*_cleared` 信号全部 emit
- [ ] 清除路径单点;无遗漏类
- [ ] GAMEOVER 之后 warning 不能再次触发(state 永久锁,直到 Main Menu 开新 Run reset autoload)

---

## Implementation Notes

*From GDD AC-FUNC-09:*

```gdscript
const ALL_WARNING_KEYS := {
    "capacity_critical": "warning_capacity_critical_cleared",
    "effort_extreme": "warning_effort_extreme_cleared",
    "month_countdown_3": "warning_month_end_cleared",
    "month_countdown_2": "warning_month_end_cleared",
    "month_countdown_1": "warning_month_end_cleared",
    "burnout": "warning_burnout_resolved",
    # NPC leaving 类 npc_id 动态,单独处理
}

func _on_scene_state_changed(from, to, ctx) -> void:
    if to == SubMode.GAMEOVER:
        _clear_all_warnings()

func _clear_all_warnings() -> void:
    for key in ALL_WARNING_KEYS:
        _try_clear_warning(key, ALL_WARNING_KEYS[key])
    # NPC leaving:遍历 _active_warnings 找 "npc_leaving_*" 前缀
    for key in _active_warnings.keys():
        if key.begins_with("npc_leaving_") and _active_warnings[key]:
            var npc_id := key.trim_prefix("npc_leaving_")
            _try_clear_warning(key, "warning_npc_leaving_resolved", [npc_id])
```

---

## Out of Scope

- Story 002..006 各类 warning 触发
- GAMEOVER sub-mode dispatch(`#16` Story 005)

---

## QA Test Cases

- **AC-FUNC-09**: 全清除
  - Given: 三类 warnings 同时激活(capacity / npc_leaving LISA / month_countdown 1)
  - When: scene_state_changed(→GAMEOVER)
  - Then: _active_warnings 全 false + 三个 cleared signals 全 emit
  - Edge cases: 全部 warning 类型同时激活 → 清除 ≤ 1 帧

- **AC-2**: GAMEOVER 后不再触发
  - Given: GAMEOVER 后,人为 emit `KPI.capacity_warning_emitted` 测试桩
  - When: `_on_capacity_warning` 进入
  - Then: 不 emit warning(state 检查 `if SceneFlow.current_sub_mode == GAMEOVER: return`)

---

## Test Evidence

**Required evidence**: `tests/integration/notification/gameover_clear_all_warnings_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001..006;`#6 Scene Flow` Story 002 + `#16 KPI Review UI` Story 005(GAMEOVER 1500ms transition)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 3 test 函数(AC-FUNC-09 静态 ledger 全清 capacity+burnout+month / 动态 npc_leaving_* 双 NPC 都 resolve / AC-2 sub_mode_provider GAMEOVER 锁定 — 后续 emit 被拒)
**Test Evidence**: `tests/integration/notification/gameover_clear_all_warnings_test.gd`(125 行 / 3 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED;`_clear_all_warnings()` 单点路径,先清静态 `ALL_WARNING_KEYS` 再扫 `npc_leaving_*` 动态 keys(快照副本避免 mutation during iteration);`_is_gameover()` 通过 `sub_mode_provider` Callable 注入,无 provider 时不锁定(向后兼容);无 BLOCKING / 无 inline fix
**Deviations**(1 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `_clear_all_warnings()` 内部触发 + `sub_mode_provider: Callable` 注入(test seam + 生产环境 wiring `_system.sub_mode_provider = func(): return SceneFlow.current_sub_mode`)
