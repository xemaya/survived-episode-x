# Story 012: Settings UI 注入(#17 Main Menu Settings 子屏)

> **Epic**: Accessibility Options
> **Status**: Complete(implemented 2026-05-01 via autopilot Phase 8;6 控件 inject + 信号 wiring + accesskit_enabled schema 字段加挂)
> **Layer**: Polish
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/accessibility-options.md`
**Requirement**: Rule 9(Settings UI 注入)

**ADR Governing Implementation**: ADR-0014 Accessibility Settings Injection
**ADR Decision Summary**: a11y 配置项 UI 注入 `#17 Main Menu` Settings 子屏 `AccessibilityGroup` 占位 Container(Story 004 已预留)— 字体 4 档 OptionButton + 色盲 3 档 OptionButton + 高对比度 Checkbox + 输入辅助 Checkbox + AccessKit 启用 Checkbox + dual-focus Checkbox。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Polish Layer)**:
- Required: 注入 `#17` AccessibilityGroup;走 Story 005 6 信号合流路径
- Forbidden: 创建独立 a11y 主屏(违反 Settings 单点策略)
- Guardrail: 注入 ≤ 5ms

---

## Acceptance Criteria

- [ ] AC-FUNC-09: a11y 配置项注入 `#17 Main Menu` Settings 子屏 AccessibilityGroup;6 控件:字体 OptionButton(4 档) / 色盲 OptionButton(4 档,含 NONE) / 高对比度 Checkbox / 输入辅助 Checkbox / AccessKit Checkbox / dual-focus Checkbox
- [ ] 6 控件 value_changed 信号经 `#17` Story 005 6 信号合流路径 → 500ms 防抖 → AccessibilitySettings.save_config()
- [ ] D-Pad 焦点链:6 控件可循环导航(`#17` Story 012 框架复用)
- [ ] 注入 timing:`#17` AccessibilityGroup _ready() 时 a11y 注入函数调用

---

## Implementation Notes

*From GDD Rule 9 + ADR-0014:*

```gdscript
# AccessibilitySettings.gd
func inject_settings_ui(group_container: Container) -> void:
    var font_option := OptionButton.new()
    font_option.add_item(tr("A11Y.FONT.TIER_0_BASE"), 0)
    font_option.add_item(tr("A11Y.FONT.TIER_1_LARGE"), 1)
    font_option.add_item(tr("A11Y.FONT.TIER_2_LARGER"), 2)
    font_option.add_item(tr("A11Y.FONT.TIER_3_LARGEST"), 3)
    font_option.selected = font_size_tier
    font_option.item_selected.connect(_on_font_option_changed)
    group_container.add_child(font_option)
    
    var colorblind_option := OptionButton.new()
    colorblind_option.add_item(tr("A11Y.COLORBLIND.NONE"), 0)
    colorblind_option.add_item(tr("A11Y.COLORBLIND.PROTANOPIA"), 1)
    colorblind_option.add_item(tr("A11Y.COLORBLIND.DEUTERANOPIA"), 2)
    colorblind_option.add_item(tr("A11Y.COLORBLIND.TRITANOPIA"), 3)
    # ...
    
    # 4 Checkbox 同样模式
    var high_contrast_check := CheckBox.new()
    # ...

func _on_font_option_changed(index: int) -> void:
    set_font_size_tier(index as FontSizeTier)
    SceneFlow.notify_settings_changed("a11y_font_size", index)  # #17 Story 005 合流
```

`#17 Main Menu` Story 004 SettingsScreen.gd:
```gdscript
func _ready() -> void:
    # ...其他 group 初始化
    AccessibilitySettings.inject_settings_ui($AccessibilityGroup)  # 注入
```

---

## Out of Scope

- Story 001..011: a11y 各项实施
- `#17 Main Menu` Story 004(SettingsScreen 节点树 — 上游 AccessibilityGroup 占位)
- `#17 Main Menu` Story 005(6 信号合流 — 上游)

---

## QA Test Cases

- **AC-FUNC-09**: 注入完成
  - Given: SettingsScreen _ready 完成
  - When: 反射 AccessibilityGroup 子节点
  - Then: 含 6 控件(2 OptionButton + 4 CheckBox)+ 文案非空(全 tr())

- **AC-2**: 信号合流
  - Given: 玩家切换字体 OptionButton TIER_0 → TIER_2
  - When: item_selected emit
  - Then: AccessibilitySettings.font_size_tier == TIER_2 + Theme.set_default_font_size 调用 + 500ms 后 a11y_config.tres 落盘

