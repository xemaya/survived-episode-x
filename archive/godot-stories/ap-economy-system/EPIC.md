# Epic: AP Economy System

> **Layer**: Core(⭐ Gameplay 核心)
> **GDD**: [design/gdd/ap-economy-system.md](../../../design/gdd/ap-economy-system.md)
> **Architecture Module**: AP Economy #7(Core)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: MEDIUM(典型 GDScript + Godot const,无 post-cutoff API 直接依赖;via ADR-0001 dispatch perf MEDIUM)
> **Stories**: 12 created — see Stories section below

## Overview

AP Economy System owns AP 4 态状态机(`AP_NORMAL` / `AP_OVERTIME_AVAILABLE` / `AP_OVERTIME_ACTIVE` / `AP_DEPLETED`);AP cost 1/2/3 分布 lint(40/40/20 比例);Hero card effort 三维度权重锁定 0.45/0.20/0.30(KPI research deviation 防 Hero 等价加班漏洞);F1-F5 公式(F1 加班 / F2 早退 / F3 capacity / F4 effort / F5 decision_space);`monthly_effort_summary(month, potential, ot, hero, ovr, days, capacity_factor)` signal owner = #7;`weekend_rest_day → energy +30`(`#6` 驱动);capacity_factor / capacity_floor 单调红线(Anti-P1 守门);`meta.run_ended` 优先持久化 R-AP-2 守门。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | ap_changed / ap_consumed / monthly_effort_summary / effort_*_incremented signal owner = #7 | MEDIUM |
| [ADR-0003](../../../docs/architecture/adr-0003-save-format-workerthreadpool.md) | sub-schema `ap_economy` 序列化(current_ap / max_ap_today / current_energy / overtime_used_this_month / hero_card_played_this_month / overage_card_played_this_month) | MEDIUM |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-ap-001 | AP 4 态状态机 | ⚠️ Partial(GDD-internal) |
| TR-ap-002 | AP cost 1/2/3 分布 lint(40/40/20) | 📋 GDD-internal(numeric) |
| TR-ap-003 | Hero card effort 三维度权重 0.45/0.20/0.30 | ⚠️ Partial(KPI research deviation lock) |
| TR-ap-004 | monthly_effort_summary signal owner = #7 | ADR-0001 ✅ |
| TR-ap-005 | meta.run_ended 优先持久化 R-AP-2 | ADR-0003 + ADR-0006 ✅ |
| TR-ap-006 | weekend_rest_day → energy +30 | ADR-0001 ✅ |
| TR-ap-007 | F1-F5 公式定义(AP 经济计算) | 📋 GDD-internal |
| TR-ap-008 | capacity_factor / capacity_floor 单调红线(Anti-P1) | ⚠️ Partial(architecture.md principle 2) |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/ap-economy-system.md` Section H 25 AC 全部 verify(Research H1-H5 假设整合;5 [RISK GUARD] AC-ROBUST-01..05 守 R-AP-1..5)
- Logic stories(F1-F5 公式 + AP 4 态状态机 + 1/2/3 分布 lint)passing tests in `tests/unit/ap/`(MVP 必测 — `.claude/docs/technical-preferences.md` minimum)
- Integration stories(weekend_rest_day → energy +30 / monthly_effort_summary → #9 KPI / Hero card effort 三维度 emit)passing tests in `tests/integration/ap/`
- Anti-P1 lint 守门:任何 effect / event / unlock 试图反向调高 AP cost / 调低 capacity_floor → PR-blocking + push_error
- Beta tier playtest:H1 决策熵 + H2 后悔感 + H5 玩家聚类(AC-FUNC-08/09 推迟)
- VS tier playtest:H3 非占优 C1 存亡级(AC-FUNC-10 推迟)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [AP 4-State Machine](story-001-ap-state-machine.md) | Logic | Complete | ADR-0001 |
| 002 | [F1 Overtime Formula](story-002-f1-overtime-formula.md) | Logic | Complete | GDD F1 |
| 003 | [F2 Early-Leave Formula](story-003-f2-early-leave-formula.md) | Logic | Complete | GDD F2 |
| 004 | [F3 capacity_factor Anti-P1](story-004-f3-capacity-factor.md) | Logic | Complete | architecture.md principle 2 |
| 005 | [F4 effort 3-Dim 0.45/0.20/0.30](story-005-f4-effort-three-dimension.md) | Logic | Complete | GDD F4 |
| 006 | [F5 decision_space](story-006-f5-decision-space.md) | Logic | Complete | GDD F5 |
| 007 | [AP Cost 1/2/3 Lint](story-007-ap-cost-distribution-lint.md) | Logic | Complete | GDD Rule 9 |
| 008 | [monthly_effort_summary Signal](story-008-monthly-effort-summary-signal.md) | Integration | Complete | ADR-0001 |
| 009 | [ap_consumed → game-time Integration](story-009-game-time-tick-integration.md) | Integration | Complete | ADR-0001 |
| 010 | [Hero Cap + report_overage](story-010-hero-card-monthly-cap.md) | Integration | Complete | ADR-0001 + ADR-0008 |
| 011 | [meta.run_ended Priority R-AP-2](story-011-meta-run-ended-priority-fsync.md) | Integration | Complete | ADR-0003 + ADR-0006 |
| 012 | [Risk Guards + Anti-P1 + Perf](story-012-risk-guards-perf.md) | Logic | Complete | architecture.md principle 2 |

**Story type breakdown**:8 Logic + 4 Integration

## Next Step

依赖树:001 → 002-007 并行 → 008/009/010 → 011/012。
