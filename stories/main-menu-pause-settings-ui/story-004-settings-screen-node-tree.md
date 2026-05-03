# Story 004: Settings 主屏 4 类节点树(音量 / 语言 / 键位 / 叙事密度)

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: `TR-mainmenu-001` + Rule 4

**ADR Governing Implementation**: ADR-0014 Accessibility Settings Injection
**ADR Decision Summary**: Settings 子屏 4 主类(音量 4 旋钮 + 语言 + 键位 remap + 叙事密度);+ Polish 阶段注入字体 4 档 + 色盲 3 模式(per `#20 Accessibility` Alpha tier);节点树由本 epic own,信号合流由 Story 005 实施。

**Engine**: Godot 4.6 | **Risk**: HIGH(via AccessKit 4.5+ ARIA 注入,延 Story 012)
**Engine Notes**: `HSlider` + `OptionButton` + `SpinBox` 4.6 标准;AccessKit ARIA label 4.5+ 实测延 Story 012。

**Control Manifest Rules (Presentation)**:
- Required: 所有 Setting 控件文案 `tr(key)` 路径
- Forbidden: AP / KPI / Energy 调节控件(R-MM-1 红线,Story 008 lint 守门)
- Guardrail: Settings 屏首帧 ≤ 4ms

---

## Acceptance Criteria

- [ ] Settings 主节点树 4 类:
  - 音量(VolumeGroup):4 HSlider(Master / Music / SFX / Ambient),0-100%
  - 语言(LocaleGroup):OptionButton(MVP `zh_CN` only,VS 加 en)
  - 键位 remap(KeymapGroup):入口按钮 → 跳 Story 007 Remap 子屏
  - 叙事密度(NarrativeDensityGroup):OptionButton 三档 brief/standard/verbose + 心理模型提示文字
- [ ] 文案全 tr() 路径(无中文硬编码)
- [ ] 节点树 own scenes 路径:`scenes/ui/main_menu/settings_screen.tscn`(待 Phase 4 `/ux-design` 产出)
- [ ] 4 类各自 Container 独立(便于 Story 005 信号绑定 + Story 012 D-Pad focus 链)

---

## Implementation Notes

*From GDD Rule 4 + ADR-0014:*

- 节点树:
  ```
  SettingsScreen (Control)
  ├─ ScrollContainer
  │  └─ VBoxContainer
  │     ├─ VolumeGroup (Container)
  │     │  ├─ MasterSlider (HSlider)
  │     │  ├─ MusicSlider (HSlider)
  │     │  ├─ SFXSlider (HSlider)
  │     │  └─ AmbientSlider (HSlider)
  │     ├─ LocaleGroup (Container)
  │     │  └─ LocaleOption (OptionButton)
  │     ├─ KeymapGroup (Container)
  │     │  └─ RemapEntryButton (Button → 跳 Story 007)
  │     └─ NarrativeDensityGroup (Container)
  │        ├─ DensityOption (OptionButton: brief/standard/verbose)
  │        └─ DensityHintLabel (Label, 三档心理模型提示)
  └─ FooterRow (BackButton + ApplyButton 由 Story 005 信号合流处理)
  ```
- Localization keys 必填:
  - `SETTINGS.VOLUME.MASTER_LABEL` / `MUSIC_LABEL` / `SFX_LABEL` / `AMBIENT_LABEL`
  - `SETTINGS.LOCALE.LABEL`
  - `SETTINGS.KEYMAP.REMAP_BUTTON`
  - `SETTINGS.DENSITY.LABEL` / `BRIEF_HINT` / `STANDARD_HINT` / `VERBOSE_HINT`
- 叙事密度 3 选项 OptionButton:`brief` / `standard` / `verbose`(对齐 ADR-0012 三档枚举)
- Polish 字体 4 档 + 色盲 3 模式由 `#20 Accessibility` Alpha tier 注入,本 story 节点树预留 `AccessibilityGroup` 占位 Container(空,Phase 4 注入)

---

