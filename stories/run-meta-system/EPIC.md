# Epic: Run Meta System

> **Layer**: Feature
> **GDD**: [design/gdd/run-meta-system.md](../../../design/gdd/run-meta-system.md)
> **Architecture Module**: Run Meta #12(Feature)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP simple
> **Engine Risk**: MEDIUM(via ADR-0003 sub-schema + ADR-0013 ScrollContainer)
> **Stories**: 7 created — see Stories section below

## Overview

Run Meta System owns `RunSummary` schema(7 字段);`archive_index: Array[ArchiveIndexEntry]` 200 cap FIFO + content-only unlocks 5 类白名单(`codex / memo / npc / event_branch / ending` — Anti-P1 红线 PR-blocking forbidden_pattern);HR 评语词条收集词库(30 条 MVP);demo end 3 月 gate(`DEMO_END_MONTH = 3`);`run_started` / `run_ended(run_id, month, reason)` signal owner = #12;`run_meta_unlock(content_id)` `#10` effect 调用 → `#12` 严格白名单守门。Archive 屏 ~500ms 加载 + 单 archive 详情 ~100ms 懒加载(ADR-0013)。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | run_started / run_ended / run_meta_unlock signal owner = #12;forbidden_pattern Anti-P1 red line 守 | LOW |
| [ADR-0003](../../../docs/architecture/adr-0003-save-format-workerthreadpool.md) | sub-schema `run_meta`(run_count / current_run_month / unlocks / archive / hr_word_library) | MEDIUM |
| [ADR-0013](../../../docs/architecture/adr-0013-archive-200-virtual-scroll.md) | archive_index 启动期加载 + archive 详情 LRU 20 cap 懒加载 + 禁批量删 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-run-meta-001 | RunSummary schema(7 字段) | ADR-0003 sub-schema ⚠️ Partial |
| TR-run-meta-002 | archive_index 200 cap FIFO + content-only unlocks 5 类白名单 | ADR-0003 + ADR-0013 ✅ |
| TR-run-meta-003 | HR 评语词条收集词库(30 条 MVP) | ❌ Gap(content-only,VS 推迟可接受)|
| TR-run-meta-004 | demo end 3 月 gate(DEMO_END_MONTH = 3) | ⚠️ Partial(entities.yaml) |
| TR-run-meta-005 | run_meta_unlock 5 类白名单(Anti-P1 红线) | ADR-0001 + ADR-0003 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/run-meta-system.md` Section H 15 AC 全部 verify
- Logic stories(F1 三轴选词 + F2 FIFO 驱逐 + content-only 5 类白名单守门)passing tests in `tests/unit/run_meta/`
- Integration stories(run_ended → archive_completed + run_meta_unlock → 5 类白名单 + demo end 3 月 gate)passing tests in `tests/integration/run_meta/`
- Anti-P1 lint 守门:`run_meta_unlock` 写入非 5 类白名单 → push_error + PR-blocking
- HR 评语 30 词条 `subject_inversion_lint.py --domain TENURE` 通过

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [RunSummary 7-Field Schema](story-001-run-summary-schema.md) | Logic | Complete | ADR-0003 + ADR-0001 |
| 002 | [archive_index Array[200] FIFO](story-002-archive-index-fifo.md) | Logic | Complete | ADR-0013 + ADR-0003 |
| 003 | [Content-Only Unlocks Anti-P1](story-003-content-only-unlocks-anti-p1.md) | Logic | Complete | ADR-0001 |
| 004 | [F1 HR 3-Axis 30-Term Library](story-004-f1-hr-three-axis-selection.md) | Logic | Complete | GDD F1 |
| 005 | [run_meta_unlock Effect Integration](story-005-run-meta-unlock-effect.md) | Integration | Complete | ADR-0001 + Event Story 003 |
| 006 | [Demo End 3-Month Gate](story-006-demo-end-three-month-gate.md) | Logic | Complete | entities.yaml |
| 007 | [Risk Guards + Save Persistence](story-007-risk-guards-save-persistence.md) | Integration | Complete | ADR-0003 + R-RM-1..3 |

**Story type breakdown**:5 Logic + 2 Integration

## Next Step

依赖树:001 → 002 / 003 / 004 / 006 → 005 → 007。
