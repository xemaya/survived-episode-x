# Story 005: Palette Swap Shader + Dither Overlay Shader

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-011`
**ADR**: GDD Rule 4 shader 规约
**Engine**: Godot 4.6 | **Risk**: LOW(canvas_item shader_type 4.0+ 稳定)

**Control Manifest Rules**:
- Required: palette swap shader + dither overlay shader 用 canvas_item shader_type
- Required: ShaderMaterial uniform 即时切换(无重 compile)

## Acceptance Criteria

- [ ] `palette_swap.gdshader` — uniform `palette_index: int` 切换 8 sub-mode palette LUT
- [ ] `dither_overlay.gdshader` — uniform `dither_amount: float` 控制累积视觉颗粒度
- [ ] ShaderMaterial 池 reuse(无 runtime new)

## Implementation Notes

```glsl
// palette_swap.gdshader
shader_type canvas_item;
uniform sampler2D palette_lut: source_color;
uniform int palette_index = 0;

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    c.rgb = texture(palette_lut, vec2(c.r, float(palette_index) / 8.0)).rgb;
    COLOR = c;
}
```

```glsl
// dither_overlay.gdshader
shader_type canvas_item;
uniform float dither_amount: hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    float n = fract(sin(dot(UV * 800.0, vec2(12.9898, 78.233))) * 43758.5453);
    c.rgb = mix(c.rgb, c.rgb * (1.0 - dither_amount * 0.3) + n * dither_amount * 0.05, 1.0);
    COLOR = c;
}
```

## QA Test Cases

- palette_index 0..7 切换 → 颜色映射 LUT 正确
- dither_amount 0..1 → 颗粒度递增

## Test Evidence

`tests/unit/lighting/shader_validation_test.gd`(visual diff)

## Dependencies

- Depends on: Story 001(palette LUT atlas)
- Unlocks: Story 008(brightness lift)+ Story 011(色盲 shader)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 3 test 函数(palette_swap shader 文件 + uniform 验 / dither_overlay shader 文件 + uniform 验 / `palette_index` 切换 reuse 同 ShaderMaterial 无 recompile)
**Test Evidence**: `tests/unit/lighting/shader_validation_test.gd`(54 行 / 3 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode);两 .gdshader 文件 `shader_type canvas_item` 4.0+ 锁定;uniform 即时切换不 recompile (set_shader_parameter / get_shader_parameter pair 验证);LUT 8x256 atlas 与 Story 013 catalogue 同步;无 BLOCKING
**Engine API Verification**: `shader_type canvas_item` 自 Godot 4.0 稳定(per docs/engine-reference/godot/breaking-changes.md — 无 4.4/4.5/4.6 涉及 canvas_item shaders 的变更);`hint_range` 4.0+;`source_color` sampler hint 4.0+
**Deviations**(2 项 ADVISORY):
1. visual diff 实际 LUT atlas 由 Phase-4 art-director 注入 — 现 placeholder 静态测试覆盖结构 + uniform 行为
2. ADR Status=Proposed(GDD Rule 4 锁定)— lean-mode-equivalent
**Tech debt**: None new
**API surface**: `assets/shaders/lighting/palette_swap.gdshader`(uniform `palette_lut` / `palette_index`)+ `assets/shaders/lighting/dither_overlay.gdshader`(uniform `dither_amount`)
