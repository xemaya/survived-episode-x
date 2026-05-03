# Epic: Daily / Weekly Recap UI

> **Layer**: Presentation
> **GDD**: [design/gdd/daily-weekly-recap-ui.md](../../../design/gdd/daily-weekly-recap-ui.md)
> **Architecture Module**: Daily / Weekly Recap UI #15(Presentation)
> **Status**: Ready(12 stories created 2026-04-29;2 stories Blocked by propagation flag #6 + #7;GDD Designed revised 2026-04-29)
> **Tier**: MVP
> **Engine Risk**: LOW(RichTextLabel + Tween 4.0+ 稳定)
> **Stories**: 12 stories | 8 Logic + 3 Integration + 1 UI(2 Blocked)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Daily Recap 触发 + ctx payload | Logic | **Blocked** flag #6 | ADR-0001 |
| 002 | Weekly Recap 周五升级 + 月末特例 | Logic | **Blocked** flag #6 | ADR-0001 |
| 003 | effort 三维度 HR 渲染 | Logic | Complete | ADR-0010 |
| 004 | 事件 numeric_only 列表 + D1 截断 8 条 | Logic | Complete | ADR-0012 |
| 005 | R-RCP-1 进度条禁用 lint [BLOCKING] | Logic | Complete | ADR-0010 |
| 006 | RECAP.* HR 主语翻转 lint 域扩展 | Logic | Complete | ADR-0010 |
| 007 | skippable + 月末 2 周 1500ms + R-RCP-2 | Integration | **Blocked** flag #7 | ADR-0001 |
| 008 | 帧预算 ≤2ms + dispatch ≤1 帧 | Logic | Complete | ADR-0001 |
| 009 | 主语翻转 RECAP.* 渲染契约 | Logic | Complete | ADR-0010 |
| 010 | AC-FAREWELL-01 numeric_only 守门 [BLOCKING] | Integration | Complete | ADR-0001 |
| 011 | AC-DENSITY-01 narrative_density_changed 切档 | Integration | Complete | ADR-0012 |
| 012 | Daily / Weekly Recap 双屏节点树 | UI | Complete | ADR-0001 |

## Overview

Daily / Weekly Recap UI owns Daily Recap (<90s) + Weekly Recap (周五);effort 三维度展示 + numeric_only 事件列表(继承 `#10 Rule 19` 三档叙事密度,密度落差本身即叙事);HR 周报口吻 lint(扩展 RECAP.* keys,`subject_inversion_lint.py --domain RECAP`);I-9 narrative_density_changed 订阅;AC-FAREWELL-01 守门(farewell event 在周报 numeric_only 列表中仅一行 `EVENT.[event_id].TITLE_NUMERIC`)+ AC-DENSITY-01;skippable 协议(`#6 Rule 12` 配合 `#2` 跳过权);数据屏蓝光 context(`#5 Rule 1`)。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | event_completed 订阅 + narrative_density_changed 订阅 + AC-FAREWELL-01 守门 | LOW |
| [ADR-0010](../../../docs/architecture/adr-0010-subject-inversion-lint-domains.md) | RECAP master domain + HR 周报口吻 + farewell numeric_only pattern | LOW |
| [ADR-0012](../../../docs/architecture/adr-0012-three-density-rendering.md) | #15 共享 fallback 逻辑(`_select_summary_by_density` 取 dialogue_keys[0] 首句) | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-recap-001 | Daily Recap (<90s) + Weekly Recap (周五)双屏 | ⚠️ Partial(GDD-internal) |
| TR-recap-002 | effort 三维度展示 + numeric_only 事件列表 | ADR-0012 ✅ |
| TR-recap-003 | HR 周报口吻 lint(扩展 RECAP.* keys) | ADR-0010 ✅ |
| TR-recap-004 | I-9 narrative_density_changed 订阅 | ADR-0001 + ADR-0012 ✅ |
| TR-recap-005 | AC-FAREWELL-01 + AC-DENSITY-01 守门 | ADR-0001 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/daily-weekly-recap-ui.md` Section H 20 AC 全部 verify
- Logic stories(Daily / Weekly Recap 触发协议 + 事件密度截断 + skippable token)passing tests in `tests/unit/recap_ui/`
- Integration stories(`#10 event_completed` history → Recap 列表 + AC-FAREWELL-01 numeric_only / AC-DENSITY-01 切档)passing tests in `tests/integration/recap_ui/`
- UI stories(daily-recap-screen + weekly-recap-screen)evidence 在 `tests/evidence/`(待 `/ux-design design/ux/daily-recap-screen.md` + `weekly-recap-screen.md` Phase 4)
- `subject_inversion_lint.py --domain RECAP` 30 条 HR 词条 PR-blocking 通过
- AC-FAREWELL-01 守门测试:周报中含 farewell event 时,**仅一行** `EVENT.[event_id].TITLE_NUMERIC` key,无情感词

## Next Step

Run `/create-stories daily-weekly-recap-ui` to break this epic into implementable stories.
