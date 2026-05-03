# Epic: Localization Hooks

> **Layer**: Foundation
> **GDD**: [design/gdd/localization-hooks.md](../../../design/gdd/localization-hooks.md)
> **Architecture Module**: Localization Hooks #3(Foundation)
> **Status**: Ready(GDD Designed,pending fresh session lean review)
> **Tier**: MVP(`zh_CN` only;`en` 推迟野心版)
> **Engine Risk**: LOW(`tr()` + `RichTextLabel` + 4.6 CSV plural form 增量功能)
> **Stories**: 12 created — see Stories section below

## Overview

Localization Hooks 提供 `tr()` 纪律 + key naming 规范(`_IRONY` 后缀 KPI / GAMEOVER 反讽 + `_BUREAUCRATIC` 后缀 HR 口吻 + EVENT.* / RECAP.* / NPC.* 8 master domain)。`broadcast_translation_changed_once()` 单次广播(ADR-0004 防抖合流);字体 fallback 链 4 档(11/13/15/17px)+ Compact variant + autofit floor 11(art-bible §7.2 禁 10px 笔画粘连);PAUSE 中 locale 切换挂起 + resume 后单次 emit;`locale_lock_watchdog_ms = 30000` 演出锁兜底;CSV 5 列 schema + plural form 4.6 + context column 4.6。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0004](../../../docs/architecture/adr-0004-settings-reflow-coalescing.md) | broadcast_translation_changed_once 单次广播 + PAUSE 挂起 + 24 notice_board reflow 30 帧 watchdog | LOW |
| [ADR-0010](../../../docs/architecture/adr-0010-subject-inversion-lint-domains.md) | 8 master domain + tr() key 命名 + `_IRONY` / `_BUREAUCRATIC` 后缀 + farewell numeric_only pattern | LOW |
| [ADR-0014](../../../docs/architecture/adr-0014-accessibility-settings-injection.md) | Theme.set_default_font_size() 单点 override + 字体 fallback 链 + AUTO_FIT_FLOOR_PX = 11 | HIGH(via AccessKit dependency)|

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-loc-001 | tr() 纪律 + key naming(_IRONY / _BUREAUCRATIC) | ADR-0010 ✅ |
| TR-loc-002 | locale_changed reflow ≤ 30 帧 + 单次广播 | ADR-0004 ✅ |
| TR-loc-003 | 字体 fallback 链 4 档 + Compact variant + AUTO_FIT_FLOOR_PX = 11 | ADR-0004 + ADR-0014 ✅ |
| TR-loc-004 | locale_lock_watchdog_ms = 30000(R-LOC-3 watchdog) | ADR-0002 + ADR-0004 ✅ |
| TR-loc-005 | CSV 5 列 schema + plural form 4.6 + context column 4.6 | 📋 GDD-internal |
| TR-loc-006 | PAUSE 中 locale 切换挂起 + resume 后单次 emit | ADR-0004 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/localization-hooks.md` Section H 30 AC 全部 verify(Tier 分级 28 MVP / 2 Beta;5 [RISK GUARD] AC-ROBUST-01..05 守 R-LOC-1..5)
- Logic stories(tr() / register_rich_text_refresh / 字体 fallback 链)passing tests in `tests/unit/loc/`
- Integration stories(locale switch + 24 notice_board reflow + PAUSE 挂起)passing tests in `tests/integration/loc/`
- UI stories(settings-screen 子屏)evidence 在 `tests/evidence/`(待 `/ux-design design/ux/settings-screen.md` Phase 4)
- `subject_inversion_lint.py` 8 master domain CI 通过
- `data/lang/zh-CN.csv` MVP 350-500 keys 完整(覆盖 `EVENT.*` + `KPI.*` + `RECAP.*` + 4 IRONY anchor key)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [tr() API + Key Naming + i18n_lint](story-001-tr-api-key-naming-lint.md) | Logic | Complete | ADR-0010 |
| 002 | [RichTextLabel Register + Auto-Purge](story-002-richtextlabel-register-api.md) | Logic | Complete | ADR-0004 |
| 003 | [Missing Key Fallback + BBCode-Safe](story-003-missing-key-fallback-bbcode-safe.md) | Logic | Complete | GDD Rule 4 |
| 004 | [locale_switch Dispatch ≤ 1 Frame](story-004-locale-switch-dispatch.md) | Integration | Complete | ADR-0001 + ADR-0004 |
| 005 | [Cutscene Lock + 30s Watchdog](story-005-cutscene-lock-watchdog.md) | Integration | Complete | ADR-0004 + ADR-0002 |
| 006 | [CSV 5-Column Schema + UTF-8 + RFC 4180](story-006-csv-schema-encoding.md) | Logic | Complete | GDD Rule 6 |
| 007 | [Plural Explicit Variants](story-007-plural-explicit-variants.md) | Logic | Complete | GDD Rule 7 |
| 008 | [Startup Load < 100ms + Parse Budget](story-008-startup-load-100ms.md) | Logic | Complete | ADR-0002 |
| 009 | [Font Fallback Chain + Compact + Floor 11](story-009-font-fallback-chain.md) | Logic | Complete | ADR-0014 + ADR-0004 |
| 010 | [F1 Reflow ≤ 500ms + Single Broadcast](story-010-reflow-perf-broadcast.md) | Integration | Complete | ADR-0004 |
| 011 | [_IRONY Tone Lint + Coverage F2](story-011-irony-tone-coverage-lint.md) | Logic | Complete | ADR-0010 |
| 012 | [CSV Missing Startup Gate + Deprecated Flow](story-012-csv-missing-key-stability.md) | Logic | Complete | GDD R-LOC-1 + Rule 10 |

**Story type breakdown**:9 Logic + 3 Integration

**Dependency tree**:
- 001(lint chain)→ 002 / 003 / 006 / 007 / 011 / 012 并行
- 002 → 004(dispatch)→ 005(lock + watchdog)
- 006 → 008(startup load)→ 009(font fallback)
- 008 → 010(reflow perf)
- 011(IRONY + coverage)blocks Release pipeline

## Next Step

按依赖树推进:001 → 002 / 006 / 007 并行 → 003 / 008 / 011 → 004 / 005 / 009 → 010 / 012。
