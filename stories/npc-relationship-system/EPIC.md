# Epic: NPC Relationship System

> **Layer**: Core(⭐ 关键依赖节点)
> **GDD**: [design/gdd/npc-relationship-system.md](../../../design/gdd/npc-relationship-system.md)
> **Architecture Module**: NPC Relationship #8(Core)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: MEDIUM(典型 GDScript + typed Dict;via ADR-0009 `@abstract EventEffect` 引入)
> **Stories**: Not yet created — run `/create-stories npc-relationship-system`

## Overview

NPC Relationship System owns 8 NPC `relationship_score: int [-100, +100]` + per-NPC `flags: Dict[String, bool]` + 4 lifecycle 态(`ACTIVE` / `LEAVING_ANNOUNCED` / `LEFT` / `RETURNED`);F3 leave_probability per-NPC 8 套参数;`relationship_changed` / `npc_lifecycle_changed` / `npc_left_company` signal owner = #8;LEFT 视觉屏蔽 R-NPC-2(`HUD_EMPTY_CHAIR` variant + `accumulation_event("npc_empty_chairs", +1)`,via ADR-0005 单 owner = #5);LEAVING_ANNOUNCED 期间道别卡走 farewell event 路径(`farewell_event = true` flag,numeric_only 强制 — ADR-0001 + ADR-0009)。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | relationship_changed / npc_lifecycle_changed / npc_left_company signal owner = #8 | MEDIUM |
| [ADR-0005](../../../docs/architecture/adr-0005-lighting-accumulation-dimensions.md) | npc_empty_chairs 维度 trigger(`#8 npc_left_company` 驱动 + `#5` 单 emit accumulation_event)| LOW |
| [ADR-0009](../../../docs/architecture/adr-0009-event-schema-format.md) | farewell_event = true flag 5 离别事件 numeric_only 强制 | HIGH |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-npc-001 | 8 NPC schema + 4 lifecycle 态 | ⚠️ Partial(GDD-internal) |
| TR-npc-002 | F3 leave_probability per-NPC 8 套参数 | 📋 GDD-internal(numeric) |
| TR-npc-003 | relationship_changed / npc_lifecycle_changed / npc_left_company signal owner = #8 | ADR-0001 ✅ |
| TR-npc-004 | LEFT 视觉屏蔽 R-NPC-2 | ADR-0005 + ADR-0011 ✅ |
| TR-npc-005 | LEAVING_ANNOUNCED 期间道别卡 numeric_only 强制 | ADR-0001 + ADR-0009 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/npc-relationship-system.md` Section H 26 AC 全部 verify
- Logic stories(F3 leave_probability + 4 lifecycle 转移 + per-NPC flags)passing tests in `tests/unit/npc/`(MVP 必测)
- Integration stories(npc_left_company → #5 accumulation + #13 HUD_EMPTY_CHAIR + #10 farewell event 链)passing tests in `tests/integration/npc/`
- AC-FAREWELL-01 守门测试:LEAVING_ANNOUNCED 期间道别卡触发 farewell_event 时,#13 / #15 / #4 / #5 各自禁特殊 UI / BGM / palette
- OQ-NPC-01 effort 三维度参数 8 NPC 实测(Pre-Production /prototype)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [8 NPC Schema](story-001-eight-npc-schema.md) | Logic | Complete | ADR-0003 |
| 002 | [4 Lifecycle State Machine](story-002-four-lifecycle-states.md) | Logic | Complete | GDD Rule 7 |
| 003 | [F3 leave_probability 8 Params](story-003-f3-leave-probability.md) | Logic | Complete | GDD F3 |
| 004 | [RelationshipPhase 5-Tier](story-004-relationship-phase-five-tier.md) | Logic | Complete | GDD Rule 3 |
| 005 | [relationship_changed Signal](story-005-relationship-changed-signal.md) | Integration | Complete | ADR-0001 |
| 006 | [npc_lifecycle_changed Signal](story-006-npc-lifecycle-changed-signal.md) | Integration | Complete | ADR-0001 |
| 007 | [npc_left_company + R-NPC-2 Visual Block](story-007-npc-left-r-npc-2-guard.md) | Integration | Complete | ADR-0001 + ADR-0005 + ADR-0011 |
| 008 | [LEAVING_ANNOUNCED Farewell Card](story-008-leaving-announced-farewell-card.md) | Integration | Complete | ADR-0009 + ADR-0001 |
| 009 | [8 NPC Personality Definitions](story-009-eight-npc-personality-defs.md) | Config/Data | Complete | GDD Section A |
| 010 | [Month-End Leave Detection + Risk Guards](story-010-month-end-leave-detection.md) | Integration | Complete | GDD Rule 6 + R-NPC-1..5 |

**Story type breakdown**:4 Logic + 5 Integration + 1 Config/Data

## Next Step

依赖树:001 → 002 / 003 / 004 / 009 → 005 / 006 → 007 / 008 / 010
