# Story 008: dual-focus mode 4.6

> **Epic**: Accessibility Options
> **Status**: Complete(implemented 2026-05-01 via autopilot Phase 8;ProjectSettings switch + signal + persistence landed,OQ-A14-ENG-02 Polish playtest deferred to manual milestone)
> **Layer**: Polish
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/accessibility-options.md`
**Requirement**: `TR-a11y-004`

**ADR Governing Implementation**: ADR-0014 + `#2 Input Story 003` dual-focus arbitration
**ADR Decision Summary**: dual-focus mode 4.6 NEW API — `ProjectSettings.input/dual_focus_mode = true` 启用鼠标 + KB/Gamepad 焦点物理分离;鼠标 hover 不抢 KB/Gamepad 焦点(适合双手协作场景 / 残障辅助 + 共享屏幕场景)。

**Engine**: Godot 4.6 | **Risk**: HIGH(via OQ-A14-ENG-02 dual-focus 4.6 实测延 Polish)
**Engine Notes**: dual-focus 4.6 NEW API,实测延 Polish playtest;`#2 Input Handler` Story 003 已实施 arbitration 框架。

**Control Manifest Rules (Polish Layer)**:
- Required: dual-focus 启用通过 ProjectSettings + AccessibilitySettings 字段
- Forbidden: 在游戏循环中切换 dual-focus(应启动期固定)
- Guardrail: dual-focus 切换 ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-08: AccessibilitySettings.dual_focus == true → ProjectSettings.input/dual_focus_mode 启用 → 鼠标 hover 不再触发 Control.focus_entered;键盘焦点独立保持
- [ ] OQ-A14-ENG-02 Polish 实测 PASS — 主菜单 4 按钮 dual-focus 验证(鼠标 + 键盘 同时 focus 不冲突)
- [ ] dual-focus == false 时回归 Godot 默认行为(鼠标 hover 抢键盘焦点)

---

## Implementation Notes

*From GDD ADR-0014 + `#2 Story 003`:*

```gdscript
# AccessibilitySettings.gd
@export var dual_focus: bool = false

func _ready() -> void:
    apply_dual_focus_setting()

func apply_dual_focus_setting() -> void:
    ProjectSettings.set_setting("input/dual_focus_mode", dual_focus)
    # 4.6 NEW API,启动期生效
```

`#2 Input Handler` Story 003 已实施 dual-focus arbitration framework;本 story 通过 a11y settings 启用。

Polish playtest:
- 测试机器:键盘 + 鼠标 + Gamepad 同时连接
- 主菜单进入,鼠标 hover Continue button + 键盘 D-Pad 在 NewRun → ArchiveButton
- 验证:鼠标 hover 显示 hover state,但键盘焦点保持在 D-Pad 当前节点;按 A 键触发的是键盘焦点节点,非鼠标 hover 节点

---

## Out of Scope

- `#2 Input Handler` Story 003(dual-focus arbitration 主体 — 上游)
- Polish stage 实测验证(OQ-A14-ENG-02)

---

## QA Test Cases

- **AC-FUNC-08**: ProjectSettings 启用
  - Given: AccessibilitySettings.dual_focus == false
  - When: set dual_focus = true + apply_dual_focus_setting()
  - Then: ProjectSettings.get_setting("input/dual_focus_mode") == true

- **AC-2 (Polish)**: 鼠标 vs 键盘焦点分离
  - Setup: dual_focus == true + 主菜单
  - Verify: 鼠标 hover ContinueButton + 键盘 D-Pad NewRunButton
  - Pass condition: 鼠标 hover state 可见 + 键盘焦点保持 NewRunButton + 按 A 触发 NewRun

---

## Test Evidence

**Required evidence**:
- `tests/unit/a11y/dual_focus_mode_test.gd` — automated
- `production/qa/evidence/dual-focus-mode-walkthrough.md` — Polish playtest manual

---

## Dependencies

- Depends on: Story 001;`#2 Input Handler` Story 003(dual-focus arbitration)
- Unlocks: 无(OQ-A14-ENG-02 实测 PASS)

---

## Completion Notes

**Completed**: 2026-05-01(autopilot Phase 8,lean-mode dev-story → inline review → story-done)

**Criteria**: 2/3 verifiable AC PASS via 6 unit test 函数;1 DEFERRED-MANUAL(OQ-A14-ENG-02 Polish playtest)
- [x] AC-FUNC-08 — `set_dual_focus(true)` writes ProjectSettings.input/dual_focus_mode = true,`false` 回写 false;`apply_dual_focus_setting()` 直调路径 + signal idempotency 三条用例覆盖
- [x] AC-3 — dual_focus == false 时 ProjectSettings 写回 false → Godot 默认行为(`test_set_dual_focus_false_writes_project_setting_false`)
- [DEFERRED-MANUAL] AC-2 OQ-A14-ENG-02 Polish playtest — 实测 mouse + KB 焦点物理分离 walkthrough 在 `production/qa/evidence/dual-focus-mode-walkthrough.md`(PENDING — 阻塞于 `#17 Main Menu` Story 004 落地后)

**Test Evidence**: `tests/unit/a11y/dual_focus_mode_test.gd`(new,6 tests)— BLOCKING gate PASS;`production/qa/evidence/dual-focus-mode-walkthrough.md` (new,manual playtest plan)

**Code Review**: APPROVED(lean-mode autopilot inline);全静态类型 ✓ | signal-decoupled 模式对齐 Stories 003/004/005 ✓ | idempotent guard ✓ | ProjectSettings before/after snapshot 隔离 ✓ | A11yConfig round-trip 字段加挂 ✓;无 BLOCKING / 无 inline fix

**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR-0014 Status=Proposed — lean mode 等同 Accepted(同 Stories 001-007 precedent)
2. AC-2 Polish playtest 推迟至 `#17 Main Menu` Story 004 落地后(Story body "Out of Scope" 第 62 行已声明)

**Tech debt**: None new(沿用既有 a11y close-out batch sweep)

**API surface**:
- `AccessibilitySettings.dual_focus: bool`(@export,默认 false)
- `AccessibilitySettings.set_dual_focus(enabled: bool) -> void`
- `AccessibilitySettings.apply_dual_focus_setting() -> void`
- `AccessibilitySettings.dual_focus_changed(enabled: bool)` signal
- `AccessibilitySettings.DUAL_FOCUS_PROJECT_SETTING: String` 常量
- `A11yConfig.dual_focus: bool`(持久化字段)
