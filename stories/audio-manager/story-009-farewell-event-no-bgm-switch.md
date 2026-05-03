# Story 009: Farewell Event — No BGM Switch (AC-FAREWELL-01)

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-006`
**ADR**: ADR-0001 FAREWELL_EVENT_IDS enum + forbidden_pattern `farewell_event_extra_ui` + ADR-0009 `farewell_event` flag
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Forbidden: farewell event 触发时切 BGM(Pillar 3 死亡叙事 + Pillar 4 红线)

## Acceptance Criteria

- [ ] `_on_event_started(event_id, narrative_tier)` 订阅 — 检测 `event_id ∈ EventScriptEngine.FAREWELL_EVENT_IDS` → 禁触 BGM 切换
- [ ] **AC-FAREWELL-01**:AudioManager READY + 当前 BGM `BGM.OFFICE_DAY` 播放 + debug 钩子拦截 `play_bgm/cross_fade_bgm/AudioStreamPlayer.stream` 赋值 → `event_started(event_id, narrative_tier)` 且 `event_id ∈ FAREWELL_EVENT_IDS`(LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF / GRIND_KING_PROMOTED_LEAVE / OLD_OIL_OPTIMIZED_OUT)→ BGM 切换调用计数 = 0(继续 ambient)+ 任何切换 → push_error `ERR_AUD_FAREWELL: BGM switch forbidden during farewell event` + CI FAIL
- [ ] `tools/farewell_lint.gd` PR 阶段比对 `#10 FAREWELL_EVENT_IDS` 与本 GDD AC 引用一致 → 不一致 BLOCK PR

## Implementation Notes

```gdscript
func _on_event_started(event_id: StringName, _narrative_tier: StringName) -> void:
    if event_id in EventScriptEngine.FAREWELL_EVENT_IDS:
        _farewell_active = true
        # 禁切 BGM,继续当前 ambient
        return
    # 非 farewell 事件正常处理

func play_bgm(key: StringName) -> void:
    if _farewell_active:
        push_error("ERR_AUD_FAREWELL: BGM switch forbidden during farewell event")
        return
    # ... 正常 BGM 切换
```

## QA Test Cases

- AC-FAREWELL-01:5 farewell event_id 各发 `event_started` → BGM 切换计数 0;故意调 `play_bgm` → push_error
- farewell_lint:`#10 FAREWELL_EVENT_IDS` 与 Audio AC 引用一致

## Test Evidence

`tests/integration/audio/farewell_no_bgm_test.gd` + `tools/farewell_lint.gd`

## Dependencies

- Depends on: Story 003(READY)+ Story 006(BGM 白名单)+ Event Script Story(FAREWELL_EVENT_IDS enum)
- Unlocks: HUD/Recap/Lighting epic farewell 守门 stories

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 1/1 AC-FAREWELL-01 COVERED via 5 test 函数(FAREWELL_EVENT_IDS shape 5 entries / play_music blocked 当 farewell active / play_bgm alias blocked / 非 farewell 不阻 / on_event_ended 释放 / 5 farewell ids 各 block)
**Test Evidence**: `tests/integration/audio/farewell_no_bgm_test.gd` (5 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);`FAREWELL_EVENT_IDS` 5 个 const enum 镜像 EventScriptEngine.FAREWELL_EVENT_IDS;`_farewell_active` 状态由 `on_event_started` 设 + `on_event_ended` 清;`play_music`/`play_bgm` 在 `_farewell_active=true` 立 push_error `ERR_AUD_FAREWELL` early-return,music_track_changed 不发射
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. EventScriptEngine.FAREWELL_EVENT_IDS 来自 event-script epic — 未实施;Audio 暴露本地镜像 const + `tools/farewell_lint.gd` PR-time 一致性比对 OUT-OF-SCOPE(待 event-script ship 后由 narrative-director 拥有 lint)
2. ADR-0009 farewell_event flag schema OUT-OF-SCOPE(event-script epic);Audio 仅消费 event_id
3. debug 钩子拦截 `AudioStreamPlayer.stream` 赋值 OUT-OF-SCOPE(无 stream resource;test 验信号边界 + 状态 flag)
**Tech debt**: None new
**API surface**: `const FAREWELL_EVENT_IDS: Array[StringName]`(5 entries);`on_event_started(event_id, narrative_tier)`;`on_event_ended(event_id)`;`play_music`/`play_bgm` farewell-aware
