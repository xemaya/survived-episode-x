# Story 003: breakdown 三行 HR 渲染 + format_contrib_pct

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: `TR-kpiui-006`

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint Master 8 Domain List
**ADR Decision Summary**: 主语翻转 + HR 戏谑口吻 lint 主域 8 个,KPI / GAMEOVER / EVAL / ARCHIVE 四域均守门。breakdown 三行 HR 文案锚 KPI research §8.1 三行格式("努力系数 / 潜力挖掘 / 工龄加成 + HR 口吻注释")。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `RichTextLabel.set_text()` BBCode 安全;`tr()` 4.6 已稳。format_contrib_pct 纯 GDScript 函数。

**Control Manifest Rules (Presentation)**:
- Required: 所有面向玩家文本 `tr(key)` 不 hardcode 字面量
- Forbidden: 字面 "%" 拼接 + 玩家主语("你的努力"),违反 Anti-P2
- Guardrail: 单帧文本渲染 ≤ 1ms

---

## Acceptance Criteria

- [ ] AC-FUNC-02: 三行 HR 文案 = `KPI.BREAKDOWN.EFFORT_LABEL` + `format_contrib_pct(effort_contrib_pct)` / `KPI.BREAKDOWN.POTENTIAL_LABEL` + 同 / `KPI.BREAKDOWN.TENURE_LABEL` + 同
- [ ] capacity 对比行 = `"old → new"` 格式(数字纯阿拉伯数字,无 emoji 无颜色编码)
- [ ] format_contrib_pct(float) → string,自动加 "%" 符号 + 1 位小数(如 12.3%);负值显示 "−12.3%"(用 U+2212 minus,非 ASCII `-`)
- [ ] 0 hardcoded 中文字面量(全 tr() 调用)

---

## Implementation Notes

*Derived from ADR-0010 + GDD Rule 2:*

- 函数签名:
  ```gdscript
  static func format_contrib_pct(value: float) -> String:
      if is_nan(value) or is_inf(value):
          return "—"  # fallback
      var sign := "−" if value < 0 else "+"  # U+2212 not ASCII
      return "%s%.1f%%" % [sign if value < 0 else "", abs(value) if false else value]
  ```
- Localization keys 必填:
  - `KPI.BREAKDOWN.EFFORT_LABEL`,`KPI.BREAKDOWN.POTENTIAL_LABEL`,`KPI.BREAKDOWN.TENURE_LABEL`
  - `KPI.BREAKDOWN.CAPACITY_COMPARE`(模板 `"{old} → {new}"`)
- 渲染顺序:行 1 EFFORT / 行 2 POTENTIAL / 行 3 TENURE / capacity 对比行 在三行下方
- HR 口吻锁:label 文本须含 HR 戏谑("努力系数已登记" / "潜力挖掘评估" / "工龄加成自动计算"),由 writer 维护 csv

---

## Out of Scope

- Story 004: M1 新人豁免破折号(行 3 的特例)
- Story 013: 主语翻转 lint CI(本 story 仅消费,不实施 lint)

---

## QA Test Cases

- **AC-FUNC-02**: 三行渲染正确性
  - Given: `breakdown = {effort_contrib_pct: 12.3, potential_contrib_pct: -5.0, tenure_contrib_pct: 2.1}`
  - When: `_render_breakdown(breakdown)` 调用
  - Then: 行 1 = "[tr(EFFORT_LABEL)] +12.3%" / 行 2 = "[tr(POTENTIAL_LABEL)] −5.0%" / 行 3 = "[tr(TENURE_LABEL)] +2.1%"
  - Edge cases: NaN value → "—";极大值 99.9% / -99.9% 不溢出

- **AC-2**: capacity 对比行
  - Given: `capacity_old=0.95, capacity_new=0.92`
  - When: 渲染
  - Then: 文本含 "0.95 → 0.92"(精度保留 2 位小数)

- **AC-3**: 无 hardcoded 字面量
  - Given: 静态分析扫描 `kpi_review_panel.gd`
  - When: grep 中文字符直接量
  - Then: 0 命中(全部 tr() 调用)

---

## Test Evidence

**Required evidence**: `tests/unit/kpi_ui/breakdown_three_line_render_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001(state machine 进入 ACTIVE 态);`#9 KPI` Story 002(F1 next_threshold + breakdown 计算);`#3 Localization` Story 001(tr API)
- Unlocks: Story 004(行 3 M1 特例)

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 7 test 函数 in `tests/unit/kpi_ui/breakdown_three_line_render_test.gd`
**Test Evidence**: `tests/unit/kpi_ui/breakdown_three_line_render_test.gd` (108 行 / 7 tests / GdUnit4) — BLOCKING gate PASS
- AC-FUNC-02 三行 HR 渲染 → `test_three_line_labels_use_tr_and_signed_pct`
- format_contrib_pct sign + U+2212 → `test_format_contrib_pct_positive_has_plus` + `test_format_contrib_pct_negative_uses_u2212` + `test_format_contrib_pct_zero_is_plus_zero` + `test_format_contrib_pct_nan_is_em_dash`
- capacity 对比 "old → new" → `test_capacity_compare_two_decimal`
- 0 hardcoded 中文字面量 → `test_no_hardcoded_chinese_literal` (CJK glyph grep)

**Code Review**: APPROVED;static `format_contrib_pct(float) -> String` 处理 NaN/Inf 兜底;tr() 全 key 化;无 BLOCKING
**Deviations** (1 项 ADVISORY):
1. csv 实际 HR 戏谑文案由 writer Phase 4 维护 — 本 story 仅消费 key
**Tech debt**: None new
**API surface**: `format_contrib_pct(value: float) -> String` (static) + `_render_breakdown(breakdown: Dictionary)` + 7 LOC_KEY_* 常量
