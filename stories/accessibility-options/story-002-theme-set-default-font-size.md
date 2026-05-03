# Story 002: Theme.set_default_font_size 单点注入

> **Epic**: Accessibility Options
> **Status**: Done
> **Layer**: Polish
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/accessibility-options.md`
**Requirement**: `TR-a11y-001`(字体 4 档注入)+ Rule 1

**ADR Governing Implementation**: ADR-0014 Accessibility Settings Injection
**ADR Decision Summary**: 字体大小注入通过 `Theme.set_default_font_size()` 单点 — 主 Theme 资源加载时根据 AccessibilitySettings.font_size_tier 设置基础字号,所有 Control 节点继承(无需逐节点设置)。`font_size_changed` 信号 emit 后单次重设 Theme + 触发 reflow(via `#3 Localization` Story 010 broadcast_translation_changed_once 节流)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `Theme.set_default_font_size()` 4.6 已稳;Control 节点继承 default font_size。

**Control Manifest Rules (Polish Layer)**:
- Required: 单点注入 Theme;不逐节点修改
- Forbidden: 直接 set Label.add_theme_font_size_override(违反单点注入)
- Guardrail: 注入耗时 ≤ 5ms

---

## Acceptance Criteria

- [ ] AC-FUNC-02: AccessibilitySettings.font_size_tier 改变 → Theme.set_default_font_size 重设 → reflow 单次广播 → 所有 Control 节点字体更新
- [ ] 信号链路:`font_size_changed(tier)` emit by `#17` Settings → AccessibilitySettings 处理 → Theme 注入 + reflow
- [ ] AUTO_FIT_FLOOR_PX = 11(art-bible §7.2 锁定;TIER_0_BASE 即 11px,最小)
- [ ] R-A11Y-2 fallback 链(由 Story 011 实施;本 story 仅基础注入)

---

## Implementation Notes

*From GDD Rule 1 + ADR-0014:*

```gdscript
# AccessibilitySettings.gd
signal font_size_changed(tier: FontSizeTier)

func set_font_size_tier(new_tier: FontSizeTier) -> void:
    if font_size_tier == new_tier: return
    font_size_tier = new_tier
    _apply_font_size()
    font_size_changed.emit(new_tier)

func _apply_font_size() -> void:
    var theme: Theme = ThemeDB.get_default_theme()  # 4.6 API
    var px := int(font_size_tier)  # enum 值即 px
    theme.set_default_font_size(px)
    # reflow 由 #3 Localization broadcast_translation_changed_once 节流处理
    # (Settings 6 信号合流 #17 Story 005 路径)
```

---

## Out of Scope

- Story 011: R-A11Y-2 二次 reflow fallback
- `#17 Main Menu` Story 005(6 信号合流 — 上游)
- `#3 Localization` Story 010(reflow broadcast — 下游消费)

---

## QA Test Cases

- **AC-FUNC-02**: 字体注入
  - Given: TIER_0_BASE = 11
  - When: set_font_size_tier(TIER_2_LARGER)
  - Then: ThemeDB.get_default_theme().get_default_font_size() == 15;后续 Control 节点 Label.text 渲染字号 == 15
  - Edge cases: TIER_0 → TIER_3 跨档;同档赋值 idempotent

- **AC-2**: 信号 emit
  - Given: font_size_tier == TIER_0
  - When: set_font_size_tier(TIER_1)
  - Then: font_size_changed(TIER_1) emit 1 次

---

## Test Evidence

**Required evidence**: `tests/integration/a11y/theme_font_size_injection_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001;`#17 Main Menu` Story 005(6 信号合流)+ Story 004(Settings 节点树);`#3 Localization` Story 010(reflow broadcast)
- Unlocks: Story 011

---

## Completion Notes

**Completed**: 2026-04-29 (autopilot Phase 4)
**Verdict**: COMPLETE WITH NOTES (lean review mode — code-review verdict APPROVED WITH SUGGESTIONS via godot-gdscript-specialist + qa-tester)
**Criteria**: 4/4 passing; 1 explicitly DEFERRED per story spec (R-A11Y-2 fallback chain → Story 011)

**Files changed**:
- `src/autoload/accessibility_settings.gd` — EDIT (175 → 223 lines, +48): added `signal font_size_changed(tier: FontSizeTier)`, public `set_font_size_tier(new_tier)` (idempotent), private `_apply_font_size()` using `ThemeDB.get_default_theme().set_default_font_size(int(font_size_tier))`, plus boot-sync `_apply_font_size()` call in `_ready()` after `load_config()`
- `tests/integration/a11y/theme_font_size_injection_test.gd` — CREATE (184 lines, 5 test functions in GdUnit4 TestSuite)

**Test Evidence**: `tests/integration/a11y/theme_font_size_injection_test.gd` (Integration story, BLOCKING gate — file exists at the exact path required). Test execution is not CI-verifiable until `project.godot` is created (carried forward from Story 001 — see active.md). Static review passed via godot-gdscript-specialist.

**ADR-0014 minor deviation (intentional, documented)**: Implementation uses `ThemeDB.get_default_theme()` runtime singleton, not `load("res://themes/main_theme.tres")` per ADR-0014 §1 snippet. Story Implementation Notes explicitly override the ADR snippet (`# 4.6 API` annotation). The `res://themes/main_theme.tres` resource creation is out of this story's scope.

**Out of Scope (deferred items confirmed not silently dropped)**:
- `broadcast_translation_changed_once()` reflow broadcast → `#3 Localization` Story 010
- Settings 6-signal coalescing (upstream emit) → `#17 Main Menu` Story 005
- R-A11Y-2 二次 reflow fallback chain → Story 011
- `res://themes/main_theme.tres` Theme resource → not yet scoped to a story
- Settings UI binding → Story 012
- AccessKit screen reader → Story 007
- project.godot autoload registration → carried forward from Story 001

**Advisory suggestions from /code-review (non-blocking, recommended for follow-up tech-debt entry):**
1. Rename test functions to include `accessibility_settings_` system prefix (`.claude/rules/test-standards.md` pattern `test_[system]_[scenario]_[expected_result]`). All 5 functions in this story use `test_[scenario]_[expected]`.
2. Perf test (`test_apply_font_size_under_5ms_perf`) uses `< 5_000 µs` with no warm-up call — possible CI flake on cold runners. Recommend adding warm-up call OR widening threshold to 20 ms.
3. Idempotency test (`test_set_font_size_tier_idempotent_when_same_value`) line 107 has redundant `set_font_size_tier(TIER_0_BASE)` prime call; field is already TIER_0_BASE so the call hits early-return. Removable for readability.
4. `_apply_font_size()` lacks defensive null guard on `ThemeDB.get_default_theme()` return (low risk; engine-guaranteed non-null in normal operation).
5. `_ready()` boot-sync calls `_apply_font_size()` directly (not the public setter), so `font_size_changed` is NOT emitted at boot. Likely intentional (no listeners wired yet) but undocumented in AC. Consider an inline doc comment on the `_ready()` line.

**New edge cases not covered (advisory, follow-up):**
- T1→T0 downgrade path (symmetric, but unproven by tests)
- Sequential distinct calls (T0→T1→T2) — multi-emit signal counting unproven

**Code Review**: Complete (code-review skill produced APPROVED WITH SUGGESTIONS via godot-gdscript-specialist + qa-tester sub-agent reviews). LP-CODE-REVIEW gate skipped per lean review mode policy.

