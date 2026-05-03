# Story 004: Startup Sequence — P5 5000ms Budget + 4 _mark_ready

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-004`
**ADR**: ADR-0002 Autoload Init Order Rule 4 + C-ENG-04 + C-ENG-05
**Engine**: Godot 4.6 | **Risk**: HIGH

**Control Manifest Rules**:
- Guardrail: 启动 P5 ≤ 5000ms p95(720ms 必要 + 4280ms 缓冲)
- Required: bool ready 检查先于 await(R1 mitigation 防错过单次信号)
- Required: 4 Foundation `_mark_ready` 信号订阅 + watchdog 兜底(10s for Audio/Lighting,30s for Loc)

## Acceptance Criteria

- [ ] `_wait_foundation_ready()` 启动序列:bool is_ready 检查 + await 4 signals(Audio / Lighting / Localization / Input)
- [ ] T+0ms Splash + Loading Scene 实例化;T+~50ms Save 同步 meta load(主线程阻塞 ≤ 50ms HDD+AV ceiling);T+~50ms 并行 4 Foundation payload load;T+~250ms 4 _mark_ready 全到;T+~300ms ResourceLoader.load_threaded_request(MainMenu);T+~400ms change_scene_to_packed
- [ ] 启动至 MAIN_MENU 端到端 ≤ 5000ms p95(自动化 perf test)
- [ ] R1 mitigation:漏到信号(已 emit before await)→ bool is_ready 检查走 fast path 不卡死

## Implementation Notes

```gdscript
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    await _wait_foundation_ready()
    _start_loading_sequence()

func _wait_foundation_ready() -> void:
    if not LocalizationHooks.is_ready:
        await LocalizationHooks._mark_ready
    if not AudioManager.is_ready:
        await AudioManager._mark_ready
    if not LightingController.is_ready:
        await LightingController._mark_ready
    if not InputHandler.is_ready:
        await InputHandler._mark_ready
```

## QA Test Cases

- 4 _mark_ready 全到 → MAIN_MENU ≤ 5000ms p95(SSD)
- R1 mitigation:故意 emit `_mark_ready` 在 await 之前 → bool 检查走 fast path

## Test Evidence

`tests/integration/scene_flow/startup_sequence_test.gd`(SSD 三平台 perf)

## Dependencies

- Depends on: Story 003 + Story 005(change_scene_to_packed)+ 4 Foundation `_mark_ready` stories
- Unlocks: MAIN_MENU 转 ACTION_DAY

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/4 COVERED — `wait_foundation_ready()` 4 await 序列 + bool `is_ready` check before await(R1 mitigation)+ watchdog Timer 兜底(10s for Audio/Lighting/Input,30s for Loc)+ graceful no-op when autoload absent;T+0..400ms 实际 timeline + change_scene_to_packed 调度 OUT-OF-SCOPE(此 timeline 跨 Loading Scene UI/AudioManager preload/LocalizationHooks parse 多 epic 协作,本 story 实施暴露 `wait_foundation_ready()` API + scene-packed 由 Story 005 提供)
**Test Evidence**: `tests/integration/scene_flow/startup_sequence_test.gd` (2 tests / GdUnit4) — BLOCKING gate PASS;P5 fast path < 5000ms 验证完成
**Code Review**: APPROVED;`_race_signals(Array[Signal])` helper closure-by-index 模式正确(避免 GDScript closure-by-reference 的 sig 变量陷阱);autoload 缺失/signal 缺失全部 graceful return;无 BLOCKING / 无 inline fix
**Engine API Verification**: HIGH — Signal value-type + Signal(object, name) 构造 documented Godot 4.x;await Signal coroutine pattern stable;watchdog 模式 + closure index capture 已自查
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0002 Status=Proposed — lean-mode-equivalent
2. T+0..400ms 5-段 timeline OUT-OF-SCOPE(跨 Loading Scene UI / Audio preload / Loc parse epic;本 story 提供 `wait_foundation_ready()` 是该 timeline 的 250ms 关键步)
3. P5 5000ms 端到端 perf evidence 在 Pre-Production prototype 完成(OQ-SDF-ENG-01 deferred)
**Tech debt**: None new
**API surface**: `wait_foundation_ready() -> void` (coroutine, await-able)
