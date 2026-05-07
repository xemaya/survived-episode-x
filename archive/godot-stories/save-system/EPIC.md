# Epic: Save System

> **Layer**: Foundation
> **GDD**: [design/gdd/save-system.md](../../../design/gdd/save-system.md)
> **Architecture Module**: Save System #1(Foundation)
> **Status**: Ready(GDD APPROVED 3rd lean review)
> **Tier**: MVP
> **Engine Risk**: MEDIUM(`FileAccess.store_*` 4.4+ 返回 bool)
> **Stories**: 16 created — see Stories section below

## Overview

Save System 是项目的唯一持久化入口。三槽位序列化(`meta.save` 全局元数据 + `current_run.save` 当前 Run + `archive/[run_id].save` 历代 200 cap FIFO),WorkerThreadPool 异步 autosave + 主线程 ARCHIVING 5 步事务边界严格;`meta.run_ended = true` 原子 fsync 必须先于 GAMEOVER 1500ms transition,防 Alt+F4 续命(R-AP-2 + R-KPI-2 守门)。MVP `current_schema_version = 1` 不支持迁移;VS 起 `_migrate_vN_to_vN+1` 链。8+ 下游系统各自 sub-schema 随 schema_version 演进。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0003](../../../docs/architecture/adr-0003-save-format-workerthreadpool.md) | JSON-primary 三槽位 + WorkerThreadPool 异步 autosave + 主线程 ARCHIVING + meta.run_ended 原子 fsync | MEDIUM |
| [ADR-0006](../../../docs/architecture/adr-0006-dismissal-gameover-path.md) | meta.run_ended fsync 时序(GAMEOVER 1500ms transition 前)+ meta.dismissal_pending 启动恢复 flag | LOW |
| [ADR-0013](../../../docs/architecture/adr-0013-archive-200-virtual-scroll.md) | archive_index 启动期加载 + archive 详情懒加载(LRU 20 cap) | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-save-001 | 三槽位 Save 文件结构 | ADR-0003 ✅ |
| TR-save-002 | WorkerThreadPool 异步 autosave + 主线程 ARCHIVING 边界 | ADR-0003 ✅ |
| TR-save-003 | meta.run_ended 原子 fsync 先于 GAMEOVER 1500ms transition | ADR-0003 + ADR-0006 ✅ |
| TR-save-004 | archive 200 cap FIFO 驱逐 | ADR-0003 + ADR-0013 ✅ |
| TR-save-005 | current_schema_version 单调递增 + MVP 不迁移 | ADR-0003 ✅ |
| TR-save-006 | JSON-primary + Resource lazy parse | ADR-0003 ✅ |
| TR-save-007 | meta_settings_debounce_ms = 500ms 防抖窗 | ADR-0004 ✅ |
| TR-save-008 | autosave_perf_hard_ceiling_ms = 50ms HDD+AV p99 | ADR-0003 ✅ |
| TR-save-009 | content-only unlocks 5 类白名单 | ADR-0001 + ADR-0006 ✅ |
| TR-save-010 | final_transition_duration_ms = 1500ms linear easing=NONE | ADR-0006 ✅ |

**Untraced Requirements**: None(10/10 covered)

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/save-system.md` Section H 43 AC 全部 verify(MVP tier 必测)
- Logic stories(序列化 / 反序列化 / FIFO 驱逐 / fsync 时序)有 passing tests in `tests/unit/save/`
- Integration stories(三槽位 round-trip / GAMEOVER 时序 / 8+ subsystem sub-schema)有 passing tests in `tests/integration/save/`
- Visual/UI stories(Archive 列表 UI)evidence 在 `tests/evidence/`
- Smoke check #5 + #11-14(critical-paths.md)PASS

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [Three-Slot Save Files Schema](story-001-three-slot-save-files-schema.md) | Logic | Done | ADR-0003 |
| 002 | [Autosave WorkerThreadPool](story-002-autosave-worker-thread.md) | Logic | Done | ADR-0003 |
| 003 | [Atomic Write 4-Step + snapshot_id](story-003-atomic-write-4-step-snapshot-id.md) | Logic | Done | ADR-0003 |
| 004 | [meta vs current_run Decouple + 500ms Debounce](story-004-meta-currentrun-decouple-debounce.md) | Logic | Done | ADR-0004 |
| 005 | [Day-End Strong Flush](story-005-day-end-flush.md) | Logic | Complete | ADR-0003 |
| 006 | [Save System State Machine(6 States)](story-006-state-machine-six-states.md) | Integration | Complete | ADR-0003 |
| 007 | [ARCHIVING 5-Step Transaction](story-007-archiving-5-step-transaction.md) | Integration | Complete | ADR-0003 + ADR-0006 |
| 008 | [pending_flags Persistence + Crash Recovery](story-008-pending-flags-recovery.md) | Integration | Complete | ADR-0003 + ADR-0006 |
| 009 | [meta.run_ended fsync Before GAMEOVER 1500ms](story-009-meta-run-ended-fsync-before-gameover.md) | Integration | Complete | ADR-0006 + ADR-0003 |
| 010 | [Content-Only Unlocks Whitelist(Anti-P1)](story-010-content-only-unlocks-whitelist.md) | Logic | Complete | ADR-0001 |
| 011 | [Archive 200 Cap FIFO + No Batch Delete](story-011-archive-200-cap-fifo.md) | Logic | Complete | ADR-0013 |
| 012 | [Memo Read-Only Cross-Run Access](story-012-memo-read-only.md) | Logic | Complete | ADR-0013 + ADR-0001 |
| 013 | [Crash Recovery + .tmp Cleanup + Exit Timeout](story-013-crash-recovery-tmp-cleanup.md) | Integration | Complete | ADR-0003 |
| 014 | [Corrupt / Tampered / NaN Recovery](story-014-corrupt-tampered-nan-recovery.md) | Integration | Complete | ADR-0003 |
| 015 | [Disk Full + Error State Handling](story-015-disk-full-error-handling.md) | Integration | Complete | ADR-0003 |
| 016 | [Performance Contract Verification](story-016-performance-contract.md) | Logic | Complete | ADR-0003 |

**Story type breakdown**:8 Logic + 8 Integration

**Dependency tree(实施顺序)**:
- 001(三槽位)→ 002(autosave)+ 010(unlocks)+ 012(memo)
- 002 → 003(原子写)+ 004(meta debounce)+ 005(日结算)+ 015(磁盘满)
- 003 → 006(状态机)→ 007(ARCHIVING)→ 008(pending_flags)→ 009(meta.run_ended fsync)
- 007 → 011(200 cap)
- 003 + 002 → 013(crash recovery)+ 014(corrupt)+ 016(perf)

## Next Step

每 story 走 `/story-readiness [story-path]` → `/dev-story [story-path]` → `/code-review` → `/story-done` 流程。

按依赖树推进:Story 001 → 002 → 003 → 004/005/010/015 并行 → 006 → 007 → 008/009/011 并行 → 012/013/014/016 并行。