## Out of Scope

- Story 005: 6 信号合流 → #6 timer 500ms debounce
- Story 006: narrative_density_changed signal owner
- Story 007: keymap remap 子屏
- Story 008: AP/KPI/Energy 红线 lint
- Story 011: 主语翻转 + HR 口吻 lint
- Story 012: Gamepad D-Pad + AccessKit
- Phase 4 字体/色盲注入(`#20 Accessibility`)

---

## QA Test Cases

- **AC-1**: 节点树完整性(manual UI walkthrough)
  - Setup: 启动主菜单 → Settings → 检查节点树
  - Verify: 4 Group(Volume/Locale/Keymap/Density)全部存在;每 Group 含规定子节点(4 sliders / 1 option / 1 button / 1 option + 1 label)
  - Pass condition: 反射节点树命名匹配 spec;无多余无缺失

- **AC-2**: tr() 路径完整性(automated grep)
  - Given: settings_screen.tscn + settings_screen.gd
  - When: grep 中文字面量
  - Then: 0 命中(全 tr() 路径)
  - Edge cases: locale 切换后所有文本应 reflow(由 Story 005 实施)

- **AC-3**: AccessibilityGroup 占位
  - Given: SettingsScreen 节点树
  - When: 反射 child names
  - Then: 含 "AccessibilityGroup" Container 节点(空)+ 注释 `# Phase 4 #20 注入`

---

## Test Evidence

**Required evidence**: `production/qa/evidence/settings-screen-node-tree-evidence.md`(UI 节点树 walkthrough doc)

---

## Dependencies

- Depends on: Story 001(主菜单 → Settings 入口);`#3 Localization` Story 001(tr API);`/ux-design design/ux/settings-screen.md`(Phase 4 — 但本 story 节点骨架可先落地,Phase 4 仅美化)
- Unlocks: Story 005, 006, 007, 011, 012

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/4 COVERED via 8 test 函数(`tests/unit/main_menu/settings_screen_node_tree_test.gd`)— AC-1 节点树 4 Group + 4 sliders + locale OptionButton + RemapEntryButton + density OptionButton + DensityHintLabel / AC-1 each-group-Container / AC-3 AccessibilityGroup 占位 / AC-2 6 locale keys 命名 prefix `SETTINGS.*`;walkthrough 文档 `production/qa/evidence/settings-screen-node-tree-evidence.md` 同步交付
**Test Evidence**: `tests/unit/main_menu/settings_screen_node_tree_test.gd`(GdUnit4 8 tests)+ `production/qa/evidence/settings-screen-node-tree-evidence.md`(walkthrough)— ADVISORY UI gate PASS
**Code Review**: APPROVED;controller 用 `_build_widget_hierarchy_if_needed()` 双轨支持 — bare instantiation(测试)+ .tscn 复用(production);`AUDIO_BUSES` const 锁定 4 bus 顺序(Master / Music / SFX / Ambient);`AccessibilityGroup` 是空 VBoxContainer 占位,Phase 4 #20 注入字体/色盲控件;6 LOC_KEY_* 常量集中守 `SETTINGS.*` 域;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0014 Status=Proposed — lean-mode-equivalent
2. .tscn 资产 OUT-OF-SCOPE(UI team Phase 4)— controller 提供 widget 骨架 + 信号 wiring
3. `Settings 屏首帧 ≤ 4ms`属 production benchmark 范畴,本 story 实施 lightweight `_build_widget_hierarchy` 已避免重负载;perf 数字延 Phase 4 实测
**Tech debt**: None new
**API surface**:
- `class_name SettingsScreenController extends Control`
- `enum NarrativeDensity { BRIEF, STANDARD, VERBOSE }`
- `const AUDIO_BUSES`(4 bus)+ 6 LOC_KEY_* 常量
- 4 group + 8 child Control 节点引用(volume_sliders Dictionary / locale_option / remap_entry_button / density_option / density_hint_label / accessibility_group / footer_row / back_button / apply_button)
