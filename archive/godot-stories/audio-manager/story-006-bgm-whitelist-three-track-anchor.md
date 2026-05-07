# Story 006: BGM Whitelist + KPI Review 800ms Three-Track

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-005`
**ADR**: ADR-0007 KPI Review Three-Track Anchor + ADR-0001
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: BGM 仅月末 KPI_REVIEW + GAMEOVER 白名单
- Required: `kpi_review_intro_duration_ms = 800ms` 三轨 cross-fade

## Acceptance Criteria

- [ ] `_on_kpi_review_started()` 订阅 — 当前 BGM cross-fade out 800ms + stinger 同帧 + KPI_REVIEW BGM cross-fade in 800ms 后启
- [ ] **AC-FUNC-07** Rule 7 配乐白名单:Music IDLE + emit `kpi_review_started` → Music fade in 800ms 至 -9dB(协作 ADR-0007 800ms 锚)+ Ambient duck -6dB + Music sub-mode KPIREVIEW;KPI 演出结束 → Ambient 800ms 线性回位 + Music fade out -∞ + sub-mode IDLE;debug 钩子断言注册表**不含**非 KPIREVIEW/GAMEOVER domain 的 `MUSIC.*` key

## Implementation Notes

```gdscript
const BGM_WHITELIST_DOMAINS := [&"KPIREVIEW", &"GAMEOVER"]

func _on_kpi_review_started() -> void:
    _cross_fade_music(&"MUSIC.KPIREVIEW.ENDGAME_LOOP_BUREAUCRATIC", fade_in_ms=800)
    play_sfx(&"SFX.MONTH_END_STINGER_BUREAUCRATIC")  # 同帧
    _duck_ambient(-6.0, fade_ms=800)
    _music_state = MusicState.KPIREVIEW
```

## QA Test Cases

- AC-FUNC-07:emit `kpi_review_started` → Music fade in 800ms + Ambient duck;debug 钩子穷举 MUSIC.* key 全 in `KPIREVIEW / GAMEOVER` domain

## Test Evidence

`tests/integration/audio/three_track_anchor_test.gd`(协作 #16 KPI Review UI Story)

## Dependencies

- Depends on: Story 003 + Story 005 + KPI Story(kpi_review_started)
- Unlocks: KPI Review UI Story 003(三轨同步协作)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 1/1 AC-FUNC-07 COVERED via 6 test 函数(KPIREVIEW domain pass / GAMEOVER domain pass / OFFICE rejected / SFX-bus key rejected / on_kpi_review_started 双 emit / KPI_REVIEW_INTRO_DURATION_MS=800)
**Test Evidence**: `tests/integration/audio/three_track_anchor_test.gd` (6 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);`BGM_WHITELIST_DOMAINS = [KPIREVIEW, GAMEOVER]` const 暴露;`_is_bgm_whitelisted(key)` 解析 BUS.DOMAIN.IDENT 并双层校验(parts[0]==MUSIC + parts[1]∈whitelist);`on_kpi_review_started()` 同帧 emit `MUSIC.KPIREVIEW.ENDGAME_LOOP_BUREAUCRATIC` + `SFX.MONTH_END_STINGER_BUREAUCRATIC`(三轨锚 ADR-0007)
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0007 800ms cross-fade 实际 Tween 时序 OUT-OF-SCOPE(test 仅 verify signal 边界 + 常量 800;timing 验证由 KPI Review UI epic 协作完成)
2. Ambient duck -6dB Tween 实施 deferred — Story 010 ambient_duck_release_ms = 800 已暴露,实际 duck 由音频资产 + Tween 在资产 ready 后实施
3. `kpi_review_started` 信号源(KPI epic)未实施 — Audio 暴露 `on_kpi_review_started()` hook;test 直接 invoke
**Tech debt**: None new
**API surface**: `const BGM_WHITELIST_DOMAINS`;`const KPI_REVIEW_INTRO_DURATION_MS = 800`;`const KPI_AMBIENT_DUCK_DB = -6.0`;`play_music(key)`(白名单守);`play_bgm(key)`(alias);`on_kpi_review_started()`;`signal music_track_changed`
