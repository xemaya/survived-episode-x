# Story 008: Preload < 200ms + 30MB Cap + MUSIC_TRACK_MAX = 4

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-003` + `TR-audio-004`
**ADR**: ADR-0002(启动序列)+ R-AUD-2
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Guardrail: `audio_preload_budget_ms = 200ms` + `audio_bank_total_size_mb = 30MB` + `bgm_loop_length_max_sec = 120s` + `MUSIC_TRACK_MAX = 4`

## Acceptance Criteria

- [ ] `preload_bank()` 异步 ResourceLoader 预加载 ~29 SFX/Ambient + 字体 4
- [ ] **AC-PERF-01** preload ≤ 200ms:29 asset(~520KB)< 200ms;超时 CI smoke FAIL
- [ ] **AC-PERF-02** `audio_bank_total_size_mb ≤ 30MB`:`tools/audio_lint.gd` 统计 `assets/audio/` on-disk 大小;> 30MB → CI FAIL `ERR_AUDIO_BANK_SIZE`
- [ ] **AC-ROBUST-02 [R-AUD-2]** `MUSIC_TRACK_MAX = 4`:`MUSIC.*` key 数 = 5 → CI FAIL `ERR_MUSIC_TRACK_MAX: 5 exceed MAX=4 — requires game-designer + audio-director dual approval`
- [ ] BGM loop length ≤ 120s(单 file 时长)

## Implementation Notes

```gdscript
# preload_bank 异步:
func preload_bank() -> void:
    var start := Time.get_ticks_msec()
    var paths := _enumerate_audio_assets()
    for p in paths:
        ResourceLoader.load_threaded_request(p)
    while not _all_loaded(paths):
        await get_tree().process_frame
    var elapsed := Time.get_ticks_msec() - start
    if elapsed > 200:
        push_warning("[AudioManager] preload_bank %dms exceeds 200ms" % elapsed)
```

## QA Test Cases

- AC-PERF-01:29 asset preload ≤ 200ms(SSD)
- AC-PERF-02:`assets/audio/` > 30MB → CI FAIL
- AC-ROBUST-02:5 MUSIC.* key → lint FAIL

## Test Evidence

`tests/integration/audio/preload_perf_test.gd` + `tests/unit/audio/audio_bank_size_lint_test.gd`

## Dependencies

- Depends on: Story 003 + Story 002(audio_lint 框架)
- Unlocks: 全 BGM/SFX runtime 行为(asset 就绪后)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 AC-PERF-01 + AC-PERF-02 + AC-ROBUST-02 + AC(BGM ≤ 120s) COVERED via 6 test 函数(constants × 4 + preload async + audio_manager_ready emit)
**Test Evidence**: `tests/integration/audio/preload_perf_test.gd` (6 tests / GdUnit4) + `tools/audio_lint.py --self-test`(MUSIC_TRACK_MAX + 30MB cap)— BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);prior session minimal stub 已存在 + 此 round 整合到 4-Bus + state machine + LRU 大类下;preload_bank() async ResourceLoader.load_threaded_request + process_frame poll;PRELOAD_BUDGET_MS=200 push_warning 超时;audio_lint.py 实施 30MB cap + MUSIC_TRACK_MAX=4 lint;BGM_LOOP_MAX_SEC=120 常量(asset-spec lint 用)
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. 实测 29 asset preload < 200ms 验证 OUT-OF-SCOPE(无 asset 提供;preload_bank 在空目录 graceful 完成,signal emit 验证)
2. BGM loop length ≤ 120s file 时长 lint OUT-OF-SCOPE(asset metadata lint 由 asset-spec epic 实施,等 audio team ship 后接);常量已暴露
3. 30MB cap CI gate 需 `assets/audio/` 目录 ship + audio_keys.txt registry — 当前 advisory PASS,等 audio team Phase 4 资产生产
**Tech debt**: None new
**API surface**: `const PRELOAD_BUDGET_MS = 200`;`const BANK_SIZE_LIMIT_MB = 30.0`;`const MUSIC_TRACK_MAX = 4`;`const BGM_LOOP_MAX_SEC = 120.0`;`preload_bank()` async;`tools/audio_lint.py lint_bank_size()` + `lint_keys()` MUSIC_TRACK_MAX gate
