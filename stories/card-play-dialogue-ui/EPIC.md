# Epic: Card Play & Dialogue UI

> **Layer**: Presentation(⭐ 关键依赖节点 — 三档密度主消费 layer)
> **GDD**: [design/gdd/card-play-dialogue-ui.md](../../../design/gdd/card-play-dialogue-ui.md)
> **Architecture Module**: Card Play & Dialogue UI #14(Presentation)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: HIGH(via ADR-0009 EventResource 派生 + RichTextLabel BBCode reflow)
> **Stories**: 8 created — see Stories section below

## Overview

Card Play & Dialogue UI 是三档密度差异化渲染主消费 layer(ADR-0012 主消费 = #14):flash overlay(brief — `#13` HUD-only)/ long(立绘 + 对白 + 选项)/ verbose(完整 long + 8+ effects)/ numeric_only(`#13` HUD-only — 离别事件强制);玩家手牌 UI + NPC 立绘 + 选项交互;`I-8 narrative_density_changed` 订阅(主消费 layer);三档 fallback 链(`brief → standard → verbose`,`standard` 必填实例化 assert);`event_started(event_id, narrative_tier)` 接收 + density 在 emit 时锁定到事件结束(EVENT_ACTIVE 中途切档延后下个 event — ADR-0004)。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | event_started 订阅 + narrative_density_changed 订阅 | LOW |
| [ADR-0009](../../../docs/architecture/adr-0009-event-schema-format.md) | EventResource .tres + 三档 effects + dialogue_keys + farewell_event flag | HIGH |
| [ADR-0012](../../../docs/architecture/adr-0012-three-density-rendering.md) | #14 主消费 layer + _select_*_by_density() + fallback 链 + standard 必填 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-cardui-001 | 三档密度差异化渲染主消费 layer | ADR-0012 ✅ |
| TR-cardui-002 | 玩家手牌 UI + NPC 立绘 + 选项交互 | ⚠️ Partial(GDD-internal) |
| TR-cardui-003 | I-8 narrative_density_changed 订阅(主消费 layer) | ADR-0001 + ADR-0012 ✅ |
| TR-cardui-004 | 三档 fallback 链(brief→standard→verbose,standard 必填) | ADR-0012 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/card-play-dialogue-ui.md` Section H 全部 AC verify
- Logic stories(`_select_dialogue_keys_by_density()` + `_select_effects_by_density()` fallback 链)passing tests in `tests/unit/card_ui/`
- Integration stories(event_started → density 锁定 + EVENT_ACTIVE 切档延后 + farewell event 禁渲染 long)passing tests in `tests/integration/card_ui/`
- UI stories(手牌 UI + NPC 立绘 + Choice button)evidence 在 `tests/evidence/`(待 `/ux-design design/ux/event-dialogue-screen.md` Phase 4)
- 单 verbose event 渲染 ≤ 30s(writer 守 verbose 12 dialogue cap;CI lint 字数检查)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [Main Consumer + Control Tree](story-001-main-consumer-control-tree.md) | UI | Complete | ADR-0012 |
| 002 | [Three-Density Differential Rendering](story-002-three-density-rendering.md) | Integration | Complete | ADR-0012 |
| 003 | [Density Fallback Chain](story-003-density-fallback-chain.md) | Logic | Complete | ADR-0012 |
| 004 | [Hand Panel + Card Render](story-004-hand-panel-card-render.md) | UI | Complete | ActionCard 协作 |
| 005 | [NPC Portrait + Choice](story-005-npc-portrait-choice.md) | UI | Complete | NPC + Loc 协作 |
| 006 | [event_started + Density Lock](story-006-event-started-density-lock.md) | Integration | Complete | ADR-0001 + ADR-0012 |
| 007 | [narrative_density_changed Subscriber](story-007-narrative-density-changed.md) | Integration | Complete | ADR-0001 + ADR-0004 |
| 008 | [Perf — Verbose ≤ 30s](story-008-perf-verbose-30-second-cap.md) | Logic | Complete | ADR-0012 |

**Story type breakdown**:2 Logic + 3 Integration + 3 UI

## Next Step

依赖树:001 → 002 → 003 → 004 / 005 → 006 / 007 → 008
