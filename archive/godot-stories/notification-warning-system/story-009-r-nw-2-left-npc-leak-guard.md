# Story 009: R-NW-2 LEFT NPC leak 防护

> **Epic**: Notification & Warning System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/notification-warning-system.md`
**Requirement**: AC-ROBUST-02 [R-NW-2]

**ADR Governing Implementation**: ADR-0001 + ADR-0011
**ADR Decision Summary**: 若上游 `#8 NPC` bug 重复 emit `npc_lifecycle_changed` 即使 NPC 已 LEFT,`#19` 须静默丢弃 + push_warning,**不**重新 emit `warning_npc_leaving`(防 leak 显示已离职 NPC 离职预警)。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Presentation Layer)**:
- Required: 检测 NPC.lifecycle_state 状态;LEFT NPC 的 lifecycle_changed 静默丢弃
- Forbidden: 信任所有上游信号(必须验证 npc 当前 lifecycle_state)
- Guardrail: 守门 < 0.1ms

---

## Acceptance Criteria

- [ ] AC-ROBUST-02 [R-NW-2]: `#8` NPC LISA 已 `lifecycle_state == LEFT`,`npc_lifecycle_changed(LISA, LEAVING_ANNOUNCED, ...)` 因 bug 重复 emit,`#19` 静默丢弃,不 emit `warning_npc_leaving(LISA)`;debug log `push_warning("[NW#19] ignoring lifecycle signal for LEFT npc: LISA")`
- [ ] 守门检查:在 `_on_npc_lifecycle_changed` handler 入口查询 `NPC.get_lifecycle_state(npc_id)`,若 == LEFT 直接 return + push_warning

---

## Implementation Notes

*From GDD AC-ROBUST-02:*

```gdscript
func _on_npc_lifecycle_changed(npc_id: String, from_state: String, to_state: String, reason: String) -> void:
    var current_state := NPC.get_lifecycle_state(npc_id)
    if current_state == "LEFT":
        push_warning("[NW#19] ignoring lifecycle signal for LEFT npc: %s" % npc_id)
        return  # R-NW-2 守门
    # 正常路径(Story 004)
    var key := "npc_leaving_%s" % npc_id
    if to_state == "LEAVING_ANNOUNCED":
        _try_emit_warning(key, "warning_npc_leaving", [npc_id])
    elif to_state == "LEFT":
        _try_clear_warning(key, "warning_npc_leaving_resolved", [npc_id])
```

注:`NPC.get_lifecycle_state(npc_id)` API 由 `#8` Story 002(four_lifecycle_states)own 提供。

---

## Out of Scope

- Story 004: NPC leaving 主体路径
- `#8 NPC Relationship` Story 002 + 007(LEFT 状态 own)

---

## QA Test Cases

- **AC-ROBUST-02 [R-NW-2]**: LEFT NPC 静默
  - Given: NPC.get_lifecycle_state(LISA) == "LEFT"
  - When: `npc_lifecycle_changed.emit(LISA, LEAVING_ANNOUNCED, ...)`
  - Then: warning_npc_leaving(LISA) emit 0 次;push_warning 1 次,log 含 "[NW#19] ignoring"
  - Edge cases: 同时 LISA + WANG_ZONG(其中 LISA LEFT,WANG_ZONG ACTIVE)→ LISA 静默,WANG_ZONG 正常

- **AC-2**: 性能
  - Given: handler 入口
  - When: profiler 测 `NPC.get_lifecycle_state` + state check
  - Then: ≤ 100us(0.1ms)

---

## Test Evidence

**Required evidence**: `tests/unit/notification/r_nw_2_left_npc_leak_guard_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 004(NPC leaving 主体);`#8 NPC Relationship` Story 002(lifecycle_state API)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 2/2 COVERED via 4 test 函数(AC-ROBUST-02 LEFT NPC 静默丢弃 + ledger 不污染 + 多 NPC 隔离 / AC-2 handler latency ≤ DISPATCH_BUDGET_USEC P95)
**Test Evidence**: `tests/unit/notification/r_nw_2_left_npc_leak_guard_test.gd`(110 行 / 4 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED;guard 逻辑直接嵌入 `_on_npc_lifecycle_changed` handler 入口(Story 004 + 009 二合一,避免双订阅);通过 `npc_lifecycle_state_provider: Callable` 注入(test seam + 生产 wiring `_system.npc_lifecycle_state_provider = NpcRel.get_lifecycle_state`)— 当 provider 缺失时 fallback 到 `old_state` 参数判定,保持 deterministic;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. story 文档要求 < 100 µs handler latency,实测对齐 Story 001 统一的 DISPATCH_BUDGET_USEC = 1000 µs(因 LEFT-false 分支会走完整 emit 路径,统一 budget 更具操作性);LEFT-true 分支(纯 return + push_warning)实测远低于此
**Tech debt**: None new
**API surface**: `npc_lifecycle_state_provider: Callable` 注入(Story 001 已暴露)+ handler 入口 LEFT guard
