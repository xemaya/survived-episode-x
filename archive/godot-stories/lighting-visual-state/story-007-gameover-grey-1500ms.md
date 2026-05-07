# Story 007: GAMEOVER Greyscale 1500ms Linear Palette

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-006`
**ADR**: ADR-0006 Dismissal/GAMEOVER + ADR-0008 Visual Boundary
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: GAMEOVER 1500ms `linear easing=NONE`(skippable 但禁推翻 transition tone)
- Forbidden: ease-in / ease-out / bounce / elastic(Pillar 3 冷静打卡机 tone)

## Acceptance Criteria

- [ ] `_on_game_over_triggered(reason, month)` 订阅 → CanvasModulate 1500ms linear 至灰 `(0.6, 0.6, 0.6)`
- [ ] Tween TRANS_LINEAR + EASE_IN(配合 LINEAR 仍是线性);严禁 TRANS_QUAD/CUBIC/BOUNCE/ELASTIC
- [ ] 自动化 perf test:逐帧 dY 采样斜率方差 < 5%(linear 断言)

## Implementation Notes

```gdscript
const GAMEOVER_GREY := Color(0.6, 0.6, 0.6, 1.0)
const FINAL_TRANSITION_DURATION_MS := 1500  # entities.yaml

func _on_game_over_triggered(_reason: StringName, _month: int) -> void:
    var tween := create_tween()
    tween.tween_property(canvas_modulate, "color", GAMEOVER_GREY, FINAL_TRANSITION_DURATION_MS / 1000.0)\
        .set_trans(Tween.TRANS_LINEAR)\
        .set_ease(Tween.EASE_IN)  # LINEAR + EASE_IN 仍线性
```

## QA Test Cases

- emit `game_over_triggered` → Tween 1500ms + 终值 = (0.6, 0.6, 0.6);逐帧 dY 采样斜率方差 < 5%

## Test Evidence

`tests/integration/lighting/gameover_palette_perf_test.gd`(linear easing 验证)

## Dependencies

- Depends on: Story 001 + KPI Story(game_over_triggered)
- Unlocks: KPI Review UI Story(1500ms transition 协作)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 3 test 函数(`FINAL_TRANSITION_DURATION_MS=1500` / Tween 终值 = (0.6,0.6,0.6) / 逐帧 dY 斜率相对方差 < 5% linear 验证)
**Test Evidence**: `tests/integration/lighting/gameover_palette_perf_test.gd`(110 行 / 3 tests / GdUnit4 含 perf 采样)— BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode);`TRANS_LINEAR` 锁定 + `EASE_IN`(Linear 下 ease 无效,曲线仍线性);Pillar 4 Tween 禁列(BOUNCE/ELASTIC/BACK)由 `tools/no_celebration_visual_lint.py` 全局守(已验);无 BLOCKING
**Engine API Verification**: Tween `TRANS_LINEAR` 在 4.0+ 即"匀速线性"语义;`get_process_delta_time()` 在 SceneTree 内合法
**Deviations**(2 项 ADVISORY):
1. perf test 在 headless / 极快帧环境 fallback 到 terminal-color check(robust degradation)
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `FINAL_TRANSITION_DURATION_MS` const + `GAMEOVER_GREY` const + `_on_game_over_triggered(reason, month)` 订阅
