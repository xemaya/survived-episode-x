# Story 004: NPC 离职预兆(LEAVING_ANNOUNCED lifecycle 期间)

> **Epic**: Notification & Warning System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/notification-warning-system.md`
**Requirement**: Rule 3 + AC-FUNC-04/05

**ADR Governing Implementation**: ADR-0011 HUD Diegetic Render
**ADR Decision Summary**: NPC 离职预兆:`#8 NPC Relationship` emit `npc_lifecycle_changed(npc_id, from_state, to_state, reason)`,`#19` 在 `to_state == LEAVING_ANNOUNCED` 时转发 `warning_npc_leaving(npc_id)`;`to_state == LEFT` 时转发 `warning_npc_leaving_resolved(npc_id)`。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Presentation Layer)**:
- Required: 单点订阅 `#8 npc_lifecycle_changed`;按 npc_id 分别 idempotent
- Forbidden: 直接读 NPC.lifecycle_state(by `#8` own)
- Guardrail: dispatch ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-04: `#8` emit `npc_lifecycle_changed(LISA, ACTIVE, LEAVING_ANNOUNCED, "lisa_quit_better_offer")`,`#19` 接收,`warning_npc_leaving(LISA)` emit ≤ 1 帧;`_active_warnings["npc_leaving_LISA"] == true`
- [ ] AC-FUNC-05: `warning_npc_leaving(LISA)` 已激活,`#8` emit `npc_lifecycle_changed(LISA, LEAVING_ANNOUNCED, LEFT, ...)`,`warning_npc_leaving_resolved(LISA)` emit;`_active_warnings["npc_leaving_LISA"] == false`
- [ ] 多 NPC 同时离职:每 npc_id 独立 idempotent(LISA + WANG_ZONG 同时 LEAVING → 两次 emit 都成功)

---

## Implementation Notes

*From GDD Rule 3:*

```gdscript
func _ready() -> void:
    NPC.npc_lifecycle_changed.connect(_on_npc_lifecycle_changed)

func _on_npc_lifecycle_changed(npc_id: String, from_state: String, to_state: String, reason: String) -> void:
    var key := "npc_leaving_%s" % npc_id
    if to_state == "LEAVING_ANNOUNCED":
        _try_emit_warning(key, "warning_npc_leaving", [npc_id])
    elif to_state == "LEFT":
        _try_clear_warning(key, "warning_npc_leaving_resolved", [npc_id])
    elif from_state == "LEAVING_ANNOUNCED" and to_state == "ACTIVE":
        # NPC 改主意 / 留下来路径(若存在)
        _try_clear_warning(key, "warning_npc_leaving_resolved", [npc_id])
```

---

## Out of Scope

- Story 009: R-NW-2 LEFT NPC leak 防护
- `#8 NPC Relationship` Story 006(npc_lifecycle_changed)+ Story 008(leaving_announced_farewell_card)

---

## QA Test Cases

- **AC-FUNC-04**: LISA leaving
  - Given: NPC LISA lifecycle_state == ACTIVE
  - When: `npc_lifecycle_changed.emit(LISA, ACTIVE, LEAVING_ANNOUNCED, "...")`
  - Then: warning_npc_leaving(LISA) emit 1 次 ≤ 1 帧;_active_warnings["npc_leaving_LISA"] == true

- **AC-FUNC-05**: LISA LEFT
  - Given: warning_npc_leaving(LISA) 激活
  - When: `npc_lifecycle_changed.emit(LISA, LEAVING_ANNOUNCED, LEFT, ...)`
  - Then: warning_npc_leaving_resolved(LISA) emit + _active_warnings 清除
  - Edge cases: LISA 直接 ACTIVE → LEFT(跳过 LEAVING_ANNOUNCED,极少见)→ resolved 不 emit(因 warning 未激活)

- **AC-3**: 多 NPC 独立
  - Given: LISA + WANG_ZONG 同时 LEAVING_ANNOUNCED
  - When: 两次 lifecycle_changed
  - Then: warning_npc_leaving emit 2 次(LISA + WANG_ZONG 各 1)

---

## Test Evidence

**Required evidence**: `tests/integration/notification/npc_leaving_prediction_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001;`#8 NPC Relationship` Story 006(npc_lifecycle_changed signal)
- Unlocks: Story 009(R-NW-2 守门)

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 5 test 函数(AC-FUNC-04 leaving emit / AC-FUNC-05 LEFT resolve + retention 路径同清 / AC-3 双 NPC 独立 idempotent + skip-state no-op)
**Test Evidence**: `tests/integration/notification/npc_leaving_prediction_test.gd`(135 行 / 5 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED;handler 入口先做 R-NW-2 LEFT guard(Story 009 同处实现 — 二合一节省一个 connect),然后按 new_state 分派 emit / resolve / retention-resolve;每 NPC 独立 ledger key `npc_leaving_<npc_id>`;无 BLOCKING / 无 inline fix
**Deviations**(1 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `_on_npc_lifecycle_changed(npc, old_state, new_state, reason)` 受体(签名匹配 #8 当前 `npc_lifecycle_changed` 信号)— wiring 仅需 `NpcRel.npc_lifecycle_changed.connect(_system._on_npc_lifecycle_changed)`
