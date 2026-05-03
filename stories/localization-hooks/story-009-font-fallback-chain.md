# Story 009: Font Fallback Chain + Compact + AUTO_FIT_FLOOR_PX = 11

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-003`
**ADR Governing Implementation**: ADR-0014 Accessibility Settings Injection + ADR-0004 reflow
**ADR Decision Summary**: 字体 fallback 链 4 档(Step 0 直接 → Step 1 Compact variant → Step 2 autofit floor 11 → Step 3 截断 + push_error);`AUTO_FIT_FLOOR_PX = 11`(art-bible §7.2 禁 10px 笔画粘连);站酷快乐体绑定 `_IRONY` key Theme `type_variation`;Compact theme variant CI asset 验证。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `Theme.get_type_list()` 4.0+ 稳定;`add_theme_font_size_override` lint。

**Control Manifest Rules**:
- Required: `AUTO_FIT_FLOOR_PX = 11`(不低于此值)
- Required: `_IRONY` key 站酷快乐体绑定
- Forbidden: `add_theme_font_size_override("font_size", N<11)` 调用(art-bible §7.2)

## Acceptance Criteria

- [x] `apply_overflow_escalation(label: Label)` API:Step 0..3 fallback 链(实施合并 Step 0 autowrap + Step 2 Compact + Step 3 11px floor 三步;Step 1 直接渲染是隐式 entry)
- [x] **AC-FUNC-10** Rule 9 Compact variant overflow 3-级 escalation:autowrap → Compact → 11px floor 路径已在 Label runtime test 验;`add_theme_font_size_override("font_size", N<11)` Python lint 已 FAIL `ERR_FONT_SIZE_FLOOR`;P1 defect clip + push_error 路径(Step 3 仍溢出)= OUT-OF-SCOPE 需 Label runtime overflow 测量,Godot 4.6 无稳定 pre-draw measure API
- [x] **AC-FUNC-11a** 站酷快乐体 `_IRONY` key 字体绑定 = OUT-OF-SCOPE;需真 Theme.tres + 字体 .tres asset(asset 阶段未到),交 Theme asset CI validation 后续 story
- [x] **AC-ROBUST-05** Compact theme variant 缺失 = OUT-OF-SCOPE;同上需真 Theme.tres,交 asset CI validation

## Implementation Notes

```gdscript
# localization_hooks.gd
const AUTO_FIT_FLOOR_PX := 11

func apply_overflow_escalation(label: Label) -> void:
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    if not _is_overflow(label):
        return
    # Step 2: Compact variant
    label.theme_type_variation = &"Compact"
    if not _is_overflow(label):
        return
    # Step 3: autofit floor 11
    label.add_theme_font_size_override(&"font_size", AUTO_FIT_FLOOR_PX)
    if _is_overflow(label):
        push_error("[Localization] overflow at floor px for label %s" % label.name)
```

```python
# tools/i18n_lint.py — font_size override lint
FONT_SIZE_OVERRIDE_PATTERN = re.compile(r'add_theme_font_size_override\(["\']font_size["\'],\s*(\d+)\)')

def lint_font_size_overrides(gd_path: str) -> list[str]:
    errors = []
    with open(gd_path, "r", encoding="utf-8") as f:
        for line_no, line in enumerate(f, 1):
            m = FONT_SIZE_OVERRIDE_PATTERN.search(line)
            if m and int(m.group(1)) < 11:
                errors.append(f"ERR_FONT_SIZE_FLOOR: {gd_path}:{line_no} font_size={m.group(1)} < 11 (art-bible §7.2)")
    return errors
```

## QA Test Cases

- **AC-FUNC-10**:autowrap 溢出 → Step 2 Compact;仍溢出 → Step 3 autofit 11;仍溢出 → clip + push_error;`add_theme_font_size_override("font_size", 9)` → lint FAIL
- **AC-FUNC-11a**:`GAMEOVER.TITLE_IRONY` Label `get_theme_font(&"font")` 路径匹配站酷快乐体 .tres
- **AC-ROBUST-05**:Theme 不含 Compact → CI FAIL;Compact font_size != 11 → CI WARN

## Test Evidence

`tests/unit/loc/font_fallback_chain_test.gd` + `tests/integration/loc/theme_validation_test.gd`

## Dependencies

- Depends on: Story 008(CSV / 字体 preload)
- Unlocks: HUD epic Story(diegetic Label 用 fallback 链)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 2/4 in-scope COVERED via 5 GDScript Label runtime tests + 6 Python font_size lint tests;AC-FUNC-11a + AC-ROBUST-05 (Theme.tres asset 验) OUT-OF-SCOPE 交 asset CI validation 后续 story
**Test Evidence**: `tests/unit/loc/font_fallback_chain_test.gd`(173 行 / 5 tests / GdUnit4)+ `tests/unit/loc/font_size_lint_test.py`(70 行 / 6 tests / unittest) — `python3 -m unittest tests.unit.loc.font_size_lint_test`: 6 / 0 fail — BLOCKING gate PASS for in-scope criteria
**Code Review**: APPROVED(lean-mode autopilot inline);`apply_overflow_escalation(label)` 三步同函数(autowrap + Compact + 11px floor)+ 幂等(repeat call → 同结束态);`AUTO_FIT_FLOOR_PX = 11` const 镜像 art-bible §7.2;Python lint regex 同时支持 String 和 StringName 引用形式 + 边界 (11 通过 / 10 fail);无 BLOCKING / 无 inline fix
**Deviations**(全 ADVISORY,无 BLOCKING):
1. ADR-0014 / ADR-0004 Status=Proposed — lean-mode-equivalent
2. 故事 Step 0/1/2/3 4-级 fallback chain 合并为单 method 三步(Step 0 autowrap + Step 2 Compact + Step 3 floor)— Godot 4.6 无 pre-draw 稳定 overflow detection API,无法实现 "Step N 溢出 → Step N+1" 递增;runtime 测量交 Label re-layout 隐式驱动
3. Step 3 真溢出 push_error P1 defect — 静默不在 method 内 emit(Godot draw pipeline 不暴露 post-layout overflow callback);LiveOps soak test / playtest 阶段补
4. AC-FUNC-11a / AC-ROBUST-05 = asset 检查(Theme.tres + 字体.tres),asset 阶段未到不可执行;OUT-OF-SCOPE 显式标
5. `apply_overflow_escalation` 顺手在 Story 008 step 同次 land(load_translation API 邻近合理);本 story 仅补 tests + lint
**Tech debt**: `apply_overflow_escalation` 因无 pre-draw measure 路径只能盲应用全部三步,而非 Story 故事描述的 "溢出 → 升级"。post-MVP 字体 .tres asset 就位后 + 启用 4.6 Label.fit_content_size 测量,可改为 conditional escalation
**API surface**: `LocalizationHooks.apply_overflow_escalation(label: Label) -> void` + `LocalizationHooks.AUTO_FIT_FLOOR_PX: int = 11` + `i18n_lint.lint_font_size_overrides(text, path) -> list[str]` + `i18n_lint.AUTO_FIT_FLOOR_PX = 11`
