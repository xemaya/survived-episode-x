# Story 005: Settings 6 信号合流 → #6 timer 500ms debounce

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: `TR-mainmenu-002` + `TR-mainmenu-005` + AC-FUNC-07/08/12 + AC-PERF-02

**ADR Governing Implementation**: ADR-0004 Settings Reflow Coalescing
**ADR Decision Summary**: 6 类 Settings 信号(`bus_volume_changed × 4` + `locale_changed` + `keymap_changed` + `font_size_changed` + `colorblind_mode_changed` + `narrative_density_changed`)同帧 → `#6` 单 timer 500ms debounce → `meta_settings_debounce_ms = 500`(Save Rule 14)→ Save 异步落盘 + Loc 单次 `broadcast_translation_changed_once` 节流 6× + EVENT_ACTIVE 切档延后 + PAUSE 挂起 reflow。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `Timer.start(0.5)` 4.6 已稳;`call_deferred` 用于推合流后的统一处理。

**Control Manifest Rules (Presentation)**:
- Required: 所有 Settings 信号通过 #6 timer 合流,UI 不直接调 SaveSystem.fsync
- Forbidden: 多 Timer 并行(违反 ADR-0004 单 timer 仲裁)
- Guardrail: 音量旋钮即时生效(同帧)+ 磁盘落盘异步 500ms 后

---

## Acceptance Criteria

- [ ] AC-FUNC-07: Music Bus 旋钮 70% → 50%,Audio Bus Music 在同帧内变化(不等防抖)— 实时音量
- [ ] AC-FUNC-08: 500 ms 内连续拖动 Music 旋钮 3 次,500ms 静默后,`meta.save` 仅写入 1 次(Save Rule 14 日志断言)
- [ ] AC-FUNC-12: 叙事密度 long → flash 切换,`narrative_density_changed("flash")` emit + 500ms 后磁盘落盘
- [ ] AC-PERF-02: Music 旋钮 `value_changed` 信号到 Audio Bus 音量更新 ≤ 1 帧(16.6ms)
- [ ] 6 信号同帧到达 → `broadcast_translation_changed_once` Loc 单次 reflow(节流 6×)

---

## Implementation Notes

*Derived from ADR-0004:*

- 信号路由:
  ```gdscript
  # SettingsScreen
  func _on_music_slider_changed(value: float) -> void:
      AudioServer.set_bus_volume_db(MUSIC_BUS, linear_to_db(value / 100.0))  # 即时
      SceneFlow.notify_settings_changed("bus_volume_music", value)  # 合流入口
  ```
- `#6 SceneFlow.notify_settings_changed`:
  ```gdscript
  var _settings_debounce_timer: Timer  # 单 timer
  var _pending_settings: Dictionary = {}

  func notify_settings_changed(key: String, value: Variant) -> void:
      _pending_settings[key] = value
      if not _settings_debounce_timer.is_stopped():
          _settings_debounce_timer.stop()
      _settings_debounce_timer.start(meta_settings_debounce_ms / 1000.0)  # 500ms

  func _on_settings_debounce_timeout() -> void:
      if SceneTree.paused or current_sub_mode == EVENT_ACTIVE:
          # PAUSE / EVENT_ACTIVE 期间挂起 reflow,resume 后再处理
          _settings_pending_post_pause = true
          return
      _flush_settings()

  func _flush_settings() -> void:
      SaveSystem.write_settings_async(_pending_settings)
      Localization.broadcast_translation_changed_once()  # 节流 6×
      _pending_settings.clear()
  ```
- 6 信号 owner 表:
  - `bus_volume_changed × 4` — owner = #4 Audio Manager
  - `locale_changed` — owner = #3 Localization Hooks
  - `keymap_changed` — owner = #2 Input Handler
  - `font_size_changed` — owner = #20 Accessibility(Alpha)
  - `colorblind_mode_changed` — owner = #20 Accessibility(Alpha)
  - `narrative_density_changed` — owner = **#17 本 epic**(per Story 006 + ADR-0001)

---

## Out of Scope

