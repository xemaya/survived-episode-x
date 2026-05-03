# Epic: Tutorial / Onboarding System(VS)

> **Layer**: Feature
> **GDD**: [design/gdd/tutorial-onboarding-system.md](../../../design/gdd/tutorial-onboarding-system.md)
> **Architecture Module**: Tutorial / Onboarding #18(Feature,VS tier)
> **Status**: Ready(10 stories created 2026-04-29;3 stories Blocked by VS tier ADR `tutorial-day-1-3-hint-api`;实施推迟到 VS milestone)
> **Tier**: VS
> **Engine Risk**: HIGH(via ADR-0002 autoload + `@abstract` 4.5+)
> **Stories**: 10 stories | 5 Logic + 5 Integration(3 Blocked by VS ADR)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [TutorialState autoload + 4 态状态机](story-001-tutorial-state-autoload-state-machine.md) | Logic | Complete | ADR-0002 |
| 002 | [Day 1-3 fixed_hand_override 协议](story-002-day-1-3-fixed-hand-override.md) | Integration | **Blocked** VS ADR | TBD |
| 003 | [ONBOARDING tier 5 NPC hint(`#10 Rule 17` 第 5 档)](story-003-onboarding-tier-5-npc-hint.md) | Integration | **Blocked** VS ADR | TBD + ADR-0001 |
| 004 | [inject_onboarding_hint() API](story-004-inject-onboarding-hint-api.md) | Logic | **Blocked** VS ADR | TBD |
| 005 | [M1 KPI 评语序列(老油条 1500ms + Lisa 800ms)](story-005-m1-kpi-review-npc-sequence.md) | Integration | Complete | ADR-0001 |
| 006 | [tutorial_completed flag content-only γ=0](story-006-tutorial-completed-content-only.md) | Integration | Complete | ADR-0003 |
| 007 | [R-TUT-1 隐形守门(无 popup / 高亮)](story-007-r-tut-1-no-popup-highlight-guard.md) | Logic | Complete | ADR-0010 |
| 008 | [P5 Day 1-3 90s budget 不打断](story-008-p5-day-1-3-90s-budget.md) | Logic | Complete | ADR-0001 |
| 009 | [P4 R-TUT-2 老 NPC tone lint](story-009-p4-r-tut-2-old-npc-tone-lint.md) | Logic | Complete | ADR-0010 |
| 010 | [信号架构 + Save 持久化](story-010-signal-architecture-save-persistence.md) | Integration | Complete | ADR-0001 + ADR-0003 |

## Overview

Tutorial / Onboarding System(VS tier)owns `TutorialState` autoload 子节点(末位 autoload,在 `SceneDayFlow` 之后);Day 1-3 fixed_hand_override + ONBOARDING tier 5 NPC hint;M1 KPI 评语 + tutorial_completed flag(`γ_effective = 0` 守门);`inject_onboarding_hint()` API;隐形 onboarding state machine + 叙事层老员工指路(P2 主 + P5 + P4 守 + Anti-P2 红线);content-only 隐式教学(无 popup tutorial),通过老员工 NPC dialogue 引导。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0002](../../../docs/architecture/adr-0002-autoload-init-order.md) | TutorialState autoload 末位(在 SceneDayFlow 之后);@abstract 4.5+ | HIGH |
| [ADR-0003](../../../docs/architecture/adr-0003-save-format-workerthreadpool.md) | sub-schema `tutorial`(tutorial_completed / tutorial_skip_flag) | MEDIUM |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-tutorial-001 | TutorialState autoload 子节点 | ADR-0002 ✅ |
| TR-tutorial-002 | Day 1-3 fixed_hand_override + ONBOARDING tier 5 NPC hint | ❌ Gap(VS tier 推迟,可接受) |
| TR-tutorial-003 | M1 KPI 评语 + tutorial_completed flag(γ_effective = 0) | ADR-0003 sub-schema ✅ |
| TR-tutorial-004 | inject_onboarding_hint() API | ❌ Gap(VS tier 推迟) |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`(VS milestone)
- `design/gdd/tutorial-onboarding-system.md` Section H 14 AC 全部 verify
- Logic stories(隐形 onboarding state machine 4 态 + γ_effective = 0 M1 守门)passing tests in `tests/unit/tutorial/`
- Integration stories(`#10 Rule 17` ONBOARDING 第 5 档 + `#9 Rule 6` M1 γ=0 + `#11 Rule 5` card_unlocked + `#6 Rule 4` 启动序列 + `#1 Rule 22` content-only)passing tests in `tests/integration/tutorial/`
- UI stories(onboarding-day1-day3 隐式引导)evidence 在 `tests/evidence/`(待 `/ux-design design/ux/onboarding-day1-day3.md` Phase 4)
- R-TUT-1 + R-TUT-2 守门:popup 漏入 + 励志台词漏入零出现
- VS tier ADR 撰写(`/architecture-decision tutorial-day-1-3-hint-api`)在 VS milestone 启动前完成

## Next Step

Stories 已创建(2026-04-29,10 stories;3 Blocked by VS ADR `tutorial-day-1-3-hint-api`)。MVP 阶段不实施(VS tier)。

**前置 unblock**:VS milestone 启动前完成 `/architecture-decision tutorial-day-1-3-hint-api` 撰写 — Story 002 / 003 / 004 解锁条件。

VS milestone 启动后:7 Ready stories 走 `/story-readiness [story-path]` → `/dev-story [story-path]` → `/code-review` → `/story-done` 流程。3 Blocked stories 等 VS ADR APPROVED 后续上。
