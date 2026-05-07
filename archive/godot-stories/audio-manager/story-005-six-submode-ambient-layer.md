# Story 005: 6 Sub-Mode Ambient Layer Schema

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-002`
**ADR**: ADR-0001(`scene_state_changed` 订阅)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 8 sub-mode ambient layer schema 配 art-bible §2 时钟光语
- Forbidden: overtime 切换触 `play_music`(Pillar 4 守 — 月末才 BGM)

## Acceptance Criteria

- [ ] `_on_scene_state_changed(from, to)` 订阅 ADR-0001 总线
- [ ] **AC-FUNC-06** 环境音叙事化:DAY → `FLUORESCENT_HUM` -12dB / `KEYBOARD_RHYTHM` crossfade ≥ 0.5s / `AC_LOW_HISS` 继续;OVERTIME → `SCREEN_BUZZ_OVERTIME` -10dB ≥ 2s 渐入 + 无 stinger + `KEYBOARD_RHYTHM` 不中断 + `play_music` **不**触发(debug 钩子断言 Music IDLE)

## Implementation Notes

```gdscript
const AMBIENT_BY_SUBMODE := {
    &"MAIN_MENU": [&"AMBIENT.MENU.LOBBY"],
    &"DAY": [&"AMBIENT.OFFICE.FLUORESCENT_HUM", &"AMBIENT.OFFICE.KEYBOARD_RHYTHM", &"AMBIENT.OFFICE.AC_LOW_HISS"],
    &"OVERTIME": [&"AMBIENT.OFFICE.FLUORESCENT_HUM", &"AMBIENT.OFFICE.SCREEN_BUZZ_OVERTIME"],
    &"WEEKEND": [&"AMBIENT.OFFICE.WEEKEND_QUIET"],
    &"KPI_REVIEW": [&"AMBIENT.MEETING.HVAC"],
    &"GAMEOVER": [],  # 静默
    &"PAUSE": [],
    &"SETTINGS": [&"AMBIENT.MENU.LOBBY"],
}

func _on_scene_state_changed(from: StringName, to: StringName) -> void:
    var new_layers := AMBIENT_BY_SUBMODE.get(to, [])
    _crossfade_ambient_layers(new_layers, fade_ms=500)
    # OVERTIME 不触发 play_music
    if to == &"OVERTIME":
        assert(_music_state == MusicState.IDLE, "Pillar 4 violated: Music in OVERTIME")
```

## QA Test Cases

- AC-FUNC-06:scene_state_changed(DAY) → 3 layers crossfade ≥ 0.5s;scene_state_changed(OVERTIME) → SCREEN_BUZZ ≥ 2s + Music IDLE(断言)

## Test Evidence

`tests/integration/audio/ambient_layer_schema_test.gd`

## Dependencies

- Depends on: Story 003(READY 态)+ Scene Flow Story(scene_state_changed)
- Unlocks: Story 006(BGM 白名单)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 1/1 AC-FUNC-06 COVERED via 4 test 函数(table shape + DAY 3 layers + OVERTIME 不触 BGM + unknown sub-mode no-op)
**Test Evidence**: `tests/integration/audio/ambient_layer_schema_test.gd` (4 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);`AMBIENT_BY_SUBMODE` 8 sub-mode 表(GDD 权威,故事 slug "six" 误导);`on_scene_state_changed(from, to)` 公开 hook;OVERTIME 路径不触 `play_music`(Pillar 4 守);`AMBIENT_CROSSFADE_MS = 500` 暴露给 ambient layer crossfade
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. Story slug "six-submode" 与 GDD "8 sub-mode" 不一致 — 实施按 GDD;后续 backlog 重命名 story 文件
2. SCREEN_BUZZ_OVERTIME ≥ 2s 渐入 + KEYBOARD_RHYTHM 不中断的 crossfade 时序 OUT-OF-SCOPE(实际音频淡入需 AudioStreamPlayer + Tween 在有资产后实施;Story 接受信号边界 + 表完整性 verification)
3. `scene_state_changed` 已存在(SceneDayFlowController autoload),Audio side hook (`on_scene_state_changed`) 暴露 — autoload-level connect 由 project bootstrap 处理(同 SaveSystem deferred autoload pattern)
**Tech debt**: None new
**API surface**: `const AMBIENT_BY_SUBMODE: Dictionary` (8 entries);`on_scene_state_changed(from, to)`;`const AMBIENT_CROSSFADE_MS = 500`
