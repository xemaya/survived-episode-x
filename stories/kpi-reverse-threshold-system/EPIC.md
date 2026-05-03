# Epic: KPI & Reverse Threshold System

> **Layer**: Core(Bottleneck ⭐⭐ — 反向 KPI 数学引擎)
> **GDD**: [design/gdd/kpi-reverse-threshold-system.md](../../../design/gdd/kpi-reverse-threshold-system.md)
> **Architecture Module**: KPI System #9(Core)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: LOW(纯 float 数学 + deterministic RNG;via ADR-0001 dispatch perf MEDIUM)
> **Stories**: 13 created — see Stories section below

## Overview

KPI & Reverse Threshold System 是反向 KPI 数学引擎 — `monthly_threshold: int` 单调递增(Anti-P1 红线)+ `month_index: int`;Formula B 乘性公式(α=0.04, β=0.18, γ=0.012)+ `capacity_factor(m) = max(0.4, 3.0 - 0.05·m)`;GAME OVER 检测协议(threshold > capacity_now);`game_over_triggered(reason, month)` signal **唯一 emit owner = #9**(`#10 / #6` 等任何系统禁 emit — forbidden_pattern `dual_emit_game_over`);Path B 双路径合并(所有 GAMEOVER 走 `dismissal_triggered → #10 EVENT.KPI.FIRED_DISMISSAL → dismissal_finalized → game_over_triggered`);`settlement_locked` R-KPI-2 守门(月末重入屏蔽);kpi_review 三轨 800ms 同步锚(ADR-0007);kpi_prediction_hint 4 档(老 NPC 预言);deterministic RNG seed 可控(public seed + 月末复算)。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | kpi_threshold_changed / kpi_review_started / game_over_triggered / dismissal_triggered / kpi_prediction_hint signal owner = #9 | MEDIUM |
| [ADR-0006](../../../docs/architecture/adr-0006-dismissal-gameover-path.md) | Path B 双路径合并 + settlement_locked + dismissal watchdog 30s | LOW |
| [ADR-0007](../../../docs/architecture/adr-0007-kpi-review-three-track-anchor.md) | kpi_review_intro_duration_ms = 800ms 三轨同步锚 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-kpi-001 | monthly_threshold 单调递增(Anti-P1) | ⚠️ Partial(architecture.md principle 2)|
| TR-kpi-002 | F1-F4 公式(乘性 + capacity_factor) | 📋 GDD-internal |
| TR-kpi-003 | GAME OVER 检测协议(threshold > capacity_now) | ADR-0006 ✅ |
| TR-kpi-004 | kpi_review_started signal owner = #9 | ADR-0001 + ADR-0007 ✅ |
| TR-kpi-005 | game_over_triggered 唯一 emit 源 = #9 | ADR-0001 + ADR-0006 ✅ |
| TR-kpi-006 | dismissal_triggered → #10 → game_over_triggered Path B | ADR-0006 ✅ |
| TR-kpi-007 | settlement_locked R-KPI-2 守门 | ADR-0006 ✅ |
| TR-kpi-008 | KPI Review 三轨 800ms 同步锚 | ADR-0007 ✅ |
| TR-kpi-009 | kpi_prediction_hint 4 档(老 NPC 预言) | ADR-0001 ✅ |
| TR-kpi-010 | deterministic RNG seed 可控 | 📋 GDD-internal |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/kpi-reverse-threshold-system.md` Section H 30 AC 全部 verify(MVP 必测)
- Logic stories(F1-F4 公式 + capacity_factor + GAME OVER 检测 + Path B 状态机)passing tests in `tests/unit/kpi/`(KPI 公式 = MVP 必测项,`.claude/docs/technical-preferences.md`)
- Integration stories(dismissal_triggered → #10 → game_over_triggered 链 ≤ 30s + settlement_locked 重入测试 + watchdog 30s fallback + crash 恢复)passing tests in `tests/integration/kpi/`
- **GDD Revision Flag(待修)**:`#9 Edge 1.4` "M1 开除...不触发 GAME OVER" → 改为对齐 ADR-0006(M1 经过剧本最终 emit game_over_triggered)
- OQ-KPI-01 标准玩家 M11 ± 2 GAME OVER 实证(Pre-Production /prototype core-loop)
- OQ-KPI-02 capacity_floor=0 vs 0.4 决策(野心版 ADR)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [monthly_threshold + Anti-P1 Monotonic](story-001-monthly-threshold-monotonic.md) | Logic | Complete | architecture.md principle 2 |
| 002 | [F1 next_threshold Formula](story-002-f1-next-threshold-formula.md) | Logic | Complete | GDD F1 |
| 003 | [F2 potential Clamp](story-003-f2-potential-clamp.md) | Logic | Complete | GDD F2 |
| 004 | [F3 capacity_factor Reuse](story-004-f3-capacity-shared.md) | Logic | Complete | AP Story 004 协作 |
| 005 | [F4 GAME OVER Detection](story-005-f4-game-over-detection.md) | Logic | Complete | ADR-0006 |
| 006 | [kpi_review_started Three-Track](story-006-kpi-review-started-three-track.md) | Integration | Complete | ADR-0007 + ADR-0001 |
| 007 | [game_over_triggered Single Emitter](story-007-game-over-triggered-single-emitter.md) | Logic | Complete | ADR-0001 + ADR-0006 |
| 008 | [Path B Dismissal Script](story-008-path-b-dismissal-script.md) | Integration | Complete | ADR-0006 |
| 009 | [settlement_locked R-KPI-2](story-009-settlement-locked-r-kpi-2.md) | Logic | Complete | ADR-0006 |
| 010 | [kpi_threshold_changed Emit Order](story-010-kpi-threshold-changed-order.md) | Integration | Complete | GDD Edge 4.1 |
| 011 | [kpi_prediction_hint 4-Tier](story-011-kpi-prediction-hint.md) | Logic | Complete | ADR-0001 |
| 012 | [Deterministic RNG + Crash Recovery](story-012-deterministic-rng-recovery.md) | Logic | Complete | GDD Edge 8.1/10.3 |
| 013 | [actual_kpi Accumulator + Risk Guards](story-013-actual-kpi-accumulator-risk-guards.md) | Logic | Complete | GDD R-KPI-1..5 |

**Story type breakdown**:9 Logic + 3 Integration + 1 Logic(actual_kpi)

## Next Step

依赖树:001 → 002 / 003 / 004 / 011 / 013 → 005 / 010 → 006 / 007 / 009 → 008 / 012。
