# ADR-0014: Accessibility Settings Injection Architecture

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | UI / Accessibility / Core(Theme + Color shader + AccessKit 4.5) |
| **Knowledge Risk** | **HIGH**(AccessKit 4.5 引入 — 屏幕阅读器适配,LLM 截止 ~4.3 不知;dual-focus mode 4.6) |
| **References Consulted** | `docs/engine-reference/godot/breaking-changes.md` 4.4→4.5 + 4.5→4.6 |
| **Post-Cutoff APIs Used** | AccessKit `Window.use_accessibility = true`(4.5 引入,4.6 enhanced) / dual-focus(4.6) |
| **Verification Required** | OQ-A14-ENG-01 AccessKit 实测(屏幕阅读器适配)/ OQ-A14-ENG-02 dual-focus mode 4.6 实测 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(`font_size_changed` + `colorblind_mode_changed` ownership)+ ADR-0004(Settings reflow coalescing) |
| **Enables** | `#20 Accessibility` 实施 + `#3 Loc` 字体 fallback 链 + `#13 HUD` 色盲适配 |
| **Blocks** | `#20` Polish layer coding(注入策略未定) |
| **Ordering Note** | P2 优先级第四(末位 P2) |

## Context

### Problem Statement

`#20 Accessibility Options` Polish layer GDD 规定 4 字体大小档 + 3 色盲模式 + ARIA-like 标签 + reduce_motion(VS 起)。注入策略未在 ADR 锁定:

- 字体大小如何作用到全 UI?(Theme override / per-Label override / RichTextLabel font_sizes property?)
- 色盲模式如何注入?(Material override / Shader / Texture swap?)
- AccessKit(4.5+ 屏幕阅读器适配)如何与 Control 节点交互?
- `#13 HUD Diegetic` 也需色盲适配 — 但它是 Node2D 而非 Control,如何统一?

### Constraints

- `#20` Rule 1 字体 4 档 11/13/15/17px
- `#20` Rule 2 色盲 3 模式(Protanopia / Deuteranopia / Tritanopia)
- `#20` Rule 3 mute_visual_parity(ADR-0008 已守)
- AccessKit 4.5+ HIGH 知识风险(LLM 截止 ~4.3)
- Godot 4.6 dual-focus mode(键盘 + gamepad 同时)
- `#13 HUD Diegetic` 是 Node2D + Sprite2D,与 Control Theme 不同

### Requirements

- 字体大小注入全 Control(Theme override 或 per-instance)
- 色盲模式注入 Control + Node2D(统一策略)
- AccessKit 启用 + Control aria_role 注入
- dual-focus mode 4.6 启用(键盘 + gamepad)
- `#13 HUD` Node2D 色盲适配方案

## Decision

### 1. 字体大小注入 = ProjectSettings + Theme override

```gdscript
# `#20 AccessibilitySettings` Autoload (low-priority autoload)
extends Node

const FONT_SIZE_TIERS := {
    &"small": 11,
    &"medium": 13,  # default
    &"large": 15,
    &"extra_large": 17,
}

var current_font_size_key: StringName = &"medium"

func apply_font_size(tier: StringName) -> void:
    current_font_size_key = tier
    var size := FONT_SIZE_TIERS[tier]
    # 全局 Theme override
    var theme := load("res://themes/main_theme.tres") as Theme
    theme.set_default_font_size(size)
    # 通知所有 Control reload
    LocalizationHooks.broadcast_translation_changed_once()  # ADR-0004 reflow
    save_settings_via_debounced_timer()
```

**理由**:
- Theme `default_font_size` 是 Godot 4.0+ 单点 override,所有 Control 自动响应
- `#3 Loc` 字体 fallback 链(Step 0..3,见 ADR-0004 R-LVS-5)
- 持久化经 ADR-0004 防抖单 timer

### 2. 色盲模式注入 = CanvasLayer post-process Shader

```gdscript
# `#5 Lighting Controller` Rule 12 (色盲适配)
# CanvasLayer.material 设为 ColorBlindShaderMaterial,覆盖整个屏幕
@onready var canvas_layer: CanvasLayer = get_tree().root.get_node("World/CanvasLayer")

