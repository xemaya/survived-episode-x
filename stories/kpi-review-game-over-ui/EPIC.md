# Epic: KPI Review & Game Over UI

> **Layer**: Presentation(⭐ 关键依赖节点 — 月末仪式 + 离职证明 + Archive)
> **GDD**: [design/gdd/kpi-review-game-over-ui.md](../../../design/gdd/kpi-review-game-over-ui.md)
> **Architecture Module**: KPI Review & Game Over UI #16(Presentation)
> **Status**: Ready(14 stories created 2026-04-29;GDD Designed,pending fresh session lean review)
> **Tier**: MVP
> **Engine Risk**: HIGH(via ADR-0009 GAMEOVER.CERTIFICATE.[reason] 文本嵌入 + ADR-0013 ScrollContainer 200 元素)
> **Stories**: 14 stories | 8 Logic + 3 Integration + 3 UI

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | 三屏节点树 + 4 态状态机 | Logic | Complete | ADR-0007 |
| 002 | KPI Review 800ms intro fade-in EASE_IN_OUT | Logic | Complete | ADR-0007 |
| 003 | breakdown 三行 HR 渲染 + format_contrib_pct | Logic | Complete | ADR-0010 |
| 004 | M1 新人豁免 `—` + capacity 数字对比预警 | Logic | Complete | ADR-0007 |
| 005 | GAMEOVER 1500ms linear easing=NONE Tween 守门 | Logic | Complete | ADR-0006 |
| 006 | GAMEOVER.CERTIFICATE.[reason] 文本嵌入 | Integration | Complete | ADR-0009 |
| 007 | skippable 注册 + skip 跳最后 1 帧不截断 | Integration | Complete | ADR-0006 |
| 008 | R-KGO-1 game_over_triggered 唯一启动 + breakdown 一帧守门 [BLOCKING] | Integration | Complete | ADR-0006 |
| 009 | R-KGO-2 CERTIFICATE missing key fallback [BLOCKING] | Logic | Complete | ADR-0009 |
| 010 | Archive 200 ScrollContainer culling + 懒加载 LRU 20 | UI | Complete | ADR-0013 |
| 011 | Archive 逐条删除 + autosave + soft warning ≥180 | UI | Complete | ADR-0013 |
| 012 | HR 评语词库 UI 子菜单(无星标无进度条) | UI | Complete | ADR-0010 |
| 013 | Pillar 1+Anti-P2 红线 + 主语翻转 lint(KPI/GAMEOVER/EVAL/ARCHIVE) [BLOCKING] | Logic | Complete | ADR-0010 |
| 014 | 帧预算 ≤4ms / Archive ≤2 帧 dispatch 性能契约 | Logic | Complete | ADR-0007 |

## Overview

KPI Review & Game Over UI owns 三屏(月末结算屏 + GAMEOVER 离职证明屏 + Archive 列表屏)节点树;`kpi_review_started` 三轨同步 800ms intro fade-in `EASE_IN_OUT` + breakdown 三行渲染 ≤ 1 帧(`#9 Rule 10` HR research §8.1 三行格式);GAMEOVER 1500ms `linear easing=NONE` Tween(skippable 但禁推翻 transition tone);GAMEOVER.CERTIFICATE.[reason] Localization key 渲染(`#10` EVENT.KPI.FIRED_DISMISSAL.[reason] 文本嵌入);Archive 200 元素 ScrollContainer 自动 culling + 懒加载详情 LRU 20 cap;主锚反讽屏 "恭喜晋升" + 副锚 "工号 #0011 · 死于 M11" 档案条;9 上游 cross-system 契约锁 + 5 双向 cross-check + 4 propagation flags。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0006](../../../docs/architecture/adr-0006-dismissal-gameover-path.md) | GAMEOVER 1500ms linear easing=NONE + dismissal_finalized 监听 + game_over_triggered 唯一 | LOW |
| [ADR-0007](../../../docs/architecture/adr-0007-kpi-review-three-track-anchor.md) | KPI Review 800ms 三轨同步锚 + Tween EASE_IN_OUT | LOW |
| [ADR-0009](../../../docs/architecture/adr-0009-event-schema-format.md) | GAMEOVER.CERTIFICATE.[reason] 文本嵌入 from EVENT.KPI.FIRED_DISMISSAL | HIGH |
| [ADR-0013](../../../docs/architecture/adr-0013-archive-200-virtual-scroll.md) | ScrollContainer + ArchiveCard 全实例 + 自动 culling + 懒加载 LRU 20 cap | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-kpiui-001 | 三屏 own 节点树 | ADR-0006 + ADR-0007 + ADR-0013 ✅ |
| TR-kpiui-002 | GAMEOVER.CERTIFICATE.[reason] Localization 渲染 | ADR-0009 + ADR-0011 ✅ |
| TR-kpiui-003 | KPI Review 800ms intro fade-in EASE_IN_OUT | ADR-0007 ✅ |
| TR-kpiui-004 | GAMEOVER 1500ms linear easing=NONE 守门 | ADR-0006 ✅ |
| TR-kpiui-005 | Archive 200 ScrollContainer 自动 culling + 懒加载 | ADR-0013 ✅ |
| TR-kpiui-006 | breakdown 三行 HR 戏谑口吻(KPI research §8.1) | ADR-0010 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/kpi-review-game-over-ui.md` Section H 22 AC 全部 verify(12 AC-FUNC + 4 AC-PERF + 3 AC-ROBUST + 2 AC-COMPAT + 1 AC-TONE)
- Logic stories(三屏状态机 + breakdown 三行 + 1500ms easing=NONE + ScrollContainer)passing tests in `tests/unit/kpi_ui/`
- Integration stories(`game_over_triggered` 唯一启动 + GAMEOVER.CERTIFICATE 文本嵌入 + Archive 详情懒加载 + 三轨 800ms 同步)passing tests in `tests/integration/kpi_ui/`
- Visual stories(主锚 "恭喜晋升" 反讽屏 + 副锚档案条 + 离职证明 1500ms transition)evidence 在 `tests/evidence/`(待 `/ux-design design/ux/kpi-review-screen.md` + `gameover-screen.md` + `archive-list-screen.md` Phase 4)
- 性能测试:Archive 屏 ~500ms 内显示 200 list + 单 archive 详情 ~100ms

## Next Step

Run `/create-stories kpi-review-game-over-ui` to break this epic into implementable stories.
