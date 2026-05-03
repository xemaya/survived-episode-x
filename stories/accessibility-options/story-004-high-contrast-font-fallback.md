# Story 004: 高对比度模式 + 字体 fallback 链

> **Epic**: Accessibility Options
> **Status**: Done(Alpha milestone)
> **Layer**: Polish
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/accessibility-options.md`
**Requirement**: `TR-a11y-001`(高对比度)+ `TR-a11y-006` + Rule 3

**ADR Governing Implementation**: ADR-0014 + ADR-0004 Settings Reflow Coalescing
**ADR Decision Summary**: 高对比度模式叠加 contrast curve shader(独立于色盲 LUT);字体 fallback 链 art-bible §7.2 — 思源黑体 → Noto Sans CJK → 系统默认。AUTO_FIT_FLOOR_PX = 11px(R-A11Y-2 二次 reflow fallback 在 Story 011)。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Polish Layer)**:
- Required: 高对比度叠加色盲 LUT 之上(layer 顺序)
- Forbidden: 字体 hardcode 单一字体(违反 fallback 链)
- Guardrail: shader ≤ 0.5ms / 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-04: AccessibilitySettings.high_contrast 改为 true → 整屏 contrast 增强(亮 +20% / 暗 -20%);UI 文字与背景对比度 ≥ 4.5:1(WCAG AA)
- [ ] 字体 fallback 链:思源黑体 Regular(主)→ Noto Sans CJK(回退)→ 系统默认(最终回退)
- [ ] AUTO_FIT_FLOOR_PX = 11(art-bible §7.2 锁定,与 `#3 Localization` Story 009 一致)

---

## Implementation Notes

*From GDD Rule 3 + ADR-0014:*

```gdscript
# 高对比度 shader 在 colorblind_post_process.gd 之上叠加
@onready var high_contrast_overlay: ColorRect = $HighContrastOverlay

func _ready() -> void:
    AccessibilitySettings.high_contrast_changed.connect(_on_high_contrast_changed)

func _on_high_contrast_changed(enabled: bool) -> void:
    high_contrast_overlay.visible = enabled
    # high_contrast shader: contrast curve, brightness +20% in highlights, -20% in shadows
```

字体 fallback 链(`#3 Localization` Story 009 已实施;本 story 仅 a11y 启用时保证 fallback 优先级正确):
```gdscript
# Theme 设置 fallback 链
theme.default_font.fallbacks = [
    preload("res://assets/fonts/source_han_sans_regular.ttf"),
    preload("res://assets/fonts/noto_sans_cjk.ttf"),
    # system default 由 OS fallback
]
```

---

## Out of Scope

- Story 003: 色盲 LUT(独立)
- Story 011: R-A11Y-2 二次 reflow fallback
- `#3 Localization` Story 009(font_fallback_chain — 上游已实施)

---

## QA Test Cases

- **AC-FUNC-04**: 对比度增强
  - Given: high_contrast == false → 测对比度
  - When: set high_contrast = true
  - Then: 测试桩屏幕截图,WCAG contrast ratio ≥ 4.5:1
  - Edge cases: 与 colorblind 模式同时启用 → 两 shader 叠加(layer 顺序正确)

- **AC-2**: 字体 fallback
  - Given: 缺思源黑体 fixture
  - When: 渲染中文 Label
  - Then: Noto Sans CJK 字体生效;字号 ≥ 11px
  - Edge cases: 两 fallback 都缺 → 系统字体兜底,不崩溃

---

## Test Evidence

**Required evidence**: `tests/unit/a11y/high_contrast_font_fallback_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001 + 003;`#3 Localization` Story 009(font fallback chain)
- Unlocks: 无

---

## Completion Notes

**Completed**: 2026-04-29
**Verdict**: COMPLETE WITH NOTES
**Manifest Version**: 2026-04-28 (matched current — no staleness)
**Review Mode**: Lean (QL-TEST-COVERAGE + LP-CODE-REVIEW gates skipped per `production/review-mode.txt`)

### Acceptance Criteria: 3/3 verifiable covered + 3 deferred

- [x] AC-FUNC-04 (signal + visibility + layer ordering + idempotency + perf):
  covered by 7 unit tests (set_high_contrast emit-once, true→false symmetric,
  idempotent same-value no-op, signal-routed _apply_state, layer == 101,
  off-state hides ColorRect, _apply_state perf < 5ms)
- [x] AC-2 (font fallback chain semantics):
  covered by 2 unit tests (no-files graceful path + install-success path via
  `install_font_fallback_chain(primary, fallbacks)` testable helper using
  `SystemFont.new()` synthetic Fonts — no .ttf I/O required)
- [x] AC-3 (AUTO_FIT_FLOOR_PX = 11 + consistency invariant with FontSizeTier.TIER_0_BASE):
  covered by 2 unit tests
- [?] WCAG 4.5:1 contrast ratio measurement — DEFERRED: Polish-stage playtest
  (visual measurement, not unit-testable)
