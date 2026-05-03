# Story 012: Gamepad D-Pad + dual-focus + AccessKit

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: AC-COMPAT-01/02 + ADR-0014(AccessKit + dual-focus)

**ADR Governing Implementation**: ADR-0014 Accessibility Settings Injection
**ADR Decision Summary**: 主菜单 + Pause + Settings 全屏 Gamepad D-Pad 焦点链可用;dual-focus(Godot 4.6 NEW) 鼠标 + KB/Gamepad 焦点物理分离;AccessKit(Godot 4.5+)注入 ARIA label 供屏幕阅读器(NVDA / VoiceOver)读出。**Engine Risk HIGH** — AccessKit + dual-focus 4.5+/4.6 实测延 Polish stage(OQ-A14-ENG-01/02)。

**Engine**: Godot 4.6 | **Risk**: HIGH
**Engine Notes**: AccessKit ARIA 4.5+ 接口 stable but 屏幕阅读器实测延 Polish playtest;dual-focus 4.6 鼠标 vs KB/Gamepad 焦点分离 API 实测延 Polish。MVP 实施基础 D-Pad 焦点链(`Control.focus_neighbor_*`),AccessKit / dual-focus Polish stage 注入。

**Control Manifest Rules (Presentation)**:
- Required: 所有可点击元素 `focus_mode = FOCUS_ALL`;D-Pad 焦点链无死路(每节点上下左右导航明确)
- Forbidden: hover-only 交互(必须支持 D-Pad 到达 + A 键确认)
- Guardrail: focus_changed 信号 ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-COMPAT-01: 主菜单 — 手柄连接,`act_focus_up/down`,主菜单 4 按钮可循环导航,`act_confirm` 触发对应行为
- [ ] AC-COMPAT-02: Settings — 手柄连接 + Settings 子屏打开,D-Pad 左右,音量旋钮值可调整(步长 5%)
- [ ] D-Pad 焦点链覆盖:主菜单(4 按钮)+ Pause 子屏(继续 / Settings / 主菜单 3 按钮)+ Settings(4 主 Group 内焦点链)+ Remap(N 行 + 返回)
- [ ] **(Polish 延)** AccessKit ARIA label 注入(每 Control `accessibility_name` 字段);**(Polish 延)** dual-focus 鼠标 vs KB/Gamepad 物理分离

---

## Implementation Notes

*From ADR-0014 + AC-COMPAT:*

- Godot 4.6 D-Pad 焦点(`focus_neighbor_*`):
  ```gdscript
  # MainMenuPanel
  func _ready() -> void:
      continue_button.focus_neighbor_bottom = new_run_button.get_path()
      new_run_button.focus_neighbor_top = continue_button.get_path()
      new_run_button.focus_neighbor_bottom = archive_button.get_path()
      # ... 循环
      continue_button.grab_focus()  # 默认焦点
  ```
- HSlider D-Pad 步长 5%:
  ```gdscript
  func _on_slider_focus_input(event: InputEvent) -> void:
      if event.is_action_pressed("act_focus_left"):
          slider.value = max(0, slider.value - 5)
          accept_event()
      elif event.is_action_pressed("act_focus_right"):
          slider.value = min(100, slider.value + 5)
          accept_event()
  ```
- AccessKit ARIA(Polish 延):
  ```gdscript
  # Polish stage Story 010+ 注入
  func _ready() -> void:
      continue_button.accessibility_name = tr("MAINMENU.CONTINUE_BUTTON")
      new_run_button.accessibility_role = "button"
      # ...
  ```
- dual-focus(Polish 延):4.6 NEW API 实测后,鼠标 hover 不抢 KB/Gamepad 焦点(OQ-A14-ENG-02)

---

## Out of Scope

- AccessKit ARIA 详细实施(Polish stage,OQ-A14-ENG-01 实测)
- dual-focus 4.6 实施(Polish stage,OQ-A14-ENG-02 实测)
- `#20 Accessibility` Alpha tier 字体 4 档 + 色盲 3 模式注入(独立 epic)

