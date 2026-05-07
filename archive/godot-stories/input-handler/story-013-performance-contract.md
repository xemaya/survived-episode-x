# Story 013: Performance Contract Verification(P5 ≤ 1 帧)

> **Epic**: input-handler
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-001`
**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix
**ADR Decision Summary**: Pillar 5 ≤ 1 帧 dispatch 承诺 — `_input(event)` 同帧内完成全部 act_* 信号发射(无 call_deferred);Profiler "Input" 分类 p99 < 1ms 主线程;modal lock acquire/release p99 < 0.1ms;100 skippable broadcast 同帧 < 1ms;load_keymap < 50ms。

**Engine**: Godot 4.6 | **Risk**: LOW(GdUnit4 perf assertion + Time.get_ticks_usec)
**Engine Notes**: `Time.get_ticks_usec()` 微秒精度;`call_deferred` 调用计数检测靠 mock。

**Control Manifest Rules**:
- Guardrail: dispatch ≤ 1 帧;无 call_deferred(P5 守)
- Guardrail: act_* 同帧 dispatch p99 < 1ms;modal lock p99 < 0.1ms;100 skippable broadcast < 1ms
- Guardrail: load_keymap < 50ms 启动期(不阻 P5 5 秒进入)

## Acceptance Criteria

- [x] **AC-PERF-01** R3 ≤ 1 帧 dispatch:1000 次不同 act_* 事件(KB + Gamepad + Mouse 混合)→ 每帧 `_input(event)` 调用到 act_* 信号发射在同一 `_input` 调用内 + Profiler Input 分类 p99 < 1ms 主线程 + 零事件用 call_deferred(日志断言无 call_deferred 来自 InputHandler) — **PARTIAL/COMPLETE WITH NOTES**: dispatch-side 全 4 子路径(arbiter / skippable / D-Pad / input-method)p99 + zero-call_deferred 静态守门 + 帧预算 covered by `tests/integration/input/perf_input_dispatch_test.gd`(3 fns);act_* 信号发射半段 DEFERRED 至 Story 002 land(同 suite docstring 已记录后续 test fn 名)
- [x] **AC-PERF-02** R3 + R7 modal lock acquire/release:1000Hz 频率连续 acquire+release 各 500 次 → 单次 acquire p99 < 0.1ms;单次 release p99 < 0.1ms(主线程) — covered by `tests/integration/input/perf_modal_lock_test.gd`(3 fns,acquire blocking + release + acquire non-blocking)
- [x] **AC-PERF-03** R6 skippable broadcast 100 entries:100 个 skippable 条目(全有效 instance,callback no-op)→ 触发合规 skip → 全 100 callback 同帧 `_input` 内同步广播 + 主线程耗时 < 1ms + 帧预算不超 16.6ms — covered by `tests/integration/input/perf_skippable_broadcast_test.gd`(3 fns,single broadcast + synchronous fire-all + burst 100×)
- [x] **AC-PERF-04** R1 + 启动 keymap 加载 < 50ms:`meta.input.keymap` payload 含全 12 act_* 三类绑定 → `load_keymap(payload)` 端到端 < 50ms + 不阻塞 `_input` 回调 + 5 秒进入承诺不受影响 — covered by `tests/integration/input/perf_load_keymap_test.gd`(3 fns,end-to-end + p99 batch + bindings synchronously applied)

## Implementation Notes

```gdscript
# tests/unit/input/perf_input_dispatch_test.gd
extends GdUnitTestSuite

const ITERATIONS := 1000
const P99_THRESHOLD_USEC := 1000  # 1ms

func test_dispatch_per_frame_p99():
    var times: Array[int] = []
    for i in range(ITERATIONS):
        var event := _make_random_act_event()
        var start := Time.get_ticks_usec()
        InputHandler._input(event)
        var elapsed := Time.get_ticks_usec() - start
        times.append(elapsed)
    times.sort()
    var p99 := times[ITERATIONS * 99 / 100]
    assert_int(p99).is_less(P99_THRESHOLD_USEC)
    # 检查无 call_deferred
    assert_array(InputHandler._call_deferred_log).is_empty()
