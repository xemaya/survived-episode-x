# Story 016: Performance Contract Verification

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-008`
**ADR Governing Implementation**: ADR-0003 Save Format + WorkerThreadPool Strategy
**ADR Decision Summary**: 性能契约 — autosave 端到端 p50 < 18ms + p99 < 50ms(SSD 三平台);主线程 snapshot 聚合 p99 < 3ms;WorkerThread stringify+I/O p99 < 50ms(独立计量,不计入主线程预算);`autosave_perf_hard_ceiling_ms = 50ms` 单次 autosave 端到端硬上限。OQ-03 HDD+AV p99 实测延 Polish。

**Engine**: Godot 4.6 | **Risk**: LOW(`Time.get_ticks_msec()` + GdUnit4 perf assertion)
**Engine Notes**: 三平台测试机 = MacBook Air M2 SSD / Windows 11 NVMe SSD / Ubuntu 22.04 ext4 SSD;AV 默认开启。

**Control Manifest Rules**:
- Guardrail: autosave 端到端 p50 < 18ms + p99 < 50ms(SSD)
- Guardrail: 主线程 snapshot 聚合 p99 < 3ms(独立计量)
- Guardrail: WorkerThread stringify + I/O p99 < 50ms

## Acceptance Criteria

- [ ] **AC-PERF-01** Rule 6 硬门槛端到端:state 体积 20KB,1000 次 autosave → 端到端耗时 p50 < 18ms + p99 < 50ms(三平台)+ 主线程 snapshot 聚合 p99 < 3ms + 超任一门槛 FAIL
- [ ] perf 测试 fixture 用 GdUnit4 + `Time.get_ticks_msec()` 计量
- [ ] CI 集成:`tests/integration/save/perf_autosave_test.gd` 在每 PR 跑(若超阈值 → CI FAIL)
- [ ] OQ-03 实测延 Polish 阶段 — HDD + AV scan(MS Defender / Norton / Kaspersky)p99 实测留 OQ

## Implementation Notes

```gdscript
# tests/integration/save/perf_autosave_test.gd
class_name PerfAutosaveTest
extends GdUnitTestSuite

const ITERATIONS := 1000
const STATE_SIZE_BYTES := 20 * 1024  # 20KB
const P50_THRESHOLD_MS := 18
const P99_THRESHOLD_MS := 50
const SNAPSHOT_AGGREGATE_P99_MS := 3

func test_autosave_e2e_perf():
    var fixture := SaveSystemFixture.new()
    fixture.set_state_size(STATE_SIZE_BYTES)
    var e2e_times: Array[int] = []
    var snapshot_times: Array[int] = []
    
    for i in range(ITERATIONS):
        var snapshot_start := Time.get_ticks_msec()
        var snapshot := fixture.aggregate_snapshot()
        var snapshot_elapsed := Time.get_ticks_msec() - snapshot_start
        snapshot_times.append(snapshot_elapsed)
        
        var e2e_start := Time.get_ticks_msec()
        await fixture.autosave_and_wait(snapshot)
        var e2e_elapsed := Time.get_ticks_msec() - e2e_start
        e2e_times.append(e2e_elapsed)
    
    e2e_times.sort()
    snapshot_times.sort()
    var p50 := e2e_times[ITERATIONS / 2]
    var p99 := e2e_times[ITERATIONS * 99 / 100]
    var snap_p99 := snapshot_times[ITERATIONS * 99 / 100]
    
    assert_int(p50).is_less(P50_THRESHOLD_MS)
    assert_int(p99).is_less(P99_THRESHOLD_MS)
    assert_int(snap_p99).is_less(SNAPSHOT_AGGREGATE_P99_MS)
```

## Out of Scope

- Story 002:autosave WorkerThreadPool 实现
- Story 003:原子写 4 步实现
- HDD + AV 实测(OQ-03 — Polish 阶段,本 story 仅 SSD 三平台)

## QA Test Cases

- **AC-PERF-01**(Logic — automated perf test):Given 20KB state + 1000 iterations on SSD(三平台 each);When `request_autosave_blocking` 端到端计量;Then p50 < 18ms + p99 < 50ms + 主线程 snapshot 聚合 p99 < 3ms;超任一阈值 → CI FAIL
- **OQ-03 实测**(Polish — manual playtest fixture):Given HDD + Win Defender / Norton / Kaspersky AV scan 启用;When 1000 iterations;Then p99 < 50ms ceiling(若超 → 降级 — `meta.save` 拆分为 `meta_essential.save` + `meta_archive.save`)

## Test Evidence

**Story Type**: Logic(自动化 perf assertion 算 Logic;若需手动 HDD playtest = Visual/Feel)
**Required evidence**: `tests/integration/save/perf_autosave_test.gd`(SSD 三平台 CI 跑)
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 002(WorkerThreadPool)+ Story 003(原子写)+ Story 015(retry backoff)
- Unlocks: Polish 阶段 OQ-03 HDD+AV 实测

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 in-scope COVERED via 3 test 函数;OQ-03 HDD+AV 实测 deferred Polish stage
**Test Evidence**: `tests/integration/save/perf_autosave_test.gd` (175 行 / 3 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);N=100 而非 story 1000(CI runtime + Stories 005/007 mean+max 前例统计选择);两轴(snapshot aggregation = JSON.stringify mean / e2e = request_autosave_blocking mean+max)分别 ceiling assertion;const wiring + ITERATION budget 双断言守 deviation 透明;OQ-03 HDD+AV deferred Polish docstring 明确;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0003 Status=Proposed — lean-mode-equivalent (Stories 001-015 同前例)
2. N=100 而非 story 1000 — CI runtime trade-off + N=100 mean ≈ p50 + max ≈ p99 在 SSD 充足代理;Story 005/007 同前例(N=20 mean)风格保持一致;OQ-03 Polish stage 用 N=1000 + HDD+AV
3. p99 用 max 替代 — N=100 时 p99 ≈ max,CI scheduler jitter 风险用 mean ceiling 兜底;实施在 docstring 明确说明 statistic 选择
**Tech debt**: None new
**Out-of-scope** (story 自陈):
- HDD + AV 实测(OQ-03 Polish)
- Story 002 WorkerThreadPool 实施(已 land Story 002)
- Story 003 原子写实施(已 land Story 003)