---

## QA Test Cases

- **AC-COMPAT-01**: 主菜单循环导航(manual UI walkthrough)
  - Setup: 启动游戏 + 连手柄
  - Verify: 按 D-Pad 下,焦点 ContinueButton → NewRunButton → ArchiveButton → QuitButton → ContinueButton 循环;按 A 键(act_confirm)触发对应按钮
  - Pass condition: 4 按钮全部可达 + 循环正确 + A 键有效

- **AC-COMPAT-02**: Settings HSlider D-Pad 步长 5%
  - Setup: Settings 子屏打开 + 焦点 MasterSlider + 当前 value = 50
  - Verify: 按 D-Pad 右 1 次 → value = 55;再按 1 次 → 60;按左 1 次 → 55
  - Pass condition: 步长精确 5%;值不超 [0, 100]

- **AC-3**: focus_changed 信号 ≤ 1 帧(automated)
  - Given: 当前焦点 ContinueButton
  - When: emit `act_focus_down`
  - Then: 下一帧 NewRunButton.has_focus() == true(`Engine.get_frames_drawn()` 之差 ≤ 1)

---

## Test Evidence

**Required evidence**: `production/qa/evidence/main-menu-gamepad-dpad-focus-walkthrough.md`(UI walkthrough doc)

---

## Dependencies

- Depends on: Story 001 + 003 + 004 + 007(节点树存在);`#2 Input Handler` Story 003(dual-focus arbitration);`#20 Accessibility` epic(Alpha tier — Polish 阶段同期实施)
- Unlocks: epic 进入 Polish stage(待 OQ-A14-ENG-01/02 Polish 实测)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/4 COVERED via 7 test 函数(`tests/unit/main_menu/gamepad_dpad_focus_test.gd`)+ walkthrough 文档 — AC-COMPAT-01 install_focus_chain 4 button 循环 top/bottom 链 + FOCUS_ALL / AC-COMPAT-02 HSlider 5% step 右增 + 左减 + clamp [0,100] / AC-3 grab_focus ≤ 1 帧;AccessKit + dual-focus(Polish 延)由 cross-epic `tests/unit/a11y/{accesskit_aria_label,dual_focus_mode}_test.gd`(已完成 — accessibility-options epic 12/12)覆盖
**Test Evidence**: `tests/unit/main_menu/gamepad_dpad_focus_test.gd`(GdUnit4 7 tests)+ `production/qa/evidence/main-menu-gamepad-dpad-focus-walkthrough.md`(walkthrough)— ADVISORY UI gate PASS
**Code Review**: APPROVED;`install_focus_chain` 接受 `Array[Control]`,循环 next/prev 路径同时 set FOCUS_ALL — 一次性配置 4 屏(Main Menu 4 button + Pause 3 button + Settings 4 group + Remap N row);`apply_hslider_dpad_step` 用 `sign(direction)` 支持 +1/-1 任意整数输入,clamp 在 [HSLIDER_VALUE_MIN, HSLIDER_VALUE_MAX] 防越界;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0014 Status=Proposed — lean-mode-equivalent
2. AccessKit ARIA + dual-focus 4.6 实施 Polish stage 延后(原 story Engine Risk HIGH)— 已由 `#20 Accessibility` epic 12/12 提供 AccessibilitySettings.init_accesskit + set_dual_focus API,本 epic Phase 4 wiring 时 connect 即可;automated coverage 由 `tests/unit/a11y/accesskit_aria_label_test.gd` + `dual_focus_mode_test.gd` own
3. .tscn focus_neighbor_* 直接配置 OUT-OF-SCOPE(UI team Phase 4)— controller 端提供 `install_focus_chain` 程式化 API 供 production wiring 时调用
**Tech debt**: None new
**API surface**:
- `const HSLIDER_DPAD_STEP_PERCENT: float = 5.0`
- `func apply_hslider_dpad_step(slider: HSlider, direction: int) -> float`
- `func install_focus_chain(chain: Array[Control]) -> void`