- [?] Real .ttf font rendering (思源黑体 / Noto Sans CJK) — DEFERRED: Phase 4
  art deliverable (files not in repo; install-success path tested with
  synthetic SystemFont stand-ins)
- [?] Shader ≤ 0.5 ms / frame GPU perf — DEFERRED: Polish-stage playtest on
  target hardware (OQ-A14-PERF-01)

### Files Implemented

- `src/autoload/accessibility_settings.gd` — EDIT: high_contrast_changed signal
  + set_high_contrast() + apply_font_fallback_chain() + install_font_fallback_chain()
  testable helper + AUTO_FIT_FLOOR_PX/FONT_PRIMARY_PATH/FONT_FALLBACK_CJK_PATH
  consts + _font_primary_path/_font_fallback_cjk_path test seams + _ready()
  boot-time call
- `src/autoload/high_contrast_post_process.gd` — CREATE: CanvasLayer autoload at
  layer 101 (above colorblind layer 100), mirrors Story 003 ColorblindPostProcess
  pattern
- `assets/shaders/high_contrast/high_contrast_post.gdshader` — CREATE: per-channel
  midpoint-pivoted contrast curve `(rgb-0.5)*1.4+0.5` with clamp[0,1]; matches
  AC-FUNC-04 +/-20% spec exactly via contrast_factor=1.4 around midpoint=0.5
- `tests/unit/a11y/high_contrast_font_fallback_test.gd` — CREATE: 12 test
  functions covering all 3 verifiable ACs + edges + perf

### Deviations

- **ADVISORY**: Story Implementation Notes use `preload(...)` for .ttf files;
  implementation uses `ResourceLoader.exists()` + `ResourceLoader.load()` to
  avoid parse-time crash on missing Phase-4 .ttf files. Behaviour-equivalent
  for present-files case; gracefully degrades when absent. (Story 003 lesson
  carried forward.)
- **ADVISORY**: Loc Story 009 (font_fallback_chain) dependency `Status: Ready`,
  not `Done`. Story 004 header explicitly marks "上游已实施" + Out-of-Scope;
  Story 004 implementation has no hard code coupling to Loc Story 009 work.
  Risk: LOW.
- **ADVISORY**: Story spec implies single `high_contrast_overlay` ColorRect
  added to existing CanvasLayer; implementation chose dedicated
  `HighContrastPostProcess` autoload class mirroring Story 003 pattern for
  layer-ordering testability + decoupling.
- **ADVISORY**: `LAYER_TOP = 101` (gap of 1 above colorblind 100). Suggested
  by gdscript-specialist to widen to 110 or 105 for future insertions —
  deferred to follow-up if/when an intermediate post-process is needed.

### Code Review Inline Fixes Applied

- **REQUIRED bug**: 4× `push_warning()` calls in `apply_font_fallback_chain()`
  had GDScript `%` operator precedence error (`%` binds tighter than `+`,
  format specifier `%s` was in early concat segment but `%` only saw last
  segment). Rewrote each as single string + `%` to avoid the multi-line `+`
  ambiguity.
- **BLOCKING gap (qa-tester GAP-001)**: AC-2 install-success path was
  untestable without real .ttf files. Refactored to extract
  `install_font_fallback_chain(primary, fallbacks)` testable helper; new test
  uses `SystemFont.new()` synthetic Fonts to verify ThemeDB.default_font +
  fallbacks slot 0 — no I/O required.
- **ADVISORY (qa-tester GAP-002)**: Symmetric true→false signal payload test
  added.

### Tech Debt Logged

- Shader inline branch `if (enabled == 0)` → could use `mix()` for shader-rule
  compliance (suggestion, low priority)
- Shader file naming: both `high_contrast_post.gdshader` and Story 003
  `colorblind_post.gdshader` could rename together to project convention
  `[type]_[category]_[name]` — defer to a11y epic batch sweep
- Shader alpha: `colorblind_post.gdshader` hard-codes `1.0` while
  high_contrast preserves `c.a` — align in batch sweep
- qa-tester GAP-003 (primary-present + CJK-absent branch untested) — needs
  fixture stub, low priority (non-crash path)
- qa-tester GAP-004 (false→false idempotency untested) — same code path,
  trivial to add later
- qa-tester GAP-005 (test naming convention `test_[system]_...`) — a11y epic
  cross-story alignment with qa-lead
- qa-tester GAP-006 (re-runnable end-state untested) — downstream of GAP-003

### Test Evidence

**Story Type**: Logic (BLOCKING gate)
**Required**: `tests/unit/a11y/high_contrast_font_fallback_test.gd`
**Found**: YES — exact path matches; 12 test functions covering all 3
verifiable ACs.

### Forbidden Patterns Confirmed Absent

- No `OS.get_ticks_msec()` (uses `Time.get_ticks_usec()`)
- No `preload()` of optional Phase-4 assets
- No `add_theme_font_size_override()` per-Label
- No string-based `connect("signal", obj, "method")` syntax
- No untyped `Array` / `Dictionary`
- No per-Sprite2D `ColorBlindMaterial` override (correct CanvasLayer post-process)
