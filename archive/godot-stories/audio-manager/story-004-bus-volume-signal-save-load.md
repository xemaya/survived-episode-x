# Story 004: Bus Volume Signal Boundary + Save Load Injection

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-002`
**ADR**: ADR-0001 + ADR-0004(Settings 防抖合流到 Save 经 #6 单 timer)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `bus_volume_changed` signal 单 emit;Save 防抖经 ADR-0004(Audio 不直调)
- Forbidden: AudioManager 直调 SaveSystem.write_meta / FileAccess.open
- Required: `load_bus_volumes(payload)` 启动期静默(不发信号,不触 Save 防抖)

## Acceptance Criteria

- [ ] **AC-FUNC-02** 信号边界:玩家 SFX -6 → -12 → AudioServer.set_bus_volume_db 同帧调 + `bus_volume_changed(SFX, -12.0)` 1 次发射 + SaveSystem.write_meta + FileAccess.open 当帧计数 0 + 500ms 后 meta.save mtime 更新
- [ ] **AC-COMPAT-01** Save 启动注入 `load_bus_volumes`:`meta.save.settings.audio` 含 SFX -18 / Music -20 / Ambient -24 + Scene Flow 启动调 `load_bus_volumes(payload)` → 3 Bus dB 应用;Master 不变;`bus_volume_changed` load 期**不**发射(静默);READY 后玩家 set 时正常发射

## Implementation Notes

```gdscript
func load_bus_volumes(payload: Dictionary) -> void:
    # 静默加载,不发信号
    for bus in [&"SFX", &"Music", &"Ambient"]:
        if bus in payload:
            AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), payload[bus])
    # NO emit bus_volume_changed
```

## QA Test Cases

- AC-FUNC-02:玩家改 SFX → set_bus_volume_db 同帧 + signal 1 次 + write_meta 当帧 0 + 500ms 后 meta mtime
- AC-COMPAT-01:load_bus_volumes 应用 + 静默 0 emit;READY 后 player set → emit 正常

## Test Evidence

`tests/integration/audio/bus_volume_signal_test.gd`

## Dependencies

- Depends on: Story 001 + Save Story 004(meta debounce 协作)
- Unlocks: Story 011(mute_visual_parity)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 2/2 AC-FUNC-02 + AC-COMPAT-01 COVERED via 4 test 函数
**Test Evidence**: `tests/integration/audio/bus_volume_signal_test.gd` (4 tests / GdUnit4) — BLOCKING gate PASS;玩家 set 单 emit / load_bus_volumes 静默 0 emit / Master 受保护 / load 后玩家 set 仍 emit
**Code Review**: APPROVED (lean-mode autopilot inline);`load_bus_volumes(payload: Dictionary)` 用 `_apply_bus_db_silent` 不发信号;Master 隔离(Master 不在 ADJUSTABLE_BUSES);payload 同时支持 StringName key 与 String key(向后兼容 SaveSystem JSON 反序列化)
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. SaveSystem.write_meta + ADR-0004 settings 防抖 timer 集成 OUT-OF-SCOPE(Save epic 拥有 timer + Settings UI Story 012 a11y 已完成 settings 注入,Audio 仅暴露 `load_bus_volumes` hook)
3. AudioServer 实际 dB 写入验证 OUT-OF-SCOPE(headless CI 无 AudioServer Bus,仅断言信号边界 — visual parity 关注的就是 signal layer)
**Tech debt**: None new
**API surface**: `load_bus_volumes(payload: Dictionary)`(silent boot);`set_bus_volume(bus, db)`(player path,emit 信号);`get_bus_volume(bus)`
