# Epic: Action Card System

> **Layer**: Feature(⭐ 关键依赖节点)
> **GDD**: [design/gdd/action-card-system.md](../../../design/gdd/action-card-system.md)
> **Architecture Module**: Action Card #11(Feature)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: HIGH(via ADR-0009 `@abstract` 4.5+ schema 派生 + ADR-0008 visual feedback)
> **Stories**: 9 created — see Stories section below

## Overview

Action Card System owns Card schema(派生 #10 EventResource schema 子集);AP cost 40/40/20 分布 lint(同 #7 AP cost 1/2/3);Hero `is_hero` flag + 互斥分组 + 4 态状态机(`IDLE` / `PLAYABLE` / `DISABLED` / `PLAYED`);`card_played(card_id)` signal owner = #11 + `kpi_contribution_reported` 累加 + `report_overage(card_id, kpi_delta)` 双向回调;hero_card_played 三 element 反馈(咖啡蒸汽 + 文件翻页 + NPC raised eyebrow + brightness +0.05;ADR-0008 mute_visual_parity 守)+ Hero 月内 4 次上限(`#7 AP Rule 12`)。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | card_played / kpi_contribution_reported / report_overage signal owner = #11;hero_card_played 反馈 cascade | MEDIUM |
| [ADR-0008](../../../docs/architecture/adr-0008-visual-boundary-pillar4-vs-mute-parity.md) | hero_card_played 三 element 反馈(克制 dignified 而非金光);brightness lift +0.05 0.5s | LOW |
| [ADR-0009](../../../docs/architecture/adr-0009-event-schema-format.md) | Card schema 派生 EventResource;EventTrigger.type = CARD | HIGH |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-card-001 | Card schema(派生 #10 EventResource schema 子集) | ADR-0009 ✅ |
| TR-card-002 | AP cost 40/40/20 分布 lint | 📋 GDD-internal(numeric) |
| TR-card-003 | Hero is_hero flag + 互斥分组 + 4 态 | ⚠️ Partial(architecture.md L122) |
| TR-card-004 | card_played + kpi_contribution_reported + report_overage 信号 | ADR-0001 ✅ |
| TR-card-005 | hero_card_played 三 element 反馈 | ADR-0008 + ADR-0011 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/action-card-system.md` Section H 全部 AC verify
- Logic stories(Card schema validation / 4 态状态机 / AP cost lint / 单卡完整链 7 步)passing tests in `tests/unit/card/`
- Integration stories(card_played → AP consume → game-time tick → KPI contribution → Event trigger 完整链)passing tests in `tests/integration/card/`
- Visual stories(hero_card_played 三 element 反馈 + brightness lift)evidence 在 `tests/evidence/`
- 5 类 Pillar 4 视觉零出现(visual lint 通过)
- mute_visual_parity 测试:全 mute 模式 Hero card 三 element 反馈仍触发

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [Card Schema (Derived)](story-001-card-schema-derived.md) | Logic | Complete | ADR-0009 |
| 002 | [AP Cost 40/40/20 Lint](story-002-ap-cost-40-40-20-lint.md) | Logic | Complete | AP Story 007 协作 |
| 003 | [Card 4-State Machine](story-003-four-state-machine.md) | Logic | Complete | GDD 状态机 |
| 004 | [Hero + Mutex + Monthly 4 Cap](story-004-hero-mutex-monthly-cap.md) | Logic | Complete | ADR-0008 |
| 005 | [try_play_card 7-Step Chain](story-005-try-play-card-seven-step.md) | Integration | Complete | architecture.md |
| 006 | [card_played + kpi_contribution Signals](story-006-card-played-signals.md) | Integration | Complete | ADR-0001 |
| 007 | [Hero Card 3-Element Reaction](story-007-hero-card-three-element-reaction.md) | Integration | Complete | ADR-0008 + ADR-0011 |
| 008 | [Farewell Card LIFECYCLE Guard](story-008-farewell-card-lifecycle-guard.md) | Integration | Complete | ADR-0009 |
| 009 | [Card Data .tres + Risk Guards](story-009-card-data-risk-guards.md) | Logic | Complete | GDD R-CARD-1..3 |

**Story type breakdown**:5 Logic + 4 Integration

## Next Step

依赖树:001 → 002 / 003 / 009 → 004 → 005 → 006 / 007 / 008
