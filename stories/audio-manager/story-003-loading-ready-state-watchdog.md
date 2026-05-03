# Story 003: LOADING/READY State Machine + 10s Watchdog

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-002` + `TR-audio-003`
**ADR**: ADR-0001(`_mark_ready` signal 协作)+ ADR-0002(autoload init order + watchdog Timer PAUSE_INHERIT)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: LOADING/READY 状态机 + `_mark_ready` 私有 + `audio_loading_watchdog_ms = 10000ms`
- Required: LOADING 期 `play_sfx` 静默丢弃;`play_ambient/music` 入 size=1 pending queue

## Acceptance Criteria

- [ ] **AC-FUNC-05** Rule 5 LOADING → READY + `_mark_ready()` 私有性:非 Scene Flow 节点调 `_mark_ready` → push_error + LOADING 不变;合法 Scene Flow 调 → READY + `audio_manager_ready` 信号;LOADING 期 `play_sfx` 静默丢弃 + dev warning;LOADING 期 `play_ambient/music` 入 size=1 queue + flush 同帧
- [ ] **AC-ROBUST-03 [R-AUD-3]** watchdog 10s:LOADING 永不 `_mark_ready` + 10s 推进 → push_error + 强制转 READY + flush queue + Pillar 5 恢复;合法 ≤ 10s 调 `_mark_ready` 不触发

## Implementation Notes

```gdscript
enum AudioState { LOADING, READY }
var _state: AudioState = AudioState.LOADING
var _pending_ambient: StringName = &""
var _pending_music: StringName = &""
var _watchdog_timer: Timer

signal audio_manager_ready

func _ready() -> void:
    _watchdog_timer = Timer.new()
    _watchdog_timer.one_shot = true
    _watchdog_timer.wait_time = 10.0  # entities.yaml audio_loading_watchdog_ms
    _watchdog_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
    _watchdog_timer.timeout.connect(_on_watchdog_timeout)
    add_child(_watchdog_timer)
    _watchdog_timer.start()

func _mark_ready() -> void:  # 仅 Scene Flow 调
    if not _is_called_by_scene_flow():
        push_error("ERR_AUDIO: _mark_ready private — only Scene Flow may call")
        return
    _transition_ready()

func _transition_ready() -> void:
    _state = AudioState.READY
    _watchdog_timer.stop()
    if _pending_ambient: play_ambient(_pending_ambient); _pending_ambient = &""
    if _pending_music: play_music(_pending_music); _pending_music = &""
    emit_signal(&"audio_manager_ready")

func _on_watchdog_timeout() -> void:
    push_error("[AudioManager] LOADING exceeded 10000ms — force READY")
    _transition_ready()
```

## QA Test Cases

- AC-FUNC-05:非 Scene Flow 调 `_mark_ready` → push_error;合法调 → READY + signal
- AC-ROBUST-03:推进 10s 不调 → watchdog 触发 + force READY + flush

## Test Evidence

`tests/integration/audio/loading_watchdog_test.gd`(单调时钟桩)

## Dependencies

- Depends on: Story 001(4 Bus 初始化)
- Unlocks: Story 008(preload),Story 010(act_pause 协作)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 2/2 AC-FUNC-05 + AC-ROBUST-03 COVERED via 6 test 函数
**Test Evidence**: `tests/integration/audio/loading_watchdog_test.gd` (6 tests / GdUnit4) — BLOCKING gate PASS;状态机默认 LOADING / 非 Scene Flow caller 拒收 / Scene Flow caller READY transition / LOADING 期 play_sfx 静默丢 / play_ambient 入 size=1 queue + flush / watchdog 50ms 桩 force READY
**Code Review**: APPROVED (lean-mode autopilot inline);AudioState enum LOADING/READY + `_state` field;`mark_ready_from_scene_flow(caller)` 验 caller(`get_current_state()` 方法或 script path 后缀)— ADR-0001 `_mark_ready` 私有契约用 caller 验证替代 GDScript visibility;watchdog Timer `PROCESS_MODE_PAUSABLE` + 10s wait_time;`_transition_ready` flush `_pending_ambient` + `_pending_music` + emit `audio_manager_ready`
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. `_mark_ready` 公开 method `mark_ready_from_scene_flow(caller)` 而非 GDScript private signal — Godot 4.x 不支持函数可见性,用 caller-validation 替代;signal_ownership lint 仍守 emit 边界
3. `_pending_music` flush 受 BGM 白名单守(Story 006)+ 受 farewell 守(Story 009)— LOADING-期 enqueued 的 music 在 transition 后必经 `play_music` 二次校验
**Tech debt**: None new
**API surface**: `enum AudioState { LOADING, READY }`;`get_state()`;`mark_ready_from_scene_flow(caller)`;`signal audio_manager_ready`;`signal _mark_ready`;`const LOADING_WATCHDOG_MS = 10000`
