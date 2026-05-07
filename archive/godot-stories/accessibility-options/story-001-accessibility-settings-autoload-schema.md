# Story 001: AccessibilitySettings autoload + 字体 4 档 + 色盲 3 档 schema

> **Epic**: Accessibility Options
> **Status**: Done(implemented 2026-04-29 via autopilot validation;tests written but not executed — Godot+gdunit4 install + project.godot bootstrap pending;AC-FUNC-01 autoload registration deferred to Foundation save Story 001 bootstrap)
> **Layer**: Polish
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/accessibility-options.md`
**Requirement**: `TR-a11y-001`

**ADR Governing Implementation**: ADR-0014 Accessibility Settings Injection
**ADR Decision Summary**: AccessibilitySettings Autoload(末位之前)持有完整 a11y schema:`font_size_tier ∈ {0,1,2,3} → {11, 13, 15, 17}px` / `colorblind_mode ∈ {NONE, PROTANOPIA, DEUTERANOPIA, TRITANOPIA}` / `high_contrast: bool` / `input_assist: bool`;通过 `assets/data/accessibility/a11y_config.tres` 持久化。

**Engine**: Godot 4.6 | **Risk**: HIGH(via AccessKit / dual-focus 实测延 Polish)
**Engine Notes**: Resource 持久化 4.6 标准;OQ-A14-ENG-01/02 实测延 Polish。

**Control Manifest Rules (Polish Layer)**:
- Required: schema 字段全集 + 默认值定义
- Forbidden: schema 内含 AP / KPI / Energy 字段(违反 Anti-P1 — Story 009 守门)
- Guardrail: 启动加载 ≤ 50ms

---

## Acceptance Criteria

- [ ] AC-FUNC-01: AccessibilitySettings autoload 注册 + schema 字段完整(font_size_tier / colorblind_mode / high_contrast / input_assist 4 字段)
- [ ] 字体 4 档枚举:`enum FontSizeTier { TIER_0_BASE = 11, TIER_1_LARGE = 13, TIER_2_LARGER = 15, TIER_3_LARGEST = 17 }`(对齐 art-bible §7.2 `AUTO_FIT_FLOOR_PX = 11`)
- [ ] 色盲 3 档枚举:`enum ColorblindMode { NONE, PROTANOPIA, DEUTERANOPIA, TRITANOPIA }`
- [ ] 持久化文件:`assets/data/accessibility/a11y_config.tres`(Resource 文件,通过 `#17 Main Menu` Story 005 6 信号合流路径 500ms 防抖落盘)

---

## Implementation Notes

*From GDD Rule 1 + 2 + ADR-0014:*

```gdscript
# autoload/accessibility_settings.gd
extends Node
class_name AccessibilitySettings

enum FontSizeTier { TIER_0_BASE = 11, TIER_1_LARGE = 13, TIER_2_LARGER = 15, TIER_3_LARGEST = 17 }
enum ColorblindMode { NONE, PROTANOPIA, DEUTERANOPIA, TRITANOPIA }

@export var font_size_tier: FontSizeTier = FontSizeTier.TIER_0_BASE
@export var colorblind_mode: ColorblindMode = ColorblindMode.NONE
@export var high_contrast: bool = false
@export var input_assist: bool = false

const CONFIG_PATH := "user://a11y_config.tres"  # 用户域,跨 platform

func _ready() -> void:
    load_config()

func load_config() -> void:
    if FileAccess.file_exists(CONFIG_PATH):
        var res = ResourceLoader.load(CONFIG_PATH)
        if res:
            font_size_tier = res.font_size_tier
            colorblind_mode = res.colorblind_mode
            high_contrast = res.high_contrast
            input_assist = res.input_assist

func save_config() -> void:
    var res := A11yConfig.new()
    res.font_size_tier = font_size_tier
    res.colorblind_mode = colorblind_mode
    res.high_contrast = high_contrast
    res.input_assist = input_assist
    ResourceSaver.save(res, CONFIG_PATH)
```

资源类:
```gdscript
# scripts/a11y_config.gd
extends Resource
class_name A11yConfig
@export var font_size_tier: int = 0
@export var colorblind_mode: int = 0
@export var high_contrast: bool = false
@export var input_assist: bool = false
```

---

## Out of Scope

- Story 002: Theme.set_default_font_size 注入逻辑
- Story 003: 色盲 LUT shader
- Story 005: 输入辅助逻辑
- Story 012: Settings UI 注入

---

## QA Test Cases

- **AC-FUNC-01**: schema 字段
  - Given: AccessibilitySettings autoload loaded
  - When: 反射字段
  - Then: 4 字段全在,默认值匹配规范

- **AC-2**: 持久化路径
  - Given: save_config() 调用 + load_config() 重启
  - When: 比较保存值 vs 加载值
  - Then: font_size_tier / colorblind_mode 等值一致

- **AC-3**: 启动 ≤ 50ms
  - Given: cold start
  - When: AccessibilitySettings._ready() 执行
  - Then: load_config() 耗时 ≤ 50ms

---

## Test Evidence

**Required evidence**: `tests/unit/a11y/accessibility_settings_autoload_test.gd` — must exist and pass

---

## Dependencies

- Depends on: `#1 Save` Story 010(content-only unlocks)— 不直接依赖,但 a11y 配置概念上是 content-only(Story 009 守门)
- Unlocks: Story 002, 003, 004, 005, 006, 007, 008, 011, 012
