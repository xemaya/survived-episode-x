# Story 009: Hero Card Brightness Lift + Mute Visual Parity

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-008`
**ADR**: ADR-0008 Visual Boundary Pillar 4 vs Mute Parity
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: brightness lift +0.05 0.5s(EASE_OUT 0.25s + EASE_IN 0.25s)
- Guardrail: brightness lift ≤ 0.07(visual lint)

## Acceptance Criteria

- [ ] `_on_hero_card_played(card_id)` 订阅 → CanvasModulate +0.05 brightness 0.25s EASE_OUT + return 0.25s EASE_IN
- [ ] mute_visual_parity:全 mute(三 Bus -60dB)时 brightness lift 仍触发
- [ ] M3+ 月份递减:hero_card_brightness_lift = 0.05 → 0.03(防麻木);registry tuning 单点

## Implementation Notes

```gdscript
const HERO_CARD_BRIGHTNESS_LIFT_MVP := 0.05
const HERO_CARD_BRIGHTNESS_LIFT_MAX := 0.07  # ceiling
const HERO_CARD_LIFT_DURATION := 0.25  # 0.25 + 0.25 = 0.5s

func _on_hero_card_played(_card_id: StringName) -> void:
    var current := canvas_modulate.color
    var lift := HERO_CARD_BRIGHTNESS_LIFT_MVP
    if SceneDayFlowController.month_index >= 3:
        lift = 0.03  # 月底接近 cap 时递减
    var lifted := current + Color(lift, lift, lift, 0.0)
    var tween := create_tween()
    tween.tween_property(canvas_modulate, "color", lifted, HERO_CARD_LIFT_DURATION)\
        .set_ease(Tween.EASE_OUT)
    tween.tween_property(canvas_modulate, "color", current, HERO_CARD_LIFT_DURATION)\
        .set_ease(Tween.EASE_IN)
```

## QA Test Cases

- emit `hero_card_played` → Tween +0.05 0.5s + return
- 全 mute 模式仍触发 brightness lift(信号物理音频解耦)
- M3+ 月份 → lift = 0.03(月底递减)

## Test Evidence

`tests/integration/lighting/hero_card_brightness_test.gd` + `tests/evidence/hero-card-mute-parity-2026-XX.png`

## Dependencies

- Depends on: Story 008(visual lint 守 ≤ 0.07)+ Action Card Story(hero_card_played)
- Unlocks: HUD Story 三 element 反馈协作

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 4 test 函数(MVP/M3+/ceiling/half_seconds 4 const / hero card lift 峰值 + return / mute parity 无 AudioManager 仍触发 / M3+ 0.03 const)
**Test Evidence**: `tests/integration/lighting/hero_card_brightness_test.gd`(105 行 / 4 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode);Tween 双段(EASE_OUT 0.25s + EASE_IN 0.25s)= 0.5s envelope;`_resolve_hero_card_lift` 用 `Object.get()` 安全读 SceneDayFlow.month_index — 跨 epic schema drift 不会 crash(initial 写法 `"month_index" in sdf` 修正为 `Object.get` + `typeof TYPE_INT` guard,inline fix);ceiling 0.07 由 Story 008 lint 守;无 BLOCKING
**Engine API Verification**: Tween 链式 chain `tween_property` 顺序 4.0+ 稳定;`Object.get(property_name)` 返回 null 当属性不存在(per Godot ClassDB Object)— defensive cross-epic guard
**Deviations**(2 项 ADVISORY,1 inline fix):
1. **inline fix**: `_resolve_hero_card_lift` 修正 `"x" in sdf` 错误语法 → `sdf.get("month_index")` + typeof guard
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `HERO_CARD_BRIGHTNESS_LIFT_MVP` / `_M3PLUS` / `_CEILING` / `_LIFT_HALF_SECONDS` 4 const + `_on_hero_card_played(card_id)` 订阅
