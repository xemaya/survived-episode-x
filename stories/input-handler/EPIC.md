# Epic: Input Handler

> **Layer**: Foundation
> **GDD**: [design/gdd/input-handler.md](../../../design/gdd/input-handler.md)
> **Architecture Module**: Input Handler #2(Foundation)
> **Status**: Ready(GDD APPROVED 2nd lean review)
> **Tier**: MVP
> **Engine Risk**: HIGH(`@abstract` 4.5+ + `change_scene_to_packed()` 4.5 + `dual-focus mode` 4.6 + SDL3 gamepad 4.5 + Recursive Control disable 4.5)
> **Stories**: 13 created — see Stories section below

## Overview

Input Handler 是 Foundation 层输入抽象。InputMap 12 actions 注册(`act_pause` / `act_skip` / `act_focus_*` 8 方向 / `act_confirm`);3-state 状态机(NORMAL / MODAL_LOCKED / REMAPPING);skippable token 注册 API(`register_skippable` / `unregister_skippable`);keymap_changed 经 ADR-0004 防抖单 timer(500ms)合流落盘 meta.save。Godot 4.6 dual-focus mode 启用(键盘 + gamepad 同时 focus 独立)+ SDL3 gamepad 兼容 + Recursive Control disable for modal stack。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| [ADR-0001](../../../docs/architecture/adr-0001-signal-ownership-matrix.md) | act_pause / act_skip / act_focus_* / act_confirm signal owner = #2;keymap_changed 防抖合流到 Save | LOW |
| [ADR-0002](../../../docs/architecture/adr-0002-autoload-init-order.md) | InputHandler autoload 第 5 位;`@abstract` 4.5+ + Recursive Control disable for modal | HIGH |
| [ADR-0014](../../../docs/architecture/adr-0014-accessibility-settings-injection.md) | `input/dual_focus_mode = true`(Godot 4.6) | HIGH |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-input-001 | InputMap 12 actions 注册 | ADR-0001 + ADR-0002 ✅ |
| TR-input-002 | 3-state 状态机(NORMAL/MODAL_LOCKED/REMAPPING) | ⚠️ Partial(GDD-internal) |
| TR-input-003 | skippable token 注册 API | ⚠️ Partial(GDD-internal) |
| TR-input-004 | keymap_changed 防抖 500ms | ADR-0004 ✅ |
| TR-input-005 | dual-focus mode 4.6 启用 | ADR-0014 ✅ |
| TR-input-006 | SDL3 gamepad 4.5+ 兼容 | ⚠️ Partial(LOW risk,引擎自动) |
| TR-input-007 | Recursive Control disable 4.5 modal stack | ⚠️ Partial(GDD-internal) |

**Untraced Requirements**: None — 4 partial 均为 GDD-internal stable contract,GDD 自身已 lock,不需独立 ADR。

## Definition of Done

- 所有 stories 实施 + reviewed + closed via `/story-done`
- `design/gdd/input-handler.md` Section H 25 AC 全部 verify(23 MVP / 2 Beta / 4 [RISK GUARD])
- Logic stories(deadzone / D-Pad repeat / path arbitration 公式)passing tests in `tests/unit/input/`
- Integration stories(modal stack / dual-focus / Steam Input)passing tests in `tests/integration/input/`
- UI stories(remap-screen)evidence 在 `tests/evidence/`(待 `/ux-design design/ux/remap-screen.md` Phase 4)
- OQ-A14-ENG-02 dual-focus 实测 PASS(Pre-Production prototype)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [InputMap 12 Actions Registration](story-001-action-map-12-actions.md) | Logic | Complete | ADR-0002 + ADR-0001 |
| 002 | [NORMAL State Legality + Co-Fire](story-002-normal-state-legality.md) | Logic | Complete | ADR-0001 |
| 003 | [Dual-Focus + Path Arbitration](story-003-dual-focus-arbitration.md) | Integration | Done | ADR-0014 |
| 004 | [skippable Token Registry + Auto-Purge](story-004-skippable-token-registry.md) | Logic | Done | ADR-0001 |
| 005 | [Modal Lock Stack + Two-Tier Strategy](story-005-modal-lock-stack.md) | Integration | Done | ADR-0002 |
| 006 | [Keymap Remap + 500ms Debounce](story-006-keymap-remap-debounce.md) | Integration | Complete | ADR-0004 + ADR-0001 |
| 007 | [Gamepad Hot-Plug — Pause + Toast](story-007-gamepad-hotplug-pause-toast.md) | Integration | Complete | ADR-0001 + ADR-0002 |
| 008 | [Deadzone 3-Zone Formula F1](story-008-deadzone-formula-f1.md) | Logic | Complete | GDD-internal |
| 009 | [D-Pad Repeat Formula F2](story-009-d-pad-repeat-formula-f2.md) | Logic | Complete | GDD-internal |
| 010 | [Steam Input Pass-Through + Legacy Smoke](story-010-steam-input-passthrough-legacy.md) | Integration | Complete | ADR-0002 |
| 011 | [OS Focus Out — reset_all_action_presses](story-011-os-focus-out-reset-actions.md) | Integration | Complete | ADR-0001 |
| 012 | [Tuning Knob Clamp + load_keymap](story-012-tuning-clamp-load-keymap.md) | Logic | Complete | ADR-0003 |
| 013 | [Performance Contract Verification](story-013-performance-contract.md) | Logic | Complete | ADR-0001 |

**Story type breakdown**:8 Logic + 5 Integration

**Dependency tree**:
- 001(InputMap)→ 002(NORMAL)+ 008(F1)+ 012(clamp)
- 002 → 003(dual-focus)+ 004(skippable)
- 008 → 009(F2)→ 010(Steam Input)
- 004 + 002 → 005(Modal lock)→ 007(Gamepad hotplug)
- 009 + 001 → 011(focus_out reset)
- 002/004/005/012 → 013(perf 验证)
- 006(keymap remap)blockedBy Save Story 004(meta debounce 协作)

## Next Step

按依赖树推进:001 → 002 / 008 / 012 并行 → 003 / 004 / 009 并行 → 005 / 010 / 011 并行 → 006 / 007 → 013(perf 验证最后跑)。
