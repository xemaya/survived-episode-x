# Story 009: Settings Debounce Single Timer + 6-Signal Coalescing

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-005`
**ADR**: ADR-0004 Settings Reflow Coalescing
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `_settings_debounce_timer` Timer 节点 PROCESS_MODE_ALWAYS(跨 pause)+ 500ms wait_time
- Required: 6 信号合流到单 timer(`bus_volume_changed × 4 + locale_changed + keymap_changed + font_size_changed + colorblind_mode_changed + narrative_density_changed`)
- Forbidden: per-signal-key 独立防抖(forbidden_pattern `per_signal_key_debounce`)

## Acceptance Criteria

- [ ] `_settings_debounce_timer: Timer`(在 _ready 创建)+ `_pending_settings_changes: Dictionary` + `_reflow_required: bool`
- [ ] 6 信号订阅:任一到达 → reset timer + 标记 reflow_required(若 locale/font_size/colorblind)
- [ ] 500ms 后 timer.timeout → SaveSystem.save_meta_async(payload) + LocalizationHooks.broadcast_translation_changed_once(if reflow_required)
- [ ] **AC-CONTRACT** 6 信号同帧 → 1 次 reflow 广播 + 1 次 meta 落盘(节流 6×)

## Implementation Notes

```gdscript
var _settings_debounce_timer: Timer
var _pending_settings_changes: Dictionary = {}
var _reflow_required: bool = false

func _ready() -> void:
    # ... 其他 _ready 逻辑
    _settings_debounce_timer = Timer.new()
    _settings_debounce_timer.one_shot = true
    _settings_debounce_timer.wait_time = 0.5
    _settings_debounce_timer.process_mode = Node.PROCESS_MODE_ALWAYS
    _settings_debounce_timer.timeout.connect(_on_settings_debounce_timeout)
    add_child(_settings_debounce_timer)
    
    # 订阅 6 信号(假定 #17 Settings 已 emit)
    SettingsUI.bus_volume_changed.connect(_on_setting.bind(&"bus_volume_changed"))
    SettingsUI.locale_changed.connect(_on_setting.bind(&"locale_changed"))
    # ... 其余 4 信号

func _on_setting(payload: Variant, signal_name: StringName) -> void:
    _pending_settings_changes[signal_name] = payload
    if signal_name in [&"locale_changed", &"font_size_changed", &"colorblind_mode_changed"]:
        _reflow_required = true
    _settings_debounce_timer.start()  # reset

func _on_settings_debounce_timeout() -> void:
    SaveSystem.save_meta_async(_aggregate_meta(_pending_settings_changes))
    if _reflow_required:
        LocalizationHooks.broadcast_translation_changed_once()
    _pending_settings_changes.clear()
    _reflow_required = false
```

## QA Test Cases

- 6 信号同帧 emit → 500ms 后 SaveSystem.save_meta_async 1 次调用 + broadcast_translation_changed_once 1 次

## Test Evidence

`tests/integration/scene_flow/settings_debounce_test.gd`

## Dependencies

- Depends on: Story 003(autoload)+ Save Story 004(meta debounce 协作)+ Loc Story 010(broadcast)+ Main Menu Story(SettingsUI emit)
- Unlocks: Loc Story 005(演出 lock + flush_pending_locale)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED — `_settings_debounce_timer: Timer` 单 timer + `_pending_settings_changes: Dictionary` 合流 + `_reflow_required: bool` flag + 6 信号 funnel 入 `notify_setting_changed(signal_name, payload)` + 500ms timer reset + flush 单次 emit;PAUSE 期间 reflow defer + resume 后 emit 一次;`settings_meta_flush_requested` payload 携 6 keys 单次广播
**Test Evidence**: `tests/integration/scene_flow/settings_signals_coalescing_test.gd` (4 tests / GdUnit4 — pre-existing) — BLOCKING gate PASS(已覆盖 AC-COALESCE-SIX / AC-TIMER-RESET / AC-PAUSE-RESUME / AC-NON-REFLOW)
**Code Review**: APPROVED;实施 reused save-system Story 004 已有的 debounce skeleton(`request_save_meta` + `notify_setting_changed` + `_on_settings_debounce_timeout`)+ 公开 `is_settings_debounce_pending()` / `get_pending_settings_changes()` / `has_pending_translation_change()` test seam;无 BLOCKING / 无 inline fix
**Engine API Verification**: Timer.process_mode / one_shot / wait_time / start API 是 Godot 4.x stable
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0004 Status=Proposed — lean-mode-equivalent
2. SettingsUI 6 信号订阅由 Main Menu Story 实施(本 story 提供 `notify_setting_changed` 入口);本 story 实施 funnel + debounce + flush 三段;cross-epic wire-up 在 Settings UI epic 完成
3. SaveSystem.save_meta_async / LocalizationHooks.broadcast_translation_changed_once 调用由 listener stories 完成(本 story 实施 `settings_meta_flush_requested` 信号 + `translation_change_broadcast_requested` 信号 emit)
**Tech debt**: None new
**API surface**: `notify_setting_changed(signal_name: StringName, payload: Variant) -> void` + `signal settings_meta_flush_requested(payload: Dictionary)` + `signal translation_change_broadcast_requested` + `signal meta_save_requested(state: Variant)` + 3 测试 seam