- Story 006: narrative_density_changed signal owner 详细
- Story 003: PAUSE-aware 挂起逻辑(本 story 仅引用挂起入口)
- Story 007: keymap remap 子屏(本 story 仅消费 keymap_changed 信号)

---

## QA Test Cases

- **AC-FUNC-07**: 音量即时
  - Given: Music Bus volume = 70%
  - When: 拖动至 50%(emit value_changed)
  - Then: 同帧 `AudioServer.get_bus_volume_db(MUSIC_BUS)` ≈ linear_to_db(0.5)
  - Edge cases: 极快拖动(每帧 emit) → AudioBus 实时跟,无延迟

- **AC-FUNC-08**: 500ms 防抖磁盘
  - Given: 500ms 内 emit value_changed 3 次
  - When: 静默 500ms 后
  - Then: `meta.save` 写入 1 次(SaveSystem fsync 日志断言);3 次拖动期间无 fsync 调用
  - Edge cases: 第 4 次拖动正好 500ms 临界 → 重置 timer,不分两次写

- **AC-FUNC-12**: 叙事密度落盘
  - Given: 当前 `long`
  - When: emit `narrative_density_changed("flash")`
  - Then: `_pending_settings["narrative_density"] == "flash"` AND 500ms 后 `meta.save.narrative_density == "flash"`
  - Edge cases: 切换连续 long → flash → standard → long(3 次) → 仅最后值落盘

- **AC-PERF-02**: dispatch ≤ 1 帧
  - Given: emit value_changed 在 frame N
  - When: 下一帧
  - Then: AudioBus volume 已更新(`Engine.get_frames_drawn()` 之差 ≤ 1)

---

## Test Evidence

**Required evidence**: `tests/integration/main_menu/six_signal_coalescing_debounce_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 003(PAUSE-aware 入口);Story 004(Settings 节点树);`#6 Scene Flow` Story 009(settings debounce coalesce);`#1 Save` Story 004(meta debounce);`#3 Localization` Story 010(reflow broadcast);`#4 Audio` Story 004(bus_volume signal save/load)
- Unlocks: Story 006, 007

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 5/5 COVERED via 5 test 函数(`tests/integration/main_menu/six_signal_coalescing_debounce_test.gd`)经真实 SceneDayFlowController 跑 500ms 防抖 — AC-FUNC-07 同帧 audio dispatch / AC-PERF-02 ≤1 帧 / AC-FUNC-08 3 次连续 → 1 次 settings_meta_flush_requested + last-write-wins / AC-FUNC-12 narrative_density 落盘 / 6 信号 → 1 次 translation_change_broadcast_requested(reflow 节流)
**Test Evidence**: `tests/integration/main_menu/six_signal_coalescing_debounce_test.gd`(GdUnit4 5 tests)— BLOCKING gate PASS
**Code Review**: APPROVED;`handle_volume_slider_changed` 即时调 set_bus_volume_callable + notify_setting_changed_callable 双路径(AC-FUNC-07 实时 + AC-FUNC-08 防抖);notify_setting_changed routing 到 SceneFlow Story 009 单 timer(已 skeleton);`bus_volume_master/music/sfx/ambient` 4 key 通过 prefix + lowercase 自动派生;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0004 Status=Proposed — lean-mode-equivalent
2. EVENT_ACTIVE 切档延后 + PAUSE 挂起 reflow 主体由 SceneFlow Story 009 实施(已 skeleton);本 story 验 controller 端 routing
3. SaveSystem.write_settings_async / Loc.broadcast_translation_changed_once 真实订阅由 production wiring 阶段 connect(本 story 通过 settings_meta_flush_requested + translation_change_broadcast_requested 信号验路径)
**Tech debt**: None new
**API surface**:
- `func handle_volume_slider_changed(bus: StringName, value_percent: float) -> void`
- `func handle_locale_changed(locale: StringName) -> void`
- `func handle_keymap_changed() -> void`
- `func handle_narrative_density_changed(tier: NarrativeDensity) -> void`
- `var notify_setting_changed_callable: Callable` + `set_bus_volume_callable: Callable`(DI seams)
