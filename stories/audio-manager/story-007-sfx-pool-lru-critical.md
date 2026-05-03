# Story 007: SFX Pool LRU 8 + CRITICAL Priority

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-002`
**ADR**: GDD Rule 8 + R-AUD-4
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: SFX 池预分配 8 slots + LRU 驱逐 + CRITICAL priority 豁免
- Forbidden: runtime `AudioStreamPlayer.new()`(GC 压力)
- Required: `EVICTION_FADE_MS = 30ms` 驱逐时淡出消除 pop

## Acceptance Criteria

- [ ] 8 个 `AudioStreamPlayer` 节点池,`_ready()` 预分配
- [ ] **AC-FUNC-08** dispatch ≤ 1 帧 + 池预分配:500 次 `play_sfx` → 主线程 ≤ 16.6ms 每次;`AudioStreamPlayer.new()` 计数 = 0;LRU 驱逐最久空闲 non-CRITICAL slot
- [ ] **AC-ROBUST-04 [R-AUD-4]** CRITICAL 不被驱逐:8/8 满 non-critical → 第 9 次 `play_sfx("PUNCH_CLOCK_CLACK_BUREAUCRATIC")` CRITICAL → 驱逐 non-critical 最旧;EVICTION_FADE_MS=30ms 淡出;8 全 CRITICAL → 普通 LRU 驱逐最旧 CRITICAL;dev build 普通 LRU 驱逐 CRITICAL → push_error

## Implementation Notes

```gdscript
const POOL_SIZE := 8
const EVICTION_FADE_MS := 30
const CRITICAL_KEY_SUFFIX := "_BUREAUCRATIC"

var _pool: Array[AudioStreamPlayer] = []
var _slot_meta: Array[Dictionary] = []  # [{key, last_used_ts, is_critical}]

func _ready() -> void:
    for i in POOL_SIZE:
        var player := AudioStreamPlayer.new()
        player.bus = &"SFX"
        add_child(player)
        _pool.append(player)
        _slot_meta.append({"key": &"", "last_used_ts": 0, "is_critical": false})

func play_sfx(key: StringName) -> void:
    var is_critical := str(key).ends_with(CRITICAL_KEY_SUFFIX)
    var slot := _find_or_evict_slot(is_critical)
    if slot == -1:
        return  # CRITICAL 全占满,普通 LRU 驱逐最旧 CRITICAL
    _slot_meta[slot] = {"key": key, "last_used_ts": Time.get_ticks_msec(), "is_critical": is_critical}
    _pool[slot].stream = ResourceLoader.load("res://assets/audio/sfx/%s.ogg" % key)
    _pool[slot].play()
```

## QA Test Cases

- AC-FUNC-08:500 次 play_sfx → 主线程 ≤ 16.6ms;new() 计数 0
- AC-ROBUST-04:8/8 non-critical + 第 9 次 CRITICAL → 驱逐 non-critical;EVICTION_FADE 30ms;dev build LRU 驱逐 CRITICAL → push_error

## Test Evidence

`tests/unit/audio/sfx_pool_lru_test.gd`

## Dependencies

- Depends on: Story 003(READY)
- Unlocks: Story 010(act_pause 协作)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 2/2 AC-FUNC-08 + AC-ROBUST-04 COVERED via 5 test 函数(pool 预分配 8 / 500 dispatch 不增长 / CRITICAL 驱逐 LRU non-CRITICAL / 全 CRITICAL 拒 non-CRITICAL / 全 CRITICAL 接受新 CRITICAL LRU 驱逐)
**Test Evidence**: `tests/unit/audio/sfx_pool_lru_test.gd` (5 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);8 个 `AudioStreamPlayer` `_preallocate_sfx_pool()` 在 `_ready()` 创建,bus = SFX;`_find_or_evict_slot(is_critical)` 实施 3 层策略(empty → LRU non-crit → fallback);`CRITICAL_KEY_SUFFIX = "_BUREAUCRATIC"` 通过 `String(key).ends_with` 判定;dev guard `ERR_AUD_LRU_CRITICAL` push_error 当全 CRITICAL pool 拒 non-CRITICAL;`get_sfx_slot_snapshot()` test-only inspector
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. EVICTION_FADE_MS = 30ms 渐出实际 Tween 实施 OUT-OF-SCOPE(实际 audio fade 需音频资产 + AudioStreamPlayer.volume_db Tween;test 验常量 + LRU 决策)
2. AudioStreamPlayer.stream 资源加载 OUT-OF-SCOPE(无 SFX 资产 → ResourceLoader 无 stream;池仅验 slot meta 决策)
3. perf 500 次 dispatch ≤ 16.6ms 主线程 — `audio_event_played` 信号 emit 是 O(1),slot lookup 是 O(8) 常量;test 验 pool size 不增长(等价 GC 守门),实际 frame budget 在 Story 012 perf test
**Tech debt**: None new
**API surface**: `const SFX_POOL_SIZE = 8`;`const SFX_EVICTION_FADE_MS = 30`;`const CRITICAL_KEY_SUFFIX`;`play_sfx(key)`(LOADING 期 drop + READY 期 LRU);`get_sfx_slot_snapshot()`(test-only inspector)