```

## Out of Scope

- Story 002:NORMAL 态 dispatch 实现(本 story 仅 perf 验证)
- Story 005:Modal lock 实现(本 story 仅 perf 验证)

## QA Test Cases

- **AC-PERF-01**:1000 次混合 act_* 事件 → 同帧 dispatch + p99 < 1ms + 0 call_deferred
- **AC-PERF-02**:1000Hz × 500 acquire+release 各 → p99 < 0.1ms 主线程
- **AC-PERF-03**:100 skippable entries → 同帧 broadcast + 主线程 < 1ms + 16.6ms 预算
- **AC-PERF-04**:全 12 act_* keymap payload → load_keymap < 50ms + 不阻 _input 回调

## Test Evidence

**Story Type**: Logic(自动化 perf assertion)
**Required evidence**: `tests/integration/input/perf_input_dispatch_test.gd` + `tests/integration/input/perf_modal_lock_test.gd` + `tests/integration/input/perf_skippable_broadcast_test.gd` + `tests/integration/input/perf_load_keymap_test.gd`
**Status**: [x] All 4 test files created (12 test 函数 total) — BLOCKING gate PASS

## Dependencies

- Depends on: Story 002, 004, 005, 012(各自实施完成后才能 perf 验证)
- Unlocks: Polish 阶段 perf gate

## Completion Notes
**Completed**: 2026-04-30
**Criteria**: 4/4 covered (AC-PERF-01 PARTIAL — dispatch-side fully covered, act_* signal emission half DEFERRED to Story 002 land)
**Deviations**:
- DEFERRED — AC-PERF-01 文字契约 "_input(event) 调用到 act_* 信号发射在同一 _input 调用内":act_* 12-action dispatch 由 Story 002 拥有 + 尚未 land。本 perf story 已落地 dispatch-side 全 4 子路径 p99 + frame-budget + zero-call_deferred 守门;act_* 信号真正发射的同帧守门留待 Story 002 closeout 时回填新增 test fn `test_act_signal_emission_same_frame_as_input_call`(perf_input_dispatch_test.gd suite docstring 已记录)。
- DEVIATION — Story pseudocode 用 `assert_array(InputHandler._call_deferred_log).is_empty()` 运行时 call_deferred 计数器:本 story 用静态源码 grep 替代(剥注释 + 子字符串扫描)— engine instrumentation hooks 尚未提供,静态 source-scan 是 BLOCKING gate;Polish-phase perf gate 可层叠 runtime counter 加固。已验证 `src/autoload/input_handler.gd` 当前 0 处 `call_deferred` 调用。
- ADVISORY — Story 002 dependency Status=Ready 非 Complete:autopilot 模式 explicit accept dependency risk;perf suite 不依赖 Story 002 dispatch 本身存在,仅 act_* signal-emit 半段 deferred。
- ADVISORY — Story 005 dependency 列在 Status=Ready,但实际查阅源码已 implementation-complete(modal lock 公共 API 全 land)— story file Status drift 而非真缺失;modal lock perf suite 直接驱动现有 public API。
- ADVISORY — ADR-0001 Status=Proposed(lean-mode 等同 Accepted,与 ADR 0001-0014 同性质)。
**Test Evidence**: 4 perf integration test files,12 test 函数,全在 `tests/integration/input/perf_*.gd`
**Code Review**: APPROVED WITH SUGGESTIONS (lean mode 内联 review;0 required changes / 4 stylistic non-blocking 建议:`_input` 公共 seam vs 直接调虚方法 / `_make_event_for` Resource fixture 替代 / `assert_int(probes.size())` 末尾 pin 多余 / `call_deferred` 静态扫描 substring 范围说明)
**Manifest Staleness**: PASS(story=2026-04-28 / current=2026-04-28)
**QL-TEST-COVERAGE / LP-CODE-REVIEW**: Skipped — Lean mode(已在 /code-review skill 内联完成)
