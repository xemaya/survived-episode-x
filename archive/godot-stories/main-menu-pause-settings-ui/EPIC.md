# Epic: Main Menu / Pause / Settings UI

> **Layer**: Presentation
> **GDD**: [design/gdd/main-menu-pause-settings-ui.md](../../../design/gdd/main-menu-pause-settings-ui.md)
> **Architecture Module**: Main Menu / Pause / Settings UI #17(Presentation)
> **Status**: 12/12 Complete(2026-05-01,autopilot lean review;.tscn 资产 + AccessKit/dual-focus Polish 延后,见各 story Deviations)
> **Tier**: MVP basic
> **Engine Risk**: HIGH(via ADR-0014 AccessKit 4.5+ + dual-focus 4.6)
> **Stories**: 12 stories | 6 Logic + 4 Integration + 2 UI

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | 主菜单 4 入口 + New Run 冲突 + Archive 满禁用 | Logic | Complete | ADR-0001 |
| 002 | LOADING → MAIN_MENU ≤500ms | Logic | Complete | ADR-0001 |
| 003 | Pause 子屏 SceneTree.paused + KPI_REVIEW 禁 Pause | Logic | Complete | ADR-0004 |
| 004 | Settings 主屏 4 类节点树 | UI | Complete | ADR-0014 |
| 005 | Settings 6 信号合流 → #6 timer 500ms debounce | Integration | Complete | ADR-0004 |
| 006 | narrative_density_changed signal owner = #17 + 三档心理模型 | Logic | Complete | ADR-0001 + ADR-0012 |
| 007 | keymap remap 正流程 + cancel 回滚 + 无绑定红色 | Integration | Complete | ADR-0001 |
| 008 | R-MM-1 Settings AP/KPI/Energy 红线 lint [BLOCKING] | Logic | Complete | ADR-0014 |
| 009 | R-MM-2 Pause + GAMEOVER 转移协调 | Integration | Complete | ADR-0006 |
| 010 | Archive 入口 MAIN_MENU → ARCHIVE sub-mode | Integration | Complete | ADR-0013 |
| 011 | HR 口吻 + 主语翻转 + 零 SFX lint | Logic | Complete | ADR-0010 |
| 012 | Gamepad D-Pad + dual-focus + AccessKit | UI | Complete | ADR-0014 |

## Overview

Main Menu / Pause / Settings UI owns 主菜单 4 入口 + Pause 子屏("摸鱼中")+ Settings 子屏(音量 4 旋钮 + 语言 + 键位 remap + 叙事密度 + 字体 4 档 + 色盲 3 模式)+ Archive 入口;Settings 6 信号合流(`bus_volume_changed × 4` + `locale_changed` + `keymap_changed` + `font_size_changed` + `colorblind_mode_changed` + `narrative_density_changed`)经 `#6` 单 timer 500ms debounce → Save 异步落盘 + Loc 单次广播 reflow;**`narrative_density_changed` signal 唯一 emit owner = #17**(B-DEP-1 仲裁);三档心理模型 UI 提示("叙事密度 — 决定事件中你能看到多少对白")。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | narrative_density_changed signal 单 owner = #17 + 5 settings 信号合流 | LOW |
| [ADR-0004](../../../docs/architecture/adr-0004-settings-reflow-coalescing.md) | 6 信号同帧 → 单次 broadcast_translation_changed_once 节流 6× + EVENT_ACTIVE 切档延后 + PAUSE 挂起 | LOW |
| [ADR-0013](../../../docs/architecture/adr-0013-archive-200-virtual-scroll.md) | Archive 入口(MAIN_MENU → ARCHIVE sub-mode 切换)| LOW |
| [ADR-0014](../../../docs/architecture/adr-0014-accessibility-settings-injection.md) | font_size + colorblind 注入 + AccessKit + dual-focus + 6 信号合流集成 | HIGH |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-mainmenu-001 | 主菜单 4 入口 + Pause 子屏 + Settings 子屏 | ⚠️ Partial(GDD-internal) |
| TR-mainmenu-002 | Settings 信号合流 6 类 | ADR-0001 + ADR-0004 + ADR-0014 ✅ |
| TR-mainmenu-003 | narrative_density 选项 + 三档心理模型 | ADR-0012 ✅ |
| TR-mainmenu-004 | Archive 入口(MAIN_MENU → ARCHIVE) | ADR-0013 ✅ |
| TR-mainmenu-005 | 4 类 settings 信号合流至 #6 单 timer 500ms | ADR-0004 ✅ |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/main-menu-pause-settings-ui.md` Section H 全部 AC verify
- Logic stories(`narrative_density_changed` emit + 6 信号合流到 #6 timer + Archive 入口转 sub-mode)passing tests in `tests/unit/main_menu/`
- Integration stories(6 信号同帧 → 单次 reflow 广播 + EVENT_ACTIVE 切档延后 + PAUSE 中改 locale resume 后单次 emit)passing tests in `tests/integration/main_menu/`
- UI stories(主菜单 + Pause + Settings + Archive 入口)evidence 在 `tests/evidence/`(待 `/ux-design design/ux/main-menu.md` + `pause-screen.md` + `settings-screen.md` + `remap-screen.md` Phase 4 4 屏)
- AccessKit 启用 PASS:屏幕阅读器(NVDA / VoiceOver)读出 ARIA label
- dual-focus 测试:键盘 + gamepad 同时 focus 独立(OQ-A14-ENG-02)

## Next Step

Run `/create-stories main-menu-pause-settings-ui` to break this epic into implementable stories.
