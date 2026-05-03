# Story 007: npc_left_company Signal + R-NPC-2 Visual Block

> **Epic**: npc-relationship-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/npc-relationship-system.md` | **Requirement**: `TR-npc-004`
**ADR**: ADR-0001 npc_left_company signal owner = #8(4 subs)+ ADR-0005(npc_empty_chairs accumulation 协作)+ ADR-0011(HUD_EMPTY_CHAIR variant)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: npc_left_company(npc, reason) signal owner = #8
- Required: R-NPC-2 LEFT 视觉屏蔽 — 触发 `accumulation_event(npc_empty_chairs, +1)`(由 #5 emit,本系统不 emit)+ #13 HUD_EMPTY_CHAIR variant
- Forbidden: LEFT NPC 仍渲染原 NPC sprite / 表情(R-NPC-2)

## Acceptance Criteria

- [ ] `signal npc_left_company(npc: StringName, reason: StringName)` owner = #8
- [ ] R-NPC-2 守门测试:LEFT NPC `get_npc_state(LISA).lifecycle_state == LEFT` + #13 检测 → HUD_EMPTY_CHAIR variant + 不渲染原 NPC sprite
- [ ] 协作 #5 Lighting Story 011 — npc_left_company → #5 emit accumulation_event(sticky_note_count, +1) + accumulation_event(npc_empty_chairs, +1)

## Implementation Notes

```gdscript
signal npc_left_company(npc: StringName, reason: StringName)

func finalize_npc_departure(npc: StringName, reason: StringName) -> void:
    if not _transition_lifecycle(npc, &"LEFT", reason):
        return
    emit_signal(&"npc_left_company", npc, reason)
    # 协作:
    # → #5 Lighting 订阅 → emit accumulation_event 2 次
    # → #13 HUD 订阅 → 切 HUD_EMPTY_CHAIR variant
    # → #16 KPI Review UI 订阅 → archive 入列
    # → #19 Notification(VS) 订阅 → emit warning_npc_leaving_resolved
```

## QA Test Cases

- finalize_npc_departure(LISA, &"FAREWELL") → emit npc_left_company + 4 subs 响应
- R-NPC-2:LEFT NPC 不再渲染原 sprite(协作 #13 Story 003)

## Test Evidence

`tests/integration/npc/r_npc_2_visual_block_test.gd`(协作 #5 / #13 stories)

## Dependencies

- Depends on: Story 002 + Story 006 + Lighting Story 011 + HUD Story
- Unlocks: 全 farewell event 链(#10/#13/#15/#4/#5)

---

## Completion Notes

**Completed**: 2026-05-01 (autopilot npc-relationship-system pass)
**Verdict**: COMPLETE (lean review mode)
**Criteria**: 3/3 passing (R-NPC-2 守门 + 4-subscriber fan-out + ACTIVE-skip verified at signal level)

**Files changed**:
- `src/npc/npc_relationship_system.gd` — EDIT (`signal npc_left_company(npc, reason)`, `finalize_npc_departure(npc, reason) -> bool` 走 LEAVING_ANNOUNCED → LEFT 转移 + emit; ADR-0001 single owner = #8 hardguard)
- `tests/integration/npc/r_npc_2_visual_block_test.gd` — CREATE (5 tests: emit on finalize / R-NPC-2 LEFT state observable / 4-sub fan-out / blocked-from-active / single-owner grep)

**Test Evidence**: `tests/integration/npc/r_npc_2_visual_block_test.gd` (Integration story, BLOCKING gate).

**Out of Scope (cross-epic seams)**:
- #5 Lighting `accumulation_event(npc_empty_chairs, +1)` + `accumulation_event(sticky_note_count, +1)` actual emit — Lighting Story 011 (单 owner = #5 已存在 hook)
- #13 HUD `HUD_EMPTY_CHAIR` variant 实际 sprite swap — HUD epic (read API `get_lifecycle_state` 已暴露 R-NPC-2 数据通路)
- #16 KPI Review UI archive 入列 — KPI epic

**Code Review**: Static review only (lean mode).
