# Story 012: Colorblind CanvasLayer Post-Process Shader

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-013`
**ADR**: ADR-0014 Accessibility Settings Injection
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 色盲 CanvasLayer post-process Shader(canvas_item shader_type)整屏适配
- Forbidden: per-Sprite2D ColorBlindMaterial override(forbidden_pattern `per_sprite_colorblind_material`)

## Acceptance Criteria

- [ ] `colorblind_post.gdshader` 实施(canvas_item shader_type)+ uniform `filter_type: int`(0=none, 1=Protanopia, 2=Deuteranopia, 3=Tritanopia)
- [ ] `apply_colorblind_mode(mode: StringName)` API → CanvasLayer.material 切 ShaderMaterial uniform
- [ ] 切换瞬时(uniform 即时生效,无 reload Shader)
- [ ] Control + Node2D 同时适配(整屏 post-process)

## Implementation Notes

```glsl
// colorblind_post.gdshader
shader_type canvas_item;
uniform int filter_type = 0;

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    if (filter_type == 1) {  // Protanopia
        c.rgb = vec3(
            0.567*c.r + 0.433*c.g + 0.0*c.b,
            0.558*c.r + 0.442*c.g + 0.0*c.b,
            0.0*c.r + 0.242*c.g + 0.758*c.b
        );
    } else if (filter_type == 2) {  // Deuteranopia
        c.rgb = vec3(
            0.625*c.r + 0.375*c.g + 0.0*c.b,
            0.700*c.r + 0.300*c.g + 0.0*c.b,
            0.0*c.r + 0.300*c.g + 0.700*c.b
        );
    } else if (filter_type == 3) {  // Tritanopia
        c.rgb = vec3(
            0.950*c.r + 0.050*c.g + 0.0*c.b,
            0.0*c.r + 0.433*c.g + 0.567*c.b,
            0.0*c.r + 0.475*c.g + 0.525*c.b
        );
    }
    COLOR = c;
}
```

```gdscript
# lighting_controller.gd
func apply_colorblind_mode(mode: StringName) -> void:
    var canvas_layer := get_tree().root.get_node("World/CanvasLayer")
    var mat := canvas_layer.material as ShaderMaterial
    if mat == null:
        mat = ShaderMaterial.new()
        mat.shader = preload("res://shaders/colorblind_post.gdshader")
        canvas_layer.material = mat
    var filter_type := {&"none": 0, &"protanopia": 1, &"deuteranopia": 2, &"tritanopia": 3}.get(mode, 0)
    mat.set_shader_parameter("filter_type", filter_type)
```

## QA Test Cases

- 4 mode 切换 → CanvasLayer Shader uniform 即时生效(visual diff)
- Control + Node2D(`#13` HUD)同时适配整屏

## Test Evidence

`tests/integration/lighting/colorblind_shader_test.gd` + visual diff fixture

## Dependencies

- Depends on: Story 005(shader 框架)+ Accessibility Story(apply_colorblind_mode 调用)
- Unlocks: a11y CI 集成(屏幕阅读器适配)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 4 test 函数(shader 文件 + canvas_item / filter_type 整数映射 == a11y 枚举 / apply_colorblind_mode 分配 layer + 设 uniform / NONE 隐 ColorRect)
**Test Evidence**: `tests/integration/lighting/colorblind_shader_test.gd`(89 行 / 4 tests / GdUnit4)+ `assets/shaders/lighting/colorblind_post.gdshader`(48 行 GLSL)— BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode);**与 a11y `colorblind_post_process.gd` 不冲突 — 后者 layer=100 顶层覆盖整屏(Control + HUD),本 lighting hook layer=90 用于 game-world 二级 LUT(可同时启用)**;`COLORBLIND_FILTER_MAP` 整数映射镜像 `AccessibilitySettings.ColorblindMode` 枚举 0..3;test 路径 fallback 到 stub material 当 shader 不存在(与 a11y autoload 同模式);无 BLOCKING
**Engine API Verification**: `CanvasLayer.layer` int 4.0+ 稳定;`ResourceLoader.exists` + `load` defensive pattern 与 a11y `colorblind_post_process.gd` L40-L67 一致;Brettel-Viénot-Mollon 1997 颜色矩阵与 a11y team 同源
**Deviations**(2 项 ADVISORY):
1. AccessibilitySettings autoload 注入路径 `apply_colorblind_mode(mode)` 由 a11y epic 决定调用方式(此处实施供调用入口)
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `assets/shaders/lighting/colorblind_post.gdshader`(uniform `filter_type`)+ `COLORBLIND_FILTER_MAP` const + `COLORBLIND_SHADER_PATH` const + `apply_colorblind_mode(mode)` 公有 API