func apply_colorblind_mode(mode: StringName) -> void:
    var shader := preload("res://shaders/colorblind_post.gdshader")
    var mat := ShaderMaterial.new()
    mat.shader = shader
    match mode:
        &"none": canvas_layer.material = null  # 无 post-process
        &"protanopia": mat.set_shader_parameter("filter_type", 1); canvas_layer.material = mat
        &"deuteranopia": mat.set_shader_parameter("filter_type", 2); canvas_layer.material = mat
        &"tritanopia": mat.set_shader_parameter("filter_type", 3); canvas_layer.material = mat
```

**colorblind_post.gdshader**:
```glsl
shader_type canvas_item;

uniform int filter_type = 0;  // 0=none, 1=Protanopia, 2=Deuteranopia, 3=Tritanopia

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    if (filter_type == 1) {
        // Protanopia matrix
        c.rgb = vec3(
            0.567*c.r + 0.433*c.g + 0.0*c.b,
            0.558*c.r + 0.442*c.g + 0.0*c.b,
            0.0*c.r + 0.242*c.g + 0.758*c.b
        );
    } else if (filter_type == 2) {
        // Deuteranopia matrix
        ...
    } else if (filter_type == 3) {
        // Tritanopia matrix
        ...
    }
    COLOR = c;
}
```

**理由**:
- 单 CanvasLayer post-process Shader 覆盖整屏(Control + Node2D 同时适配)
- `#13 HUD` Node2D 色盲适配自动(无需各 Sprite2D 单独 material)
- 切换瞬时(Shader uniform 即时生效)

### 3. AccessKit 启用(4.5+ HIGH 风险)

```gdscript
# `#20 AccessibilitySettings` Autoload
func _ready() -> void:
    # 4.5+ AccessKit 屏幕阅读器适配
    if Engine.get_version_info().major >= 4 and Engine.get_version_info().minor >= 5:
        get_window().use_accessibility = true
        # OQ-A14-ENG-01: 实测 + 验证
```

各 Control 节点设置 ARIA role(在 .tscn 中配置):
```
Button.aria_label = "Play"
Label.aria_role = "heading"
ProgressBar.aria_label = "KPI 进度"
```

### 4. dual-focus mode(4.6)

```gdscript
# project.godot
input/dual_focus_mode = true  # 4.6 enabled
```

键盘 focus + gamepad focus 独立(玩家可同时用键鼠 + Switch Pro 控制器)。
**OQ-A14-ENG-02**:实测 4.6 dual-focus 行为。

### 5. `#13 HUD Diegetic` 色盲适配 = 同 CanvasLayer post-process

由于策略 #2 是 CanvasLayer 整屏 post-process,`#13` Node2D 自动适配。但 art 设计时建议:
- 关键信息不依赖单一颜色(如 KPI 进度条 — 用 fill % + 数字 + 色彩 三重 redundancy)
- 玩家测试色盲模式下识别度

### 6. reduce_motion(VS 起)

```gdscript
# VS 起,MVP 不实施:
# - 禁 Tween 长 duration(限 0.2s 上限)
# - 禁 particle 大量发射
# - 禁 camera shake
```

### Architecture Diagram

```
┌──────────────────────────────────┐
│  #17 Settings UI                  │
│  ├ font_size_changed signal       │
│  └ colorblind_mode_changed signal │
└──────────┬────────────────────────┘
           │
           ▼ ADR-0004 防抖合流
┌──────────────────────────────────┐
│  #20 AccessibilitySettings        │
│  (Autoload)                       │
│  ├ apply_font_size() → Theme      │
│  └ apply_colorblind_mode() → Shader│
└──────────┬────────────────────────┘
           │
     ┌─────┼─────┐
     ▼     ▼     ▼
   Theme  CanvasLayer  AccessKit
   (Control  Shader     (Window
    全适配)  (整屏post   accessibility)
            -process)
```

## Alternatives Considered

### Alternative 1: 字体 per-Label override(每 Label 各自设 font_size)

- **Pros**: 精细化每 Label
- **Cons**: 200+ Label 散落各 scene,维护困难
- **Rejection**: Theme override 单点

### Alternative 2: 色盲 per-Sprite2D Material override

- **Pros**: 各元素自治
- **Cons**: `#13 HUD` 8 元素 + 200+ Texture 工作量爆炸
- **Rejection**: CanvasLayer post-process 单点

### Alternative 3: Texture swap(不同色盲模式不同 texture set)

- **Pros**: 美术控制
- **Cons**: 内存 ×4 + 资源管理复杂
- **Rejection**: 性能 / 资源问题

