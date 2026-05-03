# Epic: Accessibility Options(Alpha)

> **Layer**: Polish(注入器 — 跨切关注)
> **GDD**: [design/gdd/accessibility-options.md](../../../design/gdd/accessibility-options.md)
> **Architecture Module**: Accessibility #20(Polish,Alpha tier)
> **Status**: Ready(12 stories created 2026-04-29;Story 009/010 MVP 即上线 BLOCKING lint;字体 + 色盲 + AccessKit 实施推迟 Alpha)
> **Tier**: Alpha
> **Engine Risk**: HIGH(`AccessKit` 4.5+ + `dual-focus` 4.6 + Theme override + CanvasLayer post-process Shader)
> **Stories**: 12 stories | 6 Logic + 6 Integration(Story 009/010 MVP 即上线;余 10 stories Alpha milestone)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [AccessibilitySettings autoload + 字体/色盲 schema](story-001-accessibility-settings-autoload-schema.md) | Logic | Complete | ADR-0014 |
| 002 | [Theme.set_default_font_size 单点注入](story-002-theme-set-default-font-size.md) | Integration | Complete | ADR-0014 |
| 003 | [色盲 LUT CanvasLayer post-process Shader](story-003-colorblind-lut-shader.md) | Logic | Complete | ADR-0014 |
| 004 | [高对比度 + 字体 fallback 链](story-004-high-contrast-font-fallback.md) | Logic | Complete | ADR-0014 |
| 005 | [输入辅助(anti-QTE 守 #2 Rule 4)](story-005-input-assist-anti-qte.md) | Integration | Complete | ADR-0014 |
| 006 | [mute_visual_parity Hero card 三 element](story-006-mute-visual-parity.md) | Integration | Complete | ADR-0008 |
| 007 | [AccessKit 4.5+ 屏幕阅读器](story-007-accesskit-screen-reader.md) | Integration | Ready (Polish 实测) | ADR-0014 |
| 008 | [dual-focus mode 4.6](story-008-dual-focus-mode.md) | Integration | Ready (Polish 实测) | ADR-0014 |
| 009 | [**Anti-P1 lint(MVP 即上线)** \[BLOCKING\]](story-009-anti-p1-lint-mvp-online.md) | Logic | **Ready MVP 第一周** | ADR-0014 |
| 010 | [**Pillar 4 tone 守门(MVP 即上线)** 5 类禁视觉](story-010-pillar4-tone-five-forbidden-visual-lint.md) | Logic | **Ready MVP 第一周** | ADR-0008 |
| 011 | [R-A11Y-2 二次 reflow fallback](story-011-r-a11y-2-secondary-reflow-fallback.md) | Logic | Complete | ADR-0004 |
| 012 | [Settings UI 注入(#17 AccessibilityGroup)](story-012-settings-ui-injection.md) | Integration | Complete | ADR-0014 |

## Overview

Accessibility Options(Alpha tier)owns `AccessibilitySettings` autoload + 字体 4 档(11/13/15/17px)+ 色盲 3 档(Protanopia / Deuteranopia / Tritanopia)+ 高对比度 + 输入辅助 + TTS(野心版);**注入 7+ Presentation / Foundation 系统的渲染循环**(Anti-P1 红线 PR-blocking — 不修改任何数值规则);AccessKit 4.5+ 屏幕阅读器适配(`Window.use_accessibility = true`);dual-focus mode 4.6;mute_visual_parity(全 mute 模式 Hero card 三 element 视觉反馈独立传达);字体 fallback 链 + AUTO_FIT_FLOOR_PX = 11(R-A11Y-2 二次 reflow fallback)。

**Anti-P1 lint 守门 + Pillar 4 tone 守门从 MVP 即上线**(防护性守门,不依赖功能实装)。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0004](../../../docs/architecture/adr-0004-settings-reflow-coalescing.md) | font_size_changed + colorblind_mode_changed 防抖合流 + R-A11Y-2 二次 reflow fallback | LOW |
| [ADR-0008](../../../docs/architecture/adr-0008-visual-boundary-pillar4-vs-mute-parity.md) | mute_visual_parity(Hero card 三 element 反馈)+ 5 类禁视觉守门 | LOW |
| [ADR-0014](../../../docs/architecture/adr-0014-accessibility-settings-injection.md) | Theme.set_default_font_size 单点 + CanvasLayer post-process Shader 整屏 + AccessKit + dual-focus | HIGH |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-a11y-001 | AccessibilitySettings autoload + 字体 4 档 + 色盲 3 档 + 高对比度 + 输入辅助 | ADR-0014 ✅ |
| TR-a11y-002 | 注入 7+ 系统的渲染循环(Anti-P1 红线 PR-blocking) | ADR-0014 ✅ |
| TR-a11y-003 | AccessKit 4.5+ 屏幕阅读器适配 | ADR-0014 ✅ |
| TR-a11y-004 | dual-focus mode 4.6 | ADR-0014 ✅ |
| TR-a11y-005 | mute_visual_parity(Hero card 三 element 反馈) | ADR-0008 ✅ |
| TR-a11y-006 | 字体 fallback 链 + AUTO_FIT_FLOOR_PX = 11 | ADR-0004 + ADR-0014 ✅ |
| TR-a11y-007 | reduce_motion(VS 起,MVP 不实施) | ❌ Gap(VS 推迟,可接受) |
| TR-a11y-008 | TTS 文字转语音(野心版) | ❌ Gap(野心版,推迟超 Alpha) |

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`(Alpha milestone)
- `design/gdd/accessibility-options.md` Section H 14 AC 全部 verify
- Logic stories(字体 fallback 链 + 色盲 LUT + Theme override + CanvasLayer post-process Shader)passing tests in `tests/unit/a11y/`
- Integration stories(注入 7+ 系统渲染循环 + Anti-P1 红线守门 + mute_visual_parity)passing tests in `tests/integration/a11y/`
- UI stories(accessibility-screen + colorblind-hud-fallback)evidence 在 `tests/evidence/`(待 `/ux-design design/ux/accessibility-screen.md` + `colorblind-hud-fallback.md` Phase 4 Alpha)
- **Anti-P1 lint MVP 即上线**:任何 effect / event / unlock / settings 试图反向调高 AP cost / 调低 capacity_floor → PR-blocking + push_error
- **Pillar 4 tone 守门 MVP 即上线**:5 类禁视觉(金光/sparkle/烟花/彩虹/鸡汤)visual lint 通过
- OQ-A14-ENG-01 AccessKit 4.5+ 屏幕阅读器实测(NVDA / VoiceOver)PASS
- OQ-A14-ENG-02 dual-focus mode 4.6 实测 PASS
- OQ-A14-PERF-01 色盲 Shader 低端 GPU 性能 PASS

## Next Step

Stories 已创建(2026-04-29,12 stories)。**MVP 阶段优先**:Story 009(Anti-P1 lint)+ Story 010(Pillar 4 tone 守门)即上线 — 防护性守门,不依赖功能实装。

Alpha milestone 启动后:剩 10 stories 走 `/story-readiness [story-path]` → `/dev-story [story-path]` → `/code-review` → `/story-done` 流程。

实施顺序参考 GDD 依赖树:001(autoload schema)→ 002(Theme 注入)→ 003(色盲 LUT)→ 004/005/006/011/012 并行 → 007/008(实测 OQ-A14-ENG-01/02)。