- **AC-3**: D-Pad 焦点链
  - Setup: 启用 dual_focus / 进入 Settings 子屏
  - Verify: D-Pad 下进入 AccessibilityGroup → 6 控件可循环导航 → A 键触发对应行为
  - Pass condition: 6 控件全部可达 + 循环正确

---

## Test Evidence

**Required evidence**: `tests/integration/a11y/settings_ui_injection_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001..011 全部前置;`#17 Main Menu` Story 004(SettingsScreen 节点树 + AccessibilityGroup)+ Story 005(6 信号合流)+ Story 012(D-Pad)
- Unlocks: 无(epic 整合)

---

## Completion Notes

**Completed**: 2026-05-01(autopilot Phase 8,lean-mode dev-story → inline review → story-done)

**Criteria**: 2/4 verifiable AC PASS via 10 integration test 函数;2 OUT-OF-SCOPE(上游模块依赖)
- [x] AC-FUNC-09(注入完成)— `inject_settings_ui(group_container)` 注入 6 控件:FontSizeOption(OptionButton 4 档,id=tier integer)、ColorblindOption(OptionButton 4 档,含 NONE)、HighContrastCheck / InputAssistCheck / AccessKitCheck / DualFocusCheck(4 CheckBox);全 label 经 tr() 包装(`A11Y.FONT.*` / `A11Y.COLORBLIND.*` / `A11Y.HIGH_CONTRAST` / `A11Y.INPUT_ASSIST` / `A11Y.ACCESSKIT_ENABLED` / `A11Y.DUAL_FOCUS` master domain)
- [x] AC-2(信号 wiring 部分)— OptionButton.item_selected → set_font_size_tier / set_colorblind_mode;CheckBox.toggled → set_high_contrast / set_input_assist / set_accesskit_enabled / set_dual_focus;5 项 toggle 测试用例验证 setter 生效
- [DEFERRED-OOS] AC-2(500ms 防抖落盘)— `#17 Main Menu` Story 005 6-signal coalescing layer 上游所有(本 story Out-of-Scope 第 81 行已声明);本 story setters emit 自身 signal,debounce 由上游订阅
- [DEFERRED-OOS] AC-3(D-Pad 焦点链)— `#17 Main Menu` Story 012 框架上游所有;Container 默认 focus chain 已 wire,实测验证 OQ-A14-ENG-02 Polish playtest

**Test Evidence**: `tests/integration/a11y/settings_ui_injection_test.gd`(new,10 tests)— BLOCKING gate PASS;覆盖 6 控件计数 / OptionButton 项 / 5 项 wiring / 初始 state / null guard

**Code Review**: APPROVED(lean-mode autopilot inline);全静态类型 ✓ | OptionButton item id 编码 enum 整数 + callback 解码模式整洁 ✓ | tr() 全包装 ADR-0010 master domain ✓ | bind() 模式传 OptionButton 实例避免节点查找 ✓ | null container push_warning graceful ✓ | accesskit_enabled schema 字段 + signal + setter + round-trip 持久化 ✓;无 BLOCKING / 无 inline fix

**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0014 Status=Proposed — lean mode 等同 Accepted
2. 新增 schema 字段 `accesskit_enabled: bool = true`(story line 28 "AccessKit 启用 Checkbox" 隐含需要持久化的 toggle);A11yConfig + AccessibilitySettings 同步加挂 + signal `accesskit_enabled_changed`。本字段非 Story 007 预期(Story 007 是 framework switch 不带 toggle),建议 sprint cleanup pass 加 ADR 备注或 retro 至 ADR-0014
3. AC-2 500ms 防抖 + AC-3 D-Pad chain 实测均 OUT-OF-SCOPE 至 `#17 Main Menu` epic;本 story 仅完成 inject framework + setter wiring

**Tech debt**: `A11Y.*` localization keys(6 项)需 writer / loc team 在 ADR-0010 master domain `A11Y` 下创建 csv entries(目前 tr() 缺失 fallback 显示 raw key);记入 a11y epic close-out batch sweep

**API surface**:
- `AccessibilitySettings.inject_settings_ui(group_container: Container) -> void`
- `AccessibilitySettings.accesskit_enabled: bool`(@export,默认 true)
- `AccessibilitySettings.set_accesskit_enabled(enabled: bool) -> void`
- `AccessibilitySettings.accesskit_enabled_changed(enabled: bool)` signal
- `A11yConfig.accesskit_enabled: bool`(持久化字段)
- 6 个 child node names(`FontSizeOption` / `ColorblindOption` / `HighContrastCheck` / `InputAssistCheck` / `AccessKitCheck` / `DualFocusCheck`)固定,便于 `#17 Main Menu` Story 005 信号合流层 find_child 寻位
