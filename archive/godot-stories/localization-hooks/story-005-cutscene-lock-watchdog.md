# Story 005: Cutscene Lock + flush_pending_locale + 30s Watchdog

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-004` + `TR-loc-006`
**ADR Governing Implementation**: ADR-0004 + ADR-0002(PAUSE_INHERIT)
**ADR Decision Summary**: 演出 lock(`Scene Flow.locale_switch_locked = true`)→ pending locale 缓存 → flush_pending_locale 同帧应用;`locale_lock_watchdog_ms = 30000ms` 兜底强制 flush + push_error + reset lock(R-LOC-3);PAUSE 中 locale 切换挂起 + resume 后单次 emit。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: Timer 节点 `process_mode = PAUSE_INHERIT`(pause 期间挂起,wall-clock 不推进 — ADR-0002 协作)。

**Control Manifest Rules**:
- Required: 30s watchdog reset lock 兜底
- Required: PAUSE 期间挂起 + resume 单次 emit

## Acceptance Criteria

- [x] `flush_pending_locale()` API + `_pending_locale` 缓存
- [x] **AC-FUNC-06** 演出 lock 排队 + flush:`Scene Flow.locale_switch_locked = true` 时 `set_locale(&"zh_CN")` 不本帧生效 + pending 缓存 + signal 不发射;Scene Flow 调 `flush_pending_locale()` → 切换 flush 同帧完成 + signal 发射 + queue 清空;flush 时 lock 仍 true → 不执行 + ERROR 日志
- [x] **AC-ROBUST-03 [R-LOC-3]** 30s watchdog:本 story 内验 watchdog Timer wait_time=30.0s + process_mode=PAUSABLE + timeout handler 行为(push_error + reset lock + 强制 flush + signal 发射 + 空 queue 路径分支);wall-clock 30s 实测不在 deterministic 测试范围(stub timeout handler 直接调用)— OUT-OF-SCOPE 30s 真实计时实测交 manual smoke / soak test;合法演出 < 30s 完成时 watchdog 不触发已验
- [x] PAUSE 中 locale switch:Story 005 内置 `_pending_translation_change` flag + `request_soft_resume` 公有 surface 已就位;`broadcast_translation_changed_once` 检测 `get_tree().paused` 内部完整实现 = OUT-OF-SCOPE 交 Story 010(Story 005 仅 close 了 resume drain idempotent 半边)

## Implementation Notes

```gdscript
# localization_hooks.gd
var _pending_locale: StringName = &""
var _watchdog_timer: Timer

func _ready() -> void:
    _watchdog_timer = Timer.new()
    _watchdog_timer.one_shot = true
    _watchdog_timer.wait_time = 30.0  # locale_lock_watchdog_ms / 1000
    _watchdog_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
    _watchdog_timer.timeout.connect(_on_watchdog_timeout)
    add_child(_watchdog_timer)

func set_locale(locale: StringName) -> void:
    if SceneDayFlowController.is_locale_locked():
        _pending_locale = locale
        _watchdog_timer.start()
        return
    _force_dispatch(locale)

func flush_pending_locale() -> void:
    if SceneDayFlowController.is_locale_locked():
        push_error("[LocalizationHooks] flush_pending_locale called while lock still active")
        return
    if _pending_locale != &"":
        _force_dispatch(_pending_locale)
        _pending_locale = &""
        _watchdog_timer.stop()

func _on_watchdog_timeout() -> void:
    push_error("[LocalizationHooks] locale_switch_locked exceeded 30000ms — force flushing")
    SceneDayFlowController.reset_locale_lock()  # 协作
    if _pending_locale != &"":
        _force_dispatch(_pending_locale)
        _pending_locale = &""
```

## QA Test Cases

- **AC-FUNC-06**:lock=true + set_locale → pending + 不发射;flush(lock 已 false)→ 同帧应用 + signal 发射 + queue 清空;flush(lock 仍 true)→ 不执行 + ERROR 日志
- **AC-ROBUST-03**:lock 永不清 + pending;30s 推进 → watchdog 触发 + push_error + force flush + signal 发射;< 30s 完成时 watchdog 不触发
- **PAUSE**:PAUSE 中 set_locale → 挂起 `_pending_translation_change = true`;resume 后单次 emit

## Test Evidence

`tests/integration/loc/cutscene_lock_test.gd` + `tests/integration/loc/watchdog_30s_test.gd`(单调时钟桩 fixture)

## Dependencies

- Depends on: Story 004 + Scene Flow Story(locale_lock 协作)
- Unlocks: Scene Flow GAMEOVER 1500ms 演出协调

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 in-scope COVERED via 8 cutscene-lock tests + 6 watchdog tests(AC-FUNC-06 lock guard + flush + idempotent + injection guard + AC-ROBUST-03 watchdog Timer 配置 + timeout handler 行为 + 短 cutscene 不触发);wall-clock 30s 实测 OUT-OF-SCOPE,Story 010 PAUSE coalescing 完整 broadcast 实施 OUT-OF-SCOPE
**Test Evidence**: `tests/integration/loc/cutscene_lock_test.gd`(330 行 / 8 tests / GdUnit4)+ `tests/integration/loc/watchdog_30s_test.gd`(279 行 / 6 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode autopilot inline);新增 surface:`set_locale_lock_predicate(Callable)` + `set_locale_lock_reset(Callable)` 注入(decoupled per Control Manifest §6 — 不直引用 SceneDayFlowController 类)+ `flush_pending_locale()` + `request_soft_resume()` + `_pending_locale` / `_pending_translation_change` / `_watchdog_timer` 私有 + `_on_watchdog_timeout()` + 测试 seam(`get_watchdog_wait_seconds` / `capture_lock_push_error_for_testing` / `last_lock_push_error_message`);Timer.wait_time=30.0 + process_mode=PAUSABLE 显式守 ADR-0002 PAUSE_INHERIT;无 BLOCKING / 无 inline fix
**Deviations**(全 ADVISORY,无 BLOCKING):
1. ADR-0004 / ADR-0002 Status=Proposed — lean-mode-equivalent
2. 故事伪代码硬调 `SceneDayFlowController.is_locale_locked()` / `SceneDayFlowController.reset_locale_lock()` — 实施改用 Callable 注入(`_is_locale_locked` / `_reset_locale_lock` 默认 false / no-op)避免硬依赖另一 epic 的 autoload class;Control Manifest §6 解耦原则 + 测试可注入 stub
3. `_on_watchdog_timeout` 暴露为 public-ish(测试直调用)— deterministic 测试需,不能等真 30s
4. 故事伪代码 `Node.PROCESS_MODE_PAUSABLE` 在 Timer 上 — 实测 Godot 4.6 是 `Node.PROCESS_MODE_PAUSABLE` 常量(_watchdog_timer 是 Timer 子类,Node 常量适用)
5. `flush_pending_locale` 在 lock 仍 true 时返 push_error — 故事伪代码 `push_error(...)` 直调,实施加 capture_lock_push_error_for_testing seam(测试不报失败)
6. PAUSE part(`broadcast_translation_changed_once` 检测 paused)— Story 010 显式承担,Story 005 只 land `_pending_translation_change` flag + `request_soft_resume` drain 入口
**Tech debt**: None new
**API surface**: `set_locale_lock_predicate(predicate: Callable) -> void` + `set_locale_lock_reset(reset: Callable) -> void` + `flush_pending_locale() -> void` + `request_soft_resume() -> void` + `get_watchdog_wait_seconds() -> float` + 测试 seam `capture_lock_push_error_for_testing: bool` + `last_lock_push_error_message: String`
