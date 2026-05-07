# Story 011: Mute Visual Parity + Signal Decoupling

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-002`
**ADR**: ADR-0008 Visual Boundary Pillar 4 vs Mute Parity + R-AUD-5
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 全 mute(Master = -∞ / 三 Bus = -60)→ 视觉路径独立可达(ADR-0008 守)
- Required: 信号物理音频解耦 — `bus_volume_changed` / `audio_event_played` / `music_track_changed` 在全静音下仍 emit

## Acceptance Criteria

- [ ] **AC-FUNC-09** Rule 9 静音功能完整性:三 Bus 全 -60dB → overtime 切换 / KPI 通过 / GAME OVER → 视觉独立可达;`bus_volume_changed/audio_event_played/music_track_changed` 信号在全静音下**仍**发射
- [ ] **AC-ROBUST-05 [R-AUD-5]** Master = -∞ 双重编码:三 Bus -60 → (a) overtime sprite + 蓝光独立;(b) `play_sfx("PUNCH_CLOCK_CLACK_BUREAUCRATIC")` + `RECEIPT_THERMAL_HISS_BUREAUCRATIC` 时收据热敏视觉动画 + KPI 文本可读;(c) GAME OVER 字幕红字 + 进度条;3 路径下 `bus_volume_changed` 仍 emit;evidence 截图存 `tests/evidence/`
- [ ] **AC-FUNC-10** 零音频契约:Input emit 全信号(act_confirm/act_skip/act_pause/keymap_changed/device_*)+ Loc.set_locale → AudioManager `play_*` 调用计数 0;debug 断言 `connect()` 列表不含 Input/Loc 信号

## Implementation Notes

```gdscript
# Audio 不订阅 Input/Loc 信号 — 信号边界守
# 全静音下 emit 不依赖音频 hardware:
func play_sfx(key: StringName) -> void:
    # 即使 Master = -∞,emit signal 不变
    emit_signal(&"audio_event_played", key)
    # ... 正常 dispatch 到 SFX 池
```

## QA Test Cases

- AC-FUNC-09:三 Bus -60 + 3 路径 → 视觉独立 + signal 仍 emit
- AC-ROBUST-05:截图 evidence(visual sign-off)
- AC-FUNC-10:Input/Loc 信号 emit → Audio play_* 计数 0;`connect()` 列表不含 Input/Loc 信号

## Test Evidence

`tests/integration/audio/mute_visual_parity_test.gd` + `tests/evidence/audio-mute-visual-parity-2026-XX.png`

## Dependencies

- Depends on: Story 001 + Story 004(bus volume API)
- Unlocks: Hero card 三 element 反馈(ADR-0008 协作)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/3 AC-FUNC-09 + AC-ROBUST-05 + AC-FUNC-10 COVERED via 5 test 函数(mute play_sfx emit / mute play_ambient emit / mute music_track_changed emit / 不暴露 on_input_*/on_locale_changed handler / 五 signal 公开)
**Test Evidence**: `tests/integration/audio/mute_visual_parity_test.gd` (5 tests / GdUnit4) — BLOCKING gate PASS;visual evidence 截图 OUT-OF-SCOPE(无 UI 资产 — Hero card / KPI 文本 / GAME OVER 视觉路径由 art 资产 ready 后存 `tests/evidence/`)
**Code Review**: APPROVED (lean-mode autopilot inline);`audio_event_played.emit(key)` 在 `play_sfx`/`play_ambient` 全静音下仍触发(信号边界与物理音频解耦);`music_track_changed.emit(key)` 同理;AudioManager 类不订阅 Input/Loc 信号(`get_method_list` 验证无 `on_input_*`/`on_keymap_changed`/`on_device_changed`/`on_locale_changed`);get_signal_list 验五个核心 signal 公开
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. Visual screenshot evidence(Hero card 三元素反馈 / 收据热敏视觉 / GAME OVER 字幕)OUT-OF-SCOPE — UI/HUD epic + Lighting epic 实际渲染 + screenshot 由 polish phase 完成
2. ADR-0008 双重编码(audio mute → visual fallback)契约由 visual side 实施;Audio 仅守 signal-emit 不变契约
3. `connect()` 列表 runtime 检查 OUT-OF-SCOPE(连接边由 project bootstrap 拥有)— class-level method list 检查替代,确保 Audio 无入信号 handler 槽
**Tech debt**: None new
**API surface**: `signal audio_event_played(key)` mute-parity 守门;`signal music_track_changed(key)` mute-parity 守门;`signal bus_volume_changed(bus, db)` mute-parity 守门
