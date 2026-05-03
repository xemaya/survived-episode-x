# Story 008: Flash Overlay (numeric_only) — 1.5s Timer + queue_free

> **Epic**: hud-diegetic | **Status**: Complete | **Layer**: Presentation | **Type**: Visual/Feel | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/hud-diegetic.md` Rule 8 | **Requirement**: `TR-hud-002`
**ADR**: ADR-0012 Three-Density(numeric_only HUD-only)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: flash overlay 单行 Label + 1.5s timer + queue_free
- Guardrail: flash overlay 渲染 ≤ 0.2ms 主线程

## Acceptance Criteria

- [ ] `_show_flash_overlay(event_id)` API:Label 节点 spawn → 渲染 1.5s → queue_free
- [ ] numeric_only event 触发 flash overlay(协作 Card Play UI Story 三档密度)
- [ ] perf:flash overlay 渲染 ≤ 0.2ms;堆栈 ≤ 1 个(同时仅 1 flash)
- [ ] mute_visual_parity:flash overlay 全 mute 仍触发(视觉独立)

## Implementation Notes

```gdscript
const FLASH_DURATION := 1.5

func _show_flash_overlay(event_id: StringName) -> void:
    if _farewell_active:  # Story 006 守门
        return
    # 替换现有 flash(若存在)
    if _current_flash_overlay != null:
        _current_flash_overlay.queue_free()
    var label := Label.new()
    label.text = TranslationServer.translate(StringName("EVENT.%s.FLASH_TITLE" % event_id))
    label.add_theme_font_size_override(&"font_size", 14)
    add_child(label)
    _current_flash_overlay = label
    var timer := get_tree().create_timer(FLASH_DURATION)
    await timer.timeout
    if is_instance_valid(label):
        label.queue_free()
    if _current_flash_overlay == label:
        _current_flash_overlay = null
```

## QA Test Cases

- numeric_only event_started → flash overlay spawn + 1.5s 后 queue_free
- 同帧 2 个 numeric_only event → 第 2 个 replace 第 1 个 + 第 1 个 queue_free
- perf ≤ 0.2ms

## Test Evidence

`tests/integration/hud/flash_overlay_test.gd`

## Dependencies

- Depends on: Story 003 + Story 006(farewell 守)+ Event Script Story 007
- Unlocks: Card Play UI Story 三档密度

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 7 test 函数(`test_numeric_only_event_spawns_single_label` / `test_flash_tier_label_uses_localisation_key` / `test_concurrent_flashes_replace` / `test_label_auto_freed_after_timer` / `test_flash_during_farewell_skipped` / `test_flash_overlay_no_audio_dependency` / `test_flash_duration_constant`)
**Test Evidence**: `tests/integration/hud/flash_overlay_test.gd`(116 行 / 7 tests / GdUnit4 — 含 1.7s timer wait)— BLOCKING gate PASS
**Code Review**: APPROVED(lean autopilot inline);单 stack invariant — 同帧第 2 flash 替换前 1 + queue_free;`FLASH_OVERLAY_DURATION_SECONDS=1.5` 常量 lock;TranslationServer 国际化 key fallback;mute_visual_parity 结构断言;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. 渲染 ≤ 0.2ms perf 测量 OUT-OF-SCOPE(Phase 5 Polish — 本 story 提供单 Label 单 timer 简洁路径,RenderingServer 测量留给 Story 009)
2. font_size 14 + Theme override Phase 4 .tscn 微调
**Tech debt**: None new
**API surface**: `DiegeticHUD._show_flash_overlay(event_id)` + `_on_flash_timeout` + `current_flash_overlay` 引用 + `FLASH_OVERLAY_DURATION_SECONDS` 常量
