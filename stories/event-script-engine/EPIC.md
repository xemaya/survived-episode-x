# Epic: Event Script Engine

> **Layer**: Feature(Bottleneck ⭐⭐ — 数据驱动事件 schema)
> **GDD**: [design/gdd/event-script-engine.md](../../../design/gdd/event-script-engine.md)
> **Architecture Module**: Event Script Engine #10(Feature)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: HIGH(`@abstract` 4.5+ Resource 子类 + `duplicate_deep()` 4.5+ 间接 + EditorPlugin)
> **Stories**: 14 created — see Stories section below

## Overview

Event Script Engine 是数据驱动事件 schema 引擎(80-120 events MVP / 400+ 完整版);Schema A 扁平式 — `EventResource` `.tres` 单文件 per event(writer 用 Godot Inspector 编辑);`@abstract EventEffect` 4.5+ 基类 + 5 子类(`SetFlagEffect` / `RelationshipDeltaEffect` / `SpawnNoticeEffect` / `GiveUnlockEffect` / `EmitGameOverEffect`);三档密度差异化 effects(`brief 1-2` / `standard 2-4 必填` / `verbose 4-8`)+ dialogue_keys;`FAREWELL_EVENT_IDS` enum + 5 离别事件 numeric_only 强制(`farewell_event` flag);cooldown + once_per_run + morning_blacklist 7 天滑动;Dictionary 三层索引(by_trigger / by_chapter / by_npc);EditorPlugin EventLinter + Python CI lint chain;`subject_inversion_lint.py` 8 master domain;EVENT.KPI.FIRED_DISMISSAL 剧本 GAMEOVER 中转(Path B 唯一)+ `dismissal_finalized` signal owner = #10。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | event_started / event_completed / dismissal_finalized signal owner = #10;FAREWELL_EVENT_IDS enum owner = #10 | MEDIUM |
| [ADR-0006](../../../docs/architecture/adr-0006-dismissal-gameover-path.md) | EVENT.KPI.FIRED_DISMISSAL 剧本 GAMEOVER 中转 + dismissal_finalized 回调 | LOW |
| [ADR-0009](../../../docs/architecture/adr-0009-event-schema-format.md) | EventResource .tres 单文件 + EventTrigger + @abstract EventEffect 5 子类 + 三档密度 + farewell_event flag | HIGH |
| [ADR-0010](../../../docs/architecture/adr-0010-subject-inversion-lint-domains.md) | 8 master domain + EVENT.* / KPI.DISMISSAL.* keys + tools/lint_config.toml | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-event-001 | Schema A 扁平 event 库(.tres single file per event) | ADR-0009 ✅ |
| TR-event-002 | @abstract EventEffect 4.5+ 5 子类 | ADR-0002 + ADR-0009 ✅ |
| TR-event-003 | 三档密度 effects + dialogue | ADR-0009 + ADR-0012 ✅ |
| TR-event-004 | FAREWELL_EVENT_IDS enum + 5 离别事件 numeric_only | ADR-0001 + ADR-0009 ✅ |
| TR-event-005 | cooldown + once_per_run + morning_blacklist 7 天滑动 | ADR-0009 ✅ |
| TR-event-006 | Dictionary 三层索引 | ADR-0009 ✅ |
| TR-event-007 | EditorPlugin EventLinter + Python CI lint | ADR-0009 + ADR-0010 ✅ |
| TR-event-008 | subject_inversion_lint.py 8 master domain | ADR-0010 ✅ |
| TR-event-009 | narrative_density_changed 订阅契约 | ADR-0001 + ADR-0004 + ADR-0012 ✅ |
| TR-event-010 | EVENT.KPI.FIRED_DISMISSAL 剧本 GAMEOVER 中转 | ADR-0006 + ADR-0009 ✅ |
| TR-event-011 | dismissal_finalized signal owner = #10 | ADR-0006 ✅ |
| TR-event-012 | Lisa 跳槽线必发(playtest 实测) | ❌ Gap(Beta 推迟) |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/event-script-engine.md` Section H 30 AC 全部 verify(MVP 必测)
- Logic stories(EventTrigger evaluator / @abstract EventEffect 5 子类 / Dictionary 三层索引 / cooldown + morning_blacklist + once_per_run)passing tests in `tests/unit/event/`
- Integration stories(三档密度 fallback 链 / farewell event numeric_only / EVENT.KPI.FIRED_DISMISSAL Path B)passing tests in `tests/integration/event/`
- writer 工具:EditorPlugin EventLinter + VS Code snippet `evt`
- CI lint 阶段 < 5s(200 events × 14 master/sub-domain 检查)
- **GDD Revision Flag(待修)**:`#10 Rule 18` "JSON-primary + tres runtime" → 改为对齐 ADR-0009 ".tres 单文件 + Inspector 主路径"(JSON 仅 git-friendly 副本可选)
- OQ-EVT-ENG-01 `@abstract` Resource 子类 4.6 实测(共享 ADR-0002 OQ-SDF-ENG-03)
- OQ-EVT-03 F1-F4 公式 RNG fairness 实测
- OQ-EVT-08 Lisa 跳槽线必发 playtest(Beta tier)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [EventResource .tres Schema](story-001-event-resource-tres-schema.md) | Logic | Complete | ADR-0009 |
| 002 | [EventTrigger + 7 TriggerType](story-002-event-trigger-resource.md) | Logic | Complete | ADR-0009 |
| 003 | [@abstract EventEffect + 5 Subclass](story-003-abstract-event-effect-five-subclass.md) | Logic | Complete | ADR-0002 + ADR-0009 |
| 004 | [Dictionary 3-Layer Index + Cooldown](story-004-dictionary-three-layer-index.md) | Logic | Complete | ADR-0009 |
| 005 | [Three-Density Fallback Chain](story-005-three-density-fallback-chain.md) | Logic | Complete | ADR-0009 + ADR-0012 |
| 006 | [FAREWELL_EVENT_IDS + numeric_only Lint](story-006-farewell-event-ids-numeric-only.md) | Logic | Complete | ADR-0001 + ADR-0009 |
| 007 | [event_started Signal + Density Lock](story-007-event-started-signal.md) | Integration | Complete | ADR-0001 + ADR-0012 |
| 008 | [narrative_density_changed Deferred](story-008-narrative-density-changed-deferred.md) | Integration | Complete | ADR-0001 + ADR-0004 |
| 009 | [FIRED_DISMISSAL Path B Script](story-009-fired-dismissal-path-b.md) | Integration | Complete | ADR-0006 |
| 010 | [EditorPlugin EventLinter + Python CI](story-010-editor-plugin-event-linter.md) | Logic | Complete | ADR-0009 + ADR-0010 |
| 011 | [subject_inversion 8 Master Domain](story-011-subject-inversion-eight-master.md) | Logic | Complete | ADR-0010 |
| 012 | [Save Persistence — event_history](story-012-save-persistence-history.md) | Integration | Complete | ADR-0003 |
| 013 | [5-State State Machine](story-013-five-state-machine.md) | Logic | Complete | GDD 状态机 |
| 014 | [Risk Guards + Perf + Lisa Beta](story-014-risk-guards-perf-lisa-jumping.md) | Logic | Complete | GDD R-EVT-1..5 |

**Story type breakdown**:9 Logic + 5 Integration

## Next Step

依赖树:001 → 002 / 003 / 005 / 006 / 010 / 011 → 004 → 007 / 013 → 008 / 009 / 012 → 014。