### Alternative 4: 不启用 AccessKit(MVP scope cut)

- **Pros**: 简化
- **Cons**: a11y P1 守门失;失去屏幕阅读器适配
- **Rejection**: a11y 不可妥协

## Consequences

### Positive

- 字体 / 色盲注入策略各自单点(Theme + Shader)
- `#13 HUD Diegetic` 色盲自动适配(无单独工作)
- AccessKit 4.5+ 启用(屏幕阅读器适配)
- dual-focus mode 4.6 启用(键鼠 + gamepad 同时)
- ADR-0004 防抖合流集成

### Negative

- AccessKit 4.5+ HIGH 知识风险(LLM 截止 ~4.3)— 实测必需
- CanvasLayer post-process Shader 增 ~µs 级渲染开销(可忽略)
- reduce_motion VS 起 — MVP 玩家若有需求需等版本
  - Mitigation: VS scope 已规划

### Risks

- **R-A14-1**: AccessKit 4.5 实测不符文档(屏幕阅读器无响应)
  - **Mitigation**: OQ-A14-ENG-01 实测;若 fail,fallback Tab navigation + 字体大小 17px(无 ARIA 但视觉可读)
- **R-A14-2**: dual-focus mode 4.6 实测 race(键盘 focus + gamepad focus 冲突)
  - **Mitigation**: OQ-A14-ENG-02 实测;若 race,fallback 单 focus(玩家选择键盘 OR gamepad)
- **R-A14-3**: 色盲 Shader 在低端 GPU 性能问题
  - **Mitigation**: 实测 OQ-A14-PERF-01;如超,fallback 帧采样

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#20 Accessibility` Rule 1 | 字体 4 档 11/13/15/17px | Theme `default_font_size` |
| `#20 Rule 2` | 色盲 3 模式 | CanvasLayer post-process Shader |
| `#20 Rule 3` | mute_visual_parity | ADR-0008 已守 |
| `#20 R-A11Y-2` | 二次 reflow fallback | ADR-0004 reflow + 字体 fallback 链 |
| `#3 Loc Rule 9` | 字体 fallback 链 | Step 0..3 |
| `#13 HUD Diegetic` | 色盲适配 | CanvasLayer post-process 整屏 |
| Godot 4.5 AccessKit | 屏幕阅读器适配 | `Window.use_accessibility = true` |
| Godot 4.6 dual-focus | 键鼠 + gamepad 同时 | `input/dual_focus_mode = true` |

## Performance Implications

- **CPU**: Theme reload < 50ms / Shader uniform set < µs / AccessKit overhead 微
- **Memory**: 1 Shader + 1 ShaderMaterial < 1KB
- **Load Time**: 启动期 + 50ms(AccessKit init)
- **Network**: N/A

## Migration Plan

无现有代码:
1. `#20 AccessibilitySettings` Autoload 实施(低优先级,在 SceneDayFlow 后)
2. `res://themes/main_theme.tres` 创建(default_font_size override 路径)
3. `res://shaders/colorblind_post.gdshader` 创建 + ColorBlindShaderMaterial
4. `project.godot` `input/dual_focus_mode = true` 配置
5. AccessKit 启用 + 主要 Control aria_role 标注
6. 实测 OQ-A14-ENG-01 + OQ-A14-ENG-02 + OQ-A14-PERF-01
7. CI 集成 a11y lint(无 ARIA Control 警告)

## Validation Criteria

- 字体 4 档切换 → 全 Control 字体即时变化(集成测试)
- 色盲 3 模式切换 → CanvasLayer Shader 切换(visual diff 测试)
- AccessKit 启用 → 屏幕阅读器(NVDA / VoiceOver)读出 ARIA label(无障碍测试)
- dual-focus → 键盘 + gamepad 同时 focus 独立(集成测试)
- mute_visual_parity 守(ADR-0008 集成 — Hero card 三视觉 element 反馈)

## Related Decisions

- ADR-0001 Signal Ownership Matrix(font_size + colorblind 信号)
- ADR-0004 Settings Reflow Coalescing(防抖合流 + reflow 链)
- ADR-0008 Visual Boundary Pillar 4(mute_visual_parity 集成)
- `#20 Accessibility Options` GDD
- `#3 Loc Rule 9` 字体 fallback 链
- `#13 HUD Diegetic` 色盲适配
- Godot 4.5 AccessKit / 4.6 dual-focus mode
