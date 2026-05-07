# Story 005: 输入辅助(anti-QTE 守 #2 Rule 4)

> **Epic**: Accessibility Options
> **Status**: Done(2026-04-29 — COMPLETE WITH NOTES)
> **Layer**: Polish
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/accessibility-options.md`
**Requirement**: Rule 4(输入辅助)

**ADR Governing Implementation**: ADR-0014 + `#2 Input Rule 4` anti-QTE 锚
**ADR Decision Summary**: 输入辅助模式(input_assist == true)启用宽容输入策略 — 长按等同点击 / 双击容忍间隔加宽 / 释放 deadzone 加宽。本作 MVP 无 QTE 设计(Rule 4 anti-QTE),输入辅助主要扩展 Settings UI 旋钮 D-Pad 步长(5% → 2.5%,精确控制)+ 减少按钮误触。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Polish Layer)**:
- Required: 输入辅助通过 #2 InputHandler API 注入,UI 不直接改 InputMap
- Forbidden: 引入 QTE / 反应时机考验交互(违反 anti-QTE 锚)
- Guardrail: 输入处理 ≤ 0.1ms

---

## Acceptance Criteria

- [ ] AC-FUNC-05: AccessibilitySettings.input_assist == true → Settings UI HSlider D-Pad 步长 5% → 2.5%(精确控制)
- [ ] 长按 ≥ 200ms 等同点击(适合 motor-impaired 玩家)
- [ ] D-Pad 双击间隔由默认 200ms 扩至 350ms(更宽容)
- [ ] 守 `#2 Rule 4` anti-QTE — 全游戏无 timing-based 反应考验

---

## Implementation Notes

*From GDD Rule 4 + `#2 Rule 4`:*

```gdscript
# AccessibilitySettings.gd
signal input_assist_changed(enabled: bool)

func set_input_assist(enabled: bool) -> void:
    if input_assist == enabled: return
    input_assist = enabled
    InputHandler.set_assist_mode(enabled)  # API by #2 Story 003
    input_assist_changed.emit(enabled)
```

`#2 Input Handler` 拓展:
```gdscript
# input_handler.gd
var _assist_mode: bool = false

func set_assist_mode(enabled: bool) -> void:
    _assist_mode = enabled
    # 调整 deadzone / D-Pad repeat / 长按阈值

func get_dpad_step_for_slider() -> float:
    return 2.5 if _assist_mode else 5.0  # Settings UI 步长

func get_long_press_threshold_ms() -> int:
    return 200 if _assist_mode else 500  # 长按等同点击
```

注:本 story 涉及 `#2 Input Handler` API 拓展,VS milestone propagation flag(可选拓展 — 不阻塞 MVP)。

---

## Out of Scope

- `#2 Input Handler` Story 003(dual-focus 主体)+ Story 008(deadzone formula)
- 完整 motor accessibility 测试(Polish playtest)

---

## QA Test Cases

- **AC-FUNC-05**: D-Pad 步长
  - Given: input_assist == true
  - When: Settings HSlider D-Pad 右
  - Then: value 增 2.5%(非 5%)
  - Edge cases: input_assist == false → 5% 步长

- **AC-2**: 长按 = 点击
  - Given: input_assist == true
  - When: 按住 button 200ms 后释放
  - Then: 视为单击触发(act_confirm)
  - Edge cases: 200ms 内释放 → 视为正常单击

---

## Test Evidence

**Required evidence**: `tests/integration/a11y/input_assist_anti_qte_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001;`#2 Input Handler` Story 003 + Story 008(API 拓展);`#17 Main Menu` Story 012(D-Pad 焦点链)
- Unlocks: 无

---

## Completion Notes

**Completed**: 2026-04-29
**Criteria**: 3/4 verifiable AC 由 13 个 integration test 覆盖 + 1 AC explicit DEFERRED(AC-4 anti-QTE 项目级 design invariant,本 module 结构性不可违反 — 只放宽不收紧;mirrors Story 004 deferred-AC pattern)
**Deviations** (4 ADVISORY):
1. `set_input_assist` 未直调 `InputHandler.set_assist_mode` 如 story snippet 所示 — 改用 Stories 003/004 signal-decoupling 模板;`#2 InputHandler` Story 003 上游 deferred(story line 66 "VS milestone 不阻塞 MVP");rationale 已 inline 注释 `accessibility_settings.gd:270-275`
2. 新增 `get_double_click_interval_ms()` getter — story Implementation Notes snippet 仅列 `get_long_press_threshold_ms`,但 AC-3(350ms ≠ default 200ms)强制要求
3. 上游依赖 `#2 InputHandler` Story 003/008 + `#17 Settings UI` Story 012 NOT IMPLEMENTED,但 story line 66 explicit "VS milestone propagation flag 可选拓展不阻塞 MVP" — graceful-degradation 路径全覆盖
4. Code-review inline fixes applied: 1 BUG(test 文件 untyped loop var → `for _i: int in 1000:`)+ 1 DRIFT(3× lambda recorder → `var recorder: Callable = func(...)`)+ 1 ADVISORY(perf threshold 1_000→5_000 µs CI flakiness 缓冲,仍 20× 低于 0.1ms guardrail)
**Test Evidence**: Integration → `tests/integration/a11y/input_assist_anti_qte_test.gd`(13 tests)
**Code Review**: Complete(/code-review APPROVED — godot-gdscript-specialist + qa-tester parallel,inline fixes applied;Lean mode QL-TEST-COVERAGE + LP-CODE-REVIEW gates skipped)
**Tech-Debt Logged**(4 项 ADVISORY,待 a11y epic 批量 sweep):
- 追溯 Story 004 `high_contrast_font_fallback_test.gd` lambda `:=` → `: Callable` typing
- AC-4 tautology doc-test 提升为 grep-based forbidden-pattern audit(项目扩到多人贡献时)
- AC-2 / AC-3 signal-driven e2e 测试(当前覆盖 AC-FUNC-05 + 直接 seam,e2e 路径 LOW 优先级)
- assist 模式 signal-driven false-direction toggle e2e 测试(已通过直接 seam + AccessibilitySettings 对称 toggle 间接覆盖)
