# Story 001: 4-Bus Architecture + Master Lock

> **Epic**: audio-manager
> **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-001`
**ADR**: GDD Rule 1(architecture.md L109 引用)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 4 Bus(Master / SFX / Music / Ambient)默认 dB(0 / -6 / -9 / -12)+ Master 只读
- Forbidden: 修改 Master Bus dB

## Acceptance Criteria

- [ ] **AC-FUNC-01** Rule 1:`get_bus_volume(&"Master"/&"SFX"/&"Music"/&"Ambient")` → 0 / -6 / -9 / -12 dB;`set_bus_volume(&"Master", -3.0)` → no-op + push_error + 不发 `bus_volume_changed`;3 可调 Bus 调 set 后 emit 信号

## Implementation Notes

```gdscript
extends Node
const DEFAULTS := {&"Master": 0.0, &"SFX": -6.0, &"Music": -9.0, &"Ambient": -12.0}
const READ_ONLY := [&"Master"]
signal bus_volume_changed(bus: StringName, db: float)

func _ready() -> void:
    for bus in DEFAULTS:
        AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), DEFAULTS[bus])

func set_bus_volume(bus: StringName, db: float) -> void:
    if bus in READ_ONLY:
        push_error("ERR_AUDIO: Master bus is read-only")
        return
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), db)
    emit_signal(&"bus_volume_changed", bus, db)
```

## QA Test Cases

- 4 Bus 默认 dB;Master set → no-op + push_error + 0 emit;3 Bus set → emit 1 次

## Test Evidence

`tests/unit/audio/four_bus_test.gd`

## Dependencies

- Depends on: None
- Unlocks: 全 Audio stories

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 1/1 AC-FUNC-01 COVERED via 5 test 函数
**Test Evidence**: `tests/unit/audio/four_bus_test.gd` (5 tests / GdUnit4) — BLOCKING gate PASS;`DEFAULT_BUS_DB` 默认 dB / `READ_ONLY_BUSES` Master 锁定 / `set_bus_volume(Master)` no-op + 0 emit / SFX 单 emit / 3 可调 Bus 各 emit
**Code Review**: APPROVED (lean-mode autopilot inline);set_bus_volume Master push_error + early return + 不调 AudioServer + 不 emit 信号;3 可调 Bus emit `bus_volume_changed(bus, db)` 一次;`get_bus_volume` 用 `AudioServer.get_bus_index` 兜底 default(headless CI)
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. AudioServer Bus 注册需 `project.godot` 配置 — OUT-OF-SCOPE(autoload registration 协议同 SaveSystem,后续 project-config story 处理)
3. 真音频 dB 改变验证 OUT-OF-SCOPE(无音频资产 + headless CI 无 AudioServer Bus)— `get_bus_volume` 提供 default 兜底
**Tech debt**: None new
**API surface**: `DEFAULT_BUS_DB` / `READ_ONLY_BUSES` / `ADJUSTABLE_BUSES` / `get_bus_volume()` / `set_bus_volume()` / `signal bus_volume_changed`
